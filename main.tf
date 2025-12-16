terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = "default"
}

# IAM stays in root (shared by both Lambdas)
resource "aws_iam_role" "lambda_role" {
  name = "${var.project}-${var.env}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem", "dynamodb:Scan"]
        Resource = module.db.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

# DynamoDB
module "db" {
  source = "./modules/dynamodb"
  name   = "${var.project}-${var.env}-table"
}

# Root Lambda: /
module "lambda_root" {
  source        = "./modules/lambda"
  function_name = "${var.project}-${var.env}-lambda"
  handler       = "handler.root_handler"
  role_arn      = aws_iam_role.lambda_role.arn
  source_dir    = "${path.root}/lambda"
  env_vars = {
    TABLE_NAME = module.db.name
    STAGE      = var.env
  }
}

# Items Lambda: /items
module "lambda_items" {
  source        = "./modules/lambda"
  function_name = "${var.project}-${var.env}-items"
  handler       = "handler.items_handler"
  role_arn      = aws_iam_role.lambda_role.arn
  source_dir    = "${path.root}/lambda"
  env_vars = {
    TABLE_NAME = module.db.name
    STAGE      = var.env
  }
}

# API Gateway
module "api" {
  source   = "./modules/apigw"
  api_name = "${var.project}-${var.env}-api"
  stage    = var.env

  root_invoke_arn  = module.lambda_root.invoke_arn
  items_invoke_arn = module.lambda_items.invoke_arn

  root_fn_name  = module.lambda_root.function_name
  items_fn_name = module.lambda_items.function_name
}
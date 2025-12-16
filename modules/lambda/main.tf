variable "function_name" { type = string }
variable "handler"       { type = string }
variable "role_arn"      { type = string }
variable "source_dir"    { type = string }
variable "env_vars"      { type = map(string) }

data "archive_file" "zip" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = "${path.module}/${var.function_name}.zip"
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = var.role_arn
  handler       = var.handler
  runtime       = "python3.11"

  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256

  environment {
    variables = var.env_vars
  }
}
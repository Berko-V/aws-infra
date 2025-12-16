variable "api_name" { type = string }
variable "stage" { type = string }

variable "root_invoke_arn" { type = string }
variable "items_invoke_arn" { type = string }

variable "root_fn_name" { type = string }
variable "items_fn_name" { type = string }

resource "aws_api_gateway_rest_api" "api" {
  name = var.api_name
}

# /
resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_rest_api.api.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "proxy" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_rest_api.api.root_resource_id
  http_method             = aws_api_gateway_method.proxy.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.root_invoke_arn
}

# /items
resource "aws_api_gateway_resource" "items" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "items"
}

resource "aws_api_gateway_method" "items" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.items.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "items" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.items.id
  http_method             = aws_api_gateway_method.items.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.items_invoke_arn
}

resource "aws_api_gateway_deployment" "deploy" {
  depends_on = [
    aws_api_gateway_integration.proxy,
    aws_api_gateway_integration.items,
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id

  # redeploy when integration URIs change
  triggers = {
    redeploy = sha1(jsonencode({
      root_uri  = aws_api_gateway_integration.proxy.uri
      items_uri = aws_api_gateway_integration.items.uri
    }))
  }

  lifecycle { create_before_destroy = true }
}

resource "aws_api_gateway_stage" "stage" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.deploy.id
  stage_name    = var.stage
}

resource "aws_lambda_permission" "root" {
  action        = "lambda:InvokeFunction"
  function_name = var.root_fn_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "items" {
  action        = "lambda:InvokeFunction"
  function_name = var.items_fn_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/*"
}
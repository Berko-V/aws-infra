data "aws_region" "current" {}

output "api_id" {
  value = aws_api_gateway_rest_api.api.id
}

output "base_url" {
  value = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${var.stage}/"
}

output "items_url" {
  value = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${var.stage}/items"
}
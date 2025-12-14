output "base_url" {
  description = "Base invoke URL for the API Gateway stage (trailing slash included)"
  value       = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.region}.amazonaws.com/${var.env}/"
}

output "items_url" {
  description = "Invoke URL for the /items route"
  value       = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.region}.amazonaws.com/${var.env}/items"
}

# Backward-compatible alias (optional)
# Keeps older commands like `terraform output -raw invoke_url` working
output "invoke_url" {
  description = "Alias for base_url (trailing slash included)"
  value       = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.region}.amazonaws.com/${var.env}/"
}
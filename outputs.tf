output "base_url" {
  description = "Base invoke URL for the API Gateway stage (trailing slash included)"
  value       = module.api.base_url
}

output "items_url" {
  description = "Invoke URL for the /items route"
  value       = module.api.items_url
}

# Backward-compatible alias (optional)
output "invoke_url" {
  description = "Alias for base_url (trailing slash included)"
  value       = module.api.base_url
}
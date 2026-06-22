output "fqdn" {
  description = "Public app URL hostname"
  value       = var.domain_name
}

output "app_url" {
  description = "Full HTTPS URL for the app"
  value       = "https://${var.domain_name}"
}
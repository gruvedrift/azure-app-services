# Nice to have outputs for automation
output "acr_login_server" {
  description = "Login server for ACR"
  value       = azurerm_container_registry.tiny-flask-cr.login_server
}

output "acr_name" {
  description = "ACR name"
  value       = azurerm_container_registry.tiny-flask-cr.name
}

output "web_app_url" {
  description = "URL for web app"
  value       = "https://${azurerm_linux_web_app.tiny-flask.default_hostname}"
}



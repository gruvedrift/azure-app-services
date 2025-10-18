# Login server
output "acr_login_server" {
  description = "Login server for ACR"
  value       = azurerm_container_registry.tiny-flask-cr.login_server
}
# ACR name
output "acr_name" {
  description = "ACR name"
  value       = azurerm_container_registry.tiny-flask-cr.name
}
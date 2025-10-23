output "web_app_url" {
  description = "Web app URL"
  value       = "https://${azurerm_windows_web_app.dotnet-web-app.default_hostname}"
}

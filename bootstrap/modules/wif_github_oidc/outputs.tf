
output "client_id" {
  value = azuread_application.app.client_id
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}
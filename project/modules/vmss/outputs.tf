output "vmss_id" {
  value = azurerm_linux_virtual_machine_scale_set.vmss.id
}

output "vmss_name" {
  value = azurerm_linux_virtual_machine_scale_set.vmss.name
}

output "identity_id" {
  value = azurerm_user_assigned_identity.this.id
}

output "identity_client_id" {
  value = azurerm_user_assigned_identity.this.client_id
}

output "identity_principal_id" {
  value = azurerm_user_assigned_identity.this.principal_id
}
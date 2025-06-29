output "storage_account_name" {
  description = "The name of the storage account used for the Terraform remote backend"
  value       = azurerm_storage_account.tfstate.name
}

output "storage_container_name" {
  description = "The name of the container in the storage account for Terraform state"
  value       = azurerm_storage_container.tfstate.name
}

output "storage_account_id" {
  description = "The full ARM ID of the storage account (used for role assignments)"
  value       = azurerm_storage_account.tfstate.id
}

# created manually see not in module bootstrap/modules/wif_github_oidc
# output "wif_client_id" {
#   description = "Client ID of the Azure AD application used by GitHub Actions (OIDC)"
#   value       = module.wif_oidc.client_id
# }
#
# output "wif_tenant_id" {
#   description = "Tenant ID required by GitHub Actions for Azure login"
#   value       = module.wif_oidc.tenant_id
# }


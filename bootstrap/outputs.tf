#
# output "project_id" {
#   value = google_project.project.project_id
# }
#
# output "terraform_sa_email" {
#   value = google_service_account.terraform.email
# }


output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "terraform_sp_object_id" {
  value = azuread_service_principal.terraform.id
}

output "terraform_sp_app_id" {
  value = azuread_application.terraform.application_id
}

output "terraform_state_storage_account" {
  value = azurerm_storage_account.tfstate.name
}

output "terraform_state_container_name" {
  value = azurerm_storage_container.tfstate.name
}

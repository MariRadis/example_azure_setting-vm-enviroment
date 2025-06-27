

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# Terraform Deployment Identity (Service Principal)
resource "azuread_application" "terraform" {
  display_name = "terraform-app"
}

resource "azuread_service_principal" "terraform" {
  application_id = azuread_application.terraform.application_id
}

resource "azuread_service_principal_password" "terraform" {
  service_principal_id = azuread_service_principal.terraform.id
  value                = var.sp_password
  end_date             = "2099-01-01T00:00:00Z"
}

# Assign roles to the Service Principal
resource "azurerm_role_assignment" "terraform_contributor" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.terraform.id
}

# Storage account for Terraform state
resource "azurerm_storage_account" "tfstate" {
  name                     = "tftfstate${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  allow_blob_public_access = false

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

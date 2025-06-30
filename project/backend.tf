terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-9ae39494"
    storage_account_name = "tf9ae39494fce449q6au"
    container_name       = "tfstate"
    key                  = "whitelama.terraform.tfstate"
  }
}
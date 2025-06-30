terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.34.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "=3.4.0"
    }
  }

  required_version = ">1.9.0"
}

provider "azurerm" {
  features {}
}
provider "azuread" {
  use_cli = true
}
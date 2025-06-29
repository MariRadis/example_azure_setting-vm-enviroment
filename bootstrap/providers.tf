terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.95.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.50.0"
    }
  }

  required_version = "> 1.9.0"
}

provider "azurerm" {
  features {}
}

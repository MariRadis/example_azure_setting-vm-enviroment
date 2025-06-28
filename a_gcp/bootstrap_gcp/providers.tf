# provider "google" {
#   # Uses ADC (gcloud auth application-default login)
#   impersonate_service_account = null
# }
#
# terraform {
#   required_providers {
#     google = {
#       source  = "hashicorp/google"
#       version = "6.28.0"
#     }
#   }
#
#   required_version = "> 1.9.0"
# }


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

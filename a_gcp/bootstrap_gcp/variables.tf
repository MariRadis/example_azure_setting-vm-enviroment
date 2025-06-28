variable "subscription_id" {
  description = "The Azure Subscription ID where resources will be deployed"
  type        = string
}

variable "tenant_id" {
  description = "The Azure Tenant ID (optional if using Azure CLI authentication)"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Azure Resource Group to create or use"
  type        = string
}

variable "location" {
  description = "The Azure region to deploy resources in"
  type        = string
  default     = "westeurope"
}

variable "terraform_sp_object_id" {
  description = "The Object ID of the Terraform Service Principal (used for role assignments)"
  type        = string
}

variable "sp_password" {
  description = "The client secret password for the Terraform Service Principal"
  type        = string
  sensitive   = true
}

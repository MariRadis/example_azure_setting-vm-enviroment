
variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vmss_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "custom_data" {
  type = string
}

variable "identity_name" {
  type = string
}


variable "lb_backend_address_pool_id" {
  type        = string
  description = "ID of the Load Balancer backend address pool"
}

variable "ssh_public_key" {
  description = "SSH public key for the VMSS admin user"
  type        = string
}

output "uai_principal_id" {
  value = azurerm_user_assigned_identity.uai_vmss.principal_id
}
variable "azurerm_lb_nat_rule_ssh_id" {
  default = ""
}
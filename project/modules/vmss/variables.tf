
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

variable "role_assignments" {
  description = "List of role assignments for the identity"
  type = list(object({
    role_definition_name = string
    scope                = string
  }))
}

variable "lb_backend_address_pool_id" {
  type        = string
  description = "ID of the Load Balancer backend address pool"
}
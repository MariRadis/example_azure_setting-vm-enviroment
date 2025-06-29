variable "resource_group_name" {}
variable "location" {}
variable "identity_name" {}
variable "role_assignments" {
  type = list(object({
    role_definition_name = string
    scope                = string
  }))
}

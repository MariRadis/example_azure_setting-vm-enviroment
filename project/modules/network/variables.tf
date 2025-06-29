variable "resource_group_name" {}
variable "location" {}
variable "vnet_name" {}
variable "subnet_name" {}
variable "address_space" { default = ["10.10.0.0/16"] }
variable "subnet_prefix" { default = ["10.10.0.0/24"] }
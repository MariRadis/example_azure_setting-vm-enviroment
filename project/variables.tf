variable "prefix" {
  type        = string
  description = "Prefix for all resource names"
}

variable "location" {
  type        = string
}

variable "address_space" {
  type        = list(string)
}

variable "subnet_prefix" {
  type        = list(string)
}

variable "vm_instance_count" {
  type        = number
}


prefix            = "hasenkamp"
location          = "West Europe"
address_space     = ["10.0.0.0/16"]
subnet_prefix     = ["10.0.1.0/24"]
vm_instance_count = 2

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
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ..."

variable "location" {
  description = "Azure region to deploy resources"
}

variable "admin_username" {
  description = "Admin username for the VMSS"

}
variable "ssh_public_key" {
  description = "SSH public key for the VMSS admin user"
  type        = string
}
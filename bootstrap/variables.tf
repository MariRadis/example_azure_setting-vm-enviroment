variable "location" {}
variable "subscription_id" {
  description = "The target Azure subscription ID"
  type        = string
}

variable "github_org" {}
variable "github_repo" {}
variable "github_branch" {
}
variable "principal_id" {
}

variable "scope" {
}
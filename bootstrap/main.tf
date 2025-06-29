#Responsibilities:
# this code is what would go to bootstrap but also what would go to customer project initialization module ( resason is that this is out of scope for this task)

#Create subscription that in this case is create project for customer and subscription that would have all state buckets
#
#Enable APIs
# This bootstrap "code" would create admin users , but this is not needed for this task
#
# locally I use my user, but would it be better to do impersonation of sa for this customer project (one sa per env:prd,test... )
# I need also one workload federation for github ci/cd
#
# Bootstrap is for init staff and also has states so that is easy to remove state on resource deletion
#🛠️ What Should Bootstrap Create?
#Here’s what you typically want in your Terraform bootstrap phase:
#
#1. 🎯 Resource Group (for state)
#2. 📦 Storage Account + Container (for Terraform state)
#3. 🔐 Federated Identity Setup:
#Azure AD App Registration
#
#Federated Credential for GitHub, GitLab, or GCP OIDC
#
#Azure Role Assignment (e.g. Storage Blob Data Contributor)
#🧠 Why Put WIF Setup in the Bootstrap Project?
#Because WIF must exist before GitHub Actions can run any Terraform with Azure authentication.
#
#So:
#
#✔️ Bootstrap project = runs locally to provision:
#
#State storage
#
#AAD App + SP
#
#Federated credential
#
#Role assignment to storage
#
#🧑 You run it manually once per subscription/customer.
#
#Then:
#
#🤖 GitHub Actions can run later Terraform securely using the OIDC identity you bootstrapped.

resource "random_string" "storage_suffix" {
  length  = 4
  upper   = false
  special = false
}
locals {
  resource_group_name   = "rg-tfstate-${substr(var.subscription_id, 0, 8)}"
  short_sub_id         = substr(replace(var.subscription_id, "-", ""), 0, 14)
  storage_account_name = lower("tf${local.short_sub_id}${random_string.storage_suffix.result}")
  container_name        = "tfstate"
}

resource "azurerm_resource_group" "tfstate" {
  name     = local.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "tfstate" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
}

resource "azurerm_storage_container" "tfstate" {
  name                  = local.container_name
  storage_account_id  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

# module "wif_oidc" {
#   source               = "./modules/wif_github_oidc"
#   app_name             = "tf-ci"
#   github_org           = var.github_org
#   github_repo          = var.github_repo
#   github_branch        = var.github_branch
#   role_scope           = azurerm_storage_account.tfstate.id
#   role_definition_name = "Storage Blob Data Contributor"
# }
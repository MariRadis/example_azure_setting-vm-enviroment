

resource "azuread_application" "app" {
  display_name = var.app_name
}

resource "azuread_service_principal" "sp" {
  application_id = azuread_application.app.application_id
}

resource "azuread_application_federated_identity_credential" "github_oidc" {
  application_object_id = azuread_application.app.id
  display_name          = "github-oidc"
  description           = "OIDC trust for GitHub Actions"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/${var.github_branch}"
}

resource "azurerm_role_assignment" "assign" {
  principal_id         = azuread_service_principal.sp.id
  role_definition_name = var.role_definition_name
  scope                = var.role_scope
}


data "azurerm_client_config" "current" {}

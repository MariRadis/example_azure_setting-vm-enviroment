#The identity module is complete. It provisions:
#
#A User-Assigned Managed Identity
#
#Configurable role assignments via input list
#
#Outputs for identity reference (id, client_id, principal_id)
resource "azurerm_user_assigned_identity" "this" {
  name                = var.identity_name
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "this" {
  for_each = {
    for idx, role in var.role_assignments :
    idx => role
  }

  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

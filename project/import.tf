

import {
  to = azurerm_role_assignment.reader
  id = "/subscriptions/9ae39494-fce4-49fe-b041-56bbfcc857f6/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae77"
}

import {
  to = azurerm_role_assignment.monitoring
  id = "/subscriptions/9ae39494-fce4-49fe-b041-56bbfcc857f6/providers/Microsoft.Authorization/roleDefinitions/3913510d-42f4-4e42-8a64-420c390055eb"
}

import {
  to = azurerm_role_assignment.log_analytics
  id = "/subscriptions/9ae39494-fce4-49fe-b041-56bbfcc857f6/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293"
}
az role assignment list \
--assignee "240e2938-4913-408e-8236-fa4fb03251c1" \
--output jsonc
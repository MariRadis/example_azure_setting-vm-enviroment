

resource "azurerm_resource_group" "main" {
  name     = "webapp-rg"
  location = var.location
}

module "network" {
  source              = "./modules/network"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  vnet_name           = "webapp-vnet"
  subnet_name         = "webapp-subnet"
}

module "identity" {
  source              = "./modules/identity"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  identity_name       = "webapp-vmss-identity"
  role_assignments = [
    {
      role_definition_name = "Reader"
      scope                = azurerm_resource_group.main.id
    },
    {
      role_definition_name = "Monitoring Metrics Publisher"
      scope                = azurerm_resource_group.main.id
    },
    {
      role_definition_name = "Log Analytics Contributor"
      scope                = azurerm_resource_group.main.id
    }
  ]
}

module "vmss" {
  source              = "./modules/vmss"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  vmss_name           = "webapp-vmss"
  subnet_id           = module.network.subnet_id
  admin_username      = var.admin_username
  identity_id         = module.identity.identity_id
  custom_data         = <<-EOT
#!/bin/bash
apt-get update
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx
echo "Hello from $(hostname)" > /var/www/html/index.html
EOT
}

module "load_balancer" {
  source              = "./modules/load_balancer"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  lb_name             = "webapp-lb"
}


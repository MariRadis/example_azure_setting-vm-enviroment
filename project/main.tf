
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

module "network" {
  source              = "./modules/network"
  prefix              = var.prefix
  location            = var.location
  address_space       = var.address_space
  subnet_prefix       = var.subnet_prefix
  resource_group_name = azurerm_resource_group.rg.name
}

module "compute" {
  source              = "./modules/compute"
  prefix              = var.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = module.network.subnet_id
  backend_pool_id     = module.network.lb_backend_pool_id
  ssh_public_key      = var.ssh_public_key
  vm_instance_count   = var.vm_instance_count
}

module "monitoring" {
  source              = "./modules/monitoring"
  prefix              = var.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  vmss_id             = module.compute.vmss_id
}

#The vmss module is complete. It provisions:
#
#A Linux Virtual Machine Scale Set
#
#NGINX setup via custom_data (startup script)
#
#Attached User-Assigned Identity
#
#Network interface with subnet reference
#
#Outputs for VMSS ID and name


resource "azurerm_user_assigned_identity" "uai_vmss" {
  name                = var.identity_name
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "uai_vss_roles" {
  for_each = {
    for idx, role in var.role_assignments :
    idx => role
  }

  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = azurerm_user_assigned_identity.uai_vmss.principal_id
}

# vm scale set
resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = var.vmss_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard_DS1_v2"
  instances           = 1
  admin_username      = var.admin_username
  upgrade_mode        = "Manual"

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "vmss-nic"
    primary = true

    ip_configuration {
      name                                   = "internal"
      subnet_id                              = var.subnet_id
      primary                                = true
      load_balancer_backend_address_pool_ids = []
    }
  }

  custom_data = base64encode(var.custom_data)

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.uai_vmss.id]
  }

  tags = {
    environment = "dev"
    app         = "web"
    deployed-by = "terraform"
  }
}



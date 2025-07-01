resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = var.address_space
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_prefix
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow_http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "lb_public_ip" {
  name                = "${var.prefix}-lb-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "lb" {
  name                = "${var.prefix}-lb"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicFrontend"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "bepool" {
  name                = "backend-pool"
  # resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "http" {
  name                = "http-probe"
  # resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.lb.id
  protocol            = "Http"
  port                = 80
  request_path        = "/"
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "http" {
  name                           = "http-rule"
  # resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicFrontend"
  backend_address_pool_ids        = [azurerm_lb_backend_address_pool.bepool.id]
  probe_id                       = azurerm_lb_probe.http.id
}

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "${var.prefix}-vmss"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "Standard_B1s"
  instances           = var.vm_instance_count
  admin_username      = "azureuser"

  disable_password_authentication = true
  upgrade_mode                    = "Manual"

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "nic"
    primary = true

    ip_configuration {
      name                                   = "ipconfig"
      subnet_id                              = azurerm_subnet.subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bepool.id]
      primary                                = true
    }
  }

  custom_data = base64encode(<<-EOF
  #!/bin/bash

  # Create a log file for startup script
  exec > >(tee /var/log/startup.log | logger -t user-data -s 2>/dev/console) 2>&1

  echo "Updating packages and installing NGINX"
  apt-get update
  apt-get install -y nginx

  echo "Setting homepage to hostname"
  hostname > /var/www/html/index.html

  echo "Installing Azure Monitor Agent (AMA)"
  wget -q https://aka.ms/InstallAzureMonitorAgentLinux -O InstallAzureMonitorAgentLinux.sh
  bash InstallAzureMonitorAgentLinux.sh

  echo "Startup script completed successfully."
EOF
  )
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

output "lb_public_ip" {
  value = azurerm_public_ip.lb_public_ip.ip_address
}

resource "azurerm_monitor_autoscale_setting" "vmss_autoscale" {
  name                = "${var.prefix}-autoscale"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.vmss.id

  profile {
    name = "cpu-based-scaling"

    capacity {
      minimum = "1"
      maximum = "5"
      default = tostring(var.vm_instance_count)
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_namespace   = "Microsoft.Compute/virtualMachineScaleSets"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_namespace   = "Microsoft.Compute/virtualMachineScaleSets"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 30
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }

  notification {
    email {
      send_to_subscription_administrator    = true
      send_to_subscription_co_administrator = false
    }
  }

  enabled = true
  tags    = {}
}

# Enable Azure Monitor Diagnostics,to stream logs and metrics to a Log Analytics Workspace
#Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "log" {
  name                = "${var.prefix}-law"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
#Diagnostic Settings for VMSS:
data "azurerm_monitor_diagnostic_categories" "vmss" {
  resource_id = azurerm_linux_virtual_machine_scale_set.vmss.id
}

data "azurerm_monitor_diagnostic_categories" "vmss" {
  resource_id = azurerm_linux_virtual_machine_scale_set.vmss.id
}

resource "azurerm_monitor_diagnostic_setting" "vmss_diag" {
  name                       = "${var.prefix}-vmss-diag"
  target_resource_id         = azurerm_linux_virtual_machine_scale_set.vmss.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log.id

  dynamic "enabled_metric" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.vmss.metrics)
    content {
      category = enabled_metric.value
      enabled  = true
    }
  }

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.vmss.log_category_types
    content {
      category = enabled_log.value
      enabled  = true
    }
  }
}


#Deploy the Azure Monitor Agent Extension on VMSS
resource "azurerm_virtual_machine_scale_set_extension" "ama" {
  name                         = "AzureMonitorLinuxAgent"
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.vmss.id
  publisher                   = "Microsoft.Azure.Monitor"
  type                        = "AzureMonitorLinuxAgent"
  type_handler_version        = "1.0"
  auto_upgrade_minor_version  = true
  settings                    = "{}"
}

# from where in vm to get data
resource "azurerm_monitor_data_collection_rule" "nginx_dcr" {
  name                = "${var.prefix}-dcr"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Linux"

  destinations {
    log_analytics {
      name                  = "law-destination"
      workspace_resource_id = azurerm_log_analytics_workspace.log.id
    }
  }

  data_sources {
    linux_syslog {
      name             = "nginx-syslog"
      facility_names   = ["user"]
      log_levels       = ["All"]
    }

    linux_log {
      name         = "nginx-access"
      file_patterns = ["/var/log/nginx/access.log"]
    }

    linux_log {
      name         = "nginx-error"
      file_patterns = ["/var/log/nginx/error.log"]
    }

    linux_log {
      name         = "startup-log"
      file_patterns = ["/var/log/startup.log"]
    }
  }

  data_flows {
    streams      = ["Microsoft-Logs-LinuxSyslog", "Microsoft-Logs-CustomLogs"]
    destinations = ["law-destination"]
  }
}


resource "azurerm_monitor_data_collection_rule_association" "vmss_dcr_assoc" {
  name                    = "${var.prefix}-dcr-assoc"
  target_resource_id      = azurerm_linux_virtual_machine_scale_set.vmss.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.nginx_dcr.id

  description = "Associates DCR with VMSS to collect NGINX and startup logs"
}

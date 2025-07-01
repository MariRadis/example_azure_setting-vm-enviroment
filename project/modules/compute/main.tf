
resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "${var.prefix}-vmss"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard_B1s"
  instances           = var.vm_instance_count
  admin_username      = "azureuser"

  disable_password_authentication = true
  upgrade_mode                    = "Manual"

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
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
      subnet_id                              = var.subnet_id
      load_balancer_backend_address_pool_ids = [var.backend_pool_id]
      primary                                = true
    }
  }

  custom_data = base64encode(<<-EOF
#!/bin/bash

  # Redirect all output to log file and syslog
  exec > >(tee /var/log/startup.log | logger -t user-data -s 2>/dev/console) 2>&1

  echo "[INFO] Updating packages and installing NGINX"
  sudo apt-get update
  sudo apt-get install -y nginx

  echo "[INFO] Setting homepage to hostname"
  echo $(hostname) | sudo tee /var/www/html/index.html > /dev/null

  sudo systemctl enable nginx

  echo "[INFO] Configuring NGINX to log to syslog (facility 'user')"
  sudo tee /etc/nginx/conf.d/logging.conf > /dev/null <<'EOT'
access_log /var/log/nginx/access.log;
error_log /var/log/nginx/error.log;
EOT

  echo "[INFO] Restarting NGINX to apply logging configuration"
  sudo systemctl restart nginx

  echo "[INFO] Startup script completed successfully"
EOF
)
}

resource "azurerm_monitor_autoscale_setting" "vmss_autoscale" {
  name                = "${var.prefix}-autoscale"
  location            = var.location
  resource_group_name = var.resource_group_name
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

  enabled = true
  tags    = {}
}

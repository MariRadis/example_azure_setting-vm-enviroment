resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "${var.prefix}-vmss"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "Standard_B1s"
  instances           = var.instance_count
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
exec > >(tee /var/log/startup.log | logger -t user-data -s 2>/dev/console) 2>&1
echo "[INFO] Updating packages and installing NGINX"
sudo apt-get update
sudo apt-get install -y nginx
echo $(hostname) | sudo tee /var/www/html/index.html > /dev/null
sudo systemctl enable nginx
sudo tee /etc/nginx/conf.d/logging.conf > /dev/null <<'EOT'
access_log /var/log/nginx/access.log;
error_log /var/log/nginx/error.log;
EOT
sudo systemctl restart nginx
echo "[INFO] Startup script completed successfully"
EOF
  )
}

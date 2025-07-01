
output "subnet_id" {
  value = azurerm_subnet.subnet.id
}

output "lb_backend_pool_id" {
  value = azurerm_lb_backend_address_pool.bepool.id
}

output "web_vm_public_ip" {
  value = azurerm_public_ip.lb_public_ip.ip_address
}

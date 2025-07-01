
output "subnet_id" {
  value = azurerm_subnet.subnet.id
}

output "lb_backend_pool_id" {
  value = azurerm_lb_backend_address_pool.bepool.id
}


output "lb_public_ip" {
  value = azurerm_public_ip.lb_ip.ip_address
}

output "backend_pool_id" {
  value = azurerm_lb_backend_address_pool.bepool.id
}

output "lb_id" {
  value = azurerm_lb.lb.id
}

output "subnet_id" {
  value = azurerm_subnet.subnet.id
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "nat_public_ip" {
  value = azurerm_public_ip.nat_ip.ip_address
}

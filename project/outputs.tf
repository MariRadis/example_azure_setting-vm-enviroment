
output "web_vm_public_ip" {
  value = azurerm_public_ip.lb_public_ip.ip_address
}

output "vmss_diagnostic_log_categories" {
  description = "Log categories for the VMSS"
  value = data.azurerm_monitor_diagnostic_categories.vmss.log_category_types
}

output "vmss_diagnostic_metric_categories" {
  description = "Metric categories for the VMSS"
  value = data.azurerm_monitor_diagnostic_categories.vmss.metrics
}
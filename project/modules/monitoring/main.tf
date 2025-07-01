
resource "azurerm_log_analytics_workspace" "log" {
  name                = "${var.prefix}-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

data "azurerm_monitor_diagnostic_categories" "vmss" {
  resource_id = var.vmss_id
}

resource "azurerm_monitor_diagnostic_setting" "vmss_diag" {
  name                       = "${var.prefix}-vmss-diag"
  target_resource_id         = var.vmss_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log.id

  dynamic "enabled_metric" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.vmss.metrics)
    content {
      category = enabled_metric.value
    }
  }

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.vmss.log_category_types
    content {
      category = enabled_log.value
    }
  }
}

resource "azurerm_virtual_machine_scale_set_extension" "ama" {
  name                         = "AzureMonitorLinuxAgent"
  virtual_machine_scale_set_id = var.vmss_id
  publisher                    = "Microsoft.Azure.Monitor"
  type                         = "AzureMonitorLinuxAgent"
  type_handler_version         = "1.0"
  auto_upgrade_minor_version   = true
  settings                     = "{}"
}

resource "azurerm_monitor_data_collection_rule" "nginx_dcr" {
  name                = "${var.prefix}-dcr"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "Linux"

  destinations {
    log_analytics {
      name                  = "law-destination"
      workspace_resource_id = azurerm_log_analytics_workspace.log.id
    }
  }

  data_sources {
    syslog {
      name           = "syslog-nginx"
      facility_names = ["user"]
      log_levels     = ["Debug", "Info", "Warning", "Error"]
      streams        = ["Microsoft-Syslog"]
    }
  }

  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = ["law-destination"]
  }
}

resource "azurerm_monitor_data_collection_rule_association" "vmss_dcr_assoc" {
  name                    = "${var.prefix}-dcr-assoc"
  target_resource_id      = var.vmss_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.nginx_dcr.id
  description             = "Associates DCR with VMSS to collect NGINX and startup logs"
}

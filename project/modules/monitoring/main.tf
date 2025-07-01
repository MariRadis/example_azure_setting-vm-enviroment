resource "azurerm_log_analytics_workspace" "log" {
  name                = "${var.prefix}-law"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_autoscale_setting" "autoscale" {
  name                = "${var.prefix}-autoscale"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  target_resource_id  = var.vmss_id

  profile {
    name = "cpu-scaling"

    capacity {
      minimum = "1"
      maximum = "5"
      default = tostring(var.instance_count)
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_namespace   = "Microsoft.Compute/virtualMachineScaleSets"
        metric_resource_id = var.vmss_id
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
        metric_resource_id = var.vmss_id
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
}

data "azurerm_monitor_diagnostic_categories" "vmss" {
  resource_id = var.vmss_id
}

resource "azurerm_monitor_diagnostic_setting" "diag" {
  name                       = "${var.prefix}-diag"
  target_resource_id         = var.vmss_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

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

resource "azurerm_monitor_data_collection_rule" "dcr" {
  name                = "${var.prefix}-dcr"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Linux"

  destinations {
    log_analytics {
      name                  = "law-de

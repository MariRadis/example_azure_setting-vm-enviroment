#The load_balancer module is complete. It includes:
#
#A Public IP
#
#A Standard Load Balancer
#
#A Backend Address Pool
#
#A Health Probe on port 80
#
#A Load Balancer Rule to forward HTTP traffic



resource "azurerm_public_ip" "lb_ip" {
  name                = "${var.lb_name}-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "lb" {
  name                = var.lb_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "public-lb-ip"
    public_ip_address_id = azurerm_public_ip.lb_ip.id
  }
}

# define which virtual machines (VMs) or network interfaces are considered backend targets for load balancing.
resource "azurerm_lb_backend_address_pool" "bepool" {
  name                = "backend-pool"
  loadbalancer_id     = azurerm_lb.lb.id
}

#Helps the load balancer decide whether a backend VM is healthy or unhealthy
#
#Prevents routing traffic to unhealthy instances
resource "azurerm_lb_probe" "http" {
  name                = "http-probe"
  loadbalancer_id     = azurerm_lb.lb.id
  protocol            = "Http"
  port                = 80
  request_path        = "/"
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "http" {
  name                           = "http-rule"
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "public-lb-ip"
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.bepool.id]
  probe_id                       = azurerm_lb_probe.http.id
}

resource "azurerm_lb" "azlb" {
  name                = "${var.product}-${var.env}-lb-glusterfs"
  resource_group_name = azurerm_resource_group.atlassian_rg.name
  location            = var.location
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "lb-glusterfs-front-ip"
    subnet_id                     = module.networking.subnet_ids["atlassian-int-${var.env}-vnet-atlassian-int-subnet-dat"]
    private_ip_address            = var.frontend_private_ip_address
    private_ip_address_allocation = "Static"
  }
  tags = module.ctags.common_tags
}

resource "azurerm_lb_backend_address_pool" "azlb_backend" {
  loadbalancer_id = azurerm_lb.azlb.id
  name            = "${var.product}-${var.env}-lb-glusterfs-backend-pool"
}

resource "azurerm_lb_backend_address_pool_address" "azlb_backend_address" {
  for_each                = var.lb_backend_addresses
  name                    = each.value.name
  backend_address_pool_id = azurerm_lb_backend_address_pool.azlb_backend.id
  virtual_network_id      = module.networking.vnet_ids["atlassian-int-nonprod-vnet"]
  ip_address              = each.value.ip
}


resource "azurerm_lb_probe" "azlb" {
  for_each            = var.health_probes
  loadbalancer_id     = azurerm_lb.azlb.id
  name                = each.value.healthprobe_name
  protocol            = each.value.health_protocol
  port                = each.value.backend_port
  interval_in_seconds = each.value.lb_probe_interval
}

resource "azurerm_lb_rule" "azlb" {
  for_each = var.health_probes

  loadbalancer_id = azurerm_lb.azlb.id

  name          = each.value.rule_name
  protocol      = each.value.protocol
  frontend_port = each.value.frontend_port
  backend_port  = each.value.backend_port_rule

  frontend_ip_configuration_name = azurerm_lb.azlb.frontend_ip_configuration[0].name
  enable_floating_ip             = false
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.azlb_backend.id]
  probe_id                       = azurerm_lb_probe.azlb[each.key].id
  depends_on                     = [azurerm_lb_probe.azlb]
}

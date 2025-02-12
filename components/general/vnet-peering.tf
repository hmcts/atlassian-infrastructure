
resource "azurerm_virtual_network_peering" "int-to-dmz" {
  name                      = "atlassian-int-${var.env}-vnet-to-atlassian-dmz-${var.env}-vnet"
  resource_group_name       = azurerm_resource_group.atlassian_rg.name
  virtual_network_name      = "atlassian-int-${var.env}-vnet"
  remote_virtual_network_id = module.networking.vnet_ids["atlassian-dmz-${var.env}-vnet"]

  allow_virtual_network_access = "true"
  allow_forwarded_traffic      = "true"
}

resource "azurerm_virtual_network_peering" "dmz-to-int" {
  name                      = "atlassian-dmz-${var.env}-vnet-to-atlassian-int-${var.env}-vnet"
  resource_group_name       = azurerm_resource_group.atlassian_rg.name
  virtual_network_name      = "atlassian-dmz-${var.env}-vnet"
  remote_virtual_network_id = module.networking.vnet_ids["atlassian-int-${var.env}-vnet"]

  allow_virtual_network_access = "true"
  allow_forwarded_traffic      = "true"
}


resource "azurerm_virtual_network_peering" "int-to-ss-env-vnet" {
  name                      = "atlassian-int-${var.env}-vnet-to-${var.ss-env}-vnet"
  resource_group_name       = azurerm_resource_group.atlassian_rg.name
  virtual_network_name      = "atlassian-int-${var.env}-vnet"
  remote_virtual_network_id = "/subscriptions/${var.ss-env-sub}/resourceGroups/${var.ss-env}-network-rg/providers/Microsoft.Network/virtualNetworks/${var.ss-env}-vnet"

  allow_virtual_network_access = "true"
  allow_forwarded_traffic      = "true"
}

resource "azurerm_virtual_network_peering" "ss-env-vnet-to-int" {
  provider                  = azurerm
  name                      = "${var.ss-env}-vnet-to-atlassian-int-${var.env}-vnet"
  resource_group_name       = "${var.ss-env}-network-rg"
  virtual_network_name      = "${var.ss-env}-vnet"
  remote_virtual_network_id = module.networking.vnet_ids["atlassian-int-${var.env}-vnet"]

  allow_virtual_network_access = "true"
  allow_forwarded_traffic      = "true"
}

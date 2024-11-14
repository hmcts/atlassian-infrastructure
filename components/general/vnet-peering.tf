
resource "azurerm_virtual_network_peering" "int-to-dmz" {
  name                      = "atlassian-int-nonprod-vnet-to-atlassian-dmz-nonprod-vnet"
  resource_group_name       = azurerm_resource_group.atlassian_rg.name
  virtual_network_name      = "atlassian-int-nonprod-vnet"
  remote_virtual_network_id = module.networking.vnet_ids["atlassian-dmz-nonprod-vnet"]

  allow_virtual_network_access = "true"
  allow_forwarded_traffic      = "true"
}

resource "azurerm_virtual_network_peering" "dmz-to-int" {
  name                      = "atlassian-dmz-nonprod-vnet-to-atlassian-int-nonprod-vnet"
  resource_group_name       = azurerm_resource_group.atlassian_rg.name
  virtual_network_name      = "atlassian-dmz-nonprod-vnet"
  remote_virtual_network_id = module.networking.vnet_ids["atlassian-int-nonprod-vnet"]

  allow_virtual_network_access = "true"
  allow_forwarded_traffic      = "true"
}

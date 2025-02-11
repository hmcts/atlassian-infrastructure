
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


resource "azurerm_virtual_network_peering" "int-to-ss-stg-vnet" {
  name                      = "atlassian-int-nonprod-vnet-to-ss-stg-vnet"
  resource_group_name       = azurerm_resource_group.atlassian_rg.name
  virtual_network_name      = "atlassian-int-nonprod-vnet"
  remote_virtual_network_id = "/subscriptions/74dacd4f-a248-45bb-a2f0-af700dc4cf68/resourceGroups/ss-stg-network-rg/providers/Microsoft.Network/virtualNetworks/ss-stg-vnet"

  allow_virtual_network_access = "true"
  allow_forwarded_traffic      = "true"
}

resource "azurerm_virtual_network_peering" "ss-stg-vnet-to-int" {
  provider                  = azurerm.stg
  name                      = "ss-stg-vnet-to-atlassian-int-nonprod-vnet"
  resource_group_name       = "ss-stg-network-rg"
  virtual_network_name      = "ss-stg-vnet"
  remote_virtual_network_id = module.networking.vnet_ids["atlassian-int-nonprod-vnet"]

  allow_virtual_network_access = "true"
  allow_forwarded_traffic      = "true"
}

resource "azurerm_virtual_network_peering" "int-to-ss-prod-vnet" {
  name                      = "atlassian-int-prod-vnet-to-ss-stg-vnet"
  resource_group_name       = azurerm_resource_group.atlassian_rg.name
  virtual_network_name      = "atlassian-int-prod-vnet"
  remote_virtual_network_id = "/subscriptions/74dacd4f-a248-45bb-a2f0-af700dc4cf68/resourceGroups/ss-prod-network-rg/providers/Microsoft.Network/virtualNetworks/ss-prod-vnet"

  allow_virtual_network_access = "true"
  allow_forwarded_traffic      = "true"
}

resource "azurerm_virtual_network_peering" "ss-prod-vnet-to-int" {
  provider                  = azurerm.prod
  name                      = "ss-prod-vnet-to-atlassian-int-prod-vnet"
  resource_group_name       = "ss-prod-network-rg"
  virtual_network_name      = "ss-prod-vnet"
  remote_virtual_network_id = module.networking.vnet_ids["atlassian-int-prod-vnet"]

  allow_virtual_network_access = "true"
  allow_forwarded_traffic      = "true"
}

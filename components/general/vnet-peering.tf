
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
  count                     = var.env == "nonprod" ? 1 : 0
  name                      = "atlassian-int-${var.env}-vnet-to-ss-${var.ss-env}-vnet"
  resource_group_name       = azurerm_resource_group.atlassian_rg.name
  virtual_network_name      = "atlassian-int-${var.env}-vnet"
  remote_virtual_network_id = "/subscriptions/${var.ss-env-sub}/resourceGroups/ss-${var.ss-env}-network-rg/providers/Microsoft.Network/virtualNetworks/ss-${var.ss-env}-vnet"

  allow_virtual_network_access = "true"
  allow_forwarded_traffic      = "true"
}

resource "azurerm_virtual_network_peering" "ss-stg-vnet-to-int" {
  count                     = var.env == "nonprod" ? 1 : 0
  provider                  = azurerm.stg
  name                      = "ss-${var.ss-env}-vnet-to-atlassian-int-${var.env}-vnet"
  resource_group_name       = "ss-${var.ss-env}-network-rg"
  virtual_network_name      = "ss-${var.ss-env}-vnet"
  remote_virtual_network_id = module.networking.vnet_ids["atlassian-int-${var.env}-vnet"]

  allow_virtual_network_access = "true"
  allow_forwarded_traffic      = "true"
}


resource "azurerm_virtual_network_peering" "int-to-ss-env-vnet" {
  count                     = var.env == "prod" ? 1 : 0
  name                      = "atlassian-int-${var.env}-vnet-to-ss-${var.ss-env}-vnet"
  resource_group_name       = azurerm_resource_group.atlassian_rg.name
  virtual_network_name      = "atlassian-int-${var.env}-vnet"
  remote_virtual_network_id = "/subscriptions/${var.ss-env-sub}/resourceGroups/ss-${var.ss-env}-network-rg/providers/Microsoft.Network/virtualNetworks/ss-${var.ss-env}-vnet"

  allow_virtual_network_access = "true"
  allow_forwarded_traffic      = "true"
}

resource "azurerm_virtual_network_peering" "ss-env-vnet-to-int" {
  count                     = var.env == "prod" ? 1 : 0
  provider                  = azurerm.stg
  name                      = "ss-${var.ss-env}-vnet-to-atlassian-int-${var.env}-vnet"
  resource_group_name       = "ss-${var.ss-env}-network-rg"
  virtual_network_name      = "ss-${var.ss-env}-vnet"
  remote_virtual_network_id = module.networking.vnet_ids["atlassian-int-${var.env}-vnet"]

  allow_virtual_network_access = "true"
  allow_forwarded_traffic      = "true"
}

resource "azurerm_virtual_network_peering" "int-to-vpn" {
  name                      = "atlassian-int-${var.env}-vnet-to-core-infra-vnet-mgmt"
  resource_group_name       = azurerm_resource_group.atlassian_rg.name
  virtual_network_name      = "atlassian-int-${var.env}-vnet"
  remote_virtual_network_id = "/subscriptions/ed302caf-ec27-4c64-a05e-85731c3ce90e/resourceGroups/rg-mgmt/providers/Microsoft.Network/virtualNetworks/core-infra-vnet-mgmt"

  allow_virtual_network_access = "true"
  allow_forwarded_traffic      = "true"
}

resource "azurerm_virtual_network_peering" "vpn-to-int" {
  provider                  = azurerm.cft-mgmt
  name                      = "core-infra-vnet-mgmt-to-atlassian-int-${var.env}-vnet"
  resource_group_name       = "rg-mgmt"
  virtual_network_name      = "core-infra-vnet-mgmt"
  remote_virtual_network_id = module.networking.vnet_ids["atlassian-int-${var.env}-vnet"]

  allow_virtual_network_access = "true"
  allow_forwarded_traffic      = "true"
}

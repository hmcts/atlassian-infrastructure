
# resource "azurerm_virtual_network_peering" "jumpbox-to-prod-hub" {
#   name                      = "${var.vnet_name}-to-prod-hub"
#   resource_group_name       = var.resource_group_name
#   virtual_network_name      = var.vnet_name
#   remote_virtual_network_id = data.azurerm_virtual_network.prod-hub.id

#   allow_virtual_network_access = "true"
#   allow_forwarded_traffic      = "true"
# }


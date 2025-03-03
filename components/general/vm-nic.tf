resource "azurerm_network_interface" "nic" {
  for_each = var.nics

  name                = each.key
  location            = "UK South"
  resource_group_name = azurerm_resource_group.atlassian_rg.name

  dynamic "ip_configuration" {
    for_each = each.value.ip_configuration
    content {
      name                          = ip_configuration.value.name
      subnet_id                     = module.networking.subnet_ids["${ip_configuration.value.subnet_name}"]
      private_ip_address_allocation = ip_configuration.value.private_ip_allocation
      private_ip_address            = ip_configuration.value.private_ip_address
    }
  }

  tags = module.ctags.common_tags
}

resource "azurerm_network_interface" "nic_test" {
  count               = var.env == "nonprod" ? 1 : 0
  name                = "atlassian_nonprod_test_nic"
  location            = "UK South"
  resource_group_name = azurerm_resource_group.atlassian_rg.name
  ip_configuration {
    name = "atlassian_nonprod_test"

    subnet_id                     = module.networking.subnet_ids["atlassian-int-nonprod-vnet-atlassian-int-subnet-app"]
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.4.202"
  }
  tags = module.ctags.common_tags
}

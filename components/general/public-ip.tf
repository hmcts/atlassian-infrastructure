resource "azurerm_public_ip" "app_gw" {
  name                = "atlassian-${var.env}-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.atlassian_rg.name
  sku                 = "Standard"
  allocation_method   = "Static"
  tags                = module.ctags.common_tags
}

resource "azurerm_resource_group" "atlassian_rg" {
  location = var.location
  name     = "atlassian-${var.env}-rg"
  tags     = module.ctags.common_tags
}

resource "azurerm_storage_account" "this" {
  name                     = "atlassian-${var.env}-storage-account"
  resource_group_name      = azurerm_resource_group.atlassian_rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = module.ctags.common_tags

  cross_tenant_replication_enabled = true
}

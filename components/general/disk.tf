resource "azurerm_managed_disk" "data_disk" {
  for_each = var.data_disks

  name                 = each.key
  resource_group_name  = azurerm_resource_group.atlassian_rg.name
  location             = "UK South"
  storage_account_type = each.value.storage_account_type
  create_option        = each.value.create_option
  source_resource_id   = each.value.source_resource_id
  storage_account_id   = data.azurerm_storage_account.storage_account.id

  tags = module.ctags.common_tags
}

data "azurerm_storage_account" "storage_account" {
  name                = "atlassian${var.env}"
  resource_group_name = azurerm_resource_group.atlassian_rg.name
}

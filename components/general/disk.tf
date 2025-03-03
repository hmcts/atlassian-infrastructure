resource "azurerm_managed_disk" "data_disk" {
  for_each = var.data_disks

  name                 = each.key
  resource_group_name  = azurerm_resource_group.atlassian_rg.name
  location             = "UK South"
  storage_account_type = each.value.storage_account_type
  create_option        = each.value.create_option
  source_resource_id   = each.value.source_resource_id
  storage_account_id   = each.value.storage_account_id

  tags = module.ctags.common_tags
}

resource "azurerm_managed_disk" "data_disk_test" {
  count = var.env == "nonprod" ? 1 : 0

  name                 = "atlassian-nonprod-test-disk"
  resource_group_name  = azurerm_resource_group.atlassian_rg.name
  location             = "UK South"
  storage_account_type = "Premium_LRS"
  create_option        = "Copy"
  source_resource_id   = "/subscriptions/b7d2bd5f-b744-4acc-9c73-e068cec2e8d8/resourceGroups/atlassian-nonprod-rg/providers/Microsoft.Compute/disks/atlassiannonprodjira01-datadisk-000-20250224-221942"

  tags = module.ctags.common_tags
}

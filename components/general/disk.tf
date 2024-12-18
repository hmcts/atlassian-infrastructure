resource "azurerm_managed_disk" "data_disk" {
  for_each = var.data_disks

  name                 = each.key
  resource_group_name  = azurerm_resource_group.atlassian_rg.name
  location             = "UK South"
  storage_account_type = each.value.storage_account_type
  storage_account_id   = "/subscriptions/b7d2bd5f-b744-4acc-9c73-e068cec2e8d8/resourceGroups/atlassian-nonprod-rg/providers/Microsoft.Storage/storageAccounts/atlassiannonprod"
  create_option        = each.value.create_option
}

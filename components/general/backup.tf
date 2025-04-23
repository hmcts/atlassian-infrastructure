resource "azurerm_recovery_services_vault" "rsv" {
  name                = "${var.product}-${var.env}-rsv"
  location            = azurerm_resource_group.atlassian_rg.location
  resource_group_name = azurerm_resource_group.atlassian_rg.name
  sku                 = "Standard"
  storage_mode_type   = "GeoRedundant"

  soft_delete_enabled = true
  tags                = module.ctags.common_tags
}

resource "azurerm_backup_policy_vm" "vm-backup-policy" {

  name                = "${var.product}-${var.env}-vm-backup-policy"
  resource_group_name = azurerm_resource_group.atlassian_rg.name
  recovery_vault_name = azurerm_recovery_services_vault.rsv.name

  backup {
    frequency = "Daily"
    time      = "02:30"
  }

  timezone = "UTC"

  instant_restore_retention_days = 2

  retention_daily {
    count = 10
  }

  retention_weekly {
    weekdays = ["Sunday"]
    count    = 42
  }

  retention_monthly {
    weeks    = ["First", "Last"]
    weekdays = ["Sunday"]
    count    = 7
  }

  retention_yearly {
    months   = ["January"]
    weeks    = ["Last"]
    weekdays = ["Sunday"]
    count    = 77
  }
}

resource "azurerm_backup_protected_vm" "vm-backup" {
  for_each            = { for k, v in var.vms : k => v }
  resource_group_name = azurerm_resource_group.atlassian_rg.name
  recovery_vault_name = azurerm_recovery_services_vault.rsv.name
  source_vm_id        = azurerm_virtual_machine.vm[each.key].id
  backup_policy_id    = azurerm_backup_policy_vm.vm-backup-policy.id
}

import {
  for_each = { for k, v in var.vms : k => v if var.env == "nonprod" }

  to = azurerm_backup_protected_vm.vm-backup["${k}"]
  id = "/subscriptions/b7d2bd5f-b744-4acc-9c73-e068cec2e8d8/resourceGroups/atlassian-nonprod-rg/providers/Microsoft.RecoveryServices/vaults/atlassian-nonprod-rsv/backupFabrics/Azure/protectionContainers/IaasVMContainer;iaasvmcontainerv2;atlassian-nonprod-rg;${k}/protectedItems/VM;iaasvmcontainerv2;atlassian-nonprod-rg;${k}"
}

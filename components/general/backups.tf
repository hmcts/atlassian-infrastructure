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

resource "azurerm_data_protection_backup_vault" "postgres-backup-vault" {
  count               = var.env == "nonprod" ? 1 : 0
  name                = "${var.product}-${var.env}-postgres"
  resource_group_name = azurerm_resource_group.atlassian_rg.name
  location            = azurerm_resource_group.atlassian_rg.location
  datastore_type      = "VaultStore"
  redundancy          = "ZoneRedundant"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_data_protection_backup_policy_postgresql_flexible_server" "postgres-backup-policy" {
  count                           = var.env == "nonprod" ? 1 : 0
  name                            = "${var.product}-${var.env}-postgres-backup-policy"
  vault_id                        = azurerm_data_protection_backup_vault.postgres-backup-vault[0].id
  backup_repeating_time_intervals = ["R/2025-04-20T03:30:00+00:00/P1D"]

  default_retention_rule {
    life_cycle {
      data_store_type = "VaultStore"
      duration        = "P1W"
    }
  }

  depends_on = [
    azurerm_data_protection_backup_vault.postgres-backup-vault[0]
  ]
}

resource "azurerm_role_assignment" "backup_role" {
  count                = var.env == "nonprod" ? 1 : 0
  principal_id         = azurerm_data_protection_backup_vault.postgres-backup-vault.identity[0].principal_id
  role_definition_name = "PostgreSQL Flexible Server Long Term Retention Backup Role"
  scope                = azurerm_postgresql_flexible_server.atlassian-nonprod-flex-server-v15[0].id

  depends_on = [
    azurerm_data_protection_backup_policy.postgresql_backup_policy[0]
  ]
}

resource "azurerm_role_assignment" "reader_role" {
  count                = var.env == "nonprod" ? 1 : 0
  principal_id         = azurerm_data_protection_backup_vault.postgres-backup-vault.identity[0].principal_id
  role_definition_name = "Reader"
  scope                = azurerm_resource_group.atlassian_rg.id

  depends_on = [
    azurerm_role_assignment.backup_role[0]
  ]
}

resource "azurerm_data_protection_backup_instance_postgresql_flexible_server" "postgres-backup-instance" {
  count            = var.env == "nonprod" ? 1 : 0
  name             = "${var.product}-${var.env}-postgres-backup-instance"
  location         = azurerm_resource_group.atlassian_rg.location
  vault_id         = azurerm_data_protection_backup_vault.postgres-backup-vault[0].id
  server_id        = azurerm_postgresql_flexible_server.atlassian-nonprod-flex-server-v15[0].id
  backup_policy_id = azurerm_data_protection_backup_policy_postgresql_flexible_server.postgres-backup-policy[0].id

  depends_on = [
    azurerm_role_assignment.reader_role[0]
  ]
}


locals {
  private_dns_zone_id = "/subscriptions/1baf5470-1c3e-40d3-a6f7-74bfbce4b348/resourceGroups/core-infra-intsvc-rg/providers/Microsoft.Network/privateDnsZones/privatelink.postgres.database.azure.com"
  zone_name           = "privatelink.postgres.database.azure.com"
  zone_resource_group = "core-infra-intsvc-rg"
  app_names           = toset(["jira", "crowd", "confluence"])
  DB_SERVER           = "jdbc:postgresql://atlassian-${var.env}-flex-server.postgres.database.azure.com:5432"
}

data "azurerm_key_vault_secret" "POSTGRES-SINGLE-SERVER-PASS" {
  name         = "${var.env}-POSTGRES-SINGLE-SERVER-PASS"
  key_vault_id = azurerm_key_vault.atlassian_kv.id
}

data "azurerm_key_vault_secret" "POSTGRES-SINGLE-SERVER-USER" {
  name         = "${var.env}-POSTGRES-SINGLE-SERVER-USER"
  key_vault_id = azurerm_key_vault.atlassian_kv.id
}

resource "azurerm_postgresql_server" "atlassian-server" {
  count               = var.env == "nonprod" ? 1 : 0
  name                = "${var.product}-${var.env}-server"
  location            = azurerm_resource_group.atlassian_rg.location
  resource_group_name = azurerm_resource_group.atlassian_rg.name
  sku_name            = "MO_Gen5_8" # Memory Optimized SKU

  storage_mb = 204800 # 200GB storage

  administrator_login           = data.azurerm_key_vault_secret.POSTGRES-SINGLE-SERVER-USER.value
  administrator_login_password  = data.azurerm_key_vault_secret.POSTGRES-SINGLE-SERVER-PASS.value
  version                       = "11"
  ssl_enforcement_enabled       = true
  public_network_access_enabled = false

  lifecycle {
    ignore_changes = [
      administrator_login
    ]
  }

  tags = module.ctags.common_tags
}
resource "azurerm_private_endpoint" "postgres_private_endpoint" {
  count = var.env == "nonprod" ? 1 : 0

  name                = "${var.product}-${var.env}-postgres-pe"
  location            = azurerm_resource_group.atlassian_rg.location
  resource_group_name = azurerm_resource_group.atlassian_rg.name
  subnet_id           = module.networking.subnet_ids["atlassian-int-${var.env}-vnet-atlassian-int-subnet-postgres"]

  private_service_connection {
    name                           = "postgres-psc"
    private_connection_resource_id = azurerm_postgresql_server.atlassian-server[0].id
    is_manual_connection           = false
    subresource_names              = ["postgresqlServer"]
  }
  private_dns_zone_group {
    name                 = local.zone_name
    private_dns_zone_ids = [local.private_dns_zone_id]
  }
  tags = module.ctags.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres_dns_zone_vnet_link" {
  provider              = azurerm.dns
  name                  = "${var.product}-${var.env}-postgres-dns-vnet-link"
  resource_group_name   = local.zone_resource_group
  virtual_network_id    = module.networking.vnet_ids["atlassian-int-${var.env}-vnet"]
  private_dns_zone_name = local.zone_name
}

resource "random_password" "postgres_password" {
  for_each = local.app_names

  length  = 11
  special = false
  numeric = true
}

resource "azurerm_key_vault_secret" "postgres_password" {
  for_each = local.app_names

  name         = "${each.key}-db-${var.env}-postgres-password"
  key_vault_id = azurerm_key_vault.atlassian_kv.id
  value        = random_password.postgres_password[each.key].result
}

resource "azurerm_key_vault_secret" "postgres_username" {
  for_each = local.app_names

  name         = "${each.key}-db-${var.env}-postgres-username"
  key_vault_id = azurerm_key_vault.atlassian_kv.id
  value        = "${each.key}_user@atlassian-${var.env}-server"
}

resource "terraform_data" "postgres" {

  for_each = { for k, v in local.app_names : k => v if var.env == "nonprod" }

  triggers_replace = [
    azurerm_postgresql_server.atlassian-server[0].id,
    azurerm_key_vault_secret.postgres_password[each.key].id,
    azurerm_key_vault_secret.postgres_username[each.key].id
  ]
  provisioner "local-exec" {
    command = "./scripts/configure-postgres.sh"
    environment = {
      POSTGRES_HOST  = azurerm_postgresql_server.atlassian-server[0].fqdn
      ADMIN_USER     = "${data.azurerm_key_vault_secret.POSTGRES-SINGLE-SERVER-USER.value}@atlassian-${var.env}-server"
      ADMIN_PASSWORD = data.azurerm_key_vault_secret.POSTGRES-SINGLE-SERVER-PASS.value
      DATABASE_NAME  = "${each.key}-db-${var.env}"
      USER           = "${each.key}_user"
      PASSWORD       = random_password.postgres_password[each.key].result
    }
  }
}

data "azurerm_key_vault_secret" "POSTGRES-FLEX-SERVER-PASS" {
  name         = "${var.env}-POSTGRES-FLEX-SERVER-PASS"
  key_vault_id = azurerm_key_vault.atlassian_kv.id
}

data "azurerm_key_vault_secret" "POSTGRES-FLEX-SERVER-USER" {
  name         = "${var.env}-POSTGRES-FLEX-SERVER-USER"
  key_vault_id = azurerm_key_vault.atlassian_kv.id
}

resource "azurerm_postgresql_flexible_server" "atlassian-flex-server" {
  name                = "${var.product}-${var.env}-flex-server"
  location            = azurerm_resource_group.atlassian_rg.location
  resource_group_name = azurerm_resource_group.atlassian_rg.name
  sku_name            = var.flex_server_sku_name # Memory Optimized SKU
  delegated_subnet_id = module.networking.subnet_ids["atlassian-int-${var.env}-vnet-atlassian-int-subnet-postgres-flex"]
  private_dns_zone_id = local.private_dns_zone_id
  zone                = "1"

  storage_mb        = var.flex_server_storage_mb #Closest alternative to previous 200GB on single server
  storage_tier      = var.flex_server_storage_tier
  auto_grow_enabled = false

  authentication {
    active_directory_auth_enabled = false
    tenant_id                     = data.azurerm_client_config.current.tenant_id
    password_auth_enabled         = true
  }

  administrator_login           = data.azurerm_key_vault_secret.POSTGRES-FLEX-SERVER-USER.value
  administrator_password        = data.azurerm_key_vault_secret.POSTGRES-FLEX-SERVER-PASS.value
  version                       = "11"
  public_network_access_enabled = false

  maintenance_window {
    day_of_week  = "0"
    start_hour   = "03"
    start_minute = "00"
  }

  backup_retention_days        = var.flex_server_backup_retention_days
  geo_redundant_backup_enabled = var.flex_server_geo_redundant_backups

  lifecycle {
    ignore_changes = [
      administrator_login
    ]
  }

  tags = module.ctags.common_tags
}

resource "terraform_data" "atlassian-flex-server" {
  for_each = local.app_names

  triggers_replace = [
    azurerm_postgresql_flexible_server.atlassian-flex-server.id,
    azurerm_key_vault_secret.postgres_password[each.key].id,
    azurerm_key_vault_secret.postgres_username[each.key].id
  ]
  provisioner "local-exec" {
    command = "./scripts/configure-postgres.sh"
    environment = {
      POSTGRES_HOST  = azurerm_postgresql_flexible_server.atlassian-flex-server.fqdn
      ADMIN_USER     = data.azurerm_key_vault_secret.POSTGRES-FLEX-SERVER-USER.value
      ADMIN_PASSWORD = data.azurerm_key_vault_secret.POSTGRES-FLEX-SERVER-PASS.value
      DATABASE_NAME  = "${each.key}-db-${var.env}"
      USER           = "${each.key}_user"
      PASSWORD       = random_password.postgres_password[each.key].result
    }
  }
}

resource "azurerm_postgresql_flexible_server" "atlassian-nonprod-flex-server-v15" {
  count = var.env == "nonprod" ? 1 : 0

  name                = "${var.product}-${var.env}-flex-server-v15"
  location            = azurerm_resource_group.atlassian_rg.location
  resource_group_name = azurerm_resource_group.atlassian_rg.name
  sku_name            = var.flex_server_sku_name # Memory Optimized SKU
  delegated_subnet_id = module.networking.subnet_ids["atlassian-int-${var.env}-vnet-atlassian-int-subnet-postgres-flex"]
  private_dns_zone_id = local.private_dns_zone_id
  zone                = "1"

  storage_mb        = var.flex_server_storage_mb #Closest alternative to previous 200GB on single server
  storage_tier      = var.flex_server_storage_tier
  auto_grow_enabled = false

  authentication {
    active_directory_auth_enabled = false
    tenant_id                     = data.azurerm_client_config.current.tenant_id
    password_auth_enabled         = true
  }

  administrator_login           = data.azurerm_key_vault_secret.POSTGRES-FLEX-SERVER-USER.value
  administrator_password        = data.azurerm_key_vault_secret.POSTGRES-FLEX-SERVER-PASS.value
  public_network_access_enabled = false

  maintenance_window {
    day_of_week  = "0"
    start_hour   = "03"
    start_minute = "00"
  }

  backup_retention_days        = var.flex_server_backup_retention_days
  geo_redundant_backup_enabled = var.flex_server_geo_redundant_backups

  create_mode = "PointInTimeRestore"
  # source_server_id                  = azurerm_postgresql_flexible_server.atlassian-flex-server-temp[0].id
  # point_in_time_restore_time_in_utc = timeadd(timestamp(), "-10m")

  lifecycle {
    ignore_changes = [
      administrator_login,
      point_in_time_restore_time_in_utc,
      source_server_id
    ]
  }

  tags = module.ctags.common_tags
}

resource "terraform_data" "atlassian-nonprod-flex-server-v15" {
  for_each = { for k, v in local.app_names : k => v if var.env == "nonprod" }

  triggers_replace = [
    azurerm_postgresql_flexible_server.atlassian-nonprod-flex-server-v15.id,
    azurerm_key_vault_secret.postgres_password[each.key].id,
    azurerm_key_vault_secret.postgres_username[each.key].id
  ]
  provisioner "local-exec" {
    command = "./scripts/configure-postgres.sh"
    environment = {
      POSTGRES_HOST  = azurerm_postgresql_flexible_server.atlassian-nonprod-flex-server-v15[0].fqdn
      ADMIN_USER     = data.azurerm_key_vault_secret.POSTGRES-FLEX-SERVER-USER.value
      ADMIN_PASSWORD = data.azurerm_key_vault_secret.POSTGRES-FLEX-SERVER-PASS.value
      DATABASE_NAME  = "${each.key}-db-${var.env}"
      USER           = "${each.key}_user"
      PASSWORD       = random_password.postgres_password[each.key].result
    }
  }
}

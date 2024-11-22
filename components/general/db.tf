data "azurerm_key_vault_secret" "NONPROD-POSTGRES-SINGLE-SERVER-PASS" {
  name         = "NONPROD-POSTGRES-SINGLE-SERVER-PASS"
  key_vault_id = azurerm_key_vault.atlasssian_kv.id
}

data "azurerm_key_vault_secret" "NONPROD-POSTGRES-SINGLE-SERVER-USER" {
  name         = "NONPROD-POSTGRES-SINGLE-SERVER-USER"
  key_vault_id = azurerm_key_vault.atlasssian_kv.id
}

resource "azurerm_postgresql_server" "atlassian-NONPROD-server" {
  name                = "atlassian-NONPROD-server"
  location            = azurerm_resource_group.atlassian_rg.location
  resource_group_name = azurerm_resource_group.atlassian_rg.name
  sku_name            = "B_Gen5_2"

  storage_mb = 51200

  administrator_login          = data.azurerm_key_vault_secret.NONPROD-POSTGRES-SINGLE-SERVER-USER.value
  administrator_login_password = data.azurerm_key_vault_secret.NONPROD-POSTGRES-SINGLE-SERVER-PASS.value
  version                      = "11"
  ssl_enforcement_enabled      = true
  lifecycle {
    ignore_changes = [
      administrator_login
    ]
  }
}

resource "azurerm_postgresql_database" "jira-nonprod" {
  name                = "jira-nonprod"
  resource_group_name = azurerm_resource_group.atlassian_rg.name
  server_name         = azurerm_postgresql_server.atlassian-NONPROD-server.name
  charset             = "UTF8"
  collation           = "English_United States.1252"

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_postgresql_database" "confluence-nonprod" {
  name                = "confluence-nonprod"
  resource_group_name = azurerm_resource_group.atlassian_rg.name
  server_name         = azurerm_postgresql_server.atlassian-NONPROD-server.name
  charset             = "UTF8"
  collation           = "English_United States.1252"

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_postgresql_database" "crowd-nonprod" {
  name                = "crowd-nonprod"
  resource_group_name = azurerm_resource_group.atlassian_rg.name
  server_name         = azurerm_postgresql_server.atlassian-NONPROD-server.name
  charset             = "UTF8"
  collation           = "English_United States.1252"

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = true
  }
}

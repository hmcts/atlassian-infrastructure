data "azurerm_key_vault_secret" "POSTGRES-SINGLE-SERVER-PASS" {
  name         = "${var.env}-POSTGRES-SINGLE-SERVER-PASS"
  key_vault_id = azurerm_key_vault.atlasssian_kv.id
}

data "azurerm_key_vault_secret" "POSTGRES-SINGLE-SERVER-USER" {
  name         = "${var.env}-POSTGRES-SINGLE-SERVER-USER"
  key_vault_id = azurerm_key_vault.atlasssian_kv.id
}

resource "azurerm_postgresql_server" "atlassian-server" {
  name                = "atlassian-${var.env}-server"
  location            = azurerm_resource_group.atlassian_rg.location
  resource_group_name = azurerm_resource_group.atlassian_rg.name
  sku_name            = "GP_Gen5_8"

  storage_mb = 51200

  administrator_login          = data.azurerm_key_vault_secret.POSTGRES-SINGLE-SERVER-USER.value
  administrator_login_password = data.azurerm_key_vault_secret.POSTGRES-SINGLE-SERVER-PASS.value
  version                      = "11"
  ssl_enforcement_enabled      = true
  lifecycle {
    ignore_changes = [
      administrator_login
    ]
  }
}

resource "azurerm_postgresql_virtual_network_rule" "app_subnet_rule" {
  name                = "app-subnet-rule"
  resource_group_name = azurerm_resource_group.atlassian_rg.name
  server_name         = azurerm_postgresql_server.atlassian-server.name
  subnet_id           = module.networking.subnet_ids["atlassian-int-${var.env}-vnet-atlassian-int-subnet-app"]
}

resource "azurerm_postgresql_virtual_network_rule" "ops_subnet_rule" {
  name                = "ops-subnet-rule"
  resource_group_name = azurerm_resource_group.atlassian_rg.name
  server_name         = azurerm_postgresql_server.atlassian-server.name
  subnet_id           = module.networking.subnet_ids["atlassian-int-${var.env}-vnet-atlassian-int-subnet-ops"]
}

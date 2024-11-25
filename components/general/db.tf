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

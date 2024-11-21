data "azurerm_key_vault_secret" "PREPROD-POSTGRES-SINGLE-SERVER-PASS" {
  name         = "PREPROD-POSTGRES-SINGLE-SERVER-PASS"
  key_vault_id = azurerm_key_vault.atlasssian_kv.id
}

output "secret_value_user" {
  value     = data.azurerm_key_vault_secret.PREPROD-POSTGRES-SINGLE-SERVER-PASS.value
  sensitive = true
}

data "azurerm_key_vault_secret" "PREPROD-POSTGRES-SINGLE-SERVER-USER" {
  name         = "PREPROD-POSTGRES-SINGLE-SERVER-USER"
  key_vault_id = azurerm_key_vault.atlasssian_kv.id
}

output "secret_value_pass" {
  value     = data.azurerm_key_vault_secret.PREPROD-POSTGRES-SINGLE-SERVER-USER.value
  sensitive = true
}

resource "azurerm_postgresql_server" "atlassian-preprod-server" {
  name                = "atlassian-preprod-server"
  location            = azurerm_resource_group.atlassian_rg.location
  resource_group_name = azurerm_resource_group.atlassian_rg.name
  sku_name            = "B_Gen5_2"

  storage_mb = 51200

  administrator_login          = output.secret_value_user.value
  administrator_login_password = output.secret_value_pass.value
  version                      = "11"
  ssl_enforcement_enabled      = true
}

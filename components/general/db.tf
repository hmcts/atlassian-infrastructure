locals {
  private_dns_zone_id = "/subscriptions/1baf5470-1c3e-40d3-a6f7-74bfbce4b348/resourceGroups/core-infra-intsvc-rg/providers/Microsoft.Network/privateDnsZones/privatelink.postgres.database.azure.com"
  zone_name           = "privatelink.postgres.database.azure.com"
  zone_resource_group = "core-infra-intsvc-rg"
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
  name                = "atlassian-${var.env}-server"
  location            = azurerm_resource_group.atlassian_rg.location
  resource_group_name = azurerm_resource_group.atlassian_rg.name
  sku_name            = "GP_Gen5_8"

  storage_mb = 76800

  administrator_login          = data.azurerm_key_vault_secret.POSTGRES-SINGLE-SERVER-USER.value
  administrator_login_password = data.azurerm_key_vault_secret.POSTGRES-SINGLE-SERVER-PASS.value
  version                      = "11"
  ssl_enforcement_enabled      = true
  lifecycle {
    ignore_changes = [
      administrator_login
    ]
  }

  tags = module.ctags.common_tags
}

resource "azurerm_postgresql_virtual_network_rule" "app_subnet_rule" {
  name                = "app-subnet-rule"
  resource_group_name = azurerm_resource_group.atlassian_rg.name
  server_name         = azurerm_postgresql_server.atlassian-server.name
  subnet_id           = module.networking.subnet_ids["atlassian-int-${var.env}-vnet-atlassian-int-subnet-app"]
}

resource "azurerm_postgresql_virtual_network_rule" "dat_subnet_rule" {
  name                = "dat-subnet-rule"
  resource_group_name = azurerm_resource_group.atlassian_rg.name
  server_name         = azurerm_postgresql_server.atlassian-server.name
  subnet_id           = module.networking.subnet_ids["atlassian-int-${var.env}-vnet-atlassian-int-subnet-dat"]
}

resource "azurerm_private_endpoint" "postgres_private_endpoint" {
  name                = "atlassian-${var.env}-postgres-pe"
  location            = azurerm_resource_group.atlassian_rg.location
  resource_group_name = azurerm_resource_group.atlassian_rg.name
  subnet_id           = module.networking.subnet_ids["atlassian-int-${var.env}-vnet-atlassian-int-subnet-postgres"]

  private_service_connection {
    name                           = "postgres-psc"
    private_connection_resource_id = azurerm_postgresql_server.atlassian-server.id
    is_manual_connection           = false
    subresource_names              = ["postgresqlServer"]
  }
  private_dns_zone_group {
    name                 = local.zone_name
    private_dns_zone_ids = [local.private_dns_zone_id]
  }

}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres_dns_zone_vnet_link" {
  provider              = azurerm.dns
  name                  = "atlassian-${var.env}-postgres-dns-vnet-link"
  resource_group_name   = local.zone_resource_group
  virtual_network_id    = module.networking.vnet_ids["atlassian-int-nonprod-vnet"]
  private_dns_zone_name = local.zone_name
}

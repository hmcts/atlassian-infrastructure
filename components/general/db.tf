provider "azurerm" {
  features {}
  alias           = "live"
  subscription_id = "79898897-729c-41a0-a5ca-53c764839d95"
}

data "azurerm_key_vault" "key_vault" {
  provider            = azurerm.live
  name                = "PRD-ATL-Backups-KV"
  resource_group_name = "RG-PRD-ATL-01"
}

resource "azurerm_key_vault_secret" "POSTGRES-PASS-SOURCE" {
  name         = "recipe-backend-POSTGRES-PASS-SOURCE"
  value        = module.single_database_source.postgresql_password
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

# single server (source) - for DMS migration testing only
module "single_database_source" {
  source             = "github.com/hmcts/cnp-module-postgres?ref=postgresql_tf"
  product            = var.product
  name               = "${var.product}-v11-source"
  location           = var.location
  env                = var.env
  postgresql_user    = "rhubarbadmin"
  database_name      = "rhubarb-v11"
  postgresql_version = "11"
  subnet_id          = "/subscriptions/b7d2bd5f-b744-4acc-9c73-e068cec2e8d8/resourceGroups/atlassian-nonprod-rg/providers/Microsoft.Network/virtualNetworks/atlassian-int-nonprod-vnet/subnets/atlassian-int-subnet-dat"
  sku_name           = "GP_Gen5_2"
  sku_tier           = "GeneralPurpose"
  storage_mb         = "51200"
  common_tags        = module.ctags.common_tags
  subscription       = "b7d2bd5f-b744-4acc-9c73-e068cec2e8d8"
  key_vault_rg       = "genesis-rg"
  key_vault_name     = "dtssharedservices${var.env}kv"
  business_area      = "SDS"
}

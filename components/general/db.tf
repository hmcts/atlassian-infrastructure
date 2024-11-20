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

data "azurerm_key_vault_secret" "PRP-ATL-POSTGRES-PGSQL-BACKUP-TRIAL" {
  name         = "PRP-ATL-POSTGRES-PGSQL-BACKUP-TRIAL"
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

output "secret_value" {
  value     = data.azurerm_key_vault_secret.PRP-ATL-POSTGRES-PGSQL-BACKUP-TRIAL.value
  sensitive = true
}

# single server (source) - for DMS migration testing only
module "single_database_source" {
  source             = "github.com/hmcts/cnp-module-postgres?ref=postgresql_tf"
  product            = var.product
  name               = "${var.product}-v11-source"
  location           = var.location
  env                = var.env
  postgresql_user    = "pgsqladmin"
  database_name      = "backup-restore-trial"
  postgresql_version = "11"
  subnet_id          = "/subscriptions/b7d2bd5f-b744-4acc-9c73-e068cec2e8d8/resourceGroups/atlassian-nonprod-rg/providers/Microsoft.Network/virtualNetworks/atlassian-int-nonprod-vnet/subnets/atlassian-int-subnet-dat"
  sku_name           = "GP_Gen5_2"
  sku_tier           = "GeneralPurpose"
  storage_mb         = "51200"
  common_tags        = module.ctags.common_tags
  subscription       = "b7d2bd5f-b744-4acc-9c73-e068cec2e8d8"
  key_vault_rg       = "RG-PRD-ATL-01"
  key_vault_name     = "PRD-ATL-Backups-KV"
  business_area      = "SDS"
}

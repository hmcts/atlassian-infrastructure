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
  subnet_id          = module.networking.subnet_ids["atlassian-dmz-${var.env}-vnet-atlassian-dmz-subnet-appgw"]
  sku_name           = "GP_Gen5_2"
  sku_tier           = "GeneralPurpose"
  storage_mb         = "51200"
  common_tags        = module.ctags.common_tags
  subscription       = "b7d2bd5f-b744-4acc-9c73-e068cec2e8d8"
  key_vault_rg       = azurerm_key_vault.atlasssian_kv.resource_group_name
  key_vault_name     = azurerm_key_vault.atlasssian_kv.name
  business_area      = "SDS"
}

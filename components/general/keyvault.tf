data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "atlasssian_kv" {
  name                     = "atlasssian-${var.env}-kv"
  resource_group_name      = azurerm_resource_group.atlassian_rg.name
  location                 = var.location
  sku_name                 = "standard"
  tenant_id                = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled = false

  access_policy = [
    {
      tenant_id      = data.azurerm_client_config.current.tenant_id
      object_id      = data.azurerm_client_config.current.object_id
      application_id = null

      certificate_permissions = []
      key_permissions         = []
      storage_permissions     = []

      secret_permissions = [
        "Get",
        "List",
        "Set",
        "Delete",
        "Purge"
      ]
    },
    {
      tenant_id      = data.azurerm_client_config.current.tenant_id
      object_id      = "e7ea2042-4ced-45dd-8ae3-e051c6551789" # DTS Platform Operations
      application_id = null

      certificate_permissions = []
      key_permissions         = []
      storage_permissions     = []

      secret_permissions = [
        "Get",
        "List",
        "Set",
        "Delete",
        "Purge"
      ]
    }
  ]

  tags = module.ctags.common_tags
}

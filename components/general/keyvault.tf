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

      certificate_permissions = [
        "Get",
        "List",
        "Update",
        "Create",
        "Import",
        "Delete",
        "Recover",
        "Backup",
        "Restore",
        "ManageContacts",
        "ManageIssuers",
        "GetIssuers",
        "ListIssuers",
        "SetIssuers",
        "DeleteIssuers",
      ]
      key_permissions = [
        "Get",
        "List",
        "Update",
        "Create",
        "Import",
        "Delete",
        "Recover",
        "Backup",
        "Restore",
        "GetRotationPolicy",
        "SetRotationPolicy",
        "Rotate",
      ]
      storage_permissions = []

      secret_permissions = [
        "Get",
        "List",
        "Set",
        "Delete",
        "Purge"
      ]
    },
    {
      certificate_permissions = []
      key_permissions         = []
      object_id               = "96f806d7-de3f-4407-bd62-b746b59cc3d7"
      secret_permissions = [
        "Get",
        "List",
      ]
      storage_permissions = []
      tenant_id           = "531ff96d-0ae9-462a-8d2d-bec7c0b42082"

    }
  ]

  tags = module.ctags.common_tags
}

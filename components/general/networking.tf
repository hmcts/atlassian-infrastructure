module "networking" {

  source = "github.com/hmcts/terraform-module-azure-virtual-networking?ref=4.x"

  env                          = var.env
  product                      = var.product
  common_tags                  = module.ctags.common_tags
  component                    = "networking"
  existing_resource_group_name = azurerm_resource_group.atlassian_rg.name
  vnets                        = var.vnets
  network_security_groups      = var.network_security_groups
}

resource "azurerm_network_interface" "nic" {
  for_each = var.nics

  name                = each.key
  location            = "UK South"
  resource_group_name = azurerm_resource_group.atlassian_rg.name

  dynamic "ip_configuration" {
    for_each = each.value.ip_configuration
    content {
      name                          = ip_configuration.value.name
      subnet_id                     = module.networking.subnet_ids["${ip_configuration.value.subnet_name}"]
      private_ip_address_allocation = ip_configuration.value.private_ip_allocation
      private_ip_address            = ip_configuration.value.private_ip_address
    }
  }

  tags = module.ctags.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres_vnet_link" {
  provider = azurerm.dns

  name                  = "atlassian-${var.env}-postgres-dns-vnet-link"
  resource_group_name   = "core-infra-intsvc-rg"
  private_dns_zone_name = "privatelink.postgres.database.azure.com"
  registration_enabled  = false
  virtual_network_id    = module.networking.vnet_ids["atlassian-int-${var.env}-vnet"]

}

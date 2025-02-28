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

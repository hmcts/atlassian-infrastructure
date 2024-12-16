locals {
  vm_subnets = {
    app  = "atlassian-int-subnet-app"
    data = "atlassian-int-subnet-dat"
    ops  = "atlassian-int-subnet-ops"
  }

  all_existing_disks = merge([
    for vm_name, vm in var.vms : {
      for disk_key, disk in vm.existing_disks : "${vm_name}-${disk_key}" => {
        disk_name = disk.disk_name
        vm_name   = vm_name
        lun       = disk.lun
        caching   = disk.caching
      }
    }
  ]...)

}

data "azurerm_key_vault_secret" "admin_public_key" {
  name         = "public-key"
  key_vault_id = azurerm_key_vault.atlassian_kv.id
}

module "vm" {
  source   = "git::https://github.com/hmcts/terraform-module-virtual-machine.git?ref=master"
  for_each = var.vms

  providers = {
    azurerm     = azurerm
    azurerm.cnp = azurerm.cnp
    azurerm.soc = azurerm.soc
    azurerm.dcr = azurerm.dcr
  }

  env                             = var.env
  vm_name                         = each.key
  vm_type                         = "linux"
  vm_resource_group               = azurerm_resource_group.atlassian_rg.name
  vm_admin_name                   = "atlassian-admin"
  disable_password_authentication = true
  vm_admin_ssh_key                = data.azurerm_key_vault_secret.admin_public_key.value
  vm_size                         = each.value.vm_size
  vm_publisher_name               = each.value.vm_image_publisher_name
  vm_offer                        = each.value.vm_image_offer
  vm_sku                          = each.value.vm_image_sku
  vm_version                      = each.value.vm_image_version
  vm_availabilty_zones            = "1"

  vm_subnet_id         = module.networking.subnet_ids["atlassian-int-${var.env}-vnet-${local.vm_subnets[each.value.tier]}"]
  privateip_allocation = "Dynamic"

  tags = module.ctags.common_tags
}

data "azurerm_managed_disk" "existing_disks" {
  for_each = local.all_existing_disks

  name                = each.value.disk_name
  resource_group_name = azurerm_resource_group.atlassian_rg.name
}

resource "azurerm_virtual_machine_data_disk_attachment" "existing_disk_attachments" {
  for_each = local.all_existing_disks

  managed_disk_id    = data.azurerm_managed_disk.existing_disks[each.key].id
  virtual_machine_id = module.vm[each.value.vm_name].vm_id
  lun                = each.value.lun
  caching            = each.value.caching
}


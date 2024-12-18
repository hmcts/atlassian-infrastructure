locals {
  all_data_disks = merge([
    for vm_name, vm in var.vms : {
      for disk_key, disk in vm.data_disks : "${vm_name}-${disk_key}" => {
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

resource "azurerm_virtual_machine" "vm" {
  for_each = var.vms

  name                         = each.key
  location                     = "UK South"
  resource_group_name          = azurerm_resource_group.atlassian_rg.name
  vm_size                      = each.value.vm_size
  network_interface_ids        = [data.azurerm_network_interface.nic[each.key].id]
  primary_network_interface_id = data.azurerm_network_interface.nic[each.key].id

  storage_os_disk {
    name              = each.value.os_disk_name
    caching           = "ReadOnly"
    create_option     = "Attach"
    managed_disk_type = "Premium_LRS"
  }

  tags = module.ctags.tags
}

data "azurerm_network_interface" "nic" {
  for_each = var.vms

  name                = each.value.nic_name
  resource_group_name = azurerm_resource_group.atlassian_rg.name
}

data "azurerm_managed_disk" "data_disks" {
  for_each = local.all_data_disks

  name                = each.value.disk_name
  resource_group_name = azurerm_resource_group.atlassian_rg.name
}

resource "azurerm_virtual_machine_data_disk_attachment" "existing_disk_attachments" {
  for_each = local.all_data_disks

  managed_disk_id    = data.azurerm_managed_disk.data_disks[each.key].id
  virtual_machine_id = resource.azurerm_virtual_machine.vm[each.value.vm_name].id
  lun                = each.value.lun
  caching            = each.value.caching
}


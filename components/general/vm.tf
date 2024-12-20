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
  network_interface_ids        = [azurerm_network_interface.nic[each.value.nic_name].id]
  primary_network_interface_id = azurerm_network_interface.nic[each.value.nic_name].id

  storage_os_disk {
    name              = each.value.os_disk_name
    caching           = "ReadOnly"
    create_option     = "Attach"
    managed_disk_type = "Premium_LRS"
  }

  tags = module.ctags.common_tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk_attachment" {
  for_each = var.data_disks

  managed_disk_id    = azurerm_managed_disk.data_disk[each.key].id
  virtual_machine_id = resource.azurerm_virtual_machine.vm[each.value.vm_name].id
  lun                = each.value.lun
  caching            = each.value.caching
}


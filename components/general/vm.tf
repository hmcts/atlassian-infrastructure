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

data "azurerm_key_vault_secret" "admin_private_key" {
  name         = "private-key"
  key_vault_id = azurerm_key_vault.atlassian_kv.id
}

data "azurerm_key_vault_secret" "admin_username" {
  name         = "vm-admin-username"
  key_vault_id = azurerm_key_vault.atlassian_kv.id
}

# Currently provisions the Jira VMs only - TODO: Update script to be more generic and run on all VMs or add scripts and provisioners for other VMs
resource "terraform_data" "jira_vm" {
  for_each = { for k, v in var.vms : k => v if can(regex("jira", k)) }

  triggers_replace = [
    azurerm_virtual_machine.vm[each.key].id
  ]

  connection {
    type        = "ssh"
    host        = each.key.value.private_ip_address
    user        = data.azurerm_key_vault_secret.admin_username.value
    private_key = data.azurerm_key_vault_secret.admin_private_key.value
  }

  provisioner "file" {
    source      = "${path.module}/scripts/configure-jira-vm.sh"
    destination = "/tmp/configure-jira-vm.sh"
  }
  provisioner "file" {
    source      = "${path.module}/scripts/functions.sh"
    destination = "/tmp/functions.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/configure-jira-vm.sh",
      "sudo ./tmp/configure-jira-vm.sh ${local.DB_SERVER}/jira-db-${var.env} jira_user@atlassian-${var.env}-server ${random_password.postgres_password["jira"].result}",
      "sudo chmod +x /tmp/functions.sh",
      "sudo ./tmp/functions.sh",
      "sudo rm /tmp/configure-jira-vm.sh",
      "sudo rm /tmp/functions.sh"
    ]
  }

}

locals {
  jira_file_hash         = md5(file("${path.module}/scripts/configure-jira-vm.sh"))
  function_file_hash     = md5(file("${path.module}/scripts/functions.sh"))
  crowd_file_hash        = md5(file("${path.module}/scripts/configure-crowd-vm.sh"))
  gluster_file_hash      = md5(file("${path.module}/scripts/configure-gluster-vm.sh"))
  confluence_private_ips = join(",", [for k, v in var.vms : v.private_ip_address if can(regex("confluence", k))])
  confluence_file_hash   = md5(file("${path.module}/scripts/configure-confluence-vm.sh"))
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

resource "azurerm_virtual_machine" "vm_test" {
  count                        = var.env == "nonprod" ? 1 : 0
  name                         = "atlassian_nonprod_test_vm"
  location                     = "UK South"
  resource_group_name          = azurerm_resource_group.atlassian_rg.name
  vm_size                      = "Standard_E8s_v3"
  network_interface_ids        = [azurerm_network_interface.nic_test[count.index].id]
  primary_network_interface_id = azurerm_network_interface.nic_test[count.index].id

  storage_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "7.8"
    version   = "latest"
  }

  storage_os_disk {
    name              = "atlassiannonprodtest"
    caching           = "ReadOnly"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = "atlassian_nonprod_test_vm"
    admin_username = "test"
  }

  os_profile_linux_config {
    disable_password_authentication = false
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
  name         = "test-private-key"
  key_vault_id = azurerm_key_vault.atlassian_kv.id
}
data "azurerm_key_vault_secret" "admin_username" {
  name         = "vm-admin-username"
  key_vault_id = azurerm_key_vault.atlassian_kv.id
}

resource "terraform_data" "vm" {
  for_each = { for k, v in var.vms : k => v if can(regex("(jira|crowd|gluster|confluence)", k)) }

  triggers_replace = [
    local.jira_file_hash,
    local.crowd_file_hash,
    local.function_file_hash,
    local.gluster_file_hash,
    local.confluence_file_hash,
  ]

  connection {
    type        = "ssh"
    host        = each.value.private_ip_address
    user        = data.azurerm_key_vault_secret.admin_username.value
    private_key = data.azurerm_key_vault_secret.admin_private_key.value
    timeout     = "15m"
  }

  provisioner "file" {
    source      = "./scripts/configure-${each.value.app}-vm.sh"
    destination = "/tmp/configure-${each.value.app}-vm.sh"
  }

  provisioner "file" {
    source      = "./scripts/functions.sh"
    destination = "/tmp/functions.sh"
  }

  provisioner "file" {
    source      = "./scripts/robots_template.txt"
    destination = "/tmp/robots_template.txt"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/configure-${each.value.app}-vm.sh",
      "chmod +x /tmp/functions.sh",
      "sudo su - -c '/tmp/configure-${each.value.app}-vm.sh ${local.DB_SERVER}/${each.value.app}-db-${var.env} ${each.value.app}_user ${each.value.app != "gluster" ? random_password.postgres_password["${each.value.app}"].result : each.value.app} ${var.env} ${var.app_action} ${local.confluence_private_ips}'",
      "rm -f /tmp/configure-${each.value.app}-vm.sh",
    ]
  }

  depends_on = [terraform_data.postgres]
}


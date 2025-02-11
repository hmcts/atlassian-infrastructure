# VM IMPORTS
import {
  for_each = var.vms

  to = azurerm_virtual_machine.vm[each.key]
  id = "/subscriptions/b7d2bd5f-b744-4acc-9c73-e068cec2e8d8/resourceGroups/atlassian-nonprod-rg/providers/Microsoft.Compute/virtualMachines/${each.key}"
}

# DATA DISK IMPORTS
import {
  for_each = var.data_disks

  to = azurerm_managed_disk.data_disk[each.key]
  id = "/subscriptions/b7d2bd5f-b744-4acc-9c73-e068cec2e8d8/resourceGroups/atlassian-nonprod-rg/providers/Microsoft.Compute/disks/${each.key}"
}

import {
  for_each = var.data_disks

  to = azurerm_virtual_machine_data_disk_attachment.data_disk_attachment[each.key]
  id = "/subscriptions/b7d2bd5f-b744-4acc-9c73-e068cec2e8d8/resourceGroups/atlassian-nonprod-rg/providers/Microsoft.Compute/virtualMachines/${each.value.vm_name}/dataDisks/${each.key}"
}

# NIC IMPORTS
import {
  for_each = var.nics

  to = azurerm_network_interface.nic[each.key]
  id = "/subscriptions/b7d2bd5f-b744-4acc-9c73-e068cec2e8d8/resourceGroups/atlassian-nonprod-rg/providers/Microsoft.Network/networkInterfaces/${each.key}"
}

# VNET LINK IMPORTS
import {
  to = azurerm_private_dns_zone_virtual_network_link.postgres_dns_zone_vnet_link
  id = "/subscriptions/1baf5470-1c3e-40d3-a6f7-74bfbce4b348/resourceGroups/core-infra-intsvc-rg/providers/Microsoft.Network/privateDnsZones/privatelink.postgres.database.azure.com/virtualNetworkLinks/atlassian-nonprod-postgres-dns-vnet-link"
}

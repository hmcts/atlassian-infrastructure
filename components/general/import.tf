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

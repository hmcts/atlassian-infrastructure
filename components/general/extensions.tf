module "vm-bootstrap" {
  for_each = var.install_dynatrace_oneagent ? var.vms : {}

  providers = {
    azurerm     = azurerm
    azurerm.cnp = azurerm.cnp
    azurerm.soc = azurerm.soc
    azurerm.dcr = azurerm.dcr
  }
  source = "git::https://github.com/hmcts/terraform-module-vm-bootstrap.git?ref=DTSPO-24291-updating-dynatrace-settings"

  virtual_machine_type        = "vm"
  virtual_machine_id          = azurerm_virtual_machine.vm[each.key].id
  install_dynatrace_oneagent  = var.install_dynatrace_oneagent
  install_azure_monitor       = var.install_azure_monitor
  install_nessus_agent        = var.install_nessus_agent
  install_splunk_uf           = var.install_splunk_uf
  install_endpoint_protection = var.install_endpoint_protection
  run_command                 = var.run_command
  os_type                     = var.os_type
  env                         = var.env == "prod" ? var.env : "nonprod"
  dynatrace_custom_hostname   = azurerm_virtual_machine.vm[each.key].name

  common_tags = module.ctags.common_tags
  depends_on  = [azurerm_virtual_machine.vm]
}

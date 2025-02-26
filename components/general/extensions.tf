module "vm-bootstrap" {
  for_each = var.vms

  providers = {
    azurerm     = azurerm
    azurerm.cnp = azurerm.cnp
    azurerm.soc = azurerm.soc
    azurerm.dcr = azurerm.dcr
  }
  count  = var.install_dynatrace_oneagent ? 1 : 0
  source = "git::https://github.com/hmcts/terraform-module-vm-bootstrap.git?ref=master"

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

  common_tags = module.ctags.common_tags
}

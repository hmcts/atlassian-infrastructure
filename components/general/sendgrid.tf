# import {
#   to = azurerm_resource_group_template_deployment.sendgrid
#   id = "/subscriptions/79898897-729c-41a0-a5ca-53c764839d95/resourceGroups/atlassian-prod-rg/providers/Microsoft.Resources/deployments/MarketplaceSaaS_62b3dd1c-cb30-4009-8373-ccdeac71728a"
# }

# terraform import azurerm_resource_group_template_deployment.example 


# terraform import azurerm_resource_group_template_deployment.example
# /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/group1/providers/Microsoft.Resources/deployments/template1
# /subscriptions/79898897-729c-41a0-a5ca-53c764839d95/resourceGroups/atlassian-prod-rg/providers/Microsoft.Resources/deployments/MarketplaceSaaS_62b3dd1c-cb30-4009-8373-ccdeac71728a

# /root/.local/bin/terraform init 
# -backend-config=storage_account_name=cb7d2bd5fe068cec2e8d8sa 
# -backend-config=container_name=subscription-tfstate 
# -backend-config=key=UK South/atlassian/atlassian-infrastructure/nonprod/general/terraform.tfstate
# -backend-config=resource_group_name=azure-control-nonprod-rg
# -backend-config=subscription_id=b7d2bd5f-b744-4acc-9c73-e068cec2e8d8
# -backend-config=tenant_id=531ff96d-0ae9-462a-8d2d-bec7c0b42082
# -backend-config=client_id=*** 
# -backend-config=client_secret=*** 
# -backend-config=subscription_id=04d27a32-7a07-48b3-95b8-3c8691e1a263
# -backend-config=resource_group_name=azure-control-stg-rg


resource "azurerm_resource_group_template_deployment" "sendgrid" {
  name                = "MarketplaceSaaS_62b3dd1c-cb30-4009-8373-ccdeac71728a"
  resource_group_name = azurerm_resource_group.atlassian_rg.name
  template_content    = file("sendgrid_template.json")

  parameters_content = jsonencode({
    name                  = "SGAAPPATL01"
    location              = "global"
    plan_name             = "silver"
    plan_publisher        = "Sendgrid"
    plan_product          = "sendgrid_azure"
    plan_promotion_code   = ""
    password              = "testing"
    acceptMarketingEmails = 0
    email                 = "DTSPlatformOps@HMCTS.NET"
    firstName             = "Platform"
    lastName              = "Operations"
    company               = "HMCTS"
    website               = "https://www.gov.uk/"
  })

  deployment_mode = "Incremental"
}

data "azurerm_key_vault" "atlassian-kv" {
  name                = "atlasssian-${var.env}-kv"
  resource_group_name = azurerm_resource_group.atlassian_rg.name
}

# API Key with more open permissions for the Sengrid TF provider
# This is created manually on master Sendgrid account then added to the key vault
data "azurerm_key_vault_secret" "platform-operations-sendgrid-api-key-secret" {
  name         = "platform-operations-sendgrid-api-key"
  key_vault_id = data.azurerm_key_vault.atlassian-kv.id
}

# Import existing domain authenticate as the domain has already been verified
import {
  to = sendgrid_domain_authentication.sendgrid-domain-authenticate
  id = var.sendgrid_domain_authentication_id
}

# API key value is not set on tf import in this provider
# so the only chance to store the key is during the creation of the API key
resource "sendgrid_api_key" "sendgrid-jira-api-key" {
  provider = sendgrid
  name     = "jira-email-${var.env}-api"
  scopes = [
    "mail.send",
    "2fa_exempt",
    "2fa_required",
    "sender_verification_eligible",
    "whitelabel.read",
    "whitelabel.create",
    "whitelabel.delete",
    "whitelabel.update",
    "mail.batch.create",
    "mail.batch.delete",
    "mail.batch.read",
    "mail.batch.update",
    "user.scheduled_sends.create",
    "user.scheduled_sends.delete",
    "user.scheduled_sends.read",
    "user.scheduled_sends.update"
  ]
}

resource "azurerm_key_vault_secret" "sendgrid-jira-api-key-secret" {
  name         = "jira-email-sendgrid-api-key"
  value        = sendgrid_api_key.sendgrid-jira-api-key.api_key
  key_vault_id = azurerm_key_vault.atlassian_kv.id
}

resource "sendgrid_domain_authentication" "sendgrid-domain-authenticate" {
  provider   = sendgrid
  domain     = var.sendgrid_domain
  is_default = false
  depends_on = [
    sendgrid_api_key.sendgrid-jira-api-key
  ]
}

# Domain cjscp.justice.gov.uk is not hosted through Azure DNS, (Amazong Route 53)
# So these need to be manually verified if they changed by:
# legalservices webmaster <domains@digital.justice.gov.uk>
output "sendgrid_dns_records" {
  value = {
    record1 = {
      host = sendgrid_domain_authentication.sendgrid-domain-authenticate.dns[0].host
      data = sendgrid_domain_authentication.sendgrid-domain-authenticate.dns[0].data
    }
    record2 = {
      host = sendgrid_domain_authentication.sendgrid-domain-authenticate.dns[1].host
      data = sendgrid_domain_authentication.sendgrid-domain-authenticate.dns[1].data
    }
    record3 = {
      host = sendgrid_domain_authentication.sendgrid-domain-authenticate.dns[2].host
      data = sendgrid_domain_authentication.sendgrid-domain-authenticate.dns[2].data
    }
  }
}
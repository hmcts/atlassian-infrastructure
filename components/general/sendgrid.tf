# API Key with more open permissions for the Sengrid TF provider
# This is created manually on master Sendgrid account then added to the key vault
# TODO: 
# - change non-prod value to api key in Sendgrid account created with sendgrid-rdo automation
# - create this secret in prod vault
data "azurerm_key_vault_secret" "sendgrid-terraform-api-key" {
  name         = "platform-operations-sendgrid-api-key"
  key_vault_id = azurerm_key_vault.atlassian_kv.id
}

# Import existing API key already used on Prod
import {
  to = sendgrid_api_key.sendgrid-jira-api-key
  id = "mKQ52wP8SVmz7_YY8CsPHw"
}

# Import existing domain authenticate as the domain has already been verified
import {
  to = sendgrid_domain_authentication.sendgrid-domain-authenticate
  id = "em1187.cjscp.justice.gov.uk"
}

resource "sendgrid_api_key" "sendgrid-jira-api-key" {
  name   = "${var.env}-jira"
  scopes = ["mail.send", "2fa_required", "sender_verification_eligible", "whitelabel.read", "whitelabel.create", "whitelabel.delete", "whitelabel.update"]
}

resource "azurerm_key_vault_secret" "sendgrid-jira-api-key-secret" {
  name         = "jira-sendgrid-api-key"
  value        = sendgrid_api_key.sendgrid-jira-api-key.api_key
  key_vault_id = azurerm_key_vault.atlassian_kv.id
}

resource "sendgrid_domain_authentication" "sendgrid-domain-authenticate" {
  domain             = var.sendgrid_domain
  is_default         = true
  automatic_security = true
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
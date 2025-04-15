# API Key with more open permissions for the Sengrid TF provider
# This is created manually on master Sendgrid account then added to the key vault
# TODO: 
# - change non-prod value to api key in Sendgrid account created with sendgrid-rdo automation
# - create this secret in prod vault
data "azurerm_key_vault_secret" "sendgrid-terraform-api-key" {
  name         = "platform-operations-sendgrid-api-key"
  key_vault_id = azurerm_key_vault.atlassian_kv.id
}

resource "random_password" "sendgrid-subuser-pwd" {
  length           = 16
  special          = true
  min_numeric      = 1
  override_special = "_%@"
}

resource "azurerm_key_vault_secret" "subuser-pwd-secret" {
  name         = "hmcts-atlassian-${var.env}-sendgrid-subuser-pwd"
  value        = random_password.sendgrid-subuser-pwd.result
  key_vault_id = azurerm_key_vault.atlassian_kv.id
}

resource "sendgrid_subuser" "sendgrid-subuser-account" {
  provider = sendgrid
  username = "hmcts-atlassian-${var.env}-jira"
  email    = var.sendgrid_config.subuser_email
  password = random_password.sendgrid-subuser-pwd.result
  ips      = var.sendgrid_config.subuser_ips
}

resource "sendgrid_api_key" "subuser-api-key" {
  provider = sendgrid.subuser
  name     = "hmcts-atlassian-${var.env}-jira"
  scopes   = ["mail.send", "2fa_required", "sender_verification_eligible", "whitelabel.read", "whitelabel.create", "whitelabel.delete", "whitelabel.update"]
  depends_on = [
    sendgrid_subuser.sendgrid-subuser-account
  ]
}

resource "azurerm_key_vault_secret" "sendgrid-api-key-secret" {
  name         = "hmcts-atlassian-${var.env}-jira-sendgrid-api-key"
  value        = sendgrid_api_key.subuser-api-key.api_key
  key_vault_id = azurerm_key_vault.atlassian_kv.id
}

resource "sendgrid_domain_authentication" "sendgrid-domain-authenticate" {
  for_each           = toset(var.sendgrid_config.subuser_domains)
  provider           = sendgrid.subuser
  domain             = each.value
  is_default         = true
  automatic_security = true
  depends_on = [
    sendgrid_api_key.subuser-api-key
  ]
}

# Domain cjscp.justice.gov.uk is not hosted through Azure DNS, (Amazong Route 53)
# So these need to be manually verified by: legalservices webmaster <domains@digital.justice.gov.uk>
output "sendgrid_dns_records" {
  value = {
    for index, record in toset(var.sendgrid_config.subuser_domains) :
    "${index}" => {
      record1 = {
        host = sendgrid_domain_authentication.sendgrid-domain-authenticate["${index}"].dns[0].host
        data = sendgrid_domain_authentication.sendgrid-domain-authenticate["${index}"].dns[0].data
      }
      record2 = {
        host = sendgrid_domain_authentication.sendgrid-domain-authenticate["${index}"].dns[1].host
        data = sendgrid_domain_authentication.sendgrid-domain-authenticate["${index}"].dns[1].data
      }
      record3 = {
        host = sendgrid_domain_authentication.sendgrid-domain-authenticate["${index}"].dns[2].host
        data = sendgrid_domain_authentication.sendgrid-domain-authenticate["${index}"].dns[2].data
      }
    }
  }
}
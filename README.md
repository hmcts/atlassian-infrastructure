
This repository is used to create infrastructure for atlassian.

TODO: WIP
## Jira and SendGrid Email Service

### Postfix

Jira sends emails using locally running [Postfix](https://www.postfix.org/) service.
Postfix is configured to connect to SendGrid SMTP server using an API key created within the appropriate
SendGrid subuser account (nonprod/prod).  

### SendGrid

Main SendGrid account (Pro 300K) is created through automation in [rdo-sendgrid](https://github.com/hmcts/rdo-SendGrid),
it contains subuser account with a dedicated API key for each atlassian environment: non-prod and prod.
There is also a `platform-operations-api-key` in the main account, manually created and stored in both vaults
that the SendGrid provider in this Terraform uses to manage SendGrid resources.

Subuser accounts, their respective API Keys and domain validation requests are created for each environment by this provider, see [sendgrid.tf](components//general/sendgrid.tf) for details.  
API Keys on the subuser accounts only have permissions to send the mail and are stored in the appropriate
atlassian key vaults once they have been created within Sendgrid subuser account by automation.

Appropriate API Key is set in the Postfix configuration by the [configure-jira-vm.sh](components//general/scripts/configure-jira-vm.sh) script.

This repository is used to create infrastructure for atlassian.

TODO: WIP
## Jira and SendGrid Email Service

### Postfix

Jira sends emails using locally running [Postfix](https://www.postfix.org/) service.
Postfix is configured to connect to SendGrid SMTP server using an API key created within the appropriate
SendGrid subuser account (nonprod/prod).  
It holds an internal queue of emails to be sent which persist between postfix restarts and if for any reason
the email sending fails, it will re-attempt delivery at a later time.  
When investigating postfix configuration, these are the files to inspect:
- `/etc/postfix/main.cf` - the main configuration file
- `/etc/postfix/sasl_passwd` - the file containing the Sendgrid API key to be used by Postfix for email sending

[!IMPORTANT]  
Keep in mind that the Postfix's password database `/etc/postfix/sasl_passwd.db` needs to be updated after the
`sasl_passwd` file has been updated, this can be done with the following command: `postmap /etc/postfix/sasl_passwd`

### SendGrid

Main SendGrid account (Pro 300K) is created through automation in [rdo-sendgrid](https://github.com/hmcts/rdo-SendGrid),
it has a dedicated API key for each atlassian environment: `non-prod` and `prod`.
There is also a `platform-operations-api-key`, manually created and stored in both vaults that the SendGrid provider in this Terraform uses to manage SendGrid resources.

Respective API Keys and domain validation requests are created for each environment by this provider, see [sendgrid.tf](components//general/sendgrid.tf) for details.  
The API Key used in Postfix has a limited number of permissions which should only allow it to send emails and is stored
in each environment's key vault.

Appropriate API Key is set in the Postfix configuration by the [configure-jira-vm.sh](components//general/scripts/configure-jira-vm.sh) script (when corresponding flag is set to true).

### Domain verification

Before emails can be sent through SendGrid, we need to prove that the domain we send the emails from belongs to us. 
This is done using Sendgrid's Domain Authentication process and requires that DNS Records provided by SendGrid
are added to the Domain, until this is done the email sending will fail with following error:

```
The from address does not match a verified Sender Identity. Mail cannot be sent until this error is resolved. Visit https://sendgrid.com/docs/for-developers/sending-email/sender-identity/ to see the Sender Identity requirements (in reply to end of DATA command)
```

The Domain name that Jira is using is `jira@cjscp.justice.gov.uk` and it does not live within Azure and is not
managed by Platform Operations.  
It lives within Amazon's Route 53 and is managed by legal services webmaster, so if you need to add new records
for any reason to this domain contact: domains@digital.justice.gov.uk  
The records to add should be outputted in this pipeline, alternatively you can open Sendgrid account UI and
copy the records that need to be added by going to `Settings > Sender Authentication > <Click on the domain>`.

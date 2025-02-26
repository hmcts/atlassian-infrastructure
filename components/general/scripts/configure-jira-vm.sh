#!/bin/bash

set -x

source /tmp/functions.sh

# Access the variables
DB_URL=$1
DB_USERNAME=$2
DB_PASSWORD=$3
ENV=$4
APP_ACTION=$5

systemctl $APP_ACTION jira
log_entry "Executed systemctl $APP_ACTION jira"

# Grant permissions to Jira user
chown -R jira:jira /opt/atlassian/jira
chmod -R u+rw /opt/atlassian/jira
chown -R jira:jira /var/atlassian/application_data/jira_shared/node-status/
chmod -R u+rw /var/atlassian/application_data/jira_shared/node-status/
log_entry "Changed ownership of /opt/atlassian/jira to jira:jira"

# # Update /etc/hosts
if [ "$ENV" == "nonprod" ]; then
  update_hosts_file_staging
  log_entry "Added entries in the hosts file"
  # Replace glusterfs entry in /etc/fstab
  sed -i '/glusterfs/c\10.0.4.150:/jira_shared /var/atlassian/application_data/jira_shared glusterfs defaults 0 0' /etc/fstab
  mount -a
  log_entry "Mounted glusterfs"
  # Update Jira server.xml to replace tools.hmcts.net with staging.tools.hmcts.net
  for file2 in /opt/atlassian/jira/conf/server.xml /opt/atlassian/jira/data/customisations/conf/server.xml /opt/atlassian/jira/install/conf/server.xml; do
      sed -i 's/proxyName="tools\.hmcts\.net"/proxyName="staging.tools.hmcts.net"/g' $file2
      log_entry "Updated server.xml"
  done

  # Import SSL certificate

    openssl s_client -connect staging.tools.hmcts.net:443 -servername staging.tools.hmcts.net < /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /opt/atlassian/jira/jre/public.crt
    /opt/atlassian/jira/jre/bin/keytool -importcert -alias staging.tools.hmcts.net -keystore /opt/atlassian/jira/jre/lib/security/cacerts -file /opt/atlassian/jira/jre/public.crt -storepass changeit -noprompt
    log_entry "Imported SSL certificate"
    # Remove Dynatrace
    /opt/dynatrace/oneagent/agent/uninstall.sh
    log_entry "Uninstalled Dynatrace"

    mounting "jira" "/var/atlassian/application_data/jira_shared/"
else
  echo "No environment specified"
fi


# Update /etc/resolv.conf
RESOLV_CONF_ENTRIES="search ygysg2ix1xfehcfemfnemkbkwe.zx.internal.cloudapp.net
nameserver 168.63.129.16"
echo "${RESOLV_CONF_ENTRIES}" > /etc/resolv.conf
log_entry "Updated resolv.conf"

# Update dbconfig.xml
for file in /var/atlassian/application_data/jira_shared/dbconfig.xml /opt/atlassian/jira/data/dbconfig.xml; do
  sed -i "s|<url>.*</url>|<url>${DB_URL}</url>|" $file
  sed -i "s|<username>.*</username>|<username>${DB_USERNAME}</username>|" $file
  sed -i "s|<password>.*</password>|<password>${DB_PASSWORD}</password>|" $file
done
log_entry "Updated dbconfig.xml"

systemctl start jira
log_entry "started jira"
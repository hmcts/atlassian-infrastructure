#!/bin/bash

set -x

systemctl stop jira

source /tmp/functions.sh

# Access the variables
DB_URL=$1
DB_USERNAME=$2
DB_PASSWORD=$3
ENV=$4

# Grant permissions to Jira user
chown -R jira:jira /opt/atlassian/jira
chmod -R u+rw /opt/atlassian/jira
# chown -R jira:jira /var/atlassian/application_data/jira_shared
# chmod -R u+rw /var/atlassian/application_data/jira_shared

# # Update /etc/hosts
if [ "$ENV" == "Staging" ]; then
  update_hosts_file_staging
else
  echo "No environment specified"
fi


# Update /etc/resolv.conf
RESOLV_CONF_ENTRIES="
search ygysg2ix1xfehcfemfnemkbkwe.zx.internal.cloudapp.net
nameserver 168.63.129.16
"
echo "${RESOLV_CONF_ENTRIES}" > /etc/resolv.conf

# Replace glusterfs entry in /etc/fstab
if [ "$ENV" == "Staging" ]; then
  sed -i '/glusterfs/c\10.0.4.150:/jira_shared /var/atlassian/application_data/jira_shared glusterfs defaults 0 0' /etc/fstab
else
  echo "No environment specified"
fi


mount -a

# Update dbconfig.xml
for file in /var/atlassian/application_data/jira_shared/dbconfig.xml /opt/atlassian/jira/data/dbconfig.xml; do
  sed -i "s|<url>.*</url>|<url>${DB_URL}</url>|" $file
  sed -i "s|<username>.*</username>|<username>${DB_USERNAME}</username>|" $file
  sed -i "s|<password>.*</password>|<password>${DB_PASSWORD}</password>|" $file
done

# Update Jira server.xml to replace tools.hmcts.net with staging.tools.hmcts.net
if [ "$ENV" == "Staging" ]; then
  sed -i 's/proxyName="tools\.hmcts\.net"/proxyName="staging.tools.hmcts.net"/g' /opt/atlassian/jira/conf/server.xml
else
  echo "No changes needed"
fi


# Import SSL certificate
if [ "$ENV" == "Staging" ]; then
    openssl s_client -connect staging.tools.hmcts.net:443 -servername staging.tools.hmcts.net < /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /opt/atlassian/jira/jre/public.crt
    /opt/atlassian/jira/jre/bin/keytool -importcert -alias staging.tools.hmcts.net -keystore /opt/atlassian/jira/jre/lib/security/cacerts -file /opt/atlassian/jira/jre/public.crt -storepass changeit
else
  echo "No changes needed"
fi



systemctl start jira

# Remove Dynatrace
if [ "$ENV" == "Staging" ]; then
  /opt/dynatrace/oneagent/agent/uninstall.sh
else
  echo "No changes needed"
fi
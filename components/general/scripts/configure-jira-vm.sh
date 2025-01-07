#!/bin/bash

set -x

source ./functions.sh

# Access the variables
DB_URL=$1
DB_USERNAME=$2
DB_PASSWORD=$3

# Grant permissions to Jira user
chown -R jira:jira /opt/atlassian/jira
chmod -R u+rw /opt/atlassian/jira
chown -R jira:jira /var/atlassian/application_data/jira_shared
chmod -R u+rw /var/atlassian/application_data/jira_shared

# Update /etc/hosts
update_hosts_file

# Update /etc/resolv.conf
RESOLV_CONF_ENTRIES="
search ygysg2ix1xfehcfemfnemkbkwe.zx.internal.cloudapp.net
nameserver 168.63.129.16
"
echo "${RESOLV_CONF_ENTRIES}" > /etc/resolv.conf

# Replace glusterfs entry in /etc/fstab
sed -i '/glusterfs/c\10.0.4.150:/jira_shared /var/atlassian/application_data/jira_shared glusterfs defaults 0 0' /etc/fstab

# Update dbconfig.xml
for file in /var/atlassian/application_data/jira_shared/dbconfig.xml /opt/atlassian/jira/data/dbconfig.xml; do
  sed -i "s|<url>.*</url>|<url>${DB_URL}</url>|" $file
  sed -i "s|<username>.*</username>|<username>${DB_USERNAME}</username>|" $file
  sed -i "s|<password>.*</password>|<password>${DB_PASSWORD}</password>|" $file
done

# Update Jira server.xml to replace tools.hmcts.net with staging.tools.hmcts.net
sed -i 's/tools\.hmcts\.net/staging.tools.hmcts.net/g' /opt/atlassian/jira/conf/server.xml

# Import SSL certificate
cd /opt/atlassian/jira/jre
openssl s_client -connect staging.tools.hmcts.net:443 -servername staging.tools.hmcts.net < /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > public.crt
./bin/keytool -importcert -alias staging.tools.hmcts.net -keystore ./lib/security/cacerts -file public.crt
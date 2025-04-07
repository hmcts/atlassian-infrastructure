#!/bin/bash
set -x

source /tmp/functions.sh

# Access the variables.
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

  # Update /etc/resolv.conf
  RESOLV_CONF_ENTRIES="search ygysg2ix1xfehcfemfnemkbkwe.zx.internal.cloudapp.net
  nameserver 168.63.129.16"
  echo "${RESOLV_CONF_ENTRIES}" > /etc/resolv.conf
  log_entry "Updated resolv.conf"

  # Update SSL certificate
  CERT_ALIAS_INPUT="staging.tools.hmcts.net"
  check_and_replace_cert $CERT_ALIAS_INPUT


elif [ "$ENV" == "prod" ]; then
  update_hosts_file_prod
  log_entry "Added entries in the hosts file"
  # Replace glusterfs entry in /etc/fstab
  sed -i '/glusterfs/c\10.1.4.150:/jira_shared /var/atlassian/application_data/jira_shared glusterfs defaults 0 0' /etc/fstab
  mount -a
  log_entry "Mounted glusterfs"

  # Update /etc/resolv.conf
  RESOLV_CONF_ENTRIES="search e3aqxhxo1fvubo0wzweg4zp0eg.zx.internal.cloudapp.net
  nameserver 168.63.129.16"
  echo "${RESOLV_CONF_ENTRIES}" > /etc/resolv.conf
  log_entry "Updated resolv.conf"

 # Update SSL certificate
  CERT_ALIAS="tools.hmcts.net"
  check_and_replace_cert $CERT_ALIAS_INPUT

  if [ $? -eq 0 ]; then
    log_entry "Check completed (no change or successful update)."
  else
    log_entry "Something went wrong during certificate check/update." >&2
  fi

else
  log_entry "No environment specified"
fi

mounting "jira" "/var/atlassian/application_data/jira_shared/"

# Update NTP
  configure_ntp

# Update ntp.conf
  update_ntp_conf

# Update dbconfig.xml
for file in /var/atlassian/application_data/jira_shared/dbconfig.xml /opt/atlassian/jira/data/dbconfig.xml; do
  sed -i "s|<url>.*</url>|<url>${DB_URL}</url>|" $file
  sed -i "s|<username>.*</username>|<username>${DB_USERNAME}</username>|" $file
  sed -i "s|<password>.*</password>|<password>${DB_PASSWORD}</password>|" $file
done
log_entry "Updated dbconfig.xml"

# Update robots.txt
log_entry "Updating robots.txt"
ROBOTS_FILE="/opt/atlassian/jira/install/atlassian-jira/robots.txt"
TEMPLATE_FILE="/tmp/robots_template.txt"

# Replace robots.txt with the template content
cp "$TEMPLATE_FILE" "$ROBOTS_FILE"
# Add a new line at the end of the file
echo "" >> /opt/atlassian/jira/install/atlassian-jira/robots.txt

# Ensure proper permissions
chmod 644 "$ROBOTS_FILE"

log_entry "robots.txt updated from template file"

systemctl start jira
log_entry "started jira"
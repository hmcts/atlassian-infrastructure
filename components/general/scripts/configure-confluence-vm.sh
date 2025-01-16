#!/bin/bash

set -x

source /tmp/functions.sh

# Access the variables
DB_URL=$1
DB_USERNAME=$2
DB_PASSWORD=$3
ENV=$4
APP_ACTION=$5
PRIVATE_IPS=$6

systemctl $APP_ACTION confluence

log_entry "Executed systemctl $APP_ACTION confluence"

# Grant permissions to confluence user
chown -R confluence:confluence /opt/atlassian
chmod -R u+rw /opt/atlassian

log_entry "Changed ownership of /opt/atlassian to confluence:confluence"

# # Update /etc/hosts
if [ "$ENV" == "nonprod" ]; then
  update_hosts_file_staging
  log_entry "Added entries in the hosts file"
  # Replace glusterfs entry in /etc/fstab
  sed -i '/glusterfs/c\10.0.4.150:/confluence_shared /var/atlassian/application_data/confluence_shared glusterfs defaults 0 0' /etc/fstab
  mount -a
  log_entry "Mounted glusterfs"
  # Update confluence server.xml to replace tools.hmcts.net with staging.tools.hmcts.net
  sed -i 's/proxyName="tools\.hmcts\.net"/proxyName="staging.tools.hmcts.net"/g' /opt/atlassian/confluence/install/conf/server.xml
  log_entry "Updated server.xml"

    # Remove Dynatrace
    /opt/dynatrace/oneagent/agent/uninstall.sh
    log_entry "Uninstalled Dynatrace"

    mounting "confluence"
else
  echo "No environment specified"
fi


# Update /etc/resolv.conf
RESOLV_CONF_ENTRIES="search ygysg2ix1xfehcfemfnemkbkwe.zx.internal.cloudapp.net
nameserver 168.63.129.16"
echo "${RESOLV_CONF_ENTRIES}" > /etc/resolv.conf
log_entry "Updated resolv.conf"

# Update dbconfig.xml
for file in /var/atlassian/application_data/confluence_shared/confluence.cfg.xml /opt/atlassian/confluence/data/confluence.cfg.xml; do
  sed -i "s|<property name=\"hibernate.connection.url\">.*</property>|<property name=\"hibernate.connection.url\">${DB_URL}</property>|" $file
  sed -i "s|<property name=\"hibernate.connection.username\">.*</property>|<property name=\"hibernate.connection.username\">${DB_USERNAME}</property>|" $file
  sed -i "s|<property name=\"hibernate.connection.password\">.*</property>|<property name=\"hibernate.connection.password\">${DB_PASSWORD}</property>|" $file
  sed -i "s|<property name=\"confluence.cluster.peers\">.*</property>|<property name=\"confluence.cluster.peers\">${PRIVATE_IPS}</property>|" $file
done
log_entry "Updated dbconfig.xml"

systemctl start confluence
log_entry "started confluence"
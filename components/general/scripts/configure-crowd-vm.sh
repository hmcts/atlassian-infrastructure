#!/bin/bash
# Updating hash
set -x

source /tmp/functions.sh

# Access the variables
DB_URL=$1
DB_USERNAME=$2
DB_PASSWORD=$3
ENV=$4
APP_ACTION=$5

systemctl $APP_ACTION crowd
log_entry "Executed systemctl $APP_ACTION crowd"

# Grant permissions to crowd user
chown -R crowd:crowd /opt/crowd
chmod -R u+rw /opt/crowd

log_entry "Changed ownership of /opt/crowd to crowd:crowd"

# Remove Dynatrace
/opt/dynatrace/oneagent/agent/uninstall.sh
log_entry "Uninstalled Dynatrace"

# # Update /etc/hosts
if [ "$ENV" == "nonprod" ]; then
  update_hosts_file_staging
  log_entry "Added entries in the hosts file"
  # Replace glusterfs entry in /etc/fstab
  sed -i '/glusterfs/c\10.0.4.150:/crowd_shared /var/atlassian/application-data/crowd_shared glusterfs defaults 0 0' /etc/fstab
  mount -a
  log_entry "Mounted glusterfs"
  # Update crowd server.xml to replace tools.hmcts.net with prod-temp.tools.hmcts.net
  sed -i 's/proxyName="tools\.hmcts\.net"/proxyName="staging.tools.hmcts.net"/g' /opt/crowd/apache-tomcat/conf/server.xml
  log_entry "Updated server.xml"

  mounting "crowd" "/var/atlassian/application-data/crowd_shared"
elif [ "$ENV" == "prod" ]; then
  update_hosts_file_prod
  log_entry "Added entries in the hosts file"

  # Replace glusterfs entry in /etc/fstab
  sed -i '/glusterfs/c\10.1.4.150:/crowd_shared /var/atlassian/application-data/crowd_shared glusterfs defaults 0 0' /etc/fstab
  mount -a
  log_entry "Mounted glusterfs"

  #TO BE REMOVED FOR PRODUCTION DEPLOY AFTER TESTING
  # Update crowd server.xml to replace tools.hmcts.net with prod-temp.tools.hmcts.net
  sed -i 's/proxyName="tools\.hmcts\.net"/proxyName="prod-temp.tools.hmcts.net"/g' /opt/crowd/apache-tomcat/conf/server.xml
  log_entry "Updated server.xml"

  mounting "crowd" "/var/atlassian/application-data/crowd_shared"


else
  echo "No environment specified"
fi


# Update /etc/resolv.conf
RESOLV_CONF_ENTRIES="search ygysg2ix1xfehcfemfnemkbkwe.zx.internal.cloudapp.net
nameserver 168.63.129.16"
echo "${RESOLV_CONF_ENTRIES}" > /etc/resolv.conf
log_entry "Updated resolv.conf"

# Update dbconfig.xml
for file in /var/atlassian/application-data/crowd_shared/crowd-home/shared/crowd.cfg.xml; do
  sed -i "s|<property name=\"hibernate.connection.url\">.*</property>|<property name=\"hibernate.connection.url\">${DB_URL}</property>|" $file
  sed -i "s|<property name=\"hibernate.connection.username\">.*</property>|<property name=\"hibernate.connection.username\">${DB_USERNAME}</property>|" $file
  sed -i "s|<property name=\"hibernate.connection.password\">.*</property>|<property name=\"hibernate.connection.password\">${DB_PASSWORD}</property>|" $file
done
log_entry "Updated dbconfig.xml"

systemctl start crowd
log_entry "started crowd"
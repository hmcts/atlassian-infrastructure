#!/bin/bash
set -x
source /tmp/functions.sh

ENV=$4

# # Update /etc/hosts
if [ "$ENV" == "nonprod" ]; then
  update_hosts_file_staging
  log_entry "Added entries in the hosts file"

elif [ "$ENV" == "prod" ]; then
  update_hosts_file_prod
  log_entry "Added entries in the hosts file"

else
  echo "No environment specified"
fi

# Update NTP
  configure_ntp

# Update ntp.conf
  update_ntp_conf

if [ "$ENV" == "nonprod" ]; then
  # Remove Dynatrace.
  # /opt/dynatrace/oneagent/agent/uninstall.sh
  # log_entry "Uninstalled Dynatrace"

  # Update /etc/resolv.conf
  RESOLV_CONF_ENTRIES="search ygysg2ix1xfehcfemfnemkbkwe.zx.internal.cloudapp.net
  nameserver 168.63.129.16"
  echo "${RESOLV_CONF_ENTRIES}" > /etc/resolv.conf
  log_entry "Updated resolv.conf"

elif [ "$ENV" == "prod" ]; then
  # Update /etc/resolv.conf
  RESOLV_CONF_ENTRIES="search e3aqxhxo1fvubo0wzweg4zp0eg.zx.internal.cloudapp.net
  nameserver 168.63.129.16"
  echo "${RESOLV_CONF_ENTRIES}" > /etc/resolv.conf
  log_entry "Updated resolv.conf"

else
  log_entry "No environment specified"
fi
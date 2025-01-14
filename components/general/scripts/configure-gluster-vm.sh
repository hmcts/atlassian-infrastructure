#!/bin/bash

set -x

source /tmp/functions.sh

ENV=$4

# # Update /etc/hosts
if [ "$ENV" == "nonprod" ]; then
  update_hosts_file_staging
  log_entry "Added entries in the hosts file"

  # Remove Dynatrace
  /opt/dynatrace/oneagent/agent/uninstall.sh
  log_entry "Uninstalled Dynatrace"
else
  echo "No environment specified"
fi

# Update /etc/resolv.conf
RESOLV_CONF_ENTRIES="search ygysg2ix1xfehcfemfnemkbkwe.zx.internal.cloudapp.net
nameserver 168.63.129.16"
echo "${RESOLV_CONF_ENTRIES}" > /etc/resolv.conf

log_entry "Updated resolv.conf"
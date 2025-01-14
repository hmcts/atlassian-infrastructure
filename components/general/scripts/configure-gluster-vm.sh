#!/bin/bash

set -x

source /tmp/functions.sh

# # Update /etc/hosts
if [ "$ENV" == "nonprod" ]; then
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


#!/bin/bash

update_hosts_file_staging() {
    HOST_ENTRIES="127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
10.0.4.198 PRDATL01AJRA01.cp.cjs.hmcts.net PRDATL01AJRA01
10.0.4.198 PRDATL01AJRA01.CP.CJS.HMCTS.NET prdatl01ajra01
10.0.4.199 PRDATL01AJRA02.cp.cjs.hmcts.net PRDATL01AJRA02
10.0.4.199 PRDATL01AJRA02.CP.CJS.HMCTS.NET prdatl01ajra02
10.0.4.196 PRDATL01AJRA03.cp.cjs.hmcts.net PRDATL01AJRA03
10.0.4.196 PRDATL01AJRA03.CP.CJS.HMCTS.NET prdatl01ajra03
10.0.4.133 PRDATL01DGST01.cp.cjs.hmcts.net prdatl01dgst01
10.0.4.132 PRDATL01DGST02.cp.cjs.hmcts.net prdatl01dgst02
10.0.4.134 PRDATL01DGST03.cp.cjs.hmcts.net prdatl01dgst03
10.0.4.197 PRDATL01ACRD01.cp.cjs.hmcts.net PRDATL01ACRD01
10.0.4.197 PRDATL01ACRD01.CP.CJS.HMCTS.NET prdatl01acrd01
10.0.4.201 PRDATL01ACNF02.cp.cjs.hmcts.net PRDATL01ACNF02
10.0.4.201 PRDATL01ACNF02.CP.CJS.HMCTS.NET prdatl01acnf02
10.0.4.200 PRDATL01ACNF04.CP.CJS.HMCTS.NET prdatl01acnf04
10.0.4.200 PRDATL01ACNF04.cp.cjs.hmcts.net PRDATL01ACNF04
10.0.4.197 prdatl01lbcrd01"
echo "${HOST_ENTRIES}" > /etc/hosts
}

log_entry() {
  LOG_FILE="/tmp/configure-file.log"
  if [ ! -f $LOG_FILE ]; then
    touch $LOG_FILE
  fi
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

mounting() {
  # Create the /tmp/mounting.sh file with the specified contents

  path_to_check=$2

cat <<EOL > /tmp/mounting.sh
#!/bin/bash
if ! mountpoint -q "$path_to_check"; then
  echo "$path_to_check is not mounted. Mounting now..."
  mount -a
  systemctl stop $1
  systemctl start $1
else
  echo "$path_to_check is already mounted. No action required."
fi
EOL

# Make the script executable
chmod +x /tmp/mounting.sh

# Define the cron job
cron_job="0 * * * * /bin/bash /tmp/mounting.sh"

# Check if the cron job already exists and add it if not
  if ! crontab -l 2>/dev/null | grep -qF "$cron_job"; then
    # Remove any existing cron jobs with mounting.sh
    (crontab -l 2>/dev/null | grep -v '/tmp/mounting.sh') | crontab -

    # Add the new cron job
    (crontab -l 2>/dev/null; echo "$cron_job") | crontab -
  fi

log_entry "mounting cron job has been added to run 8am daily"
}
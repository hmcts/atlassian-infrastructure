#!/bin/bash

# Grant permissions to Jira user
chown -R jira:jira /opt/atlassian/jira
chmod -R u+rw /opt/atlassian/jira
chown -R jira:jira /var/atlassian/application_data/jira_shared
chmod -R u+rw /var/atlassian/application_data/jira_shared

# Update /etc/hosts
HOST_ENTRIES="
10.0.4.203 PRDATL01AJRA01.cp.cjs.hmcts.net PRDATL01AJRA01
10.0.4.203 PRDATL01AJRA01.CP.CJS.HMCTS.NET prdatl01ajra01
10.0.4.204 PRDATL01AJRA02.cp.cjs.hmcts.net PRDATL01AJRA02
10.0.4.204 PRDATL01AJRA02.CP.CJS.HMCTS.NET prdatl01ajra02
10.0.4.205 PRDATL01AJRA03.cp.cjs.hmcts.net PRDATL01AJRA03
10.0.4.205 PRDATL01AJRA03.CP.CJS.HMCTS.NET prdatl01ajra03
10.0.4.132 PRDATL01DGST01.cp.cjs.hmcts.net prdatl01dgst01
10.0.4.133 PRDATL01DGST02.cp.cjs.hmcts.net prdatl01dgst02
10.0.4.134 PRDATL01DGST03.cp.cjs.hmcts.net prdatl01dgst03
"
echo "${HOST_ENTRIES}" > /etc/hosts

# Update /etc/resolv.conf
RESOLV_CONF_ENTRIES="
search ygysg2ix1xfehcfemfnemkbkwe.zx.internal.cloudapp.net
nameserver 168.63.129.16
"
echo "${RESOLV_CONF_ENTRIES}" > /etc/resolv.conf

# TODO: Amend fstab

# TODO: Mount Gluster FS and update dbconfig.xml

# Update Jira server.xml to replace tools.hmcts.net with staging.tools.hmcts.net
sed -i 's/tools\.hmcts\.net/staging.tools.hmcts.net/g' /opt/atlassian/jira/conf/server.xml

# Import SSL certificate
cd /opt/atlassian/jira/jre
openssl s_client -connect staging.tools.hmcts.net:443 -servername staging.tools.hmcts.net < /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > public.crt
./bin/keytool -importcert -alias staging.tools.hmcts.net -keystore ./lib/security/cacerts -file public.crt
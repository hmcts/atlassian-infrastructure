#!/bin/bash

update_hosts_file() {
    HOST_ENTRIES="
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
10.0.4.203 PRDATL01AJRA01.cp.cjs.hmcts.net PRDATL01AJRA01
10.0.4.203 PRDATL01AJRA01.CP.CJS.HMCTS.NET prdatl01ajra01
10.0.4.204 PRDATL01AJRA02.cp.cjs.hmcts.net PRDATL01AJRA02
10.0.4.204 PRDATL01AJRA02.CP.CJS.HMCTS.NET prdatl01ajra02
10.0.4.205 PRDATL01AJRA03.cp.cjs.hmcts.net PRDATL01AJRA03
10.0.4.205 PRDATL01AJRA03.CP.CJS.HMCTS.NET prdatl01ajra03
10.0.4.132 PRDATL01DGST01.cp.cjs.hmcts.net prdatl01dgst01
10.0.4.133 PRDATL01DGST02.cp.cjs.hmcts.net prdatl01dgst02
10.0.4.134 PRDATL01DGST03.cp.cjs.hmcts.net prdatl01dgst03
10.0.4.202 PRDATL01ACRD01.cp.cjs.hmcts.net PRDATL01ACRD01
10.0.4.202 PRDATL01ACRD01.CP.CJS.HMCTS.NET prdatl01acrd01
"
echo "${HOST_ENTRIES}" > /etc/hosts
}
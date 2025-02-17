az account set --subscription 79898897-729c-41a0-a5ca-53c764839d95

TargetSubnetName=atlassian-int-subnet-app #eg "atlassian-int-subnet-dat"
TargetVmName=atlassian-prod-confluence-04 # eg "atlassian-nonprod-gluster-03"
ItemName=PRDATL01ACNF04.cp.cjs.hmcts.net # eg"PRDATL01DGST03.cp.cjs.hmcts.net"

VaultName="BK-PRD-ATL-INT-01"
SourceResourceGroup="RG-PRD-ATL-INT-01"
SourceSubscription="79898897-729c-41a0-a5ca-53c764839d95"
TargetResouceGroup="atlassian-prod-rg"
TargetSubscription="79898897-729c-41a0-a5ca-53c764839d95"
StorageAccountName="atlassianprod"
TargetVNetName="atlassian-int-prod-vnet"

# az backup container list --resource-group $SourceResourceGroup --vault-name $VaultName --backup-management-type AzureIaasVM --query '[].{Name:name, ItemName:properties.friendlyName}' -o table

ContainerName=$(az backup container list --resource-group $SourceResourceGroup --vault-name $VaultName --backup-management-type AzureIaasVM --query "[?properties.friendlyName=='$ItemName'].{Name:name}" -o tsv)

# az backup recoverypoint list --vault-name $VaultName --resource-group $SourceResourceGroup --container-name $ContainerName --item-name $ItemName --query '[].{Name:properties.recoveryPointTime, ID:name}' -o table

RecoverypointName=$(az backup recoverypoint list --vault-name $VaultName --resource-group $SourceResourceGroup --container-name $ContainerName --item-name $ItemName --query '[0].name' -o tsv)

echo $RecoverypointName

az backup restore restore-disks \
    --resource-group $SourceResourceGroup \
    --vault-name $VaultName \
    --item-name $ItemName \
    --rp-name $RecoverypointName \
    --storage-account $StorageAccountName \
    --restore-to-staging-storage-account true \
    --target-resource-group $TargetResouceGroup \
    --target-subscription-id $TargetSubscription \
    --target-vm-name $TargetVmName \
    --target-vnet-name $TargetVNetName \
    --target-subnet-name $TargetSubnetName \
    --target-vnet-resource-group $TargetResouceGroup \
    --container-name $ContainerName \
    --subscription $SourceSubscription \
    --storage-account-resource-group $TargetResouceGroup
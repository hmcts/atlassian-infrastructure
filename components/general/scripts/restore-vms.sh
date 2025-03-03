#!/bin/bash

# Set the Azure subscription
az account set --subscription "79898897-729c-41a0-a5ca-53c764839d95"

# Define variables
TargetSubnetName="atlassian-int-subnet-dat" # eg "atlassian-int-subnet-dat"
TargetVmName="atlassian-prod-gluster-03" # eg "atlassian-nonprod-gluster-03"
ItemName="PRDATL01DGST03.cp.cjs.hmcts.net" # eg "PRDATL01DGST03.cp.cjs.hmcts.net"

VaultName="BK-PRD-ATL-INT-01"
SourceResourceGroup="RG-PRD-ATL-INT-01"
SourceSubscription="79898897-729c-41a0-a5ca-53c764839d95"
TargetResouceGroup="atlassian-prod-rg"
TargetSubscription="79898897-729c-41a0-a5ca-53c764839d95"
StorageAccountName="atlassianprod"
TargetVNetName="atlassian-int-prod-vnet"

# Get the container name
ContainerName=$(az backup container list --resource-group $SourceResourceGroup --vault-name $VaultName --backup-management-type AzureIaasVM --query "[?properties.friendlyName=='$ItemName'].{Name:name}" -o tsv)

# Debugging: Print the container name
echo "ContainerName: $ContainerName"

# Get the recovery point name
RecoverypointName=$(az backup recoverypoint list --vault-name $VaultName --resource-group $SourceResourceGroup --container-name $ContainerName --item-name $ItemName --query '[0].name' -o tsv)

# Debugging: Print the recovery point name
echo "RecoverypointName: $RecoverypointName"

# Check if the recovery point name is empty
if [ -z "$RecoverypointName" ]; then
  echo "Error: RecoverypointName is empty. Exiting."
  exit 1
fi

# Restore the disks
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
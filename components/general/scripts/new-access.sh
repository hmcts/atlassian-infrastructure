#!/bin/bash

# Define an array of Target VM Names
#TargetVmNames=("atlassian-prod-jira-01" "atlassian-prod-jira-02" "atlassian-prod-jira-03" "atlassian-prod-gluster-01" "atlassian-prod-gluster-02" "atlassian-prod-gluster-03" "atlassian-prod-crowd-01" "atlassian-prod-confluence-02" "atlassian-prod-confluence-04") # Add more VMs as needed
TargetVmNames=("atlassian-prod-jira-01")
TargetSubscription="79898897-729c-41a0-a5ca-53c764839d95"

# Set the Azure subscription
az account set --subscription $TargetSubscription

# Define Key Vault details
KeyvaultName="atlasssian-prod-kv"
SecretName="public-key"
TargetResouceGroup="atlassian-prod-rg"

# Fetch the SSH Public Key from Key Vault
echo "Fetching SSH Public Key from Key Vault..."
PublicKey=$(az keyvault secret show \
  --vault-name $KeyvaultName \
  --name $SecretName \
  --subscription $TargetSubscription \
  --query value -o tsv | tr -d '\n')

# Check if the key was retrieved successfully
if [ -z "$PublicKey" ]; then
  echo "ERROR: Failed to retrieve public key from Key Vault."
  exit 1
fi
echo "Public Key retrieved successfully."

# Set the username
username="atlassian-admin"

# Loop through each VM in the list and update the SSH key
for TargetVmName in "${TargetVmNames[@]}"; do
  echo "Updating SSH key for VM: $TargetVmName..."
  
  az vm user update \
    --resource-group $TargetResouceGroup \
    --name $TargetVmName \
    --username $username \
    --ssh-key-value "$PublicKey" \
    --subscription $TargetSubscription
  
  # Check if the update was successful
  if [ $? -eq 0 ]; then
    echo "Successfully updated SSH key for $TargetVmName."
  else
    echo "ERROR: Failed to update SSH key for $TargetVmName."
  fi

  echo "---------------------------------------------"
done

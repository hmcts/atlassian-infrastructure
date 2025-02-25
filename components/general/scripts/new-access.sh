#!/bin/bash

# Define an array of Target VM Names
TargetVmNames=("atlassian-nonprod-jira-01" "atlassian-nonprod-jira-02" "atlassian-nonprod-jira-03" "atlassian-nonprod-gluster-01" "atlassian-nonprod-gluster-02" "atlassian-nonprod-gluster-03" "atlassian-nonprod-crowd-01" "atlassian-nonprod-confluence-02" "atlassian-nonprod-confluence-04") # Add more VMs as needed
TargetSubscription="b7d2bd5f-b744-4acc-9c73-e068cec2e8d8"

# Set the Azure subscription
az account set --subscription $TargetSubscription

# Define Key Vault details
KeyvaultName="atlasssian-nonprod-kv"
SecretName="public-key"
TargetResouceGroup="atlassian-nonprod-rg"

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

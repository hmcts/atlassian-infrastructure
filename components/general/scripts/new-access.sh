TargetVmName="atlassian-prod-jira-01" # eg "atlassian-nonprod-gluster-03"

az account set --subscription 79898897-729c-41a0-a5ca-53c764839d95
TargetSubscription="79898897-729c-41a0-a5ca-53c764839d95"
KeyvaultName="atlasssian-prod-kv"
SecretName="public-key"
TargetResouceGroup="atlassian-prod-rg"

PublicKey=$(az keyvault secret show \
  --vault-name $KeyvaultName \
  --name $SecretName \
  --subscription $TargetSubscription \
  --query value -o tsv)

username="atlassian-admin"

az vm user update \
  --resource-group $TargetResouceGroup \
  --name $TargetVmName \
  --username $username \
  --ssh-key-value $PublicKey \
  --subscription $TargetSubscription
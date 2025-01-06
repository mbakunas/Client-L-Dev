# Get the subscription ID
subscriptionId=$(az account show --output tsv --query id)

# Run the Azure Resource Graph query and export the results to a YAML file
az graph query -q '
resources 
| where type != "microsoft.azureactivedirectory/b2cdirectories" 
| where identity != "" or properties.tenantId != "" or properties.encryptionSettingsCollection.enabled == true 
| project name, type, kind, identity, tenantId, properties.tenantId
' --subscriptions $subscriptionId --output yaml > resources.yaml

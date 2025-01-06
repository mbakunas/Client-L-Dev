# Set the variables Login Variables
 #$tenant = "ae07d7b4-6085-45f8-a079-d1bfdcbf39cc" #Target Sandbox Tenant ID
 #$subscription = "9f1e9219-305f-4e5d-a752-84c1e239234a" #BergBest-OLD Subscription
 
 $name = "AJRD"
 $tenant = "e000d438-41ca-492b-bfe0-394c9b9dc25c" #AJRD Tenant ID
 $subscription = "8eb39352-c3a5-47f9-a677-42912c1b5ab1" #AJRD Subscription

 #$tenant ="ba488c5e-f105-4a2b-a8b1-b57b26a44117" #LHX Tenant ID
 
 # Login to Azure
#Connect-AzAccount -Environment AzureCloud -Tenant $tenant -Subscription $subscription #-deviceauth 

# Get Date
$date = get-date -Format "dd-MM-yyyy" 

# Select the Azure subscription
Select-AzSubscription -SubscriptionId $subscription

# Get all Key Vaults in the subscription
$keyVaults = Get-AzKeyVault 

# Initialize an array to hold detailed information
$keyVaultDetails = @()

# Loop through each Key Vault and get detailed information
foreach ($keyVault in $keyVaults) {
    $details = az keyvault show --resource-group $keyVault.ResourceGroupName --name $keyVault.VaultName --output json | ConvertFrom-Json
    $keyVaultDetails += $details

    # Get access policies for the Key Vault
    $accessPolicies = az keyvault show --resource-group $keyVault.ResourceGroupName --name $keyVault.VaultName --query "properties.accessPolicies" --output json | ConvertFrom-Json

    # Add access policies to the details
    $details | Add-Member -MemberType NoteProperty -Name "AccessPolicies" -Value $accessPolicies
    
    $keyVaultDetails += $details
}

# Convert the detailed information to JSON
$keyVaultDetailsJson = $keyVaultDetails | ConvertTo-Json -Depth 10

# Write the formatted JSON to the output file
$outputFile = $name + "-KeyVaultInfo-$date.json"
Set-Content -Path $outputFile -Value $keyVaultDetailsJson

Write-Output "All Key Vaults have been exported to $outputFile"



                
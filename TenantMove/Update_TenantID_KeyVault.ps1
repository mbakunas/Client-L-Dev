# Set the variables Login Variables
 #$tenant = "ae07d7b4-6085-45f8-a079-d1bfdcbf39cc" #Target Sandbox Tenant ID
  $tenant = "7905dcdc-bd59-4ad0-8e20-ddb43ae5f4d4" #BestBerg
  $subscription = "9f1e9219-305f-4e5d-a752-84c1e239234a" #BergBest-OLD Subscription

 #$tenant = "e000d438-41ca-492b-bfe0-394c9b9dc25c" #AJRD Tenant ID
 #$subscription = "8eb39352-c3a5-47f9-a677-42912c1b5ab1" #AJRD Subscription

 #$tenant ="ba488c5e-f105-4a2b-a8b1-b57b26a44117" #LHX Tenant ID

 # Login to Azure
Connect-AzAccount -Tenant $tenant -Subscription $subscription #-Environment AzureCloud -deviceauth 

# Select the Azure subscription
Select-AzSubscription -SubscriptionId $subscription


# Get all Key Vaults in the subscription
$keyVaults = Get-AzKeyVault

# Loop through each Key Vault and modify its properties
foreach ($keyVault in $keyVaults) {
    $vaultResourceId = $keyVault.ResourceId
    $vault = Get-AzResource -ResourceId $vaultResourceId -ExpandProperties

    # Change the Tenant that your key vault resides in
    $vault.Properties.TenantId = (Get-AzContext).Tenant.TenantId

    # Update access policies (here we are not setting any access policies)
    $vault.Properties.AccessPolicies = @()

    # Modify the key vault's properties
    Set-AzResource -ResourceId $vaultResourceId -Properties $vault.Properties

    Write-Output "Updated Key Vault: $($keyVault.VaultName)"
}

Write-Output "All Key Vaults have been updated."























#Updates Tenants
Select-AzSubscription -SubscriptionId $subscription                        # Select your Azure Subscription
$vaultResourceId = (Get-AzKeyVault -VaultName CSSKeys).ResourceId          # Get your key vault's Resource ID 
$vault = Get-AzResource -ResourceId $vaultResourceId -ExpandProperties     # Get the properties for your key vault
$vault.Properties.TenantId = (Get-AzContext).Tenant.TenantId               # Change the Tenant that your key vault resides in
$vault.Properties.AccessPolicies = @()                                     # Access policies can be updated with real
                                                                           # applications/users/rights so that it does not need to be done after this whole activity. Here we are not setting 
                                                                           # any access policies. 
Set-AzResource -ResourceId $vaultResourceId -Properties $vault.Properties  # Modifies the key vault's properties.

Clear-AzContext                                                            #Clear the context from PowerShell
Connect-AzAccount                                                          #Log in again to confirm you have the correct tenant id



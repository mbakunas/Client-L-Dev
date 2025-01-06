# Path to the JSON file
$jsonFilePath = "Tgtsndbx_KeyVaults_updated.json"

# Import the JSON file
$keyVaultDetails = Get-Content -Path $jsonFilePath | ConvertFrom-Json

# Process the imported Key Vault details
foreach ($keyVault in $keyVaultDetails) {
    Write-Output "Key Vault Name: $($keyVault.name)"
    Write-Output "Resource Group: $($keyVault.resourceGroup)"
    Write-Output "Location: $($keyVault.location)"
    Write-Output "SKU: $($keyVault.properties.sku.name)"
    Write-Output "Access Policies:"

    foreach ($policy in $keyVault.properties.accessPolicies) {
        Write-Output "  Tenant ID: $($policy.tenantId)"
        Write-Output "  Object ID: $($policy.objectId)"
        Write-Output "  Permissions:"
        Write-Output "    Keys: $($policy.permissions.keys -join ', ')"
        Write-Output "    Secrets: $($policy.permissions.secrets -join ', ')"
        Write-Output "    Certificates: $($policy.permissions.certificates -join ', ')"
        Write-Output "    Storage: $($policy.permissions.storage -join ', ')"
    }
    Write-Output ""
}

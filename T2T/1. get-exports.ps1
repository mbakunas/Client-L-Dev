#Thi script will export the subscription inventory and role assignments to CSV files and then create a zip archive containing both files.

# Get current date for filenames
$date = Get-Date -Format "yyyyMMdd"

# Define output filenames with date
$inventoryFile = "./SubscriptionInventory_$date.csv"
$rolesFile = "./RoleAssignments_$date.csv"
$zipFile = "./AzureExport_$date.zip"

# Capture subscription inventory
Write-Output "Exporting subscription inventory..."
Get-AzResource | Export-Csv -Path $inventoryFile -NoTypeInformation

# Capture role assignments
Write-Output "Exporting role assignments..."
Get-AzRoleAssignment | Export-Csv -Path $rolesFile -NoTypeInformation

# Create a zip archive containing both files
Write-Output "Creating zip archive..."
Compress-Archive -Path $inventoryFile, $rolesFile -DestinationPath $zipFile -Force

Write-Output "Export completed. Download the file: $zipFile"
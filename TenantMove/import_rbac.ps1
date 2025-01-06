# Import the CSV file
$import = Import-Csv -Path "c:\temp\AJRD_RBAC_RoleAssignments.csv"


# Define the input and output file names
$inputfile = 'input.csv'
$outputfile = 'output.csv'

# Define the new field names
$fieldNames = @(
    'ID', 'Name', 'RoleDefinitionName', 'RoleDefinitionID', 
    'PrincipalID-New', 'PrincipalName', 'SPN', 
    'ResourceScopeName', 'ResourceType'
)

# Create a new array to hold the modified data
$newCsvData = @()

# Process each row in the input CSV
foreach ($row in $csvData) {
    $newRow = [PSCustomObject]@{
        ID                  = $row.ID
        Name                = $row.Name
        RoleDefinitionName  = $row.RoleDefinitionName
        RoleDefinitionID    = $row.RoleDefinitionID
        'PrincipalID-New'   = $row.'PrincipalID-New'  # Assuming this field exists in the input
        PrincipalName       = $row.PrincipalName
        SPN                 = $row.SPN
        ResourceScopeName   = $row.ResourceScopeName
        ResourceType        = $row.ResourceType
    }
    $newCsvData += $newRow
}

# Export the modified data to the new CSV file
$newCsvData | Export-Csv -Path $outputFile -NoTypeInformation

Write-Output "New CSV file '$outputFile' created successfully."
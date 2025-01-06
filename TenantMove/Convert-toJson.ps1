# Define the path to the Source input and output files
$inputFilePath = "C:\Users\kevin.a.schmidt\OneDrive - Avanade\Documents\Avanade\Projects\L3 Harris\Tenant Migration\AJRD\SRCSNDBX_role-assignments-2024-09-30.json"
$outputFilePath = "C:\Users\kevin.a.schmidt\OneDrive - Avanade\Documents\Avanade\Projects\L3 Harris\Tenant Migration\AJRD\SRCSNDBX_role-assignments-new.json"

# Read the content of the input file
$jsonContent = Get-Content -Path $inputFilePath -Raw

# Parse the JSON content
$parsedJson = $jsonContent | ConvertFrom-Json

# Convert the parsed JSON back to a properly formatted JSON string
$formattedJson = $parsedJson | ConvertTo-Json -Depth 100

# Write the formatted JSON to the output file
Set-Content -Path $outputFilePath -Value $formattedJson

Write-Output "JSON conversion completed. Check the output file at $outputFilePath"


# Define the path to the Target input and output files
$csvFilePath = "C:\Users\governor\tgtsndbx_Keyvaults.csv"
$jsonFilePath = "C:\Users\governor\new_import_keyvaults.json"

# Import the CSV file
$csvContent = Import-Csv -Path $csvFilePath

# Convert the CSV content to JSON
$jsonContent = $csvContent | ConvertTo-Json -Depth 100

# Write the JSON content to the output file
Set-Content -Path $jsonFilePath -Value $jsonContent

Write-Output "CSV to JSON conversion completed. Check the output file at $jsonFilePath"

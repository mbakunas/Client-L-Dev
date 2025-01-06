# Step 1: Import the CSV file
$csvData = Import-Csv -Path './new_TGTSNDBX_role-assignments-10072024.json'

# Step 2: Convert the CSV data to JSON
$jsonData = $csvData | ConvertTo-Json -Depth 10

# Step 3: Save the JSON data to a new file
Set-Content -Path $csvData -Value $jsonData

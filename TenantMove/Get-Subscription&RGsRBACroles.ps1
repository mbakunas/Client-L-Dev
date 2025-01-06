# Set the variables Login Variables
 #$tenant = "ae07d7b4-6085-45f8-a079-d1bfdcbf39cc" #Target Sandbox Tenant ID
 #$subscription = "9f1e9219-305f-4e5d-a752-84c1e239234a" #BergBest-OLD Subscription
 
 $name = "AJRD"
 $tenant = "e000d438-41ca-492b-bfe0-394c9b9dc25c" #AJRD Tenant ID
 $subscription = "8eb39352-c3a5-47f9-a677-42912c1b5ab1" #AJRD Subscription

 #$tenant ="ba488c5e-f105-4a2b-a8b1-b57b26a44117" #LHX Tenant ID


# Get RBAC Assignments for Subscription
$subscriptionAssignments = Get-AzRoleAssignment -Scope "/subscriptions/$subscription"

# Get RBAC Assignments for each Resource Group
$resourceGroups = Get-AzResourceGroup
$resourceGroupAssignments = @()
foreach ($rg in $resourceGroups) {
    $rgAssignments = Get-AzRoleAssignment -Scope $rg.ResourceId
    $resourceGroupAssignments += $rgAssignments
}

# Get Date
$date = get-date -Format "dd-MM-yyyy" 

# Output assignments to files
$folder = $name + "RBACRoleAssignment"
mkdir $folder
cd $folder
$subscriptionAssignments | Export-Csv -Path $name-SubscriptionRBACAssignments-$date.csv -NoTypeInformation
$resourceGroupAssignments | Export-Csv -Path $name-ResourceGroupRBACAssignments-$date.csv -NoTypeInformation

$subscriptionAssignments | ConvertTo-Json | Out-File -FilePath $name-SubscriptionRBACAssignments-$date.json
$resourceGroupAssignments | ConvertTo-Json | Out-File -FilePath $name-ResourceGroupRBACAssignments-$date.json

Write-Output "RBAC assignments have been captured and saved to CSV and JSON files."

# Compress files 
cd ..
$zipname = "RBACRoleAssignment-" + $date + ".zip"
zip -r  $zipname $folder
# Step 1: Define a hashtable with old custom and new custom Role Definition IDs
 $RoleDefId = @{
  #"old-roledef-id-#" = "new-roledef-id-#"
  "b5654a3d-2f39-497e-9899-b1d292abe5cf" = "47351ecf-2c44-4521-b0dc-12edb7544e2a" # Souce 2 target TenantId
}

# Step 2: Define a hashtable with old and new object IDs
$principalIdMapping = @{
  #"old-object-id-#" = "new-object-id-#"
     #  "b45d5d40-9c69-4da0-8786-db4ba56c2258" = "2c46bd66-1009-4c74-babe-9d2f1732415a"  #user@KRSConsult.onmicrosoft.com EXT
     #  "e095a800-b0c8-48fa-b180-f53f677c0226" = "b18460fb-33bd-48ad-9b50-d05b4e9f49d0"  #kevinrschmidt_live.com EXT
     #  "f8e94bf5-132c-44a7-90c2-89a430b12b3f" = "9a4a9b70-806b-4962-a05e-fa2f5d9dd2a6" #user@tgtsndbx.com
     #  "52401978-f3b8-4fba-bbc0-975b8fcee718" = "9a4a9b70-806b-4962-a05e-fa2f5d9dd2a6" #user@tgtsndbx.com
 #Target Demo Tenant
    # "b45d5d40-9c69-4da0-8786-db4ba56c2258" = "727cdeaa-2ed3-4c43-a43b-58c97f47ceff" #kevin.a.schmidt_avanade.com#EXT#@srcsndbx.onmicrosoft.co 2 Adele Vance
     "f8e94bf5-132c-44a7-90c2-89a430b12b3f" = "a543fad9-01bf-4bcb-9ec7-2690bf8a8988" #user@srcsndbx.com 2 Mod Admin
     "0a5928c5-50b7-4824-9f9c-9d32ebb63b81" = "4f51cd9b-edc3-4b63-ac12-f21eb0273d39" #AVD-VM-Access Group
     "78fd496e-7388-4144-9fc8-3d123caf497e" = "cb71364f-c942-4862-9b07-2e3537108fdd" #Test User2 2 Bianca Pisani
    
}

# Step 3: Read the JSON file into a PowerShell object
$jsonContent = Get-Content "C:\Users\governor\Downloads\Source_role-assignments-2024-10-07.json" -Raw | ConvertFrom-Json

# Step 4: Replace Role Definition IDs
$jsonContent | ForEach-Object {
    foreach ($def in $RoleDefId.def) {
        if ($_.RoleDefinitionId -eq $def) {
            $_.RoleDefinitionId = $RoleDefId[$def]
        }
    }
}

# Step 5: Replace object IDs
$jsonContent | ForEach-Object {
    foreach ($key in $principalIdMapping.Keys) {
        if ($_.ObjectId -eq $key) {
            $_.ObjectId = $principalIdMapping[$key]
        }
    }
    $_.PSObject.Properties.Remove("DisplayName")
    $_.PSObject.Properties.Remove("SignInName")
    $_.PSObject.Properties.Remove("RoleAssignmentDescription")
    $_.PSObject.Properties.Remove("ObjectType")
    $_.PSObject.Properties.Remove("ConditionVersion")
    $_.PSObject.Properties.Remove("Condition")
    
}

# Step 6: Convert the object back to a JSON string
$jsonString = $jsonContent | ConvertTo-Json -Depth 10

# Step 7: Save the updated JSON string to a new file
Set-Content -Path "C:\Users\governor\Downloads\new_TGTSNDBX_role-assignments-10072024.json" -Value $jsonString




#########
#import
$path = "./new_TGTSNDBX_role-assignments-10072024.json"
#az role assignment create --role-definition $path
$assignment = Get-Content -Path $path | ConvertFrom-Json

foreach ($role in $assignment) {
    if (![string]::IsNullorEmpty($role.ObjectId))
    { try {
        New-AzRoleAssignment -ObjectId $role.ObjectId -RoleDefinitionName $role.RoleDefinitionName -Scope $role.Scope
    } catch {
        Write-Host "Error with this Object Id: $($role.objectid)"
        Write-Host "Error detailed: $_"

    }
}



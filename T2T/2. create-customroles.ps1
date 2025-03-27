# This script can be used to create custom roles in Azure. The role details must be saved in a json file.
# Use the following format to save custom role details in a json file:
# {
#    "Name": "Custom Role 1",
#    "Id": null,
#    "IsCustom": true,
#    "Description": "Allows for read access to Azure storage and compute resources and access to support",
#    "Actions": [
#      "Microsoft.Compute/*/read",
#      "Microsoft.Storage/*/read",
#      "Microsoft.Support/*"
#    ],
#    "NotActions": [],
#    "AssignableScopes": [
#      "/subscriptions/00000000-0000-0000-0000-000000000000",
#      "/subscriptions/11111111-1111-1111-1111-111111111111"
#    ]
#  }

# Run the following command with the json file as input to create the custom role in Azure.

New-AzRoleDefinition -InputFile "C:\CustomRoles\customrole1.json"
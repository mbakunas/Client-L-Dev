# Azure Subscription Transfer T2T Automation

The purpose of this document and its corresponding files is to assist with activities pertaining to an Azure Subscription transfer from tenant to tenant. These documents can be followed alongside the Microsoft documentation provided at the following link:

[Transfer an Azure subscription to a different Microsoft Entra directory | Microsoft Learn](https://learn.microsoft.com/en-us/azure/role-based-access-control/transfer-subscription)

PowerShell scripts: The ps1 files contained in this folder can be edited for use and uploaded into the Azure Cloud Shell to be run in the portal, or they can be edited as needed to be run using different methods. It is important to remember to select the appropriate Tenant and Subscription prior to running each script to generate the intended output.

### 1. Get-exports.ps1

The [get-exports.ps1](./1.%20get-exports.ps1) file simply generates a basic inventory report and a capture of subscription role assignments into .csv files. The role assignments file can be utilized for recreating the role assignments once the subscription directory is changed.

### 2. Create-customroles.ps1

In the case that the subscription contains custom roles that need to be recreated after the subscription directory is changed, use the [create-customroles.ps1](./2.%20create-customroles.ps1) script. Custom roles need to first be exported using a script or via the Azure portal. Once details of the custom role are captured, format the information in a .json file according to the format shown in the [create-customroles.ps1](./2.%20create-customroles.ps1) script.

### 3. Map-roles.xlsx

The map-roles.xlsx excel file depicts the basic formatting that can be used to map users from the source tenant to the target tenant to assign the roles to the proper user, group, or service principal. Once these identities are mapped, the excel file can be used with the assign-roles.ps1 script to loop through and assign each role.

### 4. Assign-roles.ps1

Once identity mapping is completed using the map-roles.xlsx template or otherwise, the [assign-roles.ps1](./4.%20assign-roles.ps1) file can be updated with the proper role assignment details. This script can then be run to recreate role assignments in the subscription once the directory is changed

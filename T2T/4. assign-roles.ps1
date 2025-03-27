# This script can be used to assign roles to users, groups, and service principals in Azure using PowerShell.
# The script requires the Az module to be installed. You can install it using the following command: Install-Module -Name Az -AllowClobber -Scope CurrentUser
# The script takes an array of role assignments as input and assigns the specified roles to the specified users at the specified scope.

# Define role assignments as an array of hashtables: SignInName, RoleDefinitionName, Scope
$roleAssignments = @(
    @{ SignInName = 'SignIn Name or Object ID'; RoleDefinitionName = 'Role Title'; Scope = '/subscriptions/00000000-0000-0000-0000-000000000000' },
    @{ SignInName = 'SignIn Name or Object ID'; RoleDefinitionName = 'Role Title'; Scope = '/subscriptions/00000000-0000-0000-0000-000000000000' }
    # Add more entries as needed
)

# Loop through and assign each role
foreach ($assignment in $roleAssignments) {
    try {
        Write-Output "Assigning role '$($assignment.RoleDefinitionName)' to $($assignment.SignInName) at scope $($assignment.Scope)"
        New-AzRoleAssignment -SignInName $assignment.SignInName -RoleDefinitionName $assignment.RoleDefinitionName -Scope $assignment.Scope
    } catch {
        Write-Error "Failed to assign role to $($assignment.SignInName): $_"
    }
}

Write-Output "Role assignment process completed."

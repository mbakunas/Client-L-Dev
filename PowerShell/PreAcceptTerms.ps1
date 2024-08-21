# ensure the PowerShell execution policy is set to allow local scripts to run
#Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

$SubscriptionName = "Bakunas Sandbox 5"
$planPublisher    = "paloaltonetworks"
$planProduct      = "vmseries-flex"
$planName         = "byol"

 
Connect-AzAccount
Set-AzContext -Subscription $SubscriptionName
 
# accept purchase plan terms
Set-AzMarketplaceTerms -Publisher $planPublisher  -Product $planProduct -Name $planName -Accept

# verify that the terms have been accepted
Get-AzMarketplaceTerms -Publisher $planPublisher  -Product $planProduct -Name $planName
# Set the variables
 $resourceGroupName = "YourResourceGroupName"
 $galleryName = "YourGalleryName"
 $imageDefinitionName = "YourImageDefinitionName"
 $imageVersionName = "YourImageVersionName"
 $tenant = "3d8a699e-35ef-4e97-a1be-03ed86a389e7"
 $subscription = "8f617eb6-cc50-43c9-8764-7801f4ce9735"
 
<# Login to Azure
Connect-AzAccount -Tenant $tenant  -Subscription $subscription #-deviceauth 
#>

# Get the image version
$imageVersion = Get-AzGalleryImageVersion -ResourceGroupName $resourceGroupName -GalleryName $galleryName -GalleryImageDefinitionName $imageDefinitionName -Name $imageVersionName

# Get the disk size
$diskSize = $imageVersion.StorageProfile.OsDiskImage.SizeInGB

# Output the disk size
Write-Output "The disk size of the image is $diskSize GB"
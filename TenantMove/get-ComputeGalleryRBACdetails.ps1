﻿$allImageVersions = @()

foreach ($gallery in $computeGalleries) {
    $galleryName = $gallery.Name
    $resourceGroupName = $gallery.ResourceGroupName
    
# Get RBAC Assignments  
 $rbacAssignments = Get-AzRoleAssignment -Scope $gallery.Id
    $rbacAssignmentsString = ($rbacAssignments | ForEach-Object { "$($_.PrincipalName): $($_.RoleDefinitionName), $($_.DisplayName), $($_.SignInName)" }) -join "; "

# Get Sharing Profile (assuming it's part of the gallery properties)
    $isPublicCommunityGallery = $galleryDetails.Properties.SharingProfile.Permissions -contains "Community"
    $securityType = $galleryDetails.Properties.SecurityProfile.SecurityType
   
    $imageDefinitions = Get-AzGalleryImageDefinition -ResourceGroupName $resourceGroupName -GalleryName $galleryName

    foreach ($imageDefinition in $imageDefinitions) {
        $imageVersions = Get-AzGalleryImageVersion -ResourceGroupName $resourceGroupName -GalleryName $galleryName -GalleryImageDefinitionName $imageDefinition.Name

        foreach ($imageVersion in $imageVersions) {
  
# Convert Tags dictionary to string

# Get recommended CPU and memory
            $recommendedCpu = $imageVersion.Recommended.Cpu
            $recommendedMemory = $imageVersion.Recommended.Memory

# Get publishing metadata if it exists
 foreach ($imageVersion in $imageVersions) {
            $imageDetails = [PSCustomObject]@{
                GalleryName         = $galleryName
                ResourceGroupName   = $resourceGroupName
                ImageDefinitionName = $imageDefinition.Name
                ImageProvisioningState   = $imagedefinition.ProvisioningState
                HyperVGen =  $imageDefinition.HyperVGeneration
               OS_Type = $imageDefinition.OsType
               OS_State =  $imageDefinition.OSState
               OS_Id_Publisher =  $imageDefinition.Identifier.Publisher
               OS_Id_Offer =  $imageDefinition.Identifier.Offer
               OS_Id_Sku =  $imageDefinition.Identifier.Sku
                ImageVersionName    = $imageVersion.Name
                Location            = $imageVersion.Location
                PublishingProfile   = $publishingProfile
                 StorageProfile      = $imageVersion.StorageProfile
	     VM_ID =  $imageVersion.StorageProfile.Source.VirtualMachineId
	     OSDiskImage = $imageVersion.StorageProfile.OSDiskImage
	     OSDiskSize =  $imageVersion.StorageProfile.OSDiskImage.SizeinGB
	     OSDiskCaching = $imageVersion.StorageProfile.OSDiskImage.HostCaching
                Tags                = $tagsString
                SharingMethod       = $SharingMethod
               IsPublicCommunityGallery = $isPublicCommunityGallery
               SecurityType        = $securityType
               RecommendedCpu      = $recommendedCpu
              RBAC = $rbacAssignmentsString
            }
            $allImageVersions += $imageDetails
        }
    }
}

$allImageVersions | Export-Csv -Path "AJRD_ComputeGallery_RBAC_versions_sharingdetails.csv" -NoTypeInformation
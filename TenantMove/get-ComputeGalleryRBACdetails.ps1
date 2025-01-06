$allImageVersions = @()

foreach ($gallery in $computeGalleries) {
    $galleryName = $gallery.Name
    $resourceGroupName = $gallery.ResourceGroupName
    
# Get RBAC Assignments  
 $rbacAssignments = Get-AzRoleAssignment -Scope $gallery.Id
    $rbacAssignmentsString = ($rbacAssignments | ForEach-Object { "$($_.PrincipalName): $($_.RoleDefinitionName), $($_.DisplayName), $($_.SignInName)" }) -join "; "

# Get Sharing Profile (assuming it's part of the gallery properties)    $galleryDetails = Get-AzResource -ResourceId $gallery.Id    $sharingMethod = $galleryDetails.Properties.SharingProfile.SharingMethod
    $isPublicCommunityGallery = $galleryDetails.Properties.SharingProfile.Permissions -contains "Community"
    $securityType = $galleryDetails.Properties.SecurityProfile.SecurityType
   
    $imageDefinitions = Get-AzGalleryImageDefinition -ResourceGroupName $resourceGroupName -GalleryName $galleryName

    foreach ($imageDefinition in $imageDefinitions) {
        $imageVersions = Get-AzGalleryImageVersion -ResourceGroupName $resourceGroupName -GalleryName $galleryName -GalleryImageDefinitionName $imageDefinition.Name

        foreach ($imageVersion in $imageVersions) {
  
# Convert Tags dictionary to string            $tagsString = ($imageVersion.Tags.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join "; "

# Get recommended CPU and memory
            $recommendedCpu = $imageVersion.Recommended.Cpu
            $recommendedMemory = $imageVersion.Recommended.Memory

# Get publishing metadata if it exists            $publishingProfile = $imageVersion.PublishingProfile            $publishingProfileTargetRegion = ($publishingProfile.TargetRegions | ForEach-Object { $_.Name }) -join "; "            $publishingDate = $publishingProfile.PublishedDate            $publishingStorageAcctType = $publishingProfile.StorageAccountType            $publishingMetadata = if ($publishingProfile.Metadata) {                ($publishingProfile.Metadata.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join "; "            } else {                ""            }           
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
                PublishingProfile   = $publishingProfile                PublishingProfileTargetRegion = $publishingProfileTargetRegion                PublishingDate      = $publishingDate                PublishingStorageAcctType = $publishingStorageAcctType                PublishingMetadata  = $publishingMetadata
                 StorageProfile      = $imageVersion.StorageProfile
	     VM_ID =  $imageVersion.StorageProfile.Source.VirtualMachineId
	     OSDiskImage = $imageVersion.StorageProfile.OSDiskImage
	     OSDiskSize =  $imageVersion.StorageProfile.OSDiskImage.SizeinGB
	     OSDiskCaching = $imageVersion.StorageProfile.OSDiskImage.HostCaching
                Tags                = $tagsString
                SharingMethod       = $SharingMethod
               IsPublicCommunityGallery = $isPublicCommunityGallery
               SecurityType        = $securityType
               RecommendedCpu      = $recommendedCpu              RecommendedMemory   = $recommendedMemory
              RBAC = $rbacAssignmentsString
            }
            $allImageVersions += $imageDetails
        }
    }
}

$allImageVersions | Export-Csv -Path "AJRD_ComputeGallery_RBAC_versions_sharingdetails.csv" -NoTypeInformation

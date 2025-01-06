# Login to Azure
#Connect-AzAccount

# Set variables
$resourceGroups = @("AR-VA-SHARED_IMAGE_LIB-RG", "AR-AZ-SERVER_IMAGES-RG", "AR-VA-WVD-IT-RG", "AR-VA-WVD-RG", "AR-AZ-WVD-RG")
$outputDirectory = "$HOME/galleryimages"

# Ensure the output directory exists
if (-Not (Test-Path -Path $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory

}

#Loop thru each gallery to collect details
foreach ($resourceGroupName in $resourceGroups) {
    # Get all galleries in the resource group
    $galleries = Get-AzGallery -ResourceGroupName $resourceGroupName

    foreach ($gallery in $galleries) {
        $galleryName = $gallery.Name
        $galleryOutputDirectory = Join-Path -Path $outputDirectory -ChildPath "$resourceGroupName\$galleryName"

        # Ensure the gallery output directory exists
        if (-Not (Test-Path -Path $galleryOutputDirectory)) {
            New-Item -ItemType Directory -Path $galleryOutputDirectory
        }

        # Get all image definitions in the gallery
        $imageDefinitions = Get-AzGalleryImageDefinition -ResourceGroupName $resourceGroupName -GalleryName $galleryName

        foreach ($imageDefinition in $imageDefinitions) {
            $imageDefinitionName = $imageDefinition.Name
            $outputFilePath = Join-Path -Path $galleryOutputDirectory -ChildPath "$imageDefinitionName.json"

            # Create a custom object with the required details
            $imageDetails = [PSCustomObject]@{
                Name  = $imageDefinition.Name
                ResourceGroup = $imageDefinition.ResourceGroupName
                OsType = $imageDefinition.OsType
                OsState = $imageDefinition.osstate
                HyperVGen = $imageDefinition.HyperVGeneration
                Publisher = $imageDefinition.Identifier.Publisher 
                Offer = $imageDefinition.Identifier.Offer
                Sku   = $imageDefinition.Identifier.Sku
                vCPU_min = $imageDefinition.Recommended.VCPUs.Min
                vCPU_max = $imageDefinition.Recommended.VCPUs.Max
                vRAM_min = $imageDefinition.Recommended.Memory.Min
                vRAM_max = $imageDefinition.Recommended.Memory.Max
                ID = $imageDefinition.Id
                Type = $imageDefinition.Type
                Location = $imageDefinition.location
                Tags = $imageDefinition.Tags
                SecType = $imageDefinition.Features[0].Name
                SecValue = $imageDefinition.Features[0].Value
                AccNet = $imageDefinition.Features[1].Name
                AccNetValue = $imageDefinition.Features[1].Value
                Architecture = $imageDefinition.Architecture              

            }

            # Export the image definition details to a JSON file
            $imageDetails | ConvertTo-Json | Out-File -FilePath $outputFilePath
        }
    }
}

Write-Output "Image definition details exported to $outputDirectory"
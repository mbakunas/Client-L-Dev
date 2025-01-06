<#

.SYNOPSIS
Exports an Image Version from an Azure Compute Gallery.
.DESCRIPTION
Exports a VHD of a Managed Disk created from an Image Version in an Azure Compute Gallery.  The VHD is saved to the Downloads folder in the user's profile that is running the script.
.PARAMETER ComputeGalleryName
The name of the Azure Compute Gallery.
.PARAMETER ComputeGalleryResourceGroupName
The name of the Resource Group that contains the Azure Compute Gallery.
.PARAMETER ImageDefinitionName
The name of the Image Definition in the Azure Compute Gallery.
.PARAMETER ImageVersionName
The name of the Image Version in the Azure Compute Gallery.

This example creates a Managed Disk from an Image Version in an Azure Compute Gallery. Downloads the VHD of the Managed Disk to the user's Downloads folder and validates the auto-generated MD5 hash.  
Once the download completes, the Managed Disk is deleted. 
.EXAMPLE
.\Export-AzureComputeGalleryImage.ps1 `
    -ComputeGalleryName <Compute-Gallery-Name> `
    -ComputeGalleryResourceGroupName <Resource-Group-Name> `
    -ImageDefinitionName <Image-Definition-Name> `
    -ImageVersionName <Image-Version-Name>

 $tenant = "3d8a699e-35ef-4e97-a1be-03ed86a389e7"
 $subscription = "8f617eb6-cc50-43c9-8764-7801f4ce9735"
 $rgname = "KS-Temp-rg"
 $galname = "ks_gallery_image"
 $vmname = "ks-w2019-image-specialized"
 $UNC = "z:"
##
Connect-AzAccount -Tenant $tenant  -Subscription $subscription -deviceauth 
##
.\Export-AzureComputeGalleryImage.ps1 `
    -ComputeGalleryName $galname `
    -ComputeGalleryResourceGroupName $rgname `
    -ImageDefinitionName $vmname `
    -ImageVersionName '1.0.0' `
    -Sastoken $sasToken
#>


[Cmdletbinding()]
param(

    [parameter(Mandatory)]
    [string]$ComputeGalleryName,

    [parameter(Mandatory)]
    [string]$ComputeGalleryResourceGroupName,

    [parameter(Mandatory)]
    [string]$ImageDefinitionName,

    [parameter(Mandatory)]
    [string]$ImageVersionName
)

$ErrorActionPreference = 'Stop'

$DiskPrefix = "disk-$($ImageDefinitionName)-"
$Location = (Get-AzResourceGroup -Name $ComputeGalleryResourceGroupName).Location

# Gets the Image Version ID
$ImageVersion = Get-AzGalleryImageVersion `
    -GalleryImageDefinitionName $ImageDefinitionName `
    -GalleryName $ComputeGalleryName `
    -ResourceGroupName $ComputeGalleryResourceGroupName `
    -Name $ImageVersionName

# Gets the OS Type
$OsType = (Get-AzGalleryImageDefinition `
    -GalleryImageDefinitionName $ImageDefinitionName `
    -GalleryName $ComputeGalleryName `
    -ResourceGroupName $ComputeGalleryResourceGroupName).OsType

$ImageDisksCount = $ImageVersion.StorageProfile.OsDiskImage.Count + $ImageVersion.StorageProfile.DataDiskImages.Count
for($i = 0; $i -lt $ImageDisksCount; $i++)
{    
    $GalleryImageReference = if($i -eq 0)
    {
        @{Id = $ImageVersion.Id}
    }
    else{
        @{Id = $ImageVersion.Id; Lun = $($i - 1)}
    }

    # Creates a Disk Configuration for a Managed Disk using the Image Version in the Compute Gallery
    $DiskConfig = New-AzDiskConfig `
        -Location $Location `
        -CreateOption FromImage `
        -GalleryImageReference $GalleryImageReference `
        -OsType $OsType

    # Creates a Managed Disk using the Image Version in the Compute Gallery
    $Disk = New-AzDisk `
        -Disk $DiskConfig `
        -ResourceGroupName $ComputeGalleryResourceGroupName `
        -DiskName ($DiskPrefix + $i.ToString())

    # Creates a URI with a SAS Token to download the VHD of the Managed Disk
    $DiskAccess = Grant-AzDiskAccess `
        -ResourceGroupName $Disk.ResourceGroupName `
        -DiskName $Disk.Name `
        -Access 'Read' `
        -DurationInSecond 14400

    # Create a storage context using the SAS token
    #$context = New-AzStorageContext -StorageAccountName $storagename -SasToken $sasToken

    # Downloads the VHD using 10 concurrent network calls and validates the MD5 hash
    Get-AzStorageBlobContent `
        -AbsoluteUri $DiskAccess.AccessSAS `
        -Destination "$($UNC)\backup Downloads\$($Disk.Name).vhd"
        -context $context

    # Revokes the SAS Token to download the VHD
    Revoke-AzDiskAccess `
        -ResourceGroupName $Disk.ResourceGroupName `
        -DiskName $Disk.Name

    # Deletes the Managed Disk
    Remove-AzDisk `
        -ResourceGroupName $Disk.ResourceGroupName `
        -DiskName $Disk.Name `
        -Force
}
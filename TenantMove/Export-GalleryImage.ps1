<#
.EXAMPLE
.\Export-AzureComputeGalleryImageVersion.ps1 `
    -ComputeGalleryName 'cg_shared_d_va' `
    -ComputeGalleryResourceGroupName 'rg-images-d-va' `
    -ImageDefinitionName 'WindowsServer2019Datacenter' `
    -ImageVersionName '1.0.0'

This example creates a Managed Disk from an Image Version in an Azure Compute Gallery. 
Downloads the VHD of the Managed Disk to the user's Downloads folder and validates the auto-generated MD5 hash.  Once the download completes, the Managed Disk is deleted. 
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

$DiskPrefix = "disk-$($ImageDefinitionName)-$($ImageVersionName)-"
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

    # Downloads the VHD using 10 concurrent network calls and validates the MD5 hash
    Get-AzStorageBlobContent `
        -AbsoluteUri $DiskAccess.AccessSAS `
        -Destination "$($HOME)\Downloads\$($Disk.Name).vhd"

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
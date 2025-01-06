<#
.SYNOPSIS
Imports an Image Version to an Azure Compute Gallery.

.DESCRIPTION
Imports a downloaded VHD as a Managed Disk and is validated using an MD5 hash that is auto-generated.  If the specified Compute Gallery and Image Definition do not exist, it creates those resources.  Next, the Managed Disk is imported as an Image Version.  Once the import completes, the Managed Disk is deleted.
.PARAMETER ComputeGalleryName
The name for the Azure Compute Gallery.  It will be created if it does not exist.
.PARAMETER ComputeGalleryResourceGroupName
The name for the Resource Group that contains the Azure Compute Gallery.
.PARAMETER ImageDefinitionAcceleratedNetworking
The accelerated networking feature for the Image Definition.
.PARAMETER ImageDefinitionHibernation
The hibernation feature for the Image Definition
.PARAMETER ImageDefinitionHyperVGeneration
The Hyper-V Generation for the Image Definition.
.PARAMETER ImageDefinitionName
The name for the Image Definition in the Azure Compute Gallery.  It will be created if it does not exist.
.PARAMETER ImageDefinitionOffer
The image offer for the Image Defintion.
.PARAMETER ImageDefinitionOsType
The operating system type for the Image Definition.
.PARAMETER ImageDefinitionPublisher
The publisher for the Image Defintion.
.PARAMETER ImageDefinitionSecurityType
The security type for the Image Definition.
.PARAMETER ImageDefinitionSku
The SKU for the Image Defintion.
.PARAMETER ImageDefinitionState
The state for the Image Defintion.
.PARAMETER ImageVersionName
The name for the Image Version.

##
#Variables
 $tenant = "3d8a699e-35ef-4e97-a1be-03ed86a389e7"
 $subscription = "8f617eb6-cc50-43c9-8764-7801f4ce9735"
 $feature = ""
 $rgname = "KS-Temp-rg"
 $galname = "ks_gallery_restored_images"
 $defname = "ks-w2019-image-specialized"
 $HyperVGeneration = "V2"
 $vername = "0.0.1" 
 $defoffer = "KS_W2019"
 $defpublish = "KS_MSFT"
 $defostype = "Windows"
 $defosstate = "Specialized"
 $defsku = "KS_Datacenter"
 $UNC = "z:"
##
Connect-AzAccount -Tenant $tenant  -Subscription $subscription -deviceauth
##

This example imports the VHD as a Managed Disk, creates a new Image Defintion, and imports the Managed Disk as a new Image Version into the new Image Defintion.
.EXAMPLE

 .\Import-AzureComputeGalleryImage.ps1 `
    -ComputeGalleryResourceGroupName $rgname `
    -ComputeGalleryName $galname `
    -ImageDefinitionAcceleratedNetworking 'False' `
    -ImageDefinitionHibernation 'False' `
    -ImageDefinitionHyperVGeneration $HyperVGeneration `
    -ImageDefinitionName $defname `
    -ImageDefinitionOffer $defoffer `
    -ImageDefinitionOsType $defostype `
    -ImageDefinitionPublisher $defpublish `
    -ImageDefinitionSecurityType 'Standard' `
    -ImageDefinitionSku $defsku `
    -ImageDefinitionState $defosstate `
    -ImageVersionName $vername


This example imports the VHD as a Managed Disk and imports the Managed Disk as a new Image Version into an existing Image Defintion.
.EXAMPLE
.\Import-AzureComputeGalleryImage.ps1 `
    -ComputeGalleryName $galname `
    -ComputeGalleryResourceGroupName $rgname `
    -ImageDefinitionName 'WindowsServer2019Datacenter' `
    -ImageVersionName '1.0.0'
#>
[Cmdletbinding()]

param(
    [parameter(Mandatory)]
    [string]$ComputeGalleryName,

    [parameter(Mandatory)]
    [string]$ComputeGalleryResourceGroupName,

    [parameter(Mandatory=$false)]
    [ValidateSet('True','False')]
    [string]$ImageDefinitionAcceleratedNetworking = 'False',

    [parameter(Mandatory=$false)]
    [ValidateSet('True','False')]
    [string]$ImageDefinitionHibernation = 'False',

    [parameter(Mandatory=$false)]
    [ValidateSet('V1','V2')]
    [string]$ImageDefinitionHyperVGeneration = 'V2',

    [parameter(Mandatory)]
    [string]$ImageDefinitionName,

    [parameter(Mandatory=$false)]
    [string]$ImageDefinitionOffer,

    [parameter(Mandatory=$false)]
    [ValidateSet('Windows','Linux')]
    [string]$ImageDefinitionOsType = 'Windows',
     
    [parameter(Mandatory=$false)]
    [string]$ImageDefinitionPublisher,

    [parameter(Mandatory=$false)]
    [ValidateSet('ConfidentialVM','ConfidentialVMSupported','Standard','TrustedLaunch')]
    [string]$ImageDefinitionSecurityType = 'Standard',

    [parameter(Mandatory=$false)]
    [string]$ImageDefinitionSku,

    [parameter(Mandatory=$false)]
    [ValidateSet('generalized','specialized')]
    [string]$ImageDefinitionState,

    [parameter(Mandatory)]
    [string]$ImageVersionName
)

$ErrorActionPreference = 'Stop'

$DiskPrefix = "disk-$($ImageDefinitionName)-$($ImageVersionName)"
$Location = (Get-AzResourceGroup -Name $ComputeGalleryResourceGroupName).Location

# Checks if the Compute Gallery exists
$Gallery = Get-AzGallery `
    -ResourceGroupName $ComputeGalleryResourceGroupName `
    -Name $ComputeGalleryName `
    -ErrorAction 'SilentlyContinue'

# If the Compute Gallery doesn't exist, create it
if(!$Gallery)
{ 
    $Gallery = New-AzGallery `
        -ResourceGroupName $ComputeGalleryResourceGroupName `
        -Name $ComputeGalleryName `
        -Location $Location
}

# Checks if the Image Definition exists
$ImageDefinition = Get-AzGalleryImageDefinition `
        -ResourceGroupName $ComputeGalleryResourceGroupName `
        -GalleryName $ComputeGalleryName `
        #-HyperVGeneration $ImageDefinitionHyperVGeneration `
        #-OsType $defostype ` 
        #-Location $Location `
        #-Name $ImageDefinitionName `
        #-Offer $defoffer `
        #-OsState $defosstate `
        #-Publisher $defpublish `
        #-Sku $defsku `
        #-ErrorAction 'SilentlyContinue'

# If the Image Definition doesn't exist, create it
if(!$ImageDefinition)
{
    $IsHibernateSupported = @{Name = 'IsHibernateSupported'; Value = $ImageDefinitionHibernation}
    $IsAcceleratedNetworkSupported = @{Name = 'IsAcceleratedNetworkSupported'; Value = $ImageDefinitionAcceleratedNetworking}
    $SecurityType = @{Name = 'SecurityType'; Value = $ImageDefinitionSecurityType}
    $Features = @($IsHibernateSupported, $IsAcceleratedNetworkSupported, $SecurityType)

    $ImageDefinition = New-AzGalleryImageDefinition `
        -GalleryName $galname `
        -ResourceGroupName $rgname `
        -HyperVGeneration $HyperVGeneration `
        -OsType $defostype `
        -Location $Location `
        -Name $defname `
        -Offer $defoffer `
        -OsState $defosstate `
        -Publisher $defpublish `
        -Sku $defsku
        #-Feature $Features `
}

# Get the downloaded disks / VHDs from the Downloads folder
$Vhds = Get-ChildItem -Path "$($UNC)\backup Downloads\disk-$($ImageDefinitionName)-*.vhd"

# Throw an error if the disks are not found
if($Vhds.Count -eq 0)
{
    Write-Host -Message "Disks were not found. Be sure to use the same Image Definition Name used in the export script." -ForegroundColor Red
    throw
}

$UNCPath = Join-Path -Path $UNC -ChildPath "backup Downloads\$($Vhds.Name)"

$DataDiskImage = @()
for($i = 0; $i -lt $Vhds.Count; $i++)
{
    # Uploads the VHD from the filesystem to Azure as a Managed Disk
    Add-AzVhd `
        -LocalFilePath $UNCPath `
        -ResourceGroupName $ComputeGalleryResourceGroupName `
        -Location $Location `
        -DiskName ($DiskPrefix + $i.ToString()) `
        -NumberOfUploaderThreads 32
        #-DiskImageDefinitionOsType $defostype `

    # Gets the information for the Managed Disk
    $Disk = Get-AzDisk `
        -ResourceGroupName $ComputeGalleryResourceGroupName `
        -DiskName ($DiskPrefix + $i.ToString())

    if($i -eq 0)
    {
        # Defines the Source object used to create the OS disk for the Image Version
        $OsDiskImage = @{Source = @{Id = $Disk.Id}}
    }
    else 
    {
        # Defines the Source object used to create a data disk for the Image Version
        $DataDisk = @{Source = @{Id = $Disk.Id}; Lun = ($i - 1)}
        $DataDiskImage += $DataDisk
    }
}

# Create a new Image Version using the Managed Disk(s)
if($Vhds.Count -eq 1)
{
    New-AzGalleryImageVersion `
        -GalleryImageDefinitionName $ImageDefinitionName `
        -GalleryImageVersionName $ImageVersionName `
        -GalleryName $ComputeGalleryName `
        -ResourceGroupName $ComputeGalleryResourceGroupName `
        -Location $Location `
        -OSDiskImage $OsDiskImage
}
else
{
    New-AzGalleryImageVersion `
        -GalleryImageDefinitionName $ImageDefinitionName `
        -GalleryImageVersionName $ImageVersionName `
        -GalleryName $ComputeGalleryName `
        -ResourceGroupName $ComputeGalleryResourceGroupName `
        -Location $Location `
        -OSDiskImage $OsDiskImage `
        -DataDiskImage $DataDiskImage
}

# Deletes the Managed Disk(s)
for($i = 0; $i -lt $Vhds.Count; $i++)
{
    Remove-AzDisk `
        -ResourceGroupName $ComputeGalleryResourceGroupName `
        -DiskName ($DiskPrefix + $i.ToString()) `
        -Force
}
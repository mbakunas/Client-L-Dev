/*

  Bootstrap.bicep
  This Bicep file deploys a resource group and storage account for use as a Terraform remote state.

*/

targetScope = 'subscription'

param resourceGroupName string
param storageAccountName string
param location string = deployment().location
param tags object = {}
param skuName string = 'Standard_GRS'
param kind string = 'StorageV2'
param accessTier string = 'Hot'
param containerName string = 'tfstate'

var enableBlobVersioning = true // Enable blob versioning to enable revision to previous states

// create the resource group

resource rg 'Microsoft.Resources/resourceGroups@2025-03-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}


// deploy the storage account
module storage 'Modules/storageAccount.bicep' = {
  name: 'storageDeployment'
  scope: rg
  params: {
    storageAccountName: storageAccountName
    location: location
    tags: tags
    skuName: skuName
    kind: kind
    accessTier: accessTier
    isVersioningEnabled: enableBlobVersioning
    containerName: containerName
  }
}

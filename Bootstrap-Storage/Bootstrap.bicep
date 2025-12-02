/*

  Bootstrap.bicep
  This Bicep file deploys a storage account for use as a Terraform remote state.

*/

targetScope = 'managementGroup'

param subscriptionId string
param resourceGroupName string
param storageAccountName string
param location string = deployment().location
param tags object = {}
param skuName string = 'Standard_GRS'
param kind string = 'StorageV2'
param accessTier string = 'Hot'

var enableBlobVersioning = true // Enable blob versioning to enable revision to previous states

module storage 'Modules/Storage.bicep' = {
  name: 'storageDeployment'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    storageAccountName: storageAccountName
    location: location
    tags: tags
    skuName: skuName
    kind: kind
    accessTier: accessTier
    isVersioningEnabled: enableBlobVersioning
  }
}

targetScope = 'resourceGroup'

param storageAccountName string
param location string = resourceGroup().location
param tags object = {}
param skuName string = 'Standard_LRS'
param kind string = 'StorageV2'
param accessTier string = 'Hot'
param isVersioningEnabled bool

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-06-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  kind: kind
  properties: {
    accessTier: accessTier
    supportsHttpsTrafficOnly: true
    isHnsEnabled: false
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'

  }
}

resource storageAccountBlobServices 'Microsoft.Storage/storageAccounts/blobServices@2025-06-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    isVersioningEnabled: isVersioningEnabled
  }
}

using './Bootstrap.bicep'

param subscriptionId = ''
param resourceGroupName = ''
param storageAccountName = ''
param location = ''
param tags = {}
param skuName = 'Standard_GRS'
param kind = 'StorageV2'
param accessTier = 'Hot'


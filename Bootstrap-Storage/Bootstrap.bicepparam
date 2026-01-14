using './Bootstrap.bicep'

param resourceGroupName = 'TerraformState'
param storageAccountName = 'coreinfratfstate03'
param location = 'East US'
param tags = {}
param skuName = 'Standard_GRS'
param kind = 'StorageV2'
param accessTier = 'Hot'
param containerName = 'tfstate'


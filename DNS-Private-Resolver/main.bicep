targetScope = 'subscription'
param vnets array = []

//get the unique list of RG names
var rgNames = [for vnet in vnets:{
  name: vnet.resourceGroupName
  location: vnet.resourceGroupLocation
}]
var uniqueRgNames = union(rgNames, rgNames)


// create the resource group(s)
resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = [for rg in uniqueRgNames: {
  name: rg.name
  location: rg.location
}]


// hub vnet
module vnet 'Modules/vnet.bicep' = [for (vnet, i) in vnets: {
  name: 'vnet${i}'
  scope: resourceGroup((vnet.resourceGroupName))
  params: {
    vnetName: vnet.name
    vnetLocation: vnet.location
    vnetAddressPrefix: vnet.addressPrefix
    vnetSubnets: vnet.subnets
  }
}]




// Azure bastion




// dns private resolver




// spoke vm




// on-prem vm

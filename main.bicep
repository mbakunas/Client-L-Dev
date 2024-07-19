targetScope = 'subscription'

param vnets array = [
  {
    name: 'vnet1'
    resourceGroupName: 'VNetRG1'
    resourceGroupLocation: 'eastus2'
    location: 'eastus2' // we need a separate vnet location since we can have resources from any region in a single resource group
    addressPrefix: ''
    subnets: [
      {
        name: 'subnet1'
        addressPrefix: '10.0.1.0/24'
      }
      {
        name: 'subnet2'
        addressPrefix: '10.0.2.0/24'
      }
    ]
  }
  {
    name: 'vnet2'
    resourceGroupName: 'VNetRG1'
    resourceGroupLocation: 'eastus2'
    location: 'eastus2'
    addressPrefix: ''
    subnets: []
  }
]





// create the resource group(s)
resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = [for i in vnets: {
  name: vnets[i].resourceGroupName
  location: vnets[i].resourceGroupLocation
}]

/*
// deploy vnet(s)
module vnet 'Modules/vnet.bicep' = [for i in vnets: {
  name: 'vnet${i}'
  scope: rg[i]
  params: {
    vnetName: vnets[i].name
    vnetLocation: vnets[i].location
    vnetAddressPrefix: vnets[i].addressPrefix
    vnetSubnets: vnets[i].subnets
  }
}]*/






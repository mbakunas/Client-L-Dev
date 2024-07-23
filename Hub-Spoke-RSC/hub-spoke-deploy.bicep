targetScope = 'subscription'

/*
TODO:
- add tags
- move to management group scope
- add user defined routes
- add dns private resolver
*/

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


// deploy vnet(s)
module vnet 'Modules/vnet.bicep' = [for (vnet, i) in vnets: {
  name: 'vnet${i}'
  scope: resourceGroup(vnet.resourceGroupName)
  params: {
    vnetName: vnet.name
    vnetLocation: vnet.location
    vnetAddressPrefix: vnet.addressPrefix
    vnetSubnets: vnet.subnets
  }
  dependsOn: [rg]
}]


// gateway
module vnetGW 'Modules/vnetGateway.bicep'= {
  name: 'vnetGW'
  scope: resourceGroup(vnets[0].resourceGroupName)
  params: {
    gwName: vnets[0].gateway.name
    gwLocation: vnets[0].location
    gwType: vnets[0].gateway.type
    gwVnetName: vnets[0].name
    gwSKU: vnets[0].gateway.sku
  }
  dependsOn: [vnet]

}

// vnet peerings
// create hub/spoke, assume first vnet is the hub
module hubOutboundPeerings 'Modules/peering.bicep' = [for i in range(1, length(vnets)-1): {
  name: 'hubOutboundPeerings${i-1}'
  scope: resourceGroup(vnets[0].resourceGroupName)
  params: {
    vnet1Name: vnets[0].name
    vnet2Name: vnets[i].name
    vnet1isHub: true
    vnet2isHub: false
  }
  dependsOn: [vnet]
}]



module hubInboundPeerings 'Modules/peering.bicep' = [for i in range(1, length(vnets)-1): {
  name: 'hubInboundPeerings${i-1}'
  scope: resourceGroup(vnets[i].resourceGroupName)
  params: {
    vnet1Name: vnets[i].name
    vnet2Name: vnets[0].name
    vnet1isHub: false
    vnet2isHub: true
  }
  dependsOn: [
    vnet
    vnetGW
  ]
}]



// user defined routes


// dns private resolver






targetScope = 'managementGroup'

/*
TODO:
- add user defined routes
*/

param vnets array
param tags object = {}

//get the unique list of RG names
var rgNames = [for vnet in vnets:{
  name: vnet.resourceGroupName
  location: vnet.resourceGroupLocation
  subscriptionId: vnet.resourceGroupSubscriptionID
}]
var uniqueRgNames = union(rgNames, rgNames)


// create the resource group(s)
module rg 'Modules/resourceGroup.bicep' = [for (rg, i) in uniqueRgNames: {
  name: 'rg${i}'
  scope: subscription(rg.subscriptionId)
  params: {
    rgName: rg.name
    rgLocation: rg.location
    rgTags: tags
  }
}]


// deploy vnet(s)
module vnet 'Modules/vnet.bicep' = [for (vnet, i) in vnets: {
  name: 'vnet${i}'
  scope: resourceGroup(vnet.resourceGroupSubscriptionID, vnet.resourceGroupName)
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
  scope: resourceGroup(vnets[0].resourceGroupSubscriptionID, vnets[0].resourceGroupName)
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
  scope: resourceGroup(vnets[0].resourceGroupSubscriptionID, vnets[0].resourceGroupName)
  params: {
    vnet1Name: vnets[0].name
    vnet2Name: vnets[i].name
    vnet2ID: resourceId(vnets[i].resourceGroupSubscriptionID, vnets[i].resourceGroupName, 'Microsoft.Network/virtualNetworks', vnets[i].name)
    vnet1isHub: true
    vnet2isHub: false
  }
  dependsOn: [
    vnet
    vnetGW
  ]
}]



module hubInboundPeerings 'Modules/peering.bicep' = [for i in range(1, length(vnets)-1): {
  name: 'hubInboundPeerings${i-1}'
  scope: resourceGroup(vnets[i].resourceGroupSubscriptionID, vnets[i].resourceGroupName)
  params: {
    vnet1Name: vnets[i].name
    vnet2ID: resourceId(vnets[0].resourceGroupSubscriptionID, vnets[0].resourceGroupName, 'Microsoft.Network/virtualNetworks', vnets[0].name)
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

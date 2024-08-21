targetScope = 'managementGroup'

param vnets array
param hubVnetSubscriptionId string
param hubVnetResourceGroupName string
param hubVnetName string
param tags object = {}


// deploy vnet(s)
module vnet '../Modules/vnet.bicep' = [for (vnet, i) in vnets: {
  name: 'vnet${i}'
  scope: resourceGroup(vnet.resourceGroupSubscriptionID, vnet.resourceGroupName)
  params: {
    vnetName: vnet.name
    vnetLocation: vnet.location
    vnetAddressPrefix: vnet.addressPrefix
    vnetEncryption: false
    vnetSubnets: vnet.subnets
    vnetDnsServers: vnet.?dnsServers ?? []
    vnetTags: tags
  }
  dependsOn: [
    routeTables
  ]
}]

// vnet peerings
// create hub/spoke
module hubOutboundPeerings '../Modules/peering.bicep' = [for i in range(0, length(vnets)): {
  name: 'hubOutboundPeerings${i}'
  scope: resourceGroup(hubVnetSubscriptionId, hubVnetResourceGroupName)
  params: {
    vnet1Name: hubVnetName
    vnet2Name: vnets[i].name
    vnet2ID: resourceId(vnets[i].resourceGroupSubscriptionID, vnets[i].resourceGroupName, 'Microsoft.Network/virtualNetworks', vnets[i].name)
    vnet1isHub: true
    vnet2isHub: false
  }
  dependsOn: [
    vnet
  ]
}]



module hubInboundPeerings '../Modules/peering.bicep' = [for i in range(0, length(vnets)): {
  name: 'hubInboundPeerings${i}'
  scope: resourceGroup(vnets[i].resourceGroupSubscriptionID, vnets[i].resourceGroupName)
  params: {
    vnet1Name: vnets[i].name
    vnet2ID: resourceId(hubVnetSubscriptionId, hubVnetResourceGroupName, 'Microsoft.Network/virtualNetworks', hubVnetName)
    vnet2Name: hubVnetName
    vnet1isHub: false
    vnet2isHub: true
  }
  dependsOn: [
    vnet
  ]
}]



// user defined routes

module routeTables '../Modules/routeTable.bicep' = [for (vnet, i) in vnets: {
  name: 'routeTables${i}'
  scope: resourceGroup(vnet.resourceGroupSubscriptionID, vnet.resourceGroupName)
  params: {
    routeTableName: vnet.routeTable.name
    routes: vnet.routeTable.routes
    routeTableTags: tags
    routeTableLocation: vnet.location
    routeTableDisableBgpRoutePropagation: vnet.routeTable.disableBgpRoutePropagation
  }
}]

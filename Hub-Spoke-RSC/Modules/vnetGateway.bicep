targetScope = 'resourceGroup'

param gwName string = '${gwVnetName}-GW'
param gwLocation string

@allowed([
  'VPN'
  'ExpressRoute'
])
param gwType string
param gwVnetName string
param gwSKU string
param gwPublicIPName string = '${gwName}-IP'




resource gw 'Microsoft.Network/virtualNetworkGateways@2024-01-01' = {
  name: gwName
  location: gwLocation
  tags: resourceGroup().tags
  properties: {
    gatewayType: gwType
    ipConfigurations: [
      {
        name: 'gwipConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', gwVnetName, 'gatewaySubnet')
          }
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
    sku: {
      name: gwSKU
      tier: gwSKU
    }
  }
}

resource publicIP 'Microsoft.Network/publicIPAddresses@2024-01-01' = {
  name: gwPublicIPName
  location: gwLocation
  tags: resourceGroup().tags
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
  zones: []
}

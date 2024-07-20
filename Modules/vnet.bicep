targetScope = 'resourceGroup'

param vnetName string
param vnetLocation string = resourceGroup().location
param vnetAddressPrefix string
param vnetSubnets array = [
  {
    name: 'gatewaySubnet'
    addressPrefix: '10.0.0.0/27'
  }
  {
    name: 'dnsInbound'
    addressPrefix: '10.0.0.32/28'
  }
  {
    name: 'dnsOutbound'
    addressPrefix: '10.0.0.48/28'
  }
]

resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: vnetName
  location: vnetLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [for subnet in vnetSubnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
      }
    }]
  }
}

// expressRoute gateway


// vnet peerings


// user defined routes


// dns private resolver




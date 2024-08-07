targetScope = 'resourceGroup'

param vnetName string = 'NEW-VNET-01'
param vnetLocation string = resourceGroup().location
param vnetAddressPrefix string = '10.0.0.0/24'
param vnetDnsServers array = []
param vnetEncryption bool = true
param vnetSubnets array = [
  {
    name: 'gatewaySubnet'
    addressPrefix: '10.0.0.0/27'
  }
  {
    name: 'dnsInbound'
    addressPrefix: '10.0.0.32/28'
    routeTable: 'RT-Spoke-01-subnet1'
  }
  {
    name: 'dnsOutbound'
    addressPrefix: '10.0.0.48/28'
  }
]
param vnetTags object = resourceGroup().tags

resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: vnetName
  location: vnetLocation
  tags: vnetTags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    dhcpOptions: !empty(vnetDnsServers)
    ? {
      dnsServers: vnetDnsServers
    }
    : null
    encryption: vnetEncryption == true
    ? {
      enabled: false
    }
    : null
    subnets: [
      for subnet in vnetSubnets: {
        name: subnet.name
        properties: {
          addressPrefix: subnet.addressPrefix
          // vnet.?dnsServers ?? []
          routeTable: (contains(subnet, 'routeTable')
            ? {
                id: resourceId('Microsoft.Network/routeTables', subnet.routeTable)
              }
            : null)
        }
      }
    ]
  }
}

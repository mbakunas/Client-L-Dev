targetScope = 'resourceGroup'

param vnetName string = 'TEST-VNET-01'
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
    name: 'Public'
    addressPrefix: '10.0.0.32/28'
  }
  {
    name: 'Private'
    addressPrefix: '10.0.0.48/28'
  }
  {
    name: 'FwMgmt'
    addressPrefix: '10.0.0.64/27'
  }
  {
    name: 'Corpnet00'
    addressPrefix: '10.0.0.96/27'
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

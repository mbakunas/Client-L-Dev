targetScope = 'resourceGroup'

param nicName string
param nicLocation string
param nicSubnetId string

@allowed([
  'Dynamic'
  'Static'
])
param nicPrivateIPAllocationMethod string
param nicPrivateIPAddress string

resource vmNic 'Microsoft.Network/networkInterfaces@2024-01-01' = {
  name: nicName
  location: nicLocation
  tags: resourceGroup().tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: nicPrivateIPAllocationMethod
          subnet: {
            id: nicSubnetId
          }
          privateIPAddress: contains(nicPrivateIPAllocationMethod, 'Static') ? nicPrivateIPAddress : ''
        }
      }
    ]
    enableIPForwarding: false
    nicType: 'Standard'
  }
}

output id string = vmNic.id
output ipAddress string = vmNic.properties.ipConfigurations[0].properties.privateIPAddress

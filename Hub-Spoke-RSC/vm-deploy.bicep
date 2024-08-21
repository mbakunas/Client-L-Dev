targetScope = 'resourceGroup'

param vmName string
param vmLocation string = resourceGroup().location
param vmSku string
param vmRedundancy object

param vmAdminUsername string

@secure()
param vmAdminPassword string

// need to iterate through a NIC object
param vnetName string
param vnetSubnetName string
param vnetAddressPrefix string

// prepending the deployment name to the resource deployments sort of groups the child deployments together
var deploymentName = deployment().name

module vm '../Modules/vm.bicep' = {
  name: '${deploymentName}-${vmName}'
  params: {
    vmName: vmName
    vmLocation: vmLocation
    vmSku: vmSku
    vmRedundancy: vmRedundancy
    vmAdminUsername: vmAdminUsername
    vmAdminPassword: vmAdminPassword
    vmNicId: nicDynamic.outputs.id
  }
}

module nicDynamic '../Modules/networkInterfaceCard.bicep' = {
  name: '${deploymentName}-${vmName}-NIC-dynamic'
  params: {
    nicName: '${vmName}-NIC'
    nicLocation: vmLocation
    nicSubnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, vnetSubnetName)
    nicPrivateIPAllocationMethod: 'Dynamic'
    nicPrivateIPAddress: ''
  }
  dependsOn: [
    vnet
  ]
}

module vnet '../Modules/vnet.bicep' = {
  name: '${deploymentName}-${vnetName}'
  params: {
    vnetName: vnetName
    vnetLocation: vmLocation
    vnetAddressPrefix: vnetAddressPrefix
    vnetSubnets: [
      {
        name: vnetSubnetName
        addressPrefix: '10.0.0.0/24'
      }
    ]
    vnetTags: resourceGroup().tags
    vnetDnsServers: []
    vnetEncryption: true
  }
}


module nicStatic '../Modules/networkInterfaceCard.bicep' = {
  name: '${deploymentName}-${vmName}-NIC-static'
  params: {
    nicName: '${vmName}-NIC'
    nicLocation: vmLocation
    nicSubnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, vnetSubnetName)
    nicPrivateIPAllocationMethod: 'Static'
    nicPrivateIPAddress: nicDynamic.outputs.ipAddress
  }
  dependsOn: [
    vm
  ]
}

targetScope = 'resourceGroup'

param vnetName string = 'TEST-VNET-01'
param vnetLocation string = 'eastus2'
param vnetAddressPrefix string = '10.0.0.0/23'
param vnetDnsServers array = []
param vnetEncryption bool = false
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
        name: 'CorpNet'
        addressPrefix: '10.0.1.0/24'
      }
  
]
param vnetTags object = {
  location: 'eastus2'
  environment: 'non-prod'
  chargeCode: '42'
  runTime: '24x7'  
}

var deploymentName = deployment().name

module vnet '../Modules/vnet.bicep' = {
  name: '${deploymentName}-${vnetName}'
  params: {
    vnetName: vnetName
    vnetLocation: vnetLocation
    vnetAddressPrefix: vnetAddressPrefix
    vnetDnsServers: vnetDnsServers
    vnetEncryption: vnetEncryption
    vnetSubnets: vnetSubnets
    vnetTags: vnetTags
  }
}

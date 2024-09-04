targetScope = 'resourceGroup'

param loadBalancerName string
param loadBalancerLocation string = resourceGroup().location
param loadBalancerSku object
param loadBalancerProbe object

param firewallsAvailabilitySetName string

param firewallsVnetName string
param firewallsPublicSubnetName string
param firewallsPrivateSubnetName string
param firewallsManagementSubnetName string
param firewallsNames array
param firewallsVmSku string
param firewallsAdminUsername string

@secure()
param firewallsAdminPassword string


// variables
var availabilitySetProperties = {
    platformFaultDomainCount: 2
    platformUpdateDomainCount: 5
}
var deploymentName = deployment().name

var vnetSubnetPublicId = resourceId('Microsoft.Network/virtualNetworks/subnets', firewallsVnetName, firewallsPublicSubnetName)
var vnetSubnetPrivateId = resourceId('Microsoft.Network/virtualNetworks/subnets', firewallsVnetName, firewallsPrivateSubnetName)
var vnetSubnetManagementId = resourceId('Microsoft.Network/virtualNetworks/subnets', firewallsVnetName, firewallsManagementSubnetName)

var loadBalancerConfig = [
  // public
  {
    frontEnd: {
      name: '${firewallsPublicSubnetName}-FrontEnd'
      subnet: {
        id: vnetSubnetPublicId
      }
    }
    backEndAddressPool: {
      name: '${firewallsPublicSubnetName}-BackEnd'
    }
    loadBalancingRule: {
        name: '${firewallsPublicSubnetName}-LB-Rules'
        protocol: 'All'
        frontendPort: 0
        backendPort: 0
        loadDistribution: 'SourceIPProtocol'
        idleTimeoutInMinutes: 4
      }
  }
  {
    frontEnd: {
      name: '${firewallsPrivateSubnetName}-FrontEnd'
      subnet: {
        id: vnetSubnetPrivateId
      }
    }
    backEndAddressPool: {
      name: '${firewallsPrivateSubnetName}-BackEnd'
    }
    loadBalancingRule: {
        name: '${firewallsPrivateSubnetName}-LB-Rules'
        protocol: 'All'
        frontendPort: 0
        backendPort: 0
        loadDistribution: 'SourceIPProtocol'
        idleTimeoutInMinutes: 4
      }
  }
]
var firewallsConfig = [for firewall in firewallsNames:{
    name: firewall.name
    location: loadBalancerLocation
    size: firewallsVmSku
    adminUsername: firewallsAdminUsername
    adminPassword: firewallsAdminPassword
    privateNicName: firewall.privateNicName
    publicNicName: firewall.publicNicName
    managementNicName: firewall.managementNicName
  }
]


// load balancer
module loadBalancer '../Modules/loadBalancer.bicep' = {
  name: '${deploymentName}-loadBalancer'
  params: {
    lbName: loadBalancerName
    lbLocation: loadBalancerLocation
    lbSku: loadBalancerSku
    lbConfigs: loadBalancerConfig
    lbProbe: loadBalancerProbe
  }
}


// firewalls

 // create the availability set
resource availabilitySet 'Microsoft.Compute/availabilitySets@2022-03-01' = {
  name: firewallsAvailabilitySetName
  location: loadBalancerLocation
  properties: availabilitySetProperties
  sku: {
    name: 'Aligned'
  }
}
 // deploy the firewalls

module firewalls '../Modules/PaloAltoFirewall-AS.bicep' = [for firewall in firewallsConfig: {
  name: '${deploymentName}-${firewall.name}'
  scope: resourceGroup()
  dependsOn: [
    loadBalancer
  ]
  params: {
    fwVmName: firewall.name
    fwVmLocation: firewall.location
    fwVmSize: firewall.size
    fwAdminUsername: firewall.adminUsername
    fwAvailabilitySetId: availabilitySet.id
    fwAdminPassword: firewall.adminPassword
    fwVnetSubnetPrivateId: vnetSubnetPrivateId
    fwVmNicPrivateName: firewall.privateNicName
    fwVnetSubnetPublicId: vnetSubnetPublicId
    fwVmNicPublicName: firewall.publicNicName
    fwVnetSubnetManagementId: vnetSubnetManagementId
    fwVmNicManagementName: firewall.managementNicName
    fwVmNicPrivateLbBackendId: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, loadBalancerConfig[1].backEndAddressPool.name)
    fwVmNicPublicBackendId:resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, loadBalancerConfig[0].backEndAddressPool.name)
  }
}]

targetScope = 'resourceGroup'

param loadBalancerName string
param loadBalancerLocation string = resourceGroup().location
param loadBalancerSku object
param loadBalancerProbe object

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
 // deploy the firewalls

module firewalls '../Modules/PaloAltoFirewall-AZ.bicep' = [for (firewall, i) in firewallsConfig: {
  name: '${deploymentName}-${firewall.name}'
  scope: resourceGroup()
  dependsOn: [
    loadBalancer
  ]
  params: {
    fwVmName: firewall.name
    fwVmLocation: firewall.location
    fwVmSize: firewall.size
    fwAz: string(((i + 1) % 3) + 1)  // calculate the availability zone (1, 2, 3)
    fwAdminUsername: firewall.adminUsername
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

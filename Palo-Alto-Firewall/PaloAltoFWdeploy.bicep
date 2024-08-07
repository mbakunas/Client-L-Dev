targetScope = 'resourceGroup'

param loadBalancerName string
param loadBalancerLocation string = resourceGroup().location
param loadBalancerSku object
param loadBalancerConfigs array
param loadBalancerProbe object

param availabilitySetName string

param firewallsConfig array = [
  {
    name: 'fw1'
    location: 'eastus'
    size: 'Standard_D3_v2'
    adminUsername: 'admin'
    adminPassword: 'password'
    vnetSubnetTrustId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg1/providers/Microsoft.Network/virtualNetworks/vnet1/subnets/subnet1'
    vnetSubnetUnTrustId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg1/providers/Microsoft.Network/virtualNetworks/vnet1/subnets/subnet2'
    vnetSubnetManagementId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg1/providers/Microsoft.Network/virtualNetworks/vnet1/subnets/subnet3'
  }
]

var availabilitySetProperties = {
    platformFaultDomainCount: 2
    platformUpdateDomainCount: 5
}


// load balancer
module loadBalancer './Modules/loadBalancer.bicep' = {
  name: 'loadBalancer'
  params: {
    lbName: loadBalancerName
    lbLocation: loadBalancerLocation
    lbSku: loadBalancerSku
    lbConfigs: loadBalancerConfigs
    lbProbe: loadBalancerProbe
  }
}


// firewalls

 // create the availability set
resource availabilitySet 'Microsoft.Compute/availabilitySets@2022-03-01' = {
  name: availabilitySetName
  location: loadBalancerLocation
  properties: availabilitySetProperties
  sku: {
    name: 'Aligned'
  }
}
 // deploy the firewalls

module firewalls 'Modules/PaloAltoFirewall.bicep' = [for firewall in firewallsConfig: {
  name: firewall.name
  scope: resourceGroup()
  dependsOn: [
    loadBalancer
  ]
  params: {
    fwVmName: firewall.name
    fwVmLocation: firewall.location
    fwVmSize: firewall.size
    fwAdminUsername: firewall.adminUsername
    fwAvailablitySetId: availabilitySet.id
    fwAdminPassword: firewall.adminPassword
    fwVnetSubnetTrustId: firewall.vnetSubnetTrustId
    fwVnetSubnetUnTrustId: firewall.vnetSubnetUnTrustId
    fwVnetSubnetManagementId: firewall.vnetSubnetManagementId
    fwVmNicManagementBackendId:
    fwVmNicTrustLbBackendId:
    fwVmNicUnTrustBackendId:
  }
}]

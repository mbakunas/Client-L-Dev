using './PaloAltoFWdeploy.bicep'

param loadBalancerName = 'TEST-FWLB-01'
param loadBalancerLocation = 'eastus2'
param loadBalancerSku = {
  name: 'Standard'
  tier: 'Regional'
}
param loadBalancerProbe = {
  name: 'SSH'
  protocol: 'Tcp'
  port: 22
  intervalInSeconds: 15
}

param firewallsAvailabilitySetName = 'TEST-FW-AS-01'

param firewallsVnetName = 'TEST-VNET-01'
param firewallsPublicSubnetName = 'Public'
param firewallsPrivateSubnetName = 'Private'
param firewallsManagementSubnetName = 'FwMgmt'
param firewallsName = [
  'TEST-FW-01'
  'TEST-FW-02'
]
param firewallsVmSku = 'standard_d3_v2'
param firewallsAdminUsername = 'fwadmin'
param firewallsAdminPassword = 'LongPassw0rd!'


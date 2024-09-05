using './PaloAltoFWdeploy-AZ.bicep'

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
param firewallsVnetName = 'VNET-EASTUS2-SPOKE-01'
param firewallsPublicSubnetName = 'Public'
param firewallsPrivateSubnetName = 'Private'
param firewallsManagementSubnetName = 'FwMgmt'
param firewallsNames = [
  {
    name: 'TEST-FW-01'
    publicNicName: 'TEST-FW-01-Public'
    privateNicName: 'TEST-FW-01-Private'
    managementNicName: 'TEST-FW-01-Management'
  }
  {
    name: 'TEST-FW-02'
    publicNicName: 'TEST-FW-02-Public'
    privateNicName: 'TEST-FW-02-Private'
    managementNicName: 'TEST-FW-02-Management'
  }
]
param firewallsVmSku = 'standard_d3_v2'
param firewallsAdminUsername = 'fwadmin'
param firewallsAdminPassword = 'LongPassw0rd!'


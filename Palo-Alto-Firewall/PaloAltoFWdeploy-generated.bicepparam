using './PaloAltoFWdeploy.bicep'

param loadBalancerName = ''
param loadBalancerLocation = resourceGroup().location
param loadBalancerSku = {}
param loadBalancerProbe = {}
param availabilitySetName = ''
param firewallsVnetName = ''
param firewallsPublicSubnetName = ''
param firewallsPrivateSubnetName = ''
param firewallsManagementSubnetName = ''
param firewallsName = []
param firewallsVmSku = ''
param firewallsAdminUsername = ''
param firewallsAdminPassword = ''


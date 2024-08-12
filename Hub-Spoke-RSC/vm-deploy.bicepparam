using './vm-deploy.bicep'

param vmName = 'TEST-VM-01'
param vmLocation = 'eastus2'
param vmSku = 'Standard_D4_v5'
param vmAdminUsername = 'azureadmin'
param vmAdminPassword = 'LongPassw0rd!'
param vnetName = 'TEST-VNET-EASTUS2-01'
param vnetSubnetName = 'Corpnet'
param vmRedundancy =  {}

param vnetAddressPrefix =  ''

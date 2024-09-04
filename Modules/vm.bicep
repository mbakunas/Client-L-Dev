targetScope = 'resourceGroup'


param vmName string
param vmLocation string
param vmSku string

param vmAvailabilitySetId string = ''
param vmAvailabilityZones array = []

param vmAdminUsername string

@secure()
param vmAdminPassword string
param vmNicIds array


param imageReference object = {
  publisher: 'MicrosoftWindowsServer'
  offer: 'WindowsServer'
  sku: '2022-Datacenter'
  version: 'latest'
}
param osDisk object = {
  name: '${vmName}-OSDisk'
  createOption: 'FromImage'
  caching: 'ReadWrite'
  managedDisk: {
    storageAccountType: 'Standard_LRS'
  }
  deleteOption: 'Delete'
}

param vmPlan object = {}

resource vm 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: vmName
  location: vmLocation
  tags: resourceGroup().tags
  zones: empty(vmAvailabilityZones) ? vmAvailabilityZones : null
  plan: empty(vmPlan) ? vmPlan : null
  properties: {
    availabilitySet: empty(vmAvailabilitySetId) ? {
      id: vmAvailabilitySetId
    } : null    
    hardwareProfile: {
      vmSize: vmSku
    }
    storageProfile: {
      imageReference: imageReference
      osDisk: osDisk
    }
    osProfile: {
      computerName: vmName
      adminUsername: vmAdminUsername
      adminPassword: vmAdminPassword
    }
    networkProfile: {
      networkInterfaces: vmNicIds
    }
  }
}

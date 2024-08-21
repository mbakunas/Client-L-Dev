targetScope = 'resourceGroup'


param vmName string
param vmLocation string = resourceGroup().location
param vmSku string
param vmRedundancy object

param vmAdminUsername string

@secure()
param vmAdminPassword string
param vmNicId string

var vmOSSku = '2022-Datacenter'

resource vm 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: vmName
  location: vmLocation
  tags: resourceGroup().tags
  zones: vmRedundancy.?zone ?? null
  properties: {
    availabilitySet: contains(vmRedundancy, 'availabilitySet') ? {
      id: vmRedundancy.set
    } : null    
    hardwareProfile: {
      vmSize: vmSku
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: vmOSSku
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}-OSDisk'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        deleteOption: 'Delete'
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: vmAdminUsername
      adminPassword: vmAdminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmNicId
        }
      ]
    }
  }
}

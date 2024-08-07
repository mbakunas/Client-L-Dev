targetScope = 'resourceGroup'

param fwVmName string
param fwVmLocation string
param fwVmSize string = 'Standard_D3_v2'
param fwAdminUsername string
param fwAvailablitySetId string

@secure()
param fwAdminPassword string

//network parameters
param fwVnetSubnetTrustId string
param fwVmNicTrustName string = '${fwVmName}-Trust-NIC'
param fwVmNicTrustLbBackendId string
param fwVnetSubnetUnTrustId string
param fwVmNicUnTrustName string = '${fwVmName}-UnTrust-NIC'
param fwVmNicUnTrustBackendId string
param fwVnetSubnetManagementId string
param fwVmNicManagementName string = '${fwVmName}-Management-NIC'
param fwVmNicManagementBackendId string


var paloAltoPlan = {
    name: 'byol'
    publisher: 'paloaltonetworks'
    product: 'vmseries-flex'
  }
var paloAltoImageReference = {
    publisher: 'paloaltonetworks'
    offer: 'vmseries-flex'
    sku: 'byol'
    version: 'latest'
  }
var paloAltoVmDiskSize = 60

resource paloAltoFireWall 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: fwVmName
  location: fwVmLocation
  zones:[]
  plan: paloAltoPlan
  properties: {
    hardwareProfile: {
      vmSize: fwVmSize
    }
    availabilitySet: {
      id: fwAvailablitySetId
    }
    storageProfile: {
      imageReference: paloAltoImageReference
      osDisk: {
        osType: 'Linux'
        name: '${fwVmName}-OSDisk'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        deleteOption: 'Delete'
        diskSizeGB: paloAltoVmDiskSize
      }
    }
    osProfile: {
      computerName: fwVmName
      adminUsername: fwAdminUsername
      adminPassword: fwAdminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicTrust.id
          properties: {
            primary: true
          }
        }
        {
          id: nicUnTrust.id
          properties: {
            primary: false
          }
        }
        {
          id: nicManagement.id
          properties: {
            primary: false
          }
        }
      ]
    }
  }
}

resource nicTrust 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: fwVmNicTrustName
  location: fwVmLocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: fwVnetSubnetTrustId
          }
          loadBalancerBackendAddressPools: [
            {
              id: fwVmNicTrustLbBackendId
            }
          ]
        }
      }
    ]
    enableIPForwarding: true
    nicType: 'Standard'
  }
}

resource nicUnTrust 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: fwVmNicUnTrustName
  location: fwVmLocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: fwVnetSubnetUnTrustId
          }
          loadBalancerBackendAddressPools: [
            {
              id: fwVmNicUnTrustBackendId
            }
          ]
        }
      }
    ]
    enableIPForwarding: true
    nicType: 'Standard'
  }
}

resource nicManagement 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: fwVmNicManagementName
  location: fwVmLocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: fwVnetSubnetManagementId
          }
          loadBalancerBackendAddressPools: [
            {
              id: fwVmNicManagementBackendId
            }
          ]
        }
      }
    ]
    enableIPForwarding: false
    nicType: 'Standard'
  }
}

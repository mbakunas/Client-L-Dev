/*
  Before a Palo Alto Firewall can be deployed using this Bicep template, the terms and conditions must be accepted in the Azure Marketplace.
  The following PowerShell will 'pre-accept' the terms and conditions for the VM-Series Firewall in the Azure Marketplace:
  
  # ensure the PowerShell execution policy is set to allow local scripts to run
  #Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

  $SubscriptionName = "your-subscription-name"
  $planPublisher    = "paloaltonetworks"
  $planProduct      = "vmseries-flex"
  $planName         = "byol"
  
  Connect-AzAccount
  Set-AzContext -Subscription $SubscriptionName
  
  # accept purchase plan terms
  Set-AzMarketplaceTerms -Publisher $planPublisher  -Product $planProduct -Name $planName -Accept

  # verify that the terms have been accepted
  Get-AzMarketplaceTerms -Publisher $planPublisher  -Product $planProduct -Name $planName
*/

targetScope = 'resourceGroup'

param fwVmName string
param fwVmLocation string
param fwVmSize string = 'Standard_D3_v2'
param fwAdminUsername string
param fwAvailabilitySetId string

@secure()
param fwAdminPassword string

//network parameters
param fwVnetSubnetPrivateId string
param fwVmNicPrivateName string = '${fwVmName}-Private-NIC'
param fwVmNicPrivateLbBackendId string
param fwVnetSubnetPublicId string
param fwVmNicPublicName string = '${fwVmName}-Public-NIC'
param fwVmNicPublicBackendId string
param fwVnetSubnetManagementId string
param fwVmNicManagementName string = '${fwVmName}-Management-NIC'


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
  tags: resourceGroup().tags
  properties: {
    hardwareProfile: {
      vmSize: fwVmSize
    }
    availabilitySet: {
      id: fwAvailabilitySetId
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
          id: nicPrivate.id
          properties: {
            primary: false
          }
        }
        {
          id: nicPublic.id
          properties: {
            primary: false
          }
        }
        {
          id: nicManagement.id
          properties: {
            primary: true
          }
        }
      ]
    }
  }
}

resource nicPrivate 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: fwVmNicPrivateName
  location: fwVmLocation
  tags: resourceGroup().tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: fwVnetSubnetPrivateId
          }
          loadBalancerBackendAddressPools: [
            {
              id: fwVmNicPrivateLbBackendId
            }
          ]
        }
      }
    ]
    enableIPForwarding: true
    nicType: 'Standard'
  }
  dependsOn: [
    nicPublic
  ]
}

resource nicPublic 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: fwVmNicPublicName
  location: fwVmLocation
  tags: resourceGroup().tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: fwVnetSubnetPublicId
          }
          loadBalancerBackendAddressPools: [
            {
              id: fwVmNicPublicBackendId
            }
          ]
        }
      }
    ]
    enableIPForwarding: true
    nicType: 'Standard'
  }
  dependsOn: [
    nicManagement
  ]
}

resource nicManagement 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: fwVmNicManagementName
  location: fwVmLocation
  tags: resourceGroup().tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: fwVnetSubnetManagementId
          }
        }
      }
    ]
    enableIPForwarding: false
    nicType: 'Standard'
  }
}

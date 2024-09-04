using 'hub-spoke-deploy-existingSpoke.bicep'

param vnets = [
  {
    name: 'VNET-EASTUS2-SPOKE-01'
    resourceGroupName: 'HubSpokeTest01'
    resourceGroupLocation: 'eastus2'
    resourceGroupSubscriptionID: 'c64ca001-2cce-46de-837e-03f5564fc802'
    location: 'eastus2'
    addressPrefix: '10.1.0.0/16'
    dnsServers: [
      '100.0.0.100'
      '100.0.0.101'
    ]
    gateway: {
      name: 'VNET-EASTUS2-HUB-01-GW01'
      type: 'ExpressRoute'
      sku: 'Standard'
      publicIPName: 'VNET-EASTUS2-HUB-01-GW01-PIP'
    }
    subnets: [
      {
        name: 'Corpnet01'
        addressPrefix: '10.1.0.0/24'
        routeTable: 'VNET-EASTUS2-SPOKE-01-Corpnet01'
      }
    ]
    routeTable: {
      name: 'VNET-EASTUS2-SPOKE-01-Corpnet01'
      disableBgpRoutePropagation: true
      routes: [
        {
          name: 'default'
          properties: {
            addressPrefix: '0.0.0.0/0'
            nextHopType: 'VirtualAppliance'
            nextHopIpAddress: '10.0.0.52'
          }
        }
        {
          name: 'AZKMS'
          properties: {
            addressPrefix: '52.126.105.2/32'
            nextHopType: 'Internet'
          }
        }
      ]
    }
  }
  {
    name: 'VNET-EASTUS2-Spoke-02'
    resourceGroupName: 'HubSpokeTest01'
    resourceGroupLocation: 'eastus2'
    resourceGroupSubscriptionID: '16936380-29b0-4326-8f6b-db86da154736'
    location: 'eastus2'
    addressPrefix: '10.2.0.0/16'
    dnsServers: [
      '100.0.0.100'
      '100.0.0.101'
    ]
    subnets: [
      {
        name: 'Corpnet02'
        addressPrefix: '10.2.0.0/24'
        routeTable: 'RT-EASTUS2-Spoke-02-Corpnet02'
      }
    ]
    routeTable: {
      name: 'RT-EASTUS2-Spoke-02-Corpnet02'
      disableBgpRoutePropagation: true
      routes: [
        {
          name: 'default'
          properties: {
            addressPrefix: '0.0.0.0/0'
            nextHopType: 'VirtualAppliance'
            nextHopIpAddress: '10.0.0.52'
          }
        }
        {
          name: 'AZKMS'
          properties: {
            addressPrefix: '52.126.105.2/32'
            nextHopType: 'Internet'
          }
        }
      ]
    }
  }
  {
    name: 'VNET-EASTUS2-Spoke-03'
    resourceGroupName: 'HubSpokeTest01'
    resourceGroupLocation: 'eastus2'
    resourceGroupSubscriptionID: '93ebbf00-49a3-49cf-acd2-e4a848c1da2e'
    location: 'eastus2'
    addressPrefix: '10.3.0.0/16'
    dnsServers: [
      '100.0.0.100'
      '100.0.0.101'
    ]
    subnets: [
      {
        name: 'Corpnet03'
        addressPrefix: '10.3.0.0/24'
        routeTable: 'RT-EASTUS2-Spoke-03-Corpnet03'
      }
    ]
    routeTable: {
      name: 'RT-EASTUS2-Spoke-03-Corpnet03'
      disableBgpRoutePropagation: true
      routes: [
        {
          name: 'default'
          properties: {
            addressPrefix: '0.0.0.0/0'
            nextHopType: 'VirtualAppliance'
            nextHopIpAddress: '10.0.0.52'
          }
        }
        {
          name: 'AZKMS'
          properties: {
            addressPrefix: '52.126.105.2/32'
            nextHopType: 'Internet'
          }
        }
      ]
    }
  }
]
param tags = {
  location: 'eastus2'
  environment: 'non-prod'
  chargeCode: '42'
  runTime: '24x7'
}
param resourceGroupTags = {
  location: 'eastus2'
  environment: 'non-prod'
  chargeCode: '42'
  runTime: '24x7'
}

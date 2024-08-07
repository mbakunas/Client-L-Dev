using './loadBalancer.bicep'

param lbName = 'TestLB01'
param lbLocation = 'eastus2'
param lbSku  = {
  name: 'Standard'
  tier: 'Regional'
}
param lbConfigs = [
  {
    frontEnd: {
      name: 'Untrust-FrontEnd'
      subnet: {
        id: '/subscriptions/f0bb6c48-80fd-445c-98cb-c38b5f817d52/resourceGroups/RSC-Test/providers/Microsoft.Network/virtualNetworks/VNET-EASTUS2-HUB-01/subnets/dnsInbound'
      }
    }
    backEndAddressPool: {
      name: 'Untrust-BackEnd'
    }
    loadBalancingRule: {
        name: 'Untrust-LB-Rules'
        protocol: 'All'
        frontendPort: 0
        backendPort: 0
        loadDistribution: 'SourceIPProtocol'
        idleTimeoutInMinutes: 4
      }
  }
  {
    frontEnd: {
      name: 'Trust-FrontEnd'
      subnet: {
        id: '/subscriptions/f0bb6c48-80fd-445c-98cb-c38b5f817d52/resourceGroups/RSC-Test/providers/Microsoft.Network/virtualNetworks/VNET-EASTUS2-HUB-01/subnets/dnsOutbound'
      }
    }
    backEndAddressPool: {
      name: 'Trust-BackEnd'
    }
    loadBalancingRule: {
        name: 'Trust-LB-Rules'
        protocol: 'All'
        frontendPort: 0
        backendPort: 0
        loadDistribution: 'SourceIPProtocol'
        idleTimeoutInMinutes: 4
      }
  }
]
param lbProbe = {
  name: 'SSH'
  protocol: 'Tcp'
  port: 22
  intervalInSeconds: 15
}


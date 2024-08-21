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
        id: '/subscriptions/93ebbf00-49a3-49cf-acd2-e4a848c1da2e/resourceGroups/Firewall-Test-01/providers/Microsoft.Network/virtualNetworks/TEST-VNET-01/subnets/Public'
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
        id: '/subscriptions/93ebbf00-49a3-49cf-acd2-e4a848c1da2e/resourceGroups/Firewall-Test-01/providers/Microsoft.Network/virtualNetworks/TEST-VNET-01/subnets/Private'
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


targetScope = 'resourceGroup'


param lbName string
param lbLocation string
param lbSku object
param lbConfigs array
param lbProbe object

resource loadBalancer 'Microsoft.Network/loadBalancers@2024-01-01' = {
  name: lbName
  location: lbLocation
  sku: lbSku
  tags: resourceGroup().tags
  properties: {
    frontendIPConfigurations: [for lbConfig in lbConfigs: {
        name: lbConfig.frontEnd.name
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          privateIPAddressVersion: 'IPv4'
          subnet: {
            id: lbConfig.frontEnd.subnet.id
          }
        }
        zones: []  //TODO: dynamically adjust zones for regions that support AZs
      }
    ]
    backendAddressPools: [for lbConfig in lbConfigs: {
        name: lbConfig.backendAddressPool.name
      }
    ]
    loadBalancingRules: [for lbConfig in lbConfigs: {
        name: lbConfig.loadBalancingRule.name
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIpConfigurations', lbName, lbConfig.frontEnd.name)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, lbConfig.backEndAddressPool.name)
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', lbName, lbProbe.name)
          }
          protocol: lbConfig.loadBalancingRule.protocol
          frontendPort: lbConfig.loadBalancingRule.frontendPort
          backendPort: lbConfig.loadBalancingRule.backendPort
          loadDistribution: lbConfig.loadBalancingRule.loadDistribution
          idleTimeoutInMinutes: lbConfig.loadBalancingRule.idleTimeoutInMinutes
        }
      }
    ]
    probes: [
      {
        name: lbProbe.name
        properties: {
          protocol:lbProbe.protocol
          port: lbProbe.port
          intervalInSeconds: lbProbe.intervalInSeconds
        }
      }
    ]
  }
}



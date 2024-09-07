param location string
param virtualNetworkName string
param subnetName string

resource publicIp 'Microsoft.Network/publicIPAddresses@2024-01-01' = {
  name: 'firewall-ip'
  location: location // musi zawierać location
  sku: {
    name: 'Standard' //rekomendowane jest standard
  }
  properties: {
    publicIPAllocationMethod: 'Static' //mówi, ze adresy ip nie zmienia sie w czasie
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: virtualNetworkName

  resource subNet 'subnets@2024-01-01' existing = {
    name: subnetName
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2024-01-01' = {
  name: 'firewall'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfiguration'
        properties: {
          subnet: {
            id: virtualNetwork::subNet.id
          }
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: 'central-log-analytics'
  scope: resourceGroup('management')
}

resource firewallDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'allLogs_to_LogAnalyticsWorkspace'
  scope: firewall
  properties: {
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    logAnalyticsDestinationType: 'Dedicated'
    workspaceId: logAnalyticsWorkspace.id
  }
}

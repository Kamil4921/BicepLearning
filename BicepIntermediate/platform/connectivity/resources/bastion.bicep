param location string
param virtualNetworkName string
param subnetName string

resource publicIp 'Microsoft.Network/publicIPAddresses@2024-01-01' = {
  name: 'bastion-ip'
  location: location
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

resource bastionHost 'Microsoft.Network/bastionHosts@2024-01-01' = {
  name: 'bastion-host'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfiguration'
        properties: {
          subnet: {
            id: virtualNetwork::subNet.id //dzieki :: możemy się dostać do zagnieżdzonych resourców
          }
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
  }
}

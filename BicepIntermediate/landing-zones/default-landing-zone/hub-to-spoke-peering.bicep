param spokeVirtualNetworkName string
param spokeResourceGroupName string
param spokeNumber string

resource hubNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: 'hub'
}

resource spokeNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: spokeVirtualNetworkName
  scope: resourceGroup(spokeResourceGroupName)
}

resource peeringSpokeToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-01-01' = {
  name: 'hub_to_spoke-${spokeNumber}'
  parent: hubNetwork
  properties: {
    remoteVirtualNetwork: {
      id: spokeNetwork.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

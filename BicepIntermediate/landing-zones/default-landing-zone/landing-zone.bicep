param location string
param productName string
param spokeNumber string

var virtualNetworkName = 'vnet-${productName}'
var connectivityResourceGroupName = 'connectivity'

resource hubNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: 'hub'
  scope: resourceGroup(connectivityResourceGroupName)
}

resource spokeNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.${spokeNumber}.0/24'
      ]
    }
  }
}

resource peeringSpokeToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-01-01' = {
  name: 'spoke_to_hub'
  parent: spokeNetwork
  properties: {
    remoteVirtualNetwork: {
      id: hubNetwork.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

module peeringHubToSpokeDeploymnet 'hub-to-spoke-peering.bicep' = {
  name: 'peeringHubToSpokeDeploymnet'
  scope: resourceGroup(connectivityResourceGroupName)
  params: {
    spokeNumber: spokeNumber
    spokeResourceGroupName: resourceGroup().name
    spokeVirtualNetworkName: spokeNetwork.name
  }
}

resource routeTable 'Microsoft.Network/routeTables@2024-01-01' = {
  name: 'defaultRouteTable'
  location: location
  properties: {
    disableBgpRoutePropagation: true
    routes: [
      {
        name: 'defaultRoute'
        properties: {
          addressPrefix: '0.0.0.0/0'
          hasBgpOverride: false
          nextHopIpAddress: '10.0.10.4'
          nextHopType: 'VirtualAppliance'
        }
      }
    ]
  }
}

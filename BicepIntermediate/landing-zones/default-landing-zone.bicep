targetScope = 'subscription'

param location string
param productName string
param spokeNumber string

resource spokeResourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'lz-${spokeNumber}-${productName}'
  location: location
}

module spokeResourcesDeployment 'default-landing-zone/landing-zone.bicep' = {
  scope: spokeResourceGroup
  name: 'spokeResourcesDeployment'
  params: {
    location: location
    productName: productName
    spokeNumber: spokeNumber
  }
}

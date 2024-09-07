param location string

var bastionSubnetName = 'AzureBastionSubnet'
var firewallSubnetName  = 'AzureFirewallSubnet'
var vnetName = 'hub'

module virtualNetworkDeployment 'resources/virtualNetwork.bicep' = {
  name: 'virtualNetworkDeployment'
  params: {
    location: location
    bastionSubnetName: bastionSubnetName
    firewallSubnetName: firewallSubnetName
    vnetName: vnetName
  }
}

module bastionHostDeployment 'resources/bastion.bicep' = {
  name: 'bastionHostDeployment'
  params: {
    location: location
    subnetName: bastionSubnetName
    virtualNetworkName: vnetName
  }
  
  dependsOn: [ virtualNetworkDeployment ]
}

module firewallDeployment 'resources/firewall.bicep' = {
  name: 'firewallDeployment'
  params: {
    location: location
    subnetName: firewallSubnetName
    virtualNetworkName: vnetName
  }
}

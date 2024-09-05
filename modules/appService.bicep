@allowed(['dev', 'test', 'prod'])
param enviroment string
param location string
param serverFarmOs string

param ConfigurationSettings websiteConfigurationSettings

var serverFarmSku = enviroment == 'prod' ? 'B1' : 'F1'

@export()
type websiteConfigurationSettings = {
  awesomeFeature: bool

  @minValue(1)
  @maxValue(5)
  awesomeFeatureCounter: int

  @minLength(5)
  @maxLength(20)
  displayedAwesomeFeatureName: string
}

resource serverFarm 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: 'bicep-test${uniqueString(resourceGroup().id)}-${enviroment}'
  location: location
  sku: {
    name: serverFarmSku
  }

  kind: serverFarmOs
  properties:{
    reserved: true //ważne by był linux jako os
  }
}

resource webapp 'Microsoft.Web/sites@2023-12-01' = {
  name: 'bicep-webapp${uniqueString(resourceGroup().id)}-${enviroment}'
  location: location
  kind: serverFarmOs
  properties:{
    serverFarmId: serverFarm.id
    reserved: true
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${websiteManagedIdentity.id}' : { }
    }
  }
}

resource appconfig 'Microsoft.Web/sites/config@2023-12-01' = {
  parent: webapp
  name: 'appsettings'
  properties:{
    awesomeFeature: string(ConfigurationSettings.awesomeFeature)
    awesomeFeatureCounter: string(ConfigurationSettings.awesomeFeatureCounter)
    displayedAwesomeFeatureName: ConfigurationSettings.displayedAwesomeFeatureName
  }
}

resource websiteManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'websiteManagedIdentity'
  location: location
}

output websiteManagedIdentityName string = websiteManagedIdentity.name
output websiteManagedIdentityClientId string = websiteManagedIdentity.properties.clientId
output websiteManagedIdentityPrincipalId string = websiteManagedIdentity.properties.principalId

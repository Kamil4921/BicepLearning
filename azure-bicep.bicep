type websiteConfigurationSettings = {
  awesomeFeature: bool

  @minValue(1)
  @maxValue(5)
  awesomeFeatureCounter: int

  @minLength(5)
  @maxLength(20)
  displayedAwesomeFeatureName: string
}

@allowed(['prod', 'test', 'dev'])
param enviroment string

param ConfigurationSettings websiteConfigurationSettings

@allowed(['linux', 'windows'])
param serverFarmOs string = 'linux'

var location = resourceGroup().location
var serverFarmSku = enviroment == 'prod' ? 'B1' : 'F1'

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

module applicationInsightsDeployment 'modules/application-insights.bicep' = {
  name: 'applicationInsights'
  params: {
    location: location
    enviroment: enviroment
  }
}

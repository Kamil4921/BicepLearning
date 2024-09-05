@allowed(['prod', 'test', 'dev'])
param enviroment string

@allowed(['linux', 'windows'])
param serverFarmOs string = 'linux'

var location = resourceGroup().location

import { websiteConfigurationSettings } from 'modules/appService.bicep'
param configurationSettings websiteConfigurationSettings

module appServiceModule 'modules/appService.bicep' = {
  name: 'appServiceDeployment'
  params: {
    location: location
    ConfigurationSettings: configurationSettings
    enviroment: enviroment
    serverFarmOs: serverFarmOs
  }
}

module applicationInsightsDeployment 'modules/application-insights.bicep' = {
  name: 'applicationInsights'
  params: {
    location: location
    enviroment: enviroment
  }
}

module sqlDatabaseDeployment 'modules/sqlDatabase.bicep' = {
  name: 'sqlServerDeployment'
  params: {
    location: location
    administratorManagedIndentityClientId: appServiceModule.outputs.websiteManagedIdentityClientId
    administratorManagedIndentityName: appServiceModule.outputs.websiteManagedIdentityName
    enviroment: enviroment
  }
}

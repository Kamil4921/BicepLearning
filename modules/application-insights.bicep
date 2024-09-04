@allowed(['dev', 'test', 'prod'])
param enviroment string

param location string

resource logAnalyticksWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  scope: resourceGroup(subscription().subscriptionId, 'bicep-sharedresources')
  name: 'Bicep-logAnalyticksWorkspace'
}

resource applicatoinInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'apInPortal-${enviroment}'
  location: location
  kind: 'web'
  properties:{
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticksWorkspace.id
  }
}

@allowed(['dev', 'test', 'prod'])
param enviroment string
param location string

param metricksPublisherPrincipalId string

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

var metricksPublisherWellKnownId = '3913510d-42f4-4e42-8a64-420c390055eb'

resource metricksPublisherRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  name: metricksPublisherWellKnownId
}

resource monitoringMetricksPublisherRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: applicatoinInsights
  name: guid(applicatoinInsights.name, metricksPublisherPrincipalId, metricksPublisherRoleDefinition.id)
  properties: {
    principalId: metricksPublisherPrincipalId
    roleDefinitionId: metricksPublisherRoleDefinition.id
  }
}

var metricDetails = [
  {
    metricName: 'Failed Requests'
    metricIdentifier: 'requests/failed'
  }
  {
    metricName: 'Failed Dependencies'
    metricIdentifier: 'dependencies/failed'
  }
]

resource failuresAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = [for metricDetail in metricDetails: if (enviroment == 'prod') {
  name: 'Rule for ${metricDetail.metricName}'
  location: 'global'
  properties: {
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          threshold: 1
          name: metricDetail.metricName
          metricName: metricDetail.metricIdentifier
          metricNamespace: 'microsoft.insights/components'
          operator: 'GreaterThan'
          timeAggregation: 'Count'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
    enabled: true
    evaluationFrequency: 'PT5M'
    scopes: [
      applicatoinInsights.id
    ]
    severity: 3
    windowSize: 'PT5M'
  }
}]

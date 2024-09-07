param location string

resource logAnalyticksWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'central-log-analytics'
  location: location
}

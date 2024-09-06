@allowed(['dev', 'test', 'prod'])
param enviroment string
param location string

param administratorManagedIndentityName string
param administratorManagedIndentityClientId string

resource sqlServer 'Microsoft.Sql/servers@2023-08-01-preview' = {
  name: 'bicepSqlServer-${enviroment}'
  location: location
  properties: {
    administrators: {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: true
      login: administratorManagedIndentityName
      sid: administratorManagedIndentityClientId
      tenantId: subscription().tenantId
    }
  }

  resource sqlDatabase 'databases' = {
    name: 'bicepDatabaseTest'
    location: location
    sku: {
      name: 'Basic'
    }
  }
}

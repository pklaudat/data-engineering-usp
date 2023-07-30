targetScope = 'subscription'


param name string
param managedIdentityName string = 'managedIdentity${name}'
param storageAccountName string = 'storageacc${name}'
param sqlServerName string = 'sqlserver${name}'
param sqlUser string
@secure()
param sqlPassword string
param location string

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-adf-${name}-workspace'
  location: location
  tags: {
    department: 'IT'
    project: 'Data Factory'
  }
}

module sourceOfData 'infrastructure/storage.bicep' = {
  name: 'storage'
  scope: rg
  params: {
    storageAccountName: storageAccountName
    location: location
    sqlUser: sqlUser
    sqlPassword: sqlPassword
    sqlServerName: sqlServerName

  }
}

module dataFactory 'infrastructure/data_factory.bicep' = {
  name: 'dataFactory'
  scope: rg
  params: {
    location: location
    managedIdentityName: managedIdentityName
    storageAccountEndpoint: sourceOfData.outputs.serviceEndpoint
  }
}

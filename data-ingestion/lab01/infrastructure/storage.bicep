param storageAccountName string
param sqlServerName string
@secure()
param sqlUser string 
@secure()
param sqlPassword string
param location string = resourceGroup().location


resource sqlServer 'Microsoft.Sql/servers@2022-11-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlUser
    administratorLoginPassword: sqlPassword
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-11-01-preview' = {
  name: '${sqlServerName}-db'
  parent: sqlServer
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 1073741824
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01'  = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

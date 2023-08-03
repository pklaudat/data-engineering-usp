targetScope = 'subscription'

param name string
param managedIdentityName string = 'managedIdentity${name}'
param storageAccountName string = 'storageacc${name}'
param factoryName string = 'data-factory-${subscription().subscriptionId}'
param sqlServerName string = 'sqlserver${name}'
@secure()
param sqlSid string
// param sqlUser string
// @secure()
// param sqlPassword string
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
    sqlSid: sqlSid
    sqlServerName: sqlServerName
    managedIdentityName: managedIdentityName
  }
}

module dataFactory 'infrastructure/data_factory.bicep' = {
  name: 'dataFactory'
  scope: rg
  params: {
    location: location
    managedIdentityName: managedIdentityName
    storageAccountEndpoint: sourceOfData.outputs.serviceEndpoint
    sqlServerName: sqlServerName
    factoryName: factoryName
  }
  dependsOn: [
    sourceOfData
  ]
}

module etlPipeline 'infrastructure/etl_pipeline.bicep' = {
  name: 'etl-pipeline'
  scope: rg
  params: {
    dataFactoryName: factoryName
    location: location
  }
  dependsOn: [
    sourceOfData
    dataFactory
  ]
}

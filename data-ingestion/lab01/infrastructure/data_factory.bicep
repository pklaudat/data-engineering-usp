param location string = resourceGroup().location
param factoryName string = 'data-factory-${subscription().subscriptionId}'
param managedIdentityName string
param storageAccountEndpoint string
param sqlServerName string

resource managedIdentityRef 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: managedIdentityName
}

resource datafactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: factoryName
  location: location
  tags: {
    department: 'IT'
    project: 'Data Factory'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityRef.id}': {}
    }
  }
}

resource credential 'Microsoft.DataFactory/factories/credentials@2018-06-01' = {
  name: '${factoryName}-credential'
  parent: datafactory
  properties: {
    type: 'ManagedIdentity'
    typeProperties: {
      resourceId: managedIdentityRef.id
    }
  }
}

resource dataInLinkedConnection 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: '${factoryName}-dataIn'
  parent: datafactory
  properties: {
    type: 'AzureBlobStorage'
    typeProperties: {
      serviceEndpoint: storageAccountEndpoint
      credential: {
        referenceName: 'data-factory-${subscription().subscriptionId}-credential'
        type: 'CredentialReference'
      }
      accountKind: 'StorageV2'
    }
  }
  dependsOn: [
    credential
  ]
}

resource dataOutLinkedConnection 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: '${factoryName}-dataOut'
  parent: datafactory
  properties: {
    annotations: []
    type: 'AzureSqlDatabase'
    typeProperties: {
      connectionString: 'Integrated Security=False;Encrypt=True;Connection Timeout=30;Data Source=${sqlServerName}.database.windows.net;Initial Catalog=${sqlServerName}-db;'
      credential: {
        referenceName: 'data-factory-${subscription().subscriptionId}-credential'
        type: 'CredentialReference'
      }
    }
  }
}

output serviceLinkOutput string = dataOutLinkedConnection.name
output serviceLinkSource string = dataInLinkedConnection.name

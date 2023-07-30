

param location string = resourceGroup().location
param factoryName string = 'data-factory-${subscription().subscriptionId}'
param managedIdentityName string


var storageAccountDataReaderRoleId = '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
var sqlServerContributorRoleId = '9b7fa17d-e63e-47b0-bb0a-15c516ac86ec'
//var sqlServerReaderRoleId = '7a2c5c1f-5e4d-4f2e-8f17-349c0bfdf9e8'

var rolesToAssign = [storageAccountDataReaderRoleId, sqlServerContributorRoleId]

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityName
  location: location
  tags: {
    department: 'IT'
    project: 'Data Factory'
  }
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
      '${managedIdentity.id}': {}
    }
  }
}

@batchSize(1)
resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for role in rolesToAssign: {
  name: guid(subscription().subscriptionId, 'DataFactoryContributor', role)
  properties: {
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', role)
  }
  dependsOn: [
    datafactory
  ]
}]

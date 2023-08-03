param storageAccountName string
param sqlServerName string
// @secure()
// param sqlUser string 
// @secure()
// param sqlPassword string
@secure()
param sqlSid string
param location string = resourceGroup().location
param managedIdentityName string

var blobFolders = ['bancos', 'empregados', 'reclamacoes']
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

resource sqlServer 'Microsoft.Sql/servers@2022-11-01-preview' = {
  name: sqlServerName
  location: location
  identity: {
    type: 'userAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    primaryUserAssignedIdentityId: managedIdentity.id
    // administratorLogin: sqlUser
    // administratorLoginPassword: sqlPassword
    minimalTlsVersion: '1.2'
    administrators: {
      login: 'sqladmin'
      sid: sqlSid //'1b8bec2c-9878-45d5-87cf-b161d55d16e7'
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: true
      tenantId: subscription().tenantId
    }
    publicNetworkAccess: 'Enabled'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-11-01-preview' = {
  name: '${sqlServerName}-db'
  parent: sqlServer
  location: location
  identity: {
    type: 'userAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 1073741824
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
    sqlDatabase
  ]
}]

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01'  = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  resource blob 'blobServices' = {
    name: 'default'
    resource container 'containers' = [ for container in blobFolders: {
      name: container
    }]
  }
}


// resource uploadData 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
//   name: 'uploadData'
//   location: location
//   kind: 'AzureCLI'
//   properties: {
//     azCliVersion: '2.0.80'
//     timeout: 'PT5M'
//     retentionInterval: 'PT1H'
//     environmentVariables: [
//       {
//         name: 'STORAGE_ACCOUNT_NAME'
//         value: storageAccount.name
//       }
//       {
//         name: 'STORAGE_ACCOUNT_KEY'
//         value: storageAccount.listKeys().keys[0].value
//       }
//     ]
//     scriptContent: 'az storage blob upload --subscription ${subscription().id} --account-name $STORAGE_ACCOUNT_NAME --account-key $STORAGE_ACCOUNT_KEY -c data-adf -f ./data' 
    
//   }
// }

output serviceEndpoint string = storageAccount.properties.primaryEndpoints.blob

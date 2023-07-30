param storageAccountName string
param sqlServerName string
@secure()
param sqlUser string 
@secure()
param sqlPassword string
param location string = resourceGroup().location

var blobFolders = ['bancos', 'empregados', 'reclamacoes']

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

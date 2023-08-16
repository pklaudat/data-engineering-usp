
@description('The name of the project.')
param projectName string

@description('The location of the resource group.')
param location string = resourceGroup().location

@description('URI where the function code is located.')
var packageUri = ''

@description('Name of the function app.')
var azureFunctionName = 'fnapp-${replace(projectName, '_', '-')}-${location}'

@description('Name of the storage account.')
var storageAccountName = 'safnapp${uniqueString(resourceGroup().id)}'

resource hostingPlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: 'asp-${azureFunctionName}'
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {
    reserved: true
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-${azureFunctionName}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}


resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  dependsOn: [
    hostingPlan
  ]
}

resource blob 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  name: 'default'
  parent: storageAccount
  properties: {}
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'mi-${azureFunctionName}'
  location: location
}


resource azureFunction 'Microsoft.Web/sites@2022-09-01' = {
  name: azureFunctionName
  location: location
  kind: 'functionapp,linux'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, '2019-06-01').keys[0].value}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '0'
        }
      ]
    }
  }
}


resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('mi-${azureFunctionName}-storage-access')
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1')
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
  dependsOn: [azureFunction]
}

// resource msdeploy 'Microsoft.Web/sites/extensions@2022-09-01' = {
//   name: 'MSDeploy'
//   parent: azureFunction
//   properties: {
//     packageUri: packageUri
//   }
// }

// code a blob trigger for this azure function
// resource blobTrigger 'Microsoft.Web/sites/functions@2022-09-01' = {
//   name: 'blobTrigger'
//   parent: azureFunction
//   properties: {
    
//   }
// }

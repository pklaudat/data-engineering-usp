targetScope = 'subscription'

param location string = deployment().location
param projectName string = 'serverless_etl'


resource rg 'Microsoft.Resources/resourceGroups@2018-05-01' = {
  name: 'rg-app-${projectName}-${location}'
  location: location
  properties: {}
}


module serverless_etl 'infrastructure/serverless_function.bicep' = {
  name: '${projectName}-infrastructure'
  scope: rg
  params: {
    location: location
    projectName: projectName
  }
}


param dataFactoryName string
param location string = resourceGroup().location

var dataSetsList = ['bancos', 'empregados', 'reclamacoes']

resource pipeline 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: '${dataFactoryName}/pipeline-lab01'
  properties: {
  }
}

// resource dataSets 'Microsoft.DataFactory/factories/datasets@2018-06-01' = [for dataSet in dataSetsList: {
//   name: '${dataSet}/dataset'
//   // properties: {
//   // }
// }]

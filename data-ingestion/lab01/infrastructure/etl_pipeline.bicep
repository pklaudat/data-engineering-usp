
param dataFactoryName string
param serviceLinkSource string
param serviceLinkOutput string
param location string = resourceGroup().location

var dataSetsList = ['bancos', 'empregados', 'reclamacoes']
var formats = [
  {
    type: 'TextFormat'
    columnDelimiter: '\t'
    rowDelimiter: '\n'
    escapeChar: ''
    quoteChar: ''
    treatEmptyAsNull: true
    firstRowAsHeader: true
  }
  {
    type: 'TextFormat'
    columnDelimiter: '|'
    rowDelimiter: '\n'
    escapeChar: ''
    quoteChar: ''
    treatEmptyAsNull: true
    firstRowAsHeader: true
  }
  {
    type: 'TextFormat'
    columnDelimiter: ';'
    rowDelimiter: '\n'
    escapeChar: '\\'
    treatEmptyAsNull: true
    firstRowAsHeader: true
    encodingName: 'WINDOWS-1258'
  }
]
resource pipeline 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: '${dataFactoryName}/pipeline-lab01'
  properties: {
  }
}

resource dataSets 'Microsoft.DataFactory/factories/datasets@2018-06-01' = [for dataSet in dataSetsList: {
  name: '${dataFactoryName}/${dataSet}'
  properties: {
    linkedServiceName: {
      type: 'LinkedServiceReference'
      referenceName: serviceLinkSource
    }
    annotations: []
    type: 'AzureBlob'
    typeProperties: {
      folderPath: dataSet
      format: formats[indexOf(dataSetsList, dataSet)]
    }
  }
}]

import * as cdk from 'aws-cdk-lib';
import { CfnTable, CfnTableProps } from 'aws-cdk-lib/aws-dynamodb';
import { Construct } from 'constructs';
// import * as sqs from 'aws-cdk-lib/aws-sqs';

const tables: {
  [key: string]: {
    attributeDefinitions: CfnTable.AttributeDefinitionProperty[];
    keySchema: CfnTable.KeySchemaProperty[];
  };
} = {
  ProductCatalog: {
    attributeDefinitions: [{
      attributeName: 'Id',
      attributeType: 'N'
    }],
    keySchema: [{
      attributeName: 'Id',
      keyType: 'HASH'
    }]
  },
  Forum: {
    attributeDefinitions: [{  
      attributeName: 'Nome',
      attributeType: 'S'
    }],
    keySchema: [{
      attributeName: 'Nome',
      keyType: "HASH"
    }]
  },
  Thread: {
    attributeDefinitions: [{
      attributeName: 'NomeForum',
      attributeType: 'S'
    }, {
      attributeName: 'Tema',
      attributeType: 'S'
    }],
    keySchema: [{
      attributeName: 'NomeForum',
      keyType: 'HASH'
    },{
      attributeName: 'Tema',
      keyType: 'RANGE'
    }],
  
  },
  Resposta: {
    attributeDefinitions: [{
      attributeName: 'Id',
      attributeType: 'S'
    },{
      attributeName: 'DataResposta',
      attributeType: 'S'
    }],
    keySchema: [{
      attributeName: 'Id',
      keyType: 'HASH'
    }, {
      attributeName: 'DataResposta',
      keyType: 'RANGE'
    }]
  }
}


export class DynamoDbStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Create DynamoDB table
    for (const tableName in tables) {
      if (tables.hasOwnProperty(tableName)) {
        const tableData = tables[tableName];
        
        const tableProps: CfnTableProps = {
          tableName: tableName,
          attributeDefinitions: tableData.attributeDefinitions,
          keySchema: tableData.keySchema,
          //billingMode: 'PAY_PER_REQUEST',
          timeToLiveSpecification: {
            attributeName: 'ttl',
            enabled: true,
          },
          pointInTimeRecoverySpecification: {
            pointInTimeRecoveryEnabled: true,
          },
          sseSpecification: {
            sseEnabled: true,
          },
          provisionedThroughput: {
            readCapacityUnits: 10,
            writeCapacityUnits: 5,
          },
        };

        new CfnTable(this, `exercicio3-dynamodb-table-${tableName}`, tableProps);
      }
    }
  }
}

import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import { Vpc, SubnetType } from 'aws-cdk-lib/aws-ec2';

export class MyVpcStack extends cdk.Stack {
    constructor(scope: Construct, id: string, props?: cdk.StackProps) {
      super(scope, id, props);
  
      // Create the VPC
      const vpc = new Vpc(this, 'MyVPC', {
        cidr: '10.0.0.0/16',
        maxAzs: 3,
        subnetConfiguration: [
          {
            cidrMask: 24,
            name: 'subnet-app',
            subnetType: SubnetType.PRIVATE_ISOLATED,
          },
          {
            cidrMask: 24,
            name: 'subnet-db',
            subnetType: SubnetType.PRIVATE_ISOLATED,
          },
          {
            cidrMask: 24,
            name: 'subnet-web',
            subnetType: SubnetType.PUBLIC,
          },
        ],
      });
    }
  }
  
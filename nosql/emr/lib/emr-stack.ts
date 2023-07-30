import * as cdk from 'aws-cdk-lib';
import * as emr from 'aws-cdk-lib/aws-emr';
import * as s3 from 'aws-cdk-lib/aws-s3';
import { Construct } from 'constructs';

export class EmrStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Create an S3 bucket for EMR input/output
    const bucket = new s3.Bucket(this, 'EmrS3Bucket', {
      removalPolicy: cdk.RemovalPolicy.DESTROY, // Not recommended for production
    });

    // Define the EMR cluster
    const emrCluster = new emr.CfnCluster(this, 'EmrCluster', {
      instances: {
        masterInstanceGroup: {
          instanceCount: 1,
          instanceType: 'm5.xlarge',
          market: 'ON_DEMAND',
        },
      },
      applications: [
        { name: 'Spark' },
        { name: 'Hive' },
      ],
      name: 'MyEMRCluster',
      logUri: `s3://${bucket.bucketName}/logs`,
      instancesBucket: bucket.bucketName,
    });

    // Grant EMR service role read/write access to the S3 bucket
    bucket.grantReadWrite(emrCluster, 'emr:*');
  }
}


---

# Detailed Documentation: Deploying AWS S3 Object Lambda with AWS CDK

How to deploy an AWS S3 Object Lambda using the AWS Cloud Development Kit (CDK) with TypeScript. I've included explanations for each component of the code and organized the documentation for better readability.

This document outlines the steps to deploy an S3 Object Lambda using the AWS Cloud Development Kit (CDK). We’ll cover relevant AWS services, delve into the TypeScript code structure, troubleshoot common issues, and provide a step-by-step guide for a successful deployment.

---

## Table of Contents

1. [Introduction to AWS S3 Object Lambda](#introduction-to-aws-s3-object-lambda)
2. [Overview of the Project Setup](#overview-of-the-project-setup)
3. [Explanation of the TypeScript Code](#explanation-of-the-typescript-code)
   - [AWS CDK Basics](#aws-cdk-basics)
   - [S3 Bucket and Access Points](#s3-bucket-and-access-points)
   - [Lambda Function for Object Transformation](#lambda-function-for-object-transformation)
4. [Common Errors and Troubleshooting](#common-errors-and-troubleshooting)
   - [Asset Not Found Errors](#asset-not-found-errors)
5. [Step-by-Step Guide to Deploy](#step-by-step-guide-to-deploy)
   - [Setting Up the Project](#setting-up-the-project)
   - [Resolving Build Errors](#resolving-build-errors)
   - [Deploying the CDK Stack](#deploying-the-cdk-stack)
6. [Conclusion](#conclusion)

---

## 1. Introduction to AWS S3 Object Lambda

Amazon S3 Object Lambda allows you to process and transform data during retrieval from S3 using an AWS Lambda function. This feature enables custom transformations, such as masking, filtering, and format conversion, before delivering content to the requester.

---

## 2. Overview of the Project Setup

The project aims to establish an AWS S3 bucket, facilitate access through an S3 Access Point, and employ S3 Object Lambda to process data during retrieval. The entire infrastructure is defined using AWS CDK in TypeScript.

---

## 3. Explanation of the TypeScript Code

The AWS CDK (Cloud Development Kit) enables the definition of cloud infrastructure using modern programming languages like TypeScript.

### 3.1. AWS CDK Basics

The core of the project utilizes the CDK’s **Stack** class to define AWS resources:

```typescript
import { Stack, StackProps, CfnOutput, Aws } from 'aws-cdk-lib';
import { Construct } from 'constructs';

export class S3ObjectLambdaStack extends Stack {
  constructor(scope: Construct, id: string, props?: StackProps) {
    super(scope, id, props);
  }
}
```

- **Stack**: Represents a deployable unit of infrastructure.
- **Scope**: The parent construct of the stack, usually the app itself.
- **id**: A unique identifier for the stack.

### 3.2. S3 Bucket and Access Points

The S3 bucket serves as the primary storage component. Access Points are created for fine-grained access control.

```typescript
const bucket = new s3.Bucket(this, 'example-bucket', {
  accessControl: s3.BucketAccessControl.BUCKET_OWNER_FULL_CONTROL,
  encryption: s3.BucketEncryption.S3_MANAGED,
  blockPublicAccess: s3.BlockPublicAccess.BLOCK_ALL,
});
```

- **S3 Bucket**: Stores the objects.
- **Access Control**: Ensures the bucket owner retains full control.
- **Block Public Access**: Blocks public access to enhance data security.

#### Access Point Policy

```typescript
bucket.addToResourcePolicy(new iam.PolicyStatement({
  actions: ['*'],
  principals: [new iam.AnyPrincipal()],
  resources: [
    bucket.bucketArn,
    bucket.arnForObjects('*'),
  ],
  conditions: {
    'StringEquals': {
      's3:DataAccessPointAccount': `${Aws.ACCOUNT_ID}`,
    },
  },
}));
```

This policy enables access control for the access points, restricting actions to authorized users.

### 3.3. Lambda Function for Object Transformation

A Lambda function processes the objects retrieved from the bucket:

```typescript
const retrieveTransformedObjectLambda = new lambda.Function(this, 'retrieveTransformedObjectLambda', {
  runtime: lambda.Runtime.NODEJS_20_X,
  handler: 'index.handler',
  code: lambda.Code.fromAsset('resources/retrieve-transformed-object-lambda'),
});
```

- **Runtime**: Specifies Node.js version 20.x.
- **Handler**: Entry point for the Lambda function.
- **Code**: Path to the Lambda function's source code.

#### Permissions for Lambda

```typescript
retrieveTransformedObjectLambda.addToRolePolicy(new iam.PolicyStatement({
  effect: iam.Effect.ALLOW,
  resources: ['*'],
  actions: ['s3-object-lambda:WriteGetObjectResponse'],
}));
```

This allows the Lambda function to write the transformed response back to S3.

#### Invocation Permissions

```typescript
retrieveTransformedObjectLambda.addPermission('invocationRestriction', {
  action: 'lambda:InvokeFunction',
  principal: new iam.AccountRootPrincipal(),
  sourceAccount: Aws.ACCOUNT_ID,
});
```

Restricts the invocation of the Lambda function to the account that owns it.

---

### 4. Common Errors and Troubleshooting

#### **Error: Cannot Find Asset**

You may encounter the following error during deployment:

```bash
Error: Cannot find asset at /Users/satish/Desktop/Ironrim/s3-object-l-s/resources/retrieve-transformed-object-lambda
```

**Solution**:

1. **Check the Path**: Verify that the `resources/retrieve-transformed-object-lambda` directory exists.
2. **Add Required Files**: Ensure that the Lambda handler file (`index.js` or `index.ts`) is present in the directory.
3. **Basic Lambda Code Example**:

   ```javascript
   exports.handler = async (event) => {
     console.log('Received event:', JSON.stringify(event, null, 2));
     const response = {
       statusCode: 200,
       body: JSON.stringify('Hello from Lambda!'),
     };
     return response;
   };
   ```

---

## 5. Step-by-Step Guide to Deploy

### 5.1. Setting Up the Project

Follow these steps to deploy the project:

1. **Install AWS CDK and Dependencies**:

   If you haven’t installed AWS CDK, run:

   ```bash
   npm install -g aws-cdk
   ```

   Then, install project dependencies:

   ```bash
   npm install
   ```

2. **Check Code Structure**:

   Ensure your Lambda function code is in `resources/retrieve-transformed-object-lambda` and that all TypeScript files are error-free.

3. **Build the Project**:

   ```bash
   npm run build
   ```

### 5.2. Resolving Build Errors

You may encounter type errors during the build process. For instance:

```bash
error TS2724: '"../lib/s3-object-l-s-stack"' has no exported member named 'S3ObjectLSStack'. Did you mean 'S3ObjectLambdaStack'?
```

**Solution**: Correct the import statement to reference the right stack name:

```typescript
import { S3ObjectLambdaStack } from '../lib/s3-object-l-s-stack';
```

After fixing the error, you should be able to build without issues.

### 5.3. Deploying the CDK Stack

Once the build is successful, deploy the stack:

```bash
cdk deploy
```

During the deployment, CDK will:
- Create an S3 bucket.
- Set up access points for the bucket.
- Deploy the Lambda function.
- Configure the S3 Object Lambda access point.

---

## 6. Conclusion

Deploying AWS S3 Object Lambda with the AWS CDK simplifies infrastructure management through infrastructure as code (IaC). This project demonstrated how to set up an S3 bucket, associate it with an S3 Access Point, and transform objects during retrieval using AWS Lambda.

By addressing common issues, such as path errors and type mismatches, you can efficiently deploy your infrastructure and leverage AWS’s serverless capabilities.

---

This structured documentation should provide a clear and comprehensive overview of the process involved in deploying an S3 Object Lambda using AWS CDK with TypeScript. 

# Project Link - 
https://github.com/aws-samples/aws-cdk-examples/blob/main/typescript/s3-object-lambda/lib/s3-object-lambda-stack.ts

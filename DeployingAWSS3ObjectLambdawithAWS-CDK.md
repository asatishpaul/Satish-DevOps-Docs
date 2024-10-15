### Detailed Documentation: Deploying AWS S3 Object Lambda with AWS CDK

This document outlines the detailed steps to deploy an S3 Object Lambda using the AWS Cloud Development Kit (CDK), based on your current work history. We’ll cover the relevant AWS services, a deep dive into the TypeScript code structure, debugging issues you encountered, and a step-by-step guide to successfully deploying your S3 Object Lambda stack.

---

### Table of Contents

1. **Introduction to AWS S3 Object Lambda**
2. **Overview of the Project Setup**
3. **Explanation of the TypeScript Code**
   - AWS CDK Basics
   - S3 Bucket and Access Points
   - Lambda for Object Transformation
4. **Common Errors and Troubleshooting**
   - Asset Not Found Errors
5. **Step-by-Step Guide to Deploy**
   - Setting Up the Project
   - Resolving Build Errors
   - Deploying the CDK Stack
6. **Conclusion**

---

### 1. Introduction to AWS S3 Object Lambda

Amazon S3 Object Lambda allows you to process and transform data during retrieval from S3 using a Lambda function. Traditionally, you retrieve S3 objects directly from a bucket. However, with S3 Object Lambda, you can apply custom transformations (e.g., masking, filtering, format conversion) before delivering the content to the requester.

### 2. Overview of the Project Setup

The project’s primary goal is to set up an AWS S3 bucket, enable access to it through an S3 Access Point, and then use S3 Object Lambda to process the data during retrieval. The entire infrastructure is defined using AWS CDK in TypeScript.

### 3. Explanation of the TypeScript Code

The AWS CDK (Cloud Development Kit) allows you to define cloud infrastructure using modern programming languages like TypeScript.

Let’s break down the main components of the code:

#### 3.1. AWS CDK Basics

At the core of the project, we are using CDK’s **Stack** class to define resources in AWS:

```typescript
export class S3ObjectLambdaStack extends Stack {
  constructor(scope: Construct, id: string, props?: StackProps) {
    super(scope, id, props);
  }
}
```

- **Stack**: Represents a single unit of deployment.
- **Scope**: The parent construct of the stack, usually the app itself.
- **id**: A unique identifier for the stack.

#### 3.2. S3 Bucket and Access Points

The S3 bucket is the core storage component, and we are applying restrictive policies using Access Points to enforce fine-grained access control.

```typescript
const bucket = new s3.Bucket(this, 'example-bucket', {
  accessControl: s3.BucketAccessControl.BUCKET_OWNER_FULL_CONTROL,
  encryption: s3.BucketEncryption.S3_MANAGED,
  blockPublicAccess: s3.BlockPublicAccess.BLOCK_ALL
});
```

- **S3 Bucket**: This stores the objects.
- **Access Control**: Ensures the bucket owner has full control over the objects.
- **Block Public Access**: Blocks public access to ensure data security.

We then create an **S3 Access Point**, which is used to control access to the bucket more precisely than bucket policies.

```typescript
const accessPoint = `arn:aws:s3:${Aws.REGION}:${Aws.ACCOUNT_ID}:accesspoint/${S3_ACCESS_POINT_NAME}`;
```

This ensures only trusted services can access the bucket.

#### 3.3. Lambda for Object Transformation

A Lambda function is configured to process the objects being retrieved from the bucket:

```typescript
const retrieveTransformedObjectLambda = new lambda.Function(this, 'retrieveTransformedObjectLambda', {
  runtime: lambda.Runtime.NODEJS_20_X,
  handler: 'index.handler',
  code: lambda.Code.fromAsset('resources/retrieve-transformed-object-lambda')
});
```

- **Runtime**: Specifies Node.js version 20.x.
- **Handler**: Defines the entry point (`index.handler`), where the code execution begins.
- **Code**: Points to the location (`resources/retrieve-transformed-object-lambda`) where the Lambda code resides. This is the path that caused issues in the deployment (discussed later).

The Lambda is granted the necessary permissions to write the transformed response back:

```typescript
retrieveTransformedObjectLambda.addToRolePolicy(new iam.PolicyStatement({
  effect: iam.Effect.ALLOW,
  resources: ['*'],
  actions: ['s3-object-lambda:WriteGetObjectResponse']
}));
```

The Lambda will receive the S3 object, apply a transformation (such as masking data or changing format), and send the result to the requester.

---

### 4. Common Errors and Troubleshooting

During your work, you encountered the following error:

#### **Error: Cannot Find Asset**

The error occurred when running the CDK deploy command:

```bash
Error: Cannot find asset at /Users/satish/Desktop/Ironrim/s3-object-l-s/resources/retrieve-transformed-object-lambda
```

This error means that the Lambda code directory specified in the CDK stack (`resources/retrieve-transformed-object-lambda`) did not exist or was improperly referenced.

#### **Solution:**

1. **Check the Path**: Ensure that the `resources/retrieve-transformed-object-lambda` directory exists.
2. **Add the Required Files**: Inside the folder, ensure the presence of the Lambda handler file (`index.js` or `index.ts`).
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

### 5. Step-by-Step Guide to Deploy

#### 5.1. Setting Up the Project

To deploy the project, follow these steps:

1. **Install AWS CDK and Dependencies:**

   If you haven’t installed AWS CDK, use the following command:

   ```bash
   npm install -g aws-cdk
   ```

   Then, install project dependencies:

   ```bash
   npm install
   ```

2. **Check the Code Structure:**

   Ensure your Lambda function code is placed in the correct directory (`resources/retrieve-transformed-object-lambda`) and the TypeScript files are error-free.

3. **Build the Project:**

   ```bash
   npm run build
   ```

#### 5.2. Resolving Build Errors

While building the project, you encountered a type error:

```bash
error TS2724: '"../lib/s3-object-l-s-stack"' has no exported member named 'S3ObjectLSStack'. Did you mean 'S3ObjectLambdaStack'?
```

The issue was that you were importing the wrong stack name. The correct import should be:

```typescript
import { S3ObjectLambdaStack } from '../lib/s3-object-l-s-stack';
```

After fixing this error, you should be able to build without issues.

#### 5.3. Deploying the CDK Stack

Once the build is successful, deploy the stack:

```bash
cdk deploy
```

During the deployment, CDK will:
- Create an S3 bucket.
- Set up access points for the bucket.
- Deploy the Lambda function.
- Configure the S3 Object Lambda access point.

### 6. Conclusion

Deploying AWS S3 Object Lambda using AWS CDK simplifies infrastructure as code (IaC) and makes it easy to manage, deploy, and scale infrastructure. In this project, we learned how to set up an S3 bucket, associate it with an S3 Access Point, and transform objects during retrieval using AWS Lambda.

By addressing common issues like path errors and type mismatches, you can smoothly deploy your infrastructure and leverage the full potential of AWS’s serverless capabilities.


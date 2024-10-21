# Create AWS Database Security Group with CDKTF

## Table of Contents

1. [Introduction](#introduction)
2. [Project Structure](#project-structure)
3. [Required Files and Configurations](#required-files-and-configurations)
   - [1. main.ts](#1-maintts)
   - [2. package.json](#2-packagejson)
   - [3. cdktf.json](#3-cdktfjson)
   - [4. tsconfig.json](#4-tsconfigjson)
4. [Project Setup](#project-setup)
5. [Deployment Steps](#deployment-steps)
6. [Encountered Errors](#encountered-errors)
7. [Conclusion](#conclusion)

---

## 1. Introduction

This documentation provides a comprehensive guide to creating an AWS Security Group with specific ingress rules using CDKTF (Cloud Development Kit for Terraform). The project aims to define a security group for a database, allowing traffic from specific CIDR blocks, prefix lists, and other security groups.

---

## 2. Project Structure

The project consists of the following files:

```
aws-db-sg-cdktf/
├── cdktf.json
├── main.ts
├── package.json
└── tsconfig.json
```

---

## 3. Required Files and Configurations

### 1. `main.ts`

This TypeScript file contains the core logic for defining the AWS Security Group and its rules.

```typescript
import { Construct } from "constructs";
import { App, TerraformStack } from "cdktf";
import { AwsProvider } from "@cdktf/provider-aws"; 
import { SecurityGroup, SecurityGroupRule } from "@cdktf/provider-aws/lib/vpc"; 

class MyStack extends TerraformStack {
  constructor(scope: Construct, name: string) {
    super(scope, name);

    new AwsProvider(this, "AWS", {
      region: "eu-north-1", 
    });

    const securityGroup = new SecurityGroup(this, "db_security_group", {
      name: "db-security-group",
      description: "Security group for the database",
      vpcId: "vpc-0ff7a8c481a69cbce", 
    });

    // Rule for CIDR Blocks
    new SecurityGroupRule(this, "allow_cidr", {
      type: "ingress",
      fromPort: 3306, 
      toPort: 3306, 
      protocol: "tcp",
      cidrBlocks: ["10.0.0.0/24"], 
      securityGroupId: securityGroup.id,
    });

    // Use existing prefix list ID
    const prefixListId = "pl-09a7a195b2b65b22a"; // Your existing prefix list ID

    // Rule for allowing traffic from the prefix list
    new SecurityGroupRule(this, "allow_prefix_list", {
      type: "ingress",
      fromPort: 8083,
      toPort: 8083,
      protocol: "tcp",
      securityGroupId: securityGroup.id,
      prefixListIds: [prefixListId], // Reference the existing prefix list ID
    });

    // Rule for Destination Security Group
    new SecurityGroupRule(this, "allow_dest_security_group", {
      type: "ingress",
      fromPort: 8081,
      toPort: 8081,
      protocol: "tcp",
      securityGroupId: securityGroup.id, // Reference the same security group
      sourceSecurityGroupId: "sg-028cf6074bb942d5c",
    });

    // Rule for Self-Reference
    new SecurityGroupRule(this, "allow_self_reference", {
      type: "ingress",
      fromPort: 23,
      toPort: 23,
      protocol: "tcp",
      securityGroupId: securityGroup.id,
      cidrBlocks: ["10.0.0.0/24"],
    });
  }
}

const app = new App();
new MyStack(app, "aws-db-sg-cdktf");
app.synth();
```

### 2. `package.json`

This file lists the dependencies and scripts for the project.

```json
{
  "name": "aws-dbsec-group",
  "version": "1.0.0",
  "scripts": {
    "build": "tsc",
    "watch": "tsc --watch",
    "test": "jest",
    "deploy": "cdktf deploy",
    "synth": "cdktf synthesize"
  },
  "dependencies": {
    "@cdktf/provider-aws": "5.0.52",
    "cdktf": "0.9.4",
    "constructs": "10.4.2"
  },
  "devDependencies": {
    "@types/jest": "29.5.13",
    "@types/node": "22.7.7",
    "jest": "29.7.0",
    "jsii-rosetta": "5.0.33",
    "ts-jest": "29.2.5",
    "ts-node": "10.9.2",
    "typescript": "5.6.3"
  }
}
```

### 3. `cdktf.json`

This configuration file specifies the language and app settings for CDKTF.

```json
{
  "language": "typescript",
  "app": "npx ts-node main.ts",
  "projectId": "a3b655ca-3bfc-416d-b727-5598658a9f38",
  "terraformProviders": [],
  "terraformModules": [],
  "context": {
    "excludeStackIdFromLogicalIds": "true",
    "allowSepCharsInLogicalIds": "true"
  }
}
```

### 4. `tsconfig.json`

The TypeScript configuration file that defines the compiler options.

```json
{
  "compilerOptions": {
    "target": "es6",
    "module": "commonjs",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": [
    "**/*.ts"
  ],
  "exclude": [
    "node_modules"
  ]
}
```

---

## 4. Project Setup

1. **Install Dependencies**: Make sure to have Node.js and npm installed. Run the following command in your project directory to install the required dependencies:

   ```bash
   npm install
   ```

2. **Compile TypeScript**: Before deploying, compile the TypeScript code using:

   ```bash
   npm run build
   ```

---

## 5. Deployment Steps

1. **Initialize CDKTF**: Run the following command to initialize the backend and provider plugins:

   ```bash
   cdktf init
   ```

2. **Plan the Deployment**: Check what changes will be applied with:

   ```bash
   cdktf plan
   ```

3. **Deploy the Stack**: Finally, deploy the stack to create the resources in AWS:

   ```bash
   npm run deploy
   ```



---

# CDKTF Error Documentation

This document provides a detailed overview of common errors encountered while working with the Cloud Development Kit for Terraform (CDKTF) and their solutions.

## 1. **Dependency Conflicts**

### **Error Message:**
```
npm error ERESOLVE unable to resolve dependency tree
```

### **Description:**
This error occurs when there is a conflict between the versions of the dependencies specified in your `package.json` file. For example, if `@cdktf/provider-aws` requires a version of `cdktf` that is incompatible with the version specified in your project.

### **Solution:**
- **Check Versions**: Review the versions of your dependencies in `package.json`. Ensure they are compatible.
- **Use `--legacy-peer-deps`**: When installing dependencies, use the command:
  ```bash
  npm install --legacy-peer-deps
  ```
  This allows npm to bypass peer dependency checks.
- **Force Installation**: As a last resort, you can force the installation with:
  ```bash
  npm install --force
  ```

## 2. **TypeScript Compilation Errors**

### **Error Message:**
```
error TS2304: Cannot find name 'AwsProvider'.
```

### **Description:**
This error indicates that TypeScript cannot find the specified class or module. This could happen due to an incorrect import or missing package.

### **Solution:**
- **Check Imports**: Ensure that your imports are correct. For example, the import for `AwsProvider` should be:
  ```typescript
  import { AwsProvider } from "@cdktf/provider-aws";
  ```
- **Install Missing Packages**: If a required package is missing, install it using:
  ```bash
  npm install @cdktf/provider-aws
  ```

## 3. **Backend Configuration Changed**

### **Error Message:**
```
Error: Backend configuration changed
```

### **Description:**
This error occurs when there’s a change in the backend configuration of your Terraform project. Terraform needs to migrate the existing state to the new configuration.

### **Solution:**
- **Migrate State**: Run the following command to attempt an automatic migration:
  ```bash
  cdktf init -migrate-state
  ```
- **Reconfigure Backend**: If you don’t want to change the state, run:
  ```bash
  cdktf init -reconfigure
  ```

## 4. **Initializing in a Non-Empty Directory**

### **Error Message:**
```
ERROR: Cannot initialize a project in a non-empty directory
```

### **Description:**
This error occurs when trying to initialize a new CDKTF project in a directory that already contains files.

### **Solution:**
- **Use an Empty Directory**: Ensure that you are in an empty directory when running `cdktf init`. If necessary, create a new directory and navigate into it before initializing.

## 5. **Unknown Command-Line Arguments**

### **Error Message:**
```
Unknown arguments: m, i, g, r, a, t, e
```

### **Description:**
This error indicates that the command you are trying to run is not recognized. It usually occurs due to incorrect syntax.

### **Solution:**
- **Check Command Syntax**: Ensure that the command is typed correctly. For example, `cdktf init -migrate-state` is the correct command for migrating state.
- **Update CDKTF**: Ensure that you are using a compatible version of CDKTF. Sometimes, the syntax might change between versions.

## 6. **Installation Issues with Packages**

### **Error Message:**
```
npm error 404 Not Found
```

### **Description:**
This error indicates that npm is unable to find a package you are trying to install. This could be due to a typo in the package name.

### **Solution:**
- **Verify Package Names**: Double-check the spelling of the package name you are trying to install. For example, if you meant to install `constructs`, ensure it’s spelled correctly (not `contructs`).

## Conclusion

This documentation covers common errors encountered while working with CDKTF and provides potential solutions. If you encounter issues not covered in this document, consider checking the official [CDKTF documentation](https://developer.hashicorp.com/terraform/docs/cdktf) or seeking help from community forums.

---


## 7. Encountered Errors

### Error Message

```
Error: One of ['cidr_blocks', 'ipv6_cidr_blocks', 'self', 'source_security_group_id', 'prefix_list_ids'] must be set to create an AWS Security Group Rule
```

### Explanation

The error indicates that the `SecurityGroupRule` for `allow_dest_security_group` is missing the required parameters. In the CDKTF, when defining security group rules, at least one of the properties (`cidr_blocks`, `ipv6_cidr_blocks`, `self`, `source_security_group_id`, or `prefix_list_ids`) must be set.

### Resolution

To resolve the error, I updated the `allow_dest_security_group` rule to use the `sourceSecurityGroupId` parameter correctly, referencing the same security group as follows:

```typescript
// Rule for Destination Security Group
new SecurityGroupRule(this, "allow_dest_security_group", {
  type: "ingress",
  fromPort: 8081,
  toPort: 8081,
  protocol: "tcp",
  securityGroupId: securityGroup.id, // Correct reference
  sourceSecurityGroupId: "sg-028cf6074bb942d5c", // Source security group ID
});
```

After making this change, I re-ran the deployment process, and it successfully created the security group and its rules.

---

## 7. Conclusion

This documentation outlined the steps to set up and deploy an AWS Security Group using CDKTF, including the necessary configurations and the troubleshooting of encountered errors. By following the structured approach in this guide, you can efficiently manage AWS resources using Infrastructure as Code (IaC) practices. If you have any further questions or need assistance, feel free to reach out!

This documentation covers common errors encountered while working with CDKTF and provides potential solutions. If you encounter issues not covered in this document, consider checking the official [CDKTF documentation](https://developer.hashicorp.com/terraform/docs/cdktf) or seeking help from community forums.

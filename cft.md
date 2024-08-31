To find the details of AWS KMS keys in your AWS account, you can use the AWS Management Console, AWS CLI, or AWS SDKs. Below are the steps for each method:

### AWS Management Console
1. **Sign in to the AWS Management Console**.
2. **Navigate to the KMS Dashboard**:
   - In the console, go to **Services**.
   - Under **Security, Identity, & Compliance**, click on **Key Management Service (KMS)**.
3. **View Keys**:
   - You will see a list of your KMS keys. Click on a key to view its details, including its ARN, key policy, and usage permissions.

### AWS CLI
You can use the AWS CLI to list and describe your KMS keys.

1. **List all KMS keys**:
   ```sh
   aws kms list-keys --region us-east-2
   ```

2. **Describe a specific KMS key**:
   ```sh
   aws kms describe-key --key-id <key-id> --region us-east-2
   ```

   Replace `<key-id>` with the actual key ID or ARN.

### AWS SDK (Python example)
You can use the AWS SDK for Python (boto3) to list and describe your KMS keys.

1. **Install boto3**:
   ```sh
   pip install boto3
   ```

2. **List and describe KMS keys**:
   ```python
   import boto3

   # Initialize a session using Amazon KMS
   kms_client = boto3.client('kms', region_name='us-east-2')

   # List keys
   keys = kms_client.list_keys()
   print(keys)

   # Describe a specific key
   key_id = 'arn:aws:kms:us-east-2:774343953368:key/986b95bf-2904-4d89-a099-a60f89b02c5d'
   key_details = kms_client.describe_key(KeyId=key_id)
   print(key_details)
   ```

### Updated CloudFormation Template

Given the additional details you provided, here’s the updated CloudFormation template including KMS permissions:

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Resources:
  DevDataLakeIntegrationRole:
    Type: 'AWS::IAM::Role'
    Properties: 
      RoleName: 'DevDataLakeIntegrationRole'
      AssumeRolePolicyDocument: 
        Version: '2012-10-17'
        Statement: 
          - Effect: 'Allow'
            Principal: 
              Service: 's3.amazonaws.com'
            Action: 'sts:AssumeRole'

  DevDataLakePolicy:
    Type: 'AWS::IAM::Policy'
    Properties: 
      PolicyName: 'DevDataLakePolicy'
      Roles: 
        - !Ref DevDataLakeIntegrationRole
      PolicyDocument: 
        Version: '2012-10-17'
        Statement: 
          - Effect: 'Allow'
            Action: 
              - 's3:*'
            Resource: 
              - '*'
          - Effect: 'Allow'
            Action: 
              - 'kms:Encrypt'
              - 'kms:Decrypt'
            Resource: 
              - 'arn:aws:kms:us-east-2:774343953368:key/986b95bf-2904-4d89-a099-a60f89b02c5d'
```

### Explanation of Changes:
1. **Added KMS Permissions**: Included the `kms:Encrypt` and `kms:Decrypt` actions to the policy.
2. **Specified KMS Key Resource**: Provided the specific KMS key ARN in the policy statement.

Make sure to adjust the actions and resources based on your exact needs and security requirements.

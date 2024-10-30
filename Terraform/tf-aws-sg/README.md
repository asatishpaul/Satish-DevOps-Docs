# Terraform Configuration for AWS Security Group

This guide outlines how to set up an AWS Security Group using Terraform and address common errors that can arise during configuration. 

## Step 1: Configure AWS Provider

### Code

```hcl
provider "aws" {
  region = "eu-north-1" 
}
```

### Explanation

- **Provider Block**: The `provider "aws"` block specifies that we are using the AWS provider and sets the region to `eu-north-1`.
- **Purpose**: This tells Terraform to make calls to AWS services in the specified region.

## Step 2: Fetch VPC ID from AWS SSM Parameter Store

### Code

```hcl
data "aws_ssm_parameter" "vpc_id" {
  name = "/org/eu-north-1/vpc_id"
}
```

### Explanation

- **Data Source**: The `data "aws_ssm_parameter"` block fetches a parameter from AWS Systems Manager Parameter Store. In this case, it retrieves the VPC ID stored at the specified name.
- **Parameter Name**: You need to replace the name with the correct path where your VPC ID is stored in the SSM Parameter Store.

### Required Inputs

- **SSM Parameter Name**: Ensure the parameter `/org/eu-north-1/vpc_id` exists in your SSM Parameter Store. You can check this via the AWS Console under Systems Manager > Parameter Store.

## Step 3: Fetch VPC Details

### Code

```hcl
data "aws_vpc" "selected" {
  id = data.aws_ssm_parameter.vpc_id.value
}
```

### Explanation

- **Data Source**: The `data "aws_vpc"` block retrieves details of the VPC using the ID obtained from the previous step.
- **Usage of Parameter**: This allows us to reference the VPC in subsequent resource definitions, such as security groups.

## Step 4: Define the Security Group

### Code

```hcl
resource "aws_security_group" "aws_security_manual" {
  name        = var.sg_name
  description = var.sg_description
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
```

### Explanation

- **Resource Block**: The `resource "aws_security_group"` block defines the actual security group that will be created in AWS.
- **Attributes**:
  - `name`: The name of the security group (provided by a variable).
  - `description`: A description for the security group (also provided by a variable).
  - `vpc_id`: The VPC ID where the security group will reside, fetched from the SSM parameter.

### Required Inputs

- **Variables**: Ensure `sg_name` and `sg_description` are declared in your `variables.tf` file.

## Step 5: Add Egress Rules

### Code

```hcl
  dynamic "egress" {
    for_each = var.egress_rules_cidr
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
      description = egress.value.description
    }
  }
```

### Explanation

- **Dynamic Block**: The `dynamic "egress"` block iterates over a list of egress rules provided by `var.egress_rules_cidr`.
- **Structure**: Each egress rule is defined within the `content` block, using attributes like `from_port`, `to_port`, `protocol`, etc.

### Required Inputs

- **Egress Rules Variable**: Ensure `egress_rules_cidr` is declared in your `variables.tf` file and contains a list of objects.

## Step 6: Add Ingress Rules

### Code

```hcl
  dynamic "ingress" {
    for_each = var.ingress_rules_cidr
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }
}
```

### Explanation

- **Dynamic Block**: Similar to the egress block, the `dynamic "ingress"` block iterates over ingress rules provided by `var.ingress_rules_cidr`.
- **Structure**: Each ingress rule is defined similarly, specifying how to allow incoming traffic.

### Required Inputs

- **Ingress Rules Variable**: Ensure `ingress_rules_cidr` is declared in your `variables.tf` file and contains a list of objects.

---

# Common Errors and Solutions

## Error 1: Unsupported Block Type

### Encountered Error

```plaintext
Error: Unsupported block type

  on main.tf line 22:
  22:     dynamic "egress" {
```

### Explanation

This error occurs because Terraform does not recognize `dynamic` blocks at the point where they are defined. This typically happens if they are placed outside the expected context within the resource block.

### Solution

Ensure that `dynamic` blocks are directly nested inside the resource block. Here’s how to structure the `aws_security_group` resource correctly:

```hcl
resource "aws_security_group" "aws_security_manual" {
  name        = var.sg_name
  description = var.sg_description
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  dynamic "egress" {
    for_each = var.egress_rules_cidr
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
      description = egress.value.description
    }
  }

  dynamic "ingress" {
    for_each = var.ingress_rules_cidr
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }
}
```

## Error 2: Argument or Block Definition Required

### Encountered Error

```plaintext
Error: Argument or block definition required

  on main.tf line 45:
  45: }
```

### Explanation

This error indicates that Terraform expects additional content or a closing brace but finds nothing. This usually occurs due to a misalignment of curly braces or a missing block.

### Solution

Review your resource definitions to ensure that every opening `{` has a corresponding closing `}`. Ensure that the `dynamic` blocks are correctly closed within the resource block.

### Conclusion

By following these steps, you should be able to set up an AWS security group in Terraform successfully. Make sure to verify your variable definitions and ensure all blocks are nested correctly. If you encounter further issues, carefully read the error messages, as they often indicate the specific lines that need adjustment.

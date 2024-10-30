# Terraform Module for AWS Security Groups

This document provides a detailed overview of the steps taken to create a Terraform module for managing AWS security groups, including explanations of relevant files, errors encountered, and their solutions.

## Overview

The goal of this project is to create a reusable Terraform module for managing AWS security groups. The module allows for the dynamic addition of ingress and egress rules based on various configurations. This ensures that the security group can be easily adapted for different use cases.

## Directory Structure

The following directory structure is used in this project:

```
/terraform-project
|-- main.tf
|-- /modules
|   |-- /security_group
|       |-- main.tf
|       |-- variables.tf
```

### File: `main.tf`

This is the root Terraform configuration file that initializes the security group module.

```hcl
module "my_security_group" {
  source      = "./modules/security_group"
  sg_name     = "my-security-group"
  sg_description = "My security group for various applications"

  ingress = [
    {
      enable_network_access = true
      enable_internal_vpc_access = true
      enable_vpc_endpoint_access = ["logs", "execute-api"]
      custom = [
        {
          from_port     = 80
          to_port       = 80
          protocol      = "tcp"
          cidr_blocks   = ["0.0.0.0/0"]
          prefix_lists  = []
          security_groups = []
          description   = "Allow HTTP traffic"
        },
        {
          from_port     = 443
          to_port       = 443
          protocol      = "tcp"
          cidr_blocks   = ["0.0.0.0/0"]
          prefix_lists  = []
          security_groups = []
          description   = "Allow HTTPS traffic"
        }
      ]
    }
    // More ingress configurations can be added here
  ]

  egress = [
    {
      enable_network_access = true
      enable_internal_vpc_access = true
      enable_vpc_endpoint_access = ["logs", "execute-api"]
      custom = [
        {
          from_port     = 0
          to_port       = 0
          protocol      = "-1"  // All traffic
          cidr_blocks   = ["0.0.0.0/0"]
          prefix_lists  = []
          security_groups = []
          description   = "Allow all outbound traffic"
        }
      ]
    }
    // More egress configurations can be added here
  ]
}
```

### Explanation

- **Module Definition**: The `module` block is defined to call the `security_group` module.
- **Security Group Name and Description**: The module accepts parameters for the security group name and description.
- **Ingress and Egress Rules**: Ingress and egress configurations are defined as lists of objects. Each object can specify various parameters such as `from_port`, `to_port`, `protocol`, `cidr_blocks`, etc.

### File: `modules/security_group/main.tf`

This file contains the actual implementation of the security group resource using AWS provider.

```hcl
provider "aws" {
  region = "eu-north-1"
}

data "aws_ssm_parameter" "vpc_id" {
  name = "/ironrim/eu-north-1/vpc_id"
}

data "aws_vpc" "selected" {
  id = data.aws_ssm_parameter.vpc_id.value
}

resource "aws_security_group" "aws_security_manual" {
  name        = var.sg_name
  description = var.sg_description
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  # Ingress Rules
  dynamic "ingress" {
    for_each = flatten([for rule in var.ingress : [
      for custom_rule in rule.custom : {
        enable = rule.enable_network_access || rule.enable_internal_vpc_access || length(rule.enable_vpc_endpoint_access) > 0 ? true : false
        from_port = custom_rule.from_port
        to_port = custom_rule.to_port
        protocol = custom_rule.protocol
        cidr_blocks = custom_rule.cidr_blocks
        prefix_lists = custom_rule.prefix_lists
        security_groups = custom_rule.security_groups
        description = custom_rule.description
      } if rule.enable_network_access || rule.enable_internal_vpc_access || length(rule.enable_vpc_endpoint_access) > 0
    ]])

    content {
      from_port      = ingress.value.from_port
      to_port        = ingress.value.to_port
      protocol       = ingress.value.protocol
      cidr_blocks    = ingress.value.cidr_blocks
      prefix_list_ids = ingress.value.prefix_lists
      security_groups = ingress.value.security_groups
      description    = ingress.value.description
    }
  }

  # Egress Rules
  dynamic "egress" {
    for_each = flatten([for rule in var.egress : [
      for custom_rule in rule.custom : {
        enable = rule.enable_network_access || rule.enable_internal_vpc_access || length(rule.enable_vpc_endpoint_access) > 0 ? true : false
        from_port = custom_rule.from_port
        to_port = custom_rule.to_port
        protocol = custom_rule.protocol
        cidr_blocks = custom_rule.cidr_blocks
        prefix_lists = custom_rule.prefix_lists
        security_groups = custom_rule.security_groups
        description = custom_rule.description
      } if rule.enable_network_access || rule.enable_internal_vpc_access || length(rule.enable_vpc_endpoint_access) > 0
    ]])

    content {
      from_port      = egress.value.from_port
      to_port        = egress.value.to_port
      protocol       = egress.value.protocol
      cidr_blocks    = egress.value.cidr_blocks
      prefix_list_ids = egress.value.prefix_lists
      security_groups = egress.value.security_groups
      description    = egress.value.description
    }
  }
}
```

### Explanation

- **Provider Configuration**: The AWS provider is configured to use the `eu-north-1` region.
- **Data Sources**: Data sources are used to retrieve the VPC ID from AWS SSM Parameter Store.
- **Security Group Resource**: The `aws_security_group` resource is defined. Dynamic blocks for `ingress` and `egress` are used to iterate over provided rules.

### File: `modules/security_group/variables.tf`

This file defines the input variables used by the `security_group` module.

```hcl
variable "sg_name" {
  description = "The name of the security group"
  type        = string
  default     = "my-security-group"
}

variable "sg_description" {
  description = "Description of the security group"
  type        = string
  default     = "Security group for my application"
}

variable "ingress" {
  description = "List of ingress rule configurations"
  type = list(object({
    enable_network_access = optional(bool)
    enable_internal_vpc_access = optional(bool)
    enable_vpc_endpoint_access = optional(list(string))
    custom = optional(list(object({
      from_port     = number
      to_port       = number
      protocol      = string
      cidr_blocks   = optional(list(string))
      prefix_lists  = optional(list(string))
      security_groups = optional(list(string))
      description   = string
    })))
  }))
}

variable "egress" {
  description = "List of egress rule configurations"
  type = list(object({
    enable_network_access = optional(bool)
    enable_internal_vpc_access = optional(bool)
    enable_vpc_endpoint_access = optional(list(string))
    custom = optional(list(object({
      from_port     = number
      to_port       = number
      protocol      = string
      cidr_blocks   = optional(list(string))
      prefix_lists  = optional(list(string))
      security_groups = optional(list(string))
      description   = string
    })))
  }))
}
```

### Explanation

- **Variable Definitions**: Input variables for security group name, description, ingress, and egress configurations are defined.
- **Types**: Variables are typed to ensure that the correct structure is used when passing data into the module.

## Errors Encountered

During the implementation of the Terraform module, several errors were encountered. Below are the notable errors and their corresponding solutions:

### Error 1: Invalid value for input variable

```plaintext
│ Error: Invalid value for input variable
│ 
│   on terraform.tfvars line 31:
│   31: egress_rules_destination_security_group = [
│   32:   {
│   33:     from_port = 3306
│   34:     to_port = 3306
│   35:     protocol = "tcp"
│   36:     destination_security = "sg-015938f1cf0c6ca31"  
│   37:     description = "Allow MySQL traffic"
│   38:   }
│   39: ]
│ 
│ The given value is not suitable for var.egress_rules_destination_security_group declared at
│ variables.tf:60,1-51: element 0: attribute "destination_security_group" is required.
```

#### Solution

The error was caused by using the wrong attribute name in the variable definition. The attribute `destination_security` should be `destination_security_group`. Ensure that the variable definitions in `variables.tf` match the expected structure.

### Error 2: Invalid value for input variable (Ingress Rules)

```plaintext
│ Error: Invalid value for input variable
│ 
│   on terraform.tfvars line 41:
│   41: ingress_rules_destination_security_group = [
│   42:   {
│   43:     from_port = 8080
│   44:     to

_port = 8080
│   45:     protocol = "tcp"
│   46:     source_security = ["sg-015938f1cf0c6ca31"]  
│   47:     description = "Allow traffic from SonarQube"
│   48:   }
│   49: ]
│ 
│ The given value is not suitable for var.ingress_rules_destination_security_group declared at
│ variables.tf:71,1-52: element 0: attribute "source_security_group" is required.
```

#### Solution

This error occurred due to a missing required attribute in the ingress rule configuration. Change `source_security` to `source_security_group` to ensure consistency with the variable definition.

## Conclusion

This documentation provides a comprehensive overview of the Terraform module for managing AWS security groups, including the necessary files, configurations, and solutions to encountered errors. By structuring the security group rules dynamically, this approach allows for scalability and ease of management in a cloud environment.

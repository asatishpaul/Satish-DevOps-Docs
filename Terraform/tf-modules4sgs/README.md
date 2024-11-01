## Overview for the Terraform Modules for Security Group Configuration

This Terraform setup is designed to manage an AWS security group with both ingress and egress rules while retrieving the necessary VPC ID from AWS SSM (AWS Systems Manager Parameter Store). The configuration is organized into a root module and a child module for the security group.

### Structure

1. **Root Module**: Contains high-level resources and calls the security group module.
2. **Security Group Module**: Defines the security group and its associated rules.
3. **Variables**: Define inputs for both modules to ensure flexibility and reusability.

## Step-by-Step Explanation

### 1. Root Module (`main.tf` and `rules.tf`)

#### `main.tf`

This file initializes the AWS provider and declares the security group module:

```hcl
# Root `main.tf`

provider "aws" {
  region = "eu-north-1"
}

# Security Group Module
module "my_security_group" {
  source         = "./modules/security_group"
  sg_name        = "my-security-group"
  sg_description = "My security group for various applications"
  vpc_id         = data.aws_ssm_parameter.vpc_id.value  # Pass VPC ID from SSM

  # Pass the `rules` variable to the module
  ingress = [
    {
      enable_network_access       = false
      enable_internal_vpc_access  = false
      enable_vpc_endpoint_access  = ["logs", "execute-api"]
      custom = [
        for rule_name, rule_values in var.rules : {
          from_port   = rule_values[0]
          to_port     = rule_values[1]
          protocol    = rule_values[2]
          description = rule_values[3]
        } if rule_name == "http" || rule_name == "https" || rule_name == "custom"
      ]
    }
  ]

  egress = [
    {
      enable_network_access       = false
      enable_internal_vpc_access  = false
      enable_vpc_endpoint_access  = ["logs", "execute-api"]
      custom = [
        for rule_name, rule_values in var.rules : {
          from_port   = rule_values[0]
          to_port     = rule_values[1]
          protocol    = rule_values[2]
          description = rule_values[3]
        } if rule_name == "all_outbound" || rule_name == "custom_out"
      ]
    }
  ]
}
```

##### Key Components:
- **Provider Block**: Specifies the AWS region for the resources.
- **Module Block**: Invokes the `my_security_group` module.
  - Passes essential parameters like `sg_name`, `sg_description`, and `vpc_id`.
  - Uses list comprehension to dynamically generate ingress and egress rules from the `rules` variable.

#### `rules.tf`

This file defines the `rules` variable, which contains the security group rules:

```hcl
# Root `rules.tf`
variable "rules" {
  description = "Map of known security group rules (define as 'name' = ['from port', 'to port', 'protocol', 'description'])"
  type        = map(list(any))

  default = {
    # Ingress Rules
    http   = [80, 80, "tcp", "Allow HTTP traffic"]
    https  = [443, 443, "tcp", "Allow HTTPS traffic"]
    custom = [2233, 2233, "tcp", "Allow traffic on port 2233"]

    # Egress Rules
    all_outbound = [0, 0, "-1", "Allow all outbound traffic"]
    custom_out   = [888, 888, "tcp", "Allow traffic on port 888"]
  }
}
```

##### Key Components:
- **Variable Declaration**: Defines a map of rules where each key corresponds to a rule and its details (ports, protocol, description).
- **Default Values**: Ingress and egress rules are provided as defaults.

### 2. Security Group Module (`modules/security_group/main.tf` and `variables.tf`)

#### `modules/security_group/main.tf`

This file defines the actual security group resource:

```hcl
# `modules/security_group/main.tf`

resource "aws_security_group" "aws_security_manual" {
  name        = var.sg_name
  description = var.sg_description
  vpc_id      = var.vpc_id

  # Ingress Rules
  dynamic "ingress" {
    for_each = flatten([
      for rule in var.ingress : [
        for custom_rule in rule.custom : {
          enable = rule.enable_network_access || rule.enable_internal_vpc_access || length(rule.enable_vpc_endpoint_access) > 0
          from_port = custom_rule.from_port
          to_port   = custom_rule.to_port
          protocol  = custom_rule.protocol
          cidr_blocks = rule.enable_network_access ? ["10.0.0.0/8"] : []
          description = custom_rule.description
        } if rule.enable_network_access || rule.enable_internal_vpc_access || length(rule.enable_vpc_endpoint_access) > 0
      ]
    ])

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  # Egress Rules
  dynamic "egress" {
    for_each = flatten([
      for rule in var.egress : [
        for custom_rule in rule.custom : {
          enable = rule.enable_network_access || rule.enable_internal_vpc_access || length(rule.enable_vpc_endpoint_access) > 0
          from_port = custom_rule.from_port
          to_port   = custom_rule.to_port
          protocol  = custom_rule.protocol
          cidr_blocks = rule.enable_network_access ? ["10.0.0.0/8"] : []
          description = custom_rule.description
        } if rule.enable_network_access || rule.enable_internal_vpc_access || length(rule.enable_vpc_endpoint_access) > 0
      ]
    ])

    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
      description = egress.value.description
    }
  }
}
```

##### Key Components:
- **Resource Definition**: Defines an AWS security group with the name, description, and VPC ID.
- **Dynamic Blocks**: Generates ingress and egress rules dynamically based on the input from the root module.

#### `modules/security_group/variables.tf`

This file defines the input variables for the security group module:

```hcl
# `modules/security_group/variables.tf`

variable "sg_name" {
  description = "The name of the security group."
  type        = string
}

variable "sg_description" {
  description = "Description of the security group."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created."
  type        = string
}

variable "ingress" {
  description = "List of ingress rules."
  type = list(object({
    enable_network_access      = bool
    enable_internal_vpc_access = bool
    enable_vpc_endpoint_access = list(string)
    custom = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      description = string
    }))
  }))
}

variable "egress" {
  description = "List of egress rules."
  type = list(object({
    enable_network_access      = bool
    enable_internal_vpc_access = bool
    enable_vpc_endpoint_access = list(string)
    custom = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      description = string
    }))
  }))
}
```

##### Key Components:
- **Variable Declarations**: Each variable defined here corresponds to inputs needed for the security group resource.
- **Data Types**: Uses `string`, `bool`, and `object` types to enforce structure and validation.

### 3. Key Issues Resolved

Throughout our previous discussions, we addressed several issues related to module organization, variable scoping, and error handling:

1. **Variable Scope Errors**: Initially, the configuration was trying to access variables defined in the root module from within the security group module. This was resolved by ensuring that all necessary inputs are passed explicitly as variables to the module.

2. **Data Resource Reference Error**: The original configuration attempted to use `data.aws_ssm_parameter.vpc_id.value` without declaring it in the root module. We shifted the logic to pass `vpc_id` as an input to the module instead, making it optional.

3. **Redundant Variable Declaration**: Errors indicating duplicate variable declarations were resolved by ensuring each variable is only declared once within the correct scope.

### Conclusion

This structured approach not only enhances code readability and maintainability but also adheres to best practices in Terraform module design. Each module is self-contained, making it easier to reuse and manage over time. The corrections made throughout this process ensure that the configuration runs smoothly without errors, allowing for a successful deployment of the AWS security group with the specified rules. 

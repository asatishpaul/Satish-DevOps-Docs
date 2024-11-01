# Root `main.tf`

provider "aws" {
  region = "eu-north-1"
}

# Retrieve the VPC ID from SSM
data "aws_ssm_parameter" "vpc_id" {
  name = "/ironrim/eu-north-1/vpc_id"
}

# Security Group Module
module "my_security_group" {
  source         = "./modules/security_group"
  sg_name        = "my-security-group"
  sg_description = "My security group for various applications"
  vpc_id         = data.aws_ssm_parameter.vpc_id.value

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

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
    name = var.sg_name
    description = var.sg_description
    vpc_id = data.aws_ssm_parameter.vpc_id.value

    dynamic "egress" {
        for_each = var.egress_rules_cidr
        content {
          from_port = egress.value.from_port
          to_port = egress.value.to_port
          protocol = egress.value.protocol
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

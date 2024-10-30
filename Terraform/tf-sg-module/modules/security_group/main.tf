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

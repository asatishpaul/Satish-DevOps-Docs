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
          cidr_blocks = rule.enable_network_access ? ["10.0.0.0/8"] : []  # Conditional CIDR block
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
          cidr_blocks = rule.enable_network_access ? ["10.0.0.0/8"] : []  # Conditional CIDR block
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

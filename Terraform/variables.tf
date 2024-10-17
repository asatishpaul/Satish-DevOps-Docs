variable "sg_name" {
    description = "my-security-group"
    type = string
    default = "my-security-group"
}

variable "sg_description" {
    description = "value"
    type = string
    default = "my-security-group"
}

variable "egress_rules_cidr" {
    description = "Egress rules for CIDR blocks"
    type = list(object({
      from_port = number
      to_port = number
      protocol = string
      cidr_blocks = list(string)
      description = string
    }))
    default = [ {
      from_port = 0
      to_port = 0
      protocol = "tcp"
      cidr_blocks = [ "0.0.0.0/0" ]
      description = "Allow SSH"
    } ]
}

variable "ingress_rules_cidr" {
  description = "Ingress rules for CIDR blocks"
  type        = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow SSH"
    }
  ]
}

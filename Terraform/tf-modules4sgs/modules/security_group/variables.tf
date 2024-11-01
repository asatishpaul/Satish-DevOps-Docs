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

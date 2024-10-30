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

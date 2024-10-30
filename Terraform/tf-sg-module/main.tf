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

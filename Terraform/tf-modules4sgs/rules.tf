# Root `rules.tf`
variable "rules" {
  description = "Map of known security group rules (define as 'name' = ['from port', 'to port', 'protocol', 'description'])"
  type        = map(list(any))

  default = {
    # Ingress Rules
    http   = [80, 80, "tcp", "Allow HTTP traffic"]
    https  = [443, 443, "tcp", "Allow HTTPS traffic"]
    custom = [2233, 2233, "tcp", "Allow traffic on port 2233"]  # New inbound rule

    # Egress Rules
    all_outbound = [0, 0, "-1", "Allow all outbound traffic"]
    custom_out   = [888, 888, "tcp", "Allow traffic on port 888"]  # New outbound rule
  }
}

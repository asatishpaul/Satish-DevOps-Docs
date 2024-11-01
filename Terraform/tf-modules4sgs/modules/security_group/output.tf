output "security_group_id" {
  description = "The ID of the security group created"
  value       = aws_security_group.aws_security_manual.id
}

output "security_group_name" {
  description = "The name of the security group created"
  value       = aws_security_group.aws_security_manual.name
}

output "vpc_id" {
  description = "The ID of the VPC associated with the security group"
  value       = aws_security_group.aws_security_manual.vpc_id
}

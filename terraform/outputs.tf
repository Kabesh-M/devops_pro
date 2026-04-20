output "vpc_id" {
  description = "Provisioned VPC ID"
  value       = aws_vpc.devops.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "web_security_group_id" {
  description = "Security group for web workloads"
  value       = aws_security_group.web.id
}

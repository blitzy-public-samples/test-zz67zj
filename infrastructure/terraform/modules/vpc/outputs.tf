# AWS Provider Version: 5.0.0

# Requirement addressed: Infrastructure as Code (Technical Specification/7.4.3 Security Architecture)
# This file defines output variables for the VPC module, exposing key attributes of the AWS Virtual 
# Private Cloud (VPC) and its associated resources for use in other modules.

output "vpc_id" {
  description = "The ID of the created VPC."
  value       = aws_vpc.main.id
  sensitive   = false
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets."
  value       = aws_subnet.public.*.id
  sensitive   = false
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets."
  value       = aws_subnet.private.*.id
  sensitive   = false
}

output "availability_zones" {
  description = "The availability zones used for the subnets."
  value       = data.aws_availability_zones.available.names
  sensitive   = false
}
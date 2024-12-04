# AWS Provider Version: 5.0.0

# Requirement addressed: Infrastructure as Code (Technical Specification/7.4.3 Security Architecture)
# This file defines the Terraform outputs that expose key information about the provisioned 
# AWS infrastructure resources for the Dog Walker Booking platform.

# VPC Output
output "vpc_id" {
  description = "The ID of the provisioned VPC."
  value       = local.vpc_id
  sensitive   = false
}

# EKS Cluster Output
output "eks_cluster_endpoint" {
  description = "The endpoint of the provisioned EKS cluster."
  value       = module.eks.eks_cluster_endpoint
  sensitive   = false
}

# RDS Instance Output
output "rds_instance_endpoint" {
  description = "The endpoint of the provisioned RDS instance."
  value       = module.rds.rds_instance_endpoint
  sensitive   = false
}

# S3 Bucket Output
output "s3_bucket_name" {
  description = "The name of the provisioned S3 bucket."
  value       = var.s3_bucket_name
  sensitive   = false
}

# ElastiCache Cluster Output
output "elasticache_cluster_id" {
  description = "The ID of the provisioned ElastiCache cluster."
  value       = local.elasticache_cluster_id
  sensitive   = false
}

# Additional metadata outputs
output "infrastructure_environment" {
  description = "The environment in which the infrastructure is deployed."
  value       = var.environment
  sensitive   = false
}

output "aws_region" {
  description = "The AWS region where the infrastructure is deployed."
  value       = var.aws_region
  sensitive   = false
}
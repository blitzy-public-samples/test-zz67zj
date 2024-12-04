# Requirement addressed: Production Environment Configuration (Technical Specification/7.4.3 Security Architecture)
# This file defines environment-specific variables for provisioning AWS resources in the production environment.

# AWS Region Configuration
aws_region = "us-east-1"

# Environment Configuration
environment = "production"

# VPC Configuration
vpc_cidr = "10.0.0.0/16"

# EKS Cluster Configuration
eks_cluster_name = "dogwalker-prod-cluster"

# RDS Configuration
rds_instance_type = "db.t3.medium"

# ElastiCache Configuration
elasticache_node_type = "cache.t3.medium"

# S3 Configuration
s3_bucket_name = "dogwalker-prod-bucket"
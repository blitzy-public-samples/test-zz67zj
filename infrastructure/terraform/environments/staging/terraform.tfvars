# Requirement addressed: Environment-Specific Configuration (Technical Specification/7.4.3 Security Architecture)
# This file defines environment-specific variables for provisioning AWS infrastructure resources in the staging environment.

# AWS Region Configuration
aws_region = "us-west-2"

# Environment Configuration
environment = "staging"

# VPC Configuration
vpc_cidr = "10.1.0.0/16"

# EKS Cluster Configuration
eks_cluster_name = "dogwalker-staging-eks"

# RDS Configuration
rds_instance_type = "db.t3.medium"

# ElastiCache Configuration
elasticache_node_type = "cache.t3.micro"

# S3 Configuration
s3_bucket_name = "dogwalker-staging-bucket"
# AWS Provider Version: 5.0.0

# Human Tasks:
# 1. Ensure AWS credentials are properly configured
# 2. Review and adjust resource configurations for each environment
# 3. Verify all required variables are set in terraform.tfvars
# 4. Ensure proper network CIDR ranges are configured
# 5. Review and configure backup retention periods
# 6. Set up proper monitoring and alerting thresholds

# Requirement addressed: Infrastructure as Code (Technical Specification/7.4.3 Security Architecture)
# This file orchestrates the provisioning of AWS infrastructure resources for the Dog Walker Booking platform,
# implementing secure, scalable, and maintainable infrastructure using Terraform.

# Configure Terraform settings
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.0.0"
    }
  }

  backend "s3" {
    # Backend configuration should be provided during initialization
  }
}

# Configure AWS Provider
provider "aws" {
  region = var.aws_region
}

# Local variables for resource naming and tagging
locals {
  vpc_id                = module.vpc.vpc_id
  elasticache_cluster_id = module.elasticache.elasticache_cluster_id
  
  common_tags = {
    Environment = var.environment
    Project     = "DogWalker"
    ManagedBy   = "Terraform"
  }
}

# VPC Module
module "vpc" {
  source = "./vpc"

  cidr_block = var.vpc_cidr
  environment = var.environment

  tags = local.common_tags
}

# EKS Module
module "eks" {
  source = "./eks"

  cluster_name = var.eks_cluster_name
  vpc_id       = local.vpc_id
  environment  = var.environment

  depends_on = [module.vpc]
  tags = local.common_tags
}

# RDS Module
module "rds" {
  source = "./rds"

  instance_type = var.rds_instance_type
  vpc_id        = local.vpc_id
  environment   = var.environment

  depends_on = [module.vpc]
  tags = local.common_tags
}

# ElastiCache Module
module "elasticache" {
  source = "./elasticache"

  node_type    = var.elasticache_node_type
  vpc_id       = local.vpc_id
  environment  = var.environment

  depends_on = [module.vpc]
  tags = local.common_tags
}

# DocumentDB Module
module "documentdb" {
  source = "./documentdb"

  vpc_id      = local.vpc_id
  environment = var.environment

  depends_on = [module.vpc]
  tags = local.common_tags
}

# S3 Module
module "s3" {
  source = "./s3"

  bucket_name  = var.s3_bucket_name
  environment  = var.environment

  tags = local.common_tags
}

# CloudFront Module
module "cloudfront" {
  source = "./cloudfront"

  s3_bucket_name = module.s3.bucket_name
  environment    = var.environment

  depends_on = [module.s3]
  tags = local.common_tags
}

# Route53 Module
module "route53" {
  source = "./route53"

  environment = var.environment

  depends_on = [module.cloudfront]
  tags = local.common_tags
}

# ACM Module
module "acm" {
  source = "./acm"

  environment = var.environment

  depends_on = [module.route53]
  tags = local.common_tags
}

# IAM Module
module "iam" {
  source = "./iam"

  environment = var.environment
  tags = local.common_tags
}

# KMS Module
module "kms" {
  source = "./kms"

  environment = var.environment
  tags = local.common_tags
}

# WAF Module
module "waf" {
  source = "./waf"

  environment = var.environment
  cloudfront_distribution_arn = module.cloudfront.distribution_arn

  depends_on = [module.cloudfront]
  tags = local.common_tags
}

# CloudWatch Module
module "cloudwatch" {
  source = "./cloudwatch"

  environment = var.environment
  vpc_id      = local.vpc_id

  depends_on = [
    module.eks,
    module.rds,
    module.elasticache,
    module.documentdb
  ]
  tags = local.common_tags
}

# Data source for current AWS region
data "aws_region" "current" {}

# Data source for current AWS account ID
data "aws_caller_identity" "current" {}

# Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = local.vpc_id
}

output "eks_cluster_endpoint" {
  description = "The endpoint for the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "rds_instance_endpoint" {
  description = "The endpoint for the RDS instance"
  value       = module.rds.instance_endpoint
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = module.s3.bucket_name
}

output "elasticache_cluster_id" {
  description = "The ID of the ElastiCache cluster"
  value       = local.elasticache_cluster_id
}
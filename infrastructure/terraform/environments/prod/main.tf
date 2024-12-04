# AWS Provider Version: 5.0.0

# Human Tasks:
# 1. Ensure AWS credentials are properly configured
# 2. Review and adjust resource configurations for production environment
# 3. Verify all required variables are set in terraform.tfvars
# 4. Ensure proper network CIDR ranges are configured
# 5. Review and configure backup retention periods
# 6. Set up proper monitoring and alerting thresholds

# Requirement addressed: Production Environment Setup (Technical Specification/7.4.3 Security Architecture)
# This file defines and provisions AWS infrastructure resources for the production environment
# using Terraform for scalability, security, and maintainability.

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

# Variables
variable "aws_region" {
  description = "AWS region for infrastructure deployment"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "dogwalker-prod"
}

variable "rds_instance_type" {
  description = "Instance type for RDS"
  type        = string
  default     = "db.r5.2xlarge"
}

variable "elasticache_node_type" {
  description = "Node type for ElastiCache"
  type        = string
  default     = "cache.r5.large"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "dogwalker-prod-assets"
}

# Local variables for resource naming and tagging
locals {
  common_tags = {
    Environment = var.environment
    Project     = "DogWalker"
    ManagedBy   = "Terraform"
  }
}

# VPC Module
module "vpc" {
  source = "../../aws/vpc"

  cidr_block  = var.vpc_cidr
  environment = var.environment

  tags = local.common_tags
}

# EKS Module
module "eks" {
  source = "../../aws/eks"

  cluster_name = var.eks_cluster_name
  vpc_id       = module.vpc.vpc_id
  environment  = var.environment

  depends_on = [module.vpc]
  tags       = local.common_tags
}

# RDS Module
module "rds" {
  source = "../../aws/rds"

  instance_type = var.rds_instance_type
  vpc_id        = module.vpc.vpc_id
  environment   = var.environment

  depends_on = [module.vpc]
  tags       = local.common_tags
}

# ElastiCache Module
module "elasticache" {
  source = "../../aws/elasticache"

  node_type   = var.elasticache_node_type
  vpc_id      = module.vpc.vpc_id
  environment = var.environment

  depends_on = [module.vpc]
  tags       = local.common_tags
}

# DocumentDB Module
module "documentdb" {
  source = "../../aws/documentdb"

  vpc_id      = module.vpc.vpc_id
  environment = var.environment

  depends_on = [module.vpc]
  tags       = local.common_tags
}

# S3 Module
module "s3" {
  source = "../../aws/s3"

  bucket_name = var.s3_bucket_name
  environment = var.environment

  tags = local.common_tags
}

# CloudFront Module
module "cloudfront" {
  source = "../../aws/cloudfront"

  s3_bucket_name = module.s3.bucket_name
  environment    = var.environment

  depends_on = [module.s3]
  tags       = local.common_tags
}

# Route53 Module
module "route53" {
  source = "../../aws/route53"

  vpc_id      = module.vpc.vpc_id
  environment = var.environment

  depends_on = [module.cloudfront]
  tags       = local.common_tags
}

# ACM Module
module "acm" {
  source = "../../aws/acm"

  vpc_id      = module.vpc.vpc_id
  environment = var.environment

  depends_on = [module.route53]
  tags       = local.common_tags
}

# IAM Module
module "iam" {
  source = "../../aws/iam"

  environment = var.environment
  tags        = local.common_tags
}

# KMS Module
module "kms" {
  source = "../../aws/kms"

  environment = var.environment
  tags        = local.common_tags
}

# WAF Module
module "waf" {
  source = "../../aws/waf"

  environment = var.environment
  tags        = local.common_tags
}

# CloudWatch Module
module "cloudwatch" {
  source = "../../aws/cloudwatch"

  environment = var.environment
  vpc_id      = module.vpc.vpc_id

  depends_on = [
    module.eks,
    module.rds,
    module.elasticache,
    module.documentdb
  ]
  tags = local.common_tags
}

# Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
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
  value       = module.elasticache.cluster_id
}
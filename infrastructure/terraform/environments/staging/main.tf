# AWS Provider Version: 5.0.0
# Provider configuration for staging environment

# Human Tasks:
# 1. Ensure AWS credentials are properly configured
# 2. Verify VPC CIDR ranges don't conflict with other environments
# 3. Review and adjust resource sizing for staging environment needs
# 4. Configure AWS KMS keys for encryption
# 5. Set up appropriate IAM roles and policies

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.0.0"
    }
  }

  backend "s3" {
    # Configure your Terraform state backend
    bucket = "dogwalker-terraform-state"
    key    = "staging/terraform.tfstate"
    region = "us-east-1"
  }
}

# Provider configuration
provider "aws" {
  region = var.region
}

# Local variables
locals {
  environment = var.environment
  common_tags = {
    Environment = local.environment
    ManagedBy   = "terraform"
    Project     = "dog-walker-app"
  }
}

# VPC Module
# Requirement addressed: Infrastructure as Code (9.5 DEVELOPMENT & DEPLOYMENT)
module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr     = "10.1.0.0/16"  # Staging VPC CIDR
  environment  = local.environment

  providers = {
    aws = aws
  }
}

# RDS Module
# Requirement addressed: Staging Environment Infrastructure (7.4.2 Deployment Architecture)
module "rds" {
  source = "../../modules/rds"

  db_instance_identifier = "dogwalker-staging-db"
  db_engine             = "postgres"
  db_engine_version     = "15.2"
  db_instance_class     = "db.t3.medium"
  db_allocated_storage  = "50"
  db_username           = "admin"
  db_password           = "StrongPassword123!"  # Should be retrieved from secrets management
  
  db_subnet_group_name    = "staging-db-subnet"
  vpc_security_group_ids  = [module.vpc.security_group_ids]
  multi_az               = false
  storage_encrypted      = true

  providers = {
    aws = aws
  }
}

# EKS Module
# Requirement addressed: Staging Environment Infrastructure (7.4.2 Deployment Architecture)
module "eks-cluster" {
  source = "../../modules/eks-cluster"

  cluster_name         = "dogwalker-staging-cluster"
  kubernetes_version   = "1.27"
  role_arn            = "arn:aws:iam::123456789012:role/eks-cluster-role"
  node_role_arn       = "arn:aws:iam::123456789012:role/eks-node-role"
  
  subnet_ids          = [module.vpc.public_subnet_ids, module.vpc.private_subnet_ids]
  security_group_ids  = [module.vpc.security_group_ids]
  
  node_group_scaling_config = {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }
  
  node_instance_types = ["t3.medium"]
  node_disk_size     = 50
  capacity_type      = "ON_DEMAND"

  providers = {
    aws = aws
  }
}

# Variables
variable "environment" {
  description = "Specifies the environment for the Terraform configuration."
  type        = string
  default     = "staging"
}

variable "region" {
  description = "Specifies the AWS region for the staging environment."
  type        = string
  default     = "us-east-1"
}

# Outputs
# Requirement addressed: Infrastructure as Code (9.5 DEVELOPMENT & DEPLOYMENT)
output "eks_cluster_id" {
  description = "The ID of the EKS cluster for the staging environment."
  value       = module.eks-cluster.cluster_id
}

output "rds_endpoint" {
  description = "The endpoint of the RDS instance for the staging environment."
  value       = module.rds.db_instance_endpoint
}

output "vpc_id" {
  description = "The ID of the VPC for the staging environment."
  value       = module.vpc.vpc_id
}
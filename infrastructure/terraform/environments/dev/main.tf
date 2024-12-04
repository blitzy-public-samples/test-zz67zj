# AWS Provider Version: 5.0.0
# This file defines the main Terraform configuration for the development environment

# Human Tasks:
# 1. Ensure AWS credentials are properly configured
# 2. Verify that the specified AWS region is appropriate for development
# 3. Review and adjust resource sizing for development needs
# 4. Confirm that all required IAM roles and policies are in place
# 5. Validate CIDR ranges don't conflict with existing networks

# Requirement addressed: Development Environment Configuration (Technical Specification/7.4.3 Security Architecture)
# This configuration provisions AWS infrastructure resources specific to the development environment,
# ensuring proper isolation and scalability.

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.0.0"
    }
  }

  backend "s3" {
    bucket = "dogwalker-terraform-state-dev"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "dog-walker-booking"
      ManagedBy   = "terraform"
    }
  }
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr     = var.vpc_cidr
  environment  = var.environment
}

# EKS Cluster Module
module "eks" {
  source = "../../modules/eks-cluster"
  
  cluster_name    = var.eks_cluster_name
  environment     = var.environment
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)
  
  node_group_scaling_config = {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }
  
  node_instance_types = ["t3.medium"]
  capacity_type      = "ON_DEMAND"
  kubernetes_version = "1.27"
  
  depends_on = [module.vpc]
}

# RDS Module
module "rds" {
  source = "../../modules/rds"
  
  db_instance_identifier = "dogwalker-db-${var.environment}"
  db_instance_class     = var.rds_instance_type
  db_engine            = "postgres"
  db_engine_version    = "15.2"
  
  db_subnet_group_name    = module.vpc.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.rds.id]
  
  multi_az            = false  # Development environment doesn't require multi-AZ
  storage_encrypted   = true
  allocated_storage   = 20
  
  depends_on = [module.vpc]
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name        = "dogwalker-rds-${var.environment}"
  description = "Security group for RDS instance in development environment"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [module.eks.cluster_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dogwalker-rds-${var.environment}"
  }
}

# S3 Bucket for application assets
resource "aws_s3_bucket" "app_assets" {
  bucket = var.s3_bucket_name
  
  tags = {
    Name = var.s3_bucket_name
  }
}

resource "aws_s3_bucket_versioning" "app_assets" {
  bucket = aws_s3_bucket.app_assets.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app_assets" {
  bucket = aws_s3_bucket.app_assets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ElastiCache instance for caching
resource "aws_elasticache_cluster" "main" {
  cluster_id           = "dogwalker-cache-${var.environment}"
  engine              = "redis"
  node_type           = var.elasticache_node_type
  num_cache_nodes     = 1
  parameter_group_family = "redis7"
  port                = 6379
  security_group_ids  = [aws_security_group.elasticache.id]
  subnet_group_name   = aws_elasticache_subnet_group.main.name
}

resource "aws_elasticache_subnet_group" "main" {
  name       = "dogwalker-cache-subnet-${var.environment}"
  subnet_ids = module.vpc.private_subnet_ids
}

# Security Group for ElastiCache
resource "aws_security_group" "elasticache" {
  name        = "dogwalker-elasticache-${var.environment}"
  description = "Security group for ElastiCache in development environment"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [module.eks.cluster_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dogwalker-elasticache-${var.environment}"
  }
}
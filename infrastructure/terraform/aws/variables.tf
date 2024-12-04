# Terraform Variables for Dog Walker Booking Platform
# AWS Provider Version: 5.0.0

# Requirement addressed: Infrastructure as Code (Technical Specification/7.4.3 Security Architecture)
# This file defines the input variables used to parameterize the AWS infrastructure resources,
# enabling flexible and maintainable infrastructure deployment across different environments.

# AWS Region Configuration
variable "aws_region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}$", var.aws_region))
    error_message = "AWS region must be in the format: us-east-1, eu-west-1, etc."
  }
}

# Environment Configuration
variable "environment" {
  description = "The environment for the infrastructure (e.g., dev, staging, prod)."
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

# VPC Configuration
variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

# EKS Cluster Configuration
variable "eks_cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.eks_cluster_name))
    error_message = "EKS cluster name must start with a letter and can only contain letters, numbers, and hyphens."
  }
}

# RDS Configuration
variable "rds_instance_type" {
  description = "The instance type for the RDS database."
  type        = string
  validation {
    condition     = can(regex("^db\\.[a-z0-9]+\\.[a-z0-9]+$", var.rds_instance_type))
    error_message = "RDS instance type must be a valid instance type (e.g., db.t3.micro, db.r5.large)."
  }
}

# ElastiCache Configuration
variable "elasticache_node_type" {
  description = "The node type for the ElastiCache cluster."
  type        = string
  validation {
    condition     = can(regex("^cache\\.[a-z0-9]+\\.[a-z0-9]+$", var.elasticache_node_type))
    error_message = "ElastiCache node type must be a valid node type (e.g., cache.t3.micro, cache.r5.large)."
  }
}

# S3 Configuration
variable "s3_bucket_name" {
  description = "The name of the S3 bucket."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.s3_bucket_name)) && length(var.s3_bucket_name) >= 3 && length(var.s3_bucket_name) <= 63
    error_message = "S3 bucket name must be between 3 and 63 characters, start and end with a lowercase letter or number, and can contain only lowercase letters, numbers, hyphens, and periods."
  }
}
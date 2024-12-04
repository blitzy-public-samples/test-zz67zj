# AWS Provider Version: 5.0.0

# Human Tasks:
# 1. Create and review assume-role-policy.json file for proper trust relationships
# 2. Create and review eks-policy.json file with appropriate EKS permissions
# 3. Create and review rds-policy.json file with appropriate RDS permissions
# 4. Ensure proper AWS credentials are configured for IAM resource creation
# 5. Review generated IAM roles and policies align with security requirements

# Requirement addressed: Infrastructure as Code (Technical Specification/7.4.3 Security Architecture)
# This file defines AWS IAM resources using Terraform for secure and scalable access management.

# Requirement addressed: Role-Based Access Control (Technical Specification/10.1.3 Role-Based Access Control)
# Implements IAM roles and policies to enforce role-based access control for different platform components.

# Import required variables
variable "aws_region" {
  type = string
}

variable "environment" {
  type = string
}

# Configure AWS Provider
provider "aws" {
  region = var.aws_region
}

# EKS IAM Role
resource "aws_iam_role" "eks_role" {
  name = "eks-role-${var.environment}"
  
  # Load assume role policy from external file
  assume_role_policy = file("assume-role-policy.json")
  
  tags = {
    Environment = var.environment
    Application = "DogWalker"
  }
}

# EKS IAM Policy
resource "aws_iam_policy" "eks_policy" {
  name = "eks-policy-${var.environment}"
  
  # Load policy from external file
  policy = file("eks-policy.json")
  
  tags = {
    Environment = var.environment
    Application = "DogWalker"
  }
}

# Attach EKS policy to EKS role
resource "aws_iam_role_policy_attachment" "eks_role_policy_attachment" {
  role       = aws_iam_role.eks_role.name
  policy_arn = aws_iam_policy.eks_policy.arn
}

# RDS IAM Role
resource "aws_iam_role" "rds_role" {
  name = "rds-role-${var.environment}"
  
  # Load assume role policy from external file
  assume_role_policy = file("assume-role-policy.json")
  
  tags = {
    Environment = var.environment
    Application = "DogWalker"
  }
}

# RDS IAM Policy
resource "aws_iam_policy" "rds_policy" {
  name = "rds-policy-${var.environment}"
  
  # Load policy from external file
  policy = file("rds-policy.json")
  
  tags = {
    Environment = var.environment
    Application = "DogWalker"
  }
}

# Attach RDS policy to RDS role
resource "aws_iam_role_policy_attachment" "rds_role_policy_attachment" {
  role       = aws_iam_role.rds_role.name
  policy_arn = aws_iam_policy.rds_policy.arn
}

# Output the ARNs of created roles
output "eks_role_arn" {
  description = "The ARN of the IAM role created for the EKS cluster."
  value       = aws_iam_role.eks_role.arn
}

output "rds_role_arn" {
  description = "The ARN of the IAM role created for RDS."
  value       = aws_iam_role.rds_role.arn
}
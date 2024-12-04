# AWS EKS Cluster Configuration
# AWS Provider Version: 5.0.0
# Kubernetes Provider Version: 2.0.0

# Human Tasks:
# 1. Ensure AWS credentials are properly configured
# 2. Verify VPC and subnet configurations exist
# 3. Configure IAM roles with appropriate permissions
# 4. Review and adjust node group scaling configurations
# 5. Set up kubectl access after cluster creation

# Requirement addressed: EKS Cluster Provisioning (7.4.2 Deployment Architecture)
# Implements the infrastructure for deploying an EKS cluster as part of the container orchestration layer.

# Configure AWS Provider
provider "aws" {
  region = var.aws_region
}

# Configure Kubernetes Provider
provider "kubernetes" {
  host                   = module.eks-cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks-cluster.cluster_certificate_authority)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      var.eks_cluster_name
    ]
  }
}

# Local variables for configuration
locals {
  cluster_tags = {
    Environment = "production"
    ManagedBy  = "terraform"
    Project    = "dog-walker-app"
  }
}

# Requirement addressed: Scalable Kubernetes Cluster (7.2 Component Details)
# Implements a scalable Kubernetes cluster to support containerized workloads.

# EKS Cluster Module
module "eks-cluster" {
  source = "../modules/eks-cluster"

  cluster_name = var.eks_cluster_name
  
  # IAM Role Configuration
  role_arn = aws_iam_role.eks_cluster_role.arn
  node_role_arn = aws_iam_role.eks_node_role.arn
  
  # Network Configuration
  vpc_id = data.aws_vpc.main.id
  subnet_ids = data.aws_subnets.private.ids
  
  # Kubernetes Version
  kubernetes_version = "1.27"
  
  # Node Group Configuration
  node_group_scaling_config = {
    desired_size = 2
    max_size     = 5
    min_size     = 1
  }
  
  # Node Instance Configuration
  node_instance_types = ["t3.medium"]
  node_disk_size     = 50
  capacity_type      = "ON_DEMAND"
  
  # Security Group Configuration
  security_group_ids = [aws_security_group.eks_cluster.id]
  
  # Logging Configuration
  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
  
  # Tags
  tags = local.cluster_tags
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.eks_cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.cluster_tags
}

# Attach required policies to cluster role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# IAM Role for EKS Node Group
resource "aws_iam_role" "eks_node_role" {
  name = "${var.eks_cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = local.cluster_tags
}

# Attach required policies to node role
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_container_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

# Security Group for EKS Cluster
resource "aws_security_group" "eks_cluster" {
  name        = "${var.eks_cluster_name}-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description = "Allow worker nodes to communicate with the cluster API Server"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.cluster_tags,
    {
      Name = "${var.eks_cluster_name}-cluster-sg"
    }
  )
}

# Data sources for VPC and subnet information
data "aws_vpc" "main" {
  id = module.eks-cluster.vpc_id
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  tags = {
    Tier = "private"
  }
}

# Outputs
output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks-cluster.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_security_group.eks_cluster.id
}

output "cluster_iam_role_name" {
  description = "IAM role name associated with EKS cluster"
  value       = aws_iam_role.eks_cluster_role.name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN associated with EKS cluster"
  value       = aws_iam_role.eks_cluster_role.arn
}
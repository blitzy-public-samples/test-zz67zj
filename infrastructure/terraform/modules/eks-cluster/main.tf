# AWS EKS Cluster Terraform Module
# Version: Terraform >= 1.5.0
# Provider: AWS Provider >= 5.0.0

# Human Tasks:
# 1. Ensure AWS credentials are properly configured
# 2. Verify VPC and subnet configurations exist
# 3. Configure IAM roles with appropriate permissions
# 4. Review and adjust node group scaling configurations
# 5. Set up kubectl access after cluster creation

# Requirement addressed: EKS Cluster Configuration (7.4.2 Deployment Architecture)
# Implements the main configuration for the EKS cluster, including cluster creation,
# node groups, and networking.

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

# Local variables for configuration
locals {
  cluster_tags = {
    Environment = var.environment
    ManagedBy  = "terraform"
    Project    = "dog-walker-app"
  }
}

# EKS Cluster resource
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = var.role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = var.security_group_ids
  }

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  encryption_config {
    provider {
      key_arn = var.kms_key_arn
    }
    resources = ["secrets"]
  }

  tags = merge(
    local.cluster_tags,
    {
      Name = var.cluster_name
    }
  )

  depends_on = [
    aws_cloudwatch_log_group.eks_cluster
  ]
}

# CloudWatch Log Group for EKS cluster logs
resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 30

  tags = local.cluster_tags
}

# EKS Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.node_group_scaling_config.desired_size
    max_size     = var.node_group_scaling_config.max_size
    min_size     = var.node_group_scaling_config.min_size
  }

  update_config {
    max_unavailable = 1
  }

  instance_types = var.node_instance_types
  disk_size      = var.node_disk_size
  capacity_type  = var.capacity_type

  labels = {
    role = "application"
  }

  tags = merge(
    local.cluster_tags,
    {
      Name = "${var.cluster_name}-node-group"
    }
  )

  # Ensure proper ordering of resource creation
  depends_on = [
    aws_eks_cluster.main
  ]

  lifecycle {
    create_before_destroy = true
    ignore_changes       = [scaling_config[0].desired_size]
  }
}

# Auto Scaling Group policies for the node group
resource "aws_autoscaling_policy" "node_group_scale_up" {
  name                   = "${var.cluster_name}-node-group-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_eks_node_group.main.resources[0].autoscaling_groups[0].name
}

resource "aws_autoscaling_policy" "node_group_scale_down" {
  name                   = "${var.cluster_name}-node-group-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_eks_node_group.main.resources[0].autoscaling_groups[0].name
}

# CloudWatch alarms for auto scaling
resource "aws_cloudwatch_metric_alarm" "node_group_cpu_high" {
  alarm_name          = "${var.cluster_name}-node-group-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/EC2"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "Scale up if CPU utilization is above 80% for 10 minutes"
  alarm_actions      = [aws_autoscaling_policy.node_group_scale_up.arn]

  dimensions = {
    AutoScalingGroupName = aws_eks_node_group.main.resources[0].autoscaling_groups[0].name
  }
}

resource "aws_cloudwatch_metric_alarm" "node_group_cpu_low" {
  alarm_name          = "${var.cluster_name}-node-group-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/EC2"
  period             = "300"
  statistic          = "Average"
  threshold          = "20"
  alarm_description  = "Scale down if CPU utilization is below 20% for 10 minutes"
  alarm_actions      = [aws_autoscaling_policy.node_group_scale_down.arn]

  dimensions = {
    AutoScalingGroupName = aws_eks_node_group.main.resources[0].autoscaling_groups[0].name
  }
}

# IRSA (IAM Roles for Service Accounts) configuration
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

# Outputs for use in other modules
output "cluster_id" {
  description = "The ID of the EKS cluster"
  value       = aws_eks_cluster.main.id
}

output "cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority" {
  description = "The certificate authority data for the EKS cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "node_group_scaling_config" {
  description = "The scaling configuration for the EKS node group"
  value       = aws_eks_node_group.main.scaling_config
}
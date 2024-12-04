# Requirement addressed: EKS Cluster Configuration Variables (7.4.2 Deployment Architecture)
# Defines input variables for configuring the EKS cluster, including cluster name,
# role ARN, subnet IDs, and scaling configurations.

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][-a-zA-Z0-9]*$", var.cluster_name))
    error_message = "Cluster name must begin with a letter and only contain letters, numbers, and hyphens."
  }
}

variable "role_arn" {
  description = "The ARN of the IAM role for the EKS cluster"
  type        = string

  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/.+", var.role_arn))
    error_message = "The role ARN must be a valid AWS IAM role ARN."
  }
}

variable "subnet_ids" {
  description = "The list of subnet IDs for the EKS cluster"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "At least one subnet ID must be provided."
  }
}

variable "node_group_scaling_config" {
  description = "The scaling configuration for the EKS node group"
  type = object({
    desired_size = string
    max_size     = string
    min_size     = string
  })
  default = {
    desired_size = "2"
    max_size     = "5"
    min_size     = "1"
  }

  validation {
    condition     = tonumber(var.node_group_scaling_config.min_size) >= 1
    error_message = "Minimum size must be at least 1."
  }

  validation {
    condition     = tonumber(var.node_group_scaling_config.max_size) >= tonumber(var.node_group_scaling_config.min_size)
    error_message = "Maximum size must be greater than or equal to minimum size."
  }

  validation {
    condition     = tonumber(var.node_group_scaling_config.desired_size) >= tonumber(var.node_group_scaling_config.min_size) && tonumber(var.node_group_scaling_config.desired_size) <= tonumber(var.node_group_scaling_config.max_size)
    error_message = "Desired size must be between minimum and maximum size."
  }
}

# Additional variables required by main.tf

variable "environment" {
  description = "The environment name for the EKS cluster (e.g., dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "kubernetes_version" {
  description = "The version of Kubernetes to use for the EKS cluster"
  type        = string
  default     = "1.27"

  validation {
    condition     = can(regex("^1\\.(2[3-9]|[3-9][0-9])$", var.kubernetes_version))
    error_message = "Kubernetes version must be 1.23 or higher."
  }
}

variable "security_group_ids" {
  description = "List of security group IDs for the EKS cluster"
  type        = list(string)
  default     = []
}

variable "kms_key_arn" {
  description = "The ARN of the KMS key for encrypting Kubernetes secrets"
  type        = string

  validation {
    condition     = can(regex("^arn:aws:kms:[a-z0-9-]+:[0-9]{12}:key/[a-zA-Z0-9-]+$", var.kms_key_arn))
    error_message = "The KMS key ARN must be a valid AWS KMS key ARN."
  }
}

variable "node_role_arn" {
  description = "The ARN of the IAM role for the EKS node group"
  type        = string

  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/.+", var.node_role_arn))
    error_message = "The node role ARN must be a valid AWS IAM role ARN."
  }
}

variable "node_instance_types" {
  description = "List of EC2 instance types for the EKS node group"
  type        = list(string)
  default     = ["t3.medium"]

  validation {
    condition     = length(var.node_instance_types) > 0
    error_message = "At least one instance type must be specified."
  }
}

variable "node_disk_size" {
  description = "The disk size in GiB for the EKS node group instances"
  type        = number
  default     = 20

  validation {
    condition     = var.node_disk_size >= 20 && var.node_disk_size <= 2000
    error_message = "Node disk size must be between 20 and 2000 GiB."
  }
}

variable "capacity_type" {
  description = "The capacity type for the EKS node group (ON_DEMAND or SPOT)"
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.capacity_type)
    error_message = "Capacity type must be either ON_DEMAND or SPOT."
  }
}
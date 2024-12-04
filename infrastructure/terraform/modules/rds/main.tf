# AWS Provider configuration
# Using AWS Provider version 5.0.0
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.0.0"
    }
  }
}

# Human Tasks:
# 1. Ensure AWS credentials are properly configured
# 2. Create and configure a KMS key if encryption is required
# 3. Set up the VPC security groups with appropriate ingress/egress rules
# 4. Configure the subnet group with appropriate private subnets
# 5. Store sensitive variables like passwords in AWS Secrets Manager or similar

# Variables definition
variable "db_instance_identifier" {
  description = "The identifier for the RDS instance"
  type        = string
  default     = "my-rds-instance"
}

variable "db_engine" {
  description = "The database engine to use"
  type        = string
  default     = "postgres"
}

variable "db_engine_version" {
  description = "The engine version to use"
  type        = string
  default     = "15.2"
}

variable "db_instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  default     = "db.t3.medium"
}

variable "db_allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = string
  default     = "20"
}

variable "db_username" {
  description = "Username for the master DB user"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "db_password" {
  description = "Password for the master DB user"
  type        = string
  default     = "securepassword"
  sensitive   = true
}

variable "db_subnet_group_name" {
  description = "Name of DB subnet group"
  type        = string
  default     = "default"
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate"
  type        = list(string)
  default     = []
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
  default     = false
}

variable "storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key"
  type        = string
  default     = null
}

# RDS instance resource
# Requirement: Database Provisioning (Section 7.2.2)
resource "aws_db_instance" "main" {
  identifier = var.db_instance_identifier
  
  # Engine configuration
  engine         = var.db_engine
  engine_version = var.db_engine_version
  
  # Instance configuration
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  
  # Authentication
  username = var.db_username
  password = var.db_password
  
  # Network configuration
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids
  multi_az              = var.multi_az
  
  # Security configuration
  storage_encrypted = var.storage_encrypted
  kms_key_id       = var.kms_key_id
  
  # Backup configuration
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "Mon:04:00-Mon:05:00"
  
  # Enhanced monitoring
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring_role.arn
  
  # Performance Insights
  performance_insights_enabled = true
  performance_insights_retention_period = 7
  
  # Additional configuration
  auto_minor_version_upgrade = true
  copy_tags_to_snapshot     = true
  deletion_protection       = true
  skip_final_snapshot      = false
  final_snapshot_identifier = "${var.db_instance_identifier}-final-snapshot"
  
  # Parameter group
  parameter_group_name = aws_db_parameter_group.main.name
  
  tags = {
    Name        = var.db_instance_identifier
    Environment = terraform.workspace
    Managed_by  = "terraform"
  }
}

# Parameter group resource
resource "aws_db_parameter_group" "main" {
  family = "postgres15"
  name   = "${var.db_instance_identifier}-params"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "log_duration"
    value = "1"
  }

  tags = {
    Name        = "${var.db_instance_identifier}-params"
    Environment = terraform.workspace
    Managed_by  = "terraform"
  }
}

# IAM role for enhanced monitoring
resource "aws_iam_role" "rds_monitoring_role" {
  name = "${var.db_instance_identifier}-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.db_instance_identifier}-monitoring-role"
    Environment = terraform.workspace
    Managed_by  = "terraform"
  }
}

# Attach the enhanced monitoring policy to the role
resource "aws_iam_role_policy_attachment" "rds_monitoring_policy" {
  role       = aws_iam_role.rds_monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# Outputs
output "db_instance_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.main.arn
}
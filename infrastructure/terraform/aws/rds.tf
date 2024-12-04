# AWS RDS Configuration for Dog Walker Booking Platform
# AWS Provider Version: 5.0.0

# Human Tasks:
# 1. Ensure AWS credentials are properly configured
# 2. Create and store database credentials securely in AWS Secrets Manager
# 3. Configure VPC security groups with appropriate database access rules
# 4. Set up private subnets for the DB subnet group
# 5. Create and configure KMS key for database encryption
# 6. Review and adjust backup and maintenance windows according to business requirements

# Requirement addressed: Database Provisioning (7.2.2 Data Storage Components)
# This configuration provisions and manages PostgreSQL database instances for the backend infrastructure

# Requirement addressed: Infrastructure as Code (9.5 DEVELOPMENT & DEPLOYMENT)
# Implements infrastructure management using Terraform for consistent and repeatable deployments

# Reference required variables from variables.tf
variable "aws_region" {}
variable "environment" {}
variable "rds_instance_type" {}

# RDS Instance Configuration
resource "aws_db_instance" "dog_walker_db" {
  identifier = "dog-walker-${var.environment}-db"
  
  # Database engine configuration
  engine         = "postgres"
  engine_version = "15.2"
  instance_class = var.rds_instance_type
  
  # Storage configuration
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type         = "gp3"
  storage_encrypted    = true
  
  # Network configuration
  db_subnet_group_name = "dog-walker-${var.environment}-subnet-group"
  multi_az            = var.environment == "prod" ? true : false
  publicly_accessible = false
  
  # Authentication and access
  username = "dogwalker_admin"
  password = "TO_BE_REPLACED_WITH_SECRETS_MANAGER_VALUE"
  
  # Backup configuration
  backup_retention_period = var.environment == "prod" ? 30 : 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "Mon:04:00-Mon:05:00"
  
  # Monitoring and insights
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring_role.arn
  
  performance_insights_enabled          = true
  performance_insights_retention_period = var.environment == "prod" ? 731 : 7
  
  # Security configuration
  vpc_security_group_ids = [
    "TO_BE_REPLACED_WITH_SECURITY_GROUP_ID"
  ]
  
  # Additional configuration
  auto_minor_version_upgrade = true
  copy_tags_to_snapshot     = true
  deletion_protection       = var.environment == "prod" ? true : false
  skip_final_snapshot      = var.environment == "prod" ? false : true
  final_snapshot_identifier = var.environment == "prod" ? "dog-walker-${var.environment}-final-snapshot" : null
  
  # Parameter group
  parameter_group_name = aws_db_parameter_group.dog_walker.name
  
  tags = {
    Name        = "dog-walker-${var.environment}-db"
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "dog-walker-booking"
  }
}

# Parameter group for database configuration
resource "aws_db_parameter_group" "dog_walker" {
  family = "postgres15"
  name   = "dog-walker-${var.environment}-params"
  
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
  
  parameter {
    name  = "shared_preload_libraries"
    value = "pg_stat_statements"
  }
  
  parameter {
    name  = "pg_stat_statements.track"
    value = "ALL"
  }
  
  tags = {
    Name        = "dog-walker-${var.environment}-params"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# IAM role for enhanced monitoring
resource "aws_iam_role" "rds_monitoring_role" {
  name = "dog-walker-${var.environment}-rds-monitoring"
  
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
    Name        = "dog-walker-${var.environment}-rds-monitoring"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Attach enhanced monitoring policy to the role
resource "aws_iam_role_policy_attachment" "rds_monitoring_policy" {
  role       = aws_iam_role.rds_monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# Outputs for use in other modules
output "db_instance_endpoint" {
  description = "The endpoint address of the RDS instance"
  value       = aws_db_instance.dog_walker_db.endpoint
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.dog_walker_db.arn
}
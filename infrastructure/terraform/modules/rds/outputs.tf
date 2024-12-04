# Requirement: Database Provisioning (Section 7.2.2)
# Defines output variables for the RDS instance that can be used by other modules

# The connection endpoint for the RDS instance
# Format: <hostname>:<port>
output "db_instance_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.main.endpoint
  
  # Ensure the endpoint is not empty
  precondition {
    condition     = aws_db_instance.main.endpoint != null
    error_message = "RDS instance endpoint must be available."
  }
}

# The ARN (Amazon Resource Name) of the RDS instance
# Used for IAM policies and cross-account access
output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.main.arn
  
  # Ensure the ARN is properly formatted
  precondition {
    condition     = can(regex("^arn:aws:rds:", aws_db_instance.main.arn))
    error_message = "RDS instance ARN must be valid."
  }
}

# Requirement: Infrastructure as Code (Section 9.5)
# Additional outputs useful for infrastructure management

output "db_instance_id" {
  description = "The RDS instance identifier"
  value       = aws_db_instance.main.id
}

output "db_subnet_group_name" {
  description = "The name of the database subnet group"
  value       = aws_db_instance.main.db_subnet_group_name
}

output "db_security_groups" {
  description = "The security groups associated with the RDS instance"
  value       = aws_db_instance.main.vpc_security_group_ids
}

output "db_monitoring_role_arn" {
  description = "The ARN of the enhanced monitoring IAM role"
  value       = aws_iam_role.rds_monitoring_role.arn
}

output "db_parameter_group_name" {
  description = "The name of the database parameter group"
  value       = aws_db_parameter_group.main.name
}

output "db_availability_zone" {
  description = "The availability zone of the RDS instance"
  value       = aws_db_instance.main.availability_zone
}

output "db_backup_retention_period" {
  description = "The backup retention period in days"
  value       = aws_db_instance.main.backup_retention_period
}

output "db_performance_insights_enabled" {
  description = "Whether Performance Insights is enabled"
  value       = aws_db_instance.main.performance_insights_enabled
}
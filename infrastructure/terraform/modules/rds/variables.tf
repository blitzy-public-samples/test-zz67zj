# Human Tasks:
# 1. Review and adjust default values based on environment requirements
# 2. Ensure sensitive values (passwords, KMS key IDs) are stored securely
# 3. Configure appropriate VPC security groups before deployment
# 4. Set up DB subnet groups in the target VPC
# 5. Consider using AWS Secrets Manager for database credentials in production

# Requirement: Database Provisioning (Section 7.2.2)
# Defines variables for PostgreSQL RDS instance configuration
variable "db_instance_identifier" {
  description = "The identifier for the RDS instance"
  type        = string
  default     = "my-rds-instance"
  
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.db_instance_identifier))
    error_message = "The instance identifier must begin with a letter and only contain alphanumeric characters and hyphens."
  }
}

variable "db_engine" {
  description = "The database engine to use"
  type        = string
  default     = "postgres"
  
  validation {
    condition     = var.db_engine == "postgres"
    error_message = "Only PostgreSQL engine is supported for this module."
  }
}

variable "db_engine_version" {
  description = "The engine version to use"
  type        = string
  default     = "15.2"
  
  validation {
    condition     = can(regex("^\\d+\\.\\d+(\\.\\d+)?$", var.db_engine_version))
    error_message = "The engine version must be a valid PostgreSQL version number (e.g., 15.2)."
  }
}

variable "db_instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  default     = "db.t3.medium"
  
  validation {
    condition     = can(regex("^db\\.[a-z0-9]+\\.[a-z0-9]+$", var.db_instance_class))
    error_message = "The instance class must be a valid RDS instance type (e.g., db.t3.medium)."
  }
}

variable "db_allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = string
  default     = "20"
  
  validation {
    condition     = can(tonumber(var.db_allocated_storage)) && tonumber(var.db_allocated_storage) >= 20
    error_message = "Allocated storage must be a number and at least 20 GB."
  }
}

variable "db_username" {
  description = "Username for the master DB user"
  type        = string
  default     = "admin"
  sensitive   = true
  
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.db_username))
    error_message = "The username must begin with a letter and only contain alphanumeric characters and underscores."
  }
}

variable "db_password" {
  description = "Password for the master DB user"
  type        = string
  default     = "securepassword"
  sensitive   = true
  
  validation {
    condition     = length(var.db_password) >= 8
    error_message = "The password must be at least 8 characters long."
  }
}

variable "db_subnet_group_name" {
  description = "Name of DB subnet group"
  type        = string
  default     = "default"
  
  validation {
    condition     = length(var.db_subnet_group_name) > 0
    error_message = "DB subnet group name cannot be empty."
  }
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate"
  type        = list(string)
  default     = []
  
  validation {
    condition     = alltrue([for sg in var.vpc_security_group_ids : can(regex("^sg-[a-f0-9]+$", sg))])
    error_message = "All security group IDs must be valid (e.g., sg-123456)."
  }
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
  
  validation {
    condition     = var.kms_key_id == null || can(regex("^arn:aws:kms:[a-z0-9-]+:[0-9]+:key/[a-f0-9-]+$", var.kms_key_id))
    error_message = "The KMS key ID must be a valid ARN or null."
  }
}
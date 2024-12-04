# AWS Provider Version: 5.0.0

# Human Tasks:
# 1. Ensure AWS credentials are properly configured with permissions to manage KMS resources
# 2. Review and adjust key rotation and deletion policies based on security requirements
# 3. Configure appropriate IAM policies for key usage
# 4. Document key aliases and their purposes for team reference

# Requirement addressed: Infrastructure as Code (Technical Specification/7.4.3 Security Architecture)
# This file defines AWS KMS resources for secure encryption key management in the Dog Walker Booking platform.

# KMS key for encrypting sensitive data
resource "aws_kms_key" "main" {
  description             = "KMS key for encrypting sensitive data in the Dog Walker Booking platform."
  key_usage              = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  
  # Enable automatic key rotation for enhanced security
  enable_key_rotation = true
  
  # Prevent accidental deletion
  deletion_window_in_days = 30
  
  # Enable key policies
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Key Management"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "dogwalker-kms-key"
    Environment = var.environment
    ManagedBy   = "terraform"
    Purpose     = "data-encryption"
  }
}

# Data source to get AWS account ID
data "aws_caller_identity" "current" {}

# KMS alias for easier key identification
resource "aws_kms_alias" "main_alias" {
  name          = "alias/dogwalker-main-key"
  target_key_id = aws_kms_key.main.id
}

# Output the KMS key ID
output "kms_key_id" {
  description = "The ID of the created KMS key."
  value       = aws_kms_key.main.id
  sensitive   = false
}

# Output the KMS key ARN
output "kms_key_arn" {
  description = "The ARN of the created KMS key."
  value       = aws_kms_key.main.arn
  sensitive   = false
}
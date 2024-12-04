# AWS Provider Version: 5.0.0

# Human Tasks:
# 1. Review and adjust log retention periods based on compliance requirements
# 2. Configure appropriate IAM permissions for CloudWatch access
# 3. Review and customize alarm thresholds based on application requirements
# 4. Ensure proper dashboard configuration in dashboard.json file
# 5. Set up notification endpoints for alarm actions

# Requirement addressed: Monitoring and Observability (Technical Specification/7.4.1 Monitoring and Observability)
# This file implements AWS CloudWatch resources for centralized logging, metrics collection, and alerting
# to ensure system reliability and performance monitoring for the Dog Walker Booking platform.

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

# Application Log Group
resource "aws_cloudwatch_log_group" "application_logs" {
  name              = "/dogwalker/${var.environment}/application"
  retention_in_days = 30
  kms_key_id        = module.kms.kms_key_arn

  tags = {
    Environment = var.environment
    Application = "DogWalker"
  }
}

# High CPU Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "HighCPUUtilization-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period             = 300
  statistic          = "Average"
  threshold          = 80
  alarm_actions      = [module.iam.eks_role_arn]

  dimensions = {
    VpcId = data.terraform_remote_state.vpc.outputs.vpc_id
  }

  tags = {
    Environment = var.environment
    Application = "DogWalker"
  }
}

# System Dashboard
resource "aws_cloudwatch_dashboard" "system_dashboard" {
  dashboard_name = "DogWalker-${var.environment}"
  dashboard_body = file("dashboard.json")

  tags = {
    Environment = var.environment
    Application = "DogWalker"
  }
}

# Outputs
output "log_group_name" {
  description = "The name of the CloudWatch log group for application logs."
  value       = aws_cloudwatch_log_group.application_logs.name
}

output "high_cpu_alarm_arn" {
  description = "The ARN of the high CPU utilization alarm."
  value       = aws_cloudwatch_metric_alarm.high_cpu_alarm.arn
}

output "dashboard_name" {
  description = "The name of the CloudWatch dashboard for system monitoring."
  value       = aws_cloudwatch_dashboard.system_dashboard.dashboard_name
}
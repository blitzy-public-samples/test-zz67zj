# AWS Provider Version: 5.0.0

# Human Tasks:
# 1. Ensure AWS credentials are properly configured
# 2. Verify VPC and subnet configurations exist
# 3. Review and adjust ElastiCache node type based on workload requirements
# 4. Configure security group rules for Redis access
# 5. Plan backup and maintenance windows according to application requirements

# Requirement addressed: Infrastructure as Code (Technical Specification/7.4.3 Security Architecture)
# This file defines the AWS ElastiCache cluster configuration for caching and session management
# in the Dog Walker Booking platform.

# Security group for ElastiCache cluster
resource "aws_security_group" "elasticache" {
  name        = "dogwalker-elasticache-sg"
  description = "Security group for ElastiCache cluster"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Redis access from private subnets"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [for subnet in module.vpc.private_subnet_ids : data.aws_subnet.private[subnet].cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "dogwalker-elasticache-sg"
    Environment = var.environment
  }
}

# Data source to get private subnet CIDR blocks
data "aws_subnet" "private" {
  for_each = toset(module.vpc.private_subnet_ids)
  id       = each.value
}

# ElastiCache subnet group
resource "aws_elasticache_subnet_group" "main" {
  name        = "dogwalker-elasticache-subnet-group"
  description = "Subnet group for ElastiCache cluster"
  subnet_ids  = module.vpc.private_subnet_ids

  tags = {
    Name        = "dogwalker-elasticache-subnet-group"
    Environment = var.environment
  }
}

# ElastiCache parameter group
resource "aws_elasticache_parameter_group" "main" {
  family      = "redis6.x"
  name        = "dogwalker-redis-params"
  description = "Custom parameter group for ElastiCache Redis cluster"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }

  parameter {
    name  = "timeout"
    value = "300"
  }

  tags = {
    Name        = "dogwalker-redis-params"
    Environment = var.environment
  }
}

# ElastiCache cluster
resource "aws_elasticache_cluster" "main" {
  cluster_id           = "dogwalker-elasticache-${var.environment}"
  engine              = "redis"
  node_type           = var.elasticache_node_type
  num_cache_nodes     = 1
  parameter_group_name = aws_elasticache_parameter_group.main.name
  port                = 6379
  subnet_group_name   = aws_elasticache_subnet_group.main.name
  security_group_ids  = [aws_security_group.elasticache.id]

  # Maintenance and backup settings
  maintenance_window = "sun:05:00-sun:06:00"
  snapshot_window   = "04:00-05:00"
  snapshot_retention_period = 7

  # Redis specific settings
  engine_version    = "6.x"
  apply_immediately = true

  # Notifications
  notification_topic_arn = aws_sns_topic.elasticache_notifications.arn

  tags = {
    Name        = "dogwalker-elasticache"
    Environment = var.environment
  }
}

# SNS topic for ElastiCache notifications
resource "aws_sns_topic" "elasticache_notifications" {
  name = "dogwalker-elasticache-notifications-${var.environment}"

  tags = {
    Name        = "dogwalker-elasticache-notifications"
    Environment = var.environment
  }
}

# CloudWatch alarms for monitoring
resource "aws_cloudwatch_metric_alarm" "cache_cpu" {
  alarm_name          = "dogwalker-elasticache-cpu-utilization"
  alarm_description   = "This metric monitors ElastiCache CPU utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/ElastiCache"
  period             = "300"
  statistic          = "Average"
  threshold          = "75"
  alarm_actions      = [aws_sns_topic.elasticache_notifications.arn]
  ok_actions         = [aws_sns_topic.elasticache_notifications.arn]

  dimensions = {
    CacheClusterId = aws_elasticache_cluster.main.id
  }

  tags = {
    Name        = "dogwalker-elasticache-cpu-alarm"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "cache_memory" {
  alarm_name          = "dogwalker-elasticache-memory"
  alarm_description   = "This metric monitors ElastiCache memory usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "DatabaseMemoryUsagePercentage"
  namespace          = "AWS/ElastiCache"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_actions      = [aws_sns_topic.elasticache_notifications.arn]
  ok_actions         = [aws_sns_topic.elasticache_notifications.arn]

  dimensions = {
    CacheClusterId = aws_elasticache_cluster.main.id
  }

  tags = {
    Name        = "dogwalker-elasticache-memory-alarm"
    Environment = var.environment
  }
}
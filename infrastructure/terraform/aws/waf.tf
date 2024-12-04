# AWS Provider Version: 5.0.0

# Human Tasks:
# 1. Review and adjust WAF rules based on security requirements
# 2. Monitor WAF logs and metrics after deployment
# 3. Configure additional custom rules if needed
# 4. Verify WAF association with CloudFront distribution
# 5. Set up alerts for WAF rule triggers

# Requirement addressed: Web Application Firewall (Technical Specification/7.4.3 Security Architecture)
# Implements AWS WAF to protect the platform from common web exploits and attacks.

# Configure AWS Provider
provider "aws" {
  region = var.aws_region
}

# WAF Web ACL
resource "aws_wafv2_web_acl" "dogwalker_waf" {
  name        = "dogwalker-waf"
  description = "WAF Web ACL for Dog Walker Booking platform"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  # AWS Managed Rule - Common Rule Set
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name               = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled  = true
    }
  }

  # AWS Managed Rule - SQL Injection Rule Set
  rule {
    name     = "AWS-AWSManagedRulesSQLiRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name               = "AWSManagedRulesSQLiRuleSet"
      sampled_requests_enabled  = true
    }
  }

  # AWS Managed Rule - Known Bad Inputs Rule Set
  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name               = "AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled  = true
    }
  }

  # Rate Limiting Rule
  rule {
    name     = "RateLimitRule"
    priority = 4

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name               = "RateLimitRule"
      sampled_requests_enabled  = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name               = "dogwalker-waf"
    sampled_requests_enabled  = true
  }

  tags = {
    Environment = var.environment
    Project     = "DogWalker"
    ManagedBy   = "Terraform"
  }
}

# Associate WAF Web ACL with CloudFront distribution
resource "aws_wafv2_web_acl_association" "dogwalker_waf_association" {
  resource_arn = aws_cloudfront_distribution.dogwalker_distribution.arn
  web_acl_arn  = aws_wafv2_web_acl.dogwalker_waf.arn
}

# CloudWatch log group for WAF logs
resource "aws_cloudwatch_log_group" "waf_log_group" {
  name              = "/aws/waf/dogwalker"
  retention_in_days = 30

  tags = {
    Environment = var.environment
    Project     = "DogWalker"
    ManagedBy   = "Terraform"
  }
}

# Enable logging for WAF Web ACL
resource "aws_wafv2_web_acl_logging_configuration" "dogwalker_waf_logging" {
  log_destination_configs = [aws_cloudwatch_log_group.waf_log_group.arn]
  resource_arn           = aws_wafv2_web_acl.dogwalker_waf.arn

  logging_filter {
    default_behavior = "KEEP"

    filter {
      behavior = "KEEP"
      condition {
        action_condition {
          action = "BLOCK"
        }
      }
      requirement = "MEETS_ANY"
    }
  }
}

# Output the WAF Web ACL ID and ARN
output "waf_web_acl_id" {
  description = "The ID of the WAF Web ACL"
  value       = aws_wafv2_web_acl.dogwalker_waf.id
}

output "waf_web_acl_arn" {
  description = "The ARN of the WAF Web ACL"
  value       = aws_wafv2_web_acl.dogwalker_waf.arn
}
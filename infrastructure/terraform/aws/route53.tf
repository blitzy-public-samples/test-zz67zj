# AWS Provider Version: 5.0.0

# Human Tasks:
# 1. Ensure domain name 'dogwalker.com' is registered and available
# 2. Verify ACM certificate is properly configured
# 3. Confirm load balancer is provisioned before creating DNS records
# 4. Review DNS propagation after applying changes
# 5. Set up DNS monitoring and health checks if required

# Requirement addressed: DNS Management (Technical Specification/7.4.3 Security Architecture)
# Implements AWS Route 53 to manage DNS records for the platform, ensuring reliable domain name resolution.

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

# Create the main hosted zone for dogwalker.com
resource "aws_route53_zone" "dogwalker_zone" {
  name = "dogwalker.com"
  
  tags = {
    Environment = var.environment
    Project     = "DogWalker"
  }

  # Enable DNSSEC for additional security
  lifecycle {
    prevent_destroy = true
  }
}

# Create A record for www subdomain pointing to the load balancer
resource "aws_route53_record" "www_record" {
  zone_id = aws_route53_zone.dogwalker_zone.zone_id
  name    = "www.dogwalker.com"
  type    = "A"

  alias {
    name                   = aws_lb.dogwalker_lb.dns_name
    zone_id               = aws_lb.dogwalker_lb.zone_id
    evaluate_target_health = true
  }

  # Ensure proper dependency order
  depends_on = [
    aws_route53_zone.dogwalker_zone
  ]
}

# Create DNS record for ACM certificate validation
resource "aws_route53_record" "cert_validation" {
  zone_id = aws_route53_zone.dogwalker_zone.zone_id
  name    = aws_acm_certificate.dogwalker_cert.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.dogwalker_cert.domain_validation_options[0].resource_record_type
  records = [aws_acm_certificate.dogwalker_cert.domain_validation_options[0].resource_record_value]
  ttl     = 60

  depends_on = [
    aws_route53_zone.dogwalker_zone,
    aws_acm_certificate.dogwalker_cert
  ]
}

# Create health check for www subdomain
resource "aws_route53_health_check" "www_health_check" {
  fqdn              = "www.dogwalker.com"
  port              = 443
  type              = "HTTPS"
  resource_path     = "/health"
  failure_threshold = "3"
  request_interval  = "30"

  tags = {
    Environment = var.environment
    Project     = "DogWalker"
    Name        = "www-health-check"
  }
}

# Create DNS failover record (if primary endpoint fails)
resource "aws_route53_record" "www_failover" {
  zone_id = aws_route53_zone.dogwalker_zone.zone_id
  name    = "www.dogwalker.com"
  type    = "A"

  failover_routing_policy {
    type = "SECONDARY"
  }

  alias {
    name                   = aws_cloudfront_distribution.static_fallback.domain_name
    zone_id               = aws_cloudfront_distribution.static_fallback.hosted_zone_id
    evaluate_target_health = true
  }

  set_identifier = "secondary"
  health_check_id = aws_route53_health_check.www_health_check.id

  depends_on = [
    aws_route53_zone.dogwalker_zone,
    aws_route53_health_check.www_health_check
  ]
}

# Output the name servers for the hosted zone
output "nameservers" {
  description = "The name servers for the hosted zone"
  value       = aws_route53_zone.dogwalker_zone.name_servers
}

# Output the zone ID
output "zone_id" {
  description = "The hosted zone ID"
  value       = aws_route53_zone.dogwalker_zone.zone_id
}
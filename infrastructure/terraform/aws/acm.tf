# AWS Provider Version: 5.0.0

# Human Tasks:
# 1. Ensure domain name 'dogwalker.com' is registered and available
# 2. Verify DNS validation records are properly created in Route53
# 3. Monitor certificate validation status after applying changes
# 4. Plan for certificate renewal before expiration (ACM handles automatic renewal if DNS validation is maintained)

# Requirement addressed: SSL/TLS Certificate Management (Technical Specification/7.4.3 Security Architecture)
# Implements AWS Certificate Manager (ACM) to provision and manage SSL/TLS certificates for secure communication.

# Import required provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.0.0"
    }
  }
}

# Configure AWS Provider
provider "aws" {
  region = var.aws_region
}

# ACM Certificate for the main domain
resource "aws_acm_certificate" "dogwalker_cert" {
  domain_name       = "dogwalker.com"
  validation_method = "DNS"

  # Add subject alternative names for subdomains
  subject_alternative_names = [
    "*.dogwalker.com",  # Wildcard for all subdomains
    "www.dogwalker.com" # Explicitly include www subdomain
  ]

  tags = {
    Environment = var.environment
    Project     = "DogWalker"
    ManagedBy   = "Terraform"
  }

  # Ensure new certificate is created before destroying the old one
  lifecycle {
    create_before_destroy = true
  }
}

# Certificate validation using DNS method
resource "aws_acm_certificate_validation" "dogwalker_cert_validation" {
  certificate_arn = aws_acm_certificate.dogwalker_cert.arn

  # Reference the validation record created in Route53
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]

  # Ensure proper dependency chain
  depends_on = [
    aws_acm_certificate.dogwalker_cert,
    aws_route53_record.cert_validation
  ]
}

# Output the certificate ARN for use in other resources
output "acm_certificate_arn" {
  description = "The ARN of the ACM certificate"
  value       = aws_acm_certificate.dogwalker_cert.arn
}

# Output the certificate domain validation options
output "certificate_validation_options" {
  description = "The domain validation options for the certificate"
  value       = aws_acm_certificate.dogwalker_cert.domain_validation_options
  sensitive   = true
}
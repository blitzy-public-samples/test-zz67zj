# AWS Provider Version: 5.0.0

# Human Tasks:
# 1. Ensure S3 bucket is properly configured with appropriate permissions
# 2. Verify ACM certificate is validated and active
# 3. Configure DNS records in Route53 to point to CloudFront distribution
# 4. Review cache behavior settings and adjust TTLs if needed
# 5. Set up monitoring and alerts for CloudFront metrics

# Requirement addressed: Content Delivery Network (Technical Specification/7.1 High-Level Architecture)
# Implements AWS CloudFront for efficient and secure content delivery across the platform.

# Configure AWS Provider
provider "aws" {
  region = var.aws_region
}

# CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "dogwalker_oai" {
  comment = "OAI for Dog Walker CloudFront distribution"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "dogwalker_distribution" {
  enabled             = true
  is_ipv6_enabled    = true
  default_root_object = "index.html"
  price_class        = "PriceClass_100"
  http_version       = "http2"
  
  # Origin configuration
  origin {
    domain_name = "${var.s3_bucket_name}.s3.amazonaws.com"
    origin_id   = "dogwalker-s3-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.dogwalker_oai.cloudfront_access_identity_path
    }
  }

  # Default cache behavior
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "dogwalker-s3-origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }

  # Custom error responses
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  # Restrictions
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # SSL/TLS configuration
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.dogwalker_cert.arn
    minimum_protocol_version = "TLSv1.2_2019"
    ssl_support_method       = "sni-only"
  }

  # Aliases
  aliases = ["dogwalker.com", "www.dogwalker.com"]

  # Tags
  tags = {
    Environment = var.environment
    Project     = "DogWalker"
    ManagedBy   = "Terraform"
  }

  # Ensure proper dependency chain
  depends_on = [
    aws_cloudfront_origin_access_identity.dogwalker_oai,
    aws_acm_certificate.dogwalker_cert
  ]
}

# S3 bucket policy for CloudFront access
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.s3_bucket_name}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.dogwalker_oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudfront_access" {
  bucket = var.s3_bucket_name
  policy = data.aws_iam_policy_document.s3_policy.json
}

# CloudFront distribution outputs
output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.dogwalker_distribution.id
}

output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.dogwalker_distribution.domain_name
}
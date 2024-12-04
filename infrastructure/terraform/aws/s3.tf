# AWS Provider Version: 5.0.0

# Human Tasks:
# 1. Ensure AWS credentials are properly configured
# 2. Verify that the S3 bucket name is globally unique
# 3. Review bucket policy permissions to ensure they align with security requirements
# 4. Configure CORS if required for web application access
# 5. Set up bucket encryption if required for sensitive data

# Requirement addressed: Infrastructure as Code (Technical Specification/7.4.3 Security Architecture)
# This file defines the S3 bucket configuration for the Dog Walker Booking platform
# using Terraform to ensure consistent and secure infrastructure provisioning.

# S3 Bucket resource
resource "aws_s3_bucket" "main" {
  bucket = var.s3_bucket_name

  # Force destroy is set to false to prevent accidental deletion
  force_destroy = false

  tags = {
    Name        = var.s3_bucket_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# S3 Bucket versioning configuration
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.main.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket server-side encryption configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket public access block
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket ACL
resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.main.id
  acl    = "private"

  depends_on = [aws_s3_bucket_ownership_controls.ownership_controls]
}

# S3 Bucket ownership controls
resource "aws_s3_bucket_ownership_controls" "ownership_controls" {
  bucket = aws_s3_bucket.main.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# S3 Bucket lifecycle rules
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_rules" {
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "cleanup_old_versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

# IAM policy document for S3 bucket
data "aws_iam_policy_document" "s3_policy" {
  statement {
    sid    = "EnforceHTTPS"
    effect = "Deny"
    
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]
    
    resources = [
      aws_s3_bucket.main.arn,
      "${aws_s3_bucket.main.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    sid    = "AllowGetObject"
    effect = "Allow"
    
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["s3:GetObject"]
    
    resources = ["${aws_s3_bucket.main.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [data.aws_organizations_organization.current.id]
    }
  }
}

# Get current AWS Organizations ID
data "aws_organizations_organization" "current" {}

# Attach bucket policy
resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.s3_policy.json

  depends_on = [aws_s3_bucket_public_access_block.public_access]
}
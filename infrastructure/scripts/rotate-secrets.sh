#!/bin/bash

# Human Tasks:
# 1. Ensure AWS credentials are properly configured in ~/.aws/credentials or environment variables
# 2. Verify that the AWS CLI version 2.0+ is installed
# 3. Review and adjust backup retention periods for secrets if needed
# 4. Ensure proper IAM permissions are configured for secret rotation
# 5. Verify that all dependent services can handle secret rotation gracefully

# Requirement addressed: Secrets Management (Technical Specification/7.4.3 Security Architecture)
# This script automates the rotation of secrets and keys for AWS infrastructure resources
# used in the Dog Walker Booking platform.

# Set error handling
set -euo pipefail

# Source initialization script
source "$(dirname "$0")/init-terraform.sh"

# Function to validate environment name
validate_environment() {
    local env=$1
    if [[ ! "$env" =~ ^(dev|staging|prod)$ ]]; then
        echo "Error: Invalid environment. Must be one of: dev, staging, prod"
        exit 1
    fi
}

# Function to rotate KMS key
rotate_kms_key() {
    local environment=$1
    echo "Rotating KMS key for environment: $environment"
    
    # Set environment variables
    export TF_VAR_environment="$environment"
    
    # Initialize Terraform
    cd "$(dirname "$0")/../terraform/aws"
    terraform init
    
    # Create new KMS key and alias
    terraform apply -target=aws_kms_key.main -target=aws_kms_alias.main_alias -auto-approve
    
    # Get the new KMS key ID
    local new_key_id=$(terraform output -raw kms_key_id)
    
    echo "New KMS key created with ID: $new_key_id"
    
    # Update dependent services to use the new key
    terraform apply -auto-approve
    
    echo "KMS key rotation completed successfully"
    return 0
}

# Function to rotate secrets in AWS Secrets Manager
rotate_secrets() {
    local environment=$1
    echo "Rotating secrets for environment: $environment"
    
    # Set AWS profile
    export AWS_PROFILE="$environment"
    
    # List all secrets
    local secrets=$(aws secretsmanager list-secrets --query 'SecretList[*].Name' --output text)
    
    # Rotate each secret
    for secret in $secrets; do
        echo "Rotating secret: $secret"
        
        # Initiate secret rotation
        aws secretsmanager rotate-secret \
            --secret-id "$secret" \
            --rotation-rules "{\"AutomaticallyAfterDays\": 30}"
        
        # Verify rotation status
        local rotation_status=$(aws secretsmanager describe-secret \
            --secret-id "$secret" \
            --query 'RotationEnabled' \
            --output text)
        
        if [ "$rotation_status" == "true" ]; then
            echo "Successfully rotated secret: $secret"
        else
            echo "Failed to rotate secret: $secret"
            return 1
        fi
    done
    
    echo "Secret rotation completed successfully"
    return 0
}

# Main script execution
main() {
    # Check if environment argument is provided
    if [ $# -lt 1 ]; then
        echo "Usage: $0 <environment> [--kms-only|--secrets-only]"
        echo "Environment must be one of: dev, staging, prod"
        exit 1
    fi
    
    local environment=$1
    local mode=${2:-"all"}
    
    # Validate environment
    validate_environment "$environment"
    
    # Execute rotations based on mode
    case $mode in
        "--kms-only")
            rotate_kms_key "$environment"
            ;;
        "--secrets-only")
            rotate_secrets "$environment"
            ;;
        *)
            # Rotate both KMS keys and secrets
            rotate_kms_key "$environment"
            rotate_secrets "$environment"
            ;;
    esac
    
    # Apply Terraform changes to update infrastructure
    source "$(dirname "$0")/apply-terraform.sh" "$environment"
    
    echo "Secret and key rotation completed successfully for environment: $environment"
}

# Execute main function with provided arguments
main "$@"
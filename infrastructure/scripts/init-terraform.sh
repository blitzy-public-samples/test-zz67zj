#!/bin/bash

# Human Tasks:
# 1. Ensure AWS credentials are properly configured in ~/.aws/credentials or environment variables
# 2. Verify S3 bucket exists for Terraform state storage
# 3. Review and adjust backend configuration parameters if needed
# 4. Ensure proper IAM permissions for Terraform state management
# 5. Verify network connectivity to AWS services

# Requirement addressed: Infrastructure Initialization (Technical Specification/7.4.3 Security Architecture)
# This script automates the initialization of Terraform configurations for consistent and secure
# infrastructure provisioning across different environments.

# Set error handling
set -euo pipefail

# Function to validate environment name
validate_environment() {
    local env=$1
    if [[ ! "$env" =~ ^(dev|staging|prod)$ ]]; then
        echo "Error: Invalid environment. Must be one of: dev, staging, prod"
        exit 1
    fi
}

# Function to initialize Terraform configuration
initialize_terraform() {
    local environment=$1
    
    echo "Initializing Terraform configuration for environment: $environment"
    
    # Set environment variables
    export TF_VAR_environment="$environment"
    
    # Determine AWS region based on environment
    case $environment in
        "dev")
            export TF_VAR_region="us-west-2"
            ;;
        "staging")
            export TF_VAR_region="us-east-2"
            ;;
        "prod")
            export TF_VAR_region="us-east-1"
            ;;
    esac
    
    # Navigate to Terraform configuration directory
    cd "$(dirname "$0")/../terraform/aws"
    
    # Initialize Terraform with backend configuration
    terraform init \
        -backend=true \
        -backend-config="bucket=dogwalker-terraform-state-${environment}" \
        -backend-config="key=terraform.tfstate" \
        -backend-config="region=${TF_VAR_region}" \
        -backend-config="encrypt=true" \
        -backend-config="dynamodb_table=dogwalker-terraform-locks-${environment}"
    
    # Validate Terraform configuration
    echo "Validating Terraform configuration..."
    terraform validate
    
    # Generate and show execution plan
    echo "Generating Terraform execution plan..."
    terraform plan -out=tfplan
}

# Function to apply Terraform configuration
apply_terraform() {
    local environment=$1
    
    echo "Applying Terraform configuration for environment: $environment"
    
    # Set environment variables
    export TF_VAR_environment="$environment"
    
    # Navigate to Terraform configuration directory
    cd "$(dirname "$0")/../terraform/aws"
    
    # Apply Terraform configuration
    terraform apply -auto-approve tfplan
}

# Main script execution
main() {
    # Check if environment argument is provided
    if [ $# -lt 1 ]; then
        echo "Usage: $0 <environment> [--apply]"
        echo "Environment must be one of: dev, staging, prod"
        exit 1
    fi
    
    local environment=$1
    local apply_flag=${2:-""}
    
    # Validate environment
    validate_environment "$environment"
    
    # Initialize Terraform
    initialize_terraform "$environment"
    
    # Apply if --apply flag is provided
    if [ "$apply_flag" == "--apply" ]; then
        apply_terraform "$environment"
    fi
}

# Execute main function with provided arguments
main "$@"
#!/bin/bash

# Human Tasks:
# 1. Ensure AWS credentials are properly configured in ~/.aws/credentials or environment variables
# 2. Verify S3 bucket exists for Terraform state storage
# 3. Review and adjust backend configuration parameters if needed
# 4. Ensure proper IAM permissions for Terraform state management
# 5. Verify network connectivity to AWS services

# Requirement addressed: Infrastructure Deployment (Technical Specification/7.4.3 Security Architecture)
# This script automates the application of Terraform configurations for consistent and secure
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

# Function to set environment-specific variables
set_environment_variables() {
    local environment=$1
    
    # Set environment variable
    export TF_VAR_environment="$environment"
    
    # Set region based on environment
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
}

# Function to initialize Terraform
initialize_terraform() {
    local environment=$1
    
    echo "Initializing Terraform for environment: $environment"
    
    # Navigate to environment-specific Terraform directory
    cd "$(dirname "$0")/../terraform/environments/$environment"
    
    # Initialize Terraform with backend configuration
    terraform init \
        -backend=true \
        -backend-config="bucket=dogwalker-terraform-state-${environment}" \
        -backend-config="key=terraform.tfstate" \
        -backend-config="region=${TF_VAR_region}" \
        -backend-config="encrypt=true" \
        -backend-config="dynamodb_table=dogwalker-terraform-locks-${environment}"
}

# Function to validate Terraform configuration
validate_terraform() {
    echo "Validating Terraform configuration..."
    terraform validate
}

# Function to plan Terraform changes
plan_terraform() {
    echo "Planning Terraform changes..."
    terraform plan -out=tfplan
}

# Function to apply Terraform changes
apply_terraform() {
    local environment=$1
    
    echo "Applying Terraform configuration for environment: $environment"
    terraform apply -auto-approve tfplan
}

# Main script execution
main() {
    # Check if environment argument is provided
    if [ $# -lt 1 ]; then
        echo "Usage: $0 <environment>"
        echo "Environment must be one of: dev, staging, prod"
        exit 1
    fi
    
    local environment=$1
    
    # Validate environment
    validate_environment "$environment"
    
    # Set environment variables
    set_environment_variables "$environment"
    
    # Initialize Terraform
    initialize_terraform "$environment"
    
    # Validate configuration
    validate_terraform
    
    # Plan changes
    plan_terraform
    
    # Apply changes
    apply_terraform "$environment"
    
    echo "Terraform apply completed successfully for environment: $environment"
}

# Execute main function with provided arguments
main "$@"
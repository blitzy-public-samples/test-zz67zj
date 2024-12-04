#!/bin/bash

# Human Tasks:
# 1. Configure Apple Developer account credentials in Fastlane match
# 2. Set up App Store Connect API key for automated uploads
# 3. Configure proper code signing certificates and provisioning profiles
# 4. Set up proper environment variables for different deployment targets

# Requirement: iOS Deployment Automation (Technical Specification/9.5 Development & Deployment/Build & Deployment)
# This script automates the deployment process for the DogWalker iOS application

# Exit on error
set -e

# Import dependencies
source "$(dirname "$0")/setup.sh"
source "$(dirname "$0")/build.sh"
source "$(dirname "$0")/test.sh"

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd)"
WORKSPACE="DogWalker.xcworkspace"
SCHEME="DogWalker"
CONFIGURATION="Release"
ARCHIVE_PATH="${PROJECT_DIR}/build/DogWalker.xcarchive"
IPA_PATH="${PROJECT_DIR}/build/DogWalker.ipa"
EXPORT_OPTIONS_PLIST="${PROJECT_DIR}/ExportOptions.plist"

# Colors for output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${2:-$GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

# Error handling function
handle_error() {
    log "Error: Deployment failed at line $1" "$RED"
    exit 1
}

# Set error handler
trap 'handle_error $LINENO' ERR

# Function to deploy the application
deploy() {
    log "Starting deployment process for DogWalker iOS application..."
    
    # Verify environment
    if [ -z "$DEPLOY_ENV" ]; then
        log "Error: DEPLOY_ENV not set" "$RED"
        exit 1
    fi
    
    if [ -z "$FASTLANE_LANE" ]; then
        log "Error: FASTLANE_LANE not set" "$RED"
        exit 1
    }
    
    # Set up environment
    log "Setting up environment..."
    setup_environment
    
    # Install dependencies
    log "Installing dependencies..."
    installDependencies
    
    # Run tests
    log "Running tests..."
    run_unit_tests
    run_ui_tests
    
    # Build project
    log "Building project..."
    buildProject
    
    # Package application
    log "Packaging application..."
    packageApp
    
    # Deploy using Fastlane
    log "Deploying using Fastlane..."
    cd "${PROJECT_DIR}"
    
    case "$DEPLOY_ENV" in
        "production")
            log "Deploying to App Store..." "$YELLOW"
            bundle exec fastlane ${FASTLANE_LANE} \
                --env production \
                --verbose
            ;;
        "staging")
            log "Deploying to TestFlight..." "$YELLOW"
            bundle exec fastlane beta \
                --env staging \
                --verbose
            ;;
        *)
            log "Invalid deployment environment: $DEPLOY_ENV" "$RED"
            exit 1
            ;;
    esac
    
    # Verify deployment
    if [ $? -eq 0 ]; then
        log "Deployment completed successfully!"
        
        # Clean up build artifacts
        if [ -d "${PROJECT_DIR}/build" ]; then
            log "Cleaning up build artifacts..."
            rm -rf "${PROJECT_DIR}/build"
        fi
    else
        log "Deployment failed" "$RED"
        exit 1
    fi
}

# Function to validate deployment prerequisites
validate_prerequisites() {
    log "Validating deployment prerequisites..."
    
    # Check for required tools
    command -v xcodebuild >/dev/null 2>&1 || { 
        log "Error: xcodebuild is required but not installed" "$RED"
        exit 1
    }
    
    command -v bundle >/dev/null 2>&1 || {
        log "Error: bundler is required but not installed" "$RED"
        exit 1
    }
    
    command -v fastlane >/dev/null 2>&1 || {
        log "Error: fastlane is required but not installed" "$RED"
        exit 1
    }
    
    # Check for required files
    if [ ! -f "${PROJECT_DIR}/${WORKSPACE}" ]; then
        log "Error: Workspace file not found at ${PROJECT_DIR}/${WORKSPACE}" "$RED"
        exit 1
    }
    
    if [ ! -f "${EXPORT_OPTIONS_PLIST}" ]; then
        log "Error: Export options plist not found at ${EXPORT_OPTIONS_PLIST}" "$RED"
        exit 1
    }
    
    log "Prerequisites validation completed"
}

# Main execution
main() {
    log "Starting DogWalker iOS deployment process..."
    
    # Validate prerequisites
    validate_prerequisites
    
    # Execute deployment
    deploy
    
    log "Deployment process completed successfully!"
}

# Execute main function
main
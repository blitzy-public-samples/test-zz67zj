#!/bin/bash

# Human Tasks:
# 1. Configure Xcode command line tools path if not using default installation
# 2. Set up code signing certificates and provisioning profiles
# 3. Configure build settings for different environments (dev/staging/prod)
# 4. Set up proper access permissions for the build directory

# Requirement: Development Environment Setup (Technical Specification/9.5 Development & Deployment/Development Tools)
# This script automates the setup of the iOS development environment, ensuring consistency and reducing manual errors.

# Exit on error
set -e

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd)"
COCOAPODS_VERSION="1.11.3"
MIN_XCODE_VERSION="14.0"

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
    log "Error: Setup failed at line $1" "$RED"
    exit 1
}

# Set error handler
trap 'handle_error $LINENO' ERR

# Function to check Xcode installation
check_xcode() {
    log "Checking Xcode installation..."
    
    if ! command -v xcodebuild &> /dev/null; then
        log "Xcode command line tools not found. Installing..." "$YELLOW"
        xcode-select --install
        return 1
    fi
    
    local xcode_version=$(xcodebuild -version | grep "Xcode" | cut -d' ' -f2)
    if [ "$(printf '%s\n' "$MIN_XCODE_VERSION" "$xcode_version" | sort -V | head -n1)" != "$MIN_XCODE_VERSION" ]; then
        log "Xcode version $xcode_version is below minimum required version $MIN_XCODE_VERSION" "$RED"
        return 1
    fi
    
    log "Xcode version $xcode_version is installed"
    return 0
}

# Function to install/update CocoaPods
install_cocoapods() {
    log "Installing CocoaPods version $COCOAPODS_VERSION..."
    
    if ! command -v gem &> /dev/null; then
        log "Ruby gem command not found. Please install Ruby first." "$RED"
        exit 1
    }
    
    # Install or update CocoaPods
    if ! command -v pod &> /dev/null; then
        sudo gem install cocoapods -v $COCOAPODS_VERSION
    else
        local current_version=$(pod --version)
        if [ "$current_version" != "$COCOAPODS_VERSION" ]; then
            log "Updating CocoaPods from $current_version to $COCOAPODS_VERSION..." "$YELLOW"
            sudo gem install cocoapods -v $COCOAPODS_VERSION
        fi
    fi
    
    log "CocoaPods $COCOAPODS_VERSION installed successfully"
}

# Function to install dependencies using CocoaPods
install_dependencies() {
    log "Installing project dependencies..."
    
    cd "$PROJECT_DIR"
    
    # Install pods
    pod install --repo-update
    
    log "Dependencies installed successfully"
}

# Function to setup Fastlane
setup_fastlane() {
    log "Setting up Fastlane..."
    
    if ! command -v fastlane &> /dev/null; then
        log "Installing Fastlane..." "$YELLOW"
        sudo gem install fastlane
    fi
    
    # Initialize Fastlane if not already set up
    if [ ! -d "$PROJECT_DIR/fastlane" ]; then
        cd "$PROJECT_DIR"
        fastlane init
    fi
    
    log "Fastlane setup completed"
}

# Function to verify and setup code signing
setup_code_signing() {
    log "Setting up code signing..."
    
    # Check for required certificates
    if ! security find-identity -v -p codesigning | grep -q "iPhone Developer"; then
        log "No iOS development certificates found. Please install required certificates." "$YELLOW"
    fi
    
    # Setup Fastlane Match if configured
    if [ -f "$PROJECT_DIR/fastlane/Matchfile" ]; then
        log "Running Fastlane Match to sync certificates..."
        cd "$PROJECT_DIR"
        fastlane match development
    fi
    
    log "Code signing setup completed"
}

# Function to configure build settings
configure_build_settings() {
    log "Configuring build settings..."
    
    # Create build directory if it doesn't exist
    mkdir -p "$PROJECT_DIR/build"
    
    # Set proper permissions
    chmod -R 755 "$PROJECT_DIR/build"
    
    log "Build settings configured successfully"
}

# Main execution
main() {
    log "Starting DogWalker iOS development environment setup..."
    
    # Check and setup Xcode
    check_xcode
    
    # Install/update CocoaPods
    install_cocoapods
    
    # Install project dependencies
    install_dependencies
    
    # Setup Fastlane
    setup_fastlane
    
    # Setup code signing
    setup_code_signing
    
    # Configure build settings
    configure_build_settings
    
    log "Setup completed successfully!"
}

# Execute main function
main
#!/bin/bash

# Human Tasks:
# 1. Configure Xcode command line tools path if not using default installation
# 2. Set up code signing certificates and provisioning profiles
# 3. Configure build settings for different environments (dev/staging/prod)
# 4. Set up proper access permissions for the build directory

# Requirement: iOS Build Automation (Technical Specification/9.5 Development & Deployment/Build & Deployment)
# This script automates the build process for the DogWalker iOS application

# Exit on error
set -e

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd)"
BUILD_DIR="${PROJECT_DIR}/build"
WORKSPACE="DogWalker.xcworkspace"
SCHEME="DogWalker"
CONFIGURATION="Release"
ARCHIVE_PATH="${BUILD_DIR}/DogWalker.xcarchive"
IPA_PATH="${BUILD_DIR}/DogWalker.ipa"
EXPORT_OPTIONS_PLIST="${PROJECT_DIR}/ExportOptions.plist"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Error handling function
handle_error() {
    log "Error: Build failed at line $1"
    exit 1
}

# Set error handler
trap 'handle_error $LINENO' ERR

# Function to install dependencies using CocoaPods
installDependencies() {
    log "Installing dependencies..."
    
    # Verify CocoaPods installation
    if ! command -v pod &> /dev/null; then
        log "Error: CocoaPods not found. Please install CocoaPods first."
        exit 1
    }
    
    # Navigate to project directory
    cd "${PROJECT_DIR}"
    
    # Install pods
    pod install --repo-update
    
    if [ $? -eq 0 ]; then
        log "Dependencies installed successfully"
    else
        log "Error: Failed to install dependencies"
        exit 1
    fi
}

# Function to build the project
buildProject() {
    log "Building project..."
    
    # Create build directory if it doesn't exist
    mkdir -p "${BUILD_DIR}"
    
    # Clean build directory
    if [ -d "${BUILD_DIR}" ]; then
        log "Cleaning build directory..."
        rm -rf "${BUILD_DIR}/*"
    fi
    
    # Build the archive
    xcodebuild archive \
        -workspace "${WORKSPACE}" \
        -scheme "${SCHEME}" \
        -configuration "${CONFIGURATION}" \
        -archivePath "${ARCHIVE_PATH}" \
        DEVELOPMENT_TEAM="${DEVELOPMENT_TEAM_ID}" \
        CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY}" \
        CODE_SIGN_STYLE="Manual" \
        | xcpretty
    
    if [ $? -eq 0 ]; then
        log "Project built successfully"
    else
        log "Error: Failed to build project"
        exit 1
    fi
}

# Function to package the application
packageApp() {
    log "Packaging application..."
    
    # Verify archive exists
    if [ ! -d "${ARCHIVE_PATH}" ]; then
        log "Error: Archive not found at ${ARCHIVE_PATH}"
        exit 1
    }
    
    # Export IPA
    xcodebuild -exportArchive \
        -archivePath "${ARCHIVE_PATH}" \
        -exportOptionsPlist "${EXPORT_OPTIONS_PLIST}" \
        -exportPath "${BUILD_DIR}" \
        | xcpretty
    
    if [ $? -eq 0 ]; then
        log "Application packaged successfully"
        log "IPA location: ${IPA_PATH}"
    else
        log "Error: Failed to package application"
        exit 1
    fi
}

# Main execution
main() {
    log "Starting build process for DogWalker iOS application..."
    
    # Verify Xcode installation
    if ! command -v xcodebuild &> /dev/null; then
        log "Error: Xcode command line tools not found"
        exit 1
    }
    
    # Execute build steps
    installDependencies
    buildProject
    packageApp
    
    log "Build process completed successfully"
}

# Execute main function
main
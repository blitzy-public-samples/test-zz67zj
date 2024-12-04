#!/bin/bash

# Human Tasks:
# 1. Ensure Docker v24.0.5 is installed and configured on the build system
# 2. Configure appropriate permissions for Docker operations
# 3. Set up monitoring for build failures in CI/CD pipeline
# 4. Configure appropriate resource limits for Docker builds
# 5. Ensure sufficient disk space for build artifacts

# Addresses requirement: Build Automation
# Location: 9.5 Development & Deployment/Build & Deployment
# Description: Automates the build process for backend services to streamline 
# the development and deployment pipeline.

# Exit on any error
set -e
set -o pipefail

# Import dependencies
source "$(dirname "$0")/proto-gen.sh"

# Define build constants
BUILD_DIR="build"
DOCKERFILE_PATH="Dockerfile"
DOCKER_IMAGE_TAG="latest"

# Function to run tests for backend services
run_tests() {
    echo "Running backend service tests..."
    
    # Create test output directory
    mkdir -p "${BUILD_DIR}/test-results"
    
    # Run unit tests
    go test ./... -v -coverprofile="${BUILD_DIR}/test-results/coverage.out" || {
        echo "Unit tests failed"
        return 1
    }
    
    # Run integration tests
    go test ./... -tags=integration -v || {
        echo "Integration tests failed"
        return 1
    }
    
    echo "All tests passed successfully"
    return 0
}

# Function to migrate database schema
migrate_database() {
    echo "Running database migrations..."
    
    # Set up database connection parameters
    DB_HOST=${DB_HOST:-"localhost"}
    DB_PORT=${DB_PORT:-5432}
    DB_NAME=${DB_NAME:-"dogwalking"}
    
    # Run migrations using golang-migrate
    migrate -path db/migrations -database "postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}?sslmode=disable" up || {
        echo "Database migration failed"
        return 1
    }
    
    echo "Database migrations completed successfully"
    return 0
}

# Main function to build services
build_services() {
    echo "Starting backend services build process..."
    
    # Create build directory
    mkdir -p "${BUILD_DIR}"
    
    # Generate Protocol Buffer code
    echo "Generating Protocol Buffer code..."
    generate_proto_code || {
        echo "Protocol Buffer code generation failed"
        return 1
    }
    
    # Run tests
    echo "Running tests..."
    run_tests || {
        echo "Tests failed"
        return 1
    }
    
    # Run database migrations
    echo "Running database migrations..."
    migrate_database || {
        echo "Database migration failed"
        return 1
    }
    
    # Build Go binaries
    echo "Building Go binaries..."
    go build -o "${BUILD_DIR}/server" ./cmd/server || {
        echo "Go build failed"
        return 1
    }
    
    # Build Docker image
    echo "Building Docker image..."
    docker build \
        --tag "dogwalking-backend:${DOCKER_IMAGE_TAG}" \
        --file "${DOCKERFILE_PATH}" \
        --build-arg BUILD_DIR="${BUILD_DIR}" \
        . || {
        echo "Docker build failed"
        return 1
    }
    
    echo "Backend services build completed successfully"
    return 0
}

# Execute main build function
if build_services; then
    echo "Build process completed successfully"
    exit 0
else
    echo "Build process failed"
    exit 1
fi
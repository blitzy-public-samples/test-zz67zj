#!/bin/bash

# Human Tasks:
# 1. Ensure JUnit 5.9.3 is installed and configured in the test environment
# 2. Configure Postman CLI 10.15.0 for automated API testing
# 3. Set up test result monitoring in CI/CD pipeline
# 4. Configure test coverage thresholds
# 5. Set up alerts for test failures in production environment

# Addresses requirement: Testing Automation
# Location: 9.5 Development & Deployment/Build & Deployment
# Description: Ensures consistent and automated testing of backend services 
# to streamline the development pipeline.

# Exit on any error
set -e
set -o pipefail

# Import dependencies
source "$(dirname "$0")/proto-gen.sh"
source "$(dirname "$0")/build.sh"

# Environment variables
export TEST_ENV=${TEST_ENV:-"test"}
export REPORT_DIR=${REPORT_DIR:-"test-reports"}
export LOG_LEVEL=${LOG_LEVEL:-"debug"}

# Test configuration
JUNIT_REPORT_PATH="${REPORT_DIR}/junit"
POSTMAN_REPORT_PATH="${REPORT_DIR}/postman"
COVERAGE_THRESHOLD=80

# Function to set up test environment
setup_test_environment() {
    echo "Setting up test environment..."
    
    # Create report directories
    mkdir -p "${JUNIT_REPORT_PATH}"
    mkdir -p "${POSTMAN_REPORT_PATH}"
    
    # Generate Protocol Buffer code for testing
    echo "Generating Protocol Buffer code..."
    generate_proto_code || {
        echo "Failed to generate Protocol Buffer code"
        return 1
    }
    
    # Build services for testing
    echo "Building services for testing..."
    build_services || {
        echo "Failed to build services"
        return 1
    }
    
    echo "Test environment setup completed"
    return 0
}

# Function to run unit tests
run_unit_tests() {
    echo "Running unit tests..."
    
    # Run JUnit tests
    java -jar junit-platform-console-standalone-5.9.3.jar \
        --scan-classpath \
        --reports-dir="${JUNIT_REPORT_PATH}" \
        --details=verbose \
        || {
        echo "Unit tests failed"
        return 1
    }
    
    # Check test coverage
    local coverage=$(awk -F"," '{ instructions += $4 + $5; covered += $5 } END \
        { print covered/instructions*100 }' "${JUNIT_REPORT_PATH}/coverage.csv")
    
    if (( $(echo "$coverage < $COVERAGE_THRESHOLD" | bc -l) )); then
        echo "Test coverage ($coverage%) is below threshold ($COVERAGE_THRESHOLD%)"
        return 1
    }
    
    echo "Unit tests completed successfully"
    return 0
}

# Function to run integration tests
run_integration_tests() {
    echo "Running integration tests..."
    
    # Ensure database schema consistency
    echo "Ensuring database schema consistency..."
    migrate_database || {
        echo "Database migration failed"
        return 1
    }
    
    # Deploy services to test environment
    echo "Deploying services to test environment..."
    docker-compose -f docker-compose.test.yml up -d || {
        echo "Service deployment failed"
        return 1
    }
    
    # Run Postman integration tests
    echo "Running API integration tests..."
    postman collection run ./tests/postman/collection.json \
        --environment ./tests/postman/test-env.json \
        --reporters cli,junit \
        --reporter-junit-export "${POSTMAN_REPORT_PATH}/results.xml" \
        || {
        echo "Integration tests failed"
        docker-compose -f docker-compose.test.yml down
        return 1
    }
    
    # Clean up test environment
    docker-compose -f docker-compose.test.yml down
    
    echo "Integration tests completed successfully"
    return 0
}

# Function to generate test report
generate_test_report() {
    echo "Generating test report..."
    
    # Create consolidated report directory
    local report_file="${REPORT_DIR}/consolidated-report.html"
    
    # Combine unit and integration test results
    echo "<html><body>" > "${report_file}"
    echo "<h1>Test Results Summary</h1>" >> "${report_file}"
    
    # Add unit test results
    echo "<h2>Unit Tests</h2>" >> "${report_file}"
    xsltproc -o "${report_file}.tmp" \
        "${JUNIT_REPORT_PATH}/junit-noframes.xsl" \
        "${JUNIT_REPORT_PATH}/TEST-junit-jupiter.xml"
    cat "${report_file}.tmp" >> "${report_file}"
    
    # Add integration test results
    echo "<h2>Integration Tests</h2>" >> "${report_file}"
    xsltproc -o "${report_file}.tmp" \
        "${POSTMAN_REPORT_PATH}/postman-noframes.xsl" \
        "${POSTMAN_REPORT_PATH}/results.xml"
    cat "${report_file}.tmp" >> "${report_file}"
    
    echo "</body></html>" >> "${report_file}"
    rm "${report_file}.tmp"
    
    echo "Test report generated at ${report_file}"
    return 0
}

# Main function to orchestrate testing process
main() {
    echo "Starting test execution..."
    
    # Set up test environment
    setup_test_environment || {
        echo "Test environment setup failed"
        return 1
    }
    
    # Run unit tests
    run_unit_tests || {
        echo "Unit tests failed"
        return 1
    }
    
    # Run integration tests
    run_integration_tests || {
        echo "Integration tests failed"
        return 1
    }
    
    # Generate test report
    generate_test_report || {
        echo "Test report generation failed"
        return 1
    }
    
    echo "Test execution completed successfully"
    return 0
}

# Execute main function
if main; then
    echo "Testing process completed successfully"
    exit 0
else
    echo "Testing process failed"
    exit 1
fi
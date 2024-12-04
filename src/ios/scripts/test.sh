#!/bin/bash

# Human Tasks:
# 1. Ensure Xcode Command Line Tools are installed
# 2. Configure proper test schemes in Xcode project
# 3. Set up proper test device/simulator configuration
# 4. Verify xcpretty is installed (gem install xcpretty)

# Requirements addressed:
# - Automated Testing (Technical Specification/Development & Deployment/CI/CD Pipeline)
# Ensures that all unit and UI tests are executed automatically as part of the CI/CD pipeline.

# Set error handling
set -e

# Define constants
TEST_SCHEME="DogWalkerTests"
UI_TEST_SCHEME="DogWalkerUITests"
DESTINATION="platform=iOS Simulator,name=iPhone 14,OS=16.0"

# Colors for output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print formatted output
print_status() {
    echo -e "${2}===> ${1}${NC}"
}

# Function to run unit tests
run_unit_tests() {
    print_status "Running unit tests..." "${YELLOW}"
    
    # Execute unit tests
    xcodebuild test \
        -scheme "$TEST_SCHEME" \
        -destination "$DESTINATION" \
        -resultBundlePath TestResults/UnitTests \
        | xcpretty
    
    # Check exit status
    if [ $? -eq 0 ]; then
        print_status "Unit tests completed successfully" "${GREEN}"
        return 0
    else
        print_status "Unit tests failed" "${RED}"
        return 1
    fi
}

# Function to run UI tests
run_ui_tests() {
    print_status "Running UI tests..." "${YELLOW}"
    
    # Execute UI tests
    xcodebuild test \
        -scheme "$UI_TEST_SCHEME" \
        -destination "$DESTINATION" \
        -resultBundlePath TestResults/UITests \
        | xcpretty
    
    # Check exit status
    if [ $? -eq 0 ]; then
        print_status "UI tests completed successfully" "${GREEN}"
        return 0
    else
        print_status "UI tests failed" "${RED}"
        return 1
    fi
}

# Create TestResults directory if it doesn't exist
mkdir -p TestResults

# Print test configuration
print_status "Test Configuration:" "${YELLOW}"
echo "Unit Test Scheme: $TEST_SCHEME"
echo "UI Test Scheme: $UI_TEST_SCHEME"
echo "Destination: $DESTINATION"
echo ""

# Run tests
unit_test_result=0
ui_test_result=0

# Run unit tests
run_unit_tests
unit_test_result=$?

# Run UI tests
run_ui_tests
ui_test_result=$?

# Print final results
echo ""
print_status "Test Results Summary:" "${YELLOW}"
if [ $unit_test_result -eq 0 ]; then
    print_status "Unit Tests: Passed" "${GREEN}"
else
    print_status "Unit Tests: Failed" "${RED}"
fi

if [ $ui_test_result -eq 0 ]; then
    print_status "UI Tests: Passed" "${GREEN}"
else
    print_status "UI Tests: Failed" "${RED}"
fi

# Exit with failure if any test suite failed
if [ $unit_test_result -ne 0 ] || [ $ui_test_result -ne 0 ]; then
    print_status "One or more test suites failed" "${RED}"
    exit 1
fi

print_status "All tests passed successfully" "${GREEN}"
exit 0
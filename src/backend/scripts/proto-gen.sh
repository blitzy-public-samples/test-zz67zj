#!/bin/bash

# Human Tasks:
# 1. Ensure protoc compiler v3.21.12 is installed on the system
# 2. Ensure grpc-tools v1.13.1 is installed for gRPC code generation
# 3. Configure appropriate file permissions for the output directories
# 4. Set up monitoring for proto compilation failures in CI/CD pipeline

# Addresses requirement: Protocol Buffer Code Generation
# Location: 7.3 Technical Decisions/Architecture Patterns
# Description: Automates the generation of protocol buffer code for consistent 
# and efficient communication between microservices.

# Set error handling
set -e
set -o pipefail

# Define directories
PROTO_DIR="src/backend/shared/proto"
OUT_DIR="src/backend/generated"

# Create output directory if it doesn't exist
mkdir -p "${OUT_DIR}"

# Function to generate protocol buffer code for a single file
generate_proto() {
    local proto_file="$1"
    local proto_name=$(basename "${proto_file}" .proto)
    
    echo "Generating code for ${proto_name}..."
    
    # Create language-specific output directories
    mkdir -p "${OUT_DIR}/typescript"
    mkdir -p "${OUT_DIR}/go"
    
    # Generate TypeScript code
    protoc \
        --plugin="protoc-gen-ts=./node_modules/.bin/protoc-gen-ts" \
        --ts_out="service=grpc-web:${OUT_DIR}/typescript" \
        --js_out="import_style=commonjs,binary:${OUT_DIR}/typescript" \
        --proto_path="${PROTO_DIR}" \
        "${proto_file}"
    
    # Generate Go code
    protoc \
        --go_out="${OUT_DIR}/go" \
        --go_opt=paths=source_relative \
        --go-grpc_out="${OUT_DIR}/go" \
        --go-grpc_opt=paths=source_relative \
        --proto_path="${PROTO_DIR}" \
        "${proto_file}"
}

# Main function to process all proto files
main() {
    echo "Starting protocol buffer code generation..."
    
    # Process each .proto file in the PROTO_DIR
    for proto_file in "${PROTO_DIR}"/*.proto; do
        if [ -f "${proto_file}" ]; then
            generate_proto "${proto_file}"
        fi
    done
    
    echo "Protocol buffer code generation completed successfully"
}

# Execute main function
main

# Exit with success
exit 0
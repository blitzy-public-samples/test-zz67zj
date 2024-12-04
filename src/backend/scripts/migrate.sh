#!/bin/bash

# Human Tasks:
# 1. Ensure Flyway CLI is installed (version 8.5.13)
# 2. Verify database connection credentials are properly configured in Kubernetes secrets
# 3. Set up monitoring for migration job execution
# 4. Configure backup strategy before running migrations
# 5. Review migration scripts in MIGRATION_DIR for correctness
# 6. Set up proper RBAC permissions for the migration job

# Addresses requirement: Database Migration Automation
# Location: 7.3 Technical Decisions/Architecture Patterns
# Description: Ensures consistent and automated application of database schema changes

# Set error handling
set -e
set -o pipefail

# Load environment variables from Kubernetes ConfigMap
DB_URL=${DB_URL:-"jdbc:postgresql://postgres.default.svc.cluster.local:5432/dogwalker"}
DB_USER=${DB_USER:-"dogwalker_user"}
DB_PASSWORD=${DB_PASSWORD:-"encrypted_value"}
MIGRATION_DIR=${MIGRATION_DIR:-"src/backend/migrations"}

# Flyway CLI command with version 8.5.13
FLYWAY_CMD="flyway -url=${DB_URL} -user=${DB_USER} -password=${DB_PASSWORD} -locations=filesystem:${MIGRATION_DIR}"

# Function to check database availability
check_database() {
    echo "Checking database availability..."
    for i in {1..30}; do
        if pg_isready -h postgres.default.svc.cluster.local -U ${DB_USER}; then
            echo "Database is ready"
            return 0
        fi
        echo "Waiting for database to be ready... (attempt $i/30)"
        sleep 2
    done
    echo "Database connection timeout"
    return 1
}

# Function to apply migrations
# Addresses requirement: Database Migration Automation
apply_migrations() {
    echo "Starting database migration process..."
    
    # Check database availability
    check_database || exit 1
    
    # Validate migration files
    echo "Validating migration files..."
    ${FLYWAY_CMD} validate
    if [ $? -ne 0 ]; then
        echo "Migration validation failed"
        return 1
    fi
    
    # Create schema history table if it doesn't exist
    echo "Initializing schema history..."
    ${FLYWAY_CMD} baseline -baselineOnMigrate=true
    
    # Apply migrations
    echo "Applying migrations..."
    ${FLYWAY_CMD} migrate
    
    # Check migration status
    echo "Checking migration status..."
    ${FLYWAY_CMD} info
    
    echo "Migration process completed successfully"
    return 0
}

# Function to rollback migration
# Addresses requirement: Database Migration Automation
rollback_migration() {
    echo "Starting migration rollback process..."
    
    # Check database availability
    check_database || exit 1
    
    # Get current version before rollback
    current_version=$(${FLYWAY_CMD} info -output=json | jq -r '.migrations[-1].version')
    
    echo "Rolling back migration from version ${current_version}..."
    ${FLYWAY_CMD} undo
    
    if [ $? -eq 0 ]; then
        echo "Rollback completed successfully"
        ${FLYWAY_CMD} info
        return 0
    else
        echo "Rollback failed"
        return 1
    fi
}

# Main execution
case "$1" in
    "migrate")
        apply_migrations
        ;;
    "rollback")
        rollback_migration
        ;;
    *)
        echo "Usage: $0 {migrate|rollback}"
        exit 1
        ;;
esac

exit $?
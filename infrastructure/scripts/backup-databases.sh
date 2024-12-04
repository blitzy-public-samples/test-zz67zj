#!/bin/bash

# Human Tasks:
# 1. Ensure AWS CLI v2.12.0 or higher is installed
# 2. Configure AWS credentials with appropriate permissions for RDS and DocumentDB operations
# 3. Verify S3 bucket exists and has proper encryption settings
# 4. Review backup retention periods and adjust if needed
# 5. Set up monitoring for backup job success/failure
# 6. Configure backup schedule in crontab

# Set error handling
set -euo pipefail

# Requirement addressed: Database Backup (Technical Specification/7.2.2 Data Storage Components)
# This script implements automated backup processes for RDS and DocumentDB databases

# Requirement addressed: Data Security (Technical Specification/10.2 Data Security)
# Ensures sensitive data is securely backed up and stored in an encrypted S3 bucket

# Import required dependencies
source "$(dirname "$0")/rotate-secrets.sh"

# Global variables
AWS_REGION="us-east-1"
S3_BACKUP_BUCKET="dogwalker-backups"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_PREFIX="database-backups"
LOG_FILE="/var/log/dogwalker/database-backups.log"

# Function to log messages
log_message() {
    local message=$1
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" | tee -a "$LOG_FILE"
}

# Function to validate S3 bucket encryption
validate_s3_encryption() {
    local bucket=$1
    local encryption_status=$(aws s3api get-bucket-encryption --bucket "$bucket" 2>/dev/null || echo "NotConfigured")
    
    if [[ $encryption_status == "NotConfigured" ]]; then
        log_message "ERROR: S3 bucket $bucket is not encrypted"
        return 1
    fi
    return 0
}

# Function to backup RDS database
backup_rds() {
    local db_instance_identifier=$1
    log_message "Starting RDS backup for instance: $db_instance_identifier"
    
    # Create RDS snapshot
    local snapshot_identifier="manual-${db_instance_identifier}-${TIMESTAMP}"
    aws rds create-db-snapshot \
        --db-instance-identifier "$db_instance_identifier" \
        --db-snapshot-identifier "$snapshot_identifier" \
        --region "$AWS_REGION"
    
    # Wait for snapshot to complete
    log_message "Waiting for RDS snapshot to complete..."
    aws rds wait db-snapshot-available \
        --db-snapshot-identifier "$snapshot_identifier" \
        --region "$AWS_REGION"
    
    # Export snapshot to S3
    local s3_path="s3://${S3_BACKUP_BUCKET}/${BACKUP_PREFIX}/rds/${db_instance_identifier}/${TIMESTAMP}"
    aws rds start-export-task \
        --source-arn "arn:aws:rds:${AWS_REGION}:$(aws sts get-caller-identity --query Account --output text):snapshot:${snapshot_identifier}" \
        --s3-bucket-name "$S3_BACKUP_BUCKET" \
        --s3-prefix "${BACKUP_PREFIX}/rds/${db_instance_identifier}/${TIMESTAMP}" \
        --iam-role-arn "$(aws rds describe-db-instances --db-instance-identifier "$db_instance_identifier" --query 'DBInstances[0].IAMDatabaseAuthenticationEnabled' --output text)" \
        --kms-key-id "$(aws kms list-aliases --query 'Aliases[?AliasName==`alias/aws/rds`].TargetKeyId' --output text)" \
        --region "$AWS_REGION"
    
    log_message "RDS backup completed successfully: $s3_path"
    return 0
}

# Function to backup DocumentDB cluster
backup_docdb() {
    local cluster_identifier=$1
    log_message "Starting DocumentDB backup for cluster: $cluster_identifier"
    
    # Create DocumentDB snapshot
    local snapshot_identifier="manual-${cluster_identifier}-${TIMESTAMP}"
    aws docdb create-db-cluster-snapshot \
        --db-cluster-identifier "$cluster_identifier" \
        --db-cluster-snapshot-identifier "$snapshot_identifier" \
        --region "$AWS_REGION"
    
    # Wait for snapshot to complete
    log_message "Waiting for DocumentDB snapshot to complete..."
    aws docdb wait db-cluster-snapshot-available \
        --db-cluster-snapshot-identifier "$snapshot_identifier" \
        --region "$AWS_REGION"
    
    # Export snapshot to S3
    local s3_path="s3://${S3_BACKUP_BUCKET}/${BACKUP_PREFIX}/docdb/${cluster_identifier}/${TIMESTAMP}"
    aws s3 cp \
        "$(aws docdb describe-db-cluster-snapshots --db-cluster-snapshot-identifier "$snapshot_identifier" --query 'DBClusterSnapshots[0].SnapshotCreateTime' --output text)" \
        "$s3_path" \
        --region "$AWS_REGION"
    
    log_message "DocumentDB backup completed successfully: $s3_path"
    return 0
}

# Function to validate backup integrity
validate_backup() {
    local backup_file_name=$1
    log_message "Validating backup integrity: $backup_file_name"
    
    # Check if backup file exists in S3
    if ! aws s3 ls "s3://${S3_BACKUP_BUCKET}/${BACKUP_PREFIX}/${backup_file_name}" &>/dev/null; then
        log_message "ERROR: Backup file not found in S3: $backup_file_name"
        return 1
    }
    
    # Verify backup file checksum
    local original_checksum=$(aws s3api head-object \
        --bucket "$S3_BACKUP_BUCKET" \
        --key "${BACKUP_PREFIX}/${backup_file_name}" \
        --query 'Metadata.checksum' \
        --output text)
    
    local current_checksum=$(aws s3api get-object \
        --bucket "$S3_BACKUP_BUCKET" \
        --key "${BACKUP_PREFIX}/${backup_file_name}" \
        --query 'Metadata.checksum' \
        --output text)
    
    if [[ "$original_checksum" != "$current_checksum" ]]; then
        log_message "ERROR: Backup validation failed for: $backup_file_name"
        return 1
    }
    
    log_message "Backup validation successful: $backup_file_name"
    return 0
}

# Main execution
main() {
    log_message "Starting database backup process"
    
    # Validate S3 bucket encryption
    if ! validate_s3_encryption "$S3_BACKUP_BUCKET"; then
        log_message "ERROR: S3 bucket validation failed"
        exit 1
    }
    
    # Rotate secrets before backup
    if ! rotate_secret "rds_credentials" && rotate_secret "docdb_credentials"; then
        log_message "ERROR: Failed to rotate secrets"
        exit 1
    }
    
    # Backup RDS database
    local rds_instance_id="dog-walker-db"
    if ! backup_rds "$rds_instance_id"; then
        log_message "ERROR: RDS backup failed"
        exit 1
    fi
    
    # Backup DocumentDB cluster
    local docdb_cluster_id="dogwalker-documentdb"
    if ! backup_docdb "$docdb_cluster_id"; then
        log_message "ERROR: DocumentDB backup failed"
        exit 1
    }
    
    # Validate backups
    for backup_type in "rds" "docdb"; do
        local backup_path="${BACKUP_PREFIX}/${backup_type}/*/${TIMESTAMP}/*"
        if ! validate_backup "$backup_path"; then
            log_message "ERROR: Backup validation failed for $backup_type"
            exit 1
        fi
    done
    
    log_message "Database backup process completed successfully"
}

# Execute main function
main "$@"
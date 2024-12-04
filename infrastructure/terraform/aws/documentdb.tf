# AWS Provider Version: 5.0.0

# Human Tasks:
# 1. Ensure AWS credentials are properly configured
# 2. Store and manage DocumentDB master password securely (e.g., AWS Secrets Manager)
# 3. Review and adjust security group CIDR blocks based on network requirements
# 4. Verify VPC and subnet configurations are properly set up
# 5. Configure backup and maintenance windows according to operational requirements

# Requirement addressed: Infrastructure as Code (Technical Specification/7.4.3 Security Architecture)
# This file defines the Amazon DocumentDB cluster configuration for the Dog Walker Booking platform,
# implementing secure and scalable document database infrastructure.

# Main DocumentDB Cluster
resource "aws_docdb_cluster" "main" {
  cluster_identifier = "dogwalker-documentdb"
  engine            = "docdb"
  
  # Authentication
  master_username = "admin"
  master_password = var.docdb_master_password

  # Network Configuration
  vpc_security_group_ids = [aws_security_group.docdb.id]
  db_subnet_group_name   = aws_db_subnet_group.docdb.name

  # Backup Configuration
  backup_retention_period = 7
  preferred_backup_window = "03:00-05:00"
  skip_final_snapshot    = false
  
  # Maintenance Configuration
  preferred_maintenance_window = "Mon:05:00-Mon:06:00"

  # Enable encryption at rest
  storage_encrypted = true

  # Enable deletion protection for production
  deletion_protection = true

  tags = {
    Name        = "dogwalker-documentdb"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# DocumentDB Instance
resource "aws_docdb_cluster_instance" "instance" {
  identifier         = "dogwalker-docdb-instance"
  cluster_identifier = aws_docdb_cluster.main.id
  instance_class     = "db.r5.large"

  # Enable enhanced monitoring
  monitoring_interval = 60
  
  # Enable auto minor version upgrades
  auto_minor_version_upgrade = true

  tags = {
    Name        = "dogwalker-docdb-instance"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Subnet Group for DocumentDB
resource "aws_db_subnet_group" "docdb" {
  name        = "dogwalker-docdb-subnet-group"
  subnet_ids  = module.vpc.private_subnet_ids
  description = "Subnet group for DocumentDB cluster"

  tags = {
    Name        = "dogwalker-docdb-subnet-group"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Security Group for DocumentDB
resource "aws_security_group" "docdb" {
  name        = "dogwalker-docdb-sg"
  description = "Security group for DocumentDB"
  vpc_id      = module.vpc.vpc_id

  # Ingress rule for DocumentDB port (27017)
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # VPC CIDR range
    description = "Allow DocumentDB access from within VPC"
  }

  # Egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "dogwalker-docdb-sg"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# CloudWatch Log Group for DocumentDB Logs
resource "aws_cloudwatch_log_group" "docdb" {
  name              = "/aws/docdb/dogwalker-documentdb"
  retention_in_days = 30

  tags = {
    Name        = "dogwalker-docdb-logs"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Parameter Group for DocumentDB
resource "aws_docdb_cluster_parameter_group" "main" {
  family      = "docdb4.0"
  name        = "dogwalker-docdb-params"
  description = "DocumentDB parameter group for Dog Walker platform"

  parameter {
    name  = "tls"
    value = "enabled"
  }

  parameter {
    name  = "audit_logs"
    value = "enabled"
  }

  tags = {
    Name        = "dogwalker-docdb-params"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
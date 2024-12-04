#!/bin/bash

# Human Tasks:
# 1. Ensure Docker and Docker Compose are installed
# 2. Configure firewall rules to allow monitoring stack ports
# 3. Set up appropriate authentication for monitoring services
# 4. Configure backup strategy for monitoring data
# 5. Review and adjust retention periods based on requirements
# 6. Set up alerting channels (email, Slack, PagerDuty)

# Requirement: Monitoring and Observability (Technical Specification/7.4 Cross-Cutting Concerns/7.4.1 Monitoring and Observability)
# This script automates the deployment and configuration of monitoring tools to ensure system observability and alerting.

set -e

# Default values
MONITORING_DIR="/opt/monitoring"
CONFIG_DIR="$MONITORING_DIR/config"
DATA_DIR="$MONITORING_DIR/data"
DEFAULT_RETENTION_PERIOD="30d"
DEFAULT_STORAGE_BACKEND="S3"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    log_error "Please run as root"
    exit 1
fi

# Create required directories
create_directories() {
    log_info "Creating monitoring directories..."
    mkdir -p "$CONFIG_DIR"/{prometheus,alertmanager,grafana,loki,tempo}
    mkdir -p "$DATA_DIR"/{prometheus,alertmanager,grafana,loki,tempo}
    chmod -R 755 "$MONITORING_DIR"
}

# Configure Prometheus
setup_prometheus() {
    log_info "Configuring Prometheus..."
    
    # Copy Prometheus configuration
    cp infrastructure/monitoring/prometheus/prometheus.yml "$CONFIG_DIR/prometheus/"
    cp -r infrastructure/monitoring/prometheus/rules "$CONFIG_DIR/prometheus/"
    
    # Set proper permissions
    chown -R nobody:nobody "$CONFIG_DIR/prometheus"
    chmod -R 644 "$CONFIG_DIR/prometheus"/*.yml
}

# Configure Alertmanager
setup_alertmanager() {
    log_info "Configuring Alertmanager..."
    
    # Copy Alertmanager configuration
    cp infrastructure/monitoring/alertmanager/alertmanager.yml "$CONFIG_DIR/alertmanager/"
    cp -r infrastructure/monitoring/alertmanager/templates "$CONFIG_DIR/alertmanager/"
    
    # Set proper permissions
    chown -R nobody:nobody "$CONFIG_DIR/alertmanager"
    chmod -R 644 "$CONFIG_DIR/alertmanager"/*.yml
}

# Configure Grafana
setup_grafana() {
    log_info "Configuring Grafana..."
    
    # Copy Grafana configuration
    cp -r infrastructure/monitoring/grafana/provisioning "$CONFIG_DIR/grafana/"
    cp -r infrastructure/monitoring/grafana/dashboards "$CONFIG_DIR/grafana/"
    
    # Set proper permissions
    chown -R 472:472 "$CONFIG_DIR/grafana"
    chmod -R 644 "$CONFIG_DIR/grafana"/**/*.json
}

# Configure Loki
setup_loki() {
    log_info "Configuring Loki..."
    
    # Copy Loki configuration
    cp infrastructure/monitoring/loki/loki.yaml "$CONFIG_DIR/loki/"
    
    # Set proper permissions
    chown -R nobody:nobody "$CONFIG_DIR/loki"
    chmod 644 "$CONFIG_DIR/loki"/*.yaml
}

# Configure Tempo
setup_tempo() {
    log_info "Configuring Tempo..."
    
    # Copy Tempo configuration
    cp infrastructure/monitoring/tempo/tempo.yaml "$CONFIG_DIR/tempo/"
    
    # Set proper permissions
    chown -R nobody:nobody "$CONFIG_DIR/tempo"
    chmod 644 "$CONFIG_DIR/tempo"/*.yaml
}

# Verify configurations
verify_configs() {
    log_info "Verifying configurations..."
    
    local has_errors=0
    
    # Check Prometheus config
    if ! promtool check config "$CONFIG_DIR/prometheus/prometheus.yml" &>/dev/null; then
        log_error "Invalid Prometheus configuration"
        has_errors=1
    fi
    
    # Check Alertmanager config
    if ! amtool check-config "$CONFIG_DIR/alertmanager/alertmanager.yml" &>/dev/null; then
        log_error "Invalid Alertmanager configuration"
        has_errors=1
    fi
    
    # Check if required files exist
    local required_files=(
        "$CONFIG_DIR/prometheus/prometheus.yml"
        "$CONFIG_DIR/alertmanager/alertmanager.yml"
        "$CONFIG_DIR/grafana/provisioning/datasources/datasources.yaml"
        "$CONFIG_DIR/loki/loki.yaml"
        "$CONFIG_DIR/tempo/tempo.yaml"
    )
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            log_error "Missing required file: $file"
            has_errors=1
        fi
    done
    
    if [ $has_errors -eq 1 ]; then
        log_error "Configuration verification failed"
        exit 1
    fi
    
    log_info "All configurations verified successfully"
}

# Main setup function
main() {
    log_info "Starting monitoring stack setup..."
    
    # Create directories
    create_directories
    
    # Setup individual components
    setup_prometheus
    setup_alertmanager
    setup_grafana
    setup_loki
    setup_tempo
    
    # Verify configurations
    verify_configs
    
    log_info "Monitoring stack setup completed successfully"
    log_info "Please ensure to:"
    log_info "1. Configure authentication for monitoring services"
    log_info "2. Set up alerting channels in Alertmanager"
    log_info "3. Review and adjust retention periods"
    log_info "4. Configure backup strategy for monitoring data"
}

# Execute main function
main "$@"
```

This script:

1. Sets up the complete monitoring stack including Prometheus, Grafana, Loki, Tempo, and Alertmanager
2. Creates necessary directories with proper permissions
3. Copies and configures all monitoring components
4. Verifies the configurations before completing
5. Provides proper error handling and logging
6. Follows security best practices for file permissions
7. Includes helpful human tasks and requirements documentation

The script addresses the monitoring and observability requirements from the technical specification by automating the deployment and configuration of all necessary monitoring tools.

Remember to make the script executable with:
```bash
chmod +x setup-monitoring.sh
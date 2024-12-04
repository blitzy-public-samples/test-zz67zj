# Makefile for automating backend service tasks
# Addresses requirement: Build Automation (9.5 Development & Deployment/Build & Deployment)
# Ensures consistent and automated building of backend services to streamline the development and deployment pipeline.

# Human Tasks:
# 1. Ensure Docker v24+ is installed and configured on the build system
# 2. Configure appropriate permissions for Docker operations
# 3. Set up monitoring for build failures in CI/CD pipeline
# 4. Configure appropriate resource limits for Docker builds
# 5. Ensure sufficient disk space for build artifacts

# Default target environment
ENV ?= dev

# Docker Compose files based on environment
DOCKER_COMPOSE_FILE = docker-compose.yml
DOCKER_COMPOSE_ENV_FILE = docker-compose.$(ENV).yml

# Docker Compose command with files
DOCKER_COMPOSE = docker-compose -f $(DOCKER_COMPOSE_FILE) -f $(DOCKER_COMPOSE_ENV_FILE)

# Default target
.DEFAULT_GOAL := help

# PHONY targets
.PHONY: help build test deploy clean logs restart status

# Help target
help:
	@echo "Available targets:"
	@echo "  build   - Build all backend services"
	@echo "  test    - Run all tests (unit and integration)"
	@echo "  deploy  - Deploy services using Docker Compose"
	@echo "  clean   - Remove all containers and build artifacts"
	@echo "  logs    - View logs from all services"
	@echo "  restart - Restart all services"
	@echo "  status  - Check status of all services"

# Build target
# Addresses requirement: Build Automation
build:
	@echo "Building backend services..."
	@./scripts/build.sh
	@echo "Build completed successfully"

# Test target
# Addresses requirement: Testing Automation
test:
	@echo "Running tests..."
	@./scripts/test.sh
	@echo "Tests completed successfully"

# Deploy target
# Addresses requirement: Backend Service Orchestration
deploy:
	@echo "Deploying services..."
	$(DOCKER_COMPOSE) up -d
	@echo "Deployment completed successfully"

# Clean target
clean:
	@echo "Cleaning up..."
	$(DOCKER_COMPOSE) down -v --remove-orphans
	@rm -rf build/
	@echo "Cleanup completed successfully"

# Logs target
logs:
	$(DOCKER_COMPOSE) logs -f

# Restart target
restart:
	@echo "Restarting services..."
	$(DOCKER_COMPOSE) restart
	@echo "Restart completed successfully"

# Status target
status:
	$(DOCKER_COMPOSE) ps

# Individual service targets
.PHONY: api-gateway auth-service booking-service notification-service payment-service tracking-service

api-gateway:
	$(DOCKER_COMPOSE) up -d api-gateway

auth-service:
	$(DOCKER_COMPOSE) up -d auth-service

booking-service:
	$(DOCKER_COMPOSE) up -d booking-service

notification-service:
	$(DOCKER_COMPOSE) up -d notification-service

payment-service:
	$(DOCKER_COMPOSE) up -d payment-service

tracking-service:
	$(DOCKER_COMPOSE) up -d tracking-service

# Development environment targets
.PHONY: dev prod

dev:
	@echo "Switching to development environment..."
	@ENV=dev $(MAKE) deploy

prod:
	@echo "Switching to production environment..."
	@ENV=prod $(MAKE) deploy

# Database targets
.PHONY: db-migrate db-rollback

db-migrate:
	@echo "Running database migrations..."
	@cd migrations && ./migrate.sh up
	@echo "Migrations completed successfully"

db-rollback:
	@echo "Rolling back database migrations..."
	@cd migrations && ./migrate.sh down
	@echo "Rollback completed successfully"

# Monitoring targets
.PHONY: monitor health-check

monitor:
	@echo "Starting monitoring dashboard..."
	@./scripts/monitor.sh

health-check:
	@echo "Running health checks..."
	@./scripts/health-check.sh
# Dog Walker Booking Application - Backend Services

## Introduction

The Dog Walker Booking application backend is built on a modern microservices architecture, designed to provide scalable, reliable, and secure services for connecting dog owners with professional dog walkers. The backend system consists of multiple specialized services that handle different aspects of the application's functionality.

Key Features:
- Microservices architecture for scalability and maintainability
- Real-time location tracking and communication
- Secure payment processing
- Push notification system
- Comprehensive walker verification system

## Services Overview

### Auth Service
- **Technology**: Node.js 20 LTS
- **Purpose**: Handles user authentication, authorization, and session management
- **Key Features**:
  - JWT-based authentication
  - OAuth2 social login integration
  - Role-based access control
  - Two-factor authentication for walkers

### Booking Service
- **Technology**: Go 1.21+
- **Purpose**: Manages walk bookings and scheduling
- **Key Features**:
  - Real-time availability management
  - Conflict detection
  - Automated scheduling
  - Booking history tracking

### Notification Service
- **Technology**: Node.js 20 LTS
- **Purpose**: Handles all system notifications
- **Key Features**:
  - Push notifications via Firebase Cloud Messaging
  - Email notifications
  - SMS alerts for critical updates
  - Real-time event broadcasting

### Payment Service
- **Technology**: Node.js 20 LTS
- **Purpose**: Processes all financial transactions
- **Key Features**:
  - Secure payment processing via Stripe
  - Automated billing
  - Refund management
  - Payment dispute handling

### Tracking Service
- **Technology**: Go 1.21+
- **Purpose**: Manages real-time location tracking
- **Key Features**:
  - Live GPS tracking
  - Geofencing
  - Route recording
  - Location history

## Setup Instructions

### Prerequisites
1. Install Docker (24.0+)
2. Install Docker Compose (2.20+)
3. Install Node.js (20 LTS)
4. Install Go (1.21+)
5. Install PostgreSQL (15+)
6. Install MongoDB (6.0+)
7. Install Redis (7.0+)

### Environment Setup
1. Clone the repository:
```bash
git clone git@github.com:your-org/dog-walker-backend.git
cd dog-walker-backend
```

2. Create environment files:
```bash
cp .env.example .env
```

3. Configure environment variables:
```bash
# Required environment variables
AWS_REGION=us-east-1
POSTGRES_HOST=localhost
MONGODB_URI=mongodb://localhost:27017
REDIS_URL=redis://localhost:6379
STRIPE_API_KEY=your_stripe_key
FCM_SERVER_KEY=your_fcm_key
```

4. Start the development environment:
```bash
docker-compose up -d
```

5. Initialize the databases:
```bash
make init-db
```

## Development Guide

### Code Structure
```
src/
├── auth/         # Authentication service
├── booking/      # Booking service
├── notification/ # Notification service
├── payment/      # Payment service
├── tracking/     # Tracking service
├── common/       # Shared utilities
└── tests/        # Integration tests
```

### Coding Standards
- Follow Go style guide for Go services
- Follow Airbnb JavaScript style guide for Node.js services
- Use dependency injection for better testability
- Write unit tests for all business logic
- Document all public APIs using OpenAPI 3.0

### Testing
1. Run unit tests:
```bash
make test
```

2. Run integration tests:
```bash
make test-integration
```

3. Run linting:
```bash
make lint
```

### Debugging
- Use built-in debugging tools:
  - Go: Delve debugger
  - Node.js: --inspect flag
- Log levels: DEBUG, INFO, WARN, ERROR
- Structured logging format (JSON)

## Deployment Instructions

### Production Deployment
1. Build Docker images:
```bash
make build
```

2. Push to container registry:
```bash
make push
```

3. Deploy to Kubernetes:
```bash
kubectl apply -f k8s/
```

### CI/CD Pipeline
- GitHub Actions for automated testing and deployment
- ArgoCD for GitOps-based deployment
- Automated rollbacks on failure
- Blue-green deployment strategy

### Monitoring
- Datadog for application monitoring
- ELK Stack for log aggregation
- Prometheus for metrics
- Grafana for visualization

## API Documentation

Detailed API documentation is available at the following endpoints:

- Auth Service: `http://localhost:3000/api-docs`
- Booking Service: `http://localhost:3001/api-docs`
- Payment Service: `http://localhost:3002/api-docs`
- Notification Service: `http://localhost:3003/api-docs`
- Tracking Service: `http://localhost:3004/api-docs`

### API Standards
- RESTful endpoints
- JWT authentication
- Rate limiting
- Request/response validation
- Comprehensive error handling

## Troubleshooting

### Common Issues

1. Database Connection Issues
```bash
# Check database connectivity
make check-db-connection
```

2. Service Dependencies
```bash
# Verify service health
make health-check
```

3. Authentication Problems
```bash
# Clear token cache
make clear-token-cache
```

### Support Contacts

- Technical Issues: tech-support@dogwalker.com
- Security Concerns: security@dogwalker.com
- Emergency Support: +1 (555) 123-4567

### Logging

- Centralized logging with ELK Stack
- Log retention: 30 days
- Log levels: DEBUG, INFO, WARN, ERROR
- Structured logging format (JSON)

For additional support, consult the internal documentation or contact the DevOps team.
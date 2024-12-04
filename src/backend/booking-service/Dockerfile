# Use golang:1.21-alpine as the base image for a lightweight and secure environment
# Addresses requirement 7.3.2: Containerization - Ensures the Booking Service is containerized for deployment
FROM golang:1.21-alpine

# Set working directory
WORKDIR /app

# Install build dependencies
RUN apk add --no-cache \
    gcc \
    musl-dev \
    git

# Copy go.mod and go.sum files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy the source code
COPY . .

# Build the application
# The binary will be created in the /app directory
RUN CGO_ENABLED=0 GOOS=linux go build -o booking-service ./cmd/server/main.go

# Create a minimal production image
FROM alpine:3.18

# Install runtime dependencies
RUN apk add --no-cache \
    ca-certificates \
    tzdata

# Set working directory
WORKDIR /app

# Copy the binary from the builder stage
COPY --from=0 /app/booking-service .

# Copy configuration files if needed
COPY --from=0 /app/config ./config

# Create a non-root user for security
RUN adduser -D -g '' appuser && \
    chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port 8080 for the HTTP server
EXPOSE 8080

# Set environment variables
ENV BOOKING_SERVICE_PORT=8080

# Define health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# Set the entry point to execute the Booking Service binary
ENTRYPOINT ["./booking-service"]

# Human Tasks:
# 1. Configure environment variables for database connection (BOOKING_DATABASE_URL)
# 2. Set up monitoring and metrics collection endpoints
# 3. Configure logging aggregation
# 4. Set up health check endpoint monitoring
# 5. Review and adjust container resource limits
# 6. Configure TLS/SSL certificates for HTTPS
# 7. Set up container registry credentials
# 8. Configure Kubernetes deployment manifests
# Build stage
# Addresses requirement: Scalable microservices architecture
# Location: 7.3 Technical Decisions/Architecture Patterns/Microservices
FROM golang:1.21 as builder

# Set working directory
WORKDIR /app

# Copy go.mod and go.sum files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy the entire source code
COPY . .

# Build the application
# CGO_ENABLED=0 creates a statically linked binary
# -ldflags="-w -s" reduces binary size by removing debug information
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o tracking-service ./cmd/server

# Runtime stage
FROM alpine:latest

# Install CA certificates for HTTPS connections
RUN apk --no-cache add ca-certificates

# Create non-root user for security
RUN adduser -D -g '' appuser

# Set working directory
WORKDIR /app

# Copy the binary from builder stage
COPY --from=builder /app/tracking-service .

# Set ownership of the application binary
RUN chown appuser:appuser /app/tracking-service

# Switch to non-root user
USER appuser

# Expose the default port
EXPOSE 8080

# Set environment variables with default values
ENV TRACKING_DB_URI=""
ENV TRACKING_WS_PORT="8080"

# Run the application
CMD ["./tracking-service"]

# Health check configuration
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:${TRACKING_WS_PORT}/health || exit 1
# Build stage
# Addresses requirement: Technical Specification/11.3 Containerization
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files for dependency installation
COPY package*.json ./

# Install dependencies
# Note: Dependencies are installed in the build stage to keep the final image clean
RUN npm ci

# Copy source code and configuration files
COPY tsconfig.json ./
COPY src ./src

# Build TypeScript code
RUN npm run build

# Runtime stage
# Addresses requirement: Technical Specification/11.2 Cloud Services
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000

# Create non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy package files and install production dependencies only
COPY package*.json ./
RUN npm ci --only=production

# Copy built files from builder stage
COPY --from=builder /app/dist ./dist

# Set ownership to non-root user
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose the service port
EXPOSE ${PORT}

# Health check configuration
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:${PORT}/health || exit 1

# Start the application
CMD ["node", "dist/index.js"]

# Human Tasks:
# 1. Configure environment variables in deployment:
#    - NODE_ENV: Environment (production/development)
#    - PORT: API Gateway port number
#    - LOG_LEVEL: Logging level (info, debug, error)
#    - AUTH_SECRET: JWT authentication secret
#    - RATE_LIMIT_WINDOW: Rate limiting window in minutes
#    - RATE_LIMIT_MAX_REQUESTS: Maximum requests per window
#    - ALLOWED_ORIGINS: Comma-separated list of allowed CORS origins
# 2. Set up proper monitoring and logging for the containerized service
# 3. Configure container resource limits in Kubernetes deployment
# 4. Set up proper network policies for the API Gateway
# 5. Configure horizontal pod autoscaling based on load
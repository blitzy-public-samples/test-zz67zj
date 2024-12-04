# Use Node.js 20 Alpine as base image
# Addresses requirement: Technical Specification/11.3 Containerization
FROM node:20-alpine

# Set working directory
WORKDIR /usr/src/app

# Install dependencies required for bcrypt
RUN apk add --no-cache python3 make g++

# Copy package files for dependency installation
COPY package*.json ./

# Install dependencies
# Using --production flag to exclude devDependencies
RUN npm ci --production

# Copy TypeScript configuration
COPY tsconfig.json ./

# Copy source code
COPY src/ ./src/

# Copy shared utilities
COPY ../shared/ ./shared/

# Build TypeScript code
RUN npm run build

# Remove development dependencies and source code
RUN npm prune --production && \
    rm -rf src/ && \
    rm -rf shared/ && \
    rm tsconfig.json

# Set environment variables
ENV NODE_ENV=production \
    PORT=3000

# Create non-root user for security
RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup

# Change ownership of the working directory
RUN chown -R appuser:appgroup /usr/src/app

# Switch to non-root user
USER appuser

# Expose the service port
EXPOSE 3000

# Set healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/api/auth/verify || exit 1

# Start the application
CMD ["node", "dist/index.js"]
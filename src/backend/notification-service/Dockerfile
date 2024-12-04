# Use Node.js 20 Alpine as base image for a lightweight container
# Requirement addressed: Containerization of Notification Service (7.2.1 Core Components/Notification Service)
FROM node:20-alpine

# Create app directory
WORKDIR /usr/src/app

# Install additional dependencies required for node-gyp and other build tools
RUN apk add --no-cache python3 make g++

# Copy package files for dependency installation
COPY package*.json ./

# Install dependencies
# Use ci instead of install for more reliable builds
RUN npm ci

# Copy source code
# Note: .dockerignore should exclude node_modules and other unnecessary files
COPY . .

# Build TypeScript files
RUN npm run build

# Remove development dependencies to reduce image size
RUN npm prune --production

# Expose the service port
EXPOSE 3000

# Add healthcheck to monitor container health
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Create a non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Set environment variables
ENV NODE_ENV=production \
    NOTIFICATION_SERVICE_PORT=3000

# Start the service
CMD ["npm", "start"]

# Add metadata labels
LABEL maintainer="DogWalker Development Team" \
      description="Notification Service for DogWalker Platform" \
      version="1.0.0"
# Use Node.js 20 Alpine as base image for a lightweight container
# Addresses requirement: Technical Specification/9.5 Development & Deployment/Containerization
FROM node:20-alpine

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
# Copy package files first to leverage Docker cache layers
COPY package*.json ./

# Install dependencies using npm 9.x
# Note: npm 9.x is included in Node.js 20 Alpine image
RUN npm install

# Bundle app source code
COPY . .

# Expose port 3000 for the Payment Service
EXPOSE 3000

# Start the Payment Service using npm start
# This will run the service using the scripts defined in package.json
CMD ["npm", "start"]

# Health check to ensure container is running properly
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:3000/health || exit 1
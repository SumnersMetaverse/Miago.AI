FROM ghcr.io/external-secrets/external-secrets:sha256-a4e1d50ba3f42fcbd818df963086ab81049c7fef6b81c34dd5360c5f253f916a.att

# Install necessary extensions for Node.js application
USER root
RUN apk add --no-cache nodejs npm

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including devDependencies needed for build)
RUN npm ci

# Copy application files
COPY . .

# Build the Docusaurus site
RUN npm run build

# Expose port for the application
EXPOSE 3003

# Start the application - serve on all interfaces
CMD ["npx", "docusaurus", "serve", "--host", "0.0.0.0", "--port", "3003"]

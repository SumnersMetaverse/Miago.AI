FROM ghcr.io/external-secrets/external-secrets:sha256-a4e1d50ba3f42fcbd818df963086ab81049c7fef6b81c34dd5360c5f253f916a.att

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application files
COPY . .

# Build the Docusaurus site
RUN npm run build

# Expose port for the application
EXPOSE 3003

# Start the application
CMD ["npm", "run", "serve"]

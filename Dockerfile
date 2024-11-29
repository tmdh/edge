FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including devDependencies)
RUN npm install

# Copy source code
COPY . .

# If you have a build step (like TypeScript compilation), add it here
# RUN npm run build

# Prune development dependencies
RUN npm prune --production

# Stage 2: Production stage
FROM node:18-alpine AS production

# Install necessary production packages
RUN apk --no-cache add dumb-init

# Create non-root user
RUN addgroup -g 1001 nodeapp && \
    adduser -u 1001 -G nodeapp -s /bin/sh -D nodeapp

WORKDIR /app

# Copy only necessary files from builder
COPY --from=builder --chown=nodeapp:nodeapp /app/package*.json ./
COPY --from=builder --chown=nodeapp:nodeapp /app/node_modules ./node_modules
COPY --from=builder --chown=nodeapp:nodeapp /app/*.js ./

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000

# Expose port
EXPOSE $PORT

# Switch to non-root user
USER nodeapp

# Use dumb-init as entrypoint to handle signals properly
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Start the application
CMD ["node", "app.js"]

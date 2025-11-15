# Node.js Application Template

Deploy Node.js applications with automatic SSL and container isolation.

## Features

- Node.js 18 (Alpine-based)
- Automatic HTTPS/SSL certificates
- Production-ready setup
- Container isolation
- Custom Dockerfile support

## Quick Deploy

```bash
# Using deploy script
./scripts/deploy-site.sh nodejs myapp app.example.com

# Or manually
cp -r sites/example-nodejs sites/myapp
cd sites/myapp
cp .env.example .env
nano .env  # Configure your settings
docker-compose up -d
```

## Structure

```
myapp/
├── docker-compose.yml    # Container configuration
├── Dockerfile            # Docker image definition
├── .env                  # Environment variables
├── package.json          # Node.js dependencies
├── index.js              # Application entry point
└── ...                   # Your application files
```

## Adding Your Application

1. Replace `index.js` with your application code
2. Update `package.json` with your dependencies
3. Modify `Dockerfile` if needed
4. Deploy

```bash
cd sites/myapp
# Add your application files
npm init  # or copy your package.json
# Add your code
docker-compose build
docker-compose up -d
```

## Example Applications

### Express.js Server

**package.json:**
```json
{
  "name": "express-app",
  "version": "1.0.0",
  "dependencies": {
    "express": "^4.18.2"
  }
}
```

**index.js:**
```javascript
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.get('/', (req, res) => {
  res.json({ message: 'Hello from Express!' });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

### Next.js Application

**Dockerfile:**
```dockerfile
FROM node:18-alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci

# Copy application files
COPY . .

# Build Next.js app
RUN npm run build

EXPOSE 3000

CMD ["npm", "start"]
```

**package.json:**
```json
{
  "name": "nextjs-app",
  "version": "1.0.0",
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start"
  },
  "dependencies": {
    "next": "^13.4.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  }
}
```

### API Server with Database

Add to docker-compose.yml:

```yaml
services:
  app:
    # ... existing config
    environment:
      - DATABASE_URL=mongodb://mongo:27017/mydb
    depends_on:
      - mongo
    networks:
      - web
      - internal

  mongo:
    image: mongo:6
    container_name: ${SITE_NAME}_mongo
    restart: unless-stopped
    volumes:
      - ./mongo-data:/data/db
    networks:
      - internal

networks:
  web:
    external: true
  internal:
    driver: bridge
```

## Environment Variables

Add to `.env`:

```bash
SITE_NAME=myapp
SITE_DOMAIN=app.example.com

# Application variables
NODE_ENV=production
DATABASE_URL=mongodb://mongo:27017/mydb
API_KEY=your-secret-key
PORT=3000
```

Use in application:

```javascript
const dbUrl = process.env.DATABASE_URL;
const apiKey = process.env.API_KEY;
```

## Customizing Dockerfile

### Add Build Arguments

```dockerfile
ARG NODE_VERSION=18
FROM node:${NODE_VERSION}-alpine

ARG BUILD_DATE
LABEL build_date=$BUILD_DATE
```

### Multi-stage Build

```dockerfile
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package*.json ./
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

### Add System Dependencies

```dockerfile
FROM node:18-alpine

# Install system dependencies
RUN apk add --no-cache \
    python3 \
    make \
    g++

WORKDIR /app
# ... rest of Dockerfile
```

## Database Integration

### PostgreSQL

```yaml
services:
  app:
    environment:
      - DATABASE_URL=postgresql://user:pass@postgres:5432/mydb
    depends_on:
      - postgres

  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: mydb
    volumes:
      - ./postgres-data:/var/lib/postgresql/data
    networks:
      - internal
```

### Redis

```yaml
services:
  app:
    environment:
      - REDIS_URL=redis://redis:6379
    depends_on:
      - redis

  redis:
    image: redis:7-alpine
    networks:
      - internal
```

## Development vs Production

### Development Setup

Create `docker-compose.dev.yml`:

```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      target: development
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
    command: npm run dev
```

Run with:
```bash
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up
```

## Common Tasks

### View Logs

```bash
docker-compose logs -f
```

### Access Container Shell

```bash
docker-compose exec app sh
```

### Run npm Commands

```bash
docker-compose exec app npm install package-name
docker-compose exec app npm test
```

### Rebuild After Changes

```bash
docker-compose build
docker-compose up -d
```

## Performance Optimization

### Use .dockerignore

```
node_modules
npm-debug.log
.git
.env
*.md
.vscode
.idea
```

### Optimize Dependencies

```dockerfile
# Install only production dependencies
RUN npm ci --only=production
```

### Enable Caching

```dockerfile
# Copy package files first (cached layer)
COPY package*.json ./
RUN npm ci

# Then copy application code
COPY . .
```

## Health Checks

Add to docker-compose.yml:

```yaml
services:
  app:
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

## Monitoring

### Add Logging

```javascript
const winston = require('winston');

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.Console()
  ]
});

logger.info('Server started', { port: PORT });
```

### Metrics Endpoint

```javascript
app.get('/metrics', (req, res) => {
  res.json({
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    cpu: process.cpuUsage()
  });
});
```

## Troubleshooting

### Port Already in Use

Change in docker-compose.yml:
```yaml
labels:
  - "traefik.http.services.${SITE_NAME}.loadbalancer.server.port=3001"
```

And in your app:
```javascript
const PORT = process.env.PORT || 3001;
```

### Dependencies Won't Install

Clear cache and rebuild:
```bash
docker-compose build --no-cache
```

### Application Crashes

Check logs:
```bash
docker-compose logs app
```

Add error handling:
```javascript
process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
});
```

## Security

- Run as non-root user in container
- Don't expose internal ports
- Use environment variables for secrets
- Keep dependencies updated
- Use security scanning tools

## Resources

- [Node.js Documentation](https://nodejs.org/docs/)
- [Express.js Guide](https://expressjs.com/)
- [Docker Node.js Best Practices](https://github.com/nodejs/docker-node/blob/main/docs/BestPractices.md)

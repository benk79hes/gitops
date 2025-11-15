#!/bin/bash
# Initial setup script for GitOps platform
# Usage: ./setup.sh

set -e

echo "=========================================="
echo "GitOps Multi-Web Hosting Platform Setup"
echo "=========================================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed"
    echo "Please install Docker first: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Error: Docker Compose is not installed"
    echo "Please install Docker Compose first: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✓ Docker and Docker Compose are installed"
echo ""

# Create necessary directories
echo "Creating directory structure..."
mkdir -p logs/traefik
mkdir -p backups
chmod 755 logs backups
echo "✓ Directories created"
echo ""

# Set up acme.json
echo "Setting up SSL certificate storage..."
if [ ! -f traefik-config/acme.json ]; then
    touch traefik-config/acme.json
fi
chmod 600 traefik-config/acme.json
echo "✓ acme.json configured with correct permissions"
echo ""

# Create .env if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating environment configuration..."
    cp .env.example .env
    echo "✓ .env file created from template"
    echo ""
    echo "⚠️  IMPORTANT: You must edit .env file before starting Traefik!"
    echo ""
    echo "Required configuration:"
    echo "  1. Set your domain name (DOMAIN)"
    echo "  2. Add Cloudflare API credentials (CF_API_EMAIL, CF_DNS_API_TOKEN)"
    echo "  3. Generate Traefik dashboard password (TRAEFIK_DASHBOARD_AUTH)"
    echo ""
    echo "To generate dashboard password:"
    echo "  echo \$(htpasswd -nb admin your-password) | sed -e s/\\\\\\\$/\\\\\\\$\\\\\\\$/g"
    echo ""
    read -p "Press Enter to edit .env now, or Ctrl+C to exit and edit later..."
    ${EDITOR:-nano} .env
else
    echo "✓ .env file already exists"
fi

echo ""
echo "Creating Docker network..."
if docker network inspect web &> /dev/null; then
    echo "✓ Docker network 'web' already exists"
else
    docker network create web
    echo "✓ Docker network 'web' created"
fi

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Verify .env configuration:"
echo "   cat .env"
echo ""
echo "2. Start Traefik:"
echo "   docker-compose up -d"
echo ""
echo "3. Check Traefik logs:"
echo "   docker logs -f traefik"
echo ""
echo "4. Deploy your first site:"
echo "   ./scripts/deploy-site.sh wordpress mysite mysite.com"
echo ""
echo "5. Access Traefik dashboard:"
echo "   https://traefik-dashboard.yourdomain.com"
echo ""
echo "For more information, see README.md"
echo "=========================================="

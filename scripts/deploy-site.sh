#!/bin/bash
# Script to deploy a new site
# Usage: ./deploy-site.sh <template> <site-name> <domain>

set -e

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "Usage: $0 <template> <site-name> <domain>"
    echo ""
    echo "Templates:"
    echo "  wordpress - WordPress site with MySQL and phpMyAdmin"
    echo "  static    - Static HTML site with Nginx"
    echo "  nodejs    - Node.js application"
    echo ""
    echo "Example: $0 wordpress mysite mysite.com"
    exit 1
fi

TEMPLATE=$1
SITE_NAME=$2
DOMAIN=$3
BASE_DIR="/home/runner/work/gitops/gitops"
SITES_DIR="${BASE_DIR}/sites"
NEW_SITE_DIR="${SITES_DIR}/${SITE_NAME}"

# Check if template exists
TEMPLATE_DIR="${SITES_DIR}/example-${TEMPLATE}"
if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "Error: Template '$TEMPLATE' not found"
    echo "Available templates:"
    ls -1 "$SITES_DIR" | grep "^example-"
    exit 1
fi

# Check if site already exists
if [ -d "$NEW_SITE_DIR" ]; then
    echo "Error: Site '$SITE_NAME' already exists at $NEW_SITE_DIR"
    exit 1
fi

echo "Creating new site '$SITE_NAME' from template '$TEMPLATE'..."

# Copy template
cp -r "$TEMPLATE_DIR" "$NEW_SITE_DIR"
echo "✓ Template copied"

# Create .env file
cd "$NEW_SITE_DIR"
if [ -f ".env.example" ]; then
    cp .env.example .env
    
    # Update environment variables
    sed -i "s/SITE_NAME=.*/SITE_NAME=${SITE_NAME}/" .env
    sed -i "s/SITE_DOMAIN=.*/SITE_DOMAIN=${DOMAIN}/" .env
    
    # Generate secure passwords for WordPress/database
    if [ "$TEMPLATE" = "wordpress" ]; then
        DB_PASSWORD=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 32)
        DB_ROOT_PASSWORD=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 32)
        sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD}/" .env
        sed -i "s/DB_ROOT_PASSWORD=.*/DB_ROOT_PASSWORD=${DB_ROOT_PASSWORD}/" .env
        echo "✓ Generated secure database passwords"
    fi
    
    echo "✓ Environment file configured"
fi

echo ""
echo "=========================================="
echo "Site created successfully!"
echo "=========================================="
echo "Site name: ${SITE_NAME}"
echo "Domain: ${DOMAIN}"
echo "Location: ${NEW_SITE_DIR}"
echo ""
echo "Next steps:"
echo "1. Review and update .env file if needed:"
echo "   cd ${NEW_SITE_DIR}"
echo "   nano .env"
echo ""
echo "2. Deploy the site:"
echo "   cd ${NEW_SITE_DIR}"
echo "   docker-compose up -d"
echo ""
echo "3. Check logs:"
echo "   docker-compose logs -f"
echo ""
echo "4. Access your site at:"
echo "   https://${DOMAIN}"

if [ "$TEMPLATE" = "wordpress" ]; then
    echo "   https://pma.${DOMAIN} (phpMyAdmin)"
fi

echo ""
echo "=========================================="

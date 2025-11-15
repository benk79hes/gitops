#!/bin/bash
# Script to remove a site
# Usage: ./remove-site.sh <site-name>

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <site-name>"
    echo "Example: $0 mysite"
    exit 1
fi

SITE_NAME=$1
SITE_DIR="/home/runner/work/gitops/gitops/sites/${SITE_NAME}"

# Check if site exists
if [ ! -d "$SITE_DIR" ]; then
    echo "Error: Site '$SITE_NAME' not found at $SITE_DIR"
    exit 1
fi

# Confirm deletion
echo "WARNING: This will remove the site '$SITE_NAME' and all its data!"
echo "Site location: $SITE_DIR"
echo ""
read -p "Are you sure you want to continue? Type 'DELETE' to confirm: " confirm

if [ "$confirm" != "DELETE" ]; then
    echo "Removal cancelled"
    exit 0
fi

echo "Removing site '$SITE_NAME'..."

cd "$SITE_DIR"

# Stop and remove containers
if [ -f "docker-compose.yml" ]; then
    echo "Stopping and removing containers..."
    docker-compose down -v
    echo "✓ Containers removed"
fi

# Optional: Create a final backup
echo ""
read -p "Create a final backup before deletion? (yes/no): " backup_confirm
if [ "$backup_confirm" = "yes" ]; then
    /home/runner/work/gitops/gitops/scripts/backup-site.sh "$SITE_NAME"
    echo "✓ Final backup created"
fi

# Remove site directory
cd ..
echo "Removing site directory..."
rm -rf "$SITE_DIR"
echo "✓ Site directory removed"

echo ""
echo "=========================================="
echo "Site '$SITE_NAME' has been removed"
echo "=========================================="
echo ""
echo "Note: Backups (if any) are still available in:"
echo "  /home/runner/work/gitops/gitops/backups/${SITE_NAME}"

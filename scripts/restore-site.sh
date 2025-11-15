#!/bin/bash
# Restore script for website and database
# Usage: ./restore-site.sh <site-name> <backup-timestamp>

set -e

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <site-name> <backup-timestamp>"
    echo "Example: $0 example-wp 20250115_120000"
    exit 1
fi

SITE_NAME=$1
BACKUP_TIMESTAMP=$2
SITE_DIR="/home/runner/work/gitops/gitops/sites/${SITE_NAME}"
BACKUP_DIR="/home/runner/work/gitops/gitops/backups/${SITE_NAME}"
BACKUP_FILE="${BACKUP_DIR}/backup_${BACKUP_TIMESTAMP}"

# Check if backup exists
if [ ! -f "${BACKUP_FILE}_metadata.txt" ]; then
    echo "Error: Backup not found: ${BACKUP_FILE}_metadata.txt"
    echo "Available backups:"
    ls -1 "$BACKUP_DIR" | grep metadata
    exit 1
fi

echo "Starting restore for $SITE_NAME from backup $BACKUP_TIMESTAMP..."

# Confirm restore
read -p "This will overwrite existing data. Are you sure? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Restore cancelled"
    exit 0
fi

cd "$SITE_DIR"

# Stop containers
echo "Stopping containers..."
docker-compose down

# Restore website files
if [ -f "${BACKUP_FILE}_files.tar.gz" ]; then
    echo "Restoring website files..."
    tar -xzf "${BACKUP_FILE}_files.tar.gz"
    echo "Website files restored"
fi

# Start containers
echo "Starting containers..."
docker-compose up -d

# Wait for database to be ready
if [ -f "${BACKUP_FILE}_database.sql.gz" ]; then
    echo "Waiting for database to be ready..."
    sleep 10
    
    # Load environment variables
    if [ -f .env ]; then
        source .env
    fi
    
    # Restore database
    echo "Restoring database..."
    gunzip -c "${BACKUP_FILE}_database.sql.gz" | docker exec -i ${SITE_NAME}_db mysql -u root -p${DB_ROOT_PASSWORD} ${DB_NAME}
    echo "Database restored"
fi

echo "Restore completed successfully!"

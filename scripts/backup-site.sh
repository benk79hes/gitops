#!/bin/bash
# Backup script for website and database
# Usage: ./backup-site.sh <site-name>

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <site-name>"
    echo "Example: $0 example-wp"
    exit 1
fi

SITE_NAME=$1
SITE_DIR="/home/runner/work/gitops/gitops/sites/${SITE_NAME}"
BACKUP_DIR="/home/runner/work/gitops/gitops/backups/${SITE_NAME}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}"

# Check if site exists
if [ ! -d "$SITE_DIR" ]; then
    echo "Error: Site directory $SITE_DIR does not exist"
    exit 1
fi

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo "Starting backup for $SITE_NAME..."

# Change to site directory
cd "$SITE_DIR"

# Backup website files
echo "Backing up website files..."
if [ -d "wordpress-data" ]; then
    tar -czf "${BACKUP_FILE}_files.tar.gz" wordpress-data
    echo "WordPress files backed up to ${BACKUP_FILE}_files.tar.gz"
elif [ -d "html" ]; then
    tar -czf "${BACKUP_FILE}_files.tar.gz" html
    echo "Static site files backed up to ${BACKUP_FILE}_files.tar.gz"
else
    echo "No standard web directory found, skipping file backup"
fi

# Backup database if it exists
if docker ps | grep -q "${SITE_NAME}_db"; then
    echo "Backing up database..."
    
    # Load environment variables
    if [ -f .env ]; then
        source .env
    fi
    
    # Export database
    docker exec ${SITE_NAME}_db mysqldump -u root -p${DB_ROOT_PASSWORD} ${DB_NAME} > "${BACKUP_FILE}_database.sql"
    gzip "${BACKUP_FILE}_database.sql"
    echo "Database backed up to ${BACKUP_FILE}_database.sql.gz"
fi

# Create a backup metadata file
cat > "${BACKUP_FILE}_metadata.txt" << EOF
Backup Information
==================
Site Name: ${SITE_NAME}
Timestamp: ${TIMESTAMP}
Date: $(date)
Backup Files:
EOF

ls -lh "${BACKUP_FILE}"* >> "${BACKUP_FILE}_metadata.txt"

echo "Backup completed successfully!"
echo "Backup location: ${BACKUP_FILE}*"

# Clean old backups (keep last 30 days)
find "$BACKUP_DIR" -name "backup_*" -type f -mtime +30 -delete
echo "Old backups (>30 days) cleaned up"

#!/bin/bash
# Script to list all deployed sites
# Usage: ./list-sites.sh

SITES_DIR="/home/runner/work/gitops/gitops/sites"

echo "=========================================="
echo "Deployed Sites"
echo "=========================================="
echo ""

for site_dir in "$SITES_DIR"/*; do
    if [ -d "$site_dir" ]; then
        site_name=$(basename "$site_dir")
        
        # Skip example templates
        if [[ $site_name == example-* ]]; then
            continue
        fi
        
        cd "$site_dir"
        
        # Check if .env exists
        if [ -f ".env" ]; then
            source .env
            
            echo "Site: $site_name"
            echo "  Domain: ${SITE_DOMAIN:-N/A}"
            
            # Check if containers are running
            if docker-compose ps | grep -q "Up"; then
                echo "  Status: ✓ Running"
                
                # List running containers
                containers=$(docker-compose ps --services --filter "status=running" 2>/dev/null | tr '\n' ', ' | sed 's/,$//')
                if [ -n "$containers" ]; then
                    echo "  Containers: $containers"
                fi
            else
                echo "  Status: ✗ Stopped"
            fi
            
            echo ""
        fi
    fi
done

echo "=========================================="
echo ""
echo "To view site details:"
echo "  cd sites/<site-name>"
echo "  cat .env"
echo "  docker-compose ps"

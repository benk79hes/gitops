.PHONY: help setup start stop restart logs status deploy-site list-sites backup restore clean

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup: ## Initial setup (run once)
	@./setup.sh

start: ## Start Traefik
	@echo "Starting Traefik..."
	@docker-compose up -d
	@echo "Traefik started. Check logs with: make logs"

stop: ## Stop Traefik
	@echo "Stopping Traefik..."
	@docker-compose down
	@echo "Traefik stopped."

restart: ## Restart Traefik
	@echo "Restarting Traefik..."
	@docker-compose restart
	@echo "Traefik restarted."

logs: ## View Traefik logs
	@docker-compose logs -f

status: ## Show status of all services
	@echo "=== Traefik Status ==="
	@docker-compose ps
	@echo ""
	@echo "=== All Sites ==="
	@./scripts/list-sites.sh

deploy-site: ## Deploy a new site (usage: make deploy-site TEMPLATE=wordpress NAME=mysite DOMAIN=mysite.com)
	@if [ -z "$(TEMPLATE)" ] || [ -z "$(NAME)" ] || [ -z "$(DOMAIN)" ]; then \
		echo "Error: Missing required parameters"; \
		echo "Usage: make deploy-site TEMPLATE=wordpress NAME=mysite DOMAIN=mysite.com"; \
		echo "Templates: wordpress, static, nodejs"; \
		exit 1; \
	fi
	@./scripts/deploy-site.sh $(TEMPLATE) $(NAME) $(DOMAIN)

list-sites: ## List all deployed sites
	@./scripts/list-sites.sh

backup: ## Backup a site (usage: make backup SITE=mysite)
	@if [ -z "$(SITE)" ]; then \
		echo "Error: SITE parameter required"; \
		echo "Usage: make backup SITE=mysite"; \
		exit 1; \
	fi
	@./scripts/backup-site.sh $(SITE)

restore: ## Restore a site (usage: make restore SITE=mysite TIMESTAMP=20250115_120000)
	@if [ -z "$(SITE)" ] || [ -z "$(TIMESTAMP)" ]; then \
		echo "Error: SITE and TIMESTAMP parameters required"; \
		echo "Usage: make restore SITE=mysite TIMESTAMP=20250115_120000"; \
		exit 1; \
	fi
	@./scripts/restore-site.sh $(SITE) $(TIMESTAMP)

clean: ## Clean up unused Docker resources
	@echo "Cleaning up Docker resources..."
	@docker system prune -f
	@echo "Cleanup complete."

update: ## Update all Docker images
	@echo "Updating Docker images..."
	@docker-compose pull
	@echo "Update complete. Run 'make restart' to apply changes."

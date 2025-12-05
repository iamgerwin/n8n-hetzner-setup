.PHONY: up down logs status backup restore update stop start restart help ps config

help:
	@echo "n8n Self-Hosted Management"
	@echo ""
	@echo "Available commands:"
	@echo "  make up           - Start all services"
	@echo "  make down         - Stop all services"
	@echo "  make status       - Show service status"
	@echo "  make logs         - View logs (all services)"
	@echo "  make logs-n8n     - View n8n logs"
	@echo "  make logs-worker  - View worker logs"
	@echo "  make logs-db      - View PostgreSQL logs"
	@echo "  make ps           - List running containers"
	@echo "  make backup       - Create backup"
	@echo "  make restore      - Restore from backup"
	@echo "  make update       - Update n8n safely"
	@echo "  make stop         - Stop all services (graceful)"
	@echo "  make start        - Start all services"
	@echo "  make restart      - Restart all services"
	@echo "  make config       - Show configuration"
	@echo "  make clean        - Remove stopped containers"
	@echo "  make prune        - Remove unused Docker resources"

up:
	docker-compose up -d
	@echo "✅ Services started. Waiting for health checks..."
	@sleep 10
	@$(MAKE) status

down:
	docker-compose down
	@echo "✅ Services stopped"

status:
	@echo "=== Service Status ==="
	@docker-compose ps

logs:
	./scripts/logs.sh all

logs-n8n:
	./scripts/logs.sh n8n

logs-worker:
	./scripts/logs.sh worker

logs-db:
	./scripts/logs.sh postgres

ps:
	docker-compose ps

backup:
	./scripts/backup.sh

restore:
	./scripts/restore.sh

update:
	./scripts/update.sh

stop:
	docker-compose stop
	@echo "✅ Services stopped gracefully"

start:
	docker-compose start
	@echo "✅ Services started"

restart:
	docker-compose restart
	@echo "✅ Services restarted. Waiting for health checks..."
	@sleep 10
	@$(MAKE) status

config:
	@echo "=== n8n Configuration ==="
	@cat .env

clean:
	docker-compose down -v
	@echo "✅ Containers and volumes removed"

prune:
	docker system prune -f
	@echo "✅ Unused Docker resources removed"

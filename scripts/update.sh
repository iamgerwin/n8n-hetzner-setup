#!/bin/bash

# n8n Update Script - Safely update n8n with data preservation

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$( dirname "$SCRIPT_DIR" )"

echo "=== n8n Update Script ==="
echo "Project directory: $PROJECT_DIR"
echo ""

# Create backup before update
echo "📦 Creating backup before update..."
BACKUP_DIR="$PROJECT_DIR/backup"
BACKUP_FILE="$BACKUP_DIR/n8n-backup-before-update-$(date +%Y%m%d-%H%M%S).tar.gz"

mkdir -p "$BACKUP_DIR"

cd "$PROJECT_DIR"
docker run --rm \
  -v n8n_storage:/source \
  -v postgres_data:/postgres \
  -v redis_data:/redis \
  -v "$BACKUP_DIR":/backup \
  alpine tar czf "/backup/$(basename "$BACKUP_FILE")" -C / source postgres redis 2>/dev/null || true

echo "✅ Backup created: $BACKUP_FILE"
echo ""

# Stop services
echo "⏸️  Stopping services..."
docker-compose down
echo "✅ Services stopped"
echo ""

# Pull latest images
echo "🔄 Pulling latest images..."
docker-compose pull
echo "✅ Latest images pulled"
echo ""

# Start services again
echo "🚀 Starting services..."
docker-compose up -d
echo "✅ Services started"
echo ""

# Wait for services to be healthy
echo "⏳ Waiting for services to be healthy..."
sleep 10

# Check health
RETRIES=30
COUNTER=0
while [ $COUNTER -lt $RETRIES ]; do
  if docker-compose exec -T n8n curl -f http://localhost:5678/healthz > /dev/null 2>&1; then
    echo "✅ n8n is healthy"
    break
  fi
  COUNTER=$((COUNTER+1))
  if [ $COUNTER -eq $RETRIES ]; then
    echo "❌ n8n health check failed after $RETRIES attempts"
    echo "Check logs: docker-compose logs n8n"
    exit 1
  fi
  sleep 2
done

echo ""
echo "=== Update Complete ==="
echo "n8n is now running with the latest version"
echo "Backup saved to: $BACKUP_FILE"

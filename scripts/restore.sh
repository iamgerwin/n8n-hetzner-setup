#!/bin/bash

# n8n Restore Script - Restore from a backup

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$( dirname "$SCRIPT_DIR" )"
BACKUP_DIR="$PROJECT_DIR/backup"

echo "=== n8n Restore Script ==="
echo ""

# List available backups
echo "📦 Available backups:"
ls -lh "$BACKUP_DIR"/n8n-backup-*.tar.gz 2>/dev/null || { echo "No backups found"; exit 1; }
echo ""

# Get backup file from user
read -p "Enter backup filename to restore (e.g., n8n-backup-20241205-123456.tar.gz): " BACKUP_FILE

if [ ! -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
  echo "❌ Backup file not found: $BACKUP_DIR/$BACKUP_FILE"
  exit 1
fi

echo "⚠️  WARNING: This will restore from backup and may overwrite current data"
read -p "Are you sure? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
  echo "❌ Restore cancelled"
  exit 0
fi

echo ""
echo "🛑 Stopping services..."
cd "$PROJECT_DIR"
docker-compose down

echo "🗑️  Removing current volumes..."
docker volume rm n8n_storage postgres_data redis_data 2>/dev/null || true

echo "📥 Restoring from backup..."
docker run --rm \
  -v n8n_storage:/source \
  -v postgres_data:/postgres \
  -v redis_data:/redis \
  -v "$BACKUP_DIR":/backup \
  alpine tar xzf "/backup/$BACKUP_FILE" -C /

echo "🚀 Starting services..."
docker-compose up -d

echo "⏳ Waiting for services to be healthy..."
sleep 15

RETRIES=30
COUNTER=0
while [ $COUNTER -lt $RETRIES ]; do
  if docker-compose exec -T n8n curl -f http://localhost:5678/healthz > /dev/null 2>&1; then
    echo "✅ Restore complete and services are healthy"
    exit 0
  fi
  COUNTER=$((COUNTER+1))
  sleep 2
done

echo "❌ Services did not become healthy. Check logs: docker-compose logs"
exit 1

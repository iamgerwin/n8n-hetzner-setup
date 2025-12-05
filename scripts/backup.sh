#!/bin/bash

# n8n Backup Script - Create timestamped backup of all data

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$( dirname "$SCRIPT_DIR" )"
BACKUP_DIR="$PROJECT_DIR/backup"

echo "=== n8n Backup Script ==="
echo "Backup directory: $BACKUP_DIR"
echo ""

mkdir -p "$BACKUP_DIR"

BACKUP_FILE="$BACKUP_DIR/n8n-backup-$(date +%Y%m%d-%H%M%S).tar.gz"

echo "📦 Creating backup: $BACKUP_FILE"

cd "$PROJECT_DIR"

docker run --rm \
  -v n8n_storage:/source \
  -v postgres_data:/postgres \
  -v redis_data:/redis \
  -v "$BACKUP_DIR":/backup \
  alpine tar czf "/backup/$(basename "$BACKUP_FILE")" -C / source postgres redis

echo "✅ Backup completed: $BACKUP_FILE"
echo "📊 Backup size: $(du -h "$BACKUP_FILE" | cut -f1)"
echo ""

# Clean old backups (keep last 7 days)
echo "🧹 Cleaning old backups (keeping last 7 days)..."
find "$BACKUP_DIR" -name "n8n-backup-*.tar.gz" -mtime +7 -delete

REMAINING=$(find "$BACKUP_DIR" -name "n8n-backup-*.tar.gz" | wc -l)
echo "✅ Cleanup complete. Remaining backups: $REMAINING"

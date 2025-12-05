#!/bin/bash
set -e

echo "🚀 n8n Migration Script - For transferring to new VPS"
echo ""
echo "This script helps you migrate your n8n setup to a new VPS."
echo "Run this on your NEW VPS after cloning the repository."
echo ""

# Check prerequisites
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Please install Docker first."
    echo "   Visit: https://docs.docker.com/engine/install/"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose not found. Please install Docker Compose first."
    echo "   Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✅ Docker and Docker Compose found"
echo ""

# Check for .env file
if [ ! -f ".env" ]; then
    echo "❌ .env file not found!"
    echo ""
    echo "Please create .env from .env.example:"
    echo "  cp .env.example .env"
    echo "  nano .env"
    echo ""
    echo "Then run this script again."
    exit 1
fi

echo "📋 Environment Configuration:"
echo "================================"
grep "^N8N_HOST\|^TRAEFIK_DOMAIN\|^POSTGRES_DB" .env || true
echo ""

# Option 1: Fresh start
echo "🔄 Migration Options:"
echo "  1) Fresh start (new database)"
echo "  2) Restore from backup"
read -p "Choose option (1 or 2): " migrate_option

case $migrate_option in
    1)
        echo ""
        echo "🆕 Starting fresh installation..."
        make up
        echo ""
        echo "✅ Fresh n8n instance running!"
        echo ""
        echo "Next steps:"
        echo "  1. Access your n8n at: https://$(grep '^TRAEFIK_DOMAIN' .env | cut -d= -f2)"
        echo "  2. Create your admin user"
        echo "  3. Re-import your workflows"
        echo ""
        ;;
    2)
        echo ""
        read -p "Enter backup file path (e.g., /path/to/backup.tar.gz): " backup_path
        
        if [ ! -f "$backup_path" ]; then
            echo "❌ Backup file not found: $backup_path"
            exit 1
        fi
        
        echo "📥 Copying backup..."
        cp "$backup_path" ./backup/restore.tar.gz
        
        echo "🚀 Starting services..."
        make up
        
        echo ""
        echo "⏳ Waiting for services to be ready..."
        sleep 10
        
        echo "📂 Restoring backup..."
        ./scripts/restore.sh
        
        echo ""
        echo "✅ Restore complete!"
        echo ""
        echo "Next steps:"
        echo "  1. Access your n8n at: https://$(grep '^TRAEFIK_DOMAIN' .env | cut -d= -f2)"
        echo "  2. Verify all workflows are intact"
        echo "  3. Test critical automations"
        echo ""
        ;;
    *)
        echo "❌ Invalid option"
        exit 1
        ;;
esac

# Install systemd service for auto-start
echo "🔧 Setting up auto-start on reboot..."
read -p "Install systemd service? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo ./scripts/install-systemd.sh
else
    echo "ℹ️  You can install it later with: sudo ./scripts/install-systemd.sh"
fi

echo ""
echo "📊 Service Status:"
make status
echo ""
echo "✨ Migration complete!"

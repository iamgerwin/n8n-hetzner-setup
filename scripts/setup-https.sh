#!/bin/bash

# Setup Let's Encrypt HTTPS for n8n with Certbot

set -e

DOMAIN="usisa.store"
EMAIL="admin@$DOMAIN"

echo "=== Let's Encrypt HTTPS Setup ==="
echo "Domain: $DOMAIN"
echo "Email: $EMAIL"
echo ""

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p /var/www/certbot
mkdir -p /etc/letsencrypt

# Check if certificate already exists
if [ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    echo "✅ Certificate already exists for $DOMAIN"
    echo "To renew: sudo certbot renew"
    exit 0
fi

# Start nginx temporarily to allow Let's Encrypt verification
echo "🚀 Starting Nginx temporarily for certificate verification..."
cd /home/sites/n8n
docker-compose up -d nginx
sleep 5

# Request certificate
echo "🔐 Requesting certificate from Let's Encrypt..."
sudo certbot certonly \
    --standalone \
    --agree-tos \
    --no-eff-email \
    --email "$EMAIL" \
    -d "$DOMAIN" \
    --preferred-challenges http

# Check if certificate was obtained
if [ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    echo "✅ Certificate obtained successfully!"
    echo ""
    echo "📁 Certificate location: /etc/letsencrypt/live/$DOMAIN/"
    echo "📝 Certificates:"
    echo "   - Full chain: /etc/letsencrypt/live/$DOMAIN/fullchain.pem"
    echo "   - Private key: /etc/letsencrypt/live/$DOMAIN/privkey.pem"
    echo ""
    echo "Restarting services with HTTPS..."
    docker-compose restart nginx n8n
    sleep 10
    
    echo "✅ Setup complete!"
    echo "🌐 Access n8n at: https://$DOMAIN:9999"
    echo ""
    echo "🔄 Auto-renewal is configured in system cron"
else
    echo "❌ Certificate retrieval failed"
    exit 1
fi

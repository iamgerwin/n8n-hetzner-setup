#!/bin/bash
set -e

echo "📦 Installing n8n systemd service for auto-start on reboot..."

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "❌ This script must be run as root"
   exit 1
fi

# Copy systemd service file
if [ -f "./systemd/n8n.service" ]; then
    cp ./systemd/n8n.service /etc/systemd/system/n8n.service
    chmod 644 /etc/systemd/system/n8n.service
    echo "✅ Service file copied to /etc/systemd/system/"
else
    echo "❌ systemd/n8n.service not found"
    exit 1
fi

# Reload systemd daemon
systemctl daemon-reload
echo "✅ Systemd daemon reloaded"

# Enable the service
systemctl enable n8n.service
echo "✅ n8n service enabled for auto-start on reboot"

# Optionally start the service
read -p "Start n8n service now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    systemctl start n8n.service
    echo "✅ n8n service started"
    sleep 5
    systemctl status n8n.service
else
    echo "⏭️  Service not started. You can start it manually with: sudo systemctl start n8n"
fi

# n8n Hetzner VPS Deployment Guide

This guide provides step-by-step instructions to deploy n8n on a Hetzner VPS (or any Ubuntu/Debian-based VPS) with full HTTPS support, PostgreSQL, Redis, and automatic startup on reboot.

## Prerequisites

- Hetzner VPS (Ubuntu 20.04 LTS or later recommended)
- Domain name configured with DNS pointing to your VPS IP
- SSH access to your VPS
- Basic knowledge of command line

## Quick Start (15 minutes)

### 1. Connect to Your VPS

```bash
ssh root@your_vps_ip
```

### 2. Clone This Repository

```bash
cd /home/sites
git clone https://github.com/iamgerwin/n8n-hetzner-setup.git n8n
cd n8n
```

### 3. Configure Environment Variables

```bash
# Copy the example environment file
cp .env.example .env

# Edit with your configuration
nano .env
```

Update these critical variables:
- `N8N_HOST`: Your domain (e.g., n8n.example.com)
- `TRAEFIK_DOMAIN`: Your domain
- `N8N_ENCRYPTION_KEY`: Generate with `openssl rand -hex 32`
- `POSTGRES_PASSWORD`: Change to a secure password
- `POSTGRES_NON_ROOT_PASSWORD`: Change to a secure password
- `REDIS_PASSWORD`: Change to a secure password

### 4. Generate SSL Certificate

Before starting containers, ensure your domain points to your VPS IP. Then:

```bash
# The docker-compose includes Traefik for automatic HTTPS
# It will attempt to get a Let's Encrypt certificate
make up
```

### 5. Verify Services Are Running

```bash
make status
```

### 6. Install Auto-Start on Reboot

```bash
sudo ./scripts/install-systemd.sh
```

## Configuration Details

### Docker Services

- **n8n**: Workflow automation platform (port 5678)
- **PostgreSQL**: Database for n8n data persistence
- **Redis**: Cache and message queue
- **Traefik**: Reverse proxy with automatic HTTPS (Let's Encrypt)

### Environment Variables

Copy `.env.example` to `.env` and update:

```env
# Your domain
N8N_HOST=n8n.yourdomain.com
TRAEFIK_DOMAIN=n8n.yourdomain.com

# Generate a secure key: openssl rand -hex 32
N8N_ENCRYPTION_KEY=your_generated_key_here

# Secure passwords (change these!)
POSTGRES_PASSWORD=your_secure_postgres_password
POSTGRES_NON_ROOT_PASSWORD=your_secure_n8n_user_password
REDIS_PASSWORD=your_secure_redis_password
```

## Common Commands

```bash
# Start all services
make up

# Stop all services
make down

# View logs
make logs

# View specific service logs
make logs-n8n
make logs-worker
make logs-db

# Create backup
make backup

# Restore from backup
make restore

# Update n8n
make update

# Check service status
make status
```

## HTTPS/SSL Certificate

The setup uses Traefik with Let's Encrypt for automatic HTTPS:

1. **First-time setup**: Traefik will attempt to obtain a certificate when containers start
2. **Domain requirement**: Your domain MUST point to your VPS IP before starting
3. **Certificate renewal**: Automatic (Let's Encrypt handles renewal 30 days before expiry)
4. **Certificate location**: Stored in `./letsencrypt/acme.json` (included in `.gitignore`)

## Persistence & Auto-Start

### Before Reboot
After initial setup, run:
```bash
sudo ./scripts/install-systemd.sh
```

This creates a systemd service that:
- Automatically starts n8n on VPS reboot
- Restarts containers if they crash
- Maintains data persistence in volumes

### Verify Auto-Start
```bash
# Check service status
sudo systemctl status n8n

# Check if enabled
sudo systemctl is-enabled n8n

# View recent logs
sudo journalctl -u n8n -n 50
```

## Transferring to a New VPS

### On Old VPS
```bash
# Create full backup
make backup

# List available backups
ls -lh backup/
```

### On New VPS
```bash
# Follow "Quick Start" steps 1-5

# If you have a backup
cp /path/to/backup.tar.gz ./backup/
make restore
```

## Troubleshooting

### Services not starting
```bash
# Check logs
make logs

# Check Docker status
docker ps -a
docker-compose logs
```

### Certificate issues
```bash
# Check Traefik dashboard (if exposed)
# Check certificate file
ls -la letsencrypt/

# Traefik logs
docker logs n8n_traefik_1 -f
```

### Database connection errors
```bash
# Verify PostgreSQL is running
docker exec n8n_postgres_1 psql -U n8n -d n8n -c "SELECT 1"

# Check Redis
docker exec n8n_redis_1 redis-cli ping
```

### Permission issues
```bash
# Ensure proper permissions
sudo chown -R root:root /home/sites/n8n
sudo chmod -R 755 /home/sites/n8n
```

## Security Best Practices

1. **Change all default passwords** in `.env`
2. **Use strong, random passwords** (22+ characters)
3. **Never commit `.env` to Git** (use `.env.example`)
4. **Enable firewall** on your VPS:
   ```bash
   sudo ufw enable
   sudo ufw allow 22
   sudo ufw allow 80
   sudo ufw allow 443
   ```
5. **Keep Docker updated**: `docker-compose pull && make restart`
6. **Regular backups**: `make backup` (schedule with cron)

## Support & Issues

For issues specific to this setup, check:
- `TROUBLESHOOTING_HTTPS.md` - HTTPS certificate problems
- `QUICK_REFERENCE.txt` - Quick command reference
- n8n documentation: https://docs.n8n.io

## License

This setup repository is provided as-is for deploying n8n on Hetzner VPS infrastructure.

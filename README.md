# n8n Self-Hosted Setup

Production-ready self-hosted n8n instance with Docker, PostgreSQL, Redis, and Traefik.

## Directory Structure

```
/home/sites/n8n/
├── docker-compose.yml      # Docker Compose configuration
├── .env                     # Environment variables (KEEP SECURE!)
├── Makefile                # Convenient management commands
├── README.md               # This file
├── config/
│   ├── encryption_key.txt  # n8n encryption key (keep secure)
│   └── init-data.sh        # PostgreSQL initialization script
├── scripts/
│   ├── update.sh          # Safely update n8n
│   ├── backup.sh          # Create timestamped backups
│   ├── restore.sh         # Restore from backup
│   └── logs.sh            # View service logs
├── data/                   # Local files for n8n workflows
└── backup/                 # Timestamped backups
```

## Quick Start

### 1. Start Services

```bash
cd /home/sites/n8n
docker-compose up -d
```

Or using Make:

```bash
make up
```

### 2. Access n8n

- **URL**: http://localhost:5678 (internal)
- **Public URL**: https://localhost:9999 (via Traefik)
- Complete initial setup wizard on first access

### 3. Check Status

```bash
make status
```

## Configuration

Edit `.env` file to customize:

- `N8N_HOST` - Hostname
- `TRAEFIK_DOMAIN` - Domain for Traefik
- `N8N_EXTERNAL_PORT` - External port (default: 9999)
- `GENERIC_TIMEZONE` - Timezone
- Database and Redis passwords

**IMPORTANT**: Keep `.env` and `config/encryption_key.txt` secure!

## Common Commands

### Using Make

```bash
make help                # Show all available commands
make up                  # Start all services
make down                # Stop all services
make status              # Show service status
make logs                # View all logs
make logs-n8n            # View n8n logs only
make backup              # Create backup
make restore             # Restore from backup
make update              # Update n8n safely
make restart             # Restart all services
```

### Using Docker Compose

```bash
docker-compose up -d                    # Start
docker-compose down                     # Stop
docker-compose ps                       # Status
docker-compose logs -f n8n              # View n8n logs
docker-compose restart                  # Restart
```

## Backup and Restore

### Create Backup

```bash
make backup
# or
./scripts/backup.sh
```

Backups are saved to `/home/sites/n8n/backup/` with timestamp.

### Restore from Backup

```bash
make restore
# or
./scripts/restore.sh
```

Select backup file when prompted.

## Updates

Update n8n safely with automatic backup:

```bash
make update
# or
./scripts/update.sh
```

Process:
1. Creates backup before update
2. Pulls latest images
3. Restarts services
4. Verifies health

## Services

### n8n (Main)
- Handles UI, API, and webhook triggers
- Internal port: 5678
- Container: n8n-main

### n8n Worker
- Processes queued workflows
- Scales horizontally (add more workers in docker-compose.yml)
- Container: n8n-worker

### PostgreSQL
- Persistent workflow data storage
- Database: n8n
- User: n8n (non-root)
- Container: n8n-postgres

### Redis
- Queue management for workflow distribution
- Container: n8n-redis

### Traefik
- Reverse proxy with HTTPS/TLS
- Manages routing and certificates
- External ports: 80, 443, 9999
- Container: n8n-traefik

## Scaling Workers

To add more workers, edit `docker-compose.yml`:

```yaml
n8n-worker-2:
  image: n8nio/n8n:latest
  container_name: n8n-worker-2
  restart: always
  user: '1000:1000'
  depends_on:
    postgres:
      condition: service_healthy
    redis:
      condition: service_healthy
  command: worker
  environment:
    # Same environment as n8n-worker
    ...
  volumes:
    - n8n_storage:/home/node/.n8n
  networks:
    - n8n-net
```

Then run: `docker-compose up -d`

## HTTPS Configuration

### Let's Encrypt (Recommended)

1. Point domain to server IP
2. Update `.env`:
   ```
   TRAEFIK_DOMAIN=yourdomain.com
   ```
3. Update `docker-compose.yml` Traefik email
4. Restart: `make restart`

### Self-Signed Certificate

Already configured for local use. Traefik will generate certificates automatically.

## Auto-Restart on Reboot

Services are configured with `restart: always` policy. To ensure Docker starts on boot:

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

Verify:
```bash
sudo systemctl status docker
```

## Monitoring

### View Logs

```bash
# All services
make logs

# Specific service
make logs-n8n
make logs-worker
make logs-db
```

### Health Checks

All services have health checks. View container health:

```bash
docker-compose ps
```

Health status shows in "Status" column.

## Security Best Practices

1. **Keep .env secure** - Contains database passwords
2. **Restrict file permissions** - `chmod 600` on `.env`
3. **Use strong passwords** - Change defaults in `.env`
4. **Enable HTTPS** - Use domain with Let's Encrypt
5. **Regular backups** - Automate with cron:
   ```bash
   0 2 * * * /home/sites/n8n/scripts/backup.sh >> /var/log/n8n-backup.log 2>&1
   ```
6. **Keep images updated** - Regular `make update`
7. **Monitor logs** - Watch for errors

## Troubleshooting

### Services won't start

Check logs:
```bash
make logs
```

Verify Docker is running:
```bash
docker ps
```

### Database connection errors

```bash
docker-compose exec postgres pg_isready -U postgres -d n8n
```

### Redis connection errors

```bash
docker-compose exec redis redis-cli ping
```

### n8n not responding

```bash
docker-compose restart n8n
docker-compose logs n8n
```

### Port conflicts

Change `N8N_EXTERNAL_PORT` in `.env` if port 9999 is in use.

## Useful Links

- [n8n Documentation](https://docs.n8n.io)
- [Docker Compose Reference](https://docs.docker.com/compose/reference/)
- [Traefik Documentation](https://doc.traefik.io)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

## Support

For issues:
1. Check logs: `make logs`
2. Verify health: `make status`
3. Review configuration: `make config`
4. Consult n8n docs: https://docs.n8n.io

## License

n8n is open source. See [n8n License](https://github.com/n8n-io/n8n/blob/master/LICENSE.md)

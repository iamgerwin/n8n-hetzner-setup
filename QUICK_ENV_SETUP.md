# Quick Environment Setup

## Generate Secure Passwords & Keys

```bash
# Generate n8n encryption key (32 chars hex)
openssl rand -hex 32

# Generate PostgreSQL password
openssl rand -base64 18

# Generate Redis password
openssl rand -base64 18
```

## Template for Your .env

Save the output and fill in this template:

```env
# N8N Configuration
N8N_HOST=your-domain.com
N8N_PORT=5678
N8N_PROTOCOL=https
WEBHOOK_URL=https://your-domain.com/
N8N_ENCRYPTION_KEY=[PASTE_HEX_KEY_HERE]

# PostgreSQL Configuration
POSTGRES_USER=postgres
POSTGRES_PASSWORD=[PASTE_FIRST_PASSWORD_HERE]
POSTGRES_DB=n8n
POSTGRES_NON_ROOT_USER=n8n
POSTGRES_NON_ROOT_PASSWORD=[PASTE_SECOND_PASSWORD_HERE]

# Redis Configuration
REDIS_PASSWORD=[PASTE_THIRD_PASSWORD_HERE]

# Execution Mode
EXECUTIONS_MODE=queue
QUEUE_HEALTH_CHECK_ACTIVE=true
OFFLOAD_MANUAL_EXECUTIONS_TO_WORKERS=true

# Traefik Configuration
TRAEFIK_DOMAIN=your-domain.com
N8N_EXTERNAL_PORT=443

# Timezone
GENERIC_TIMEZONE=UTC

# Security
N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=false
INSECURE_COOKIE=false
N8N_SECURE_COOKIE=true
```

## Steps

1. Generate passwords using commands above
2. Copy `.env.example` to `.env`
3. Fill in your values
4. Never commit `.env` to git
5. Run `make up` to start services

## One-Liner Setup

For VPS with proper DNS setup:

```bash
# 1. Clone repo
git clone https://github.com/iamgerwin/n8n-hetzner-setup.git ~/n8n && cd ~/n8n

# 2. Setup env
cp .env.example .env
nano .env  # Edit with your domain and generated passwords

# 3. Start
make up

# 4. Auto-start on reboot
sudo ./scripts/install-systemd.sh

# Done! Access at https://your-domain.com
```

# 🚀 START HERE - n8n Hetzner Setup Guide

Welcome! Your n8n Hetzner setup is now version-controlled and ready for deployment across multiple VPS instances.

## 📍 Where Am I?

You have two scenarios:

### Scenario 1: Current VPS (Already Running)
You're on the VPS where n8n is currently operational. Your `.env` file has production passwords.

**What to do:**
1. Review `REPO_SETUP_SUMMARY.md` - understand what's been set up
2. Create backups regularly: `make backup`
3. When ready to migrate, follow "VPS Migration" below

### Scenario 2: New VPS (Setting Up Fresh)
You're deploying to a fresh Hetzner VPS without n8n running yet.

**What to do:**
1. Jump to the "Quick Start" section below

---

## ⚡ Quick Start (New VPS)

```bash
# SSH into your new VPS
ssh root@your-new-vps-ip

# Clone the repository
cd /home/sites
git clone https://github.com/iamgerwin/n8n-hetzner-setup.git n8n
cd n8n

# Setup environment variables
cp .env.example .env
nano .env  # Edit with your values

# Start all services
make up

# Install auto-restart on reboot
sudo ./scripts/install-systemd.sh

# Done!
# Access your n8n at: https://your-domain.com
```

**Time needed**: ~15-20 minutes (mostly waiting for Docker and SSL certificate)

---

## 🔑 Environment Variables Quick Ref

Open `.env` and update these critical values:

```bash
# Your domain
N8N_HOST=your-domain.com
TRAEFIK_DOMAIN=your-domain.com

# Generate these securely:
# openssl rand -hex 32
N8N_ENCRYPTION_KEY=paste_generated_key_here

# Database passwords (change these!)
POSTGRES_PASSWORD=your_secure_password_here
POSTGRES_NON_ROOT_PASSWORD=your_secure_password_here

# Redis password
REDIS_PASSWORD=your_secure_password_here
```

⚠️ **Never commit `.env` to GitHub** - it's in `.gitignore` for security

---

## 📚 Documentation Map

| Document | Purpose | Read When |
|----------|---------|-----------|
| **REPO_SETUP_SUMMARY.md** | Complete overview | First time after setup |
| **QUICK_ENV_SETUP.md** | Generate passwords & keys | Setting up `.env` |
| **DEPLOYMENT.md** | Detailed deployment guide | Deploying to new VPS |
| **QUICK_REFERENCE.txt** | Command cheat sheet | Daily operations |
| **HTTPS_SETUP.md** | Certificate configuration | SSL/TLS issues |
| **TROUBLESHOOTING_HTTPS.md** | Certificate troubleshooting | Certificate problems |

---

## 🔄 VPS Migration (5 Steps)

### Step 1: Backup Current VPS
```bash
ssh root@current-vps
cd /home/sites/n8n
make backup
# Creates backup-TIMESTAMP.tar.gz
```

### Step 2: Download Backup
```bash
# From your local machine
scp root@current-vps:/home/sites/n8n/backup/backup-*.tar.gz ./
```

### Step 3: Setup New VPS
```bash
# SSH into new VPS
ssh root@new-vps
cd /home/sites
git clone https://github.com/iamgerwin/n8n-hetzner-setup.git n8n
cd n8n
cp .env.example .env
# Edit .env with new domain (if different)
nano .env
```

### Step 4: Restore Backup
```bash
# Use the interactive migration script
./scripts/migrate-to-new-vps.sh
# Choose option 2 (restore from backup)
# Point to your backup file
```

### Step 5: Install Auto-Start
```bash
sudo ./scripts/install-systemd.sh
# Choose to start now
```

Done! Your n8n with all workflows is on the new VPS.

---

## 📊 What's Running

Your Docker setup includes:

```
┌─────────────────────────────────────┐
│      Traefik (Reverse Proxy)        │
│    - HTTPS with Let's Encrypt       │
│    - Domain routing                 │
└────────────┬────────────────────────┘
             │ HTTPS
             ▼
┌─────────────────────────────────────┐
│        n8n Main Application         │
│    - Port 5678 (internal)           │
│    - Worker processes               │
└────────────┬────────────────────────┘
             │
    ┌────────┴────────┐
    ▼                 ▼
┌─────────┐      ┌──────────┐
│PostgreSQL│     │  Redis   │
│Database  │     │  Cache   │
└──────────┘     └──────────┘
```

Check status: `make status`

---

## 🛠️ Essential Commands

```bash
# Manage services
make up              # Start all
make down            # Stop all
make restart         # Restart all
make status          # Check health

# Monitor
make logs            # View all logs
make logs-n8n        # View n8n only
docker ps            # List containers

# Backup & Recovery
make backup          # Create backup
make restore         # Restore backup

# Updates
make update          # Update n8n safely
```

---

## 🔐 Security Checklist

Before first deployment:
- [ ] Generated secure encryption key
- [ ] Changed all default passwords
- [ ] Domain points to VPS IP
- [ ] Updated `.env` file
- [ ] Never committed `.env` to Git
- [ ] Enabled firewall (if needed)

---

## ✅ Verification Checklist

After starting services:
- [ ] Services running: `make status`
- [ ] Access n8n: `https://your-domain.com`
- [ ] Create admin user
- [ ] SSL certificate valid (no browser warnings)
- [ ] Database connected (check n8n settings)
- [ ] Auto-start configured: `sudo systemctl status n8n`

---

## 🆘 Common Issues

### "Domain not working"
- Check DNS: `nslookup your-domain.com`
- Should point to your VPS IP
- Wait 5-10 minutes for DNS propagation

### "Certificate not valid"
- Check Traefik logs: `docker logs n8n_traefik_1`
- Ensure domain is reachable
- See: `TROUBLESHOOTING_HTTPS.md`

### "Services won't start"
- Check logs: `make logs`
- Check Docker: `docker ps -a`
- Verify `.env` syntax

### "Lost connection after reboot"
- Check systemd: `sudo systemctl status n8n`
- View logs: `sudo journalctl -u n8n -f`
- Restart: `sudo systemctl restart n8n`

---

## 📞 Support Resources

- **n8n Docs**: https://docs.n8n.io
- **Docker Docs**: https://docs.docker.com
- **Let's Encrypt**: https://letsencrypt.org/
- **GitHub Issues**: Check repository

---

## 🎯 Next Steps

1. ✅ Read `REPO_SETUP_SUMMARY.md`
2. ✅ Setup `.env` with your values
3. ✅ Run `make up` and verify
4. ✅ Setup auto-start: `sudo ./scripts/install-systemd.sh`
5. ✅ Create a backup: `make backup`
6. ✅ Import your workflows
7. ✅ Test critical automations

---

**Repository**: https://github.com/iamgerwin/n8n-hetzner-setup  
**Branch**: main  
**Author**: Gerwin  
**Email**: iamgerwin@live.com

Ready to deploy? Start with DEPLOYMENT.md or run `make up`! 🚀

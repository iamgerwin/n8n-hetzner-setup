# HTTPS Setup with Let's Encrypt

Your n8n instance is now configured for HTTPS. Follow these steps to obtain a certificate.

## Prerequisites

- Domain `usisa.store` must point to your server IP: `77.42.19.179`
- DNS A record should be updated
- Port 80 (HTTP) must be accessible from the internet

## Step-by-Step Setup

### 1. Point Your Domain to the Server

Update your DNS records:
```
Type: A
Name: usisa.store (or @ for root)
Value: 77.42.19.179
TTL: 3600
```

Wait 5-15 minutes for DNS propagation. Test with:
```bash
dig usisa.store
nslookup usisa.store
```

### 2. Obtain Let's Encrypt Certificate

Once DNS is updated, request the certificate:

```bash
sudo certbot certonly \
  --standalone \
  --agree-tos \
  --no-eff-email \
  --email admin@usisa.store \
  -d usisa.store \
  --preferred-challenges http
```

Or use the automated script:
```bash
sudo /home/sites/n8n/scripts/setup-https.sh
```

### 3. Verify Certificate

After successful certificate request:

```bash
sudo ls -la /etc/letsencrypt/live/usisa.store/
```

You should see:
- `fullchain.pem` - Full certificate chain
- `privkey.pem` - Private key
- `cert.pem` - Certificate
- `chain.pem` - Intermediate certificates

### 4. Restart Services

Restart nginx and n8n to load the certificate:

```bash
cd /home/sites/n8n
docker-compose restart nginx n8n
```

### 5. Access n8n via HTTPS

- **Main URL**: https://usisa.store/
- **Port 9999**: https://usisa.store:9999/
- **Redirect**: http://usisa.store automatically redirects to HTTPS

## Certificate Renewal

Let's Encrypt certificates expire after 90 days. Set up automatic renewal:

### Automatic Renewal with Cron

Add to crontab:
```bash
sudo crontab -e
```

Add this line (runs daily at 2 AM):
```
0 2 * * * certbot renew --quiet && docker-compose -f /home/sites/n8n/docker-compose.yml restart nginx
```

Or use the renewal script:
```bash
# Check for expiring certificates
sudo certbot renew --dry-run

# Renew all certificates
sudo certbot renew
```

## Troubleshooting

### Domain doesn't resolve
```bash
# Test DNS
dig usisa.store
nslookup usisa.store

# Wait for DNS propagation (5-15 min typically)
```

### Port 80 not accessible
- Ensure firewall allows port 80
- Check if another service is using port 80
- Verify Docker nginx is running: `docker-compose ps`

### Certificate already exists
If you get "Certificate already in use" error:
```bash
# Remove old certificate
sudo certbot delete --cert-name usisa.store

# Then request new one
sudo certbot certonly ...
```

### Nginx won't start
Check logs:
```bash
docker-compose logs nginx
```

If certificate paths are wrong, verify:
```bash
sudo ls -la /etc/letsencrypt/live/usisa.store/
```

### Invalid certificate error in browser
- Clear browser cache and cookies
- Try in incognito/private mode
- Wait a few minutes for certificate propagation

## SSL Security Configuration

The Nginx configuration includes:

- **TLS 1.2 & 1.3** - Modern encryption
- **HTTP/2** - Performance
- **Security Headers**:
  - HSTS (Strict-Transport-Security)
  - X-Content-Type-Options
  - X-Frame-Options

## Testing HTTPS

After setup, test your SSL configuration:

```bash
# Using curl
curl -I https://usisa.store/

# Using openssl
openssl s_client -connect usisa.store:443

# Using SSL Labs (online)
# Visit: https://www.ssllabs.com/ssltest/analyze.html?d=usisa.store
```

## Ports and Access

After HTTPS setup:
- **HTTP (80)**: Redirects to HTTPS
- **HTTPS (443)**: Main secure access
- **9999**: Alternative HTTPS access
- **Internal (5678)**: n8n service (Docker only)

## Security Best Practices

1. **Always use HTTPS** - Enable secure cookies
2. **Certificate backup** - Backup `/etc/letsencrypt` regularly
3. **Monitor renewal** - Check logs for renewal errors
4. **Keep Docker updated** - `docker-compose pull && docker-compose up -d`
5. **Strong passwords** - Use complex credentials

## Configuration Files

- **Nginx config**: `/home/sites/n8n/config/nginx.conf`
- **Docker config**: `/home/sites/n8n/docker-compose.yml`
- **n8n config**: `/home/sites/n8n/.env`
- **Certificate path**: `/etc/letsencrypt/live/usisa.store/`

## Next Steps

1. ✅ Point domain to server (DNS A record)
2. ⏳ Wait for DNS propagation
3. 🔐 Run certificate request
4. 🔄 Restart services
5. 🌐 Access at https://usisa.store:9999

---

For more help:
- Let's Encrypt: https://letsencrypt.org/
- Certbot: https://certbot.eff.org/
- Nginx: https://nginx.org/

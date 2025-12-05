# HTTPS Setup - Quick Start

Your n8n is now ready for Let's Encrypt HTTPS. Follow these 3 quick steps.

## Step 1: Update DNS (5 minutes)

Point your domain to your server:

**Update your domain registrar DNS settings:**
```
Type: A Record
Name: usisa.store (or @ for root)
Value: 77.42.19.179
TTL: 3600 (or lower for faster updates)
```

**Verify DNS is updated:**
```bash
dig usisa.store
# Should show: 77.42.19.179
```

Wait 5-15 minutes for global DNS propagation.

## Step 2: Get Certificate (2 minutes)

Once DNS is updated, request your certificate:

```bash
sudo certbot certonly \
  --standalone \
  --agree-tos \
  --no-eff-email \
  --email admin@usisa.store \
  -d usisa.store
```

Or use the automated script:
```bash
sudo /home/sites/n8n/scripts/setup-https.sh
```

**Expected output:**
```
Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/usisa.store/fullchain.pem
Key is saved at: /etc/letsencrypt/live/usisa.store/privkey.pem
```

## Step 3: Enable HTTPS (1 minute)

Update Nginx to use the certificate:

```bash
# Copy the SSL config
sudo cp /home/sites/n8n/config/nginx-ssl.conf /home/sites/n8n/config/nginx.conf

# Restart services
cd /home/sites/n8n
docker-compose restart nginx n8n
```

Or manually update the Nginx config to use SSL certificates.

## Done! 🎉

Your n8n is now accessible via HTTPS:

```
https://usisa.store:9999
```

- **HTTP (80)** → Auto-redirects to HTTPS
- **HTTPS (443)** → Secure main access
- **Port 9999** → Alternative HTTPS access

## Test Your Setup

```bash
# Check certificate
curl -I https://usisa.store:9999/

# Full SSL test
openssl s_client -connect usisa.store:443

# Online SSL test
# Visit: https://www.ssllabs.com/ssltest/analyze.html?d=usisa.store
```

## Auto-Renewal (Set & Forget)

Add to crontab for automatic renewal:

```bash
sudo crontab -e
```

Add this line:
```
0 2 * * * certbot renew --quiet && docker-compose -f /home/sites/n8n/docker-compose.yml restart nginx
```

This runs daily at 2 AM and auto-renews expiring certificates.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| DNS not resolving | Wait 5-15 min, check with `nslookup usisa.store` |
| Certbot fails | Ensure port 80 is open: `sudo ufw allow 80` |
| Nginx won't start | Check logs: `docker-compose logs nginx` |
| Certificate not found | Verify: `sudo ls -la /etc/letsencrypt/live/usisa.store/` |

## Files Location

- **Nginx config**: `/home/sites/n8n/config/nginx.conf`
- **Certificate**: `/etc/letsencrypt/live/usisa.store/`
- **Full docs**: `/home/sites/n8n/HTTPS_SETUP.md`
- **Setup script**: `/home/sites/n8n/scripts/setup-https.sh`

## Support Links

- [Let's Encrypt](https://letsencrypt.org/)
- [Certbot Docs](https://certbot.eff.org/docs/using.html)
- [Nginx SSL](https://nginx.org/en/docs/http/ngx_http_ssl_module.html)

---

**Status**: Ready for HTTPS setup
**Domain**: usisa.store
**Server IP**: 77.42.19.179
**Email**: admin@usisa.store

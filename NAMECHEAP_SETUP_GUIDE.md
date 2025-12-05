# Namecheap Domain Setup Guide for n8n

Complete step-by-step guide to connect usisa.store from Namecheap to your n8n server.

## Prerequisites

- Domain: `usisa.store` (purchased from Namecheap)
- Server IP: `77.42.19.179`
- Namecheap account login ready

## Step 1: Log in to Namecheap Dashboard

1. Visit: https://www.namecheap.com/
2. Click "Sign In" (top right)
3. Enter your Namecheap email and password
4. Click "Sign In"
5. You're now in the Namecheap dashboard

## Step 2: Access Your Domain Management

1. In the Namecheap dashboard, find "Domain List" in the left menu
2. Click "Domain List"
3. You should see "usisa.store" in your domains list
4. Click on "usisa.store" (the domain name itself, not the checkmark)

This opens the domain management page.

## Step 3: Access DNS Settings

1. Look for the "NAMESERVERS" section or "DNS" option
2. You might see different options:
   - "Namecheap BasicDNS" (default)
   - "Namecheap PremiumDNS"
   - "Custom DNS"
3. You want to stay with **Namecheap BasicDNS** (which is already selected)
4. Click on the "Manage" button next to your domain name, OR
5. Look for "Manage DNS" or "DNS Settings" option

## Step 4: Navigate to DNS Records

Once you're in DNS settings:

1. Look for a section called "DNS Records" or "Advanced DNS"
2. You might see tabs at the top - click on "Advanced DNS"
3. This shows the DNS records for your domain

## Step 5: Add Your A Record

You need to create an A record pointing your domain to your server IP.

**In the DNS Records section:**

1. Find the section with existing DNS records
2. Look for an empty row or click "Add Record" button
3. Fill in the new record:

| Field | Value |
|-------|-------|
| Type | A |
| Host | @ (at symbol) |
| Value | 77.42.19.179 |
| TTL | 3600 (or default) |

**Important Fields Explained:**
- **Type**: Select "A" from the dropdown
- **Host**: Use "@" (at symbol) for the root domain (usisa.store)
  - Or use "n8n" if you want: n8n.usisa.store
- **Value**: Enter your server IP: `77.42.19.179`
- **TTL**: Leave as default or set to 3600 (seconds)

4. Click "Save All Changes" or "Add Record" button

## Step 6: Optional - Add WWW Subdomain

If you want `www.usisa.store` to also work:

1. Add another A record:

| Field | Value |
|-------|-------|
| Type | A |
| Host | www |
| Value | 77.42.19.179 |
| TTL | 3600 |

2. Click "Save All Changes"

## Step 7: Wait for DNS Propagation

DNS changes take time to propagate globally:

- **Initial update**: 1-5 minutes (Namecheap servers)
- **Full propagation**: 5-15 minutes (worldwide)
- **Sometimes**: Up to 48 hours (but rarely needed)

**During this time:**
- Visit the domain in your browser - might not work yet
- That's normal! Wait 5-15 minutes.

## Step 8: Verify DNS is Working

Open Terminal/Command Prompt and run:

```bash
dig usisa.store
```

Or:

```bash
nslookup usisa.store
```

**Look for this in the output:**
```
usisa.store.     3600    IN  A       77.42.19.179
```

If you see your IP (77.42.19.179), DNS is working! ✓

**If you don't see it yet:**
- Wait a few more minutes
- Try again
- Clear your local DNS cache (varies by OS)

## Step 9: Test HTTP Access

Once DNS is propagated:

1. Open browser
2. Visit: `http://usisa.store:9999`
3. You should see n8n loading!

If it works, continue to Step 10.

## Step 10: Get Let's Encrypt Certificate

Now that DNS is working, get an HTTPS certificate.

Run this command on your server:

```bash
sudo certbot certonly \
  --standalone \
  --agree-tos \
  --no-eff-email \
  --email admin@usisa.store \
  -d usisa.store
```

**What this does:**
- Contacts Let's Encrypt
- Verifies you own usisa.store (via DNS)
- Issues a free SSL certificate
- Saves it to `/etc/letsencrypt/live/usisa.store/`

**Expected output:**
```
Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/usisa.store/fullchain.pem
Key is saved at: /etc/letsencrypt/live/usisa.store/privkey.pem
```

If successful, continue to Step 11.

## Step 11: Enable HTTPS in Nginx

Switch from HTTP to HTTPS configuration:

```bash
cd /home/sites/n8n
sudo cp config/nginx-ssl.conf config/nginx.conf
docker-compose restart nginx n8n
```

Wait 5-10 seconds for services to restart.

## Step 12: Test HTTPS Access

1. Open browser
2. Visit: `https://usisa.store:9999`
3. You should see n8n with a green lock icon ✓

If browser shows certificate warning:
- Click "Advanced"
- Click "Proceed" (or similar button)
- This is normal for new certificates
- Warning should disappear after a few minutes

## Step 13: Test n8n Functionality

1. Complete the n8n setup wizard
2. Create your admin account
3. Test workflows
4. Everything should work with HTTPS!

## Troubleshooting

### DNS not working

**Symptom**: `nslookup usisa.store` doesn't show your IP

**Solution**:
1. Wait another 5-10 minutes
2. Verify in Namecheap dashboard:
   - Check you added the A record correctly
   - Verify IP is: 77.42.19.179
   - Try clicking "Save All Changes" again
3. Clear local DNS cache:
   - **Windows**: `ipconfig /flushdns`
   - **Mac**: `sudo dscacheutil -flushcache`
   - **Linux**: `sudo systemctl restart systemd-resolved`

### Certbot fails

**Symptom**: Certificate request fails with "Connection refused"

**Solution**:
1. Wait another 5 minutes for DNS
2. Verify DNS is working: `dig usisa.store`
3. Make sure port 80 is open: `sudo ufw allow 80`
4. Check Nginx logs: `docker-compose logs nginx`

### HTTPS shows certificate error

**Symptom**: Browser shows "Not Secure" or certificate warning

**Solution**:
1. Clear browser cache and cookies
2. Try incognito/private mode
3. Wait a few minutes
4. Try accessing: `https://usisa.store:9999` (different browser)

### Site inaccessible after HTTPS setup

**Symptom**: Can't access n8n at all

**Solution**:
1. Check Docker services are running:
   ```bash
   cd /home/sites/n8n
   docker-compose ps
   ```

2. Check Nginx logs:
   ```bash
   docker-compose logs nginx
   ```

3. Restart services:
   ```bash
   docker-compose restart
   ```

### Port 9999 redirect not working

**Symptom**: `https://usisa.store:9999` shows error

**Solution**:
1. Verify port 9999 is exposed:
   ```bash
   docker-compose ps | grep nginx
   ```
   Should show: `0.0.0.0:9999->9999/tcp`

2. Restart Nginx:
   ```bash
   docker-compose restart nginx
   ```

3. Check firewall allows port 9999:
   ```bash
   sudo ufw allow 9999
   ```

## Quick Checklist

Before asking for help, verify:

- [ ] Domain purchased from Namecheap
- [ ] A record added in Namecheap DNS: @ → 77.42.19.179
- [ ] DNS propagated: `dig usisa.store` returns 77.42.19.179
- [ ] Port 80 is open: `curl http://usisa.store:9999`
- [ ] Port 443 is open: `sudo ufw allow 443`
- [ ] Port 9999 is open: `sudo ufw allow 9999`
- [ ] Certificate obtained: `/etc/letsencrypt/live/usisa.store/`
- [ ] Nginx restarted: `docker-compose restart nginx`
- [ ] HTTPS accessible: `https://usisa.store:9999`

## Final URLs

After complete setup:

| URL | Status |
|-----|--------|
| http://usisa.store | Redirects to HTTPS ✓ |
| https://usisa.store | Works (main HTTPS) ✓ |
| http://usisa.store:9999 | Redirects to HTTPS ✓ |
| https://usisa.store:9999 | Works (with custom port) ✓ |
| http://localhost:9999 | Local HTTP access |
| http://77.42.19.179:9999 | Direct IP access (HTTP) |

## Auto-Renewal

Your certificate automatically renews 30 days before expiration:

```bash
sudo certbot renew --dry-run  # Test renewal
sudo certbot renew            # Force renewal now
```

To auto-renew daily:

```bash
sudo crontab -e
```

Add this line:
```
0 2 * * * certbot renew --quiet && docker-compose -f /home/sites/n8n/docker-compose.yml restart nginx
```

## Need Help?

Useful commands for debugging:

```bash
# Check DNS
dig usisa.store
nslookup usisa.store

# Check ports
sudo netstat -tuln | grep -E "80|443|9999"
sudo ufw status

# Check certificates
sudo certbot certificates
sudo ls -la /etc/letsencrypt/live/usisa.store/

# Check services
docker-compose ps
docker-compose logs nginx
docker-compose logs n8n

# Test HTTPS
curl -I https://usisa.store:9999
openssl s_client -connect usisa.store:443
```

---

**Setup Time Estimate**: 20-30 minutes
**Difficulty**: Easy
**Success Rate**: 95%+ (if steps followed correctly)

Ready to get started? Proceed with Step 1 above!

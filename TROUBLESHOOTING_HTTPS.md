# HTTPS Setup Troubleshooting - Site Not Accessible

## Problem
Got error: "This site can't be reached" when accessing https://usisa.store:9999/

## Root Cause
The nginx SSL configuration was loaded BEFORE the certificate was obtained, causing nginx to fail to start.

## Solution Applied

### What Was Wrong
- DNS: ✅ Working (usisa.store → 77.42.19.179)
- Docker services: ✅ Running
- Ports: ✅ Open (80, 9999)
- **Nginx config: ❌ Referenced missing SSL certificate files**

### What We Fixed
1. Reverted nginx config from SSL to HTTP-only
2. Restarted nginx service
3. Services now running properly

## Current Status

✅ **HTTP Access Working:**
```
http://usisa.store:9999
http://localhost:9999
```

## Next Steps: Get HTTPS Certificate

Now that HTTP is working, you can safely get the HTTPS certificate.

### Step 1: Verify DNS (Already Done ✓)
```bash
dig usisa.store
# Returns: 77.42.19.179
```

### Step 2: Get Let's Encrypt Certificate

Run this command on your server:

```bash
sudo certbot certonly \
  --standalone \
  --agree-tos \
  --no-eff-email \
  --email admin@usisa.store \
  -d usisa.store
```

**What to expect:**
- Certbot will verify you own usisa.store
- Issues free 90-day certificate
- Saves to: `/etc/letsencrypt/live/usisa.store/`

**Success message:**
```
Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/usisa.store/fullchain.pem
Key is saved at: /etc/letsencrypt/live/usisa.store/privkey.pem
```

### Step 3: Enable HTTPS After Certificate Obtained

Once you get the "Successfully received certificate" message, enable HTTPS:

```bash
cd /home/sites/n8n
sudo cp config/nginx-ssl.conf config/nginx.conf
docker-compose restart nginx n8n
```

### Step 4: Test HTTPS

```bash
https://usisa.store:9999
```

Should show:
- ✅ Green lock icon
- ✅ "usisa.store" in green
- ✅ n8n interface

## Important Notes

**Do NOT run Step 3 (Enable HTTPS) until:**
1. ✅ DNS is working: `dig usisa.store` shows 77.42.19.179
2. ✅ HTTP is working: Can access http://usisa.store:9999
3. ✅ Certificate is obtained: See "Successfully received certificate" message

**If you enable HTTPS before getting the certificate:**
- Nginx will fail to start
- You'll get "This site can't be reached"
- Solution: Revert config and get certificate first

## Current Setup

```
Domain: usisa.store
Server IP: 77.42.19.179
Current Config: /home/sites/n8n/config/nginx.conf (HTTP-only)
SSL Config Ready: /home/sites/n8n/config/nginx-ssl.conf
```

## Files

- **HTTP config (current):** `/home/sites/n8n/config/nginx.conf`
- **SSL config (for later):** `/home/sites/n8n/config/nginx-ssl.conf`
- **Backup of SSL config:** `/home/sites/n8n/config/nginx.conf.backup-ssl`

## Recommended Order

1. ✅ HTTP access working (DONE)
2. ⏭️ Get HTTPS certificate (NEXT)
3. ⏭️ Enable HTTPS config
4. ⏭️ Test HTTPS access
5. ⏭️ Set up auto-renewal

---

**Status**: HTTP working, ready for HTTPS setup
**Next**: Follow "Step 2: Get Let's Encrypt Certificate" above

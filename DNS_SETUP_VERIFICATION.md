# DNS Not Resolving - Verification & Fix Guide

## Problem
Your computer can't resolve usisa.store:
```
ping: cannot resolve usisa.store: Unknown host
```

But the server can resolve it. This means DNS hasn't propagated globally yet.

## Step 1: Verify DNS is Set in Namecheap

**Log in to Namecheap:**
1. Go to https://www.namecheap.com/
2. Sign in with your account
3. Click "Domain List" (left menu)
4. Click on "usisa.store"
5. Click "Advanced DNS" or "Manage DNS"

**Check your DNS records:**

You should see a table like this. Look for an A record:

```
Type    Host    Value           TTL
────────────────────────────────────────
A       @       77.42.19.179    3600
```

**If you see it:** DNS is set correctly. Wait for propagation (see Step 2).

**If you DON'T see it:** Add it:
1. Find empty row or click "Add Record"
2. Set:
   - Type: A
   - Host: @
   - Value: 77.42.19.179
   - TTL: 3600
3. Click "Save All Changes"

## Step 2: Wait for DNS Propagation

DNS changes don't happen instantly worldwide. Timeline:

- **0-1 min:** Changes saved to Namecheap
- **1-5 min:** Your ISP's DNS updates
- **5-15 min:** Most resolvers worldwide update
- **Up to 48 hrs:** Some old caches update (rare)

**During this time:**
- Your computer might not resolve the domain yet
- That's **COMPLETELY NORMAL**
- Just wait

## Step 3: Check DNS Propagation Status

### Method 1: Use Online Tools (Recommended for you)

Visit these websites to check if DNS has propagated:

1. **DNSChecker** (https://dnschecker.org/)
   - Enter: usisa.store
   - It checks multiple DNS servers worldwide
   - Shows green if propagated, red if not

2. **WhatsMyDNS** (https://www.whatsmydns.net/)
   - Enter: usisa.store
   - Shows propagation status globally

3. **MXToolbox** (https://mxtoolbox.com/dnslookup.aspx)
   - Enter: usisa.store
   - Shows DNS records

### Method 2: Command Line (On server or Linux/Mac computer)

```bash
# Check specific DNS server
dig @8.8.8.8 usisa.store          # Google DNS
dig @1.1.1.1 usisa.store          # Cloudflare DNS
nslookup usisa.store 8.8.8.8      # Alternative command

# Expected output:
usisa.store.        3600    IN  A       77.42.19.179
```

**If it returns 77.42.19.179:** DNS is propagated to that server.

### Method 3: Check Your Computer's DNS

```bash
# On Mac/Linux/Windows:
nslookup usisa.store

# Look for answer section with IP 77.42.19.179
```

## Step 4: Force DNS Cache Clear (If still not working)

Your computer might have cached the old/wrong DNS. Clear it:

### Windows
```cmd
ipconfig /flushdns
```

### Mac
```bash
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
```

### Linux
```bash
sudo systemctl restart systemd-resolved
```

Then try again:
```bash
ping usisa.store
```

## Step 5: Use IP Address Directly (While Waiting)

While DNS propagates, you can access n8n using the IP address directly:

```
http://77.42.19.179:9999
```

This bypasses DNS completely and should work immediately.

## Troubleshooting Checklist

**If DNS still doesn't work:**

1. ✅ Check A record exists in Namecheap
   - Type: A
   - Host: @
   - Value: 77.42.19.179

2. ✅ Verify it was saved
   - Refresh the page
   - Should still be there

3. ✅ Check Nameservers
   - Should be Namecheap BasicDNS (default)
   - Click "Manage" → "Nameserver Settings"
   - Should show Namecheap nameservers

4. ✅ Wait longer
   - Even if DNS checkers show pending, wait 15+ minutes
   - Some ISPs cache DNS longer

5. ✅ Use online DNS checker
   - Visit: https://dnschecker.org/
   - Enter: usisa.store
   - Shows propagation across multiple servers

## Common Issues

### "DNS is set but still not resolving"
- **Cause:** Hasn't propagated yet globally
- **Solution:** Wait 10-15 minutes, then check online

### "A record shows different IP"
- **Cause:** Wrong IP was set
- **Solution:** Update it to 77.42.19.179

### "Can't find usisa.store in Domain List"
- **Cause:** Logged in to wrong Namecheap account
- **Solution:** Check you're using correct account email

### "DNS works on server but not computer"
- **Cause:** Not fully propagated yet
- **Solution:** Check with online tool, use IP address meanwhile

## Quick Reference

| Check | Command | Expected |
|-------|---------|----------|
| DNS from server | `dig usisa.store` | 77.42.19.179 |
| DNS online | Visit dnschecker.org | Green checkmarks |
| Local DNS | `nslookup usisa.store` | 77.42.19.179 |
| IP access | `ping 77.42.19.179` | Works immediately |

## Meantime: Access n8n

While DNS propagates, use the direct IP:

```
http://77.42.19.179:9999
```

You can use n8n normally while DNS finishes propagating.

## Timeline

**You are here:**
```
0 min: A record added to Namecheap
↓ (waiting)
5 min: Some resolvers updated
↓ (waiting)
10-15 min: Most resolvers updated ← Your computer might be here
↓ (waiting)
48 hrs: All resolvers updated
```

The server resolved it because it's closer to Namecheap's DNS. Your computer's ISP DNS takes longer.

---

**Current Status:** DNS set in Namecheap ✓ | Waiting for global propagation ⏳

**Action:** 
1. Wait 10-15 minutes
2. Try again: `ping usisa.store`
3. If still not working, use: `http://77.42.19.179:9999`

**Next Steps:**
- Once DNS works: Continue with HTTPS setup
- See: TROUBLESHOOTING_HTTPS.md

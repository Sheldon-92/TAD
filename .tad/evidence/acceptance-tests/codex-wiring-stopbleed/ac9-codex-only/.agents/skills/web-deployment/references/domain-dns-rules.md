# Domain & DNS Rules
<!-- capability: domain_dns -->

## Quick Rule Index

| # | Rule | Applies When |
|---|------|-------------|
| DN1 | Custom domain setup: add to platform + update DNS records (10-20 min) | Every custom domain |
| DN2 | Record types: CNAME for subdomains, A/ALIAS for apex | DNS configuration |
| DN3 | SSL: automatic Let's Encrypt on all major platforms | HTTPS setup |
| DN4 | HTTP to HTTPS redirect: mandatory, built-in on all platforms | Every domain |
| DN5 | Cache-Control strategy: immutable for hashed assets, no-cache for HTML | Static asset serving |
| DN6 | CAA records to restrict certificate issuance | SSL certificate security |
| DN7 | DNS propagation: verify with dig, expect up to 48h for global propagation | After DNS changes |

---

## Rules

### DN1: Custom Domain Setup

When connecting a custom domain to a deployment platform:

**Vercel**:
```bash
# CLI
vercel domains add example.com
vercel domains add www.example.com

# Or via vercel.json
# { "alias": ["example.com", "www.example.com"] }
```
DNS records to add:
| Type | Name | Value |
|------|------|-------|
| A | @ | `76.76.21.21` |
| CNAME | www | `cname.vercel-dns.com` |

**Netlify**:
```bash
# After deploy, add custom domain in site settings
netlify domains:add example.com
```
DNS records to add:
| Type | Name | Value |
|------|------|-------|
| A | @ | `75.2.60.5` (Netlify load balancer) |
| CNAME | www | `<site-name>.netlify.app` |

**Fly.io**:
```bash
flyctl certs add example.com
flyctl certs show example.com  # shows required DNS records
```

**General process** (10-20 minutes):
1. Add domain in platform dashboard or CLI
2. Platform provides required DNS records
3. Add records at your DNS provider (Cloudflare, Namecheap, Route53)
4. Wait for propagation (usually 5-30 min, up to 48h)
5. Platform auto-provisions SSL certificate

### DN2: DNS Record Types

When configuring DNS records, use the correct record type:

| Record Type | Use Case | Example |
|-------------|----------|---------|
| A | Apex domain (example.com) to IPv4 address | `@ -> 76.76.21.21` |
| AAAA | Apex domain to IPv6 address | `@ -> 2606:4700::1` |
| CNAME | Subdomain to another domain | `www -> cname.vercel-dns.com` |
| ALIAS/ANAME | Apex domain to another domain (provider-specific) | `@ -> myapp.netlify.app` |
| TXT | Domain verification, SPF, DKIM | `@ -> "v=spf1 ..."` |
| MX | Email routing | `@ -> mail.example.com` |
| CAA | Certificate authority authorization | `@ -> 0 issue "letsencrypt.org"` |

**Key rule**: CNAME records CANNOT be used on apex domains (`example.com`). Use A record or ALIAS/ANAME (if your DNS provider supports it). Cloudflare supports CNAME flattening at apex.

**Subdomain structure**:
```
example.com          -> Production app (A record)
www.example.com      -> Redirect to example.com (CNAME)
staging.example.com  -> Staging environment (CNAME)
api.example.com      -> API server (CNAME or A)
docs.example.com     -> Documentation (CNAME)
```

### DN3: Automatic SSL

When setting up HTTPS, use platform-managed Let's Encrypt. Every major platform provisions SSL automatically:

| Platform | SSL Provisioning | Time | Action Required |
|----------|-----------------|------|-----------------|
| Vercel | Automatic | <60s after DNS propagation | None (add domain, it works) |
| Netlify | Automatic | <60s after DNS propagation | None |
| Fly.io | Automatic | 1-5 min | `flyctl certs add domain.com` |
| Cloudflare | Automatic (Universal SSL) | Minutes | Enable "Full (Strict)" mode |
| Coolify | Automatic (Traefik + Let's Encrypt) | 1-2 min | Configure domain in UI |

**Self-hosted with Certbot**:
```bash
sudo certbot --nginx -d example.com -d www.example.com
# Auto-renewal is configured automatically
sudo certbot renew --dry-run  # verify renewal works
```

### DN4: HTTP to HTTPS Redirect (MANDATORY)

When a domain is live, HTTP (port 80) MUST redirect to HTTPS (port 443). All major platforms do this automatically:

- **Vercel**: Automatic, no configuration needed
- **Netlify**: Automatic, no configuration needed
- **Cloudflare**: Enable "Always Use HTTPS" in SSL/TLS settings
- **Nginx** (self-hosted):
  ```nginx
  server {
      listen 80;
      server_name example.com www.example.com;
      return 301 https://$server_name$request_uri;
  }
  ```

**Verification**:
```bash
# Should return 301 redirect to https://
curl -sI http://example.com | head -3

# Should return 200 with security headers
curl -sI https://example.com | head -10
```

### DN5: Cache-Control Strategy

When serving static assets, set Cache-Control headers correctly:

| Resource Type | Cache-Control | Reason |
|--------------|--------------|--------|
| Hashed static assets (JS, CSS, images) | `public, max-age=31536000, immutable` | Filename changes on content change — safe to cache forever |
| HTML pages | `no-cache` or `max-age=0, must-revalidate` | Must always check for latest version |
| API responses | `no-store` or `private, max-age=60` | User-specific or real-time data |
| Fonts | `public, max-age=31536000, immutable` | Rarely change, large download cost |

**Vercel** (`vercel.json`):
```json
{
  "headers": [
    {
      "source": "/assets/(.*)",
      "headers": [
        { "key": "Cache-Control", "value": "public, max-age=31536000, immutable" }
      ]
    }
  ]
}
```

**Netlify** (`netlify.toml`):
```toml
[[headers]]
  for = "/assets/*"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"

[[headers]]
  for = "/*.html"
  [headers.values]
    Cache-Control = "no-cache"
```

### DN6: CAA Records

When securing SSL certificate issuance, add CAA (Certificate Authority Authorization) records to restrict which CAs can issue certificates for your domain:

```
example.com.  CAA  0 issue "letsencrypt.org"
example.com.  CAA  0 issue "digicert.com"
example.com.  CAA  0 issuewild "letsencrypt.org"
example.com.  CAA  0 iodef "mailto:security@example.com"
```

- `issue`: Authorizes CA to issue standard certs
- `issuewild`: Authorizes CA to issue wildcard certs
- `iodef`: Email address for violation reports

**Why**: Without CAA, any CA can issue a certificate for your domain. A compromised CA could issue a fraudulent cert for MITM attacks.

### DN7: DNS Propagation Verification

When DNS changes are made, verify propagation:

```bash
# Check current DNS records
dig example.com A +short
dig www.example.com CNAME +short
dig example.com CAA +short

# Check from multiple locations
dig @8.8.8.8 example.com A +short      # Google DNS
dig @1.1.1.1 example.com A +short      # Cloudflare DNS
dig @208.67.222.222 example.com A +short # OpenDNS

# Check SSL certificate
openssl s_client -connect example.com:443 -servername example.com < /dev/null 2>/dev/null | openssl x509 -noout -dates

# Full DNS audit
nslookup -type=ANY example.com
```

**Propagation times**:
- Low TTL records (300s): 5-10 minutes
- Standard TTL (3600s): 1-4 hours
- Global propagation: up to 48 hours

**Pre-migration tip**: Lower TTL to 300s 24-48 hours BEFORE the DNS change. After migration is verified, raise TTL back to 3600s.

---

## Anti-Patterns

- **HTTP without HTTPS redirect**: Credentials, cookies, and data sent in plaintext. Every domain must redirect HTTP to HTTPS.
- **Static assets with `no-cache`**: Forces re-download of unchanged JS/CSS on every page load. Use `immutable` with hashed filenames.
- **API responses with long cache**: `Cache-Control: max-age=86400` on API responses means users see stale data for 24 hours.
- **CNAME on apex domain**: Most DNS providers do not support CNAME on `example.com` (only subdomains). Use A record or ALIAS.
- **SSL "Flexible" mode on Cloudflare**: User sees HTTPS padlock, but traffic from Cloudflare to your server is unencrypted HTTP. Use "Full (Strict)".
- **No CAA records**: Any CA can issue certificates for your domain. Restrict to your actual CA (Let's Encrypt, DigiCert).
- **DNS migration without lowering TTL**: Changing DNS records with a 24-hour TTL means some users see old records for a full day. Lower TTL first.

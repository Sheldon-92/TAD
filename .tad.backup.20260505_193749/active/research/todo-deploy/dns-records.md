# DNS Configuration: todoapp.example.com

## DNS Records Table

| Type | Name | Value | TTL | Proxy | Notes |
|---|---|---|---|---|---|
| CNAME | todoapp | cname.vercel-dns.com. | 300 | No | Production — Vercel managed |
| CNAME | staging.todoapp | cname.vercel-dns.com. | 300 | No | Staging environment |
| CNAME | www.todoapp | todoapp.example.com. | 300 | No | Redirect www to apex |
| TXT | _vercel.todoapp | vc-domain-verify=xxxxx | 3600 | No | Vercel domain verification |
| CAA | todoapp | 0 issue "letsencrypt.org" | 3600 | No | Restrict cert issuance to Let's Encrypt |
| CAA | todoapp | 0 issuewild ";" | 3600 | No | Deny wildcard certs |
| MX | todoapp | 10 mail.example.com. | 3600 | No | [ASSUMPTION] If email needed |

## SSL/TLS Configuration

| Setting | Value | Notes |
|---|---|---|
| Provider | Let's Encrypt (via Vercel) | Auto-managed, auto-renewed |
| TLS Version | 1.2+ (1.3 preferred) | Vercel enforces minimum TLS 1.2 |
| HTTP -> HTTPS | Automatic 308 redirect | Vercel default behavior |
| HSTS | max-age=31536000; includeSubDomains; preload | Set in vercel.json headers |
| Certificate Transparency | Enabled by default | Let's Encrypt publishes to CT logs |

## Cache-Control Strategy

| Resource Type | Cache-Control Value | Rationale |
|---|---|---|
| HTML pages | `no-cache` (revalidate every request) | Ensure users always see latest content |
| `/_next/static/*` | `public, max-age=31536000, immutable` | Content-hashed filenames, safe to cache forever |
| `/images/*` | `public, max-age=86400, stale-while-revalidate=604800` | Cache 1 day, serve stale up to 7 days while revalidating |
| `/api/*` | `no-store, no-cache, must-revalidate` | API responses must never be cached |
| Fonts | `public, max-age=31536000, immutable` | Font files don't change once deployed |
| favicon.ico | `public, max-age=604800` | Cache 7 days |

## Performance Optimizations

```html
<!-- Add to <head> in layout.tsx -->
<link rel="dns-prefetch" href="//o0.ingest.sentry.io" />
<link rel="preconnect" href="https://fonts.googleapis.com" crossorigin />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
```

## Verification Commands (Run Post-Deploy)

```bash
# Check HTTPS redirect
curl -sI http://todoapp.example.com | head -5

# Check security headers
curl -sI https://todoapp.example.com | grep -iE "(strict-transport|x-frame|x-content-type|referrer-policy|permissions-policy|content-security)"

# Check SSL certificate
echo | openssl s_client -connect todoapp.example.com:443 -servername todoapp.example.com 2>/dev/null | openssl x509 -noout -dates

# Check DNS resolution
dig todoapp.example.com CNAME +short
dig todoapp.example.com CAA +short
```

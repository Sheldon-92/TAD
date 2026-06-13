# Security Hardening Rules
<!-- capability: security_hardening -->

## Quick Rule Index

| # | Rule | Applies When |
|---|------|-------------|
| SH1 | OWASP security headers: set 6, remove 2 | Every web application |
| SH2 | CSP two-phase rollout: report-only first, enforce after review | Content Security Policy |
| SH3 | Checkov for IaC scanning, Snyk/Grype for container images | Infrastructure and container security |
| SH4 | SSL auto-provisioned via Let's Encrypt — never manage certs manually | All HTTPS configurations |
| SH5 | Rate limiting at the edge, not just application layer | API and login endpoints |
| SH6 | Platform-specific header configuration via config files | Vercel / Netlify / Next.js |
| SH7 | Cookie security: Secure + HttpOnly + SameSite=Strict | Authentication cookies |
| SH8 | Verify artifact attestations before deploy — fail closed on unsigned artifacts | Release / supply-chain gate |

---

## Rules

### SH1: OWASP Security Headers (MANDATORY)

When deploying any web application, configure these headers:

**Headers to SET**:

| Header | Value | Protects Against |
|--------|-------|-----------------|
| `Content-Security-Policy` | See SH2 for full policy | XSS, data injection |
| `Strict-Transport-Security` | `max-age=31536000; includeSubDomains; preload` | HTTPS downgrade attacks |
| `X-Content-Type-Options` | `nosniff` | MIME type sniffing |
| `X-Frame-Options` | `DENY` | Clickjacking |
| `Referrer-Policy` | `strict-origin-when-cross-origin` | Referrer information leakage |
| `Permissions-Policy` | `camera=(), microphone=(), geolocation=()` | Unauthorized API access |

**Headers to REMOVE**:

| Header | Why Remove |
|--------|-----------|
| `X-Powered-By` | Reveals technology stack (Express, PHP, etc.) |
| `Server` | Reveals server software and version |

**Next.js** (`next.config.js`):
```javascript
module.exports = {
  poweredByHeader: false,  // removes X-Powered-By
  async headers() {
    return [{
      source: '/(.*)',
      headers: [
        { key: 'X-Content-Type-Options', value: 'nosniff' },
        { key: 'X-Frame-Options', value: 'DENY' },
        { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
        { key: 'Strict-Transport-Security', value: 'max-age=31536000; includeSubDomains' },
        { key: 'Permissions-Policy', value: 'camera=(), microphone=(), geolocation=()' },
      ],
    }];
  },
};
```

### SH2: CSP Two-Phase Rollout (MANDATORY)

When implementing Content Security Policy, NEVER go straight to enforcement. A strict CSP will break inline scripts, third-party widgets, and analytics — resulting in a "security improvement" that takes down the site.

**Phase 1: Report-Only** (2-4 weeks):
```
Content-Security-Policy-Report-Only: default-src 'self'; script-src 'self' 'nonce-{random}'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; report-uri /api/csp-report
```
- Collect violation reports WITHOUT blocking anything
- Review reports to identify legitimate sources that need whitelisting
- Adjust policy until violation reports drop to near-zero

**Phase 2: Enforce**:
```
Content-Security-Policy: default-src 'self'; script-src 'self' 'nonce-{random}'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; report-uri /api/csp-report
```

**Nonce-based CSP** (preferred over `unsafe-inline`):
```typescript
// middleware.ts
import { NextResponse } from 'next/server';
import crypto from 'crypto';

export function middleware(request) {
  const nonce = crypto.randomBytes(16).toString('base64');
  const response = NextResponse.next();
  response.headers.set(
    'Content-Security-Policy',
    `script-src 'self' 'nonce-${nonce}'; style-src 'self' 'unsafe-inline';`
  );
  return response;
}
```

### SH3: IaC and Container Security Scanning

When deploying infrastructure-as-code or container images:

**Checkov for IaC** (Terraform, CloudFormation, Kubernetes manifests):
```bash
pip install checkov
checkov -d .                        # scan current directory
checkov -f main.tf                  # scan specific file
checkov --framework terraform       # scan only Terraform files
checkov --skip-check CKV_AWS_123    # skip specific check (with justification)
```

**Container image scanning**:
```bash
# Grype (open-source, fast)
grype myapp:latest                  # scan local image
grype registry.example.com/myapp:abc123  # scan remote image

# Snyk (more detailed, requires account)
snyk container test myapp:latest
snyk container monitor myapp:latest  # continuous monitoring

# Trivy (comprehensive, includes IaC)
trivy image myapp:latest
trivy fs .                          # filesystem scan
```

**CI integration** (GitHub Actions):
```yaml
- name: Scan IaC
  run: checkov -d . --output cli --soft-fail  # warn, don't block initially

- name: Scan container
  run: |
    grype myapp:${{ github.sha }} --fail-on high
    # Blocks pipeline on HIGH or CRITICAL vulnerabilities
```

### SH4: SSL via Let's Encrypt (Automatic)

When configuring HTTPS, use platform-managed SSL. Never manage certificates manually.

| Platform | SSL Provider | Setup |
|----------|-------------|-------|
| Vercel | Automatic (Let's Encrypt) | Add domain in dashboard / `vercel domains add` |
| Netlify | Automatic (Let's Encrypt) | Add domain, SSL provisioned in <60s |
| Fly.io | Automatic (Let's Encrypt) | `flyctl certs add example.com` |
| Coolify | Automatic (Let's Encrypt via Traefik) | Configure domain in Coolify UI |
| Self-hosted | Certbot | `certbot --nginx -d example.com` |

**Certbot for self-hosted** (VPS with Nginx):
```bash
# Install
sudo apt install certbot python3-certbot-nginx

# Obtain + auto-configure Nginx
sudo certbot --nginx -d example.com -d www.example.com

# Auto-renewal (certbot installs a cron/systemd timer)
sudo certbot renew --dry-run  # test renewal
```

**Cloudflare SSL modes** (when using Cloudflare as CDN):
- **Full (Strict)**: MANDATORY. Encrypts browser-to-Cloudflare AND Cloudflare-to-origin.
- **Full**: Encrypts both, but doesn't validate origin cert. Vulnerable to MITM at origin.
- **Flexible**: NEVER USE. Browser-to-Cloudflare is HTTPS, but Cloudflare-to-origin is HTTP (plaintext).

### SH5: Rate Limiting at the Edge

When protecting APIs and login endpoints, rate limit at the edge (before traffic reaches your server):

| Endpoint | Limit | Window |
|----------|-------|--------|
| Login / auth | 5 requests | per minute per IP |
| API (authenticated) | 60 requests | per minute per user |
| API (public) | 20 requests | per minute per IP |
| General | 1000 requests | per minute per IP |

**Vercel Edge Middleware**:
```typescript
// middleware.ts
import { Ratelimit } from '@upstash/ratelimit';
import { Redis } from '@upstash/redis';
import { ipAddress } from '@vercel/functions';   // NextRequest.ip/.geo were REMOVED in Next.js 15
import type { NextRequest } from 'next/server';

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(60, '1 m'),
});

export async function middleware(request: NextRequest) {
  // `request.ip` was removed in Next.js 15 (vercel/next.js PR #68379) — it is now undefined.
  // On Vercel, read the client IP via @vercel/functions instead.
  const ip = ipAddress(request) ?? '127.0.0.1';
  const { success } = await ratelimit.limit(ip);
  if (!success) {
    return new Response('Too Many Requests', { status: 429 });
  }
}
```

**Why edge, not just application**: Application-layer rate limiting means the request already consumed server resources (TLS handshake, connection, routing). Edge rate limiting blocks at the CDN level.

### SH6: Platform-Specific Header Configuration

**Vercel** (`vercel.json`):
```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        { "key": "X-Frame-Options", "value": "DENY" },
        { "key": "Referrer-Policy", "value": "strict-origin-when-cross-origin" },
        { "key": "Strict-Transport-Security", "value": "max-age=31536000; includeSubDomains" },
        { "key": "Permissions-Policy", "value": "camera=(), microphone=(), geolocation=()" }
      ]
    }
  ]
}
```

**Netlify** (`netlify.toml`):
```toml
[[headers]]
  for = "/*"
  [headers.values]
    X-Content-Type-Options = "nosniff"
    X-Frame-Options = "DENY"
    Referrer-Policy = "strict-origin-when-cross-origin"
    Strict-Transport-Security = "max-age=31536000; includeSubDomains"
    Permissions-Policy = "camera=(), microphone=(), geolocation=()"
```

**Netlify `_headers` file** (alternative):
```
/*
  X-Content-Type-Options: nosniff
  X-Frame-Options: DENY
  Referrer-Policy: strict-origin-when-cross-origin
  Strict-Transport-Security: max-age=31536000; includeSubDomains
  Permissions-Policy: camera=(), microphone=(), geolocation=()
```

### SH7: Cookie Security

When setting authentication cookies:

```typescript
res.cookie('session', token, {
  httpOnly: true,      // not accessible via JavaScript (prevents XSS theft)
  secure: true,        // only sent over HTTPS
  sameSite: 'strict',  // not sent with cross-site requests (prevents CSRF)
  maxAge: 86400000,    // 24 hours
  path: '/',
});
```

**Rules**:
- `httpOnly: true` — MANDATORY for session cookies. Prevents `document.cookie` access.
- `secure: true` — MANDATORY. Cookie only transmitted over HTTPS.
- `sameSite: 'strict'` — Default for auth cookies. Use `'lax'` only if cross-site navigation is required.
- Never store sensitive data directly in cookies. Store a session ID that references server-side data.

### SH8: Verify Artifact Attestations Before Deploy (Fail Closed)

Header hardening protects the served response; **attestation verification** protects what you ship onto the box. This is the deploy-time consumer side of CI12 (which generates the attestation in CI). **GitHub Artifact Attestations** are built on **Sigstore** (ephemeral ~10-minute signing certs) with the **Rekor** transparency log, binding the artifact **digest** to a **SLSA build-provenance** predicate.

The deploy step MUST verify provenance and **fail closed** if there is no valid attestation for the expected repo — an unsigned artifact is indistinguishable from a tampered one:

```bash
# Verify a release artifact before promoting it (fails non-zero if unsigned/wrong repo):
gh attestation verify dist/myapp.tar.gz --repo <owner/repo> \
  || { echo "[P0] no valid attestation — refusing to deploy"; exit 1; }

# Verify a container image by digest:
gh attestation verify oci://ghcr.io/<owner>/<app>@sha256:<digest> --repo <owner/repo>
```

This extends the cross-cutting **Immutable Deploys + OIDC** rule with end-to-end provenance: OIDC proves *who* authenticated, immutability fixes *what* ran, and attestation proves the artifact *came from your pipeline and was not swapped in transit*. Source: docs.github.com Artifact Attestations (retrieved 2026-06-13).

---

## Anti-Patterns

- **CSP with `unsafe-inline`**: Equivalent to no CSP. Use nonce-based CSP instead.
- **CORS `*` wildcard**: Allows any origin to call your API. Whitelist specific origins.
- **Not removing `X-Powered-By`**: Tells attackers your stack is Express/Rails/PHP. Remove it.
- **Rate limiting only at application layer**: Request already consumed server resources. Rate limit at the edge.
- **CSP enforce without report-only phase**: Will break third-party scripts, analytics, and widgets. Always test with report-only first.
- **Cloudflare SSL "Flexible" mode**: Browser sees HTTPS padlock but Cloudflare-to-origin is plaintext HTTP. Use Full (Strict).
- **Manual certificate management**: Certbot auto-renews. Manual cert management = expired certs at 2 AM.
- **Deploying an unattested artifact**: an artifact with no SLSA provenance can't be distinguished from a tampered one. Gate deploy on `gh attestation verify ... --repo <owner/repo>` and fail closed.

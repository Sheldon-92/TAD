# Security Hardening: Todo App

## OWASP Security Headers Checklist

### Headers to SET

| Header | Value | Protects Against | Status |
|---|---|---|---|
| Content-Security-Policy | nonce-based strict (see security-headers.ts) | XSS, data injection | Phase 1: Report-Only |
| Strict-Transport-Security | max-age=31536000; includeSubDomains; preload | Protocol downgrade, cookie theft | Configured in vercel.json |
| X-Content-Type-Options | nosniff | MIME sniffing attacks | Configured in vercel.json |
| X-Frame-Options | DENY | Clickjacking | Configured in vercel.json |
| Referrer-Policy | strict-origin-when-cross-origin | Information leakage | Configured in vercel.json |
| Permissions-Policy | camera=(), microphone=(), geolocation=(), browsing-topics=(), payment=(), usb=() | Feature abuse | Configured in vercel.json |
| Cross-Origin-Opener-Policy | same-origin | Spectre-style side-channel | Configured in security-headers.ts |
| Cross-Origin-Resource-Policy | same-origin | Cross-origin data theft | Configured in security-headers.ts |
| Cross-Origin-Embedder-Policy | require-corp | Cross-origin embedding | Configured in security-headers.ts |

### Headers to REMOVE

| Header | Reason | How |
|---|---|---|
| X-Powered-By | Reveals technology stack (Next.js) | `poweredByHeader: false` in next.config.js |
| Server | Reveals server software | Vercel strips by default |

## CSP Implementation Plan

### Phase 1: Report-Only (Week 1-2)
1. Deploy with `Content-Security-Policy-Report-Only` header
2. Set up `/api/csp-report` endpoint to collect violations
3. Monitor violation reports in Sentry or dedicated log
4. Whitelist legitimate sources found in reports

### Phase 2: Enforce (Week 3+)
1. Switch from `Content-Security-Policy-Report-Only` to `Content-Security-Policy`
2. Keep `report-uri` for ongoing monitoring
3. Test all pages, especially dynamic content areas

## Rate Limiting Design

| Endpoint | Limit | Window | Penalty |
|---|---|---|---|
| POST /api/auth/login | 5 requests | 1 minute | 429 + 60s cooldown |
| POST /api/auth/register | 3 requests | 1 minute | 429 + 120s cooldown |
| GET/POST /api/todos | 60 requests | 1 minute | 429 + 30s cooldown |
| All other /api/* | 100 requests | 1 minute | 429 + 30s cooldown |
| Global (per IP) | 1000 requests | 1 minute | 429 + 60s cooldown |

### Implementation
- **Recommended**: `@upstash/ratelimit` with Vercel KV (Redis-based, edge-compatible)
- **Alternative**: Vercel Edge Middleware with in-memory Map (single-region only)
- See `middleware.ts` for implementation skeleton

## Additional Security Measures

### Cookie Security
```
Set-Cookie: session=...; Secure; HttpOnly; SameSite=Strict; Path=/; Max-Age=604800
```

### CORS Configuration
```typescript
// Only allow requests from our own domain
const ALLOWED_ORIGINS = [
  'https://todoapp.example.com',
  'https://staging.todoapp.example.com',
];
// Never use Access-Control-Allow-Origin: *
```

### Dependency Security
- `npm audit` in CI pipeline (ci.yml)
- GitHub Dependabot enabled for security updates
- [ASSUMPTION] Consider `actions/dependency-review-action` for PR-level supply chain checks

Sources:
- [OWASP Secure Headers Project](https://owasp.org/www-project-secure-headers/)
- [OWASP HTTP Headers Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/HTTP_Headers_Cheat_Sheet.html)
- [OWASP CSP Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Content_Security_Policy_Cheat_Sheet.html)

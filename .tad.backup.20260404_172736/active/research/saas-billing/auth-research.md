# Authentication & Authorization Research — Multi-Tenant SaaS Billing

## 1. Authentication Strategy

### Dual Authentication Model

| Method | Use Case | Token Location | Expiry |
|--------|----------|----------------|--------|
| **JWT (Bearer Token)** | User sessions (web app, dashboard) | `Authorization: Bearer <token>` | Access: 15min, Refresh: 7 days |
| **API Key** | Server-to-server (usage recording, automation) | `X-API-Key: <key>` | Configurable (default: 90 days), revocable |
| **Stripe HMAC** | Webhook verification only | `Stripe-Signature` header | Per-request (timestamp + signature) |

### JWT Token Claims

```json
{
  "sub": "usr_clx1234567890",
  "tenantId": "ten_clx1234567890",
  "role": "TENANT_ADMIN",
  "permissions": ["subscriptions:read", "subscriptions:write", "invoices:read", "users:read", "users:write"],
  "iat": 1711900800,
  "exp": 1711901700,
  "iss": "https://api.example.com",
  "aud": "https://api.example.com"
}
```

### Token Lifecycle
1. **Login**: POST /v1/auth/login → returns `{ accessToken, refreshToken, expiresIn }`
2. **Request**: `Authorization: Bearer <accessToken>` on every API call
3. **Refresh**: POST /v1/auth/refresh with `{ refreshToken }` → new accessToken + rotated refreshToken
4. **Logout**: POST /v1/auth/logout → invalidate refreshToken (add to deny list)
5. **Revocation**: Refresh tokens stored in DB, deleted on logout/password change

### API Key Design
- Key format: `sk_live_<random_32_bytes_base64>` (prefix indicates environment)
- Storage: Only SHA-256 hash stored in `ApiKey` table. Plain key shown once at creation.
- Scoping: API keys are tenant-scoped (inherit tenant context, no user context)
- Rate limit: 1000 req/min per key (configurable per tenant)

## 2. Multi-Tenant x Multi-Role Permission Matrix

### RBAC Matrix — All Resources x All Roles

| Resource.Action | SuperAdmin | TenantAdmin | BillingAdmin | Member |
|-----------------|:----------:|:-----------:|:------------:|:------:|
| **Tenants** | | | | |
| tenants:create | ALL | - | - | - |
| tenants:read | ALL | OWN | OWN | OWN |
| tenants:update | ALL | OWN | - | - |
| tenants:delete | ALL | - | - | - |
| **Users** | | | | |
| users:create | ALL | OWN | - | - |
| users:read | ALL | OWN | OWN | SELF |
| users:update | ALL | OWN | - | SELF |
| users:delete | ALL | OWN | - | - |
| **Plans** | | | | |
| plans:create | ALL | - | - | - |
| plans:read | ALL | ALL | ALL | ALL |
| plans:update | ALL | - | - | - |
| plans:delete | ALL | - | - | - |
| **Subscriptions** | | | | |
| subscriptions:create | ALL | OWN | OWN | - |
| subscriptions:read | ALL | OWN | OWN | OWN |
| subscriptions:update | ALL | OWN | OWN | - |
| subscriptions:cancel | ALL | OWN | OWN | - |
| subscriptions:change-plan | ALL | OWN | OWN | - |
| **Invoices** | | | | |
| invoices:read | ALL | OWN | OWN | OWN |
| invoices:pay | ALL | OWN | OWN | - |
| **Usage** | | | | |
| usage:record | API_KEY | API_KEY | API_KEY | - |
| usage:read | ALL | OWN | OWN | OWN |
| **AuditLog** | | | | |
| audit:read | ALL | OWN | - | - |

**Legend:**
- `ALL` = Can access across all tenants (platform-wide)
- `OWN` = Can access only within own tenant
- `SELF` = Can access only own record
- `-` = No access
- `API_KEY` = Authenticated via API Key (server-to-server only)

## 3. Stripe Webhook Signature Verification

Stripe uses HMAC-SHA256, NOT JWT:
1. Stripe sends `Stripe-Signature` header: `t=timestamp,v1=signature`
2. Compute expected signature: `HMAC-SHA256(webhook_secret, timestamp + "." + raw_body)`
3. Compare computed signature with `v1` value from header
4. Reject if timestamp is older than 300 seconds (replay protection)

[ASSUMPTION] Using `stripe.webhooks.constructEvent()` from the Stripe Node.js SDK, which handles all verification logic internally.

## 4. Security Checklist (OWASP Compliance)

- [x] Password hashing: bcrypt with cost factor 12 (or argon2id)
- [x] JWT: Short-lived access tokens (15min)
- [x] Refresh token rotation: Old refresh token invalidated on use
- [x] Login failure response: Generic "Invalid credentials" (no user enumeration)
- [x] Rate limiting: Login endpoint: 5 attempts/minute per IP
- [x] API Key: Hashed storage, prefix-based identification
- [x] CORS: Whitelist specific origins (no `*`)
- [x] CSRF: Not applicable (Bearer token auth, not cookie-based)
- [x] Sensitive operations: Password change requires current password
- [x] Token in response body only (never in URL query params)

## Sources
- [Stripe Webhook Signature Verification](https://docs.stripe.com/webhooks)
- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)

# API Documentation — Multi-Tenant SaaS Billing System

## Getting Started

### Base URL
- Production: `https://api.example.com/v1`
- Staging: `https://api-staging.example.com/v1`
- Development: `http://localhost:3000/v1`

### Authentication

This API supports two authentication methods:

#### 1. JWT Bearer Token (User Sessions)

```bash
# Login to get tokens
curl -X POST https://api.example.com/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "alice@acme.com", "password": "password123"}'

# Response:
# { "accessToken": "eyJ...", "refreshToken": "eyJ...", "expiresIn": 900 }

# Use token in subsequent requests
curl https://api.example.com/v1/tenants/ten_abc123 \
  -H "Authorization: Bearer eyJ..."

# Refresh when expired (15 min)
curl -X POST https://api.example.com/v1/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{"refreshToken": "eyJ..."}'
```

#### 2. API Key (Server-to-Server)

```bash
# Use API key for usage recording
curl -X POST https://api.example.com/v1/usage-records \
  -H "X-API-Key: sk_live_your_key_here" \
  -H "Content-Type: application/json" \
  -d '{"tenantId": "ten_abc", "subscriptionId": "sub_xyz", "featureName": "api_calls", "quantity": 100, "transactionId": "txn_unique_123"}'
```

### Error Format (RFC 7807)

All errors return RFC 7807 Problem Details:

```json
{
  "type": "https://api.example.com/errors/not-found",
  "title": "Not Found",
  "status": 404,
  "detail": "The requested resource was not found.",
  "error_code": "RESOURCE_NOT_FOUND",
  "request_id": "req_abc123"
}
```

Validation errors include field-level details:

```json
{
  "type": "https://api.example.com/errors/validation-failed",
  "title": "Validation Failed",
  "status": 422,
  "detail": "Request body contains invalid fields.",
  "error_code": "VALIDATION_FAILED",
  "errors": [
    { "field": "email", "message": "Must be a valid email address" },
    { "field": "slug", "message": "Must be lowercase alphanumeric with hyphens" }
  ]
}
```

### Pagination

Cursor-based pagination on all list endpoints:

```bash
# First page
curl "https://api.example.com/v1/tenants/ten_abc/invoices?limit=20"

# Next page (use nextCursor from response)
curl "https://api.example.com/v1/tenants/ten_abc/invoices?limit=20&cursor=inv_last_id"
```

Response format:
```json
{
  "data": [...],
  "meta": { "hasMore": true, "nextCursor": "inv_last_id", "totalCount": 42 }
}
```

---

## Endpoint Reference

### Tenants

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| POST | /v1/tenants | Create tenant | SuperAdmin |
| GET | /v1/tenants | List tenants | SuperAdmin |
| GET | /v1/tenants/{id} | Get tenant | SuperAdmin, TenantAdmin (own) |
| PATCH | /v1/tenants/{id} | Update tenant | SuperAdmin, TenantAdmin (own) |
| DELETE | /v1/tenants/{id} | Soft-delete tenant | SuperAdmin |

### Users

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| POST | /v1/tenants/{tenantId}/users | Create user | TenantAdmin |
| GET | /v1/tenants/{tenantId}/users | List users | TenantAdmin, BillingAdmin |
| GET | /v1/tenants/{tenantId}/users/{id} | Get user | TenantAdmin, self |
| PATCH | /v1/tenants/{tenantId}/users/{id} | Update user | TenantAdmin, self |
| DELETE | /v1/tenants/{tenantId}/users/{id} | Delete user | TenantAdmin |

### Plans (Public Read)

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| POST | /v1/plans | Create plan | SuperAdmin |
| GET | /v1/plans | List plans | Public |
| GET | /v1/plans/{id} | Get plan | Public |
| PATCH | /v1/plans/{id} | Update plan | SuperAdmin |

### Subscriptions

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| POST | /v1/tenants/{tenantId}/subscriptions | Create subscription | TenantAdmin, BillingAdmin |
| GET | /v1/tenants/{tenantId}/subscriptions | List subscriptions | TenantAdmin, BillingAdmin, Member |
| GET | /v1/subscriptions/{id} | Get subscription | Tenant members |
| POST | /v1/subscriptions/{id}/cancel | Cancel | TenantAdmin, BillingAdmin |
| POST | /v1/subscriptions/{id}/reactivate | Reactivate (grace) | TenantAdmin, BillingAdmin |
| POST | /v1/subscriptions/{id}/change-plan | Change plan | TenantAdmin, BillingAdmin |
| GET | /v1/subscriptions/{id}/proration-preview | Preview proration | TenantAdmin, BillingAdmin |

#### Subscription Lifecycle Example

```bash
# 1. Create subscription (starts trial if plan has trialDays)
curl -X POST .../tenants/ten_abc/subscriptions \
  -H "Authorization: Bearer ..." \
  -d '{"planId": "plan_pro", "paymentMethodId": "pm_card_visa"}'

# 2. Preview plan upgrade cost
curl ".../subscriptions/sub_xyz/proration-preview?newPlanId=plan_enterprise"
# Response: { credit: 2450, charge: 9950, prorationAmount: 7500, remainingDays: 15 }

# 3. Execute plan change (with optimistic locking)
curl -X POST .../subscriptions/sub_xyz/change-plan \
  -d '{"newPlanId": "plan_enterprise", "version": 3}'

# 4. Cancel with reason
curl -X POST .../subscriptions/sub_xyz/cancel \
  -d '{"cancelImmediately": false, "reason": "Switching provider"}'

# 5. Reactivate within 7-day grace period
curl -X POST .../subscriptions/sub_xyz/reactivate
```

### Invoices

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| GET | /v1/subscriptions/{id}/invoices | List subscription invoices | Tenant members |
| GET | /v1/tenants/{tenantId}/invoices | List all tenant invoices | TenantAdmin, BillingAdmin |
| GET | /v1/invoices/{id} | Get invoice detail | Tenant members |
| POST | /v1/invoices/{id}/pay | Retry payment | TenantAdmin, BillingAdmin |

### Usage Records

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| POST | /v1/usage-records | Record usage event | API Key |
| GET | /v1/tenants/{tenantId}/usage | Get usage summary | Tenant members |
| GET | /v1/subscriptions/{id}/usage | Get subscription usage | Tenant members |

```bash
# Record usage (idempotent via transactionId)
curl -X POST .../usage-records \
  -H "X-API-Key: sk_live_..." \
  -d '{"tenantId":"ten_abc","subscriptionId":"sub_xyz","featureName":"api_calls","quantity":150,"transactionId":"txn_unique_123"}'

# Get usage summary
curl ".../tenants/ten_abc/usage?period=current"
# Response: { features: [{ name: "api_calls", used: 85000, limit: 100000, percentUsed: 85.0 }] }
```

### Webhooks (Stripe)

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| POST | /v1/webhooks/stripe | Receive Stripe events | Stripe HMAC |

**Handled Events:**
- `invoice.payment_succeeded` — Update invoice + restore PAST_DUE subscriptions
- `invoice.payment_failed` — Update to PAST_DUE + schedule retry
- `customer.subscription.updated` — Sync status from Stripe
- `customer.subscription.deleted` — Set EXPIRED + grace period
- `customer.subscription.trial_will_end` — Send trial ending notification

### WebSocket Endpoints

| Path | Events | Auth |
|------|--------|------|
| /ws/billing-events | PAYMENT_SUCCEEDED, PAYMENT_FAILED, SUBSCRIPTION_CANCELED, SUBSCRIPTION_RESTORED | JWT |
| /ws/usage-alerts | USAGE_ALERT (80%, 90%, 100% thresholds) | JWT |

---

## Billing-Specific Error Codes

| Code | HTTP | When |
|------|------|------|
| PAYMENT_FAILED | 402 | Card declined, insufficient funds, etc. |
| SUBSCRIPTION_LIMIT_REACHED | 403 | Plan usage limit exceeded |
| SUBSCRIPTION_ALREADY_EXISTS | 409 | Tenant already has active subscription |
| INVALID_STATUS_TRANSITION | 409 | Invalid state machine transition |
| GRACE_PERIOD_EXPIRED | 409 | Reactivation after 7-day window |
| CONCURRENT_MODIFICATION | 409 | Optimistic lock version mismatch |
| SUBSCRIPTION_NOT_ACTIVE | 422 | Usage recording on inactive subscription |
| FEATURE_NOT_IN_PLAN | 422 | Usage for feature not in current plan |

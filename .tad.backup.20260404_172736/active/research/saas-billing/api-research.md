# API Design Research — Multi-Tenant SaaS Billing System

## 1. Reference API Analysis

### Stripe Billing API (Primary Reference)
- **Resource model**: Customers, Subscriptions, Invoices, Plans/Prices, PaymentIntents, UsageRecords
- **Nesting**: `/v1/customers/{id}/subscriptions`, `/v1/subscriptions/{id}` (both top-level and nested)
- **Versioning**: Date-based via header (`Stripe-Version: 2025-12-18.acacia`)
- **Pagination**: Cursor-based (`starting_after`, `ending_before`, `limit`)
- **Idempotency**: `Idempotency-Key` header for POST requests
- **Webhook events**: `customer.subscription.created`, `invoice.payment_failed`, etc.

### Chargebee API
- **Resource model**: Customers, Subscriptions, Plans, Addons, Invoices, CreditNotes
- **Nesting**: `/api/v2/customers/{id}/subscriptions`
- **Versioning**: URL path (`/api/v2/`)
- **Pagination**: Offset-based (`offset`, `limit`)

### Lago (Open Source)
- **Resource model**: Customers, Subscriptions, Plans, Charges, Invoices, Wallets, Events
- **Usage tracking**: Event-based API (`POST /events`) with `transaction_id` for dedup
- **Versioning**: URL path (`/api/v1/`)

## 2. Resource Modeling

### Identified Resources (6 domains + supporting)

| # | Resource | Description | Tenant-scoped |
|---|----------|-------------|---------------|
| 1 | **Tenant** | Platform tenant/organization | No (platform-level) |
| 2 | **User** | Authenticated user within a tenant | Yes |
| 3 | **Plan** | Subscription plan definition | No (platform-level) |
| 4 | **Subscription** | Tenant's active subscription to a plan | Yes |
| 5 | **Invoice** | Billing document for a subscription | Yes |
| 6 | **UsageRecord** | API call / storage usage tracking | Yes |
| 7 | **Payment** | Payment attempt for an invoice | Yes |
| 8 | **WebhookEvent** | Inbound Stripe webhook event log | No (platform-level) |
| 9 | **AuditLog** | Change history for compliance | Yes |

### Resource Relationships

```
Tenant 1:N User
Tenant 1:N Subscription
Plan 1:N PlanFeature
Plan 1:N Subscription
Subscription 1:N SubscriptionItem (links Subscription to PlanFeature)
Subscription 1:N Invoice
Invoice 1:N InvoiceLineItem
Invoice 1:N Payment
Tenant 1:N UsageRecord
Subscription 1:N UsageRecord
```

## 3. API Endpoint Design

### Tenants
| Method | URI | Description | Auth |
|--------|-----|-------------|------|
| POST | /v1/tenants | Create tenant | SuperAdmin |
| GET | /v1/tenants | List all tenants | SuperAdmin |
| GET | /v1/tenants/{tenantId} | Get tenant | SuperAdmin, TenantAdmin (own) |
| PATCH | /v1/tenants/{tenantId} | Update tenant | SuperAdmin, TenantAdmin (own) |
| DELETE | /v1/tenants/{tenantId} | Soft-delete tenant | SuperAdmin |

### Users
| Method | URI | Description | Auth |
|--------|-----|-------------|------|
| POST | /v1/tenants/{tenantId}/users | Create user | TenantAdmin |
| GET | /v1/tenants/{tenantId}/users | List users in tenant | TenantAdmin, BillingAdmin |
| GET | /v1/tenants/{tenantId}/users/{userId} | Get user | TenantAdmin, self |
| PATCH | /v1/tenants/{tenantId}/users/{userId} | Update user | TenantAdmin, self |
| DELETE | /v1/tenants/{tenantId}/users/{userId} | Soft-delete user | TenantAdmin |

### Plans (Platform-wide)
| Method | URI | Description | Auth |
|--------|-----|-------------|------|
| POST | /v1/plans | Create plan | SuperAdmin |
| GET | /v1/plans | List available plans | Public |
| GET | /v1/plans/{planId} | Get plan with features | Public |
| PATCH | /v1/plans/{planId} | Update plan | SuperAdmin |
| DELETE | /v1/plans/{planId} | Archive plan | SuperAdmin |

### Subscriptions
| Method | URI | Description | Auth |
|--------|-----|-------------|------|
| POST | /v1/tenants/{tenantId}/subscriptions | Create subscription | TenantAdmin, BillingAdmin |
| GET | /v1/tenants/{tenantId}/subscriptions | List subscriptions | TenantAdmin, BillingAdmin, Member |
| GET | /v1/subscriptions/{subscriptionId} | Get subscription | TenantAdmin, BillingAdmin, Member (own tenant) |
| PATCH | /v1/subscriptions/{subscriptionId} | Update subscription | TenantAdmin, BillingAdmin |
| POST | /v1/subscriptions/{subscriptionId}/cancel | Cancel subscription | TenantAdmin, BillingAdmin |
| POST | /v1/subscriptions/{subscriptionId}/reactivate | Reactivate (within grace) | TenantAdmin, BillingAdmin |
| POST | /v1/subscriptions/{subscriptionId}/change-plan | Upgrade/downgrade | TenantAdmin, BillingAdmin |
| GET | /v1/subscriptions/{subscriptionId}/proration-preview | Preview proration | TenantAdmin, BillingAdmin |

### Invoices
| Method | URI | Description | Auth |
|--------|-----|-------------|------|
| GET | /v1/subscriptions/{subscriptionId}/invoices | List invoices for subscription | TenantAdmin, BillingAdmin, Member (own) |
| GET | /v1/invoices/{invoiceId} | Get invoice detail | TenantAdmin, BillingAdmin, Member (own) |
| POST | /v1/invoices/{invoiceId}/pay | Retry payment | TenantAdmin, BillingAdmin |
| GET | /v1/tenants/{tenantId}/invoices | List all tenant invoices | TenantAdmin, BillingAdmin |

### Usage Records
| Method | URI | Description | Auth |
|--------|-----|-------------|------|
| POST | /v1/usage-records | Record usage event | API Key (server-to-server) |
| GET | /v1/tenants/{tenantId}/usage | Get usage summary | TenantAdmin, BillingAdmin, Member (own) |
| GET | /v1/subscriptions/{subscriptionId}/usage | Get usage for subscription | TenantAdmin, BillingAdmin |

### Webhooks
| Method | URI | Description | Auth |
|--------|-----|-------------|------|
| POST | /v1/webhooks/stripe | Receive Stripe events | Stripe HMAC signature |

### WebSocket Endpoints
| Path | Description | Auth |
|------|-------------|------|
| /ws/billing-events | Real-time billing notifications | JWT (connection auth) |
| /ws/usage-alerts | Usage threshold alerts | JWT (connection auth) |

## 4. Pagination Strategy

**Cursor-based pagination** (following Stripe pattern):
```json
{
  "data": [...],
  "meta": {
    "has_more": true,
    "next_cursor": "sub_abc123",
    "total_count": 42
  }
}
```
- Default page size: 20, max: 100
- Query params: `?limit=20&cursor=sub_abc123&sort=created_at:desc`

## 5. Error Format (RFC 7807)

```json
{
  "type": "https://api.example.com/errors/payment-failed",
  "title": "Payment Failed",
  "status": 402,
  "detail": "Card ending in 4242 was declined due to insufficient funds.",
  "instance": "/v1/invoices/inv_abc123/pay",
  "error_code": "PAYMENT_FAILED",
  "request_id": "req_xyz789"
}
```

## Sources
- [Stripe Webhook Events for Subscriptions](https://docs.stripe.com/billing/subscriptions/webhooks)
- [Stripe Event Types Reference](https://docs.stripe.com/api/events/types)
- [Stripe Prorations](https://docs.stripe.com/billing/subscriptions/prorations)
- [How Stripe Subscriptions Work](https://docs.stripe.com/billing/subscriptions/overview)

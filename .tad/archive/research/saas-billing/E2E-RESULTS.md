# E2E Stress Test Results — Multi-Tenant SaaS Billing System

**Domain Pack**: web-backend v1.0.0
**Date**: 2026-04-01
**Complexity**: 6 resource domains, 4 roles, Stripe integration, real-time WebSocket

---

## Capability Results Summary

| # | Capability | Status | Key Deliverables | Validation |
|---|-----------|--------|------------------|------------|
| 1 | **api_design** | PASS | OpenAPI 3.1 spec (29 operations, 32 schemas, 7 tags) | Redocly lint: 0 errors, 9 warnings |
| 2 | **database_design** | PASS | Prisma schema (13 models, 7 enums, 20+ indexes) | `npx prisma validate`: valid |
| 3 | **authentication** | PASS | JWT + API Key dual auth, 4-role RBAC matrix, Stripe HMAC | Code + diagram |
| 4 | **business_logic** | PASS | 5 service classes, 3 repository classes, proration formula | Architecture diagram |
| 5 | **api_documentation** | PASS | Full endpoint reference, auth guide, webhook guide, error codes | Markdown doc |
| 6 | **data_seeding** | PASS | Seed covers all 5 subscription statuses, 4 roles, failed payments | faker.seed(42) |
| 7 | **error_handling** | PASS | 22 error codes, payment failure lifecycle, webhook idempotency | State diagram |

---

## Capability 1: API Design

### Deliverables
- `openapi.yaml` — OpenAPI 3.1 spec (1,560 lines)
- `api-research.md` — API design research with Stripe/Chargebee/Lago references
- `diagrams/api-resources.d2` + `.svg` — API resource diagram

### Validation
```
$ npx @redocly/cli lint openapi.yaml
Woohoo! Your API description is valid.
You have 9 warnings.

$ npx @redocly/cli stats openapi.yaml
Operations: 29 | Schemas: 32 | Parameters: 14 | Tags: 7
```

Warnings are non-blocking: missing 4xx on some GET endpoints, example server URLs, license URL format.

### Key Design Decisions
- **Cursor-based pagination** (following Stripe pattern)
- **RFC 7807 Problem Details** for all errors
- **Nested resources**: `/tenants/{id}/subscriptions` + direct access `/subscriptions/{id}`
- **Custom actions as sub-resources**: `/subscriptions/{id}/cancel`, not `/cancelSubscription`
- **WebSocket endpoints**: `/ws/billing-events`, `/ws/usage-alerts`
- **Webhook**: `POST /webhooks/stripe` with HMAC signature verification

---

## Capability 2: Database Design

### Deliverables
- `prisma/schema.prisma` — Prisma schema (13 models, validated)
- `prisma.config.ts` — Prisma v7 configuration
- `db-research.md` — Multi-tenancy analysis with trade-off table
- `diagrams/erd.d2` + `.svg` — ER diagram (81KB SVG)

### Multi-Tenancy Decision
**Chosen: Shared DB + tenant_id column** (not RLS, not schema-per-tenant)

| Factor | Decision Rationale |
|--------|-------------------|
| Prisma compatibility | Prisma doesn't natively support RLS policy management |
| Startup simplicity | Single schema, single migration path |
| Scale ceiling | Supports 10,000+ tenants |
| Leak mitigation | tenant_id enforced at Repository layer (single place) |
| Migration path | Can add RLS later; enterprise customers get dedicated deploy |

### Schema Highlights
- **13 models**: Tenant, User, ApiKey, Plan, PlanFeature, Subscription, SubscriptionItem, Invoice, InvoiceLineItem, Payment, UsageRecord, WebhookEvent, AuditLog
- **7 enums**: UserRole, SubscriptionStatus, InvoiceStatus, PaymentStatus, InvoiceLineItemType, WebhookEventStatus, AuditAction
- **Optimistic locking**: `version` field on Subscription
- **Soft deletes**: `deletedAt` on Tenant, User
- **Idempotency keys**: `transactionId` (unique) on UsageRecord, `stripeEventId` (unique) on WebhookEvent
- **Audit trail**: `before`/`after` JSON columns on AuditLog

---

## Capability 3: Authentication

### Deliverables
- `auth-research.md` — Auth design with RBAC matrix (25 permission combinations)
- `auth-middleware.ts` — TypeScript middleware (JWT verify, API key lookup, Stripe HMAC, role/tenant enforcement)
- `diagrams/auth-flow.d2` + `.svg` — Auth flow diagram

### RBAC Matrix Coverage
- 4 roles x 6+ resources x CRUD = 25 unique permission entries
- Distinguishes: ALL (platform-wide), OWN (own tenant), SELF (own record)
- SuperAdmin bypasses all permission checks
- API Key auth maps to BillingAdmin-level access [ASSUMPTION]

### Security Measures
- JWT: 15min access token, 7-day refresh with rotation
- API Key: SHA-256 hashed storage, prefix identification (`sk_live_`)
- Stripe: HMAC-SHA256 verification, 300s timestamp tolerance
- OWASP: Generic "Invalid credentials" message (no user enumeration)

---

## Capability 4: Business Logic

### Deliverables
- `src/services/SubscriptionService.ts` — Subscription lifecycle (create, cancel, reactivate, change plan with proration)
- `src/services/UsageService.ts` — Usage tracking, limit checks, overage alerts
- `src/services/WebhookService.ts` — Stripe event processing with idempotency
- `src/services/PaymentRetryService.ts` — Exponential backoff retry (1h, 4h, 24h, 72h)
- `src/repositories/SubscriptionRepository.ts` — Data access with optimistic locking
- `src/repositories/UsageRecordRepository.ts` — Usage aggregation queries
- `src/repositories/WebhookEventRepository.ts` — Webhook idempotency storage
- `diagrams/architecture.d2` + `.svg` — Service architecture diagram
- `diagrams/subscription-state-machine.d2` + `.svg` — State machine diagram

### Proration Formula
```
remaining_fraction = remaining_days / total_days_in_period
credit = old_price x remaining_fraction
charge = new_price x remaining_fraction
net = charge - credit  (positive = pay more, negative = credit)
```
- Integer arithmetic (cents) to avoid floating-point precision issues
- Edge cases handled: same-day change, last-day change, free-to-paid

### Subscription State Machine
```
TRIALING --[payment succeeds]--> ACTIVE
TRIALING --[trial ends, no payment]--> EXPIRED
ACTIVE --[payment fails]--> PAST_DUE
ACTIVE --[user cancels]--> CANCELED
PAST_DUE --[retry succeeds]--> ACTIVE
PAST_DUE --[max retries (4)]--> CANCELED
CANCELED --[resubscribe within 7d grace]--> ACTIVE
CANCELED --[grace period ends]--> EXPIRED
```

### Concurrent Upgrade Protection
- Optimistic locking via `version` field on Subscription
- `changePlan` requires `version` in request body
- `WHERE id = X AND version = Y` — returns null on version mismatch
- Client receives `409 CONCURRENT_MODIFICATION` with expected vs actual version

---

## Capability 5: API Documentation

### Deliverables
- `api-documentation.md` — Complete API reference with examples
- Covers: Authentication guide (JWT + API Key), endpoint reference (all 29 operations), subscription lifecycle example, webhook integration guide, WebSocket events, billing-specific error codes

---

## Capability 6: Data Seeding

### Deliverables
- `prisma/seed.ts` — Deterministic seed script (faker.seed(42))

### Coverage Matrix

| Entity | Count | Coverage |
|--------|-------|---------|
| Plans | 4 | Free, Pro, Enterprise, Archived |
| Tenants | 6 | 5 active, 1 soft-deleted |
| Users | 9 | SuperAdmin, TenantAdmin, BillingAdmin, Member, soft-deleted |
| API Keys | 3 | Active, expiring, revoked |
| Subscriptions | 5 | TRIALING, ACTIVE, PAST_DUE, CANCELED, EXPIRED |
| Invoices | 4 | PAID, OPEN, OPEN (failed), UNCOLLECTIBLE |
| Payments | 8 | 1 SUCCEEDED, 7 FAILED (retry history) |
| Usage Records | ~27 | Near-limit (85%), heavy, minimal |
| Webhook Events | 3 | PROCESSED, PROCESSED, RECEIVED |
| Audit Logs | 3 | CREATE, STATUS_CHANGE x2 |

---

## Capability 7: Error Handling

### Deliverables
- `src/errors/AppError.ts` — RFC 7807 error class with factory methods (22 error types including 8 billing-specific)
- `src/errors/errorMiddleware.ts` — Global error handler (Prisma mapping, Zod mapping, Stripe mapping)
- `error-design.md` — Error catalog, payment failure lifecycle, webhook idempotency, logging strategy
- `diagrams/payment-failure-flow.d2` + `.svg` — Payment failure state diagram

### Payment Failure Lifecycle (Complete)
1. Stripe sends `invoice.payment_failed` → log webhook event
2. Update subscription to `PAST_DUE`
3. Notify TenantAdmin + BillingAdmin (email + WebSocket)
4. Schedule retry: 1h → 4h → 24h → 72h (exponential backoff)
5. Max retries exceeded (4) → cancel subscription
6. 7-day grace period → final notice
7. Grace period ends → `EXPIRED`, data access revoked

### Webhook Idempotency
- `WebhookEvent.stripeEventId` unique index for dedup
- Check before processing → skip if PROCESSED/PROCESSING
- Always return 200 to Stripe (even on processing error)
- Retention: 90 days for processed events (cron cleanup)

---

## Diagram Inventory

| Diagram | File | Size | Description |
|---------|------|------|-------------|
| ER Diagram | `diagrams/erd.svg` | 81KB | All 13 models with relationships |
| API Resources | `diagrams/api-resources.svg` | 49KB | Endpoint grouping and nesting |
| Architecture | `diagrams/architecture.svg` | 57KB | Service layer architecture |
| Auth Flow | `diagrams/auth-flow.svg` | 50KB | JWT + API Key + Webhook auth |
| State Machine | `diagrams/subscription-state-machine.svg` | 27KB | Subscription lifecycle states |
| Payment Failure | `diagrams/payment-failure-flow.svg` | 42KB | Complete payment failure chain |

---

## Assumptions Log

| ID | Assumption | Impact |
|----|-----------|--------|
| A1 | PostgreSQL as primary database | Schema design, index strategy |
| A2 | SMB-focused (100-10K tenants) | Shared DB choice over schema-per-tenant |
| A3 | 30-day billing cycles | Period calculation in proration |
| A4 | BullMQ/Redis for job queue | Payment retry scheduling |
| A5 | API keys have BillingAdmin-level access | Permission mapping |
| A6 | Stripe SDK for webhook verification | Not manual HMAC implementation |
| A7 | Enterprise customers get dedicated deploy | Not schema-per-tenant |

---

## File Inventory (28 files)

```
.tad/active/research/saas-billing/
├── E2E-RESULTS.md                          # This file
├── api-research.md                         # Cap 1: API research
├── openapi.yaml                            # Cap 1: OpenAPI 3.1 spec (validated)
├── api-lint-report.txt                     # Cap 1: Redocly lint output
├── api-documentation.md                    # Cap 5: API documentation
├── db-research.md                          # Cap 2: DB research + multi-tenancy analysis
├── prisma/schema.prisma                    # Cap 2: Prisma schema (validated)
├── prisma.config.ts                        # Cap 2: Prisma v7 config
├── prisma/seed.ts                          # Cap 6: Seed data script
├── auth-research.md                        # Cap 3: Auth research + RBAC matrix
├── auth-middleware.ts                       # Cap 3: Auth middleware code
├── error-design.md                         # Cap 7: Error catalog + payment lifecycle
├── src/services/SubscriptionService.ts     # Cap 4: Subscription business logic
├── src/services/UsageService.ts            # Cap 4: Usage tracking + alerts
├── src/services/WebhookService.ts          # Cap 4: Stripe webhook processing
├── src/services/PaymentRetryService.ts     # Cap 4: Payment retry with backoff
├── src/repositories/SubscriptionRepository.ts  # Cap 4: Data access (optimistic lock)
├── src/repositories/UsageRecordRepository.ts   # Cap 4: Usage aggregation
├── src/repositories/WebhookEventRepository.ts  # Cap 4: Webhook idempotency
├── src/validators/subscription.validators.ts   # Cap 4: Zod validation schemas
├── src/errors/AppError.ts                  # Cap 7: RFC 7807 error class
├── src/errors/errorMiddleware.ts           # Cap 7: Global error handler
├── diagrams/erd.d2 + .svg                  # Cap 2: ER diagram
├── diagrams/api-resources.d2 + .svg        # Cap 1: API resource diagram
├── diagrams/architecture.d2 + .svg         # Cap 4: Architecture diagram
├── diagrams/auth-flow.d2 + .svg            # Cap 3: Auth flow diagram
├── diagrams/subscription-state-machine.d2 + .svg  # Cap 4: State machine
└── diagrams/payment-failure-flow.d2 + .svg # Cap 7: Payment failure flow
```

## Validation Results

| Tool | Command | Result |
|------|---------|--------|
| Prisma | `npx prisma validate` | "The schema is valid" |
| Redocly | `npx @redocly/cli lint openapi.yaml` | 0 errors, 9 warnings |
| D2 | 6 diagrams compiled | All 6 SVGs generated successfully |

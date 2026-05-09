# Database Design Research — Multi-Tenant SaaS Billing

## 1. Multi-Tenancy Strategy Analysis

### Trade-off Table

| Criteria | Shared DB + tenant_id | PostgreSQL RLS | Schema-per-tenant | DB-per-tenant |
|----------|----------------------|----------------|-------------------|---------------|
| **Isolation Level** | Low (app-level) | Medium (DB-enforced) | High | Highest |
| **Query Complexity** | Low (add WHERE) | Low (transparent via policy) | Medium (schema switching) | High (connection routing) |
| **Migration Complexity** | Low (one schema) | Low (one schema + policies) | High (N schemas) | Highest (N databases) |
| **Cost** | Lowest | Low | Medium | Highest |
| **Performance** | Good (shared indexes) | Good (small policy overhead ~2-5%) | Good (schema-level isolation) | Variable |
| **Max Tenants** | 10,000+ | 10,000+ | ~1,000 | ~100 |
| **Cross-tenant Queries** | Easy | Easy | Complex (UNION) | Very complex |
| **Compliance (SOC2)** | Requires app-level audit | Better (DB-level enforcement) | Good | Best |
| **Accidental Data Leak Risk** | High (forgotten WHERE) | Low (policy enforced) | Very low | Minimal |
| **ORM Compatibility** | Excellent (Prisma native) | Good (requires raw SQL for policy setup) | Limited (schema switching hacks) | Poor (connection pool per tenant) |

### Decision: Shared DB + tenant_id Column with Application-Level Filtering

**Justification:**
1. **Prisma ORM compatibility**: Prisma does not natively support PostgreSQL RLS policies. Using RLS would require raw SQL for policy management and risk bypassing RLS in Prisma-generated queries that use the connection owner role.
2. **Startup simplicity**: For an MVP/growing SaaS, operational simplicity > perfect isolation. Schema-per-tenant and DB-per-tenant add migration complexity that doesn't pay off until hundreds of enterprise customers demand it.
3. **Migration path**: Start with tenant_id → add RLS policies later as compliance requirements grow → move enterprise customers to schema-per-tenant if needed.
4. **Mitigation for leak risk**: Enforce tenant_id filtering at the Repository layer (single place) rather than at every query site. All repository methods accept `tenantId` as required parameter.

**[ASSUMPTION]**: The SaaS platform serves primarily SMB customers (100-10,000 tenants). Enterprise customers requiring dedicated infrastructure would be handled via a separate deployment, not schema-per-tenant.

Sources:
- [AWS: Multi-tenant data isolation with PostgreSQL RLS](https://aws.amazon.com/blogs/database/multi-tenant-data-isolation-with-postgresql-row-level-security/)
- [Nile: Shipping multi-tenant SaaS using Postgres RLS](https://www.thenile.dev/blog/multi-tenant-rls)
- [Simplyblock: Row-Level Security for Multi-Tenant Applications](https://www.simplyblock.io/blog/underated-postgres-multi-tenancy-with-row-level-security/)

## 2. Entity Analysis

### 12 Models with Field Specifications

| Model | Primary Key | Tenant-scoped | Soft Delete | Optimistic Lock | Key Fields |
|-------|-------------|---------------|-------------|-----------------|------------|
| Tenant | cuid | No | Yes (deletedAt) | No | name, slug (unique), billingEmail, stripeCustomerId |
| User | cuid | Yes (tenantId) | Yes (deletedAt) | No | email (unique per tenant), name, role, passwordHash |
| ApiKey | cuid | Yes (tenantId) | No (revokedAt) | No | keyHash (SHA-256), name, expiresAt |
| Plan | cuid | No | No (isActive flag) | No | name, slug, priceMonthly (cents), trialDays, stripePriceId |
| PlanFeature | cuid | No | No | No | name, limit (-1=unlimited), unit, overagePrice |
| Subscription | cuid | Yes (tenantId) | No | **Yes (version)** | status, periodStart/End, stripeSubscriptionId, gracePeriodEnd |
| SubscriptionItem | cuid | Indirect | No | No | quantity (for seat-based) |
| Invoice | cuid | Yes (tenantId) | No | No | status, amountDue (cents), dueDate, stripeInvoiceId |
| InvoiceLineItem | cuid | Indirect | No | No | description, quantity, unitPrice, amount, type |
| Payment | cuid | Indirect | No | No | status, amount, failureCode, attemptNumber |
| UsageRecord | cuid | Yes (tenantId) | No | No | featureName, quantity, transactionId (idempotency) |
| WebhookEvent | cuid | No | No | No | stripeEventId (dedup), eventType, payload (JSON), status |
| AuditLog | cuid | Yes (tenantId) | No | No | action, entityType, entityId, before/after (JSON) |

### Index Strategy

**Composite indexes for common query patterns:**
- `UsageRecord(tenantId, featureName, timestamp)` — usage aggregation queries
- `UsageRecord(subscriptionId, featureName, timestamp)` — per-subscription usage
- `AuditLog(tenantId, createdAt)` — tenant audit trail
- `AuditLog(entityType, entityId)` — entity change history
- `Invoice(tenantId)`, `Invoice(subscriptionId)` — invoice lookups
- `Subscription(tenantId)`, `Subscription(status)` — subscription queries
- `WebhookEvent(stripeEventId)` — idempotency check (unique index)
- `WebhookEvent(createdAt)` — cleanup of old events

### Normalization Assessment
- All models are in 3NF
- **Deliberate denormalization**: `Invoice.tenantId` duplicates the tenant relationship available via `Subscription.tenantId`. Justified: avoids JOIN through Subscription for every tenant invoice query (high frequency query).

## 3. Horizontal Concerns

### Audit Trail Design
- `AuditLog.before` / `AuditLog.after` store JSON snapshots of entity state
- Captures: who (userId), what (action + entityType + entityId), when (createdAt), where (ipAddress), context (before/after diff)
- Immutable: AuditLog has no `updatedAt` — records are write-once

### Soft Delete Pattern
- Only on Tenant and User (business requirement: data retention for compliance)
- `deletedAt: DateTime?` — null means active, non-null means deleted
- All queries must filter `WHERE deletedAt IS NULL` (enforced in Repository layer)
- Index on `deletedAt` for efficient filtering

### Optimistic Locking
- Only on Subscription (highest contention: concurrent plan changes)
- `version: Int @default(1)` — incremented on every update
- Update query: `WHERE id = X AND version = Y` — if 0 rows affected, throw CONCURRENT_MODIFICATION

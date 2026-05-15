# Database Rules

Six judgment rules for database design, identifier strategy, testing, aggregate
access, transaction management, and delete semantics.

---

**Rule 1: Never use in-memory databases for integration or E2E tests**

In-memory databases (H2, SQLite in-memory mode) have different behavior from
production databases: different SQL dialects, missing index types, no row-level
locking semantics, different NULL handling, and different constraint enforcement.
Tests that pass against in-memory databases regularly fail against PostgreSQL or MySQL.

```yaml
# WRONG: test configuration uses H2
spring:
  datasource:
    url: jdbc:h2:mem:testdb

# RIGHT: use the real database in a container
services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_PASSWORD: test
```

```typescript
// Use Testcontainers for integration tests
const container = await new PostgreSqlContainer('postgres:16-alpine').start();
const db = knex({ client: 'pg', connection: container.getConnectionUri() });
```

If a container is not available in CI: use a dedicated test schema on a shared
test database instance. In-memory is never the right tradeoff.

[Source: Sairyss/backend-best-practices — Testing; Testcontainers documentation]

---

**Rule 2: Choose identifiers appropriate to context**

Identifier choice has security, performance, and operational implications:

- If distributed system or records exposed via public API: use **UUIDv7 or ULID**.
  They are time-ordered (index-friendly) and globally unique. Note: they embed a
  millisecond-precision timestamp — use UUIDv4 when creation timing must be hidden
  (e.g., security tokens). They do not expose record count.
- If internal single-database table with high write volume and IDs are never
  exposed externally: **auto-incrementing integers** are acceptable for insert
  performance (clustered index inserts, no page splits).
- If public-facing API: **never expose auto-incrementing IDs**. A client who
  knows order #1047 can infer you have ~1000 orders. Use UUIDv7/ULID externally
  even if you use auto-increment internally (map in the application layer).

```sql
-- UUIDv7 in PostgreSQL (pg_uuidv7 extension or application-generated)
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
  ...
);

-- ULID as text (application-generated)
CREATE TABLE events (
  id VARCHAR(26) PRIMARY KEY,  -- ULID stored as text
  ...
);
```

```typescript
// If Node.js: use 'ulidx' or 'uuid' v7
import { ulid } from 'ulidx';
const id = ulid();  // '01ARZ3NDEKTSV4RRFFQ69G5FAV'
```

[Source: Sairyss/backend-best-practices — Identifiers; IETF UUID RFC 9562]

---

**Rule 3: Set external dependency timeouts to p99 latency plus a small buffer**

Never use the default timeout of a database driver, HTTP client, or queue consumer.
Defaults are typically infinite or very long (30–60s). Under load, slow calls pile up,
exhaust thread pools, and cascade into full service outages.

Formula: `timeout = max(p99 × 2, p99.9 + 100ms)`

Avoid `p99 + 50ms` — this is too aggressive during tail-latency spikes and will
reject legitimate traffic at 99th percentile under load (Google SRE Book Chapter 22
recommends 2× p99 as the canonical baseline).

```typescript
// If Node.js: pg pool timeout
const pool = new Pool({
  connectionTimeoutMillis: 5000,  // p99 = 100ms → set to 150ms; but connection timeout
  idleTimeoutMillis: 10000,       // release idle connections
  statement_timeout: 2000,        // individual query timeout
});

// HTTP client timeout
const response = await fetch(url, {
  signal: AbortSignal.timeout(500),  // p99 = 400ms → set to 450ms
});
```

```python
# If Python: requests timeout
response = requests.get(url, timeout=(3.0, 10.0))  # (connect_timeout, read_timeout)
```

```go
// If Go: http.Client timeout
client := &http.Client{Timeout: 450 * time.Millisecond}
```

If you don't know your p99: start with 1s for DB queries, 500ms for internal HTTP,
5s for external HTTP. Measure and tighten.

[Source: Sairyss/backend-best-practices — Resilience Patterns]

---

**Rule 4: Only Aggregate Roots can be queried directly**

In DDD, an aggregate is a cluster of domain objects treated as a unit. The Aggregate
Root is the only public entry point. Querying child entities (e.g., `OrderLine`) by
ID directly bypasses invariant protection and makes the aggregate boundary meaningless.

```typescript
// WRONG: querying a child entity directly
const line = await orderLineRepository.findById(lineId);

// RIGHT: access through the Aggregate Root
const order = await orderRepository.findById(orderId);
const line = order.getLine(lineId);
```

Exception: CQRS read-side query handlers can bypass this rule (see Rule 4 in
`references/application-logic.md`). The restriction applies to write paths only.

[Source: Sairyss/domain-driven-hexagon — Aggregates and Repositories]

---

**Rule 5: Do not force transactions across aggregate boundaries**

Transactions that span multiple aggregates create distributed locking, reduce
throughput, and couple the lifecycle of independent business concepts. When two
aggregates must stay consistent:

- Use the **Saga pattern**: a sequence of local transactions coordinated by events,
  with compensating transactions on failure
- Use the **Outbox pattern**: write the event to a database table in the same local
  transaction as the aggregate change; a background process publishes the event

```sql
-- Outbox pattern: same transaction, no distributed lock
BEGIN;
UPDATE orders SET status = 'confirmed' WHERE id = $1;
INSERT INTO outbox_events (aggregate_id, event_type, payload)
  VALUES ($1, 'OrderConfirmed', $2);
COMMIT;
-- A separate process reads outbox_events and publishes to message queue
```

[Source: Sairyss/domain-driven-hexagon — Sagas and Outbox Pattern]

---

**Rule 6: Match delete strategy to the business requirement**

Delete semantics have compliance, audit, and recovery implications. Choose explicitly:

- If audit trail or recovery is needed (orders, financial records, user-generated
  content): use **soft delete** — add a `deleted_at TIMESTAMPTZ` column, set it
  instead of deleting the row
- If record contains PII and subject to GDPR/regulatory erasure rights: use
  **hard delete** — the record must be physically removed, not merely hidden
- If soft-deleting: add a **partial index** on `deleted_at IS NULL` to keep active
  record queries fast; add a **retention policy** so soft-deleted rows are purged
  after the required retention period

```sql
-- Soft delete: add column
ALTER TABLE orders ADD COLUMN deleted_at TIMESTAMPTZ;

-- Partial index for active records
CREATE INDEX idx_orders_active ON orders (id) WHERE deleted_at IS NULL;

-- Query: always filter
SELECT * FROM orders WHERE deleted_at IS NULL AND user_id = $1;
```

```sql
-- Hard delete for PII (GDPR right to erasure)
DELETE FROM user_profiles WHERE user_id = $1;  -- permanent removal
DELETE FROM user_payment_methods WHERE user_id = $1;
```

Choosing soft-delete "by default" without a retention policy creates unbounded
table growth. Document the retention period at the time you add the column.

[Source: Sairyss/backend-best-practices — Soft Delete Patterns; GDPR Article 17]

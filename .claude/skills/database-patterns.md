# Database Patterns Skill

---
title: "Database Patterns"
version: "3.0"
last_updated: "2026-01-06"
tags: [database, sql, schema, optimization, migration, multi-tenant, engineering]
domains: [backend, data]
level: intermediate
estimated_time: "45min"
prerequisites: []
sources:
  - "SQL Antipatterns - Bill Karwin"
  - "Database Design for Mere Mortals"
  - "PostgreSQL Documentation"
  - "pt-online-schema-change - Percona"
  - "gh-ost - GitHub"
enforcement: recommended
tad_gates: [Gate2_Design]
---

## TL;DR Quick Checklist

```
1. [ ] Primary key defined for every table
2. [ ] Foreign keys with proper constraints (CASCADE/RESTRICT)
3. [ ] Indexes on WHERE, JOIN, and ORDER BY columns
4. [ ] Appropriate normalization level (usually 3NF)
5. [ ] EXPLAIN ANALYZE for complex queries
```

**Red Flags:**
- SELECT * in production code
- Missing indexes on foreign keys
- N+1 query patterns
- No pagination for list queries
- Storing arrays in single columns (1NF violation)

---

## Overview

This skill guides database schema design, query optimization, and data patterns.

**Core Principle:** "Data models are the skeleton of your application. Design mistakes cost exponentially more to fix over time."

---

## Triggers

| Trigger | Context | Action |
|---------|---------|--------|
| Schema design | Alex planning data model | Apply design patterns |
| Query performance | Slow queries identified | Optimize with indexes/rewrites |
| Data migration | Schema changes needed | Plan zero-downtime migration |
| Code review | Database code changes | Validate patterns |

---

## Inputs

- Data requirements
- Relationship cardinality
- Query patterns (read/write ratio)
- Scale expectations
- Consistency requirements

---

## Outputs / Evidence / Acceptance

### Required Evidence

| Evidence Type | Description | Location |
|---------------|-------------|----------|
| `schema_diagram` | ERD or table definitions | `.tad/docs/` |
| `index_strategy` | Index definitions with justification | Migration files |
| `query_analysis` | EXPLAIN output for key queries | `.tad/evidence/` |

### Acceptance Criteria

```
[ ] Schema follows normalization rules
[ ] All foreign keys have indexes
[ ] Key queries have EXPLAIN analysis
[ ] Migration scripts include rollback
[ ] No N+1 patterns in code
```

---

## Procedure

### Step 1: Apply Normalization

**Normal Forms:**
```
1NF: Atomic values, no repeating groups
├── Each column contains single value
└── No arrays stored in columns

2NF: 1NF + No partial dependencies
├── Non-key columns depend on full primary key
└── Split tables if partial dependencies exist

3NF: 2NF + No transitive dependencies
├── Non-key columns don't depend on other non-key columns
└── Most applications should target 3NF
```

**When to Denormalize:**
```
✅ Denormalize when:
□ Read performance critical
□ Joins are expensive
□ Data rarely changes
□ Reporting/analytics queries

❌ Stay normalized when:
□ Data integrity is critical
□ Write-heavy workload
□ Data changes frequently
```

### Step 2: Design Relationships

#### One-to-Many

```sql
-- User has many orders
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  total DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Always index foreign keys
CREATE INDEX idx_orders_user_id ON orders(user_id);
```

#### Many-to-Many

```sql
-- Users and roles (many-to-many)
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

CREATE TABLE roles (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) UNIQUE NOT NULL
);

-- Junction table with composite primary key
CREATE TABLE user_roles (
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  role_id INTEGER REFERENCES roles(id) ON DELETE CASCADE,
  assigned_at TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY (user_id, role_id)
);
```

#### Self-Referencing (Hierarchy)

```sql
-- Employee hierarchy
CREATE TABLE employees (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  manager_id INTEGER REFERENCES employees(id),
  level INTEGER DEFAULT 0
);

-- Recursive CTE for tree traversal
WITH RECURSIVE subordinates AS (
  SELECT id, name, manager_id, 1 AS depth
  FROM employees WHERE manager_id = 1

  UNION ALL

  SELECT e.id, e.name, e.manager_id, s.depth + 1
  FROM employees e
  JOIN subordinates s ON e.manager_id = s.id
)
SELECT * FROM subordinates;
```

### Step 3: Apply Common Patterns

#### Soft Delete

```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL,
  deleted_at TIMESTAMP NULL,  -- NULL = active

  -- Unique only among non-deleted
  CONSTRAINT unique_email_active
    UNIQUE (email) WHERE deleted_at IS NULL
);

-- View for active records
CREATE VIEW active_users AS
SELECT * FROM users WHERE deleted_at IS NULL;
```

#### Audit Trail

```sql
CREATE TABLE audit_log (
  id SERIAL PRIMARY KEY,
  table_name VARCHAR(100) NOT NULL,
  record_id INTEGER NOT NULL,
  action VARCHAR(10) NOT NULL,  -- INSERT, UPDATE, DELETE
  old_data JSONB,
  new_data JSONB,
  changed_by INTEGER,
  changed_at TIMESTAMP DEFAULT NOW()
);

-- Trigger function
CREATE OR REPLACE FUNCTION audit_trigger()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO audit_log (table_name, record_id, action, old_data, new_data)
  VALUES (TG_TABLE_NAME, COALESCE(NEW.id, OLD.id), TG_OP,
          to_jsonb(OLD), to_jsonb(NEW));
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;
```

#### Polymorphic Association

```sql
-- Option 1: Type column (simple but no FK constraint)
CREATE TABLE comments (
  id SERIAL PRIMARY KEY,
  content TEXT NOT NULL,
  commentable_type VARCHAR(50) NOT NULL,  -- 'Article', 'Video'
  commentable_id INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_comments_poly
ON comments(commentable_type, commentable_id);

-- Option 2: Separate tables (better integrity)
CREATE TABLE article_comments (
  id SERIAL PRIMARY KEY,
  article_id INTEGER REFERENCES articles(id) ON DELETE CASCADE,
  content TEXT NOT NULL
);

CREATE TABLE video_comments (
  id SERIAL PRIMARY KEY,
  video_id INTEGER REFERENCES videos(id) ON DELETE CASCADE,
  content TEXT NOT NULL
);
```

### Step 4: Optimize with Indexes

**Index Types:**
```sql
-- B-Tree (default, most common)
CREATE INDEX idx_users_email ON users(email);

-- Composite index (column order matters!)
CREATE INDEX idx_orders_user_status
ON orders(user_id, status);  -- Leftmost prefix rule

-- Partial index (filtered)
CREATE INDEX idx_active_orders
ON orders(created_at) WHERE status = 'active';

-- GIN (for JSONB, arrays)
CREATE INDEX idx_users_metadata ON users USING gin(metadata);

-- GiST (for geometry, full-text)
CREATE INDEX idx_locations_geo ON locations USING gist(coordinates);
```

**When to Create Indexes:**
```
✅ Should index:
□ WHERE clause columns (frequently queried)
□ JOIN columns
□ ORDER BY columns
□ Foreign keys

❌ Avoid indexing:
□ Low selectivity columns (gender, boolean)
□ Frequently updated columns
□ Small tables (< 1000 rows)
□ Columns rarely used in queries
```

### Step 5: Write Efficient Queries

```sql
-- ❌ Bad: SELECT *
SELECT * FROM users;

-- ✅ Good: Select needed columns
SELECT id, name, email FROM users;

-- ❌ Bad: Function in WHERE (prevents index use)
SELECT * FROM orders WHERE YEAR(created_at) = 2024;

-- ✅ Good: Range query (uses index)
SELECT * FROM orders
WHERE created_at >= '2024-01-01'
  AND created_at < '2025-01-01';

-- ❌ Bad: N+1 queries
-- Python pseudocode:
-- for user in users:
--     orders = query("SELECT * FROM orders WHERE user_id = ?", user.id)

-- ✅ Good: Batch query
SELECT * FROM orders WHERE user_id = ANY(ARRAY[1, 2, 3, 4, 5]);

-- ✅ Good: Pagination
SELECT * FROM logs
WHERE level = 'error'
ORDER BY created_at DESC
LIMIT 100 OFFSET 0;
```

### Step 6: Plan Zero-Downtime Migrations

**Strategy Selection Matrix:**
```
┌─────────────────────────────────────────────────────────────────────┐
│                    Zero-Downtime Migration Strategies               │
├─────────────────┬───────────────────┬───────────────────────────────┤
│ Strategy        │ Best For          │ Trade-offs                    │
├─────────────────┼───────────────────┼───────────────────────────────┤
│ Expand-Contract │ Column add/rename │ Simple, multi-deploy          │
│ Shadow Table    │ Large schema      │ Complex, space overhead       │
│ pt-osc/gh-ost   │ MySQL big tables  │ Automated, trigger-based      │
│ Blue-Green DB   │ Major rewrites    │ Full duplication cost         │
│ Online Index    │ Index creation    │ CONCURRENTLY (PostgreSQL)     │
└─────────────────┴───────────────────┴───────────────────────────────┘
```

#### Strategy 1: Expand-Contract Pattern

```
Phase 1: EXPAND (Add new, keep old)
┌─────────────────────────────────────────────────────────────┐
│  ALTER TABLE users ADD COLUMN email_new VARCHAR(255);       │
│  -- Deploy code: write to BOTH old and new columns          │
└─────────────────────────────────────────────────────────────┘
                              ↓
Phase 2: MIGRATE (Backfill data)
┌─────────────────────────────────────────────────────────────┐
│  -- Batch update to avoid table lock                        │
│  UPDATE users SET email_new = email                         │
│  WHERE id BETWEEN ? AND ? AND email_new IS NULL;            │
└─────────────────────────────────────────────────────────────┘
                              ↓
Phase 3: CONTRACT (Remove old)
┌─────────────────────────────────────────────────────────────┐
│  -- Deploy code: read from new only                         │
│  ALTER TABLE users DROP COLUMN email;                       │
│  ALTER TABLE users RENAME COLUMN email_new TO email;        │
└─────────────────────────────────────────────────────────────┘
```

#### Strategy 2: Shadow Table Pattern (Large Tables)

```sql
-- Step 1: Create shadow table with new schema
CREATE TABLE users_new (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) NOT NULL,
  full_name VARCHAR(200) NOT NULL,  -- NEW: was split first_name/last_name
  created_at TIMESTAMP DEFAULT NOW()
);

-- Step 2: Create trigger to sync inserts/updates
CREATE OR REPLACE FUNCTION sync_to_users_new()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO users_new (id, email, full_name, created_at)
  VALUES (NEW.id, NEW.email, CONCAT(NEW.first_name, ' ', NEW.last_name), NEW.created_at)
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = EXCLUDED.full_name;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_sync_users
AFTER INSERT OR UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION sync_to_users_new();

-- Step 3: Backfill existing data (in batches)
INSERT INTO users_new (id, email, full_name, created_at)
SELECT id, email, CONCAT(first_name, ' ', last_name), created_at
FROM users
WHERE id NOT IN (SELECT id FROM users_new)
ON CONFLICT (id) DO NOTHING;

-- Step 4: Atomic swap (during low traffic)
BEGIN;
  ALTER TABLE users RENAME TO users_old;
  ALTER TABLE users_new RENAME TO users;
  DROP TRIGGER IF EXISTS trigger_sync_users ON users_old;
COMMIT;

-- Step 5: Cleanup (after verification)
DROP TABLE users_old;
```

#### Strategy 3: Using gh-ost (MySQL)

```bash
# gh-ost: GitHub's online schema change tool
gh-ost \
  --user="root" \
  --password="***" \
  --host="db.example.com" \
  --database="myapp" \
  --table="users" \
  --alter="ADD COLUMN avatar_url VARCHAR(500)" \
  --execute \
  --assume-rbr \
  --chunk-size=1000 \
  --max-load="Threads_running=25"

# Key features:
# - No triggers (uses binlog replication)
# - Pausable/resumable
# - Can test before execute (--test-on-replica)
```

#### Strategy 4: PostgreSQL Concurrent Index

```sql
-- ❌ BAD: Locks table during index creation
CREATE INDEX idx_orders_user_id ON orders(user_id);

-- ✅ GOOD: Non-blocking (PostgreSQL)
CREATE INDEX CONCURRENTLY idx_orders_user_id ON orders(user_id);

-- Note: CONCURRENTLY takes longer but doesn't block writes
-- If interrupted, run:
DROP INDEX CONCURRENTLY IF EXISTS idx_orders_user_id;
-- Then retry
```

**Migration Script Template:**
```sql
-- migrations/20260106_001_add_avatar.sql

-- UP
ALTER TABLE users ADD COLUMN avatar_url VARCHAR(500);
CREATE INDEX CONCURRENTLY idx_users_avatar ON users(avatar_url)
WHERE avatar_url IS NOT NULL;

-- DOWN
DROP INDEX CONCURRENTLY IF EXISTS idx_users_avatar;
ALTER TABLE users DROP COLUMN avatar_url;
```

**Backfill Script Template:**
```python
# backfill_in_batches.py
import time

BATCH_SIZE = 1000
SLEEP_SECONDS = 0.1  # Avoid overwhelming DB

def backfill_avatar_urls():
    last_id = 0
    while True:
        result = db.execute("""
            UPDATE users
            SET avatar_url = CONCAT('/avatars/', id, '.png')
            WHERE id > %s AND id <= %s AND avatar_url IS NULL
            RETURNING id
        """, (last_id, last_id + BATCH_SIZE))

        updated = result.rowcount
        if updated == 0:
            break

        last_id += BATCH_SIZE
        print(f"Updated {updated} rows, last_id={last_id}")
        time.sleep(SLEEP_SECONDS)
```

### Step 7: Operational Governance

#### Slow Query Log Configuration

**PostgreSQL:**
```sql
-- postgresql.conf settings
log_min_duration_statement = 1000  -- Log queries > 1 second
log_statement = 'none'              -- Avoid logging all queries
log_lock_waits = on                 -- Log waits > deadlock_timeout
log_temp_files = 0                  -- Log all temp file usage

-- Query slow query log
SELECT
  calls,
  mean_time::numeric(10,2) AS avg_ms,
  total_time::numeric(10,2) AS total_ms,
  rows,
  query
FROM pg_stat_statements
WHERE mean_time > 1000  -- > 1 second average
ORDER BY total_time DESC
LIMIT 20;
```

**MySQL:**
```sql
-- my.cnf settings
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 1  -- Threshold in seconds
log_queries_not_using_indexes = 1

-- Query from performance_schema
SELECT
  DIGEST_TEXT AS query,
  COUNT_STAR AS calls,
  AVG_TIMER_WAIT/1000000000 AS avg_ms,
  SUM_ROWS_EXAMINED AS rows_examined
FROM performance_schema.events_statements_summary_by_digest
WHERE AVG_TIMER_WAIT > 1000000000  -- > 1 second
ORDER BY SUM_TIMER_WAIT DESC
LIMIT 20;
```

#### Index Health Dashboard

```sql
-- PostgreSQL: Index Usage Statistics
CREATE OR REPLACE VIEW v_index_health AS
SELECT
  schemaname,
  relname AS table_name,
  indexrelname AS index_name,
  idx_scan AS times_used,
  idx_tup_read AS rows_read,
  idx_tup_fetch AS rows_fetched,
  pg_size_pretty(pg_relation_size(indexrelid)) AS index_size,
  CASE
    WHEN idx_scan = 0 THEN 'UNUSED - Consider dropping'
    WHEN idx_scan < 100 THEN 'LOW USAGE - Review'
    ELSE 'HEALTHY'
  END AS status
FROM pg_stat_user_indexes
ORDER BY idx_scan ASC;

-- Find duplicate indexes
SELECT
  a.indexrelid::regclass AS index1,
  b.indexrelid::regclass AS index2,
  a.indrelid::regclass AS table_name
FROM pg_index a
JOIN pg_index b ON a.indrelid = b.indrelid
  AND a.indexrelid < b.indexrelid
  AND a.indkey = b.indkey;

-- Index bloat estimation
SELECT
  schemaname || '.' || relname AS table,
  indexrelname AS index,
  pg_size_pretty(pg_relation_size(indexrelid)) AS index_size,
  ROUND(100 * pg_relation_size(indexrelid) /
        NULLIF(pg_relation_size(indrelid), 0)) AS index_ratio_pct
FROM pg_stat_user_indexes
JOIN pg_index USING (indexrelid)
WHERE pg_relation_size(indrelid) > 0
ORDER BY pg_relation_size(indexrelid) DESC;
```

#### Deadlock Diagnostics

```sql
-- PostgreSQL: Current locks and blocking
SELECT
  blocked_locks.pid AS blocked_pid,
  blocked_activity.usename AS blocked_user,
  blocking_locks.pid AS blocking_pid,
  blocking_activity.usename AS blocking_user,
  blocked_activity.query AS blocked_query,
  blocking_activity.query AS blocking_query
FROM pg_catalog.pg_locks blocked_locks
JOIN pg_catalog.pg_stat_activity blocked_activity
  ON blocked_activity.pid = blocked_locks.pid
JOIN pg_catalog.pg_locks blocking_locks
  ON blocking_locks.locktype = blocked_locks.locktype
  AND blocking_locks.database IS NOT DISTINCT FROM blocked_locks.database
  AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
  AND blocking_locks.pid != blocked_locks.pid
JOIN pg_catalog.pg_stat_activity blocking_activity
  ON blocking_activity.pid = blocking_locks.pid
WHERE NOT blocked_locks.granted;

-- Deadlock prevention settings
SET deadlock_timeout = '1s';         -- Time before deadlock check
SET lock_timeout = '10s';            -- Max time to wait for lock
SET statement_timeout = '30s';       -- Max statement execution time
```

#### Connection Pool Configuration

```yaml
# PgBouncer configuration (pgbouncer.ini)
[databases]
myapp = host=localhost dbname=myapp

[pgbouncer]
pool_mode = transaction          # transaction pooling (recommended)
max_client_conn = 1000           # Max client connections
default_pool_size = 20           # Connections per user/database pair
min_pool_size = 5                # Keep min connections ready
reserve_pool_size = 5            # Extra connections for burst
reserve_pool_timeout = 3         # Seconds before using reserve
max_db_connections = 100         # Max connections to backend DB
server_idle_timeout = 600        # Close idle server connections
```

```javascript
// Node.js connection pool (pg-pool)
const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  database: 'myapp',
  max: 20,                    // Maximum pool size
  min: 5,                     // Minimum pool size
  idleTimeoutMillis: 30000,   // Close idle clients after 30s
  connectionTimeoutMillis: 5000,  // Fail if no connection in 5s
  maxUses: 7500,              // Close connection after N uses
});

// Health check query
pool.query('SELECT 1')
  .then(() => console.log('DB connection healthy'))
  .catch(err => console.error('DB connection failed', err));
```

**Connection Pool Sizing Formula:**
```
Optimal Pool Size = (core_count * 2) + effective_spindle_count

Example (8-core server, SSD):
- core_count = 8
- effective_spindle_count = 1 (SSD counts as 1)
- Optimal = (8 * 2) + 1 = 17 connections per pool

For web apps: Start with 10-20, monitor, adjust based on wait times
```

### Step 8: Multi-Tenancy Patterns

**Pattern Selection Matrix:**
```
┌───────────────────────────────────────────────────────────────────────┐
│                      Multi-Tenancy Strategies                         │
├──────────────────┬────────────────┬───────────────────────────────────┤
│ Pattern          │ Isolation      │ Trade-offs                        │
├──────────────────┼────────────────┼───────────────────────────────────┤
│ Shared DB/Schema │ Low (Row-Level)│ Simple, cost-effective, shared    │
│ Schema per Tenant│ Medium         │ Logical isolation, same DB        │
│ DB per Tenant    │ High           │ Full isolation, expensive         │
│ Hybrid           │ Variable       │ Premium tenants get dedicated     │
└──────────────────┴────────────────┴───────────────────────────────────┘
```

#### Pattern 1: Row-Level Isolation (Shared Schema)

```sql
-- All tables have tenant_id column
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  tenant_id INTEGER NOT NULL REFERENCES tenants(id),
  name VARCHAR(200) NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Composite index for tenant-scoped queries
CREATE INDEX idx_products_tenant ON products(tenant_id, id);

-- Row-Level Security (PostgreSQL)
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation_policy ON products
  USING (tenant_id = current_setting('app.current_tenant')::INTEGER);

-- Set tenant context in application
SET app.current_tenant = '123';
SELECT * FROM products;  -- Only returns tenant 123's products
```

```typescript
// Application middleware (Express/Node.js)
async function tenantMiddleware(req, res, next) {
  const tenantId = req.headers['x-tenant-id'];
  if (!tenantId) {
    return res.status(400).json({ error: 'Tenant ID required' });
  }

  // Set tenant context for this request
  await db.query(`SET app.current_tenant = $1`, [tenantId]);
  req.tenantId = tenantId;
  next();
}

// All queries automatically filtered by RLS
app.get('/products', async (req, res) => {
  const products = await db.query('SELECT * FROM products');
  res.json(products.rows);  // Only this tenant's products
});
```

#### Pattern 2: Schema per Tenant

```sql
-- Create tenant schema
CREATE SCHEMA tenant_acme;

-- Create tables in tenant schema
CREATE TABLE tenant_acme.products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  price DECIMAL(10,2) NOT NULL
);

-- Application sets search_path per request
SET search_path TO tenant_acme, public;
```

```typescript
// Schema routing middleware
async function schemaMiddleware(req, res, next) {
  const tenantSlug = req.headers['x-tenant-slug'];
  const schemaName = `tenant_${tenantSlug}`;

  // Verify schema exists
  const exists = await db.query(
    `SELECT schema_name FROM information_schema.schemata WHERE schema_name = $1`,
    [schemaName]
  );

  if (exists.rows.length === 0) {
    return res.status(404).json({ error: 'Tenant not found' });
  }

  await db.query(`SET search_path TO ${schemaName}, public`);
  req.tenantSchema = schemaName;
  next();
}
```

**Tenant Provisioning Script:**
```sql
-- Create new tenant
CREATE OR REPLACE FUNCTION create_tenant(tenant_slug TEXT)
RETURNS VOID AS $$
DECLARE
  schema_name TEXT := 'tenant_' || tenant_slug;
BEGIN
  -- Create schema
  EXECUTE format('CREATE SCHEMA %I', schema_name);

  -- Create tables
  EXECUTE format('CREATE TABLE %I.products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
  )', schema_name);

  EXECUTE format('CREATE TABLE %I.orders (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES %I.products(id),
    quantity INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
  )', schema_name, schema_name);

  -- Create indexes
  EXECUTE format('CREATE INDEX ON %I.products(created_at)', schema_name);
END;
$$ LANGUAGE plpgsql;

-- Usage
SELECT create_tenant('acme');
SELECT create_tenant('globex');
```

#### Pattern 3: Database per Tenant

```yaml
# Connection configuration per tenant
tenants:
  acme:
    host: acme-db.example.com
    database: acme_prod
    pool_size: 10
  globex:
    host: globex-db.example.com
    database: globex_prod
    pool_size: 20
  default:
    host: shared-db.example.com
    database: multi_tenant
    pool_size: 50
```

```typescript
// Connection pool per tenant
class TenantConnectionManager {
  private pools: Map<string, Pool> = new Map();

  getPool(tenantId: string): Pool {
    if (!this.pools.has(tenantId)) {
      const config = this.getTenantConfig(tenantId);
      this.pools.set(tenantId, new Pool(config));
    }
    return this.pools.get(tenantId)!;
  }

  async query(tenantId: string, sql: string, params?: any[]) {
    const pool = this.getPool(tenantId);
    return pool.query(sql, params);
  }

  async closeTenant(tenantId: string) {
    const pool = this.pools.get(tenantId);
    if (pool) {
      await pool.end();
      this.pools.delete(tenantId);
    }
  }
}
```

**Multi-Tenancy Security Checklist:**
```
[ ] Tenant ID validated on every request
[ ] Cross-tenant data access impossible (test with tenant A accessing B's data)
[ ] Tenant ID cannot be spoofed (validate against auth token)
[ ] Bulk operations respect tenant boundaries
[ ] Logs include tenant context for debugging
[ ] Backup/restore tested per tenant
[ ] Data export includes only tenant's data
```

**Migration Impact by Pattern:**
```
┌──────────────────┬────────────────────────────────────────────────────┐
│ Pattern          │ Migration Complexity                               │
├──────────────────┼────────────────────────────────────────────────────┤
│ Row-Level        │ Single migration, affects all tenants              │
│                  │ Risk: One bad migration affects everyone           │
├──────────────────┼────────────────────────────────────────────────────┤
│ Schema per Tenant│ Must run migration per schema                      │
│                  │ Can rollout gradually, tenant by tenant            │
├──────────────────┼────────────────────────────────────────────────────┤
│ DB per Tenant    │ Independent migrations per database                │
│                  │ Highest isolation, but most operational overhead   │
└──────────────────┴────────────────────────────────────────────────────┘
```

---

## Checklists

### Schema Design

```
[ ] Primary key defined
[ ] Foreign keys with proper ON DELETE
[ ] Indexes on foreign keys
[ ] Appropriate data types
[ ] NOT NULL where required
[ ] Default values where appropriate
[ ] Check constraints for validation
[ ] tenant_id column (if multi-tenant)
```

### Query Review

```
[ ] No SELECT *
[ ] EXPLAIN ANALYZE run
[ ] Index scan (not seq scan) for large tables
[ ] No N+1 patterns
[ ] Pagination for lists
[ ] Proper JOIN types
[ ] Timeout configured for long-running queries
```

### Migration (Zero-Downtime)

```
[ ] Strategy selected (expand-contract/shadow/gh-ost)
[ ] UP migration tested
[ ] DOWN migration tested (rollback works)
[ ] Backfill script ready (batched)
[ ] Indexes created CONCURRENTLY
[ ] No blocking DDL statements
[ ] Blue-green deploy considered for major changes
```

### Operational Governance

```
[ ] Slow query log enabled (threshold: 1s)
[ ] Index health dashboard configured
[ ] Deadlock monitoring in place
[ ] Connection pool sized appropriately
[ ] Query timeout configured
[ ] Alerting on slow queries / deadlocks
```

### Multi-Tenancy

```
[ ] Tenant isolation pattern selected
[ ] Row-Level Security enabled (if shared schema)
[ ] Cross-tenant access tested and blocked
[ ] Tenant context set per request
[ ] Migration strategy per pattern documented
[ ] Backup/restore tested per tenant
```

---

## Anti-patterns

| Anti-pattern | Why Bad | Fix |
|--------------|---------|-----|
| SELECT * | Wastes bandwidth, breaks on schema change | List needed columns |
| Missing FK indexes | Slow JOINs and CASCADE deletes | Add indexes |
| N+1 queries | Exponential query count | Batch queries or JOINs |
| No pagination | Memory/time explosion | Add LIMIT/OFFSET |
| God table | Hard to maintain, poor performance | Normalize |
| EAV pattern | Complex queries, no type safety | Proper columns or JSONB |

---

## Tools / Commands

### Query Analysis

```bash
# PostgreSQL
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'test@test.com';

# Check index usage
SELECT
  relname AS table,
  indexrelname AS index,
  idx_scan AS scans
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;

# Find missing indexes
SELECT
  relname AS table,
  seq_scan,
  idx_scan
FROM pg_stat_user_tables
WHERE seq_scan > idx_scan
ORDER BY seq_scan DESC;
```

### Schema Management

```bash
# Prisma
npx prisma migrate dev --name add_user_avatar
npx prisma migrate deploy

# Drizzle
npx drizzle-kit generate:pg
npx drizzle-kit push:pg

# Raw SQL
psql -d database -f migrations/001_create_users.sql
```

---

## TAD Integration

### Gate Mapping

```yaml
Database_Patterns:
  skill: database-patterns.md
  enforcement: RECOMMENDED
  tad_gates: [Gate2_Design]
  triggers:
    - Alex designing data model
    - Blake implementing data layer
    - Performance issues identified
    - Schema migration required
    - Multi-tenant system design
  evidence_required:
    - schema_diagram
    - index_strategy (for key queries)
    - query_analysis (EXPLAIN output)
    - migration_plan (if schema changes)
    - slow_query_baseline (before/after)
  acceptance:
    - Schema normalized appropriately
    - FKs indexed
    - Key queries optimized (< 100ms p95)
    - Zero-downtime migration verified
    - Connection pool configured
```

### Evidence Template

```markdown
## Database Design Evidence - [Feature Name]

**Date:** YYYY-MM-DD
**Author:** [Name]
**Gate:** Gate2_Design

---

### 1. Schema Overview

**Tables:** users, orders, order_items
**Relationships:**
- users 1:N orders
- orders 1:N order_items

**ERD:** (Link to diagram or inline ASCII)

---

### 2. Index Strategy

| Table | Index | Columns | Purpose | Usage |
|-------|-------|---------|---------|-------|
| orders | idx_orders_user_id | user_id | FK lookup | High |
| orders | idx_orders_status | status | Filter | Medium |
| orders | idx_orders_created | created_at | Time range | High |

---

### 3. Query Analysis

**Critical Query 1:** Get user orders
\`\`\`sql
EXPLAIN ANALYZE SELECT * FROM orders WHERE user_id = 123;

Index Scan using idx_orders_user_id on orders
  Index Cond: (user_id = 123)
  Rows Returned: 47
  Execution Time: 0.5ms
\`\`\`

**Query Performance Summary:**
| Query | p50 | p95 | p99 | Status |
|-------|-----|-----|-----|--------|
| Get user orders | 0.3ms | 0.8ms | 1.2ms | ✅ Pass |
| List all products | 2.1ms | 5.3ms | 8.7ms | ✅ Pass |

---

### 4. Migration Plan

**Strategy:** Expand-Contract
**Files:**
- `migrations/20260106_001_add_avatar_up.sql`
- `migrations/20260106_001_add_avatar_down.sql`
- `scripts/backfill_avatar.py`

**Deployment Steps:**
1. [ ] Deploy migration (add column NULL)
2. [ ] Deploy code (write to both)
3. [ ] Run backfill script
4. [ ] Deploy code (read from new)
5. [ ] Drop old column

**Rollback Tested:** ✅ Yes
**Estimated Backfill Time:** ~15 minutes (1M rows)

---

### 5. Operational Governance

**Slow Query Threshold:** 1000ms
**Connection Pool:**
- Max: 20
- Min: 5
- Idle timeout: 30s

**Monitoring:**
- [ ] pg_stat_statements enabled
- [ ] Slow query alerts configured
- [ ] Index health dashboard set up

---

### 6. Multi-Tenancy (if applicable)

**Pattern:** Row-Level Security
**Isolation Verification:**
- [ ] Tenant A cannot access Tenant B data
- [ ] API validates tenant_id against auth token
- [ ] Bulk operations include tenant filter

---

### Sign-off

**Schema Design:** ✅ Complete
**Migration Plan:** ✅ Verified
**Ready for Gate2:** Yes
```

---

## Related Skills

- `api-design.md` - API layer above database
- `performance-optimization.md` - Overall performance strategy
- `software-architecture.md` - System-level data design
- `security-checklist.md` - SQL injection prevention

---

## References

- [SQL Antipatterns](https://www.amazon.com/SQL-Antipatterns-Programming-Pragmatic-Programmers/dp/1934356557)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Use The Index, Luke](https://use-the-index-luke.com/)
- [Database Normalization](https://www.guru99.com/database-normalization.html)

---

*This skill guides Claude in designing efficient database schemas and writing optimized queries.*

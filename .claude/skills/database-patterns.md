# Database Patterns Skill

---
title: "Database Patterns"
version: "2.0"
last_updated: "2026-01-06"
tags: [database, sql, schema, optimization, engineering]
domains: [backend, data]
level: intermediate
estimated_time: "35min"
prerequisites: []
sources:
  - "SQL Antipatterns - Bill Karwin"
  - "Database Design for Mere Mortals"
  - "PostgreSQL Documentation"
enforcement: recommended
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

### Step 6: Plan Migrations

**Zero-Downtime Migration Steps:**
```
1. Add new column (allow NULL)
   ALTER TABLE users ADD COLUMN new_field VARCHAR(100);

2. Deploy code that writes to both old and new columns

3. Backfill existing data
   UPDATE users SET new_field = old_field WHERE new_field IS NULL;

4. Add NOT NULL constraint (if needed)
   ALTER TABLE users ALTER COLUMN new_field SET NOT NULL;

5. Deploy code that only reads from new column

6. Remove old column
   ALTER TABLE users DROP COLUMN old_field;
```

**Migration Script Template:**
```sql
-- migrations/20240106_001_add_avatar.sql

-- UP
ALTER TABLE users ADD COLUMN avatar_url VARCHAR(500);
CREATE INDEX idx_users_avatar ON users(avatar_url)
WHERE avatar_url IS NOT NULL;

-- DOWN
DROP INDEX IF EXISTS idx_users_avatar;
ALTER TABLE users DROP COLUMN avatar_url;
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
```

### Query Review

```
[ ] No SELECT *
[ ] EXPLAIN ANALYZE run
[ ] Index scan (not seq scan) for large tables
[ ] No N+1 patterns
[ ] Pagination for lists
[ ] Proper JOIN types
```

### Migration

```
[ ] UP migration tested
[ ] DOWN migration tested
[ ] Zero-downtime compatible
[ ] Backfill script ready
[ ] Indexes created after data load
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
  triggers:
    - Alex designing data model
    - Blake implementing data layer
    - Performance issues identified
  evidence_required:
    - schema_diagram
    - index_strategy (for key queries)
    - query_analysis (EXPLAIN output)
  acceptance:
    - Schema normalized appropriately
    - FKs indexed
    - Key queries optimized
```

### Evidence Template

```markdown
## Database Design Evidence

### Schema Overview
Tables: users, orders, order_items
Relationships:
- users 1:N orders
- orders 1:N order_items

### Index Strategy
| Table | Index | Columns | Purpose |
|-------|-------|---------|---------|
| orders | idx_orders_user_id | user_id | FK lookup |
| orders | idx_orders_status | status | Filter by status |

### Query Analysis
```
Query: SELECT * FROM orders WHERE user_id = 123
Plan: Index Scan on idx_orders_user_id
Time: 0.5ms
```

### Migration
File: `migrations/20240106_create_orders.sql`
Rollback: Tested ✓
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

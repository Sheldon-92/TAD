# Database Review Output Format

> Extracted from database-patterns skill - use this for database design reviews

## Quick Checklist

```
1. [ ] Primary key defined (prefer UUID or ULID over auto-increment)
2. [ ] Foreign keys with proper ON DELETE/UPDATE actions
3. [ ] Indexes on frequently queried columns
4. [ ] Normalization appropriate (3NF for OLTP, denormalized for OLAP)
5. [ ] EXPLAIN ANALYZE on critical queries
6. [ ] Connection pooling configured
```

## Red Flags

- Missing primary keys or foreign key constraints
- No indexes on JOIN columns or WHERE clauses
- N+1 query patterns in application code
- SELECT * in production queries
- No pagination on large result sets
- Raw SQL with string concatenation (SQL injection risk)
- Missing database migrations

## Output Format

### Schema Review

| Table | Primary Key | Foreign Keys | Indexes | Issues |
|-------|-------------|--------------|---------|--------|
| [table] | [type] | [references] | [columns] | [findings] |

### Query Performance

| Query | Execution Time | Rows Scanned | Index Used | Recommendation |
|-------|---------------|--------------|------------|----------------|
| [query] | [time] | [rows] | Yes/No | [suggestion] |

### Normalization Assessment

| Table | Current Form | Recommended | Reason |
|-------|--------------|-------------|--------|
| [table] | [1NF/2NF/3NF] | [target] | [explanation] |

### Migration Checklist

- [ ] Backward compatible (can rollback)
- [ ] Data migration script tested
- [ ] Indexes created CONCURRENTLY (if applicable)
- [ ] Foreign key constraints added after data load
- [ ] Old columns/tables have deprecation plan

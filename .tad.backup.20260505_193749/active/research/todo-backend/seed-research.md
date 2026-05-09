# Seed Data Research — Todo App Backend

## Seed Requirements

### From Schema
- **User roles**: owner, member (+ soft-deleted edge case)
- **Todo priorities**: low, medium, high, urgent
- **Todo states**: completed (true/false)
- **Category colors**: hex codes

### Data Volume (by profile)

| Profile | Users | Todos/User | Categories/User | Total Todos |
|---------|-------|------------|-----------------|-------------|
| dev | 5 | 4 | 3 | ~23 (+ 3 edge cases) |
| staging | 50 | 10 | 5 | ~500 |
| stress | 1000 | 50 | 8 | ~50,000 |

### Insertion Order (FK constraints)
1. Users (no dependencies)
2. Categories (depends on User)
3. Todos (depends on User + Category)

### Edge Cases Covered
| Case | Data | Purpose |
|------|------|---------|
| Soft-deleted user | deletedAt set | Test login rejection |
| Max-length title | 255 chars | Test boundary |
| Max-length description | 2000 chars | Test boundary |
| Null description | description = null | Test optional field |
| Null dueDate | dueDate = null | Test optional field |
| Null categoryId | categoryId = null | Test uncategorized todo |
| Overdue todo | dueDate in the past | Test date filtering |
| Unicode content | CJK characters | Test encoding |
| All priorities | low/medium/high/urgent | Test enum coverage |
| Both roles | owner + member | Test RBAC |

### Determinism
- `faker.seed(42)` ensures identical output on every run
- Shared password: `TestPass123` (bcrypt hashed once, reused)

### Idempotency
- Script starts with `deleteMany()` on all tables (child first, then parent)
- Safe to run repeatedly

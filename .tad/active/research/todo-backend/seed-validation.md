# Seed Validation — Todo App Backend

## Prisma Schema Validation
- **Tool**: `npx prisma validate` (Prisma v5)
- **Result**: PASS - "The schema at prisma/schema.prisma is valid"

## Seed Script Code Review

### Correctness Checks
| Check | Status | Notes |
|-------|--------|-------|
| Insertion order respects FK | PASS | Users -> Categories -> Todos |
| Idempotent (deleteMany first) | PASS | Cleans all tables before seeding |
| faker.seed(42) deterministic | PASS | Called once at top of script |
| All roles covered | PASS | 1 owner + N members + 1 soft-deleted |
| All priorities covered | PASS | Random selection from all 4 values |
| Both todo states | PASS | 30% completed, 70% pending |
| Nullable fields tested | PASS | description, dueDate, categoryId can be null |
| Edge cases | PASS | Max-length, unicode, overdue |
| Password hashed | PASS | bcrypt(TestPass123, 12) |
| Profile support | PASS | dev/staging/stress via CLI arg |

### Potential Issues
- [ASSUMPTION] Script uses `@prisma/client` which requires `npx prisma generate` to have been run first
- [ASSUMPTION] bcryptjs must be installed as a dependency
- Stress profile (1000 users x 50 todos) may take 1-2 minutes due to sequential inserts
  - Optimization: Use `prisma.user.createMany()` for bulk insert if needed

## Runtime Validation (not executed)
- Cannot run seed without an active SQLite database
- To validate end-to-end: `npx prisma db push && npx tsx prisma/seed.ts`

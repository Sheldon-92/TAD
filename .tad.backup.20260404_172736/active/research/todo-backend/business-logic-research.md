# Business Logic Research — Todo App Backend

## Architecture Pattern: Clean Layered Architecture

### Reference Patterns
- **Repository Pattern**: Separate data access from business logic
- **Service Layer Pattern**: Centralize business rules
- **Zod Validation**: Input validation at the boundary

### Layer Responsibilities

| Layer | Files | Responsibility | Can Call |
|-------|-------|---------------|----------|
| Route | `routes/*.ts` | Parse HTTP, call service, format response | Validators, Services |
| Validator | `validators/schemas.ts` | Zod schema validation | Nothing |
| Service | `services/*.ts` | Business logic, authorization | Repositories |
| Repository | `repositories/*.ts` | Prisma ORM calls | Database |
| Error | `errors/*.ts` | Error formatting, mapping | Nothing |

## Core Business Rules

| Rule | Entity | Trigger | Validation | Failure |
|------|--------|---------|------------|---------|
| Unique email | User | Register | DB unique constraint | 409 Conflict |
| Password strength | User | Register/Update | Zod regex | 400 Bad Request |
| Category name unique per user | Category | Create/Update | DB @@unique | 409 Conflict |
| Todo category ownership | Todo | Create/Update | Service checks userId match | 400 Bad Request |
| Member sees own todos only | Todo | List/Get | Service scopes by userId | 403 Forbidden |
| Owner can access all | All | Any | Role check in middleware | N/A (allowed) |
| Password change needs current | User | Update | Service verifies old hash | 400 Bad Request |
| Soft-deleted users can't login | User | Login | Service checks deletedAt | 401 Unauthorized |
| Refresh token rotation | Auth | Refresh | bcrypt compare stored hash | 401 Unauthorized |

## State Machine: Todo

Todo has a simple binary state (no complex state machine):
- `completed: false` (pending)
- `completed: true` (completed)

No state transitions restrictions — user can toggle freely.
[ASSUMPTION] If workflow states needed (draft -> in_progress -> done), would add a `status` enum field.

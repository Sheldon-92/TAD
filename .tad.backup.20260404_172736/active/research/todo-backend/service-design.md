# Service Layer Design — Todo App Backend

## Architecture: 3-Layer Separation

```
Route Layer          → HTTP parsing, Zod validation, response formatting
Service Layer        → Business logic, authorization, orchestration
Repository Layer     → Data access, Prisma ORM encapsulation
```

### Rule: Each layer has ONE responsibility
- **Route**: Parse HTTP → call Service → format HTTP response
- **Service**: Enforce business rules → call Repository → return domain objects
- **Repository**: Translate domain queries → Prisma calls → return raw data

## Service Method Signatures

### AuthService

| Method | Input | Output | Side Effects |
|--------|-------|--------|-------------|
| `register` | `{email, password, name}` | `AuthResult` | Create user, hash password, store refresh token |
| `login` | `{email, password}` | `AuthResult` | Verify credentials, issue tokens |
| `refresh` | `refreshToken: string` | `TokenResult` | Rotate refresh token |
| `logout` | `userId: string` | `void` | Clear refresh token |

### TodoService

| Method | Input | Output | Side Effects |
|--------|-------|--------|-------------|
| `create` | `userId, CreateTodoInput` | `TodoWithCategory` | Validate category ownership |
| `list` | `userId, role, filters, page, pageSize` | `PaginatedResult` | Scope by role |
| `getById` | `todoId, userId, role` | `TodoWithCategory` | Ownership check |
| `update` | `todoId, userId, role, UpdateTodoInput` | `TodoWithCategory` | Ownership + category check |
| `delete` | `todoId, userId, role` | `void` | Ownership check |

### UserService

| Method | Input | Output | Side Effects |
|--------|-------|--------|-------------|
| `getProfile` | `userId` | `UserProfile` | None |
| `updateProfile` | `userId, UpdateProfileInput` | `UserProfile` | Password re-verification |
| `listUsers` | `page, pageSize` | `PaginatedResult` | Owner only |
| `getUserById` | `userId` | `UserProfile` | Owner only |
| `deleteUser` | `userId` | `void` | Soft delete |

### CategoryService

| Method | Input | Output | Side Effects |
|--------|-------|--------|-------------|
| `create` | `userId, CreateCategoryInput` | `CategoryData` | DB unique constraint |
| `list` | `userId, page, pageSize` | `PaginatedResult` | Scoped to user |
| `getById` | `categoryId, userId` | `CategoryData` | Ownership check |
| `update` | `categoryId, userId, UpdateCategoryInput` | `CategoryData` | Ownership + unique check |
| `delete` | `categoryId, userId` | `void` | Ownership check, cascade nullify |

## Validation Layer (Zod)

Each API endpoint has a corresponding Zod schema:

| Endpoint | Schema | Key Rules |
|----------|--------|-----------|
| POST /auth/register | `registerSchema` | email format, password strength |
| POST /auth/login | `loginSchema` | email format, non-empty password |
| POST /auth/refresh | `refreshSchema` | non-empty token |
| PATCH /users/me | `updateUserSchema` | password requires currentPassword |
| POST /todos | `createTodoSchema` | title required, max lengths |
| PATCH /todos/:id | `updateTodoSchema` | all fields optional |
| GET /todos | `todoFiltersSchema` | enum validation, date coercion |
| POST /categories | `createCategorySchema` | name required, hex color regex |
| PATCH /categories/:id | `updateCategorySchema` | all fields optional |

## Error Handling Strategy

| Error Type | Handler | HTTP Status |
|------------|---------|-------------|
| Zod validation error | errorMiddleware → 400 | 400 Bad Request |
| Business rule violation | Service throws AppError | 400/403/404/409 |
| Prisma P2002 (unique) | prismaErrors mapper | 409 Conflict |
| Prisma P2025 (not found) | prismaErrors mapper | 404 Not Found |
| Prisma P2003 (FK) | prismaErrors mapper | 400 Bad Request |
| Unknown error | errorMiddleware → 500 | 500 Internal |

## Transaction Boundaries

| Operation | Needs Transaction? | Reason |
|-----------|--------------------|--------|
| Register user + store token | Yes | User and token must be atomic |
| Delete category + nullify todos | No | DB cascade handles (onDelete: SetNull) |
| Delete user (soft) | No | Single update operation |
| Update todo + verify category | No | Read-then-write, category check is validation |

[ASSUMPTION] For v1, all operations are single-table or leverage DB cascades.
Multi-table transactions will be needed when adding features like "batch todo operations" or "team management".

# Database Design Research — Todo App Backend

## Data Model References
- Standard todo app patterns: User -> Todo (1:N), User -> Category (1:N), Category -> Todo (1:N optional)
- Reference: Todoist, Microsoft To Do, TickTick data models

## Database Selection: SQLite
- **Rationale**: Zero-infrastructure, perfect for development and small-to-medium apps
- **Trade-off**: No concurrent write performance, no built-in enum type
- [ASSUMPTION] Migrate to PostgreSQL for production at scale (>1000 concurrent users)

## Entity Analysis

### User
- **Fields**: id (CUID), email (unique), name, passwordHash, role (owner|member), refreshToken, deletedAt, timestamps
- **Indexes**: email (unique), deletedAt (for filtering active users)
- **Soft delete**: deletedAt field preserves audit trail
- **Nullable fields**: refreshToken (null when logged out), deletedAt (null when active)

### Todo
- **Fields**: id (CUID), title, description?, completed, priority, dueDate?, userId (FK), categoryId? (FK), timestamps
- **Indexes**: userId, categoryId, [userId+completed], [userId+priority], [userId+dueDate]
- **Compound indexes**: Cover common query patterns (my completed todos, my urgent todos, my upcoming todos)
- **Nullable fields**: description (optional), dueDate (optional), categoryId (optional)

### Category
- **Fields**: id (CUID), name, color?, userId (FK), timestamps
- **Unique constraint**: @@unique([userId, name]) — category names unique per user
- **Indexes**: userId
- **Nullable fields**: color (optional hex color)

## Relationship Summary
| From | To | Type | On Delete |
|------|----|------|-----------|
| User | Todo | 1:N | Cascade (delete user deletes todos) |
| User | Category | 1:N | Cascade (delete user deletes categories) |
| Category | Todo | 1:N | SetNull (delete category nullifies todo.categoryId) |

## Design Decisions
1. **CUID over UUID**: Shorter, URL-friendly, sortable by creation time
2. **String enums over Prisma enum**: SQLite doesn't support native enums; validated at app layer
3. **Compound indexes**: Cover the 3 most common todo list queries (status, priority, due date)
4. **Soft delete on User only**: Todos and categories cascade-delete with user; no need for independent soft delete
5. **No version field**: Low-concurrency app, optimistic locking not needed in v1

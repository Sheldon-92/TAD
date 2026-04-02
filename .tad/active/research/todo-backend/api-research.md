# API Design Research — Todo App Backend

## Reference API Patterns

### Industry Standards for Todo/Task Management APIs
- **Todoist API (v2)**: REST, Bearer token auth, `/tasks`, `/projects`, `/labels`, `/sections`
- **Microsoft To Do (Graph API)**: REST, OAuth 2.0, `/me/todo/lists`, `/me/todo/lists/{id}/tasks`
- **Google Tasks API**: REST, OAuth 2.0, `/tasklists`, `/tasklists/{id}/tasks`

### Common Patterns Observed
1. **Resource Naming**: Plural nouns (`/tasks`, `/users`, `/categories`)
2. **Nesting**: Max 2 levels (`/users/{id}/todos`)
3. **Pagination**: Offset-based for simple apps, cursor-based for scale
4. **Auth**: Bearer JWT for API-only, OAuth 2.0 for third-party integrations
5. **Error Format**: Structured JSON with error code + message
6. **Versioning**: URL path `/v1/` is most common for public APIs

## Resource Modeling

| Resource | URI | Methods | Description | Auth |
|----------|-----|---------|-------------|------|
| Auth | `/v1/auth/register` | POST | Register new user | Public |
| Auth | `/v1/auth/login` | POST | Login, get tokens | Public |
| Auth | `/v1/auth/refresh` | POST | Refresh access token | Public (refresh token) |
| Auth | `/v1/auth/logout` | POST | Invalidate refresh token | Bearer |
| Users | `/v1/users/me` | GET | Get current user profile | Bearer |
| Users | `/v1/users/me` | PATCH | Update current user profile | Bearer |
| Users | `/v1/users` | GET | List all users | Bearer (Owner only) |
| Users | `/v1/users/{userId}` | GET | Get user by ID | Bearer (Owner only) |
| Users | `/v1/users/{userId}` | DELETE | Delete user | Bearer (Owner only) |
| Todos | `/v1/todos` | GET | List todos (filtered) | Bearer |
| Todos | `/v1/todos` | POST | Create todo | Bearer |
| Todos | `/v1/todos/{todoId}` | GET | Get todo by ID | Bearer |
| Todos | `/v1/todos/{todoId}` | PATCH | Update todo | Bearer |
| Todos | `/v1/todos/{todoId}` | DELETE | Delete todo | Bearer |
| Categories | `/v1/categories` | GET | List user's categories | Bearer |
| Categories | `/v1/categories` | POST | Create category | Bearer |
| Categories | `/v1/categories/{categoryId}` | GET | Get category by ID | Bearer |
| Categories | `/v1/categories/{categoryId}` | PATCH | Update category | Bearer |
| Categories | `/v1/categories/{categoryId}` | DELETE | Delete category | Bearer |

### Resource Relationships
- User 1:N Todo (a user owns many todos)
- User 1:N Category (a user creates categories)
- Category 1:N Todo (a todo belongs to one category, optional)

### Pagination Strategy
- **Offset-based** (simple, sufficient for todo app scale)
- Query params: `?page=1&pageSize=20&sort=createdAt&order=desc`
- Response wrapper: `{ "data": [], "meta": { "total": 100, "page": 1, "pageSize": 20, "totalPages": 5 } }`

### Filtering (Todos)
- `?status=completed|pending`
- `?categoryId={id}`
- `?priority=low|medium|high|urgent`
- `?dueBefore=2026-04-01T00:00:00Z`
- `?dueAfter=2026-03-01T00:00:00Z`
- `?search=keyword` (title search)

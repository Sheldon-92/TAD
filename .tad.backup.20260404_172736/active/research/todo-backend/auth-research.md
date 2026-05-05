# Authentication Research — Todo App Backend

## Auth Pattern References

### Industry Patterns for Todo/Task Apps
- **Todoist**: OAuth 2.0 for third-party, API tokens for personal use
- **Microsoft To Do**: Azure AD / OAuth 2.0
- **Google Tasks**: Google OAuth 2.0

### Selected Approach: Self-hosted JWT Bearer Token
- **Rationale**: API-only backend, no browser sessions needed, simple to implement
- **Not OAuth 2.0**: No third-party integrations required in v1
- **Not Session-based**: No server-rendered pages

## RBAC Matrix

| Resource | Action | Owner | Member |
|----------|--------|-------|--------|
| Auth (register) | POST | Public | Public |
| Auth (login) | POST | Public | Public |
| Auth (refresh) | POST | Public | Public |
| Auth (logout) | POST | Self | Self |
| Users /me | GET | Own profile | Own profile |
| Users /me | PATCH | Own profile | Own profile |
| Users (list) | GET | All users | **FORBIDDEN** |
| Users (by ID) | GET | Any user | **FORBIDDEN** |
| Users (delete) | DELETE | Any user | **FORBIDDEN** |
| Todos (list) | GET | All todos | **Own todos only** |
| Todos (create) | POST | Create any | Create own |
| Todos (get) | GET | Any todo | **Own only** |
| Todos (update) | PATCH | Any todo | **Own only** |
| Todos (delete) | DELETE | Any todo | **Own only** |
| Categories (list) | GET | Own categories | Own categories |
| Categories (create) | POST | Create own | Create own |
| Categories (get) | GET | Own only | Own only |
| Categories (update) | PATCH | Own only | Own only |
| Categories (delete) | DELETE | Own only | Own only |

## Security Checklist (OWASP)

| Item | Implementation |
|------|---------------|
| Password hashing | bcrypt, 12 rounds |
| Password policy | Min 8 chars, uppercase + lowercase + number |
| Token expiry (access) | 15 minutes |
| Token expiry (refresh) | 7 days, single-use with rotation |
| Refresh token storage | Hashed in DB (bcrypt) |
| Login failure message | Generic "Invalid email or password" (no enumeration) |
| Timing attack prevention | Always hash even if user not found |
| CORS | Whitelist specific origins [ASSUMPTION: to be configured per deployment] |
| Rate limiting | Login endpoint: 5 requests/minute/IP [ASSUMPTION] |
| Sensitive operations | Password change requires current password |
| Token in response | Access token in JSON body (not cookie) |
| Soft-deleted users | Cannot login (treated as invalid credentials) |

## Token Lifecycle

1. **Register/Login** -> Returns accessToken (15m) + refreshToken (7d)
2. **API Request** -> `Authorization: Bearer {accessToken}`
3. **Token Expired** -> POST /auth/refresh with refreshToken
4. **Refresh** -> Old refreshToken invalidated, new pair issued (rotation)
5. **Logout** -> RefreshToken cleared from DB
6. **Reuse Detection** -> If old refreshToken is reused, ALL tokens invalidated

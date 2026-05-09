# Authentication Design — Todo App Backend

## Auth Provider: Self-hosted JWT

**Choice Rationale**:
- Simple Todo app, no OAuth/SSO requirement in v1
- Full control over token management
- Zero external dependency
- [ASSUMPTION] If third-party login (Google, GitHub) needed later, can add OAuth 2.0 as additional flow

## Token Flow Design

### Registration
```
Client                    Server                    Database
  |-- POST /auth/register -->|                         |
  |   {email,password,name}  |                         |
  |                          |-- bcrypt.hash(pw, 12) --|
  |                          |-- INSERT user ---------->|
  |                          |-- Generate JWT pair -----|
  |                          |-- Store hash(refresh) -->|
  |<-- 201 {access,refresh} -|                         |
```

### Login
```
Client                    Server                    Database
  |-- POST /auth/login ----->|                         |
  |   {email, password}      |                         |
  |                          |-- SELECT user by email ->|
  |                          |-- bcrypt.compare --------|
  |                          |-- Generate JWT pair -----|
  |                          |-- Store hash(refresh) -->|
  |<-- 200 {access,refresh} -|                         |
```

### Authenticated Request
```
Client                    Server
  |-- GET /todos ----------->|
  |   Authorization: Bearer  |
  |   {accessToken}          |
  |                          |-- jwt.verify(token)
  |                          |-- Extract {userId, role}
  |                          |-- Scope query by userId (if member)
  |<-- 200 {data} ----------|
```

### Token Refresh (Rotation)
```
Client                    Server                    Database
  |-- POST /auth/refresh --->|                         |
  |   {refreshToken}         |                         |
  |                          |-- jwt.verify(refresh) --|
  |                          |-- SELECT stored hash --->|
  |                          |-- bcrypt.compare --------|
  |                          |-- Generate NEW pair -----|
  |                          |-- Store NEW hash ------->|
  |<-- 200 {access,refresh} -|                         |
  |                          |   (old refresh invalid) |
```

## Middleware Stack (per request)

1. **requestIdMiddleware** — Generate/propagate X-Request-ID
2. **authenticate** — Verify JWT, extract user payload
3. **requireRole** — Check role against allowed roles
4. **requireOwnership** — Verify user owns the resource (Members only)
5. **errorMiddleware** — Catch and format all errors (registered LAST)

## Security Configuration

| Config | Value | Notes |
|--------|-------|-------|
| JWT Algorithm | HS256 | [ASSUMPTION] Symmetric for single-server; use RS256 for distributed |
| JWT Secret | `process.env.JWT_SECRET` | Must be 256+ bit random string |
| Access Token TTL | 15 minutes | Short-lived |
| Refresh Token TTL | 7 days | Rotated on each use |
| Password Hash | bcrypt, 12 rounds | ~250ms per hash |
| Refresh Token Storage | Hashed in DB | Not plaintext |
| CORS Origins | env-configured whitelist | Never `*` in production |
| Rate Limit (login) | 5 req/min/IP | [ASSUMPTION] Using express-rate-limit |

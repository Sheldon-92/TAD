# API Contract — Todo App Backend

## HTTP Method Semantics (RFC 9110)

| Method | Semantics | Idempotent | Safe |
|--------|-----------|------------|------|
| GET | Read resource(s) | Yes | Yes |
| POST | Create resource | No | No |
| PATCH | Partial update | Yes | No |
| DELETE | Remove resource | Yes | No |

## Status Code Usage

| Code | Usage |
|------|-------|
| 200 OK | Successful GET, PATCH, login, refresh |
| 201 Created | Successful POST (register, create todo/category) |
| 204 No Content | Successful DELETE, logout |
| 400 Bad Request | Invalid input (Zod validation failure) |
| 401 Unauthorized | Missing/invalid/expired token |
| 403 Forbidden | Insufficient role or not resource owner |
| 404 Not Found | Resource doesn't exist |
| 409 Conflict | Unique constraint violation (email, category name) |
| 429 Too Many Requests | Rate limit exceeded (includes Retry-After header) |
| 500 Internal Server Error | Unexpected server error (details in logs only) |

## Error Format: RFC 7807 Problem Details

```json
{
  "type": "https://todoapp.example.com/errors/{error-type}",
  "title": "Human-Readable Title",
  "status": 400,
  "detail": "Specific explanation of what went wrong.",
  "errors": [
    { "field": "email", "message": "Must be a valid email.", "code": "INVALID_FORMAT" }
  ]
}
```

## Authentication: Bearer JWT

- Header: `Authorization: Bearer {accessToken}`
- Access token TTL: 15 minutes
- Refresh token TTL: 7 days (rotation on use)
- Public endpoints: register, login, refresh

## Pagination Response Format

```json
{
  "data": [...],
  "meta": {
    "total": 42,
    "page": 1,
    "pageSize": 20,
    "totalPages": 3
  }
}
```

## Versioning Strategy

URL path versioning: `/v1/`

Future breaking changes would use `/v2/` with v1 deprecation period.

# Error Handling Research — Todo App Backend

## RFC 7807 Problem Details

All error responses follow RFC 7807 format:
```json
{
  "type": "https://todoapp.example.com/errors/{error-type}",
  "title": "Human-Readable Title",
  "status": 400,
  "detail": "Specific explanation of what went wrong.",
  "errors": [{ "field": "email", "message": "...", "code": "..." }]
}
```

## Error Catalog

| HTTP Status | Error Code | Type URI | Description | Retryable |
|-------------|-----------|----------|-------------|-----------|
| 400 | REQUIRED | .../validation-failed | Required field missing | No |
| 400 | INVALID_FORMAT | .../validation-failed | Wrong format (email, date, etc.) | No |
| 400 | OUT_OF_RANGE | .../validation-failed | Value exceeds min/max | No |
| 400 | INVALID_CATEGORY | .../validation-failed | Category doesn't exist or wrong owner | No |
| 401 | MISSING_TOKEN | .../missing-token | No Authorization header | No |
| 401 | INVALID_TOKEN | .../invalid-token | Token malformed or signature invalid | No |
| 401 | EXPIRED_TOKEN | .../expired-token | Token past expiry time | No |
| 401 | INVALID_CREDENTIALS | .../invalid-credentials | Wrong email/password (generic) | No |
| 403 | INSUFFICIENT_PERMISSIONS | .../insufficient-permissions | Role lacks required permission | No |
| 403 | RESOURCE_FORBIDDEN | .../resource-forbidden | User doesn't own the resource | No |
| 404 | RESOURCE_NOT_FOUND | .../resource-not-found | Entity with given ID doesn't exist | No |
| 409 | RESOURCE_ALREADY_EXISTS | .../resource-already-exists | Unique constraint violation | No |
| 422 | VALIDATION_FAILED | .../validation-failed | Multi-field validation failure | No |
| 429 | RATE_LIMIT_EXCEEDED | .../rate-limit-exceeded | Too many requests (include Retry-After) | Yes |
| 500 | INTERNAL_ERROR | .../internal-error | Unhandled server error | No |
| 503 | SERVICE_UNAVAILABLE | .../service-unavailable | Database/dependency down | Yes |

## Logging Strategy (12-Factor)

- **Format**: Structured JSON (not plain text)
- **Destination**: stdout/stderr (container-friendly)
- **Levels**: error (5xx) > warn (4xx) > info (request log) > debug
- **Per request**: Always include `requestId` (X-Request-ID)
- **Security**: NEVER log passwords, tokens, full email addresses, or PII
- **Production**: No stack traces in responses (only in server logs)

## Prisma Error Mapping

| Prisma Code | Meaning | Maps To |
|-------------|---------|---------|
| P2002 | Unique constraint violation | 409 RESOURCE_ALREADY_EXISTS |
| P2003 | Foreign key violation | 400 INVALID_FORMAT |
| P2025 | Record not found | 404 RESOURCE_NOT_FOUND |
| P2014 | Required relation missing | 400 REQUIRED |
| P2016 | Query interpretation error | 400 INVALID_FORMAT |
| Other | Unknown DB error | 500 INTERNAL_ERROR |

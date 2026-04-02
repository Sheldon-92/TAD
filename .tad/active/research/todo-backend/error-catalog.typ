#set page(paper: "a4", margin: 2cm)
#set text(size: 10pt, font: "New Computer Modern")
#set heading(numbering: "1.1")

#align(center)[
  #text(size: 20pt, weight: "bold")[Error Catalog]
  #v(0.5em)
  #text(size: 12pt, fill: gray)[Todo App Backend | RFC 7807 Problem Details]
  #v(0.5em)
  #text(size: 10pt, fill: gray)[Generated: 2026-04-01]
]

#v(1em)

= Error Response Format

All errors follow *RFC 7807 Problem Details*:

```json
{
  "type": "https://todoapp.example.com/errors/{type}",
  "title": "Short Title",
  "status": 400,
  "detail": "Human-readable explanation.",
  "errors": [{"field": "...", "message": "...", "code": "..."}]
}
```

The `errors` array is only present for validation errors (400/422).

= Client Errors (4xx)

== 400 Bad Request — Validation Errors

#table(
  columns: (auto, auto, 1fr, auto),
  table.header([*Error Code*], [*Type URI Suffix*], [*Description*], [*Retry*]),
  [REQUIRED], [validation-failed], [Required field is missing], [No],
  [INVALID_FORMAT], [validation-failed], [Field format is invalid (email, date, etc.)], [No],
  [OUT_OF_RANGE], [validation-failed], [Value exceeds allowed min/max range], [No],
  [INVALID_CATEGORY], [validation-failed], [Category doesn't exist or belongs to another user], [No],
)

== 401 Unauthorized — Authentication Errors

#table(
  columns: (auto, auto, 1fr, auto),
  table.header([*Error Code*], [*Type URI Suffix*], [*Description*], [*Retry*]),
  [MISSING_TOKEN], [missing-token], [Authorization header not provided], [No],
  [INVALID_TOKEN], [invalid-token], [Token is malformed or signature is invalid], [No],
  [EXPIRED_TOKEN], [expired-token], [Access token has expired (use /auth/refresh)], [No],
  [INVALID_CREDENTIALS], [invalid-credentials], [Email or password is incorrect], [No],
)

*Security Note:* Login failures always return "Invalid email or password" — never reveal which field was wrong.

== 403 Forbidden — Authorization Errors

#table(
  columns: (auto, auto, 1fr, auto),
  table.header([*Error Code*], [*Type URI Suffix*], [*Description*], [*Retry*]),
  [INSUFFICIENT_PERMISSIONS], [insufficient-permissions], [User's role lacks required permission], [No],
  [RESOURCE_FORBIDDEN], [resource-forbidden], [User doesn't own the requested resource], [No],
)

== 404 Not Found

#table(
  columns: (auto, auto, 1fr, auto),
  table.header([*Error Code*], [*Type URI Suffix*], [*Description*], [*Retry*]),
  [RESOURCE_NOT_FOUND], [resource-not-found], [The requested entity does not exist], [No],
)

== 409 Conflict

#table(
  columns: (auto, auto, 1fr, auto),
  table.header([*Error Code*], [*Type URI Suffix*], [*Description*], [*Retry*]),
  [RESOURCE_ALREADY_EXISTS], [resource-already-exists], [Unique constraint violation (email, category name)], [No],
)

== 429 Too Many Requests

#table(
  columns: (auto, auto, 1fr, auto),
  table.header([*Error Code*], [*Type URI Suffix*], [*Description*], [*Retry*]),
  [RATE_LIMIT_EXCEEDED], [rate-limit-exceeded], [Request rate exceeded. Check `Retry-After` header.], [*Yes*],
)

= Server Errors (5xx)

== 500 Internal Server Error

#table(
  columns: (auto, auto, 1fr, auto),
  table.header([*Error Code*], [*Type URI Suffix*], [*Description*], [*Retry*]),
  [INTERNAL_ERROR], [internal-error], [Unexpected server error. Details logged server-side.], [No],
)

*Security:* 500 responses never include stack traces, database errors, or internal paths.

= Prisma Error Mapping

#table(
  columns: (auto, auto, auto, 1fr),
  table.header([*Prisma Code*], [*HTTP Status*], [*Error Code*], [*Example*]),
  [P2002], [409], [RESOURCE_ALREADY_EXISTS], [Duplicate email or category name],
  [P2003], [400], [INVALID_FORMAT], [Foreign key references non-existent record],
  [P2025], [404], [RESOURCE_NOT_FOUND], [Update/delete on non-existent record],
  [P2014], [400], [REQUIRED], [Missing required related record],
  [Other], [500], [INTERNAL_ERROR], [Unexpected database error],
)

= Request Tracing

Every request includes an `X-Request-ID` header (UUID). If a client reports an error, provide this ID for log correlation.

= Retry Guide

#table(
  columns: (auto, auto, 1fr),
  table.header([*Status*], [*Retryable*], [*Strategy*]),
  [400], [No], [Fix the request and resubmit],
  [401], [No], [Re-authenticate or refresh token],
  [403], [No], [Check role/ownership permissions],
  [404], [No], [Verify the resource ID exists],
  [409], [No], [Change the conflicting field value],
  [429], [Yes], [Wait for `Retry-After` seconds, then retry],
  [500], [No], [Report with X-Request-ID for investigation],
  [503], [Yes], [Exponential backoff: 1s, 2s, 4s, 8s (max 3 retries)],
)

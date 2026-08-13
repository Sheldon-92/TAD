# API Design Rules

Seven judgment rules for designing backend APIs. Applied when the user is
designing endpoints, reviewing an API, or making decisions about pagination,
batching, authentication, or data delivery strategy.

---

**Rule 1: Use cursor pagination for datasets > 10K rows**

Offset pagination (`LIMIT 10 OFFSET 50000`) causes a full table scan to the
offset position on every page request. At 50K+ rows this becomes a performance
cliff, and results are inconsistent if rows are inserted/deleted between pages.

Use cursor-based pagination instead:

```sql
-- Cursor pagination: fast, stable, works at any scale
SELECT * FROM orders
WHERE id > :cursor_id
ORDER BY id ASC
LIMIT :page_size;
```

```json
// Response envelope
{
  "items": [...],
  "next_cursor": "eyJpZCI6IDEyMzQ1fQ==",
  "has_more": true
}
```

- If dataset is < 10K rows and never expected to grow beyond it: offset is acceptable
- If dataset is or will be > 10K rows: cursor pagination is required
- If the sort key is non-unique (e.g., `created_at`): use a compound cursor
  `(sort_key, tiebreaker_id)` to avoid row skipping when values collide
- If the user needs to jump to arbitrary pages (e.g., "page 500 of 10,000"): cursor
  does not support this; use Elasticsearch or pre-computed page indexes

[Source: zalando/restful-api-guidelines — Section: Pagination]

---

**Rule 2: Require empirical evidence before implementing batch operations**

Batch endpoints (accepting arrays of items) add significant complexity: partial
failure handling, ordering guarantees, input size limits, timeout risks, and
rollback semantics. Build bulk endpoints instead when the operation is truly
homogeneous.

Decision criteria:
- "Batch" = mixed operations in one request (create some, update others) → avoid
- "Bulk" = same operation on multiple items of the same type → acceptable with limits

```http
# Prefer bulk (homogeneous)
POST /products/bulk-create
Content-Type: application/json
{"items": [...], "on_duplicate": "skip"}

# Avoid batch (mixed operations)
POST /products/batch
[{"op": "create", ...}, {"op": "update", "id": 123, ...}]
```

Before implementing either: measure whether client-side sequential requests with
connection pooling are sufficient. Batch/bulk is rarely needed at < 1000 items/s.

[Source: zalando/restful-api-guidelines — Section: Batch and Bulk Requests]

---

**Rule 3: GET requests must never have business logic side effects**

GET is defined by HTTP as safe and idempotent. Any GET endpoint that modifies
state (writes audit logs, increments counters, triggers emails, updates `last_seen`)
creates CSRF vulnerabilities and breaks cache semantics.

```http
# WRONG: GET that triggers side effect
GET /documents/123/download  →  writes AuditLog entry

# RIGHT: separate the read from the write
GET /documents/123/download           → returns document, no writes
POST /documents/123/download-events   → records the download event (fire-and-forget)
```

If logging access is required, fire it asynchronously post-response via middleware
or a background queue — not inside the GET handler.

[Source: zalando/restful-api-guidelines — Section: HTTP Requests; RFC 7231 §4.3.1]

---

**Rule 4: Use whitelisting, not blacklisting, for Response DTOs**

Returning ORM objects or database rows directly exposes every field, including
fields added later. A single new column (e.g., `password_hash`, `internal_notes`)
becomes a data leak if no DTO filters it out.

```typescript
// WRONG: returning the raw entity
return await userRepository.findOne(id);

// RIGHT: explicit whitelist via DTO
class UserResponseDto {
  id: string;
  email: string;
  displayName: string;
  createdAt: Date;
  // password_hash, stripeCustomerId, etc. are NOT listed → never serialized
}
return plainToClass(UserResponseDto, user, { excludeExtraneousValues: true });
```

```python
# Python equivalent
return UserResponseSchema.from_orm(user)  # schema defines the whitelist
```

Every new field must be consciously added to the DTO. This is the correct default.

[Source: Sairyss/backend-best-practices — DTOs and Data Leakage]

---

**Rule 5: Never accept authentication material in URLs**

API keys, tokens, passwords, and session IDs in query strings or path segments
appear in server logs, browser history, referrer headers, and proxy access logs.

```http
# WRONG
GET /api/data?api_key=sk-prod-abc123

# WRONG
GET /api/data/token/sk-prod-abc123

# RIGHT
GET /api/data
Authorization: Bearer sk-prod-abc123
```

If a client cannot set headers (e.g., browser `<img>` tag, webhook callback):
use short-lived signed URLs with expiry, not long-lived tokens in query strings.

[Source: OWASP/API-Security — API2:2023 Broken Authentication; zalando/restful-api-guidelines]

---

**Rule 6: Enforce HTTPS with context-appropriate strategy**

- If API endpoints: reject non-HTTPS requests with `400 Bad Request` or `403 Forbidden`.
  Do **not** redirect to HTTPS. Redirecting silently downgrades the security of the
  first request (which may contain a token) and teaches clients to use HTTP.
- If browser-facing web app (renders HTML): use HSTS + 301 redirect per RFC 6797.
  Browsers cache the HSTS header and skip HTTP on subsequent visits.

```nginx
# API server: reject HTTP
server {
  listen 80;
  return 400;  # not 301
}

# Web app: HSTS + redirect
server {
  listen 443 ssl;
  # First deployment: start with max-age=300, verify, then ramp to 31536000
  # Add preload only when committed long-term — preload list removal takes 6+ months
  add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
}
server {
  listen 80;
  return 301 https://$host$request_uri;
}
```

[Source: RFC 6797 (HSTS); zalando/restful-api-guidelines — Security]

---

**Rule 7: Prefer event-driven delivery over polling**

Polling creates N×M load (N clients × M poll requests per minute) and delivers
stale data between polls. Use event-driven delivery as the default:

- If WebSocket is possible (persistent connection): use WebSocket push
- If server-to-client only (no client messages): use Server-Sent Events (SSE)
- If decoupled / cross-service: use webhooks with retry + signature verification
- If serverless (no persistent connections): use exponential-backoff polling with
  `ETag` / `If-Modified-Since` to avoid transferring unchanged data

```http
# Polling with cache headers (serverless fallback)
GET /jobs/123/status
If-None-Match: "etag-abc"

# Server returns 304 Not Modified if unchanged → zero data transfer
```

Polling without cache headers is **never** acceptable for real-time requirements.

[Source: zalando/restful-api-guidelines — Section: Events and Webhooks; Sairyss/backend-best-practices]

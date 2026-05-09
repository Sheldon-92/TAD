# Web Backend Skills Best Practices — Research Summary

> Research date: 2026-04-01
> Sources: 9 web searches, 20+ page fetches across GitHub repos, OWASP, industry guides

## Repositories Analyzed

| Repo | Stars | Focus | Key Strengths |
|------|-------|-------|---------------|
| [Jeffallan/claude-skills](https://github.com/Jeffallan/claude-skills) | — | 66 specialized skills (api-designer, security-reviewer, database-optimizer) | Best-structured reference docs; 6-step workflow with tool validation; RFC 7807 templates |
| [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) | — | 220+ skills (database-designer, database-schema-designer, api-design-reviewer) | Most comprehensive DB skill; zero-downtime migration patterns; multi-DB decision matrix |
| [supabase/agent-skills](https://github.com/supabase/agent-skills) | — | Postgres best practices (34 reference rules across 8 categories) | Production-proven; impact-prioritized categories; correct/incorrect SQL examples per rule |
| [auth0/agent-skills](https://github.com/auth0/agent-skills) | — | Auth implementation (13+ framework-specific skills, migration, MFA) | Framework-specific auth patterns; migration from legacy providers; PKCE + OAuth 2.0 |
| [affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) | — | Backend patterns (Node.js/Express/Next.js) | Practical N+1 prevention; Redis caching decorator pattern; service layer examples |
| [VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents) | — | API Designer subagent | Most thorough API design phases; weighted scoring model; cross-agent collaboration |
| [Bikach/skills-claude-code](https://github.com/Bikach/skills-claude-code) | — | Security Guardian | 9-domain audit methodology; severity classification; OWASP-aligned |
| [PatrickJS/awesome-cursorrules](https://github.com/PatrickJS/awesome-cursorrules) | — | Cursor rules for TypeScript/Node.js | Coding conventions; framework-specific patterns |

---

## By Capability

### API Design

**Best step design** (from Jeffallan/api-designer — 6 steps):
1. **Analyze domain** — Understand business requirements, data models, client needs
2. **Model resources** — Identify resources, relationships, operations; sketch entity diagram BEFORE writing spec
3. **Design endpoints** — Define URI patterns, HTTP methods, request/response schemas
4. **Specify contract** — Create OpenAPI 3.1 spec; validate: `npx @redocly/cli lint openapi.yaml`
5. **Mock and verify** — Spin up mock server: `npx @stoplight/prism-cli mock openapi.yaml`
6. **Plan evolution** — Design versioning, deprecation, backward-compatibility strategy

**Best frameworks referenced**:
- **Richardson Maturity Model** (Level 0-3 for REST maturity assessment)
- **OpenAPI 3.1** as the single source of truth for API contracts
- **RFC 7807 Problem Details** for standardized error responses (`application/problem+json`)
- **JSON:API** specification for response structure consistency
- **HATEOAS / HAL** (Hypertext Application Language) for API discoverability
- **HTTP Semantics** (RFC 9110) for method/status code correctness

**Quality standards** (output checklist from Jeffallan/api-designer):
1. Resource model and relationships (diagram or table)
2. Endpoint specifications with URIs and HTTP methods
3. OpenAPI 3.1 specification (YAML) — must pass `npx @redocly/cli lint`
4. Authentication and authorization flows documented
5. Error response catalog — all 4xx/5xx with stable `type` URIs
6. Pagination and filtering patterns defined
7. Versioning and deprecation strategy documented
8. Mock server operational via Prism

**Scoring model** (from VoltAgent/api-designer — weighted):
- Consistency Analysis: 30%
- Documentation Quality: 20%
- Security Implementation: 20%
- Usability Design: 15%
- Performance Patterns: 15%

**Anti-patterns**:
- Verbs in resource URIs (`/getUser/{id}` instead of `/users/{id}`)
- Inconsistent response structures across endpoints
- Missing error code documentation
- Ignoring HTTP status code semantics (e.g., returning 200 for errors)
- No versioning strategy from day one
- Exposing implementation details in API surface (DB column names, stack traces)
- Creating breaking changes without migration path
- Omitting rate limiting considerations
- Deep nesting hierarchies (max 2-3 levels)
- Action parameters in GET (`?action=delete`)

**REST conventions** (comprehensive, from Jeffallan/references/rest-patterns.md):
- Resource-oriented: nouns not verbs, plural collections
- Naming: lowercase with hyphens (`/shipping-addresses`)
- Methods: GET (safe+idempotent), POST (create, not idempotent), PUT (full replace, idempotent), PATCH (partial), DELETE (idempotent)
- Status codes: 200/201/202/204 for success; 301/304 for redirects; 400/401/403/404/409/422/429 for client errors; 500/502/503/504 for server errors
- Idempotency: Use `Idempotency-Key` header for non-idempotent POST operations
- Caching: `Cache-Control`, `ETag`, `Last-Modified` headers; conditional requests via `If-None-Match`/`If-Match`
- Content negotiation: `Accept`/`Content-Type` headers

---

### Database Design

**Best step design** (from alirezarezvani/database-schema-designer):
1. **Requirements to Entities** — Extract distinct business objects from requirements narrative
2. **Identify Relationships** — Map cardinality (1:1, 1:N, M:N); design junction tables for M:N
3. **Add Cross-cutting Concerns**:
   - Multi-tenancy: `organization_id` on tenant-scoped tables
   - Soft deletes: `deleted_at TIMESTAMPTZ`
   - Audit trail: `created_by`, `updated_by`, `created_at`, `updated_at`
   - Versioning: `version INTEGER` for optimistic locking
4. **Generate Schema** — SQL migrations via Drizzle/Prisma/TypeORM/Alembic
5. **Generate Types** — TypeScript interfaces or Python Pydantic models
6. **Apply RLS** — Row-Level Security policies for multi-tenancy
7. **Create Indexes** — Composite, partial, covering indexes based on query patterns
8. **Generate Seed Data** — Realistic test data using faker, parents before children
9. **Generate ERD** — Mermaid diagram for documentation

**Best frameworks**:
- **Normalization to 3NF/BCNF** — Normalize first, denormalize only with measured query justification
- **Expand-Contract Pattern** for zero-downtime migrations (4 phases: Expand, Migrate Data, Transition, Contract)
- **EXPLAIN ANALYZE** for query plan reading (key signals: Seq Scan on large tables, Nested Loop with high estimates, Buffers shared read >> hit)
- **Connection pooling rule of thumb**: `(2 * CPU cores) + disk spindles`

**Index strategy** (from alirezarezvani/database-designer):

| Index Type | Use Case |
|------------|----------|
| B-tree (default) | Equality, range, ORDER BY |
| GIN | Full-text search, JSONB, arrays |
| GiST | Geometry, range types, nearest-neighbor |
| Partial | Subset of rows (reduce index size) |
| Covering (INCLUDE) | Index-only scans |

**Quality standards**:
- Every table has `created_at` and `updated_at` timestamps
- Every foreign key has both a constraint AND an index
- Nullable columns reviewed — NOT NULL unless business reason for null
- Unique business rules enforced at database level (not just application)
- UUIDs/CUIDs as PKs to prevent integer leakage
- RLS at database level, not application level
- Soft deletes for auditable data with partial index on `deleted_at IS NULL`
- Migration scripts always reversible (up.sql + down.sql)
- Audit logs with before/after JSON for compliance

**Supabase Postgres rules** (34 rules across 8 categories, impact-prioritized):

| Priority | Category | Rules |
|----------|----------|-------|
| CRITICAL | Query Performance | missing-indexes, composite-indexes, covering-indexes, partial-indexes, index-types |
| CRITICAL | Connection Management | pooling, limits, idle-timeout, prepared-statements |
| CRITICAL | Security & RLS | privileges, rls-basics, rls-performance |
| HIGH | Schema Design | constraints, data-types, foreign-key-indexes, lowercase-identifiers, partitioning, primary-keys |
| MEDIUM-HIGH | Concurrency & Locking | advisory, deadlock-prevention, short-transactions, skip-locked |
| MEDIUM | Data Access Patterns | batch-inserts, n-plus-one, pagination, upsert |
| LOW-MEDIUM | Monitoring | explain-analyze, pg-stat-statements, vacuum-analyze |
| LOW | Advanced Features | full-text-search, jsonb-indexing |

**Multi-DB decision matrix** (from alirezarezvani/database-designer):
- **PostgreSQL** — Default for new projects; best extensibility, JSONB, standards compliance
- **MySQL** — Existing MySQL ecosystem; simple read-heavy web apps
- **SQLite** — Mobile apps, CLI tools, unit test DBs, IoT/edge
- **SQL Server** — Mandated enterprise; deep .NET/Azure integration
- **MongoDB** — Schema flexibility, rapid prototyping, content management
- **Redis** — Session store, rate limiting, leaderboards, pub/sub
- **DynamoDB** — Serverless AWS, single-digit-ms latency at any scale
- Rule: **Use SQL as default. Reach for NoSQL only when access patterns clearly benefit.**

**Anti-patterns / Common pitfalls**:
- Soft deletes without indexes → full table scans
- Mutable PKs (email/slug) → data exposure risk
- NOT NULL additions to existing tables without migration planning
- Concurrent updates without optimistic locking (version column)
- RLS tested only with superuser roles (must test with non-superuser)
- `SELECT *` instead of selecting only needed columns
- N+1 queries: fetching related records in loops instead of JOINs/batch
- Missing indexes on foreign key columns
- No connection pooling (pool size: `2 * vCPUs` for cloud SSDs)
- Ignoring EXPLAIN ANALYZE output

---

### Authentication & Authorization

**Best step design** (synthesized from auth0/agent-skills + Security Guardian):
1. **Detect framework** — Auto-detect stack, route to framework-specific patterns
2. **Configure provider** — Set up Auth0/Supabase Auth/custom; create application
3. **Implement login/logout flows** — OAuth 2.0 + PKCE for SPAs; session-based for server apps
4. **Protect routes** — Server-side middleware for authenticated endpoints
5. **Implement RBAC** — Role-based access control with claim-based authorization
6. **Add MFA** — Step-up authentication with `acr_values`; support TOTP/SMS/Email/Push/WebAuthn
7. **Configure token management** — Short-lived access tokens + refresh token rotation
8. **Test with non-admin roles** — Verify least privilege works correctly

**Best frameworks**:
- **OAuth 2.0 + PKCE** — Required for SPAs (no client secret in browser)
- **OpenID Connect (OIDC)** — Identity layer on top of OAuth 2.0
- **JWT** with short expiration + refresh tokens for APIs
- **OWASP Authentication Cheat Sheet** — Password hashing, session management
- **RBAC / ABAC** — Role-Based and Attribute-Based Access Control models
- **Zero Trust Architecture** — Continuous verification, no implicit trust

**Quality standards** (from OWASP + Security Guardian):
- All pages/resources require authentication except explicitly public ones
- Authentication failures don't reveal which credential was incorrect
- Passwords hashed server-side with cryptographically strong one-way salted hashes
- Session identifiers generated on trusted system with sufficient randomness
- Cookies set with `Secure`, `HttpOnly`, and `SameSite` attributes
- Logout fully terminates session/connection
- Session inactivity timeout as short as business allows
- New session identifier on re-authentication (prevent session fixation)
- Token refresh implemented with rotation (old tokens invalidated)
- Multi-Factor Authentication for sensitive/high-value accounts
- Access controls fail securely (deny by default)
- Re-authenticate before critical operations
- Rate limiting on authentication endpoints

**Auth0 framework coverage** (production-ready skills):

| Category | Frameworks |
|----------|-----------|
| Frontend SPAs | React, Vue.js, Angular |
| Backend/Web | Next.js, Nuxt, Express, Fastify, Rails, Laravel, Flask, Django, Spring Boot, ASP.NET Core, Go |
| Mobile | React Native, Expo, Android (Kotlin), iOS (Swift) |
| APIs | Express, Fastify, FastAPI, Django REST, Go, Spring Boot |

**Migration patterns** (from auth0/agent-skills):
- User export from legacy providers (Firebase, Cognito, etc.)
- Bulk import with password hash support
- Gradual migration strategies for production
- JWT validation updates for migrating applications

**Anti-patterns**:
- Skipping OAuth state validation → CSRF session hijacking
- Storing tokens in localStorage → XSS theft (use httpOnly cookies)
- Long-lived access tokens without refresh mechanism
- Hardcoded secrets in code (must use vaults/env stores)
- Client-side only authentication checks
- Generic error messages that don't help debugging but DO leak info
- Trusting client-provided role/permission claims without server validation
- Missing brute-force protection on login endpoints
- Session identifiers in URLs, error messages, or logs

---

### Business Logic (Service Layer Patterns)

**Best step design** (from affaan-m/backend-patterns):
1. **Repository Pattern** — Abstract ALL data access behind interfaces
   - Methods: `findAll()`, `findById()`, `create()`, `update()`, `delete()`
   - Repositories handle database operations exclusively
2. **Service Layer** — Separate business logic from data access
   - Services use repositories, contain domain-specific operations
   - Orchestrate multiple repository calls (e.g., `searchMarkets()`)
3. **Middleware Pattern** — Request/response processing pipeline
   - Cross-cutting concerns: authentication, validation, logging
   - Functions wrap handlers, execute before reaching business logic
4. **Transaction Pattern** — Group multiple operations atomically
   - Use database RPC functions for all-or-nothing execution
   - Automatic rollback on errors
5. **Caching Layer** — Decorator pattern wrapping repositories
   - Cache-aside: check cache → fetch DB on miss → update cache
   - TTL-based expiration via Redis

**Quality standards**:
- Business rules live in service layer, never in controllers or repositories
- All multi-step operations wrapped in transactions
- Validation at service boundary (before DB operations)
- Domain events emitted for cross-cutting concerns
- Retry logic with exponential backoff for external calls
- Circuit breaker for downstream service failures

**Anti-patterns**:
- Business logic in controllers (fat controllers)
- Direct DB queries in route handlers
- Coupling business rules to specific ORM/database
- No transaction boundaries for multi-step operations
- Synchronous external calls without timeout/retry

---

### API Documentation

**Best step design** (synthesized from Jeffallan/api-designer + VoltAgent):
1. **Write OpenAPI 3.1 spec** — YAML format, single source of truth
2. **Validate spec** — `npx @redocly/cli lint openapi.yaml`
3. **Generate interactive docs** — Redoc, Swagger UI, or Stoplight
4. **Create mock server** — `npx @stoplight/prism-cli mock openapi.yaml`
5. **Generate SDK** — Auto-generate client libraries from spec
6. **Maintain changelog** — Track breaking/non-breaking changes per version

**Required OpenAPI components** (from alirezarezvani/api-design-reviewer):
- API information (title, description, version)
- Server information (base URLs for each environment)
- Path definitions (all endpoints with all methods)
- Parameter definitions (query, path, header, cookie)
- Request/response schemas with `$ref` to shared components
- Security definitions (Bearer, API Key, OAuth)
- Error responses for every endpoint
- Examples for complex request/response objects

**Quality standards**:
- Every endpoint has request/response examples
- Error responses documented with specific `type` URIs
- Authentication guide included
- Rate limit documentation with headers explained
- Webhook specifications with payload schemas
- SDK usage examples per supported language
- Deprecation notices with sunset dates

**Anti-patterns**:
- Spec diverges from implementation (no CI validation)
- Missing error response documentation
- No examples for complex nested objects
- Undocumented query parameters
- API changelog not maintained

---

### Data Seeding & Test Fixtures

**Best step design** (from alirezarezvani/database-schema-designer):
1. **Establish parent entities first** — Respect foreign key constraints
2. **Use faker libraries** — Generate realistic data (names, emails, dates)
3. **Batch inserts** — Bulk insert for performance
4. **Seed deterministically** — Fixed seed value for reproducible test data
5. **Cover edge cases** — Include boundary values, null-allowed fields, unicode

**Quality standards**:
- Seed data respects all constraints (FK, unique, check)
- Covers all enum values and status states
- Includes "unhappy path" data (expired tokens, deleted users, locked accounts)
- Seed scripts idempotent (safe to run multiple times)
- Separate seed profiles: minimal (dev), realistic (staging), stress (load test)

**Anti-patterns**:
- Hardcoded IDs that conflict with auto-increment
- Seed data violating business rules
- Non-deterministic seeds causing flaky tests
- Missing referential integrity in seed order

---

### Error Handling

**Best step design** (from Jeffallan/api-designer/references/error-handling.md):
1. **Choose format** — RFC 7807 Problem Details (`application/problem+json`)
2. **Define error catalog** — All error codes with stable `type` URIs
3. **Implement field-level validation errors** — `errors[]` array with field, code, message, constraints
4. **Add request tracking** — `X-Request-ID` header in every response
5. **Implement rate limiting response** — 429 with `Retry-After`, `X-RateLimit-*` headers
6. **Classify retryability** — Retryable (429, 503, 5xx) vs non-retryable (400, 401, 403, 404, 409)

**RFC 7807 template**:
```json
{
  "type": "https://api.example.com/errors/resource-not-found",
  "title": "Resource Not Found",
  "status": 404,
  "detail": "User with ID 123 does not exist",
  "instance": "/users/123",
  "errors": []
}
```

**Error code catalog** (standardized):

| Category | Codes |
|----------|-------|
| Validation (400) | REQUIRED, INVALID_FORMAT, OUT_OF_RANGE, INVALID_ENUM |
| Authentication (401) | MISSING_TOKEN, INVALID_TOKEN, EXPIRED_TOKEN, REVOKED_TOKEN |
| Authorization (403) | INSUFFICIENT_PERMISSIONS, RESOURCE_FORBIDDEN |
| Conflict (409) | RESOURCE_ALREADY_EXISTS, CONCURRENT_MODIFICATION |
| Rate Limit (429) | RATE_LIMIT_EXCEEDED |

**Quality standards**:
- `type` field is stable, documented URI (never generic string)
- `detail` is human-readable AND actionable
- Field-level validation errors include constraint details
- Cross-field validation uses `fields` array
- Server errors return generic message (never stack traces, DB errors, file paths)
- Every error response includes `requestId` and `timestamp`
- Rate limit responses include `Retry-After` header

**Anti-patterns**:
- Returning 200 OK with error in body
- Inconsistent error format across endpoints
- Stack traces or DB errors in production responses
- Generic "Something went wrong" without request ID
- Missing retry guidance for 5xx errors
- Error codes that are just HTTP status codes (not domain-specific)

---

### Security (Backend-Specific)

**Best audit methodology** (from Bikach/security-guardian — 9 domains):
1. **Vulnerability Analysis** — SQL/NoSQL injection, XSS, CSRF, XXE, command injection, path traversal, SSRF
2. **Authentication & Authorization** — Password security, session/token management, OAuth/MFA, RBAC/ABAC, brute-force, IDOR, privilege escalation
3. **Cryptography** — Algorithm review, hashing, key management, TLS config, secure random
4. **Secrets Management** — Hardcoded secret detection, env variable usage, vault integration, rotation
5. **Input Validation** — Sanitization, escaping, whitelist/blacklist, file upload, deserialization
6. **API Security** — Rate limiting, CORS, GraphQL depth/complexity limits, versioning
7. **Data Protection** — PII handling, GDPR compliance, encryption at rest/in transit, secure deletion
8. **Logging & Monitoring** — Logs exclude sensitive data, audit trails, security alerting
9. **Dependency Security** — Up-to-date libraries, vulnerability scanning

**Severity classification**:
- **Critical**: Arbitrary code execution, unauthorized data access, privilege escalation, secret exposure
- **High**: SQL/NoSQL injection, stored XSS, weak auth, sensitive data leaks
- **Medium**: Reflected XSS, CSRF, insufficient validation, weak TLS
- **Low**: Minor info disclosure, excessive logging, outdated non-critical deps

**OWASP Secure Coding Checklist** (key items for backend):

| Category | Critical Items |
|----------|----------------|
| Input Validation | Server-side validation only; allow-list over deny-list; centralized routine; canonicalize before validate |
| Output Encoding | Context-specific encoding; sanitize for SQL/XML/LDAP/OS commands |
| Authentication | Hash passwords server-side; POST for credentials; fail securely; no info leak on failure |
| Session | Server-generated IDs; new ID on auth; HttpOnly+Secure cookies; full session termination on logout |
| Access Control | Single site-wide authorization component; fail secure; deny if config unavailable |
| Cryptography | Trusted system only; FIPS 140-2 modules; approved RNG |
| Error Handling | No sensitive data in errors; generic error pages; deny access by default on error |
| Database | Parameterized queries ALWAYS; least privilege; close connections ASAP; disable default accounts |
| Logging | Log all auth attempts, access control failures, input validation failures; never log sensitive data |

**Foundational principles** (from Security Guardian):
- **Defense in Depth**: Layered controls, no single-point failure
- **Least Privilege**: Minimal necessary permissions
- **Fail Secure**: Error conditions default to denial
- **Security by Design**: Build in from architecture, don't retrofit
- **Zero Trust**: Continuous verification, no implicit trust

---

### Pagination

**Strategy comparison** (from Jeffallan/api-designer/references/pagination.md):

| Feature | Offset | Page | Cursor | Keyset |
|---------|--------|------|--------|--------|
| Performance | Poor (large offsets) | Poor | Excellent | Excellent |
| Random Access | Yes | Yes | No | No |
| Total Count | Yes | Yes | No | Optional |
| Real-time Data | Poor | Poor | Excellent | Excellent |
| DB Load | High | High | Low | Low |
| Complexity | Simple | Simple | Medium | Medium |

**Recommendations**:
- **Default choice**: Cursor-based pagination for APIs with large/changing datasets
- **Offset-based**: Only for admin panels where random page access needed
- **Keyset**: When transparency matters (human-readable cursor values)
- **Config**: Default limit 20-50, max limit 100-1000, return 400 for invalid

**Universal rules**:
1. Always paginate collections — never return unbounded lists
2. Provide `has_more` flag
3. Include navigation links (first, prev, next, last)
4. Apply filters before pagination
5. Support sorting on paginated results
6. Include sort fields in cursor structure

---

### API Versioning

**Strategy recommendation** (from Jeffallan/references/versioning.md):
- **URI versioning recommended** (`/v1/users`, `/v2/users`) — most explicit and discoverable
- Major versions only (`v1`, `v2`) — no minor versions in URI
- Support at least 2 versions simultaneously
- 6-12 month deprecation period before sunset
- Return `410 Gone` after sunset date
- Version from day one (avoid unversioned `/api` paths)

**Breaking vs non-breaking changes**:
- **Breaking** (require new version): removing fields, type changes, restructuring, removing endpoints
- **Non-breaking** (safe to add): new endpoints, optional request fields, new response fields, new enum values

**Lifecycle**: Introduction → Deprecation (6+ months, `Deprecation: true` header) → Sunset (`410 Gone`) → Removal

---

## Cross-Cutting Patterns

### TypeScript/Node.js Backend Conventions (from PatrickJS/awesome-cursorrules)
- Functional and declarative patterns; avoid classes
- Prefer interfaces over types; avoid enums, use maps
- Descriptive variable names with auxiliary verbs (`isLoading`, `hasError`)
- Lowercase with dashes for directories (`components/auth-wizard`)
- Named exports for components
- `function` keyword for pure functions

### Caching Strategies (from affaan-m/backend-patterns)
- **Cache-Aside**: App checks cache → DB on miss → update cache
- **Redis decorator pattern**: Wrap repository methods with cache layer
- **TTL-based expiration**: Set appropriate TTL per data volatility
- **Cache invalidation**: Invalidate on write operations

### Background Jobs (from affaan-m/backend-patterns)
- Queue-based async processing for long-running operations
- Retry with exponential backoff
- Dead letter queue for permanently failed jobs
- Structured logging for job lifecycle

---

## Synthesis: What Makes a Great Backend Skill

### Structure pattern (observed across all high-quality skills):
1. **When to activate** — Clear trigger conditions
2. **Step-by-step workflow** — Numbered, actionable steps
3. **Reference materials** — Linked docs for deep dives
4. **MUST DO / MUST NOT DO** — Explicit constraints
5. **Templates** — Ready-to-use code/config templates
6. **Output checklist** — Verification criteria for "done"
7. **Tool commands** — Specific CLI commands to validate (e.g., `npx @redocly/cli lint`)

### Best practices for skill design:
- **Impact-prioritized categories** (Supabase pattern: CRITICAL → LOW)
- **Correct + incorrect examples** per rule (Supabase pattern: bad SQL → good SQL)
- **Weighted scoring model** for quality assessment (VoltAgent pattern)
- **Severity classification** for findings (Security Guardian pattern: Critical/High/Medium/Low/Info)
- **Cross-references to related skills** for workflow integration
- **Framework-specific variants** where implementation differs (Auth0 pattern)

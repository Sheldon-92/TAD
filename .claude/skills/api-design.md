# API Design Skill

---
title: "API Design"
version: "3.0"
last_updated: "2026-01-06"
tags: [api, rest, graphql, openapi, design, engineering, backend]
domains: [backend, web, mobile, integration]
level: intermediate
estimated_time: "45min"
prerequisites: [http-basics, json]
sources:
  - "RESTful Web APIs - O'Reilly"
  - "OpenAPI Specification 3.1"
  - "Google API Design Guide"
  - "Microsoft REST API Guidelines"
  - "RFC 7807 - Problem Details for HTTP APIs"
enforcement: recommended
tad_gates: [Gate2_Design_Completeness, Gate3_Interface_Verification]
---

## TL;DR Quick Checklist

```
1. [ ] Resources use nouns (plural), not verbs
2. [ ] HTTP methods match operations (GET=read, POST=create, PUT=replace, PATCH=update, DELETE=remove)
3. [ ] Status codes correct + RFC 7807 error format
4. [ ] Version strategy defined (URL path `/v1/` recommended)
5. [ ] Idempotency-Key for non-idempotent operations
```

**Red Flags:**
- `/getUsers` instead of `/users`
- Using POST for everything
- Returning 200 for errors
- No pagination for lists (> 50 items)
- Missing `Idempotency-Key` on payment APIs
- No deprecation policy

---

## Overview

This skill guides the design of RESTful and GraphQL APIs following industry best practices, with emphasis on versioning, idempotency, rate limiting, and proper error handling.

**Core Principle:** "A good API is like a good joke - it doesn't need explanation."

**Key Standards:**
- REST: Richardson Maturity Model Level 3 (HATEOAS optional)
- Errors: RFC 7807 Problem Details
- Documentation: OpenAPI 3.1 / GraphQL SDL
- Security: OAuth 2.0 / JWT / API Keys with scopes

---

## Triggers

| Trigger | Context | Action | Gate |
|---------|---------|--------|------|
| New API endpoint | Alex designing features | Apply REST/GraphQL patterns | Gate2 |
| API review | Code review | Validate against checklist | Gate3 |
| Documentation | Blake implementing | Generate OpenAPI spec | Gate2 |
| Integration | External service | Design contract | Gate2 |
| Version change | Breaking changes | Create migration plan | Gate4 |
| Deprecation | Old endpoints | Define sunset schedule | Gate4 |

**MQ6 Triggers:**
- "API design patterns for [domain]"
- "REST vs GraphQL tradeoffs"
- "Rate limiting strategies"

---

## Inputs

- Feature requirements and use cases
- Data models / Domain entities
- Authentication requirements (OAuth scopes, API keys)
- Rate limiting needs (requests/second, quotas)
- Versioning strategy (major versions only)
- Consumer types (web, mobile, third-party)
- SLA requirements (latency, availability)

---

## Outputs / Evidence / Acceptance

### Required Evidence

| Evidence Type | Description | Location | Format |
|---------------|-------------|----------|--------|
| `api_spec` | OpenAPI 3.1 / GraphQL schema | `docs/api/openapi.yaml` | YAML/SDL |
| `endpoint_list` | Endpoints with methods + auth | Design document | Markdown table |
| `error_codes` | Error code catalog | `docs/api/errors.md` | RFC 7807 |
| `schema_diff` | Changes from previous version | PR description | Diff |
| `request_response_samples` | Example payloads | OpenAPI examples | JSON |
| `security_review` | Auth/authz verification | Security checklist | Checklist |

### Acceptance Criteria

```
[ ] All endpoints follow REST conventions
[ ] HTTP methods used correctly (idempotent where required)
[ ] Status codes appropriate for each response (RFC 7807)
[ ] Error format consistent across API
[ ] Pagination implemented (offset OR cursor, not mixed)
[ ] Authentication documented with scopes
[ ] Rate limits specified (X-RateLimit-* headers)
[ ] Versioning strategy applied consistently
[ ] Deprecation warnings for old endpoints
[ ] OpenAPI spec validates without errors
```

### Artifacts

| Artifact | Path | Template |
|----------|------|----------|
| OpenAPI Spec | `docs/api/openapi.yaml` | See below |
| Error Catalog | `docs/api/errors.md` | RFC 7807 |
| API Changelog | `docs/api/CHANGELOG.md` | Keep a Changelog |
| Migration Guide | `docs/api/migration-v{N}.md` | Breaking changes |

---

## Procedure

### Step 1: Resource Design

**URL Structure:**
```
✅ Correct                    ❌ Wrong
/users                        /getUsers
/users/123                    /user/123
/users/123/orders             /getUserOrders?userId=123
/orders/456/items             /orderItems/456
/users/123/avatar             /uploadUserAvatar
```

**Rules:**
- Use nouns, not verbs
- Use plural forms consistently
- Use kebab-case for multi-word resources (`/user-profiles`)
- Max 2 levels of nesting (otherwise use query params or links)
- Actions on resources: `POST /users/123/actions/disable`

### Step 2: HTTP Methods & Idempotency

| Method | Purpose | Idempotent | Safe | Request Body | Idempotency-Key |
|--------|---------|------------|------|--------------|-----------------|
| GET | Read resource | Yes | Yes | No | No |
| POST | Create resource | No | No | Yes | **Required** |
| PUT | Full replace | Yes | No | Yes | Optional |
| PATCH | Partial update | No | No | Yes | Recommended |
| DELETE | Remove resource | Yes | No | No | No |
| HEAD | Get headers | Yes | Yes | No | No |
| OPTIONS | Get allowed methods | Yes | Yes | No | No |

**Idempotency-Key Implementation:**
```http
POST /api/v1/payments HTTP/1.1
Content-Type: application/json
Idempotency-Key: 550e8400-e29b-41d4-a716-446655440000

{
  "amount": 10000,
  "currency": "USD"
}
```

```typescript
// Server-side handling
async function handlePayment(req: Request) {
  const idempotencyKey = req.headers['idempotency-key'];

  // Check cache first
  const cached = await cache.get(`idempotency:${idempotencyKey}`);
  if (cached) {
    return cached; // Return same response
  }

  // Process payment
  const result = await processPayment(req.body);

  // Cache for 24 hours
  await cache.set(`idempotency:${idempotencyKey}`, result, 86400);
  return result;
}
```

### Step 3: Status Codes (Complete Reference)

```
2xx Success
├── 200 OK - Request succeeded (GET, PUT, PATCH, DELETE)
├── 201 Created - Resource created (POST) + Location header
├── 202 Accepted - Async processing started
├── 204 No Content - Success, no body (DELETE)

3xx Redirection
├── 301 Moved Permanently - Resource moved (update bookmarks)
├── 304 Not Modified - Cached response valid

4xx Client Error
├── 400 Bad Request - Invalid syntax / malformed JSON
├── 401 Unauthorized - Not authenticated (missing/invalid token)
├── 403 Forbidden - Authenticated but no permission
├── 404 Not Found - Resource doesn't exist
├── 405 Method Not Allowed - Wrong HTTP method
├── 406 Not Acceptable - Can't satisfy Accept header
├── 409 Conflict - Resource state conflict (optimistic locking)
├── 410 Gone - Resource deleted permanently
├── 415 Unsupported Media Type - Wrong Content-Type
├── 422 Unprocessable Entity - Validation failed (semantic errors)
├── 429 Too Many Requests - Rate limited

5xx Server Error
├── 500 Internal Server Error - Unexpected server failure
├── 501 Not Implemented - Feature not available
├── 502 Bad Gateway - Upstream service failed
├── 503 Service Unavailable - Temporary overload/maintenance
├── 504 Gateway Timeout - Upstream timeout
```

### Step 4: Error Format (RFC 7807)

**Standard Error Response:**
```json
{
  "type": "https://api.example.com/errors/validation-error",
  "title": "Validation Error",
  "status": 422,
  "detail": "The request body contains invalid fields",
  "instance": "/api/v1/users/123",
  "timestamp": "2024-01-06T10:00:00Z",
  "traceId": "abc123",
  "errors": [
    {
      "field": "email",
      "code": "INVALID_FORMAT",
      "message": "Email must be a valid email address"
    },
    {
      "field": "age",
      "code": "OUT_OF_RANGE",
      "message": "Age must be between 0 and 150"
    }
  ]
}
```

**Error Catalog Template:**
```markdown
| Type | Status | Code | Description |
|------|--------|------|-------------|
| /errors/validation-error | 422 | VALIDATION_ERROR | Request validation failed |
| /errors/not-found | 404 | RESOURCE_NOT_FOUND | Resource doesn't exist |
| /errors/unauthorized | 401 | INVALID_TOKEN | Token missing or invalid |
| /errors/forbidden | 403 | INSUFFICIENT_SCOPE | Token lacks required scope |
| /errors/rate-limited | 429 | RATE_LIMIT_EXCEEDED | Too many requests |
| /errors/conflict | 409 | RESOURCE_CONFLICT | Optimistic lock failed |
```

### Step 5: Versioning Strategies

| Strategy | Example | Pros | Cons | Recommendation |
|----------|---------|------|------|----------------|
| **URL Path** | `/v1/users` | Clear, cacheable, easy to route | URL changes | **Recommended** |
| Query Param | `/users?version=1` | Flexible | Easy to forget, cache issues | Not recommended |
| Header | `Accept: application/vnd.api+json;v=1` | Clean URLs | Hard to test/debug | Enterprise only |
| Media Type | `Accept: application/vnd.api.v1+json` | RESTful purist | Complex | Not recommended |

**Versioning Rules:**
- Only increment major version for **breaking changes**
- Non-breaking changes (new fields, new endpoints) don't need new version
- Support N-1 versions minimum (v1 + v2)
- Deprecation notice: 6 months minimum

**Deprecation Headers:**
```http
HTTP/1.1 200 OK
Deprecation: Sun, 01 Jun 2025 00:00:00 GMT
Sunset: Sun, 01 Dec 2025 00:00:00 GMT
Link: <https://api.example.com/v2/users>; rel="successor-version"
```

### Step 6: Rate Limiting & Quotas

**Rate Limit Headers:**
```http
HTTP/1.1 200 OK
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1609459200
Retry-After: 60
```

**Rate Limit Response (429):**
```json
{
  "type": "https://api.example.com/errors/rate-limited",
  "title": "Rate Limit Exceeded",
  "status": 429,
  "detail": "You have exceeded the rate limit of 1000 requests per hour",
  "retryAfter": 60
}
```

**Rate Limiting Strategies:**
| Strategy | Use Case | Implementation |
|----------|----------|----------------|
| Fixed Window | Simple rate limiting | Redis INCR + EXPIRE |
| Sliding Window | Smoother limits | Redis sorted sets |
| Token Bucket | Burst-friendly | Redis + Lua script |
| Leaky Bucket | Constant rate | Queue-based |

**Quota Tiers:**
```yaml
tiers:
  free:
    requests_per_hour: 100
    requests_per_day: 1000
  pro:
    requests_per_hour: 10000
    requests_per_day: 100000
  enterprise:
    requests_per_hour: unlimited
    requests_per_day: unlimited
```

### Step 7: Pagination (Two Patterns)

**Pattern A: Offset Pagination (Simple)**
```http
GET /users?page=2&pageSize=20

Response:
{
  "data": [...],
  "pagination": {
    "page": 2,
    "pageSize": 20,
    "total": 100,
    "totalPages": 5
  }
}
```
- ✅ Jump to any page
- ✅ Easy to implement
- ❌ Inconsistent on updates
- ❌ Poor performance on large offsets

**Pattern B: Cursor Pagination (Scalable)**
```http
GET /users?cursor=eyJpZCI6MTAwfQ&limit=20

Response:
{
  "data": [...],
  "pagination": {
    "nextCursor": "eyJpZCI6MTIwfQ",
    "prevCursor": "eyJpZCI6ODB9",
    "hasMore": true
  }
}
```
- ✅ Consistent results
- ✅ O(1) performance
- ❌ Cannot jump to page
- ❌ More complex

**When to Use:**
| Scenario | Recommendation |
|----------|----------------|
| Small datasets (< 10K) | Offset |
| Large datasets (> 100K) | Cursor |
| Real-time feeds | Cursor |
| Admin dashboards | Offset |
| Mobile apps | Cursor |

### Step 8: Authentication & Authorization

**OAuth 2.0 Scopes:**
```yaml
scopes:
  users:read: Read user profiles
  users:write: Create and update users
  users:delete: Delete users
  orders:read: Read orders
  orders:write: Create and update orders
  admin: Full administrative access
```

**Endpoint Authorization:**
```yaml
/users:
  GET:
    scopes: [users:read]
  POST:
    scopes: [users:write]

/users/{id}:
  GET:
    scopes: [users:read]
  PUT:
    scopes: [users:write]
  DELETE:
    scopes: [users:delete, admin]
```

**Authorization Response (403):**
```json
{
  "type": "https://api.example.com/errors/forbidden",
  "title": "Forbidden",
  "status": 403,
  "detail": "Token lacks required scope: users:delete",
  "requiredScopes": ["users:delete", "admin"]
}
```

---

## GraphQL Section

### Schema Design

```graphql
type User {
  id: ID!
  name: String!
  email: String!
  orders(first: Int, after: String): OrderConnection!
  createdAt: DateTime!
  updatedAt: DateTime!
}

type Query {
  user(id: ID!): User
  users(first: Int, after: String, filter: UserFilter): UserConnection!
}

type Mutation {
  createUser(input: CreateUserInput!): CreateUserPayload!
  updateUser(id: ID!, input: UpdateUserInput!): UpdateUserPayload!
  deleteUser(id: ID!): DeleteUserPayload!
}

# Relay-style connections
type UserConnection {
  edges: [UserEdge!]!
  pageInfo: PageInfo!
  totalCount: Int!
}

type UserEdge {
  node: User!
  cursor: String!
}

type PageInfo {
  hasNextPage: Boolean!
  hasPreviousPage: Boolean!
  startCursor: String
  endCursor: String
}

# Input types
input CreateUserInput {
  name: String!
  email: String!
}

# Payload types (for errors)
type CreateUserPayload {
  user: User
  errors: [UserError!]!
}

type UserError {
  field: String!
  message: String!
  code: ErrorCode!
}
```

### N+1 Prevention with DataLoader

```typescript
// ❌ N+1 Problem
const resolvers = {
  User: {
    orders: async (user) => {
      return db.orders.findMany({ where: { userId: user.id } });
    }
  }
};

// ✅ DataLoader Solution
import DataLoader from 'dataloader';

const createLoaders = () => ({
  ordersByUser: new DataLoader(async (userIds: string[]) => {
    const orders = await db.orders.findMany({
      where: { userId: { in: userIds } }
    });

    // Map results back to input order
    return userIds.map(id =>
      orders.filter(order => order.userId === id)
    );
  })
});

const resolvers = {
  User: {
    orders: async (user, _, { loaders }) => {
      return loaders.ordersByUser.load(user.id);
    }
  }
};
```

### Error Handling in GraphQL

```graphql
# Partial failure response
{
  "data": {
    "createOrder": {
      "order": null,
      "errors": [
        {
          "field": "items",
          "message": "Product SKU-123 is out of stock",
          "code": "OUT_OF_STOCK"
        }
      ]
    }
  }
}
```

**Error Boundaries Pattern:**
```typescript
const resolvers = {
  Mutation: {
    createOrder: async (_, { input }) => {
      try {
        const order = await orderService.create(input);
        return { order, errors: [] };
      } catch (error) {
        if (error instanceof ValidationError) {
          return {
            order: null,
            errors: error.details.map(d => ({
              field: d.field,
              message: d.message,
              code: 'VALIDATION_ERROR'
            }))
          };
        }
        throw error; // Let top-level handler catch
      }
    }
  }
};
```

---

## Checklists

### Design Phase

```
[ ] Resources follow REST naming conventions
[ ] HTTP methods match operations correctly
[ ] Idempotency-Key required for POST operations
[ ] Status codes cover all scenarios
[ ] RFC 7807 error format implemented
[ ] Version strategy documented
[ ] Pagination approach selected (offset OR cursor)
[ ] Rate limits defined per tier
[ ] OAuth scopes defined
```

### Security

```
[ ] HTTPS enforced (HSTS enabled)
[ ] Authentication mechanism documented
[ ] Authorization (scopes) for each endpoint
[ ] Input validation (type, format, range)
[ ] Output encoding (prevent XSS in JSON)
[ ] Rate limiting configured
[ ] CORS properly set
[ ] No sensitive data in URLs
[ ] Audit logging enabled
```

### Documentation

```
[ ] OpenAPI 3.1 spec complete and valid
[ ] Example requests/responses for each endpoint
[ ] Error codes documented with solutions
[ ] Authentication flow explained
[ ] Rate limits documented
[ ] SDK/code samples provided
[ ] Changelog maintained
[ ] Migration guides for breaking changes
```

### Deprecation

```
[ ] Deprecation header added
[ ] Sunset date announced (6+ months)
[ ] Migration guide published
[ ] Successor version linked
[ ] Client notification sent
[ ] Usage monitoring active
```

---

## Anti-patterns

| Anti-pattern | Why Bad | Fix |
|--------------|---------|-----|
| `/getUser/123` | Verb in URL | Use `/users/123` |
| POST for reads | Wrong semantics | Use GET |
| 200 for errors | Hides problems, breaks clients | Use proper status codes |
| Nested >2 levels | Complex URLs, tight coupling | Flatten or use links |
| No versioning | Breaking changes break clients | Add `/v1/` prefix |
| Mixed pagination | Confusing API | Choose one style |
| No Idempotency-Key | Duplicate payments/creates | Require for POST |
| Exposing internal IDs | Security risk | Use UUIDs or slugs |
| No rate limiting | DoS vulnerability | Implement limits |
| Inconsistent errors | Hard to handle | Use RFC 7807 |

---

## Tools / Commands

### OpenAPI Validation & Generation

```bash
# Validate OpenAPI spec
npx @apidevtools/swagger-cli validate docs/api/openapi.yaml

# Lint OpenAPI spec (Spectral)
npx @stoplight/spectral-cli lint docs/api/openapi.yaml

# Generate TypeScript client
npx openapi-generator-cli generate \
  -i docs/api/openapi.yaml \
  -g typescript-fetch \
  -o ./client

# Generate server stubs (NestJS)
npx @nestjs/swagger
```

### API Testing

```bash
# HTTPie (recommended)
http GET localhost:3000/api/v1/users Authorization:"Bearer token"
http POST localhost:3000/api/v1/users name=John email=john@example.com

# curl
curl -X GET http://localhost:3000/api/v1/users \
  -H "Authorization: Bearer token"

# API diff (detect breaking changes)
oasdiff breaking old.yaml new.yaml
```

### Rate Limit Testing

```bash
# Test rate limits with hey
hey -n 1000 -c 100 http://localhost:3000/api/v1/users

# Test with k6
k6 run --vus 100 --duration 30s api-test.js
```

---

## OpenAPI 3.1 Template

```yaml
openapi: 3.1.0
info:
  title: My API
  version: 1.0.0
  description: API description
  contact:
    name: API Support
    email: api@example.com
  license:
    name: MIT

servers:
  - url: https://api.example.com/v1
    description: Production
  - url: https://api.staging.example.com/v1
    description: Staging

security:
  - bearerAuth: []

paths:
  /users:
    get:
      summary: List users
      operationId: listUsers
      tags: [Users]
      parameters:
        - $ref: '#/components/parameters/PageParam'
        - $ref: '#/components/parameters/PageSizeParam'
      responses:
        '200':
          description: Users list
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserListResponse'
        '401':
          $ref: '#/components/responses/Unauthorized'
        '429':
          $ref: '#/components/responses/RateLimited'
    post:
      summary: Create user
      operationId: createUser
      tags: [Users]
      parameters:
        - name: Idempotency-Key
          in: header
          required: true
          schema:
            type: string
            format: uuid
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserRequest'
      responses:
        '201':
          description: User created
          headers:
            Location:
              schema:
                type: string
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '422':
          $ref: '#/components/responses/ValidationError'

components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

  schemas:
    User:
      type: object
      properties:
        id:
          type: string
          format: uuid
        name:
          type: string
        email:
          type: string
          format: email
        createdAt:
          type: string
          format: date-time
      required: [id, name, email, createdAt]

    ProblemDetail:
      type: object
      properties:
        type:
          type: string
          format: uri
        title:
          type: string
        status:
          type: integer
        detail:
          type: string
        instance:
          type: string
        traceId:
          type: string

  responses:
    Unauthorized:
      description: Unauthorized
      content:
        application/problem+json:
          schema:
            $ref: '#/components/schemas/ProblemDetail'

    RateLimited:
      description: Rate limit exceeded
      headers:
        X-RateLimit-Limit:
          schema:
            type: integer
        X-RateLimit-Remaining:
          schema:
            type: integer
        Retry-After:
          schema:
            type: integer
      content:
        application/problem+json:
          schema:
            $ref: '#/components/schemas/ProblemDetail'

    ValidationError:
      description: Validation error
      content:
        application/problem+json:
          schema:
            allOf:
              - $ref: '#/components/schemas/ProblemDetail'
              - type: object
                properties:
                  errors:
                    type: array
                    items:
                      type: object
                      properties:
                        field:
                          type: string
                        code:
                          type: string
                        message:
                          type: string
```

---

## TAD Integration

### Gate Mapping

```yaml
API_Design:
  skill: api-design.md
  enforcement: RECOMMENDED
  triggers:
    - Alex designing API endpoints
    - Blake implementing API layer
    - Code review for API changes
    - External integration design
  gates:
    - Gate2: Design completeness
    - Gate3: Interface verification
    - Gate4: Deprecation planning
  mq_triggers:
    - MQ6: "API design patterns"
    - MQ6: "REST vs GraphQL"
    - MQ6: "Rate limiting strategies"
  evidence_required:
    - api_spec: OpenAPI/GraphQL schema file
    - endpoint_list: Method/path/auth table
    - error_codes: RFC 7807 catalog
    - schema_diff: For version changes
    - request_response_samples: Example payloads
  acceptance:
    - REST conventions followed
    - RFC 7807 error format
    - Idempotency handled
    - Rate limits documented
    - Documentation complete
```

### Evidence Template

```markdown
## API Design Evidence

### Design Summary
- API Style: REST / GraphQL
- Version: v1
- Base URL: `https://api.example.com/v1`

### Endpoints Designed
| Method | Path | Auth | Rate Limit | Description |
|--------|------|------|------------|-------------|
| GET | /users | Bearer (users:read) | 100/min | List users |
| POST | /users | Bearer (users:write) | 20/min | Create user |
| GET | /users/:id | Bearer (users:read) | 100/min | Get user |
| PUT | /users/:id | Bearer (users:write) | 50/min | Update user |
| DELETE | /users/:id | Bearer (users:delete) | 10/min | Delete user |

### Error Codes
| Status | Code | Description |
|--------|------|-------------|
| 422 | VALIDATION_ERROR | Request validation failed |
| 404 | USER_NOT_FOUND | User ID doesn't exist |
| 409 | EMAIL_EXISTS | Email already registered |

### Versioning Strategy
- Style: URL path (`/v1/`, `/v2/`)
- Breaking change policy: New major version
- Deprecation notice: 6 months
- Support window: Current + 1 previous

### Rate Limiting
- Free tier: 100 requests/hour
- Pro tier: 10,000 requests/hour
- Headers: X-RateLimit-Limit, X-RateLimit-Remaining, Retry-After

### OpenAPI Spec
Location: `docs/api/openapi.yaml`
Validation: ✅ Passed (Spectral)

### Security Review
- [ ] OAuth scopes defined
- [ ] Input validation complete
- [ ] Rate limiting configured
- [ ] CORS properly set
```

---

## Related Skills

- `software-architecture.md` - System design context
- `security-checklist.md` - API security requirements (OWASP API Top 10)
- `testing-strategy.md` - API testing approaches
- `error-handling.md` - Error response design patterns
- `performance-optimization.md` - API performance tuning
- `database-patterns.md` - Data layer for API

---

## References

- [RFC 7807 - Problem Details for HTTP APIs](https://tools.ietf.org/html/rfc7807)
- [OpenAPI Specification 3.1](https://spec.openapis.org/oas/latest.html)
- [Google API Design Guide](https://cloud.google.com/apis/design)
- [Microsoft REST API Guidelines](https://github.com/microsoft/api-guidelines)
- [JSON:API Specification](https://jsonapi.org/)
- [GraphQL Best Practices](https://graphql.org/learn/best-practices/)
- [Stripe API Design](https://stripe.com/docs/api)
- [GitHub API Design](https://docs.github.com/en/rest/overview/resources-in-the-rest-api)

---

*This skill guides Claude in designing high-quality APIs following industry standards with emphasis on versioning, idempotency, rate limiting, and proper error handling (RFC 7807).*

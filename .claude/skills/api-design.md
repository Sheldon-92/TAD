# API Design Skill

---
title: "API Design"
version: "2.0"
last_updated: "2026-01-06"
tags: [api, rest, graphql, design, engineering]
domains: [backend, web, mobile]
level: intermediate
estimated_time: "30min"
prerequisites: []
sources:
  - "RESTful Web APIs - O'Reilly"
  - "OpenAPI Specification"
  - "Google API Design Guide"
enforcement: recommended
---

## TL;DR Quick Checklist

```
1. [ ] Resources use nouns (plural), not verbs
2. [ ] HTTP methods match operations (GET=read, POST=create, etc.)
3. [ ] Status codes are correct and consistent
4. [ ] Error responses include code, message, and details
5. [ ] Version strategy defined (URL path recommended)
```

**Red Flags:**
- `/getUsers` instead of `/users`
- Using POST for everything
- Returning 200 for errors
- Inconsistent response formats
- No pagination for lists

---

## Overview

This skill guides the design of RESTful and GraphQL APIs following industry best practices.

**Core Principle:** "A good API is like a good joke - it doesn't need explanation."

---

## Triggers

| Trigger | Context | Action |
|---------|---------|--------|
| New API endpoint | Alex designing features | Apply REST/GraphQL patterns |
| API review | Code review | Validate against checklist |
| Documentation | Blake implementing | Generate OpenAPI spec |
| Integration | External service | Design contract |

---

## Inputs

- Feature requirements
- Data models
- Authentication requirements
- Rate limiting needs
- Versioning strategy

---

## Outputs / Evidence / Acceptance

### Required Evidence

| Evidence Type | Description | Location |
|---------------|-------------|----------|
| `api_spec` | OpenAPI/GraphQL schema | `docs/api/` or inline |
| `endpoint_list` | List of endpoints with methods | Design document |
| `error_codes` | Error code documentation | API docs |

### Acceptance Criteria

```
[ ] All endpoints follow REST conventions
[ ] HTTP methods used correctly
[ ] Status codes appropriate for each response
[ ] Error format consistent across API
[ ] Pagination implemented for list endpoints
[ ] Authentication documented
[ ] Rate limits specified
```

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
```

**Rules:**
- Use nouns, not verbs
- Use plural forms
- Use kebab-case for multi-word resources
- Hierarchy shows relationships

### Step 2: HTTP Methods

| Method | Purpose | Idempotent | Safe |
|--------|---------|------------|------|
| GET | Read resource | Yes | Yes |
| POST | Create resource | No | No |
| PUT | Full update | Yes | No |
| PATCH | Partial update | No | No |
| DELETE | Remove resource | Yes | No |

### Step 3: Status Codes

```
2xx Success
├── 200 OK - Request succeeded
├── 201 Created - Resource created
├── 204 No Content - Success, no body

4xx Client Error
├── 400 Bad Request - Invalid syntax
├── 401 Unauthorized - Not authenticated
├── 403 Forbidden - No permission
├── 404 Not Found - Resource missing
├── 409 Conflict - Resource conflict
├── 422 Unprocessable Entity - Validation failed
├── 429 Too Many Requests - Rate limited

5xx Server Error
├── 500 Internal Server Error
├── 502 Bad Gateway
├── 503 Service Unavailable
```

### Step 4: Request/Response Design

**Single Resource Response:**
```json
{
  "data": {
    "id": "123",
    "name": "John Doe",
    "email": "john@example.com",
    "createdAt": "2024-01-06T10:00:00Z"
  }
}
```

**List Response (with pagination):**
```json
{
  "data": [
    { "id": "1", "name": "User 1" },
    { "id": "2", "name": "User 2" }
  ],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "total": 100,
    "totalPages": 5
  }
}
```

**Error Response:**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "The request body is invalid",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ]
  }
}
```

### Step 5: Versioning

| Strategy | Example | Pros | Cons |
|----------|---------|------|------|
| URL Path | `/v1/users` | Clear, visible | URL changes |
| Query Param | `/users?version=1` | Flexible | Easy to forget |
| Header | `Accept: application/vnd.api+json;v=1` | Clean URLs | Hard to debug |

**Recommended:** URL path versioning (`/api/v1/users`)

### Step 6: Pagination

**Offset Pagination:**
```
GET /users?page=2&pageSize=20
```
- Simple and intuitive
- Poor performance on large datasets

**Cursor Pagination:**
```
GET /users?cursor=eyJpZCI6MTAwfQ&limit=20
```
- Better performance
- Consistent results
- Cannot jump to page

### Step 7: Filtering and Sorting

```
# Filtering
GET /users?status=active&role=admin
GET /orders?createdAt[gte]=2024-01-01&createdAt[lte]=2024-12-31

# Sorting
GET /users?sort=createdAt:desc
GET /users?sort=name:asc,createdAt:desc

# Field Selection
GET /users?fields=id,name,email

# Search
GET /users?q=john
```

---

## Checklists

### Design Phase

```
[ ] Resources follow REST naming conventions
[ ] HTTP methods match operations
[ ] Status codes cover all scenarios
[ ] Error responses are consistent
[ ] Version strategy determined
[ ] Pagination approach selected
```

### Security

```
[ ] HTTPS required
[ ] Authentication mechanism secure
[ ] Authorization checks complete
[ ] Input validation sufficient
[ ] Rate limiting configured
[ ] CORS properly set
```

### Documentation

```
[ ] OpenAPI spec complete
[ ] Example requests/responses
[ ] Error codes documented
[ ] Authentication explained
[ ] SDK/code samples provided
```

---

## Anti-patterns

| Anti-pattern | Why Bad | Fix |
|--------------|---------|-----|
| `/getUser/123` | Verb in URL | Use `/users/123` |
| POST for reads | Wrong semantics | Use GET |
| 200 for errors | Hides problems | Use proper status codes |
| Nested resources >2 levels | Complex URLs | Flatten or use links |
| No versioning | Breaking changes | Add version prefix |

---

## GraphQL Section

### Schema Design

```graphql
type User {
  id: ID!
  name: String!
  email: String!
  orders: [Order!]!
}

type Query {
  user(id: ID!): User
  users(page: Int, pageSize: Int): UserConnection!
}

type Mutation {
  createUser(input: CreateUserInput!): User!
  updateUser(id: ID!, input: UpdateUserInput!): User!
}
```

### Best Practices

```
✅ Use Connection pattern for pagination
✅ Input types use Input suffix
✅ Use Non-null (!) for required fields
✅ Implement DataLoader for N+1 prevention
```

---

## Tools / Commands

### OpenAPI Generation

```bash
# Generate from code (NestJS)
npx @nestjs/swagger

# Validate OpenAPI spec
npx @apidevtools/swagger-cli validate openapi.yaml

# Generate client SDK
npx openapi-generator-cli generate \
  -i openapi.yaml \
  -g typescript-fetch \
  -o ./client
```

### Testing APIs

```bash
# HTTPie
http GET localhost:3000/api/v1/users Authorization:"Bearer token"

# curl
curl -X GET http://localhost:3000/api/v1/users \
  -H "Authorization: Bearer token"
```

---

## TAD Integration

### Gate Mapping

```yaml
API_Design:
  skill: api-design.md
  enforcement: RECOMMENDED
  triggers:
    - Alex designing API
    - Blake implementing endpoints
    - Code review for API changes
  evidence_required:
    - api_spec (OpenAPI/GraphQL)
    - endpoint_list
  acceptance:
    - REST conventions followed
    - Documentation complete
```

### Evidence Template

```markdown
## API Design Evidence

### Endpoints Designed
| Method | Path | Description |
|--------|------|-------------|
| GET | /api/v1/users | List users |
| POST | /api/v1/users | Create user |
| GET | /api/v1/users/:id | Get user |

### OpenAPI Spec
Located at: `docs/api/openapi.yaml`

### Versioning Strategy
URL path versioning: `/api/v1/`
```

---

## Related Skills

- `software-architecture.md` - System design context
- `security-checklist.md` - API security requirements
- `testing-strategy.md` - API testing approaches
- `error-handling.md` - Error response design

---

## References

- [RESTful Web APIs](https://www.oreilly.com/library/view/restful-web-apis/9781449359713/)
- [OpenAPI Specification](https://spec.openapis.org/oas/latest.html)
- [Google API Design Guide](https://cloud.google.com/apis/design)
- [Microsoft REST API Guidelines](https://github.com/microsoft/api-guidelines)
- [JSON:API Specification](https://jsonapi.org/)

---

*This skill guides Claude in designing high-quality APIs following industry standards.*

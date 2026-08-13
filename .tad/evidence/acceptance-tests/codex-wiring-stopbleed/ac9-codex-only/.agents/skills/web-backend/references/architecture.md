# Architecture Rules

Six judgment rules for backend architecture decisions, plus a decision matrix
for choosing the right pattern at the right scale.

---

**Rule 1: Never break the one-hop rule for service communication**

A service should be able to respond to a request by making at most one synchronous
call to another service. Chains of 3+ synchronous calls are a cascading failure
multiplier: if each of A, B, C, D has 99.9% uptime independently, the chain delivers
0.999⁴ ≈ 99.6% uptime.

```
# BAD: A calls B, B calls C, C calls D — all synchronously
Request → ServiceA → ServiceB → ServiceC → ServiceD → ... → Response

# GOOD: A calls only what it owns; async for the rest
Request → ServiceA → responds with 202 Accepted
                   → publishes event → ServiceB processes independently
```

If you find yourself writing a handler that calls two or more services synchronously,
this is a sign that the capability belongs in one service, or that the communication
model should be event-driven.

[Source: Sairyss/domain-driven-hexagon — Service Communication; Sairyss/backend-best-practices]

---

**Rule 2: Do not share SDKs or libraries between services**

Shared SDKs create coupling between release cycles. When the SDK changes, every
service depending on it must upgrade simultaneously. Prefer:
- HTTP APIs with versioned endpoints between services
- Published event schemas with versioning (AsyncAPI, Avro, Protobuf)
- If a library is truly shared (e.g., a logging utility): publish it as a versioned
  internal package and pin versions in each service's lockfile

```
# BAD: services import a shared SDK
import { UserService } from '@company/shared-sdk';

# GOOD: call the versioned HTTP API
const user = await fetch('https://user-service.internal/v1/users/123');
```

[Source: Sairyss/backend-best-practices — Shared Libraries]

---

**Rule 3: Never proxy foreign resources by default — return reference URLs**

An API endpoint should return a reference (URL) to a resource it does not own,
not proxy the resource. Proxying means your service becomes a bottleneck for
another service's traffic, and you bear the latency and error rate of the upstream.

```json
// BAD: your service proxies the CDN asset
GET /products/123/image → streams binary from cdn.example.com

// GOOD: return the reference
{
  "id": "123",
  "imageUrl": "https://cdn.example.com/products/123.jpg"
}
```

Exception: authenticated proxying for access-controlled resources (e.g., pre-signed
S3 URL generation) is acceptable when the access control is the point.

[Source: Sairyss/domain-driven-hexagon — API Design Principles]

---

**Rule 4: New services must not require proxying through other services**

If a new service requires all requests to flow through an existing service (e.g.,
an API gateway that is also business logic), the new service is not independently
deployable. This defeats the purpose of service decomposition.

Each service must be independently addressable. An API gateway for routing and
authentication is acceptable; a business-logic service acting as a mandatory proxy
for other services is not.

[Source: Sairyss/backend-best-practices — Microservices Independence]

---

**Rule 5: All error responses must use RFC 9457 Problem Details format**

Inconsistent error formats force API consumers to parse multiple response shapes.
RFC 9457 provides a standard structure that works across all endpoints:

```json
{
  "type": "https://api.example.com/problems/insufficient-funds",
  "title": "Insufficient Funds",
  "status": 422,
  "detail": "Account balance 50.00 is below the required 100.00.",
  "instance": "/accounts/123/transfers/456"
}
```

```http
Content-Type: application/problem+json
```

Required fields: `type`, `title`, `status`.
Optional but recommended: `detail` (human-readable), `instance` (URI to this occurrence).

`Content-Type: application/problem+json` is required — using `application/json` makes
the response unrecognized as Problem Details by client parsers.

Do not use `{"error": "something went wrong"}` — it is not parseable by clients.

[Source: RFC 9457 (Problem Details for HTTP APIs); zalando/restful-api-guidelines — Error Handling]

---

**Rule 6: Use versioning strategy appropriate to API visibility**

API versioning affects how breaking changes are introduced. Choose by visibility:

- **Public APIs** (external consumers, third-party integrations): URL-path versioning
  (`/v1/`, `/v2/`) — visible, cacheable, easy to route, easy for clients to reason about
- **Internal APIs** (service-to-service, same team): header versioning
  (`API-Version: 2024-01-01` or `Accept: application/vnd.company.v2+json`) —
  avoids URL proliferation in internal environments

```http
# Public API — URL versioning
GET /v1/orders/123
GET /v2/orders/123  # breaking change → new major version

# Internal API — header versioning
GET /orders/123
API-Version: 2024-01-01
```

Never use query parameter versioning (`?version=2`) for public APIs — parameters
are optional and clients frequently omit them.

[Source: zalando/restful-api-guidelines — Versioning; Microsoft REST API Guidelines]

---

## Architecture Pattern Decision Matrix

Use this matrix to choose the right architecture pattern. Start from the top.
Justify deviations in an ADR (Architectural Decision Record).

| Pattern | RIGHT for | OVERKILL for | When to introduce |
|---------|-----------|--------------|-------------------|
| **Simple Layered (MVC)** | MVPs, CRUD apps, small teams, internal tools, REST APIs with straightforward business logic | Nothing — this is the correct baseline for most projects | Start here by default |
| **Clean Architecture** | Medium-complexity domains where you want to isolate business rules from frameworks; teams > 3 people | Simple CRUD, prototypes, tools that will be rewritten | When you're writing unit tests for business rules and find yourself mocking the database |
| **Hexagonal (Ports & Adapters)** | Services that need to swap infrastructure (DB, message queue, HTTP → gRPC) without touching business logic; domain logic worth protecting | Most web apps; adds indirection without benefit if swapping is not a real requirement | When you've changed infrastructure twice and paid the cost of entanglement |
| **DDD (Domain-Driven Design)** | Complex domains with rich business invariants, multiple aggregates, explicit bounded contexts | Simple domains where "Entity = DB table" is accurate; teams without domain experts | When the domain logic is more complex than the infrastructure logic |
| **CQRS (Command Query Responsibility Segregation)** | High read/write ratio divergence (e.g., read model is denormalized, write model is normalized); audit trail requirements | Most APIs; adds operational complexity (two models to maintain, eventual consistency to explain) | After you've built the domain model and found the read model significantly different from the write model |
| **Event Sourcing** | Audit-first systems (financial, compliance, healthcare), complex event replay requirements, temporal queries | General-purpose APIs, prototypes, teams new to distributed systems | Only when audit trail is the primary product requirement, not just a nice-to-have |

**Anti-overengineering rules:**
- If you cannot name the bounded contexts before writing code → don't do DDD yet
- If you have one read path and one write path → don't do CQRS yet
- If you don't need time-travel queries → don't do Event Sourcing

[Source: Sairyss/domain-driven-hexagon — Architecture Patterns; Microsoft Architecture Guides]

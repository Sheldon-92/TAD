# API Testing Rules
<!-- capability: api_testing -->

## Quick Rule Index

| # | Rule | When |
|---|------|------|
| A1 | OpenAPI spec as single source of truth | Setting up API testing |
| A2 | Consumer-Driven Contracts with Pact | Testing microservice boundaries |
| A3 | k6 thresholds: P95 < 500ms, error < 1% | Setting performance gates |
| A4 | Tiered load testing: smoke/load/stress/soak | Configuring load test levels |
| A5 | Schema validation with Schemathesis/Dredd | Validating API contracts |
| A6 | Response body validation, not just status codes | Writing API assertions |
| A7 | Auth matrix: all roles x all protected endpoints | Testing authorization |
| A8 | Error handling coverage: 400/401/403/404/429/500 | Testing failure modes |

---

## Rules

### A1: OpenAPI Spec as Single Source of Truth

When setting up API testing infrastructure:

- **The OpenAPI spec defines the contract.** If the spec says `GET /users` returns `{ users: User[] }`, test that.
- **Schemathesis** generates property-based tests from OpenAPI specs automatically -- finds edge cases humans miss
- **Dredd** validates API implementation against the spec document

```bash
# Property-based testing from OpenAPI
pip install schemathesis
schemathesis run http://localhost:3000/openapi.json

# Spec compliance validation
npm i -D dredd
npx dredd openapi.yaml http://localhost:3000
```

**Anti-pattern**: Writing API tests without an OpenAPI spec. You're testing against assumptions, not contracts.

### A2: Consumer-Driven Contracts with Pact

When testing boundaries between microservices or frontend-backend:

- **Pact** implements Consumer-Driven Contracts: the consumer defines what it needs, the provider verifies it can deliver
- Consumer writes a Pact test (expected request/response pairs) -> generates a contract file
- Provider verifies the contract against its real implementation
- Contract changes surface as test failures BEFORE deployment

```bash
npm i -D @pact-foundation/pact

# Consumer side: generate contract
npx jest --testPathPattern=pact

# Provider side: verify contract
npx jest --testPathPattern=pact-provider
```

**When to use Pact**: Any service boundary where teams deploy independently. If frontend and backend deploy together from the same repo, integration tests may suffice.

### A3: k6 Performance Thresholds

When setting API performance gates in CI:

- **P95 response time < 500ms** -- 95th percentile, not average (averages hide tail latency)
- **Error rate < 1%** -- non-zero exit on threshold breach blocks CI
- These thresholds are minimums; adjust tighter for latency-sensitive endpoints

```javascript
// k6-config.js
export const options = {
  thresholds: {
    http_req_duration: ['p(95)<500'],  // P95 < 500ms
    http_req_failed: ['rate<0.01'],     // Error rate < 1%
  },
};
```

```bash
k6 run k6-config.js
# Non-zero exit if thresholds breached -> CI fails
```

### A4: Tiered Load Testing

When configuring load tests, use four tiers:

| Tier | Virtual Users | Trigger | Purpose |
|------|--------------|---------|---------|
| Smoke | 5-10 VU | Every PR | Catch regressions, verify endpoints respond |
| Load | 100-500 VU | Merge to main | Validate normal production load |
| Stress | 1000+ VU | Nightly/weekly | Find breaking points and degradation patterns |
| Soak | Moderate VU, hours | Pre-release | Detect memory leaks, connection pool exhaustion |

```bash
# Smoke (PR gate)
k6 run --vus 10 --duration 30s smoke.js

# Load (merge gate)
k6 run --vus 200 --duration 5m load.js

# Stress (nightly)
k6 run --vus 1000 --duration 10m stress.js
```

**Anti-pattern**: Only running smoke tests. You discover your service crashes at 200 VU in production instead of in CI.

### A5: Schema Validation -- Property-Based Testing

When validating API responses against schemas:

- **Schemathesis**: Generates hundreds of valid/invalid inputs from your OpenAPI spec. Finds edge cases like empty strings, Unicode, boundary values that manual tests miss.
- **Dredd**: Validates that every documented endpoint exists and responds correctly.
- Both tools catch spec drift -- when implementation and documentation diverge.

```bash
# Schemathesis: property-based fuzzing
schemathesis run --checks all http://localhost:3000/openapi.json

# Dredd: spec compliance
npx dredd api-spec.yaml http://localhost:3000
```

### A6: Response Body Validation

When writing API test assertions:

- **Validate response body structure**, not just HTTP status codes
- Use Zod, TypeScript interfaces, or JSON Schema for structural validation
- Check: correct types, required fields present, no extra fields leaking internal data

```typescript
// Good: validates structure
const response = await api.get('/users/1');
expect(response.status).toBe(200);
expect(response.data).toMatchObject({
  id: expect.any(Number),
  name: expect.any(String),
  email: expect.stringMatching(/@/),
});

// Bad: only checks status
expect(response.status).toBe(200); // What if body is { error: "..." }?
```

### A7: Auth Matrix Coverage

When testing authorization:

- Test every protected endpoint with every role: admin, user, viewer, unauthenticated
- Verify: correct role gets 200, wrong role gets 403, no token gets 401, expired token gets 401
- **Table-driven tests** reduce boilerplate:

```typescript
const authMatrix = [
  { endpoint: '/admin/users', role: 'admin', expected: 200 },
  { endpoint: '/admin/users', role: 'viewer', expected: 403 },
  { endpoint: '/admin/users', role: null, expected: 401 },
];

authMatrix.forEach(({ endpoint, role, expected }) => {
  it(`${endpoint} with ${role} returns ${expected}`, async () => {
    const res = await request(endpoint, { role });
    expect(res.status).toBe(expected);
  });
});
```

### A8: Error Handling Coverage

When testing API error paths:

- **400**: Missing/invalid fields -- verify error message is user-safe (no stack traces)
- **401**: Missing/expired/malformed token
- **403**: Valid token, insufficient permissions
- **404**: Resource does not exist
- **429**: Rate limit exceeded (if applicable)
- **500**: Forced server error -- verify graceful response (no internal details leaked)

**Anti-pattern**: Testing only happy paths. Most production bugs are in error handling code that was never tested.

---

## Anti-Patterns

| Pattern | Problem | Fix |
|---------|---------|-----|
| Status-code-only assertions | Body could contain errors with 200 status | Validate response body structure |
| Hardcoded auth tokens | Break on rotation, leak in CI logs | Use test fixture generation |
| No contract tests | API changes break consumers silently | Pact for service boundaries |
| Average latency thresholds | Hide P99 spikes | Use P95/P99 percentiles |
| Happy-path-only tests | Error handling untested | Auth matrix + error code coverage |
| Testing against production APIs | Flaky, data pollution, rate limits | Mock server or test environment |

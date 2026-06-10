# Production Readiness Checklist

46 items organized into three tiers. Run `scripts/readiness-score.sh` to
automatically score Tier 1 items. Tier 2 and Tier 3 require human attestation
or infrastructure verification.

---

## Tier 1 — Automatable (~25 items)

Script-verifiable checks. `scripts/readiness-score.sh` runs these automatically.

- [ ] **PC-01: Secrets not hardcoded** — No API keys, passwords, or tokens in source code or committed config files. PASS: `grep -rE "(api_key|secret|password)\s*=\s*['\"][^'\"]{8,}" src/` returns 0 matches.

- [ ] **PC-02: Environment file excluded from git** — `.env` is listed in `.gitignore`. PASS: `grep -q '^\.env' .gitignore`.

- [ ] **PC-03: Environment example exists** — `.env.example` exists with all required variable names (no real values). PASS: `test -f .env.example`.

- [ ] **PC-04: Dependency audit clean** — No high or critical severity vulnerabilities in production dependencies. PASS: `npm audit --audit-level=high --omit=dev` exits 0 (Node.js); `pip-audit --severity high` exits 0 (Python).

- [ ] **PC-05: Structured logging enabled** — Application writes logs in JSON format to stdout. PASS: check that `pino`, `winston`, `structlog`, `zerolog`, or `zap` is imported; `console.log` not used for application events.

- [ ] **PC-06: Health endpoint exists** — `/health` or `/healthz` returns 200 OK with no authentication required. PASS: `curl -s -o /dev/null -w "%{http_code}" http://localhost:$PORT/health` returns 200.

- [ ] **PC-07: Readiness endpoint exists** — `/ready` or `/readyz` checks database and critical dependencies, returns 503 if not ready. PASS: endpoint exists and returns non-200 when database is unavailable.

- [ ] **PC-08: TLS enforced** — API endpoints reject plain HTTP (no redirect), and TLS certificate auto-renewal is configured (cert-manager, ACM auto-renew, or ACME client) with > 30 days validity. PASS: `curl -s -o /dev/null -w "%{http_code}" http://localhost:$PORT/health` returns 400 or 403; `openssl s_client -connect $HOST:443 </dev/null 2>/dev/null | openssl x509 -noout -enddate` shows > 30 days remaining.

- [ ] **PC-09: Request timeout configured** — HTTP server has a request timeout. PASS: `server.timeout` or equivalent is set and < 15s (30s is a common misconfiguration that allows exhausted worker pools).

- [ ] **PC-10: Database connection pool configured** — Pool size is explicit, not library default. PASS: `pool.max` and `pool.idleTimeoutMillis` are set in database configuration.

- [ ] **PC-11: Database query timeout configured** — Individual query timeout prevents runaway queries. PASS: `statement_timeout` (PostgreSQL) or equivalent is set and < 10s.

- [ ] **PC-12: External dependency timeouts set** — All HTTP client calls have explicit timeouts. PASS: no `fetch(url)` or `requests.get(url)` without timeout parameter.

- [ ] **PC-13: Error responses use RFC 9457 format** — All error responses include `type`, `title`, `status` fields. PASS: `curl -s http://localhost:$PORT/nonexistent | jq '.status'` returns a number.

- [ ] **PC-14: Rate limiting configured** — At minimum, authentication endpoints are rate-limited. PASS: `/login` or `/auth/token` returns 429 after N rapid requests.

- [ ] **PC-15: CORS configured explicitly** — No `Access-Control-Allow-Origin: *` with `credentials: true`. PASS: `grep -rE "origin.*\*.*credentials|credentials.*origin.*\*" src/` returns 0.

- [ ] **PC-16: Input validation at API boundary** — Request bodies are validated against a schema before processing. PASS: `zod`, `joi`, `pydantic`, `class-validator`, or equivalent is used in request handlers.

- [ ] **PC-17: OpenAPI specification exists** — API endpoints are documented in an OpenAPI 3.x spec. PASS: `test -f openapi.yaml || test -f swagger.yaml || test -f docs/api.yaml`.

- [ ] **PC-18: Database migrations are tracked** — Schema changes are managed by a migration tool, not manual SQL. PASS: `ls migrations/` or `db/migrations/` contains numbered migration files; or Flyway/Alembic/Atlas is configured.

- [ ] **PC-19: Container runs as non-root user** — Dockerfile has `USER` directive with non-root UID. PASS: `grep -q '^USER' Dockerfile && ! grep -q '^USER root' Dockerfile`.

- [ ] **PC-20: Container health check defined** — Dockerfile has `HEALTHCHECK` directive. PASS: `grep -q '^HEALTHCHECK' Dockerfile`.

- [ ] **PC-21: Graceful shutdown implemented** — Application handles SIGTERM by stopping new requests, finishing in-flight requests, then exiting. PASS: process handles `SIGTERM` signal explicitly.

- [ ] **PC-22: Request ID propagated** — Every request generates a unique ID, propagated through all logs and responses. PASS: response headers include `X-Request-Id` or `X-Correlation-Id`.

- [ ] **PC-23: Pagination on list endpoints** — No unbounded list endpoints. PASS: no `SELECT *` without `LIMIT`; all list endpoints accept `limit` and `cursor`/`offset` parameters.

- [ ] **PC-24: Background jobs are non-blocking** — Long-running operations return `202 Accepted` immediately. PASS: no synchronous operations > 2s in HTTP handlers.

- [ ] **PC-25: Memory limit set in container config** — Container has explicit memory limit. PASS: `resources.limits.memory` set in Kubernetes manifest, or `--memory` flag in Docker Compose.

---

## Tier 2 — Human Attestation (~12 items)

Organization or process items. Cannot be script-verified. A team member must
attest that each item is in place.

- [ ] **PC-26: On-call rotation established** — A defined list of engineers is on-call, with schedule published and accessible. Owner: _________

- [ ] **PC-27: Escalation policy documented** — Clear path from alert → on-call engineer → secondary → manager. Owner: _________

- [ ] **PC-28: Service owner designated** — A named individual or team owns this service, is listed in service catalog, and is the point of contact for incidents. Owner: _________

- [ ] **PC-29: Runbook exists** — A runbook covers the most common alert scenarios for this service, including restart procedures and rollback steps. Location: _________

- [ ] **PC-30: SLA/SLO targets defined** — Explicit availability target (e.g., 99.9%), error rate budget, and latency P99 target are documented. Location: _________

- [ ] **PC-31: Incident response playbook exists** — Steps for declaring an incident, communicating to stakeholders, and writing a post-mortem. Location: _________

- [ ] **PC-32: Post-mortem process defined** — Process for writing a blameless post-mortem within 5 business days of a P0/P1 incident. Owner: _________

- [ ] **PC-33: Dependency inventory maintained** — All upstream dependencies (services, databases, queues, third-party APIs) are documented with their owners and SLAs. Location: _________

- [ ] **PC-34: Data retention policy documented** — Explicit retention period for all data stored by this service, including soft-deleted records. Location: _________

- [ ] **PC-35: Security review completed** — Service has passed a security review covering authentication, authorization, input handling, and data protection. Reviewer: _________

- [ ] **PC-36: ADR published for significant architecture decisions** — Architectural Decision Records exist for any non-obvious technical choices made during development. Location: _________

- [ ] **PC-37: Monitoring dashboard exists** — A dashboard covering request rate, error rate, latency (P50/P95/P99), and saturation is published and linked from the runbook. Location: _________

---

## Tier 3 — Infrastructure-Dependent (~9 items)

Only applicable if the target infrastructure supports these capabilities. Mark N/A
if not applicable to your deployment environment.

- [ ] **PC-38: Horizontal Pod Autoscaler tested** — HPA is configured and has been tested to scale up under load. Applies to: Kubernetes deployments. N/A if: serverless, single-node, or container platform without HPA.

- [ ] **PC-39: Read replicas configured for read-heavy workloads** — Database has at least one read replica; read queries are routed to replicas. Applies to: services with > 80% read traffic. N/A if: write-heavy workload.

- [ ] **PC-40: CDN configured for static assets** — Static files (JS, CSS, images) are served via a CDN, not directly from the application server. Applies to: services with web frontends. N/A if: API-only service.

- [ ] **PC-41: Database backup restore verified** — A full restore from backup has been tested successfully in the last 30 days. Applies to: all production databases. Never N/A.

- [ ] **PC-42: Chaos engineering baseline run** — A failure injection experiment (killed pod, degraded dependency, network partition) has been run and the service recovered correctly. Applies to: services with > 99.5% SLO. N/A if: non-critical internal tooling.

- [ ] **PC-43: Load testing completed** — Service has been load-tested to at least 2× expected peak traffic; baseline throughput and latency profile documented. Applies to: public-facing services. N/A if: internal tools < 100 users.

- [ ] **PC-44: Distributed tracing enabled** — Traces are collected and visible in a tracing system (Jaeger, Honeycomb, AWS X-Ray, Datadog APM). Applies to: microservices with > 2 downstream dependencies. N/A if: monolith or single-dependency service.

- [ ] **PC-45: Secret rotation tested** — Database passwords and API keys can be rotated without downtime; procedure has been tested. Applies to: long-lived credentials. N/A if: short-lived tokens only (OIDC, IRSA).

- [ ] **PC-46: Multi-region failover tested** — Service can survive a full region failure and recover in the target RTO. Applies to: services with multi-region availability requirement. N/A if: single-region deployment is acceptable per SLO.

---

## Score Summary

After running `scripts/readiness-score.sh`:

```
Tier 1 automated score: X/25 PASS
Tier 2 human attestation: 12 items (manual review required)
Tier 3 infrastructure-dependent: 9 items (verify applicability)

Recommended minimum before launch:
  - Tier 1: ≥ 20/25 PASS
  - Tier 2: ≥ 8/12 attested
  - Tier 3: all applicable items checked
```

[Source: Mercari Engineering / production-readiness-checklist; bregman-arie/sre-checklist; Google SRE Book Chapter 32]

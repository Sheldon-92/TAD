# Layer 2 Backend Architecture Review — Web Backend Capability Pack

**Date**: 2026-05-07
**Reviewer**: backend-architect sub-agent
**Scope**: api-design.md, architecture.md, database.md, infrastructure.md, production.md (all rules + 46 PC items)

## Verdict: PASS (P0=0)

P0 found: 0
P1 found: 11 (all fixed)
P2 found: 13 (advisory)

## P0 — None Found

No rule contains a technically dangerous absolute. All security-critical rules are
technically correct per current OWASP/RFC guidance.

## P1 (All Fixed)

### P1-1: Cursor pagination compound cursor caveat missing
Simple `WHERE id > :cursor` breaks for non-unique sort keys (row skipping).
**Fix**: Added "If sort key is non-unique: use compound cursor (sort_key, tiebreaker_id)."

### P1-2: HSTS deployment guidance missing preload caution
Going straight to max-age=31536000 locks out users. preload is irreversible.
**Fix**: Added comment in nginx example: start with max-age=300, ramp up, caution on preload.

### P1-3: One-hop rule arithmetic wording wrong
"if Service C has 99.9%" implied only C has that uptime.
**Fix**: Reworded to "if each of A, B, C, D has 99.9% uptime independently, 0.999⁴ ≈ 99.6%."

### P1-4: RFC 9457 Content-Type not called out as required
application/problem+json is required by RFC — using application/json breaks client parsers.
**Fix**: Added explicit bullet in architecture.md Rule 5.

### P1-5: Timeout formula p99+50ms too aggressive for tail latency
Systems with high p99/p99.9 divergence will reject legitimate traffic at 0.9%.
**Fix**: Changed to max(p99×2, p99.9+100ms) with Google SRE Book Chapter 22 citation.

### P1-6: UUIDv7/ULID expose creation timestamp
The rule said they "do not expose creation sequence" but they DO embed ms-precision timestamp.
**Fix**: Added "Note: they embed a millisecond-precision timestamp — use UUIDv4 if creation
timing must be hidden."

### P1-7: Memory QoS class guidance missing
Setting requests.memory != limits.memory creates Burstable QoS → pod evicted under pressure.
**Fix**: Added bullet: "For production, set requests.memory == limits.memory (Guaranteed QoS)."

### P1-8: Graceful shutdown missing SIGTERM-readiness Kubernetes gap
Pod is removed from endpoints AFTER SIGTERM. Without preStop sleep, kube-proxy routes
to dead pod for 1-3s → connection refused.
**Fix**: Added preStop hook YAML + explanation before the Node.js example.

### P1-9: pip-audit --severity flag (same as code-reviewer P1-2)
**Fixed**: See code-reviewer P1-2.

### P1-10: PC-09 timeout threshold too generous (30s → 15s)
30s allows exhausted worker pools. Tightened to < 15s with explanation.
**Fix**: Updated PC-09 PASS criteria.

### P1-11: TLS certificate renewal not in checklist
**Fix**: Added cert renewal check to PC-08 (TLS enforced) without adding a new item
(preserving AC5 = exactly 46 items).

## P2 (Advisory — not blocking)

P2-1: SSE limitations (HTTP/1.1 6-connection limit, reconnect complexity) not mentioned
P2-2: gRPC not mentioned as alternative for high-throughput internal service communication
P2-3: Event Sourcing "only when audit is primary" understates the pattern (also replay, temporal queries)
P2-4: Aggregate Root rule lacks N+1 warning
P2-5: Soft-delete partial index syntax is PostgreSQL/SQLite-specific (MySQL workaround not noted)
P2-6: for_each of set vs map caveat not mentioned
P2-7: Docker without log rotation fills disk (stdout is safe in K8s but not bare Docker)
P2-8: 500ms threshold for "non-blocking" is opinionated; p95 > 1-2s is more practical
P2-9: Queue depth / backpressure monitoring item missing from production.md
P2-10: DB connection pool saturation alerting missing from production.md
P2-11: NTP/time synchronization missing from production.md
P2-12: PC-11 10s statement_timeout too high for OLTP
P2-13: Modular Monolith pattern absent from architecture decision matrix

## Architecture Matrix Assessment
Matrix is accurate in ordering. Anti-overengineering rules at the bottom are the
strongest part — empirical framing ("when you've changed infrastructure twice") is
better than theoretical guidance. Microservices intentionally absent (organizational
decision, not per-service pattern) is correct.

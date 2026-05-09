# Web Backend Capability Pack — Deep Research Findings
Date: 2026-05-07
Notebook: 20c498da-7a87-442e-88ed-1b1b57571908
Sources: ~41 (30 manual GitHub + 11 deep research imports)

---

## Q1: Top 5 Backend Quality Problems + Specific CLI Tools

### 1. Security Vulnerabilities and Broken Access Control
- **Snyk, Trivy**: dependency/code vulnerability scanning (SAST)
- **Spectral + spectral-owasp-ruleset**: OpenAPI document security lint
- **OFFAT (OWASP)**: autonomous API vulnerability testing from OpenAPI spec
- **sqlmap**: SQL injection detection
- **helmet**: HTTP header hardening for Node.js

### 2. Performance Bottlenecks and Slow Database Queries
- **k6, Artillery, Gatling, Locust**: load/stress testing
- **PgBouncer, HikariCP**: connection pooling
- **hyperfine**: CLI benchmarking
- **EverSQL, SlowQL**: SQL static analyzers

### 3. Inconsistent API Design and Database Schema Drift
- **apilint**: REST API linter (CI-friendly)
- **Spectral**: JSON/YAML linter for OpenAPI
- **Buf CLI**: gRPC proto linting + breaking change detection
- **Atlas**: declarative schema migration, 50+ safety analyzers
- **Flyway, Liquibase**: database migration tools
- **SQLFluff**: SQL linter and auto-formatter
- **openapi-generator**: type-safe SDK generation from OpenAPI

### 4. Lack of Observability (Silent Failures)
- **OpenTelemetry (OTel)**: traces, metrics, logs framework
- **OTel Collector**: telemetry proxy
- **Jaeger, Zipkin**: distributed tracing
- **Prometheus, Datadog**: metrics + alerting
- **Winston, Pino**: structured logging (Node.js)

### 5. Poor Code Quality and Architectural Violations
- **SonarQube**: SAST, code smell detection
- **Dependency cruiser (JS/TS), ArchUnit (Java)**: architectural dependency validation
- **ESLint + typescript-eslint**: strict coding rules

---

## Q2: Complete Production Readiness Checklist (from Mercari PRR, Google SRE, etc.)

### Security & Compliance (11 items)
- Secrets in secrets manager (not hardcoded)
- Dependency vulnerability scans (Snyk/Trivy)
- RBAC/ABAC access controls
- Encryption at rest (AES-256) + in transit (TLS 1.2+)
- MFA enforcement
- Regulatory compliance (GDPR/HIPAA/SOC2/PCI)
- VPN for non-public services
- WAF + CDN for public services
- Rootless containers
- PII excluded from logs unless approved
- SAST + DAST in CI/CD

### Observability & Monitoring (8 items)
- Four Golden Signals (latency, traffic, errors, saturation)
- Structured JSON logging to STDOUT
- Debug logs disabled in production
- Distributed tracing with correlation IDs
- Actionable alerting with thresholds
- Runbook-linked alerts
- KPI dashboards (Grafana/Datadog)
- K8s readiness/liveness probes

### Reliability & Operations (11 items)
- SLOs/SLIs/SLAs + error budgets defined
- Circuit breakers + retries with backoff/jitter
- Graceful degradation fallbacks
- Graceful shutdown (SIGTERM)
- Chaos engineering / fault injection tests
- Automated rollback within MTTR target
- Fully automated CI/CD (no manual SSH)
- Redundancy (min 2-3 replicas, anti-affinity)
- 3-2-1 backup rule, rehearsed DR with RTO/RPO
- Idempotent APIs + dead-letter queues
- 12-factor config via env vars

### Scalability & Performance (7 items)
- Load + stress testing against realistic traffic
- 6-12 month capacity planning
- Auto-scaling policies tested (HPA)
- Container resource limits/requests set
- Strategic multi-layer caching (CDN/Redis/app)
- Connection pool tuning + slow query indexing
- Read/write replica separation, no shared DBs

### Ownership & Documentation (9 items)
- Designated service owner/team
- On-call rotation assigned + synced
- Escalation policies defined
- Standardized runbooks with debugging commands
- Dependency mapping (upstream/downstream)
- Service catalog registration (Backstage)
- README with bounded context + local setup
- OpenAPI spec in repo root
- RFC for cross-team architectural changes

---

## Q3: Architecture Patterns — Practical Decision Criteria

### Clean Architecture
- **Right for**: large enterprise, long-term maintenance, regulatory compliance
- **Overkill for**: MVPs, simple CRUD, startup speed
- **Key repos**: Sairyss/domain-driven-hexagon, Equinox Project
- **Common mistakes**: rigid blueprint instead of guidelines, unnecessary POJO duplication across layers

### Hexagonal Architecture (Ports & Adapters)
- **Right for**: multi-integration systems (payment gateways, cloud providers), microservices
- **Overkill for**: small apps where 3-tier MVC suffices
- **Key repos**: Over-engineered ToDo (NestJS)
- **Common mistakes**: creating unnecessary port abstractions, copying exact folder structures from demos

### Domain-Driven Design (DDD)
- **Right for**: complex business domains, microservice boundary definition
- **Overkill for**: data-centric CRUD, glue between DB and client
- **Key repos**: heynickc/awesome-ddd, Eclipse CargoTracker
- **Common mistakes**: anemic domain model, primitive obsession, shared domain/persistence models, oversized aggregates

### CQRS
- **Right for**: drastically different read/write workloads (e.g., news app: many reads, few writes)
- **Overkill for**: straightforward CRUD with low complexity
- **Key repos**: SimpleCQRS (Greg Young), CQRS-DDD Example (.NET)
- **Common mistakes**: Command→Command coupling instead of Command→Event→Command

### Event Sourcing
- **Right for**: financial ledgers, audit logs, order processing (capturing business intent)
- **Overkill for**: real-time read consistency, static catalogs, prototypes
- **Key repos**: Event Sourcing .NET, Message DB (PostgreSQL)
- **Common mistakes**: state-focused events instead of intent-focused, in-place migration (breaks immutability), all-or-nothing adoption

---

## Q4: AI Agent-Specific Backend Weaknesses

1. **API version mismatches in IaC**: silent failures in K8s/service mesh YAML
2. **Knowledge cutoff**: old patterns (sidecar proxy) instead of new (Ambient Mode)
3. **Insecure defaults**: hardcoded secrets, weak crypto, default credentials
4. **Destructive commands without context**: rm -rf, DROP TABLE, force-push
5. **"Vibe coding"**: syntactically correct but functionally broken business logic
6. **Over-engineering / AI slop**: generic bloated code, violating KISS
7. **Unsafe data handling**: prompt injection, supply chain vulnerabilities

---

## Key GitHub Sources (Manual + Verified)

### Broad Backend
- Sairyss/backend-best-practices (TypeScript+NodeJS, language-agnostic)
- zhashkevych/awesome-backend (structured learning path)
- binhnguyennus/awesome-scalability (large-scale patterns)
- mehdihadeli/awesome-software-architecture (comprehensive)

### API Design
- Kikobeats/awesome-api, yosriady/awesome-api-devtools, marmelab/awesome-rest
- zalando/restful-api-guidelines (industry gold standard)
- stoplightio/spectral (OpenAPI linter), danielgtaylor/apilint
- CiscoDevNet/api-design-guide

### Database
- mgramin/awesome-db-tools, danhuss/awesome-sql
- sqlfluff/sqlfluff (SQL linter), ariga/atlas (schema migration)

### Security
- arainho/awesome-api-security, OWASP/API-Security, OWASP/OFFAT
- stoplightio/spectral-owasp-ruleset

### SRE / Production Readiness
- dastergon/awesome-sre, bregman-arie/sre-checklist
- kgoralski/microservice-production-readiness-checklist
- mercari/production-readiness-checklist

### Architecture
- Sairyss/domain-driven-hexagon, heynickc/awesome-ddd
- DovAmir/awesome-design-patterns, madd86/awesome-system-design

### AI Agent Tools
- VoltAgent/awesome-claude-code-subagents (100+ subagent definitions)
- VoltAgent/awesome-agent-skills (1000+ skills)

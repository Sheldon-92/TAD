---
name: web-backend
description: Web backend capability pack. Gives AI agents the judgment rules a senior backend engineer applies automatically — API design, architecture selection, application logic, database modeling, security, production readiness, infrastructure, and debugging. 43 concrete decision rules + 46-item production readiness checklist + executable validation scripts. Use for any backend feature, API design, architecture review, database schema, security hardening, or pre-launch checklist task.
keywords: ["backend", "API", "REST", "GraphQL", "database", "security", "deploy", "infrastructure", "后端", "接口", "数据库", "安全", "部署"]
type: reference-based
---

**CONSUMES**: User backend task + optional existing codebase context
**PRODUCES**: Applied judgment rules + quality checklist results + validated architecture decisions

# Web Backend Capability Pack

**Version**: 0.1.0
**Compatibility**: Claude Code (Phase 1); Codex / Cursor / Gemini in Phase 3
**License**: Apache 2.0 — see LICENSE-ATTRIBUTION.md for source credits

---

## What This Pack Does

AI agents write backend code that passes code review but fails in production. They
choose the wrong architecture for the problem size. They use offset pagination on
tables with 50M rows. They hardcode secrets. They never think about graceful shutdown.

This pack embeds the judgment rules that senior backend engineers apply automatically —
rules learned from production incidents, not tutorials.

**Pack = domain judgment. Your workflow system = process constraints. No overlap.**
This pack tells the agent WHAT to check. It never reimports process mechanisms.

---

## Step 0: Context Detection

When the user mentions backend work, detect the context and load the right reference:

| User Signal | Reference to Load |
|-------------|-------------------|
| "design API", "new endpoint", "REST", "API review", "GraphQL" | `references/api-design.md` |
| "architecture", "tech stack", "framework choice", "microservices vs monolith" | `references/architecture.md` |
| "domain logic", "DDD", "CQRS", "command handler", "value object" | `references/application-logic.md` |
| "database", "schema", "query", "migration", "ORM", "SQL", "index" | `references/database.md` |
| "security", "auth", "JWT", "OWASP", "hardening", "secrets", "CORS" | `references/security.md` |
| "deploy", "ship", "production", "launch", "go-live", "release" | `references/production.md` |
| "infrastructure", "Kubernetes", "K8s", "Terraform", "logging", "ArgoCD" | `references/infrastructure.md` |
| "debug", "fix bug", "investigate", "root cause", "performance issue" | `references/debugging.md` |
| "review my code", "full audit", "backend review", "everything" | Load **all references** sequentially |

---

## Step 1: Apply Rules

After loading the relevant reference file(s):

1. **Read the reference completely** — do not skim
2. **Apply each rule as a judgment check** against the user's code, design, or request
3. **For each violated rule**: state the violation clearly, then give the specific fix
4. **Severity classification**:
   - **P0 — Blocking**: security vulnerability, data loss risk, production outage risk
   - **P1 — Required**: correctness issue, performance cliff, maintainability debt
   - **P2 — Advisory**: best-practice deviation, nice-to-have improvement

Output format per finding:
```
[P0] Rule 3 (api-design): GET /users/search modifies state (adds audit log entry)
→ Move the audit log write to a POST /users/search/audit endpoint or use a
  middleware that fires POST-response asynchronously.
```

---

## Step 2: Run Validation Scripts (when applicable)

| Context | Script | Command |
|---------|--------|---------|
| API spec exists (OpenAPI/Swagger) | `scripts/api-lint.sh` | `bash scripts/api-lint.sh <path-to-spec>` |
| Database schema or migrations | `scripts/schema-check.sh` | `bash scripts/schema-check.sh <schema-path>` |
| Security review requested | `scripts/security-scan.sh` | `bash scripts/security-scan.sh <project-root>` |
| Pre-launch / production readiness | `scripts/readiness-score.sh` | `bash scripts/readiness-score.sh <project-root>` |

Run scripts first, then add their output to your findings report. If a required tool
is not installed, the script prints an install command and exits — do not skip the
script, follow the install instruction.

---

## Step 3: Output

Produce a structured findings report:

```
## Backend Review: [area reviewed]

### P0 — Blocking (must fix before merge)
- [finding + specific fix]

### P1 — Required (fix this sprint)
- [finding + specific fix]

### P2 — Advisory (track as tech debt)
- [finding + specific fix]

### Validation Script Output
[paste script output here]

### Score (if readiness-score.sh run)
Automated: X/25 PASS
Human attestation needed: 12 items (see production.md Tier 2)
Infrastructure-dependent: 9 items (see production.md Tier 3)
```

---

## Anti-Skip Table

These are the most common reasons an agent skips rules. Each has a counter-argument.

| Excuse | Counter |
|--------|---------|
| "This is just a prototype" | Prototypes become production code. Soft-delete, structured logging, and secrets in env vars cost nothing now; retrofitting costs a sprint later. |
| "I'll add tests later" | Later never comes. Write the test that exercises the rule violation NOW, even if it's a single `assert response.status_code == 200`. |
| "The user didn't ask for security" | Security is not a feature request. Run `scripts/security-scan.sh` regardless of whether the user mentioned security. |
| "This is overkill for a small project" | These rules are MOST important for small projects. Large teams catch mistakes in code review and dedicated QA; solo developers rely on the pack. |
| "The deadline is tomorrow" | A P0 security finding shipped under deadline pressure becomes a production incident the day after launch. Block the merge now. |
| "The rule doesn't apply to our stack" | Read the rule. Every rule in this pack has a context-scoped form ("If X context: …"). A rule with no applicable branch genuinely does not apply — but you must read it to confirm. |

---

## CONVENTIONS.md

For naming conventions, directory layout, and worked examples (REST endpoint,
DB migration, error handling, auth middleware), see `CONVENTIONS.md`.

---

## Quick Rule Index

| Reference | Rules |
|-----------|-------|
| `references/api-design.md` | Rules 1–7: pagination, batch, GET side-effects, DTOs, auth URLs, HTTPS, polling |
| `references/architecture.md` | Rules 1–6: one-hop, SDK sharing, proxy, microservices, error format, versioning + decision matrix |
| `references/application-logic.md` | Rules 1–6: domain errors, error types, commands, queries, value objects, inheritance |
| `references/database.md` | Rules 1–6: test DBs, IDs, timeouts, aggregates, transactions, deletes |
| `references/security.md` | Rules 1–7: JWT, rate limiting, enumeration, secrets, input validation, CORS, dependencies |
| `references/production.md` | 46-item checklist: Tier 1 (~25 automatable), Tier 2 (~12 attestation), Tier 3 (~9 infra) |
| `references/infrastructure.md` | Rules 1–7: K8s limits, ArgoCD, Terraform, provider modules, logging, jobs, shutdown |
| `references/debugging.md` | Rules 1–4: 3-Strike Rule, test-verified fixes, blast radius, Iron Law |

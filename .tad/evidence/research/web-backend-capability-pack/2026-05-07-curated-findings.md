# Web Backend Capability Pack — Curated Research Findings (Round 2)
Date: 2026-05-07
Notebook: 75a22e54-4d5e-486c-b2c4-b3b3e035c414 (clean, 20 curated sources)

---

## Core Insight: Domain Judgment ≠ Process Mechanism

TAD already provides process constraints (gates, review, isolation).
Capability Pack provides DOMAIN JUDGMENT — specific decision rules a senior backend engineer applies.

---

## Q5: Concrete Backend Decision Rules (from curated sources)

### Architecture & Communication (5 rules)
1. Never break the "one-hop rule" — service should not call other services to respond (cascading failure risk)
2. Do not share SDKs between services — prefer APIs
3. Never proxy foreign resources by default — return reference URLs instead
4. Avoid Monolith-to-Microservice HTTP calls — keep them independent
5. New RESTful web services MUST NOT require proxying

### API Design (7 rules)
1. Use cursor pagination, not offset, for large datasets
2. Require empirical evidence before implementing batch operations (prefer bulk)
3. GET requests must never have business logic side effects (CSRF)
4. Use whitelisting, not blacklisting, for Response DTOs (leak prevention)
5. Never accept auth material in URLs
6. Fail hard on HTTP → don't redirect to HTTPS
7. Do not design APIs that require polling

### Application Logic & DDD (6 rules)
1. Do not throw HTTP exceptions from domain core — return explicit error types
2. Return recoverable errors, throw unrecoverable ones
3. Don't execute commands from command handlers — use events (Command→Event→Command)
4. Bypass domain model for read queries — query DB directly from query handler
5. Don't serialize Value Objects to external boundaries — convert to primitives
6. Limit inheritance depth to 1-2 levels, prefer composition

### Database & Testing (6 rules)
1. Never use in-memory databases for tests (unreliable)
2. Use ULIDs, not auto-incrementing IDs
3. Set external dependency timeouts to p99 latency + buffer
4. Only Aggregate Roots can be queried directly
5. Don't force transactions across aggregates — use Sagas/Outbox
6. Implement soft-deletes by default (DELETE = soft delete)

### Infrastructure & DevOps (7 rules)
1. Never set CPU limits in Kubernetes (only memory limits)
2. Never install ArgoCD via kubectl or Helm — use hosted
3. Prefer for_each over count in Terraform
4. Never put provider code in reusable Terraform modules
5. Write logs to stdout/stderr in JSON, not files
6. Use non-blocking background jobs by default (return 202)
7. Graceful shutdown: stop new requests → finish current → close connections → exit

### Debugging & QA (4 rules)
1. 3-Strike Rule: if 3 hypotheses fail, question the architecture
2. Never apply a fix you cannot verify with a test
3. Flag fixes touching >5 files — review blast radius
4. Never fix symptoms without root cause (Iron Law)

**Total: 35 concrete decision rules extracted from curated sources**

---

## Q6: Skill File Structure Blueprint

### Required Files
```
skill-name/
├── SKILL.md          # Main entry point (<500 lines), step-by-step workflow
├── CONVENTIONS.md    # Directory layout + naming tables + worked examples
├── references/       # Just-in-time loaded checklists and docs
│   ├── api-design-rules.md
│   ├── security-checklist.md
│   ├── production-readiness.md
│   └── architecture-decision-matrix.md
├── scripts/          # Executable validation scripts
│   ├── lint-api.sh
│   ├── check-schema.sh
│   └── production-readiness-check.sh
└── assets/           # Output templates, JSON schemas
    └── decision-record-template.md
```

### Key Design Rules for SKILL.md
- Under 500 lines
- Third-person imperative ("The agent MUST...")
- Progressive disclosure — reference files loaded on demand
- Explicit trigger keywords in frontmatter
- Step-by-step chronological workflow, not topic-organized reference
- Anti-skip table: list common excuses with counter-arguments
- End with evidence requirements (tests passing, lint output, etc.)

### CONVENTIONS.md Structure (from api-skill)
1. Directory layout map (where each file type goes)
2. Naming convention tables (class/method/file naming rules)
3. Complete worked examples for each pattern:
   - Store operations
   - Destroy operations with background jobs
   - Exception handlers (RFC 9457)
   - CORS setup
   - Testing setup

---

## Source Quality Verification

20 sources, 0 duplicates. Tier distribution:
- Tier 1 (authoritative): 11 (Zalando, Microsoft, Cisco, OWASP, Mercari, SRE, Sairyss ×2, VoltAgent ×2)
- Tier 2 (proven skills): 5 (addyosmani, mgechev, api-skill, gstack investigate, gstack docs)
- Tier 2 (key tools): 4 (Spectral, Atlas, OFFAT, SQLFluff)

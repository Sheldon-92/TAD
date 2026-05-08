# Web Backend Capability Pack

**Version**: 0.1.0 | **License**: Apache 2.0

Gives AI coding agents the judgment rules a senior backend engineer applies
automatically. 43 concrete decision rules + 46-item production readiness checklist
+ 4 executable validation scripts.

---

## What's Inside

```
CAPABILITY.md          Main skill entry — context router (install this as SKILL.md)
CONVENTIONS.md         Naming, directory layout, worked examples (3 languages)
references/
  api-design.md        7 rules: pagination, batch, GET safety, DTOs, auth, HTTPS, polling
  architecture.md      6 rules + decision matrix: Simple Layered → Event Sourcing
  application-logic.md 6 DDD rules: error types, command handlers, CQRS, value objects
  database.md          6 rules: test DBs, IDs, timeouts, aggregates, transactions, deletes
  security.md          7 rules + OWASP API Top 10 mapping
  production.md        46-item checklist: 25 automatable + 12 attestation + 9 infra
  infrastructure.md    7 rules: K8s, ArgoCD, Terraform, logging, jobs, shutdown
  debugging.md         4 rules: 3-Strike Rule, test-verified fixes, Iron Law
scripts/
  api-lint.sh          Spectral OWASP + naming conventions
  schema-check.sh      Atlas lint + SQLFluff
  security-scan.sh     Secrets detection + dependency audit + OFFAT
  readiness-score.sh   Tier 1 automated production readiness score
```

---

## Install

### Claude Code (Phase 1)

```bash
# Install to current project
bash install.sh --agent=claude-code

# Install globally
bash install.sh --agent=claude-code --global

# Dry run (preview only)
bash install.sh --agent=claude-code --dry-run
```

### Codex / Cursor / Gemini (Phase 3 — planned)

```bash
bash install.sh --agent=codex   # → exits with instructions
bash install.sh --agent=cursor  # → exits with instructions
```

---

## Use

After installing, reference the skill in your conversation:

```
"Review this API endpoint using the web-backend capability pack."
"Use web-backend to review my database schema."
"Run the production readiness checklist on this project."
```

Run scripts directly from your project root:

```bash
# API spec lint
bash .claude/skills/web-backend/scripts/api-lint.sh openapi.yaml

# Schema check
bash .claude/skills/web-backend/scripts/schema-check.sh migrations/

# Security scan
bash .claude/skills/web-backend/scripts/security-scan.sh .

# Production readiness score
bash .claude/skills/web-backend/scripts/readiness-score.sh .
```

---

## Sources

Rules are grounded in production-tested sources:

- **Zalando RESTful API Guidelines** — Industry gold standard for REST APIs
- **Sairyss/backend-best-practices** — TypeScript/Node production patterns
- **Sairyss/domain-driven-hexagon** — DDD architecture decision criteria
- **OWASP API Security Project** — API Security Top 10
- **Mercari PRR + bregman-arie/sre-checklist** — Production readiness criteria
- **garrytan/gstack** — Iron Law debugging methodology

Full attribution: see `LICENSE-ATTRIBUTION.md`.

---

## Languages

Language-agnostic rules with inline branches:
- **Node.js/TypeScript**: pino, zod, BullMQ, TypeORM, Knex
- **Python**: structlog, Pydantic, Celery, SQLAlchemy
- **Go**: zerolog, standard library, database/sql

---

## License

Apache 2.0. See `LICENSE` and `LICENSE-ATTRIBUTION.md` for source credits.

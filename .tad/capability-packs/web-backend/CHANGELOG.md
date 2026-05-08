# Changelog

All notable changes to this project will be documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [0.1.0] — 2026-05-07

### Added
- `CAPABILITY.md` — context-sensitive router skill entry, YAML frontmatter for Claude Code
- `CONVENTIONS.md` — naming conventions, directory layout, worked examples (Node.js, Python, Go)
- `references/api-design.md` — 7 API design rules (Zalando/Microsoft sources)
- `references/architecture.md` — 6 architecture rules + 6-pattern decision matrix
- `references/application-logic.md` — 6 DDD/domain logic rules (Sairyss sources)
- `references/database.md` — 6 database rules (identifiers, aggregates, delete strategy)
- `references/security.md` — 7 security rules + OWASP API Security Top 10 mapping
- `references/production.md` — 46-item production readiness checklist (3 tiers)
- `references/infrastructure.md` — 7 infrastructure rules (K8s, Terraform, logging)
- `references/debugging.md` — 4 debugging rules (Iron Law, 3-Strike Rule)
- `scripts/api-lint.sh` — Spectral OWASP + naming conventions
- `scripts/schema-check.sh` — Atlas lint + SQLFluff + soft-delete check
- `scripts/security-scan.sh` — Secrets detection + dependency audit + OFFAT
- `scripts/readiness-score.sh` — 25-point Tier 1 automated readiness score
- `install.sh` — Claude Code installer with Phase 3 stubs (Codex/Cursor/Gemini)
- `LICENSE-ATTRIBUTION.md` — Full source attribution (Zalando, OWASP, Sairyss, Mercari, etc.)

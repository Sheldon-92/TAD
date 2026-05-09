---
task_type: mixed
e2e_required: no
research_required: yes
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Web Backend Capability Pack

**From:** Alex | **To:** Blake | **Date:** 2026-05-07
**Project:** Independent repo (not TAD)
**Epic:** EPIC-20260507-agent-capability-packs (parallel to web-ui-design + product-thinking)

---

## 1. Task Overview

Build a **Web Backend Capability Pack** — domain judgment rules that make any AI agent write backend code like a senior engineer. Not a reference document. Not a tool list. A judgment framework with 43 concrete decision rules, executable validation scripts, and real-world conventions.

**Core idea**: AI agents write backend code that "looks right but won't survive production." This pack embeds the decision rules a senior backend engineer applies automatically — rules the AI doesn't know because they come from production experience, not training data.

**Key distinction from TAD Domain Packs**: Domain Pack YAML listed tools and quality criteria that agents ignored. This Capability Pack encodes **judgment** — specific "if X then Y" rules with executable validation commands.

**Phase 1 target: Claude Code.** Same install.sh pattern as web-ui-design.

---

## 2. Research Foundation

- **Notebook (curated):** `75a22e54-4d5e-486c-b2c4-b3b3e035c414` — 20 sources, 0 duplicates
- **Notebook (broad):** `20c498da-7a87-442e-88ed-1b1b57571908` — 41 sources (has duplicates, use curated notebook)
- **Research findings:** `.tad/evidence/research/web-backend-capability-pack/2026-05-07-curated-findings.md`
- **Key references:**
  - Zalando RESTful API Guidelines (industry gold standard)
  - Microsoft API Guidelines
  - Sairyss/backend-best-practices (TypeScript+Node, language-agnostic principles)
  - Sairyss/domain-driven-hexagon (architecture decision criteria)
  - Mercari Production Readiness Checklist (real company PRR)
  - OWASP API Security Project
  - mgechev/skills-best-practices (how to write effective skills)
  - addyosmani/agent-skills (production-grade skill patterns)
  - JustSteveKing/api-skill (CONVENTIONS.md pattern)
  - garrytan/gstack investigate (Iron Law debugging)

---

## 3. Architecture

### 3.1 File Structure

```
web-backend/
├── CAPABILITY.md            # Main skill entry (<800 lines, ZERO inline rules)
│                            # YAML frontmatter: name + description
│                            # Workflow: context router → load relevant references
│                            # Pure router + anti-skip table, all rules in references/
│
├── CONVENTIONS.md           # Naming conventions + directory layout + code examples
│                            # Language-agnostic with "If Node: / If Python: / If Go:" branches
│                            # Per-pattern worked examples (REST endpoint, DB migration, etc.)
│
├── references/
│   ├── api-design.md           # 7 API design judgment rules + Zalando/Microsoft standards
│   ├── architecture.md         # 6 architecture rules + decision matrix (Simple Layered/Clean/Hex/DDD/CQRS/ES)
│   ├── application-logic.md    # 6 DDD/domain logic rules (error handling, CQRS, Value Objects)
│   ├── database.md             # 6 database/data modeling rules + query patterns
│   ├── security.md             # OWASP API Top 10 + 7 security rules + tool commands
│   ├── production.md           # 46-item production readiness checklist, 3 tiers (automatable/attestation/infra-dependent)
│   ├── infrastructure.md       # 7 infrastructure/DevOps rules (K8s, Terraform, logging)
│   └── debugging.md            # 4 debugging judgment rules (Iron Law, 3-Strike Rule)
│
├── scripts/
│   ├── api-lint.sh          # Spectral + naming consistency check
│   ├── schema-check.sh      # Atlas lint + SQLFluff
│   ├── security-scan.sh     # OFFAT scan + secrets detection + dependency audit
│   └── readiness-score.sh   # Tier 1 automated scoring only (X/~25 PASS, Tier 2-3 presented for human attestation)
│
├── install.sh               # Install to Claude Code / Codex / Cursor (Phase 1+3 stubs)
├── README.md                # Human-facing docs
├── LICENSE                  # Apache 2.0
├── LICENSE-ATTRIBUTION.md   # Source attribution (Zalando, OWASP, Sairyss, etc.)
└── CHANGELOG.md
```

### 3.2 CAPABILITY.md Workflow

The main SKILL.md is NOT a reference document — it's a **context-sensitive router** that detects what the user is doing and loads the right reference:

```
User says something about backend
  ↓
Step 0: Context Detection
  - "design API / new endpoint / API review" → Load references/api-design.md
  - "choose architecture / tech stack / framework" → Load references/architecture.md
  - "database / schema / query / migration" → Load references/database.md
  - "security / auth / OWASP / hardening" → Load references/security.md
  - "deploy / ship / production / launch" → Load references/production.md
  - "infrastructure / K8s / Terraform / logging" → Load references/infrastructure.md
  - "debug / fix / investigate / bug" → Load references/debugging.md
  - "review my code / full audit" → Load ALL references sequentially
  ↓
Step 1: Apply Rules
  - Read the loaded reference
  - Apply each rule as a judgment check against the user's code/design
  - For each violated rule: state the violation + the specific fix
  ↓
Step 2: Run Validation Scripts (if applicable)
  - For API work: `bash scripts/api-lint.sh <openapi-spec-path>`
  - For DB work: `bash scripts/schema-check.sh <schema-path>`
  - For security: `bash scripts/security-scan.sh <project-root>`
  - For shipping: `bash scripts/readiness-score.sh <project-root>`
  ↓
Step 3: Output
  - Structured findings with severity (P0/P1/P2)
  - Specific fix commands (not "consider fixing" but "run this command")
  - Score where applicable (e.g., readiness: 38/46 PASS)
```

### 3.3 The 35 Decision Rules (organized by reference file)

**references/api-design.md (7 rules)**
1. Use cursor pagination, not offset, for datasets >10K rows
2. Require empirical evidence before implementing batch operations (prefer bulk)
3. GET requests must never have business logic side effects
4. Use whitelisting, not blacklisting, for Response DTOs
5. Never accept authentication material in URLs
6. For API endpoints: reject non-HTTPS requests (do not redirect). For browser-facing web apps: use HSTS + 301 redirect (RFC 6797).
7. Prefer event-driven delivery (webhooks, SSE, WebSocket) over polling for real-time data. If serverless (no persistent connections): use exponential-backoff polling with ETag/If-Modified-Since.

**references/architecture.md (6 rules + decision matrix)**
1. Never break the "one-hop rule" for service communication
2. Do not share SDKs between services — prefer APIs
3. Never proxy foreign resources by default — return reference URLs
4. [If microservices:] Avoid monolith-to-microservice HTTP calls
5. New services MUST NOT require proxying through other services
6. All error responses MUST use RFC 9457 Problem Details format (consistency across endpoints)
+ Decision matrix: **Simple Layered (MVC)** / Clean / Hexagonal / DDD / CQRS / Event Sourcing
  - Simple Layered row: "RIGHT for: MVPs, CRUD apps, small teams. OVERKILL for: nothing — this is the baseline."
  - Each advanced pattern: when RIGHT vs OVERKILL (from research Q3)
  - Includes anti-overengineering rules
+ API versioning default: URL-path (/v1/) for public APIs, header versioning for internal APIs

**references/application-logic.md (6 rules) — NEW, from research Q5 DDD section**
1. Do not throw HTTP exceptions from domain core — return explicit error types (Result/Either)
2. Return recoverable errors, throw unrecoverable ones (OOM, disk full)
3. Don't execute commands from command handlers — use events (Command→Event→Command)
4. Bypass domain model for read queries — query DB directly from query handler
5. Don't serialize Value Objects to external boundaries — convert to primitives first
6. Limit inheritance depth to 1-2 levels, prefer composition

**references/database.md (6 rules)**
1. Never use in-memory databases for integration/E2E tests
2. Use time-ordered identifiers (UUIDv7 or ULID) for distributed systems and public-facing IDs. Auto-incrementing IDs acceptable for internal single-database tables with high write volume. Never expose auto-incrementing IDs in public APIs.
3. Set external dependency timeouts to p99 latency + small buffer
4. Only Aggregate Roots can be queried directly; traverse for others
5. Don't force transactions across aggregates — use Sagas/Outbox
6. Use soft-deletes for entities needing audit trail/recoverability. Use hard-deletes for PII under GDPR/regulatory erasure. Soft-deletes require retention policy + partial index on `deleted_at IS NULL`.

**references/security.md (7 explicit rules + OWASP mapping)**
1. Always validate JWT signature server-side — never trust client-decoded claims
2. Rate limit by authenticated user, not by IP alone (IP = shared NATs, VPNs)
3. Never return different error messages for "user not found" vs "wrong password" (enumeration attack)
4. Secrets in env vars or secrets manager, never in code or config files committed to git
5. Input validation at system boundary: whitelist allowed characters, reject everything else
6. CORS: explicit allowed origins, never wildcard (*) with credentials
7. Dependency audit: run `npm audit` / `pip-audit` / `go vuln check` before every release
+ OWASP API Security Top 10 mapped to specific Spectral ruleset checks
+ Tool commands: `npx @stoplight/spectral-cli lint --ruleset .spectral-owasp.yaml`
+ Secrets detection: regex patterns for common API key formats

**references/production.md (46 items, 3 tiers)**
- **Tier 1 — Automatable (~25 items)**: script-verifiable checks (secrets not hardcoded, structured logging, TLS enforced, health endpoints exist, etc.)
- **Tier 2 — Human Attestation (~12 items)**: org/process items (on-call rotation, escalation policies, service owner designated, RFC published)
- **Tier 3 — Infrastructure-Dependent (~9 items)**: only applicable if target infra exists (HPA tested, read replicas configured, chaos engineering run)
- readiness-score.sh scores Tier 1 ONLY → outputs "X/25 automated checks PASS, 12 items require human attestation, 9 items infra-dependent"
- Each item: description + PASS/FAIL criteria + verification command (Tier 1) or attestation prompt (Tier 2-3)
- Derived from: Mercari PRR + Google SRE + microservice-production-readiness

**references/infrastructure.md (7 rules)**
1. K8s: Set CPU requests always. Set CPU limits in multi-tenant clusters (noisy-neighbor prevention). Omit CPU limits only in single-tenant clusters. Never set CPU limits equal to requests (causes immediate throttling under burst).
2. Never install ArgoCD via kubectl or Helm — use hosted instance
3. Prefer for_each over count in Terraform
4. Never put provider code in reusable Terraform modules
5. Write logs to stdout/stderr in JSON format, not files
6. Use non-blocking background jobs by default (return 202 Accepted)
7. Graceful shutdown sequencing: stop new → finish current → close connections → exit

**references/debugging.md (4 rules)**
1. 3-Strike Rule: 3 failed hypotheses → question the architecture, not the hypothesis
2. Never apply a fix you cannot verify with a failing-then-passing test
3. Flag fixes touching >5 files — review blast radius before proceeding
4. Iron Law: never fix symptoms without root cause investigation

### 3.4 Language-Agnostic with Inline Branches

Rules are stated in universal terms. Where language-specific, use inline branches:

```markdown
**Rule: Structured Logging**
Write all logs to stdout in JSON format.
- If Node.js: use `pino` (fastest) or `winston`. NOT `console.log`.
- If Python: use `structlog` or `python-json-logger`. NOT `logging.basicConfig`.
- If Go: use `zerolog` or `zap`. NOT `log.Println`.
```

No separate adapter files — inline branches keep the file count low and avoid 80% content duplication.

### 3.5 Anti-Skip Table (from skills-best-practices)

CAPABILITY.md includes an anti-skip table — common excuses the agent uses to skip rules, with counter-arguments:

| Excuse | Counter |
|--------|---------|
| "This is just a prototype" | Prototypes become production. Apply soft-delete + structured logging now. |
| "I'll add tests later" | Later never comes. Write the test that exercises the rule violation NOW. |
| "The user didn't ask for security" | Security is not a feature request. Run security-scan.sh regardless. |
| "This is overkill for a small project" | These are the rules MOST important for small projects — big teams catch mistakes in code review; solo devs rely on the pack. |

---

## 4. Implementation Steps

### P1: Scaffold (estimated: 30 min)
1. Create ~/web-backend/ directory
2. `git init` + create initial files (README, LICENSE, CHANGELOG, install.sh)
3. Write CAPABILITY.md YAML frontmatter + top-level workflow (Steps 0-3)

### P2: Core Rules (estimated: 2 hours)
1. Write references/api-design.md — 7 rules with Zalando/Microsoft citations
2. Write references/architecture.md — 5 rules + decision matrix (5 patterns)
3. Write references/database.md — 6 rules with Atlas/SQLFluff commands
4. Write references/security.md — OWASP mapping + tool commands
5. Write references/infrastructure.md — 7 rules with K8s/Terraform specifics
6. Write references/debugging.md — 4 rules with Iron Law

### P3: Production Readiness (estimated: 1 hour)
1. Write references/production.md — 46 items grouped by 5 categories
2. Each item: description + PASS/FAIL criteria + verification command
3. Source from Mercari PRR + SRE checklist + microservice PRR

### P4: Conventions & Examples (estimated: 1 hour)
1. Write CONVENTIONS.md — directory layout + naming tables
2. Add worked examples: REST endpoint, DB migration, error handling, auth middleware
3. Language branches: Node.js/TypeScript, Python, Go

### P5: Validation Scripts (estimated: 1 hour)
1. Write scripts/api-lint.sh — wraps Spectral CLI + naming consistency
2. Write scripts/schema-check.sh — wraps Atlas lint + SQLFluff
3. Write scripts/security-scan.sh — wraps OFFAT + secrets grep + dependency audit
4. Write scripts/readiness-score.sh — parses production.md, runs checks, outputs X/46

### P6: Installation & Attribution (estimated: 30 min)
1. Write install.sh (same pattern as web-ui-design: --agent flag with Phase 3 stubs)
2. Write LICENSE-ATTRIBUTION.md (Zalando, OWASP, Sairyss, Mercari, etc.)
3. Final README.md

---

## 5. Line Budget

| File | Estimated Lines | Purpose |
|------|----------------|---------|
| CAPABILITY.md | ~600 | Pure router + anti-skip table + context detection (ZERO inline rules) |
| CONVENTIONS.md | ~600 | Naming + layout + worked examples (3 languages) |
| references/ (8 files) | ~2400 total | 43 rules + 46 PRR items + tool commands |
| scripts/ (4 files) | ~400 total | Executable validation with dependency preflight |
| install.sh | ~150 | Multi-agent installer |
| Other (README, LICENSE, etc.) | ~200 | Documentation |
| **Total** | **~4350** | (under 5000 AC14 cap) |

---

## 6. Acceptance Criteria

- [ ] AC1: ~/web-backend/ repo created with all files from §3.1 file structure (8 reference files, 4 scripts, CAPABILITY.md, CONVENTIONS.md, install.sh)
- [ ] AC2: CAPABILITY.md has YAML frontmatter (name + description) for skill loader
- [ ] AC3: CAPABILITY.md contains ZERO inline rules — all rules live exclusively in references/*.md
- [ ] AC4: All 43 decision rules present across 8 reference files, each marked with `**Rule N:**` prefix
- [ ] AC5: references/production.md has exactly 46 checklist items, split into 3 tiers (Tier 1 automatable ~25, Tier 2 attestation ~12, Tier 3 infra-dependent ~9)
- [ ] AC6: Every rule in references/*.md has at least one inline code block or CLI command (total backtick-lines ≥ 60 across all reference files)
- [ ] AC7: Language branches present for Node.js/Python/Go where tool differs (≥5 branch points)
- [ ] AC8: scripts/ contains 4 .sh files, each passes `bash -n` syntax check and has dependency preflight (command -v check)
- [ ] AC9: install.sh works for --agent=claude-code (Phase 1)
- [ ] AC10: Anti-skip table present in CAPABILITY.md as markdown table with ≥4 rows
- [ ] AC11: LICENSE-ATTRIBUTION.md credits all sources (Zalando, OWASP, Sairyss, Mercari, etc.)
- [ ] AC12: references/architecture.md contains decision matrix for 6 patterns (Simple Layered/Clean/Hex/DDD/CQRS/ES) with "RIGHT vs OVERKILL" criteria
- [ ] AC13: Zero TAD-specific terminology in pack files (grep excluding LICENSE-ATTRIBUTION.md returns 0)
- [ ] AC14: Total line count ≤ 5000 (anti-bloat)
- [ ] AC15: `git init` + initial commit with all files
- [ ] AC16: Every rule with context-dependent advice uses scoped form ("If X context: ... If Y context: ..."), NOT absolute form ("Never use X")
- [ ] AC17: references/application-logic.md exists with 6 DDD rules from research Q5

---

## 7. Important Notes

### 7.1 Content Sources — MUST Directly Borrow, Not Reinvent
Rules come FROM the sources, not from Alex/Blake's imagination. Blake MUST:

**Primary lifting sources (read these repos FIRST, adapt content directly):**
1. **Zalando RESTful API Guidelines** (`zalando/restful-api-guidelines`): API naming, pagination, versioning, error handling rules → lift verbatim into references/api-design.md with attribution
2. **Sairyss/backend-best-practices**: Application logic rules, DDD anti-patterns, testing rules → lift into references/database.md + debugging.md
3. **Sairyss/domain-driven-hexagon**: Architecture decision criteria, DDD patterns → lift into references/architecture.md
4. **Mercari production-readiness-checklist**: PRR items → lift into references/production.md
5. **bregman-arie/sre-checklist**: SRE items → merge into references/production.md
6. **OWASP/API-Security**: API security top 10 → lift into references/security.md
7. **JustSteveKing/api-skill**: CONVENTIONS.md structure (naming tables + worked examples) → adapt for CONVENTIONS.md
8. **addyosmani/agent-skills + mgechev/skills-best-practices**: SKILL.md structure patterns → adapt for CAPABILITY.md workflow

**Process:**
- Step 1: `gh api repos/{org}/{repo}/git/trees/main?recursive=1` to find key files
- Step 2: Read the actual content from each source (WebFetch or gh api contents)
- Step 3: Adapt (not copy verbatim) into pack format with attribution
- Step 4: Fill gaps from NotebookLM notebook `75a22e54` ask results

**NOT acceptable:** Making up rules that sound plausible but aren't grounded in a specific source. Every rule in references/*.md must have a `[Source: repo-name]` attribution tag.

- Research findings summary: `.tad/evidence/research/web-backend-capability-pack/2026-05-07-curated-findings.md`
- Curated notebook for deep questions: `75a22e54-4d5e-486c-b2c4-b3b3e035c414`

### 7.2 Key Design Principle
**Pack = domain judgment. TAD = process constraint. No overlap.**
The pack tells the agent WHAT to check (35 rules). TAD tells the agent HOW to work (gates, review, isolation). The pack must never reimport TAD mechanisms.

### 7.3 Anti-Patterns (from research)
- ❌ Listing tool names without usage commands ("Use Spectral" → useless)
- ❌ Generic advice without decision criteria ("Consider caching" → useless)
- ❌ Over-engineering the pack itself (scripts/ should be simple wrappers, not frameworks)
- ❌ Framework-specific content without language-agnostic foundation
- ❌ >5000 lines total (context bloat = agent ignores the pack)

### 7.4 Precedent
Follow ~/web-ui-design-capability/ structure as template. Key differences:
- web-ui-design has checklists/ + tools/ directories → web-backend uses references/ + scripts/
- web-ui-design CAPABILITY.md is 1197 lines → target 800 for web-backend (simpler workflow)
- Both use install.sh with --agent stubs for Phase 3

---

## Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/capability-pack-web-backend/code-reviewer.md
  - .tad/evidence/reviews/blake/capability-pack-web-backend/backend-architect.md
gate_verdicts:
  - .tad/evidence/completions/capability-pack-web-backend/GATE3-REPORT.md
completion:
  - .tad/active/handoffs/COMPLETION-20260507-capability-pack-web-backend.md
knowledge_updates:
  - .tad/project-knowledge/architecture.md (if new patterns discovered)
```

---

## 9.2 Expert Review Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0-1: 6 DDD rules missing from 35-rule count | Added references/application-logic.md (8th file), total now 43 | Resolved |
| code-reviewer | P0-2: AC4 grep counts headings not rules | Changed to `grep -rcE '^\*\*Rule [0-9]+'` with consistent rule prefix | Resolved |
| code-reviewer | P0-3: AC5 grep matches prose, not checklist items | Changed to `grep -cE '^\- \[[ x]\] \*\*PC-[0-9]+'` numbered prefix | Resolved |
| code-reviewer | P0-4: AC6 no threshold, multi-file grep output | Added threshold ≥60, uses awk to sum | Resolved |
| code-reviewer | P0-5: AC13 TAD-leak exception weakens AC | Added `--exclude='LICENSE-ATTRIBUTION.md'`, expected = 0 | Resolved |
| backend-architect | P0-2: "Use ULIDs" too absolute | Rewritten: UUIDv7/ULID for distributed, auto-increment OK for internal high-write | Resolved |
| backend-architect | P0-3: "Never set CPU limits in K8s" dangerous | Rewritten: context-scoped for multi-tenant vs single-tenant | Resolved |
| backend-architect | P0-4: "Soft-deletes by default" contradicts GDPR | Rewritten: soft-delete for audit, hard-delete for PII/GDPR | Resolved |
| backend-architect | P0-5: 46-item checklist mixes automatable + human | Split into 3 tiers, readiness-score.sh scores Tier 1 only | Resolved |
| backend-architect | P0-6: "Fail hard on HTTP" wrong for web apps | Rewritten: API = reject, browser = HSTS + 301 (RFC 6797) | Resolved |
| backend-architect | P0-7: "No polling" too absolute | Rewritten: prefer event-driven, serverless fallback to backoff polling | Resolved |
| backend-architect | P1-1: Missing Simple Layered/MVC in matrix | Added as first row: "RIGHT for MVPs/CRUD, OVERKILL for nothing" | Resolved |
| backend-architect | P1-2: Security rules underspecified | Added 7 explicit security rules (JWT, rate limit, enumeration, etc.) | Resolved |
| backend-architect | P1-6: Missing RFC 9457 error format rule | Added to architecture.md rule 6 | Resolved |
| backend-architect | P1-7: No API versioning strategy | Added to architecture.md: URL-path for public, header for internal | Resolved |
| code-reviewer | P1-1: CAPABILITY.md must be pure router | Added AC3: ZERO inline rules, explicit statement in file structure | Resolved |
| code-reviewer | P1-6: Scripts need dependency preflight | Added to AC8: all scripts must have `command -v` check | Resolved |

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训

- **Capability Pack: YAML Frontmatter is Load-Bearing** (architecture.md, 2026-05-07): CAPABILITY.md 必须有 YAML frontmatter (`name:` + `description:`) 否则 skill loader 不会注册
- **Capability Pack: Multi-Agent Install Pattern** (architecture.md, 2026-05-07): install.sh 用 --agent flag + Phase 3 stubs
- **Anti-AI-Slop Philosophy** (architecture.md, 2026-04-25): 每个 anti-pattern 要配正面标准
- **Codex-Edition SKILL: Strip-Only Rule** (architecture.md, 2026-05-01): 如果未来做 Codex 版本，只能删不能加

---

## 9. Spec Compliance Checklist

| AC# | Verification Method | Expected Evidence |
|-----|-------------------|-------------------|
| AC1 | `ls ~/web-backend/ ~/web-backend/references/ ~/web-backend/scripts/` | All files from §3.1 present (8 .md in references/, 4 .sh in scripts/) |
| AC2 | `head -5 ~/web-backend/CAPABILITY.md` | YAML frontmatter with name + description |
| AC3 | `grep -cE '^\*\*Rule' ~/web-backend/CAPABILITY.md` | 0 (ZERO inline rules — all in references/) |
| AC4 | `grep -rcE '^\*\*Rule [0-9]+' ~/web-backend/references/*.md` | Total ≥43 across 8 files |
| AC5 | `grep -cE '^\- \[[ x]\] \*\*PC-[0-9]+' ~/web-backend/references/production.md` | 46 (numbered checklist items) |
| AC6 | `grep -rc '`' ~/web-backend/references/*.md \| awk -F: '{s+=$NF} END{print s}'` | ≥60 |
| AC7 | `grep -rcE 'If Node\|If Python\|If Go' ~/web-backend/references/*.md ~/web-backend/CONVENTIONS.md` | ≥5 |
| AC8 | `for f in ~/web-backend/scripts/*.sh; do bash -n "$f" && echo "OK: $f"; done` + `grep -l 'command -v' ~/web-backend/scripts/*.sh \| wc -l` | All 4 syntax OK + all 4 have preflight |
| AC9 | `bash ~/web-backend/install.sh --agent=claude-code --dry-run 2>&1` | Exit 0 |
| AC10 | `grep -cE '^\|.*\|.*\|' ~/web-backend/CAPABILITY.md` | ≥6 (anti-skip table markdown rows) |
| AC11 | `grep -cE 'Zalando\|OWASP\|Sairyss\|Mercari' ~/web-backend/LICENSE-ATTRIBUTION.md` | ≥4 |
| AC12 | `grep -cE 'Simple Layered\|Clean\|Hexagonal\|DDD\|CQRS\|Event Sourcing' ~/web-backend/references/architecture.md` | ≥6 |
| AC13 | `grep -rnE '\bTAD\b\|handoff\|Gate [1-4]\|Ralph Loop\|\bBlake\b\|\bAlex\b' ~/web-backend/ --include='*.md' --include='*.sh' --exclude='LICENSE-ATTRIBUTION.md'` | 0 |
| AC14 | `find ~/web-backend/ \( -name '*.md' -o -name '*.sh' \) -exec cat {} + \| wc -l` | ≤5000 |
| AC15 | `cd ~/web-backend && git log --oneline -1` | Initial commit exists |
| AC16 | `grep -rcE 'If .+:' ~/web-backend/references/database.md ~/web-backend/references/infrastructure.md ~/web-backend/references/api-design.md` | ≥5 (context-scoped rules) |
| AC17 | `wc -l ~/web-backend/references/application-logic.md` | File exists, ≥30 lines |

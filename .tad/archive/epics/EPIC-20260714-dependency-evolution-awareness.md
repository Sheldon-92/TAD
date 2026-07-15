# Epic: Dependency Evolution Awareness

**Epic ID**: EPIC-20260714-dependency-evolution-awareness
**Created**: 2026-07-14
**Owner**: Alex

---

## Objective
Build a project-level dependency evolution awareness system that lets the user know when key external dependencies (OpenClaw, Supabase, NotebookLM, etc.) have evolved — new capabilities that could simplify existing code, breaking changes that need attention — while enforcing a safety buffer to avoid supply-chain risks. Each project maintains its own rich registry; a periodic scan checks upstream; Alex surfaces relevant changes at startup.

## Success Criteria
- [ ] Every TAD-managed project can maintain a `.tad/dependencies/REGISTRY.yaml` with rich fields (capabilities_used, files_depending, known_limitations)
- [ ] Periodic upstream scanning detects new versions, changelogs, and security advisories
- [ ] Alex startup shows dependency evolution status with noise filtering (only relevant + past safety buffer)
- [ ] Safety buffer L1(7d)/L2(14d)/L3(30d) enforced; urgent_security bypasses buffer
- [ ] Known limitations resolved by upstream are detected and surfaced ("workaround removable")

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Registry + Init | ✅ Done | HANDOFF-20260714-deps-registry-init.md | REGISTRY.yaml schema + `*deps init` semi-auto scan + `*deps` show + `*deps add` |
| 2 | Upstream Scan | ✅ Done | HANDOFF-20260714-deps-upstream-scan.md | Scan script + scheduled task + scan-results.yaml cache + `*deps check` |
| 3 | Alex Integration | ✅ Done | HANDOFF-20260714-deps-alex-integration.md | STEP 3.5b startup integration + safety buffer logic + relevance filter + limitation resolution detection |

### Phase Dependencies
All phases are sequential: P2 depends on P1 (needs registry to know what to scan), P3 depends on P2 (needs scan results to display).

### Derived Status
Status and progress are computed from the Phase Map:
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ → Complete
- **Progress**: Count of ✅ Done / Total phases

---

## Phase Details

### Phase 1: Registry + Init

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
Create the dependency registry schema and the `*deps init` command that semi-automatically scans a project's files (package.json, requirements.txt, code imports) to infer key dependencies, then lets the user confirm and enrich with detailed information (capabilities_used, known_limitations, integration_context). Also implement `*deps` (show registry) and `*deps add` (manual registration). NOT in scope: upstream scanning, scheduled tasks, Alex startup integration, or safety buffer logic (those are P2/P3).

#### Input
- Existing project structures across all user projects (scanned in *discuss: ~20 key deps across ~15 active projects)
- Design from Socratic Inquiry: registry schema with 6 top-level fields (name, type, safety_tier, current_version, upstream, usage, known_limitations)
- GitHub Registry scan pattern (.tad/github-registry/) as architectural reference

#### Output
- `.tad/dependencies/REGISTRY.yaml` schema (documented, versioned)
- `.tad/templates/deps-registry-template.yaml` — empty template for new projects
- `*deps init` command in Alex SKILL.md — semi-auto scan + interactive enrichment
- `*deps` command — display registry in readable format
- `*deps add` command — manually register a single dependency
- TAD project's own REGISTRY.yaml populated (dogfood)

#### Acceptance Criteria
- [ ] REGISTRY.yaml schema supports all designed fields: name, type (incl library), safety_tier, current_version, version_pinned_at, status, upstream (repo, registry as open string, changelog_url), usage (capabilities_used, files_depending, integration_context), known_limitations (id, description, workaround, resolved_by_upstream), last_checked, notes
- [ ] `*deps init` scans package.json / requirements.txt / pyproject.toml and extracts dependency names + versions; presents to user via AskUserQuestion for confirmation
- [ ] `*deps init` prompts user to enrich each confirmed dependency with capabilities_used and known_limitations (not just name+version)
- [ ] `*deps` displays registry in a readable table format with status summary
- [ ] `*deps add <name>` registers a single new dependency interactively
- [ ] TAD project itself has a populated REGISTRY.yaml with ≥5 real dependencies (dogfood)
- [ ] Template file exists at `.tad/templates/deps-registry-template.yaml` with commented example entry
- [ ] `.tad/dependencies/` added to ZERO_TOUCH in derive-sync-set.sh (project data excluded from sync)
- [ ] Commands routed via explicit_commands + route_targets in Alex SKILL.md

#### Files Likely Affected
- `.tad/dependencies/REGISTRY.yaml` (CREATE)
- `.tad/templates/deps-registry-template.yaml` (CREATE)
- `.claude/skills/alex/SKILL.md` (MODIFY — add *deps, *deps init, *deps add commands)
- `.tad/hooks/lib/derive-sync-set.sh` (MODIFY — add dependencies/ to sync awareness)

#### Dependencies
None (can execute independently)

#### Notes
- Semi-auto scan is the key UX: user should NOT have to type everything from scratch. Alex infers, user confirms + enriches.
- The "enrichment" step (capabilities_used, known_limitations) is where the real value is. Without it, the registry is just another package.json.
- For TAD dogfood: register NotebookLM CLI, GitHub Registry (gh CLI), Playwright (if used by tests), and any other TAD infrastructure deps.

### Phase 2: Upstream Scan

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
Build the upstream scanning mechanism: a script that reads REGISTRY.yaml, queries GitHub Releases API / npm / PyPI for each dependency's latest version and changelog, uses LLM to assess relevance against capabilities_used, and writes results to scan-results.yaml. Wire it to a scheduled task (cron/schedule pattern). Also implement `*deps check` for manual trigger. NOT in scope: Alex startup display, safety buffer enforcement, or limitation resolution detection (those are P3).

#### Input
- Phase 1 output: populated REGISTRY.yaml with rich fields
- GitHub token for API rate limits (existing gh auth)
- Scheduled task infrastructure (cron/schedule pattern from GitHub Registry scan)

#### Output
- `.tad/hooks/lib/deps-scan.sh` — scanning script
- `.tad/dependencies/scan-results.yaml` — cached scan output
- Scheduled task registration (weekly scan)
- `*deps check` command in Alex SKILL.md

#### Acceptance Criteria
- [ ] `deps-scan.sh` reads REGISTRY.yaml and queries upstream for each dependency
- [ ] GitHub Releases API queries work with authenticated gh CLI (rate limit: 5000/h)
- [ ] npm/PyPI queries work for registered package-type dependencies
- [ ] Changelog text captured raw in scan-results.yaml (LLM relevance assessment deferred to Phase 3)
- [ ] scan-results.yaml captures: upstream_latest, released date, days_since_release, changelog_text (raw), security_advisories
- [ ] `*deps check` triggers immediate scan (bypasses cache) and refreshes scan-results.yaml
- [ ] Scheduled task runs weekly (same pattern as GitHub Registry scan)
- [ ] Scan completes within 60 seconds for ≤20 dependencies

#### Files Likely Affected
- `.tad/hooks/lib/deps-scan.sh` (CREATE)
- `.tad/dependencies/scan-results.yaml` (CREATE — by scan script)
- `.claude/skills/alex/SKILL.md` (MODIFY — add *deps check command)
- Scheduled task config (CREATE — cron prompt file)

#### Dependencies
Phase 1

#### Notes
- **Design revision**: LLM relevance assessment deferred to Phase 3 (scan collects raw data only — no Claude CLI dependency). Scan script writes raw changelog text; Phase 3 does LLM judgment in Alex's conversation context.
- Rate limit: GitHub API 5000/h authenticated. For 20 deps, well within limit.
- Error handling: if a dependency's upstream repo is unreachable, log warning and continue (don't fail entire scan).
- **Expected skip rate**: 3/6 TAD dogfood deps have registry: null and will produce scan_status: skipped. This is acceptable — null-registry deps can be enriched later.
- **Security**: Input validation on all REGISTRY fields before shell interpolation. Option A (JSON→YAML) required for output. GraphQL uses parameterized variables.

### Phase 3: Alex Integration

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
Wire scan results into Alex's startup health check (new STEP 3.5b), implement safety buffer logic (L1/L2/L3 tier enforcement with buffer_status computation), relevance-based noise filtering, and known-limitation resolution detection (when upstream resolves a registered limitation, surface "workaround removable" message). Also implement `*deps update <name>` to record that a dependency was upgraded. NOT in scope: auto-upgrading code, dependency replacement recommendations beyond limitation resolution.

#### Input
- Phase 1 output: REGISTRY.yaml with known_limitations
- Phase 2 output: scan-results.yaml with relevant_changes
- Alex SKILL.md startup protocol (STEP 3.x sequence)

#### Output
- Alex STEP 3.5b: Dependency Evolution Check (startup integration)
- Safety buffer computation logic (days_since_release vs safety_tier threshold)
- Limitation resolution detection (relevant_changes.resolves_limitation matches known_limitations.id)
- `*deps update <name>` command
- Noise filter: only show relevance >= MEDIUM AND buffer_status == evaluable

#### Acceptance Criteria
- [ ] Alex STEP 3.5b reads scan-results.yaml at startup and shows dependency status summary
- [ ] buffer_status computed correctly: observing (within buffer), evaluable (past buffer), urgent_security (security advisory)
- [ ] Only evaluable + relevance >= MEDIUM changes shown at startup (noise filter)
- [ ] When a relevant_change has resolves_limitation matching a known_limitations.id, message includes "workaround {id} may be removable"
- [ ] `*deps update <name> --version <v>` updates current_version in REGISTRY.yaml and clears related scan-result entries
- [ ] urgent_security bypasses buffer and shows immediately with warning
- [ ] Startup check adds ≤2 seconds to Alex activation (non-blocking, read-only)

#### Files Likely Affected
- `.claude/skills/alex/SKILL.md` (MODIFY — add STEP 3.5b, *deps update command)
- `.tad/dependencies/scan-results.yaml` (READ at startup)
- `.tad/dependencies/REGISTRY.yaml` (MODIFY by *deps update)

#### Dependencies
Phase 2

#### Notes
- STEP 3.5b placement: after STEP 3.5 (document health check), before STEP 3.55 (zombie cleanup). Independent of zombie detection.
- Performance: scan-results.yaml is a small file (≤20 entries). Reading + filtering is negligible.
- The limitation resolution detection is the highest-value feature — it's the "你的 workaround 可以移除了" insight that no other tool provides.

---

## Context for Next Phase
{Alex updates this section after each *accept}

### Completed Work Summary
- Phase 1: Registry schema (11 fields) + *deps init/show/add commands + template + TAD dogfood (6 deps) + ZERO_TOUCH sync exclusion. Commit 2b816f0. Gate 4 PASS 11/11 AC.
- Phase 2: deps-scan.sh (~300L bash) + scan-results.yaml + *deps-check + cron prompt. Security: input validation + GraphQL parameterization + JSON→YAML + error sanitization. Dogfood: 3/6 scanned (gh, yq, jq all version_changed:true), 3/6 skipped (registry:null). First real finding: jq 1.8.2 has 14 CVE fixes vs installed 1.7.1. Commit e407bbd. Gate 4 PASS 11/11 AC.
- Phase 3: STEP 3.5b startup protocol (~61 lines body) + safety buffer (L1/L2/L3) + CVE dual-path urgent_security + inline LLM relevance + limitation resolution detection + *deps-update + noise filter. Circular trigger safety verified. Commit 5435a87. Gate 4 PASS 10/10 AC.

### Decisions Made So Far
- Registry is project-level (each project maintains its own)
- TAD's deps flow to downstream via *sync (template only)
- Safety buffer: L1(7d) / L2(14d) / L3(30d) + urgent_security bypass
- Noise filter: only show evaluable + relevance >= MEDIUM at startup
- Known limitation resolution is a first-class feature

### Known Issues / Carry-forward
- P2-1 (cosmetic): deps-protocol.md uses markdown format vs YAML-in-markdown in other references
- Expert review P2s deferred: status field added (ARCH), files_depending staleness accepted, non-GitHub deps documented as graceful degradation

### Next Phase Scope
Phase 3: Alex Integration — STEP 3.5b startup check (read scan-results, LLM relevance assessment against capabilities_used, safety buffer computation), *deps update command, limitation resolution detection, noise filtering (only evaluable + relevance >= MEDIUM).

---

## Notes
- Inspired by GitHub Registry weekly scan pattern (same cron architecture)
- User's core pain: "以前要搭脚手架，后来平台内置了，但我不知道" — limitation resolution detection directly addresses this
- Supply chain safety: litellm 2026-03-24 incident is the grounding evidence for safety buffer design

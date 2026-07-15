---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: [".tad/dependencies", ".tad/templates"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-07-14
**Project:** TAD Framework
**Task ID:** TASK-20260714-001
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260714-dependency-evolution-awareness.md (Phase 1/3)

---

## Gate 2: Design Completeness

**Execution time**: 2026-07-14

### Gate 2 Checklist

| Check | Status | Notes |
|-------|--------|-------|
| Architecture Complete | ✅ | Registry schema designed with 7 top-level fields; *deps commands specified |
| Components Specified | ✅ | REGISTRY.yaml schema, template, 3 Alex commands (*deps, *deps init, *deps add) |
| Functions Verified | ✅ | Follows existing GitHub Registry pattern (.tad/github-registry/) |
| Data Flow Mapped | ✅ | init scans project files → user confirms → enriches → writes REGISTRY.yaml |

**Gate 2 Result**: ✅ PASS

**Alex Confirmation**: I have verified all design elements. Blake can independently complete implementation based on this document.

---

## Handoff Checklist (Blake must read)

- [ ] Read all sections
- [ ] Read Project Knowledge section for historical lessons
- [ ] All mandatory questions have evidence
- [ ] Understand the true intent (not just literal requirements)
- [ ] Each deliverable and evidence requirement is clear
- [ ] Can independently complete implementation using this document

---

## 1. Task Overview

### 1.1 Title
Dependency Evolution Awareness — Phase 1: Registry + Init

### 1.2 Background
The user manages ~15 active projects with ~20 key external dependencies (OpenClaw across 5 projects, Supabase, Next.js, Playwright, F5-TTS, etc.). Once a project starts, knowledge of these dependencies freezes — upstream platforms may add native features that replace custom scaffolding, but the user doesn't know. Phase 1 creates the registry structure so each project can maintain a rich, detailed record of its key dependencies.

### 1.3 Intent Statement
Give every TAD-managed project the ability to declare and describe its key external dependencies in enough detail that future scanning (Phase 2) can determine whether upstream changes are relevant. The registry is NOT a package.json mirror — it captures WHY each dependency is used, WHAT specific capabilities matter, and WHAT known limitations exist.

---

## 2. Requirements

### 2.1 Functional Requirements

**FR1: REGISTRY.yaml Schema**
Create `.tad/dependencies/REGISTRY.yaml` with the following schema:

```yaml
version: 1.0.0
last_updated: YYYY-MM-DD
project: "<project name>"

dependencies:
  - name: "<dependency name>"
    type: platform | framework | api | tool | library
    safety_tier: L1 | L2 | L3
    current_version: "<semver or descriptive>"
    version_pinned_at: YYYY-MM-DD       # When current_version was set (temporal anchor)
    status: active                       # active | deprecated | evaluating (optional, default: active)

    upstream:
      repo: "<owner/repo>"              # GitHub owner/repo (null for non-GitHub)
      registry: "<string>"              # Open string: npm | pypi | github_releases | homebrew | cargo | null
      changelog_url: "<URL>"

    usage:
      capabilities_used:                 # Specific capabilities/APIs used
        - "<capability 1>"
      files_depending:                   # Project files that depend on this
        - "<file path>"
      integration_context: "<1-2 sentence description of role in project>"

    known_limitations:
      - id: "<DEP-NNN>"
        description: "<limitation description>"
        workaround: "<current workaround>"
        resolved_by_upstream: false

    last_checked: YYYY-MM-DD
    notes: "<free text>"
```

**FR2: `*deps init` Command**
Semi-automatic initialization that:
1. Scans project files (package.json, requirements.txt, pyproject.toml, .env.example, docker-compose.yml) to extract dependency names + versions
2. Filters to "key" dependencies (platforms, frameworks, APIs, major tools — not utility packages like lodash)
3. Presents candidate list to user via AskUserQuestion for confirmation
4. For each confirmed dependency, prompts user to enrich:
   - `type` and `safety_tier` (with sensible defaults based on type)
   - `capabilities_used` (what specifically are you using?)
   - `known_limitations` (any workarounds you maintain?)
   - `upstream.repo` (auto-detect from package registry if possible)
5. Writes populated REGISTRY.yaml

**FR3: `*deps` Command**
Display the registry in a readable table:
```
📦 Dependency Registry (5 dependencies)

| Name | Type | Version | Safety | Last Checked | Limitations |
|------|------|---------|--------|-------------|-------------|
| notebooklm-cli | platform | 0.5.2 | L2 (14d) | 2026-07-14 | 2 known |
| gh (GitHub CLI) | tool | 2.x | L1 (7d) | 2026-07-14 | 0 |
```

**FR4: `*deps add` Command**
Manually register a single new dependency:
1. Ask for name
2. Auto-detect type/version if package name found in project files
3. Guide through enrichment (same flow as *deps init per-dependency)
4. Append to REGISTRY.yaml

**FR5: Template File**
Create `.tad/templates/deps-registry-template.yaml` — commented template for new projects:

```yaml
# Dependency Evolution Registry — created by *deps init
# Rich fields enable Phase 2 upstream scanning and Phase 3 limitation resolution detection.
# See: EPIC-20260714-dependency-evolution-awareness.md
version: 1.0.0
last_updated: YYYY-MM-DD
project: "<project name>"

dependencies: []
# Example entry (uncomment and fill):
#  - name: "example-dep"
#    type: platform          # platform | framework | api | tool | library
#    safety_tier: L2         # L1 (7d) | L2 (14d) | L3 (30d)
#    current_version: "1.0.0"
#    version_pinned_at: YYYY-MM-DD
#    status: active          # active | deprecated | evaluating
#    upstream:
#      repo: "owner/repo"
#      registry: "npm"       # npm | pypi | github_releases | homebrew | cargo | null
#      changelog_url: "https://github.com/owner/repo/releases"
#    usage:
#      capabilities_used:
#        - "Specific API or capability used"
#      files_depending:
#        - "src/path/to/file.ts"
#      integration_context: "One-line description of this dependency's role"
#    known_limitations:
#      - id: "DEP-001"
#        description: "Known limitation"
#        workaround: "Current workaround"
#        resolved_by_upstream: false
#    last_checked: YYYY-MM-DD
#    notes: ""
```

**FR6: TAD Dogfood**
Populate TAD's own REGISTRY.yaml with ≥5 real dependencies. Verified candidates:
- NotebookLM CLI (platform, L2) — research engine backend
- GitHub CLI / gh (tool, L1) — GitHub API access, Registry scan, releases
- yq (tool, L1) — YAML processing in hooks/scripts
- jq (tool, L1) — JSON processing in hooks/scripts
- rsync (tool, L1) — used in *sync and release-verify.sh

**FR7: Sync Awareness**
- Template file (`.tad/templates/deps-registry-template.yaml`) should be in the sync set
- Project-specific REGISTRY.yaml should NOT be synced (each project's data is unique)
- `.tad/dependencies/` directory should be in derive-sync-set.sh awareness — template syncs, REGISTRY.yaml excluded via zero-touch or transient as appropriate

### 2.2 Non-Functional Requirements

- `*deps init` should complete interactive flow in ≤5 minutes for a project with 10 dependencies
- REGISTRY.yaml should be human-readable and hand-editable
- Schema should be forward-compatible (Phase 2 scan-results reference dependency names)

---

## 3. Design Summary

### Architecture
Follows the same pattern as `.tad/github-registry/`:
- YAML registry file as structured data store
- Alex SKILL.md commands as the interaction layer
- Template file for new project bootstrapping

### Data Flow
```
*deps init
  ├─ Read package.json / requirements.txt / pyproject.toml
  ├─ Filter: key dependencies only (LLM judgment)
  ├─ AskUserQuestion: confirm list
  ├─ Per-dependency enrichment (AskUserQuestion)
  └─ Write .tad/dependencies/REGISTRY.yaml

*deps
  └─ Read REGISTRY.yaml → format table → display

*deps add
  ├─ AskUserQuestion: name
  ├─ Auto-detect from project files
  ├─ Enrichment flow
  └─ Append to REGISTRY.yaml
```

---

## 4. Implementation Guidance

### 4.1 Alex SKILL.md Changes
Add to the `commands:` section:
```yaml
deps: "Show dependency registry"
deps-init: "Initialize dependency registry from project scan"
deps-add: "Register a new dependency"
```

Add to the `explicit_commands` array (line ~693 in intent_router_protocol):
```yaml
explicit_commands: ["*bug", "*discuss", ..., "*deps", "*deps-init", "*deps-add"]
```

Add `route_targets` entries mapping each command to its protocol:
```yaml
route_targets:
  deps: deps_show_protocol
  deps-init: deps_init_protocol
  deps-add: deps_add_protocol
```

Add protocol blocks for each command. Command entries + route_targets stay in SKILL.md body; the enrichment flow details go to `.claude/skills/alex/references/deps-protocol.md` (progressive loading, per circular trigger rule).

### 4.2 Smart Filtering in *deps init
When scanning package.json, the "key dependency" filter should:
- INCLUDE: packages listed in Alex's project scan results (OpenClaw, Next.js, Supabase, Playwright, etc.)
- INCLUDE: any package with >1000 GitHub stars (if determinable)
- EXCLUDE: utility packages (lodash, uuid, chalk, etc.)
- EXCLUDE: dev-only tools unless they're frameworks (exclude prettier, include vitest)
- When in doubt: include and let user remove during confirmation

### 4.3 Safety Tier Defaults
```
platform → L2 (14 days)
framework → L3 (30 days) if major version tracking, L2 (14 days) otherwise
api → L1 (7 days)
tool → L1 (7 days)
```
User can override during enrichment.

### 4.4 Sync Set Integration (MANDATORY)
In `derive-sync-set.sh`, `.tad/dependencies/` MUST be added to ZERO_TOUCH:
- The template at `.tad/templates/deps-registry-template.yaml` is a framework file → syncs (already in sync set via `.tad/templates/`)
- `.tad/dependencies/REGISTRY.yaml` is project-specific data → MUST NOT sync to downstream
- **Action**: Add `dependencies` to the ZERO_TOUCH array in derive-sync-set.sh. Without this, the deny-list derivation principle means the new directory defaults to SYNC, which will clobber downstream project registries on next *publish.
- **Verify**: `bash .tad/hooks/lib/derive-sync-set.sh --zero-touch | grep -cxF 'dependencies'` must return 1

---

## 5. Scope

### 5.1 In Scope
- REGISTRY.yaml schema design and creation
- `*deps init` semi-auto initialization command
- `*deps` display command
- `*deps add` manual registration command
- Template file for new projects
- TAD dogfood (populate TAD's own registry)
- Sync awareness (template syncs, registry data doesn't)

### 5.2 Out of Scope
- Upstream scanning (Phase 2)
- Scheduled tasks (Phase 2)
- Alex startup integration (Phase 3)
- Safety buffer enforcement logic (Phase 3)
- `*deps check` or `*deps update` commands (Phase 2/3)

---

## 6. Files to Modify

| File | Action | Description |
|------|--------|-------------|
| `.tad/dependencies/REGISTRY.yaml` | CREATE | TAD's own dependency registry (dogfood) |
| `.tad/templates/deps-registry-template.yaml` | CREATE | Empty template for new projects |
| `.claude/skills/alex/SKILL.md` | MODIFY | Add *deps, *deps init, *deps add commands + protocols |
| `.claude/skills/alex/references/deps-protocol.md` | CREATE | Extracted protocol details (progressive loading) |
| `.tad/hooks/lib/derive-sync-set.sh` | MODIFY | Add dependencies/ to ZERO_TOUCH (MANDATORY) |

---

## 7. Testing Checklist

- [ ] `*deps init` scans TAD's package files and produces a populated REGISTRY.yaml
- [ ] `*deps` displays the registry in readable table format
- [ ] `*deps add` successfully appends a new dependency to existing REGISTRY.yaml
- [ ] REGISTRY.yaml is valid YAML (parseable by yq)
- [ ] Template file exists and is valid empty-template YAML
- [ ] TAD dogfood registry has ≥5 real dependencies with enriched fields
- [ ] Each dogfood entry has ≥1 capabilities_used and ≥1 files_depending

---

## 8. Additional Metadata

### 8.1 Priority
Medium — foundational for Phase 2/3 but no urgency

### 8.2 Estimated Effort
Small-Medium — primarily YAML schema + Alex SKILL protocol additions

### 8.3 Risk Assessment
- Low risk: no existing code modified (except SKILL.md command additions)
- Main risk: schema design regret in Phase 2 (mitigated by forward-compatible design)

### 8.4 Friction Preflight
- No external dependencies needed for Phase 1 (no API keys, no new tools)
- yq required for YAML validation (already installed)
- Friction Status: READY

### 8.5 Feedback Collection
- feedback_required: false (infrastructure, not UI)

---

## 9. Acceptance Criteria

### 9.1 Spec Compliance Checklist

| AC# | Description | Verification Method | Expected Evidence |
|-----|-------------|-------------------|-------------------|
| AC1 | REGISTRY.yaml schema supports all designed fields | `yq '.dependencies[0] | keys' .tad/dependencies/REGISTRY.yaml` | Lists: name, type, safety_tier, current_version, upstream, usage, known_limitations, last_checked, notes |
| AC2 | *deps init protocol exists in Alex SKILL | `grep -c 'deps_init_protocol\|deps-init' .claude/skills/alex/SKILL.md` | ≥2 matches (command + protocol reference) |
| AC3 | *deps display protocol exists in Alex SKILL | `grep -c 'deps_show_protocol\|"deps"' .claude/skills/alex/SKILL.md` | ≥1 match |
| AC4 | *deps add protocol exists in Alex SKILL | `grep -c 'deps_add_protocol\|deps-add' .claude/skills/alex/SKILL.md` | ≥1 match |
| AC5 | Template file exists and is valid YAML | `yq '.version' .tad/templates/deps-registry-template.yaml` | Returns "1.0.0" |
| AC6 | TAD dogfood registry has ≥5 dependencies | `yq '.dependencies | length' .tad/dependencies/REGISTRY.yaml` | ≥5 |
| AC7 | Each dogfood entry has capabilities_used | `yq '[.dependencies[].usage.capabilities_used | length] | min' .tad/dependencies/REGISTRY.yaml` | ≥1 (every entry has at least 1) |
| AC8 | Sync: template is in syncable path | `ls .tad/templates/deps-registry-template.yaml` | File exists in .tad/templates/ (synced by default) |
| AC10 | Sync exclusion: dependencies/ in ZERO_TOUCH | `bash .tad/hooks/lib/derive-sync-set.sh --zero-touch \| grep -cxF 'dependencies'` | Returns 1 |
| AC11 | version_pinned_at field present in schema | `yq '.dependencies[0].version_pinned_at' .tad/dependencies/REGISTRY.yaml` | Non-null date value |
| AC12 | Change scope as planned | `git diff --stat` | Only §6 files changed |

---

## 10. Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/acceptance-tests/deps-registry-init/expert-review-{reviewer}.md
gate_verdicts:
  - .tad/evidence/acceptance-tests/deps-registry-init/gate3-report.md
completion:
  - .tad/active/handoffs/COMPLETION-20260714-deps-registry-init.md
blake_reviews: []
knowledge_updates: []
```

---

## 11. Decision Summary

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| D1 | Project-level registry (not TAD-global) | Each project has unique deps; TAD deps flow via *sync | Global registry (rejected: cross-project deps are different) |
| D2 | Rich schema with capabilities_used + known_limitations | Enables Phase 2 relevance filtering and Phase 3 limitation resolution detection | Thin schema (rejected: just another package.json) |
| D3 | Semi-auto init with LLM filtering | Balance between manual work and accuracy | Fully manual (rejected: too tedious), fully auto (rejected: can't enrich capabilities_used) |
| D4 | Template in .tad/templates/ (synced), registry data in .tad/dependencies/ (zero-touch) | Framework structure syncs; project data stays local | Both synced (rejected: overwrites project data) |
| D5 | Safety tier as enum not number | Clearer semantics; Phase 3 maps to days | Raw days (rejected: less readable in YAML) |

---

## Project Knowledge

### Blake must note these historical lessons:

- **Shell Portability: yq -i Normalizes Whole File** (patterns/shell-portability.md) — If using yq -i to append to REGISTRY.yaml, expect first-write normalization. Use Edit tool for initial creation, yq only for subsequent modifications.
- **AC Verification Drift Pattern** (patterns/ac-verification.md) — All AC verification commands above have been designed to run on the expected output. Blake should verify each AC command runs correctly after implementation.
- **Release & Sync: Mirror Destroys Gitignore Semantics** (patterns/release-sync.md) — When adding .tad/dependencies/ to sync awareness, ensure project-specific data (REGISTRY.yaml) is excluded, not just ignored at source.
- **Deny-List Must Be Applied at EVERY Copy Granularity** (principles.md) — The template file and the registry data file are at the SAME directory level — verify the sync set correctly includes one and excludes the other.

---

## Message to Blake

📨 **Blake Implementation Task**

| Field | Value |
|-------|-------|
| **Task** | Dependency Evolution Awareness — Phase 1: Registry + Init |
| **Handoff** | `.tad/active/handoffs/HANDOFF-20260714-deps-registry-init.md` |
| **Epic** | EPIC-20260714-dependency-evolution-awareness.md (Phase 1/3) |
| **Priority** | Medium |
| **Scope** | REGISTRY.yaml schema + *deps init/show/add commands + template + TAD dogfood |
| **Key Files** | `.tad/dependencies/REGISTRY.yaml` (CREATE), `.tad/templates/deps-registry-template.yaml` (CREATE), `.claude/skills/alex/SKILL.md` (MODIFY), `.claude/skills/alex/references/deps-protocol.md` (CREATE) |
| **Critical** | Registry fields must be RICH — capabilities_used, known_limitations, files_depending are the differentiator vs a bare version list |

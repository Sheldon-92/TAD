# Completion Report — github-registry-phase1
**Task**: TASK-20260504-004
**Handoff**: HANDOFF-20260504-github-registry-phase1.md
**Date**: 2026-05-04
**Blake Commit**: 047266c

---

## What Was Delivered

### Files Created / Modified
1. `.tad/github-registry/REGISTRY.yaml` — 24 domains, 50 awesome-list entries, full schema
2. `.claude/skills/research-github/SKILL.md` — 6 commands: list/search/add/explore/notebook/refresh
3. `.tad/templates/github-registry-entry.yaml` — domain + entry templates with field reference + validation checklist
4. `.tad/active/epics/EPIC-20260504-github-knowledge-integration.md` — Phase 1: ⬚→🔄 Active

### Evidence Files
- `.tad/evidence/reviews/blake/github-registry-phase1/code-reviewer.md`
- `.tad/evidence/reviews/blake/github-registry-phase1/backend-architect.md`
- `.tad/evidence/completions/github-registry-phase1/GATE3-REPORT.md`

---

## Implementation vs Plan Deviations

| Area | Planned | Actual | Reason |
|------|---------|--------|--------|
| Domain count | 20 | 24 | NLP and CV separated; prompt-engineering/mcp-servers as standalone; knowledge-graph/autonomous-driving/game-dev/meta added |
| Entry count | 50+ | 50 (exactly) | Added awesome-chatgpt-prompts + awesome-javascript to hit threshold |
| gh api field names | not specified | Fixed snake_case | code-reviewer P0-1 catch: gh api REST ≠ gh search camelCase |
| File enumeration API | contents/ | git/trees?recursive=1 | code-reviewer P0-2: contents/ only returns root-level |
| Source add failure handling | not specified | >50% threshold + AskUserQuestion | backend-architect P1-2 catch |
| Write ordering | not specified | research-notebooks first | backend-architect P1-5 (safer ordering) |

---

## AC Status

| AC | Status | Evidence |
|----|--------|---------|
| AC1 | ✅ PASS | 24 domains verified by yq |
| AC2 | ✅ PASS | 50 entries verified by yq |
| AC3 | ✅ PASS | SKILL.md exists with 6 commands |
| AC4 | ✅ INTENT | list documented with formatted table |
| AC5 | ✅ INTENT | explore documented with 7-step algorithm |
| AC6 | ✅ INTENT | notebook documented with 11-step pipeline |
| AC7 | ⏳ Live test | Requires human to run notebook → ask → verify code-level answer |
| AC8 | ✅ INTENT | search documented with gh search repos |
| AC9 | ✅ INTENT | add documented with REGISTRY.yaml write |
| AC10 | ✅ INTENT | refresh documented with per_page=1 API |
| AC11 | ✅ PASS | 🔄 Active in epic Phase Map |

---

## Implementation Decisions Made

| Decision | Context | Chosen | Rationale |
|----------|---------|--------|-----------|
| Use git/trees?recursive=1 | File enumeration API | Recursive tree | Code-reviewer found contents/ is root-only |
| Write order for registries | Cross-registry sync | research-notebooks first | Safer: stale ref in github-registry > orphan entry in notebooks |
| Failure threshold for source-add | Partial failure handling | >50% triggers AskUserQuestion | User should decide if notebook is worth keeping at this quality |
| created_by as extension field | YAML schema | Extension (no template change) | YAML accepts extra fields; reverse-sync documented as manual |

---

## Knowledge Assessment

**是否有新发现？** ✅ Yes

**Category**: architecture

**Summary**: Discovered `gh api` (REST API wrapper) uses snake_case field names (`.full_name`, `.stargazers_count`) while `gh search repos --json` uses camelCase (`fullName`, `stargazersCount`) — these are different APIs with different conventions. Mixing them silently returns null with no error. Also: `gh api .../contents/` returns only root-level entries, NOT recursive; the correct primitive for full repo path enumeration is `git/trees/{branch}?recursive=1` which returns all blob paths with a `truncated` flag for large repos. Both findings are broadly applicable to any TAD workflow using gh CLI.

---

## Notes for Alex Gate 4

1. **AC7 live test**: The `notebook` command's value prop is code-level answers (not just README-level). Alex should run: `*research-github explore "mcp-servers"` → select ≥3 repos → `*research-github notebook "mcp-servers"` → ask about a specific class/function in one of the repos → verify the answer references code internals. This is the T4 experiment-grounding that the handoff §2 declares.

2. **BA-P1-3 (Phase 2 extensibility)**: `auto_query_keywords`, `query_priority` reserved fields were not added to REGISTRY.yaml. The YAML schema is open (no strict validation), so Phase 2 can add them without migration. Decision: deferred — Phase 2 handoff will specify.

3. **P0-2 BA finding was invalid**: `notebooklm create` exists in 0.3.4 (verified via `notebooklm --help` output). The architecture.md capability matrix entry from 2026-05-04 omitted create/delete/rename/summary in its tested-command list — it was partial, not exhaustive.

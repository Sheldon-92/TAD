---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: yes
gate4_delta: []
---

# Handoff: Release v2.31.0

**From:** Alex
**To:** Blake
**Date:** 2026-06-17
**Task ID:** TASK-20260617-003
**Priority:** Routine release (minor version, no breaking changes)

---

## Task

Bump TAD from v2.30.0 → v2.31.0, add CHANGELOG entry, commit all pending files, push + tag.

## Version Bump Files (3 files, change "2.30.0" → "2.31.0")

1. `.tad/version.txt` — single line
2. `.tad/config.yaml` → line 3 `version: 2.31.0`
3. `tad.sh` → `TARGET_VERSION="2.31.0"`

## CHANGELOG Entry

Insert after `## [2.30.0] - 2026-06-15` line in CHANGELOG.md:

```markdown
## [2.31.0] - 2026-06-17

### Added
- **agent-computer-interface capability pack (#26)** — 5-layer tool selection model (engine/data/hybrid/agent/desktop), two-tier capability detection (ToolSearch + shell), security-aware fallback chains. 6 references, 35+ judgment rules, 2 executable scripts
- **agent-skill-evolution capability pack (#25)** — SkillOpt-based self-improving agent judgment rules. 7 references + gate-check.sh
- **Unified *research command** — 9 separate research entries consolidated into Quick/Standard/Deep routing (default: Standard via NotebookLM)
- **6 research quality improvements** — Q1 decision point, Q2 source verification, Q3 semantic saturation, Q4 decision brief template, Q5 claim verification, Q6 feedback loop
- **SkillOpt methodology integration** — TAD methodology updated with SkillOpt research insights
- **Research decision brief template** — .tad/templates/research-decision-brief.md

### Changed
- pack-upgrade workflow migrated from research-engine to NotebookLM-based agent
- pack-dogfood workflow enhanced with regression stage

### Removed
- research-engine.workflow.js (405 lines) — replaced by Standard *research flow

### Fixed
- Sync install.sh ordering bug that silently downgraded 21 packs in v2.30.0
```

## Commit + Push + Tag

1. Clean up: archive 3 COMPLETION reports from active/handoffs/ (already done by Alex)
1b. Archive THIS release handoff before committing: `mv .tad/active/handoffs/HANDOFF-20260617-release-v2.31.0.md .tad/archive/handoffs/`
2. `git add` all relevant files (version bumps + CHANGELOG + untracked evidence/archives/ideas/traces + modified knowledge files + NEXT.md + REGISTRY.yaml + archived release handoff)
   - ⚠️ Do NOT `git add -A` — use explicit paths
   - ⚠️ Include `.tad/evidence/research/agent-computer-control/` (new research data)
   - ⚠️ Include `.tad/capability-packs/agent-computer-interface/install.sh` (new)
3. Commit: `chore(TAD): release v2.31.0 — 2 new packs + unified *research + sync fix`
4. Push to origin main
5. Tag: `git tag v2.31.0 && git push origin v2.31.0`

## AC

- [ ] AC1: version.txt = "2.31.0"
- [ ] AC2: config.yaml version = 2.31.0
- [ ] AC3: tad.sh TARGET_VERSION = "2.31.0"
- [ ] AC4: CHANGELOG.md has [2.31.0] entry
- [ ] AC5: All untracked files committed (0 untracked after commit)
- [ ] AC6: Tag v2.31.0 pushed to origin
- [ ] AC7: `git status` clean after push

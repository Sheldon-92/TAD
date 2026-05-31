---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: yes
gate4_delta: []
---

# Handoff Document for Agent B (Blake) — ROUTINE RELEASE (SOP)

**From:** Alex (Terminal 1) | **To:** Blake (Terminal 2)
**Date:** 2026-05-30 | **Priority:** P1
**Slug:** release-v2.19.0
**Type:** Routine minor release — execute per release-runbook SOP (no Socratic/design; SOP IS the spec)

---

## ⚠️ MANDATORY FIRST STEP
**Read `.claude/skills/release-runbook/SKILL.md` BEFORE doing anything.** It has the exhaustive
14-file version-string list, CHANGELOG format, jq/sed gotchas, and the `tad.sh`/`config.yaml`
historical version-drift bug. Do NOT bump versions from memory.

---

## 1. Task Overview
Cut **TAD v2.18.0 → v2.19.0** (minor — 4 additive features since 2.18, no breaking changes).
Fix a pre-existing version-drift bug, write the CHANGELOG entry, commit the dirty framework state.
Then hand back to Alex for `*publish` (push + tag) and `*sync` (distribute to 14 projects).

**Why now**: 4 features are committed-but-unpushed; 6 downstream projects are stuck on V1 trace
hooks and need the new observational instrumentation. This release unblocks distribution.

## 2. Version Decision (Alex — release strategy)
- **2.18.0 → 2.19.0** (minor). Rationale: 4 additive features, zero breaking changes.
- ⚠️ **Known drift bug to fix**: `tad.sh TARGET_VERSION="2.15"` — 3 minor versions stale.
  Bump it to `2.19` (MAJOR.MINOR form per tad.sh convention). This is exactly the
  `config.yaml`-stayed-at-2.8.0 class of bug the runbook warns about — grep every file, trust nothing.

## 3. The 4 features to document in CHANGELOG [2.19.0]
(from the 4 unpushed commits — `git log --oneline origin/main..HEAD`)
1. **v2 observational trace instrumentation** (`b0e1c78`) — gate_result/expert_finding/decision_point/
   reflexion now fire observationally from artifacts; handoff_created 6x over-fire fixed; analyzer
   schema fix + N=0 gate guard. Self-evolution data layer now functional.
2. **\*sync directory-list fix** (`d94e956`) — added `.tad/domains/` + `.tad/hooks/` to sync list
   (12→14 entries, mirrors tad.sh:115). Fixes downstream projects missing hooks.
3. **ML Training capability pack** (`2ab17b3`) — reference-based pack.
4. **Cloud compute resource awareness** (`027489c`) — embedded into Socratic + 2 other files.

## 4. Acceptance Criteria

| AC# | Requirement | Verification |
|-----|-------------|--------------|
| AC1 | Version = 2.19.0 in ALL runbook-listed files (14) | `grep -rnE "2\.1[0-8]\." .tad/version.txt .tad/config.yaml tad.sh README.md INSTALLATION_GUIDE.md .claude/skills/tad-help/SKILL.md` → no stale 2.15/2.18 hits (except historical changelog/version-history lines) |
| AC2 | tad.sh drift fixed | `grep TARGET_VERSION tad.sh` = 2.19 (not 2.15) |
| AC3 | CHANGELOG has [2.19.0] entry covering all 4 features | `grep -c '## \[2.19.0\]' CHANGELOG.md` = 1; entry mentions trace/sync-fix/ML/cloud |
| AC4 | Dirty framework state committed | `git status --porcelain` shows no modified framework files (NEXT.md, architecture.md, sync-registry.yaml, dream-state.yaml committed); lifecycle churn (dream-candidate deletions, old completions) also committed |
| AC5 | Version-bump grep clean (runbook Phase 2 stragglers) | runbook's straggler grep returns only 2.19.0 |
| AC6 | No push/tag by Blake | Blake does NOT push or tag — that's Alex's `*publish` step. Just commit. |

## 5. Files to Modify (per release-runbook Phase 2 — 14 strings)
Per runbook table: `.tad/version.txt`, `.tad/config.yaml`, `tad.sh` (TARGET_VERSION — the drift bug),
`README.md` (version history), `INSTALLATION_GUIDE.md`, `.claude/skills/tad-help/SKILL.md`,
`CHANGELOG.md` (new [2.19.0] entry). **Read the runbook for the exact 14-line list — do not work from this summary.**

## 6. Commit scope (AC4)
Commit in 2 logical groups (or 1 if cleaner):
- **Release commit**: version-string files + CHANGELOG → `chore(release): TAD v2.19.0`
- **Framework state**: architecture.md (3 new knowledge entries), NEXT.md, sync-registry.yaml,
  dream-state.yaml, dream-candidate deletions, old completion deletions, new ideas/epics
  → `chore: framework state + knowledge + lifecycle churn`
- ⚠️ Do NOT commit: `.tad.backup.20260528_215246/`, `.claude/projects/`, `.claude/worktrees/`
  (transient/local — add to .gitignore if not already, or leave untracked).

## 7. Important Notes
- This is SOP execution — the release-runbook is the authoritative spec. Follow its phases.
- Blake STOPS after commit. Alex runs `*publish` (push origin/main + tag v2.19.0) and `*sync`.
- No expert review needed (routine release per release_duties); Layer 1 = AC grep verification.

## Blake Instructions
- Read release-runbook SKILL → Phase 1 pre-flight → Phase 2 version bump (grep every file) →
  Phase 3 CHANGELOG → commit (Phase scope §6) → STOP, hand back to Alex for push+tag+sync.
- Run the AC greps, paste output in COMPLETION. Do NOT push/tag.

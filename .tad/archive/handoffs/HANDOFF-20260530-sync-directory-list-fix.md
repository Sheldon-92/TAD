---
task_type: yaml
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Fix *sync Directory List — Add Missing hooks/ and domains/

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-05-30
**Project:** TAD
**Priority:** P1
**Type:** Bugfix

---

## 1. Executive Summary

`*sync` protocol in Alex SKILL.md omits `.tad/hooks/` and `.tad/domains/` from the Framework subdirectories copy list. This causes all downstream projects (6 of 8 active) to retain V1 trace hooks, making V2 trace metrics (gate_result, reflexion_diagnosis, decision_point, expert_review_finding) non-functional across the ecosystem. Only Colin声音项目 (installed fresh via tad.sh) has V2 traces.

## 2. Root Cause

The `sync_protocol.step3b` directory list in `.claude/skills/alex/SKILL.md` (line 5705-5717) has 12 entries. The `tad.sh` `copy_framework_files` function (line 115) has 14 entries. The 2 missing entries: `domains` and `hooks`.

Additionally, the `step3_commit` git add command already includes `.tad/hooks/` and `.tad/domains/` — creating an inconsistency where old files get committed but never updated.

## 3. Requirements

- FR1: Add `.tad/hooks/` and `.tad/domains/` to SKILL.md sync_protocol.step3b Framework subdirectories list
- FR2: Verify the complete directory list matches tad.sh line 115 exactly (14 entries)

## 4. Technical Design

Simple insertion of 2 lines into the existing YAML list at the correct alphabetical position (matching tad.sh ordering).

## 5. Implementation Steps

### Task 1: Add missing directories to SKILL.md sync list

**File:** `.claude/skills/alex/SKILL.md`
**Location:** After the line containing `.tad/data/` in the sync_protocol.step3b "Framework subdirectories" block (currently line ~5707)

Insert `.tad/domains/` after `.tad/data/`, and `.tad/hooks/` after `.tad/guides/`.

**After edit, the list should read (14 entries, matching tad.sh line 115):**
```
           # SYNC-MIRROR: must match tad.sh copy_framework_files() dir list (line 115)
           Framework subdirectories (full recursive copy):
           - .tad/agents/
           - .tad/data/
           - .tad/domains/
           - .tad/gates/
           - .tad/guides/
           - .tad/hooks/
           - .tad/ralph-config/
           - .tad/references/
           - .tad/schemas/
           - .tad/skills/
           - .tad/sub-agents/
           - .tad/tasks/
           - .tad/templates/
           - .tad/workflows/
```

## 6. Files to Modify

| File | Action | Lines |
|------|--------|-------|
| `.claude/skills/alex/SKILL.md` | MODIFY | ~5707-5717 (sync_protocol.step3b) |

**Grounded Against** (Alex step1c):
- .claude/skills/alex/SKILL.md (lines 5695-5724, read at 2026-05-30)
- tad.sh (line 115, read at 2026-05-30)

## 7. Testing

- After edit: grep the SKILL.md for all 14 directory names, verify count = 14
- After *sync: verify one sub-project's common.sh contains "schema_version"

## 8. Important Notes

- This is a bugfix, not a new feature — the intent was always to mirror tad.sh
- After Blake implements this fix, a full *sync to all 16 projects should be run
- The *sync itself runs in Alex terminal — Blake only fixes the SKILL.md file
- **cp -r additive-only limitation**: sync overwrites existing files and adds new ones, but does NOT delete files removed from source. If TAD source renames a hook script, the old file persists in downstream projects. This is an existing systemic limitation, not introduced by this fix.
- **Overwrite safety**: `.tad/hooks/` and `.tad/domains/` contain framework-only content. Downstream projects should NOT create custom files in these directories (use `.tad/capability-packs/` or project-specific locations instead). The first sync after this fix will overwrite V1 `common.sh` with V2 in 6 projects — this is the desired behavior.

## 9. Acceptance Criteria

All verification commands use context-anchored grep scoped to the "Framework subdirectories" block to avoid false matches elsewhere in SKILL.md (P0 fix from expert review — known pattern per code-quality.md "AC grep-count").

| # | Criterion | Verification |
|---|-----------|-------------|
| AC1 | Sync list has exactly 14 `.tad/` subdirectory entries | `grep -A 20 'Framework subdirectories (full recursive copy)' .claude/skills/alex/SKILL.md \| grep -c '\- \.tad/[a-z]'` = 14 |
| AC2 | `.tad/domains/` in sync block | `grep -A 20 'Framework subdirectories' .claude/skills/alex/SKILL.md \| grep -q '\.tad/domains/'` exits 0 |
| AC3 | `.tad/hooks/` in sync block | `grep -A 20 'Framework subdirectories' .claude/skills/alex/SKILL.md \| grep -q '\.tad/hooks/'` exits 0 |
| AC4 | Directory order matches tad.sh line 115 | Visual comparison of the 14-entry list vs tad.sh |
| AC5 | SYNC-MIRROR comment present | `grep -q 'SYNC-MIRROR.*tad.sh' .claude/skills/alex/SKILL.md` exits 0 |

### 9.1 Spec Compliance Checklist

| # | Check | Verification Method | Expected Evidence |
|---|-------|-------------------|-------------------|
| SC1 | sync list entry count | `grep -A 20 'Framework subdirectories (full recursive copy)' .claude/skills/alex/SKILL.md \| grep -c '\- \.tad/[a-z]'` | 14 |
| SC2 | domains present in sync block | `grep -A 20 'Framework subdirectories' .claude/skills/alex/SKILL.md \| grep 'domains/'` | `.tad/domains/` line |
| SC3 | hooks present in sync block | `grep -A 20 'Framework subdirectories' .claude/skills/alex/SKILL.md \| grep 'hooks/'` | `.tad/hooks/` line |

**AC Dry-Run Log** (Alex step1d at 2026-05-30):
- SC1: ✅ pre-impl-verifiable, raw cmd: `grep -A 20 'Framework subdirectories (full recursive copy)' .claude/skills/alex/SKILL.md | grep -c '\- \.tad/[a-z]'`, output: 12 (will be 14 after fix)
- SC2: ✅ post-impl-verifiable, syntax-validated
- SC3: ✅ post-impl-verifiable, syntax-validated

## 10. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Fix scope | Just 2 dirs / Full tad.sh parity audit | Full audit | Confirmed only 2 dirs missing; rest matches |
| 2 | Drift prevention | (A) MIRROR comment / (B) Runtime parse tad.sh / (C) Pre-flight diff check | (A) MIRROR comment | Option B over-engineering for ~2x/year changes; Option C is future improvement tracked as idea |

## 9.2 Expert Review Status

| Reviewer | Type | Finding Count | P0 | Status |
|----------|------|--------------|-----|--------|
| code-reviewer | Code quality | 5 (2 P0, 3 P1) | AC grep commands match 21 lines not 12; SC2 pipe order reversed | ✅ All P0 resolved |
| backend-architect | Architecture | 5 (2 P0, 3 P1) | cp -r additive-only undocumented; overwrite impact unspecified | ✅ All P0 resolved |

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0-1: AC1 grep matches 21 lines | §9 AC1-AC3 rewritten with context-anchored grep | Resolved |
| code-reviewer | P0-2: SC1 same broad grep | §9.1 SC1 rewritten | Resolved |
| code-reviewer | P1-1: SC2 pipe order reversed | §9.1 SC2 rewritten | Resolved |
| code-reviewer | P1-2: AC3 not specific to sync block | §9 AC3 context-anchored | Resolved |
| backend-architect | P0-1: cp -r additive-only undocumented | §8 added limitation note | Resolved |
| backend-architect | P0-2: Overwrite impact unclear | §8 added overwrite safety note | Resolved |
| backend-architect | P1-1: MIRROR comment for drift prevention | §5 Task 1 added SYNC-MIRROR comment + §9 AC5 | Resolved |

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训
- "Never Hand-Write What an Existing Tool Already Does" (architecture.md) — this bug was caused by manually maintaining a directory list in SKILL.md that should have referenced tad.sh as source of truth

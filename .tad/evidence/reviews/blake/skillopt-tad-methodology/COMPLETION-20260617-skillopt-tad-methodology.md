---
task_id: TASK-20260616-001
handoff: HANDOFF-20260616-skillopt-tad-methodology.md
slug: skillopt-tad-methodology
gate3_verdict:
---

# Completion Report: SkillOpt-Informed TAD Methodology Improvements

## Summary
Implemented three SkillOpt-inspired improvements to TAD's pack management workflows:
1. **pack-upgrade bounded edit mode** — Upgrade stage defaults to structured edits (add/modify/delete rules) instead of full rewrite, with escape hatch for structural reorganization
2. **pack-dogfood regression dimension** — Pre-pipeline snapshot, fixture persistence, task threading, and Regression stage that compares current pack against previous baseline to detect knowledge loss
3. **Auto-evolve spike** — Python stdlib script mining trace files for pack-usage signals (found 386 events across 47 files, SIGNAL PRESENT verdict)

## Implementation vs Plan

| Planned | Actual | Delta |
|---------|--------|-------|
| FR1: ~50 lines prompt + schema | 22 lines (PREPEND + schema) | Smaller — bounded edit block + schema extension only |
| FR2: ~80 lines regression | ~75 lines (snapshot + persist + thread + regression + schema) | On target |
| FR3: ~60-80 lines spike | 125 lines (richer analysis) | Slightly larger — added pack name extraction (domain field), temporal co-occurrence analysis |
| FR4: .agents sync | DROPPED per expert review | Codex doesn't consume workflows |

## Files Changed

- `.claude/workflows/pack-upgrade.workflow.js` — Upgrade stage bounded-edit prompt + UPGRADE_SCHEMA edit_list
- `.claude/workflows/pack-dogfood.workflow.js` — Full rewrite: Snapshot loop + fixture persist stage + task threading + Regression stage + REGRESSION_SCHEMA + updated meta.phases (5) + return value with regression dimension
- `.tad/evidence/spikes/pack-evolve-spike/spike.py` — NEW: Python stdlib trace signal miner
- `.tad/evidence/spikes/pack-evolve-spike/spike-report.md` — NEW: Generated spike output

## Evidence

- `.tad/evidence/reviews/blake/skillopt-tad-methodology/spec-compliance.md` — 15/15 ACs SATISFIED
- `.tad/evidence/reviews/blake/skillopt-tad-methodology/code-review.md` — 1 P0 (not real; functional test disproves), 1 P1 fixed (scope constraint restored), 3 P1 accepted (match handoff design)
- `.tad/evidence/pack-dogfood/regression-code-security.md` — Functional test: 10 claims compared, 0 regressions, 2 pre-existing errors noted
- `.tad/evidence/pack-dogfood/regression-rag-retrieval.md` — Functional test: 22+ claims compared, 0 regressions
- `.tad/evidence/pack-dogfood/fixtures/code-security.task.md` — Persisted fixture (AC5)
- `.tad/evidence/pack-dogfood/fixtures/rag-retrieval.task.md` — Persisted fixture (AC5)
- `.tad/evidence/pack-dogfood/dogfood-code-security.prev.md` — Snapshot baseline (AC4)
- `.tad/evidence/pack-dogfood/dogfood-rag-retrieval.prev.md` — Snapshot baseline (AC4)
- Commit: `c4fbeb2`

## Functional Test Results (AC15)

Ran pack-dogfood workflow (updated version via scriptPath) on 2 packs (code-security, rag-retrieval):
- **14 agents**, 541K tokens, ~8.5 minutes
- Both packs: WITH-PACK won (clear margin)
- Snapshot stage: `.prev.md` files created ✅
- Fixture persist stage: `fixtures/*.task.md` written ✅
- Task threading: `task: b.task` in Judge `.then()` ✅
- Regression stage: `regression_found: false` for both packs ✅
- `packs_with_regression: []` in top-level return ✅

## Deviations from Plan

1. **pack-dogfood was a full rewrite** (not incremental edits) due to the number of interleaved changes (5 new sections + data flow changes across all stages). All existing logic preserved verbatim.
2. **spike.py domain field** — Handoff assumed `context.pack` for pack name extraction. Live trace data uses `domain` field instead. Fixed spike to check `domain` first, with fallback chain.
3. **Workflow args known issue** — Named workflow resolution (`name: "pack-dogfood"`) cached the old version. Re-ran with `scriptPath` to pick up the new code. Args `evidence_dir` not reliably injected (known issue documented in workflow header).

## Friction Status

| Step | Status | Notes |
|------|--------|-------|
| Layer 1 (build/test/lint/tsc) | NOT_APPLICABLE_WITH_REASON | Workflow JS + Python spike — no npm project; verified via syntax checks + functional test |
| Layer 2 spec-compliance | READY | 15/15 SATISFIED |
| Layer 2 code-reviewer | READY | 1 P0 disproved by functional test, 1 P1 fixed, 3 P1 accepted |
| Layer 2 test-runner | NOT_APPLICABLE_WITH_REASON | No test suite for workflow scripts; AC15 functional test serves as integration test |
| Layer 2 security-auditor | NOT_APPLICABLE_WITH_REASON | No auth/token/credential changes |
| Layer 2 performance-optimizer | NOT_APPLICABLE_WITH_REASON | No database/query/cache/batch changes |

## Reflexion History

无 reflexion（Layer 1 一次通过）

## Knowledge Assessment

**是否有新发现？** ✅ Yes

**类别**: patterns/pack-evaluation.md

**总结**: Named workflow resolution (`Workflow({name: "pack-dogfood"})`) can cache the script at resolution time. When iterating on a workflow file, use `scriptPath` pointing to the actual file to ensure the latest version is used. This is distinct from the known args-injection issue — it's a resolution/caching behavior.

**是否有可复用的工作模式？** ❌ No

**是否发现 workflow 模式？** ❌ No — existing pack-dogfood workflow was extended, no new orchestration pattern.

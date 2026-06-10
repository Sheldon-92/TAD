# Completion Report: Acceptance Test Tooling (Phase 6/6)

**Task ID**: TASK-20260610-001
**Epic**: EPIC-20260609-upgrade-lifecycle-system (Phase 6/6 - FINAL)
**Date**: 2026-06-10
**Agent**: Blake (Agent B)

## Summary

Built two verification scripts + evidence directory for the final acceptance phase
of the upgrade-lifecycle-system Epic. All Layer 1 checks pass.

## Deliverables

| File | Status |
|------|--------|
| .tad/tests/upgrade-acceptance.sh | Created (post-sync per-project verifier) |
| .tad/tests/gate-exercise.sh | Created (gate interception exercise) |
| .tad/evidence/acceptance-tests/upgrade-lifecycle/README.md | Created (evidence index + recommendation) |
| .tad/evidence/acceptance-tests/upgrade-lifecycle/fixture-run-output.txt | Created (22/22 pass) |
| .tad/evidence/acceptance-tests/upgrade-lifecycle/gate-exercise-output.txt | Created (PASS) |
| .tad/evidence/acceptance-tests/upgrade-lifecycle/chain-dry-run-output.txt | Created (12 manifests, exit 0) |

## Layer 1 Verification Results

| # | Check | Result |
|---|-------|--------|
| 1 | `bash -n .tad/tests/upgrade-acceptance.sh` | PASS (exit 0) |
| 2 | `bash -n .tad/tests/gate-exercise.sh` | PASS (exit 0) |
| 3 | `bash .tad/tests/gate-exercise.sh` outputs PASS | PASS |
| 4 | `bash .tad/tests/migration-fixtures/run-fixtures.sh` (regression) | PASS (22/22) |
| 5 | Chain dry-run v2.19.0 to v2.27.0 exit 0 | PASS |

## AC Verification

| AC | Status | Evidence |
|----|--------|----------|
| AC1 | PASS | `bash -n` exit 0 |
| AC2 | PASS | No-args produces "Usage" + exit 2 |
| AC3 | PASS | `--expected-version 2.27.0` outputs `version (2.27.0): PASS` |
| AC4 | PASS | `--expected-version 9.9.9` outputs `version: FAIL` |
| AC5 | PASS | Without --snapshot: `ZERO_TOUCH diff: SKIP` |
| AC6 | PASS | `deprecated files: FAIL` (correct detection of AGENTS.md/.codex/ in source repo) |
| AC7 | PASS | Script references `derive-sync-set.sh --zero-touch` |
| AC8 | PASS | Script references `deprecation.yaml` |
| AC9 | PASS | Script uses exit 0, exit 1, exit 2 |
| AC10 | PASS | `bash -n` exit 0 |
| AC11 | PASS | gate-exercise.sh outputs "PASS" |
| AC12 | PASS | Output contains "UNMANIFESTED DELETE" |
| AC13 | PASS | Script uses `trap ... EXIT` |
| AC14 | PASS | 22/22 fixtures pass |
| AC15 | PASS | Evidence dir contains 4 files (3 required + 1 bonus) |
| AC16 | PASS | fixture-run-output.txt contains "ALL FIXTURES PASS" |
| AC17 | PASS | gate-exercise-output.txt contains "PASS" |
| AC18 | PASS | README contains "hard-block" (3 occurrences) |
| AC19 | PASS | Both scripts use `set -euo pipefail` |
| AC20 | PASS | No `grep -P` in either script |
| AC21 | PASS | Only new files created (no modifications) |
| AC22 | PASS | Chain dry-run v2.19.0->v2.27.0 exit 0, resolves 12 manifests |
| AC23 | PASS | README documents 3 merge-strategy projects |

## P0 Fixes

1. **P0-1 (Chain dry-run)**: Verified by creating temp dir with version.txt="2.19.0"
   and running engine --dry-run. Resolves all 12 manifests successfully.

2. **P0-2 (Merge-strategy documentation)**: README.md documents the 3 projects
   (my-openclaw-agents, toy, 内存管理) that need the `<!-- TAD:PROJECT-CONTENT-BELOW -->`
   marker added as a human post-Epic step.

## Notes

- The upgrade-acceptance.sh script correctly detects deprecated files (AGENTS.md, .codex/)
  that exist in the TAD source repo. When run against TARGET projects (its intended use),
  these files should be absent. The detection is working as designed.
- gate-exercise.sh creates all required .tad/ subdirectories for derive-sync-set.sh to work
  (including ZERO_TOUCH dirs), ensuring the migration gate functions correctly in the temp env.
- The `printf` format string issue with `---` was fixed by using `printf '%s\n'` instead
  of format strings starting with dashes (bash 3.2 compatibility).

## Epic Status

Phase 6 is the FINAL phase. The upgrade-lifecycle-system Epic is now complete:
- Phase 1: Migration manifest schema v1
- Phase 2: migration-engine.sh + 14 fixtures
- Phase 3: tad.sh integration
- Phase 4: Merge capability + 4 fixtures
- Phase 5: release-verify.sh migration mode + 12 manifests + 3 gate fixtures
- Phase 6: Acceptance test tooling + chain verification (THIS PHASE)

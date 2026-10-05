# Gate 3 — Capability Builder Phase 1 Create (Rerun after Gate4 P1 remediation — 2d7e359b)

**Date:** 2026-09-01
**Handoff:** `.tad/active/handoffs/HANDOFF-20260831-capability-builder-phase1-create.md`
**Commit:** `2d7e359b` (2 files, see `scope/implementation-commit.txt` — honest: marker is post-commit working-tree evidence, `git cat-file -e` passes, not inside commit)
**Verdict:** PASS

## Prerequisite

| Check | Status |
|---|---|
| Completion Report | ✅ Exists `COMPLETION-20260831-capability-builder-phase1-create.md` |

## Friction Status

| Friction Point | Status | Evidence |
|---|---|---|
| Fresh agent CONTROL/WITH requires harness execution | READY | Conductor produced raw outputs with manifest/hashes/provenance; deterministic recompute via runner. |
| Dirty worktree from parallel YOLO2 task | READY | Staged explicit task paths only (`git add -f` list); verified no yolo2 riders staged; protected manifests identical. |
| Shell portability | READY | `bash -n` passes for all new/modified scripts; BSD-safe (no grep -P, LC_ALL=C). |
| Required Layer 2 reviews | READY | code-reviewer PASS, security-auditor PASS, spec-compliance PASS, test-runner PASS (independent). |

No BLOCKED rows.

## §9.1 Spec Compliance (PRIMARY VERIFICATION SOURCE)

| AC | Verification Method | Expected | Actual | Status |
|---|---|---|---|---|
| AC1 | `bash -n` all three scripts | exit 0 | 0 | ✅ Pass |
| AC2 | `run-acceptance.sh projection` | PASS projection | PASS projection | ✅ Pass |
| AC3 | `run-acceptance.sh structural` | all cases PASS, no mutation, no temp/lock | 54 cases PASS (incl. block >/\|, foreign temp, diff/cp wrapper rollback, concurrency, parent cleanup) | ✅ Pass |
| AC4 | `run-acceptance.sh eval-compat` | legacy preserved, skill/fallback valid, dual/missing/invalid regex/dash SKIP | PASS (7/7 incl. invalid regex, leading-dash --) | ✅ Pass |
| AC5 | `run-acceptance.sh behavior` | hashes reconcile, FAIL→PASS, neither SKIP | PASS (hash_tree binds path+type) | ✅ Pass |
| AC6 | `run-acceptance.sh routing` | builder routes, legacy SHA equal, no old scaffold | PASS (SHA 69026199) | ✅ Pass |
| AC7 | `diff -rq` both mirrors | exit 0 | exit 0 | ✅ Pass |
| AC8 | obsolete scaffold absent | exit 0 | exit 0 | ✅ Pass |
| AC9 | `run-acceptance.sh claude-routing` | single row diff (pinned) | PASS (pinned to `scope/implementation-commit.txt`) | ✅ Pass |
| AC10 | `run-acceptance.sh scope` | bounded commit + protected identical | PASS (remediation 2 files, 434 lines identical, pinned) | ✅ Pass |
| AC11 | `rg` anchor `local-skill` in release-verify.sh | lines 1006,1018 present | present | ✅ Pass |
| AC12 | `rg` anchor `is_pack_skill` in tad.sh | lines 359,363 present | present | ✅ Pass |

Empty guard: not empty. Dev floor: N/A (structural ACs cover shell).

## Git Commit Verification

| Check | Status | Detail |
|---|---|---|
| Changes committed | ✅ | `2d7e359b` (2 files: `capability-skill.sh` + `run-acceptance.sh`) + working-tree `scope/implementation-commit.txt` (honest: marker is post-commit working-tree evidence, `git cat-file -e` passes, not inside commit) |
| Commit bounded | ✅ | 2 files within §7 (`capability-skill.sh`, `run-acceptance.sh`) — remediation only, base `c0176f18` holds 31-file feature, HEAD `2d7e359b` verified via `scope` |
| Protected identical | ✅ | before == after (434) |

## Quality Checks

| Item | Status | Note |
|---|---|---|
| Code/Deliverable Complete | ✅ Pass | All §6 tasks done |
| §9.1 all rows pass | ✅ Pass | 12/12 |
| Evidence | ✅ Pass | manifest, raw, verdict, regression, scope, journal present |
| Evidence replayable | ✅ Pass | `run-acceptance.sh` reruns produce identical verdicts (hashes recomputed) |
| Git commit done | ✅ Pass | hash recorded |
| Knowledge Assessment | ✅ Pass | Journal `capability-builder-create-2026-08-31.md` exists |

## Knowledge Assessment

| Question | Answer | Evidence |
|---|---|---|
| New discoveries? | ✅ Yes | Hash-tree path-normalization; pack-raw vs pack-resolved |
| If Yes: written to | `.tad/evidence/journal/capability-builder-create-2026-08-31.md` | Journal entry present |

Gate 3 PASS — ready for Gate 4 human acceptance.

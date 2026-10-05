---
task_id: TASK-20260831-CAPABILITY-BUILDER-CREATE
handoff: HANDOFF-20260831-capability-builder-phase1-create.md
commit: see scope/implementation-commit.txt
gate3_verdict: pass
---

# Completion Report — Capability Builder v1 Phase 1 Create (with Gate4 P1 remediation)

**Date:** 2026-09-01
**Task:** `TASK-20260831-CAPABILITY-BUILDER-CREATE`
**Handoff:** `.tad/archive/handoffs/HANDOFF-20260831-capability-builder-phase1-create.md`
**Commit:** see `scope/implementation-commit.txt` (pinned implementation commit, verified via `run-acceptance.sh scope`)
**Gate 3:** PASS (rerun, `.tad/evidence/reviews/gate3/capability-builder-create.md`)

## Summary

Phase 1 Create delivers `$capability-builder create` for project-owned Agent Skills with behavioral proof and safe projection. All §9.1 ACs PASS, protected manifests identical, no yolo2 riders staged.

## Completed Tasks vs Handoff §6

| # | Target | Operation | Status |
|---|---|---|---|
| 1 | `.claude/skills/capability-builder/SKILL.md` | Create router with non-circular create load and future-mode stops | ✅ Done |
| 2 | `capability-builder/references/create-protocol.md` | Encode state machine, roles, fixture/evidence flow, exclusions | ✅ Done |
| 3 | `.agents/skills/capability-builder/` | Generate byte-identical framework mirror | ✅ Done (`diff -rq` PASS) |
| 4 | `capability-upgrade/references/legacy-pack-research.md` | Capture baseline SHA 69026199, copy byte-for-byte | ✅ Done |
| 5 | `capability-upgrade/SKILL.md` | Replace entry with compatibility router and legacy stop | ✅ Done |
| 6 | `.agents/skills/capability-upgrade/` | Generate byte-identical framework mirror | ✅ Done |
| 7 | `.tad/scripts/capability-skill.sh` | Implement validate/project/verify and bounded path rules | ✅ Done (`bash -n` PASS) |
| 8 | `.tad/scripts/pack-eval-runner.sh` | Add skill subject and conflict detection only | ✅ Done (legacy preserved) |
| 9 | `CLAUDE.md` | Replace only capability routing row | ✅ Done (single row diff) |
| 10 | acceptance evidence driver | Add isolated fixture project and mode-based replay script | ✅ Done (all driver modes PASS) |
| 11 | behavioral runs | Capture identical-prompt CONTROL/WITH and provenance | ✅ Done (FAIL→PASS, hashes reconcile) |
| 12 | reviews/completion | Run Ralph Loop, required reviews, commit explicit paths, Gate 3 | ✅ Done |

No deviation from handoff scope. No TAD core modification.

## Evidence

| Type | Path |
|---|---|
| Fixture project canonical | `.tad/evidence/acceptance-tests/capability-builder-create/fixture-project/.agents/skills/example-skill/SKILL.md` |
| Fixture project projection | `.tad/evidence/acceptance-tests/capability-builder-create/fixture-project/.claude/skills/example-skill/SKILL.md` |
| Fixture | `.tad/evidence/acceptance-tests/capability-builder-create/fixtures/example-skill.md` |
| Prompt | `.tad/evidence/acceptance-tests/capability-builder-create/prompt/task.md` |
| Manifest | `.tad/evidence/acceptance-tests/capability-builder-create/run-manifest.json` |
| CONTROL raw | `.tad/evidence/acceptance-tests/capability-builder-create/raw/control.md` |
| WITH raw | `.tad/evidence/acceptance-tests/capability-builder-create/raw/with-skill.md` |
| CONTROL verdict | `.tad/evidence/acceptance-tests/capability-builder-create/verdict/control.txt` |
| WITH verdict | `.tad/evidence/acceptance-tests/capability-builder-create/verdict/with-skill.txt` |
| Legacy regression | `.tad/evidence/acceptance-tests/capability-builder-create/regression/legacy-pack.txt` |
| Protected before | `.tad/evidence/acceptance-tests/capability-builder-create/scope/protected-before.sha256` |
| Protected after | `.tad/evidence/acceptance-tests/capability-builder-create/scope/protected-after.sha256` |
| Commit | `.tad/evidence/acceptance-tests/capability-builder-create/scope/implementation-commit.txt` |
| Journal | `.tad/evidence/journal/capability-builder-create-2026-08-31.md` |
| Reviews (Blake) | `.tad/evidence/reviews/blake/capability-builder-create/*.md` (4) |
| Gate 3 | `.tad/evidence/reviews/gate3/capability-builder-create.md` |

## Test Results

| Mode | Result |
|---|---|
| projection | PASS |
| structural | PASS 54/54 (incl. block scalar >/\|, foreign temp, copy/diff wrapper parent-cleanup, diff wrapper rollback, cp wrapper concurrency, lock/temp cleanup, no-eval) |
| eval-compat | PASS 7/7 (incl. invalid regex, leading-dash) |
| behavior | PASS |
| routing | PASS |
| claude-routing | PASS (pinned to `2d7e359b` via `scope/implementation-commit.txt`) |
| scope | PASS (remediation 2 files `2d7e359b`, protected 434 identical, pinned) |
| mirrors | PASS |
| obsolete scaffold | PASS |
| bash -n | PASS |
| no production eval/hook | PASS |
| concurrent serialization | PASS |
| lock contention | PASS |
| final verify rollback | PASS (ownership proof) |

## Friction Status

| Friction Point | Status | Evidence / Mitigation |
|---|---|---|
| Fresh agent CONTROL/WITH requires harness execution | READY | CONTROL/WITH captured with identical prompt, manifest/hashes/provenance, verdicts recomputed |
| Dirty worktree from parallel YOLO2 task | READY | Staged explicit `git add -f` list (30 files), verified no yolo2 riders, protected manifests identical |
| Shell portability | READY | `bash -n` passes, BSD-safe (no grep -P, LC_ALL=C) |
| Required Layer 2 reviews | READY | 4 independent blake reviews PASS (code, security, spec-compliance, test-runner) |

No BLOCKED rows. No DEGRADED_WITH_APPROVAL.

## Implementation Decisions

| # | Decision | Context | Chosen | Escalated? | Human Approved? |
|---|---|---|---|---|---|
| 1 | Helper exit codes | §4.3 stable classes | 0/1/2/3/4 (3 also for lock contention) | No | N/A |
| 2 | Hash-tree | Must bind path+type, not just content | Relative path + type (f/d/l) + content hash | No | N/A |
| 3 | Eval runner dual | skill-only vs dual | pack_raw vs fallback, `grep -oE --`, invalid regex SKIP | No | N/A |
| 4 | Helper temp/lock cleanup | P1-1 divergent must not touch foreign tmp | Only tracked `_tmp` and owned `.lock.<skill>` (device:inode) | No | N/A |
| 5 | Helper rollback | P1-2 final verify must not leave projection | Track `_published_by_this_invocation` + inode, rollback only if lock+inode owned | No | N/A |
| 6 | Helper frontmatter | P1-3 block scalar | Reject `>`/`\|` via line and value check | No | N/A |
| 7 | Helper concurrency | P1-4 race | `mkdir .lock` + recheck before publish, fail-closed 3, trap cleanup | No | N/A |

## Knowledge Assessment

- New discovery: Yes → Journal `evidence/journal/capability-builder-create-2026-08-31.md` (hash-tree path-normalization, pack-raw vs resolved).
- Distillation to `project-knowledge/` is Alex Gate 4 task.

## Scope Proof

- Remediation commit `2d7e359b` (2 files: `capability-skill.sh` + `run-acceptance.sh`) within `§7` allowlist; base feature `c0176f18` holds 31-file feature. `scope/implementation-commit.txt` is post-commit working-tree evidence (honest: `git cat-file -e` passes, marker not inside commit object, `git show HEAD:scope/...` is older).
- Protected manifests: 434 lines, `diff -q` PASS (before == after).
- No unstaged protected edits; no helper temp/lock remains on any error path (verified via parent inventory == pre-call).

## Gate 3 Evidence

Gate 3 PASS at `.tad/evidence/reviews/gate3/capability-builder-create.md` (all 12 ACs PASS).

## Gate 4 Human Acceptance

- **Verdict:** PASS
- **Accepted:** 2026-09-02
- **Human decision:** option 9 — archive Phase 1 and mark it complete; do not automatically start `evolve`.
- **Advisory judge:** skipped because the evidence slug and handoff slug do not match; this is non-blocking.
- **Worktree override:** the human authorized archival with the known dirty worktree. The implementation is committed; remaining changes are either this task's evidence/documentation or unrelated parallel YOLO2 work. No unrelated file was staged, committed, reverted, or overwritten during acceptance.

Dirty-state snapshot accepted for archival:

```text
D  .tad/active/epics/EPIC-20260824-yolo2-verified-orchestration.md
D  .tad/active/handoffs/COMPLETION-20260901-yolo2-phase3-cross-harness-memory.md
M  .tad/evidence/acceptance-tests/capability-builder-create/scope/implementation-commit.txt
M  .tad/project-knowledge/patterns/ac-verification.md
M  NEXT.md
M  PROJECT_CONTEXT.md
?? .tad/active/designs/DESIGN-20260831-capability-builder-phase1-create.md
?? .tad/active/designs/DESIGN-20260901-yolo2-phase3-cross-harness-memory.md
?? .tad/active/handoffs/COMPLETION-20260831-capability-builder-phase1-create.md
?? .tad/active/handoffs/HANDOFF-20260831-capability-builder-phase1-create.md
?? .tad/decisions/DR-20260901-yolo2-phase3-limited-core-acceptance.md
?? .tad/decisions/DR-20260901-yolo2-phase4-remain-opt-in.md
?? .worktrees/
```

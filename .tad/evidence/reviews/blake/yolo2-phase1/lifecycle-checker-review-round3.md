# Narrow Review — AC10 must-appear-follows-lifecycle delta (commit 7b12d429)

Reviewer model: ox-alpha-free (opencode-go/ox-alpha-free)
date: 2026-08-26
verified_head: 7b12d429 (+ archive proof commit 35996d99 in disposable worktree)

Scope: commit `7b12d429` touches ONLY `.tad/scripts/yolo-recovery.test.mjs`
(1 file, +73/−33; confirmed via `git show --stat`). Contract read from
`87d30085` ("Gate 4 lifecycle amendment — round 3") on
`.tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md`.
Main repo HEAD = `7b12d429bae65cad0b530c54ff0df6e0e58cfa66`.

## Q1 must-appear follows state

- **ALLOW_EXACT no longer contains any lifecycle path.** At `7b12d429`,
  ALLOW_EXACT holds exactly the stable product/status paths: scripts×2
  (`.tad/scripts/yolo-recovery.mjs`, `.tad/scripts/yolo-recovery.test.mjs`),
  guide (`.tad/guides/yolo-recovery.md`),
  `.tad/active/epics/EPIC-20260824-yolo2-verified-orchestration.md`,
  DR-20260824-yolo2-orchestration-kernel.md,
  DR-20260824-yolo2-vertical-slice-first.md,
  `.tad/project-knowledge/patterns/memory-and-learning.md`, `NEXT.md`,
  `PROJECT_CONTEXT.md`. The active HANDOFF path was removed from it by this
  delta. **All nine stable paths retain their unconditional must-appear loop**
  (`for (const rel of ALLOW_EXACT) expect(changed.includes(rel), ...)`).
- **offAllowlist accepts all four lifecycle paths** via the new
  `!ALLOW_LIFECYCLE_ACTIVE.includes(p)` clause plus the existing
  `!ALLOW_LIFECYCLE_ARCHIVE.includes(p)` clause; both arrays carry exactly the
  two active / two archive pair paths.
- **caseRequiredEvidence asserts requiredPair per resolved state:**
  `requiredPair = lifecycle.state === 'archived' ? [archived handoff, archived completion] : [active handoff, active completion]`,
  each asserted against the committed diff list `changed`. In archived state
  the active pair is NOT required in the net diff. Matches contract §round 3
  exactly.
- **Regression guard added:** a new expect asserts all four LIFECYCLE_PAIR
  paths are absent from ALLOW_EXACT, and that the active handoff path remains
  an accepted scope member (`offAllowlist([active-handoff]).length === 0`).
  The old single-path guard was replaced, not weakened.

## Q2 committed-archive proof

(a) Read `.tad/evidence/yolo/yolo2-verified-orchestration/phase1/committed-archive-proof.txt`: documents disposable worktree at `/private/tmp/tad-yolo2-ac10-proof` detached at `7b12d429`, frozen base `bfce27f3469960946679b03e2562ece67a34f0f3`, pre-archive suite PASS, git-mv of both files, archive commit `35996d99670f0c1bce58bf5bac28f015a7baf385`, and a full post-archive rerun (10 cases) with `WORKTREE_SUITE_EXIT=0`.

(b) Independently verified in the worktree:
- Worktree exists at `/private/tmp/tad-yolo2-ac10-proof`; `git log` shows
  `35996d99` directly on top of `7b12d429` (detached); full SHA matches the
  claimed `35996d99670f0c1bce58bf5bac28f015a7baf385`.
- Archive commit is a pure rename of BOTH files:
  `R100 .tad/active/handoffs/HANDOFF-...md → .tad/archive/handoffs/HANDOFF-...md`
  and same for COMPLETION (0 insertions/deletions — content identical by move).
- Worktree `base-commit.txt` = `bfce27f34699...` = merge-base of bfce27f3..HEAD.
- **I re-ran the FULL suite myself inside the worktree**
  (`node .tad/scripts/yolo-recovery.test.mjs`): all 10 cases
  (path-guard, lifecycle-e2e, verified-authority, authority-conflicts,
  side-effect-reconcile, status-capsule, atomic-write, binding-and-closure,
  dogfood-evidence, required-evidence) → RESULT=PASS, final `RESULT=PASS`,
  exit 0 — with REAL moved files on disk and REAL frozen-base..HEAD git diff.

(c) Net diff `bfce27f3..HEAD` in the worktree contains exactly:
`A .tad/archive/handoffs/COMPLETION-...md`, `A .tad/archive/handoffs/HANDOFF-...md`
(plus the stable EPIC/DR/guide/scripts/NEXT/PROJECT_CONTEXT/memory-and-learning members),
and does **NOT** contain either ACTIVE lifecycle path as an addition or in any form.

## Q3 sim-mode honesty + red controls

- **Simulated diff models the net effect of the move:** under
  `YOLO2_LIFECYCLE_SIM=archive`, `changed` = raw `git diff --name-only base..HEAD`
  minus both active lifecycle paths, with both archive paths injected — i.e.
  the simulation now exercises BOTH dimensions required by the round-3
  amendment (filesystem existence via `lifecycleExists`, AND the committed-diff
  list). Real runs use raw git output unchanged.
- **Honest content requirement retained:** in sim mode the archive copies'
  size check reads the REAL active counterpart from disk
  (`fs.existsSync` + `statSync(...).size > 0` on the active path) — a fake
  empty archive state cannot satisfy it.
- **16-combination fixture unchanged:** extracted LIFECYCLE_COMBOS from
  `7b12d429^` and `7b12d429` — byte-identical (`COMBOS_IDENTICAL`).
- **Red controls unchanged and green:** the workflow
  (`.claude/workflows/yolo-epic.workflow.js`), hooks
  (`.tad/hooks/precompact-session-snapshot.sh`), protocol
  (`.agents/skills/alex/references/yolo-execution-protocol.md`), and config
  (`.tad/config.yaml`) offAllowlist expects are identical between parent and
  delta, and the full-suite runs above confirm they stay green.
- **Runtime untouched:** `git show 7b12d429 --stat` lists only the test file;
  `.tad/scripts/yolo-recovery.mjs` is not modified by this delta.
- Extra control I ran myself: `YOLO2_LIFECYCLE_SIM=archive` full suite in the
  main repo → 10/10 RESULT=PASS.

verdict: PASS

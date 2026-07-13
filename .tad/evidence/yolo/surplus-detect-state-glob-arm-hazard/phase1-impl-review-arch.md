# Phase 1 Impl Review — Architecture Lens

**Task:** surplus-detect-state-glob-arm-hazard (Phase 1/1 — verify-and-fixture)
**Reviewer:** backend-architect (architecture / blast-radius / completeness lens)
**Date:** 2026-07-05
**Artifacts reviewed (worktree `wf_35a6e2d1-e8a-5`):**
- `.tad/tests/detect-state-fixture.sh` (new, git-tracked)
- `.tad/evidence/yolo/surplus-detect-state-glob-arm-hazard/phase1-fixture-run.txt` (new)
- `COMPLETION-surplus-detect-state-glob-arm-hazard.md`
- `tad.sh` L1330-1373 (`_tad_ver_cmp` + `detect_state`), unchanged
**Verdict:** ✅ CONDITIONAL PASS — Gate-3-passable. 0 P0, 1 P1 (non-blocking hardening), 2 P2.

> Note: the implementation, COMPLETION report, and evidence live in worktree
> `wf_35a6e2d1-e8a-5`, not on `main`. The COMPLETION path named in the review
> prompt resolves only inside that worktree. This review verified against the
> worktree artifacts and independently re-ran everything.

---

## Verification performed (not paper-read)

| Check | Method | Result |
|-------|--------|--------|
| Fixture syntax | `bash -n` | SYNTAX_OK |
| Fixture green | ran independently in worktree | 10 PASS / 0 FAIL, exit 0 (matches recorded evidence) |
| Git-tracked | `git ls-files` | 1 |
| tad.sh untouched | `git status` | clean (only a trace `.jsonl` untracked) |
| zsh guard (NFR2) | `zsh fixture.sh` | re-execs under bash, correct output, exit 0 |
| **Discrimination — hazard reintroduction** | injected `2.x same-major → v1.8` into a tad.sh copy | fixture RED: exact-match FAIL + FR4 hazard-check FAIL on 2.19.1/2.20.0, exit 1 |
| **Discrimination — preflight** | renamed `detect_state` in a tad.sh copy | `FAIL: extraction preflight … not extracted (renamed/moved?)`, exit 1 |
| Ground truth AC1 | `grep -cE '^[[:space:]]*2\.[0-9]+\*\)' tad.sh` | 0 |

The negative self-checks claimed in COMPLETION §5 are real — independently reproduced. The fixture is a genuine behavioral regression guard, not a perpetually-green stub.

---

## Strengths

1. **Single source of truth (extraction, not copy).** sed-extracts `_tad_ver_cmp` + `detect_state` at run time from tad.sh; no drifting function-body copy. Correctly avoids sourcing tad.sh whole (unguarded `main` at EOF). Extraction-integrity preflight (function-name grep, exactly-2 `^}` count, ≥20-line floor, `bash -n`, post-source `type` check) fails loudly on rename/move — verified.
2. **Behavior-pin over structure-pin is the right axis.** Pinning the observable `version.txt → state` contract (not the internal branch shape) means a legitimate future refactor stays green while any routing-corruption change goes red. Confirmed the fixture reddens on the actual failure mode (2.x misrouted into a v1.x label).
3. **Zero blast radius.** All work in `mktemp -d` sandboxes under one `$WORK` root, cleaned via `trap … EXIT`. tad.sh unmodified. No network, no deps beyond bash/sed/grep/mktemp. macOS bash-3.2-safe throughout.
4. **Evergreen (FR6).** `hazard_expected = upgrade iff target-major==2 else old` degrades gracefully across a future 3.x bump instead of rotting red. Target version derived live, so version bumps don't break the `current` case.
5. **Project-knowledge lessons applied and verified:** `|| true` on legal-no-match greps (lesson 1), `abc → old` undecidable-input case (lesson 2), bash re-exec guard (lesson 4).

---

## Findings

### P1-1 — "Silent reintroduction" goal only partially enforced: structural glob-arm guard is one-shot (AC1), not baked into the recurring fixture

The handoff's stated success criterion (§1.1) is that "future edits cannot **silently reintroduce** the 2.x glob-arm misclassification hazard." The fixture enforces this **behaviorally**, which covers the real routing-corruption failure mode. But there is a residual gap:

- While the target major is 2, versions like `2.19.1`/`2.20.0` are routed by the earlier `vmaj -eq tmaj → upgrade` branch and **never reach the cross-major `case "$ver"` block**. A reintroduced order-sensitive arm placed inside that block (e.g. `2.25*) echo "v1.8"`) that matches a version **not in the fixture matrix** would be dead code today and produce **no observable change** on the three 2.x cases the fixture tests — so the fixture stays green.
- The only structural guard against a reappearing `2.\d+\*)` arm is **AC1** (`grep -cE '^[[:space:]]*2\.[0-9]+\*\)' tad.sh` = 0), which is a **one-time pre-impl check**, not part of the recurring fixture. Nothing recurring blocks the structural regression.

**Impact:** narrow (no live misrouting while target major is 2; behavioral coverage catches the realistic case), which is why this is P1 not P0 — and it does **not** block Gate 3. **Recommendation (2 lines, cheap):** add the AC1 structural grep as an in-fixture assertion so the fixture fails red if any `2.\d+\*)` arm reappears in tad.sh, closing the gap between the stated goal ("cannot silently reintroduce") and delivered behavior. This turns the one-shot structural check into a durable guard alongside the behavioral one.

### P2-1 — Hazard-check on the target version is trivially redundant

`run_case "$TARGET_VERSION" "current"` triggers the `2.*` FR4 hazard-check, which asserts `current` is not `v1.8/v1.6/v1.4` — always trivially true, adding a noise PASS line (`2.33.0 hazard-check`). Harmless, but the hazard-class assertion is only meaningful for older-than-target 2.x inputs. Optional: scope the FR4 negative assertion to older-than-target 2.x cases, or leave as-is (it costs nothing).

### P2-2 — Recorded evidence hardcodes the worktree path

`phase1-fixture-run.txt` L3 records `TAD_SH=…/worktrees/wf_35a6e2d1-e8a-5/tad.sh`, a path that won't exist post-merge. Cosmetic (evidence is a historical run record; the fixture self-resolves at run time). Optional: regenerate the evidence line from the repo root at merge, or annotate it as a worktree artifact.

---

## Blast radius assessment

**Contained.** New test file + evidence file only; tad.sh (production installer) untouched (AC8 verified). Runtime side effects confined to `mktemp -d` sandboxes with EXIT-trap cleanup. No shared state, no network, no cross-project reach. Failure mode of the fixture itself is fail-loud (preflight) — it cannot pass vacuously on a moved/renamed target.

## Completeness assessment

All 7 FRs, 4 NFRs, and 9 ACs implemented and independently re-verified. The §10.2-sanctioned 7th case (`PARTIAL → partial`) is explicitly pre-authorized and correct. The one completeness gap (P1-1) is a knowingly-scoped behavior-pin design decision (COMPLETION §11) whose residual structural blind-spot is cheap to close.

## Gate 3 readiness

PASS-eligible. No correctness defect, no blast-radius concern, discrimination independently proven. P1-1 is a recommended hardening, not a blocker; P2s are cosmetic.

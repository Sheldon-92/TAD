# Code-Reviewer Review — HANDOFF-20260702-trajectory-eval-p3

**Reviewer**: code-reviewer (narrow-scope, Gate 2 pre-handoff)
**Date**: 2026-07-02
**Scope**: §4.2 / §6 / §9.1 / §10 + acceptance-protocol.md L100-140 + assemble-bundle.sh (full)
**Verdict**: CONDITIONAL PASS

---

## Summary

Purpose: wire a calibrated (advisory) trajectory judge into Alex's `*accept` protocol as an
additive sibling `step4d`, add active-first path resolution to `assemble-bundle.sh`, and ship a
30-day `gate-roi-report.sh`. The design is disciplined — three freeze prohibitions with matching
ACs, SAFETY line-set diff pinned to a stable commit, in-place metric definitions. The AC3 baseline
mechanism is empirically sound (verified below). However there is one **P0**: the entire new
active-first code path (FR2's whole reason to exist) is untested by any AC and, combined with the
all-path silent degradation contract, could ship as a permanent silent no-op — the exact
"unconsumed measurement" failure the Epic exists to prevent. Plus two P1 AC-integrity gaps.

**Empirical checks run:**
- `git cat-file -t 3a9c82e` → commit exists; baseline file present at that commit ✓
- AC3 forward-missing on UNMODIFIED file → `0` ✓ (mechanism sound)
- current SAFETY count = 5, baseline @3a9c82e = 5 ✓
- mirrors byte-identical (`diff -q`) → SAME ✓
- `grep step4d acceptance-protocol.md` → empty (no name collision) ✓
- `grep -rn assemble-bundle .claude/skills` → empty (no other caller) ✓
- **`grep -c 'blocking: false'` current = 4** (AC1 vacuousness — see P1-1)
- other 5 markers current = 0 (valid presence markers) ✓
- trajectory-eval-p2 = ARCHIVED (both HANDOFF + COMPLETION in archive/) — see P0-1

---

## 1. Critical Issues (P0)

### P0-1 — The new active-first path (FR2) has ZERO acceptance coverage, and failure is silent
**Focus areas 3 + 4 converge here.**

- AC4 regenerates `sep-phase2` — an **archived** slug → active lookup misses → exercises only the
  **archive fallback** (the old code path).
- AC6 E2E runs on `trajectory-eval-p2` — confirmed **archived** (`archive/handoffs/HANDOFF-…-p2.md`
  + `COMPLETION-…-p2.md` both present) → again archive path only.
- **Result: no AC ever exercises active-first resolution.** Yet FR2's entire purpose is to judge a
  trajectory *at acceptance time, before it is archived* (§1.1). So the one behavior being built is
  the one behavior never verified.
- Compounding factor: NFR1 makes every failure **silently skip** (exit 0 + 1 log line). A broken
  active-first glob (wrong dir, bad `head -1`, empty match) would not error — it would skip forever.
  Every real acceptance would emit `judge: skipped` and accumulate nothing. That is precisely the
  "traces無人消費 / 1-in-328" failure mode cited as this Phase's raison d'être (§1.2, §11.1).
- Blast-radius amplifier: `grep -rn assemble-bundle .claude/skills` is empty — step4d will be the
  **first and only** caller of the assembler, so this AC is the *only* possible guard.

**Required fix**: add an AC that runs the assembler (or the step4d wrapper — see P1-2) on an
**active** slug and asserts a well-formed, non-thin bundle. `HANDOFF-20260702-trajectory-eval-p3`
is live in `active/handoffs/` right now and is a natural fixture. Assert the bundle resolves the
handoff from `active/` (not archive) and contains the frontmatter + §9.1 sections.

---

## 2. Recommendations (P1)

### P1-1 — AC1 marker `blocking: false` is VACUOUS (verified: file already has 4 occurrences)
`grep -c 'blocking: false' acceptance-protocol.md` returns **4** *today* (step4c L108, step4e L112,
step4f L130, + a rationale). AC1's `grep -c ≥1` therefore PASSES even if step4d omits
`blocking: false` entirely — the marker cannot distinguish "step4d correctly advisory" from
"step4d missing the advisory flag." This is the single most safety-relevant marker (it encodes the
whole advisory-not-blocking contract of Intent §1.3) and it is the one that is unverifiable.

**Fix**: scope AC1 to the step4d block. Extract the block first, grep within it, e.g.
`awk '/^  step4d_trajectory_judge:/,/^  step4e_feedback:/' <file>` piped to each `grep -c`.
The other 5 markers currently return 0, so they are valid presence markers — but scoping all 6 to
the block is cheap and closes the "right token, wrong location" hole for the whole set.

### P1-2 — AC7 is not verifiable as written; step4d is prose, not a script
AC7/micro-6 say "移開 judge-prompt.md → **執行 step4d 腳本化部分** → `echo exit=$?`". But step4d is a
protocol YAML/prose block that *Alex-the-agent* executes; the skip logic (`--no-judge` check,
`judge-prompt.md` existence check, JSON validation, skip-line emission) lives in agent prose, not a
script. `assemble-bundle.sh` does **not** check `judge-prompt.md`, so moving that file changes no
script's exit code. There is nothing that emits `exit=$?`. As written the AC cannot be run.

**Fix (also resolves P0-1 and hardens NFR1)**: factor the *mechanical* parts of step4d into a small
wrapper, e.g. `.tad/eval/judge/step4d-run.sh <slug>`, that: (1) checks `--no-judge` /
`judge-prompt.md` existence, (2) calls `assemble-bundle.sh`, (3) validates the produced JSON, (4) on
any miss prints `judge: skipped ({reason})` and `exit 0`. The agent-only part (the actual Sonnet
spawn) stays in prose. Then AC7 tests the wrapper's real exit code, AC4/P0-1 test the wrapper on an
active slug, and NFR1's "truly silent" guarantee becomes *mechanical* rather than prose-dependent
(directly serves the "a false gate trains the operator to ignore it" lesson in §Project-Knowledge #6).

### P1-3 — §4.2C Section 2 windowing has no date carrier for reviews
Section 2 counts P0/P1 in `evidence/reviews/**/*.md` "窗口内", but review files carry **no date** in
their path (`reviews/blake/{slug}/name.md`). Only handoffs carry `HANDOFF-YYYYMMDD-` filenames. The
spec says "archive 中按文件日期過濾" — that clause only covers the handoff Audit-Trail source in the
same section, leaving the review-count window **undefined**. This breaks reproducibility and the
per-section "複算命令" promise (a reviewer can't re-derive an undefined window). Define the carrier
explicitly (file mtime? the owning handoff's date via slug lookup?) in §4.2C.

### P1-4 — §4.2C `evidence/reviews/**/*.md` `**` globstar is not BSD/default-bash safe
`**` recursion requires `shopt -s globstar` (OFF by default in bash) and is unsupported by BSD
`/bin/sh`; unquoted it silently degrades to a single-level glob → review files under
`reviews/blake/{slug}/` are missed, undercounting silently. Per the shell-portability principle
mandate the spec use `find … -name '*.md'`, not `**`.

---

## 3. Suggestions (P2)

- **P2-1 (AC3 is order-insensitive)**: `comm -23` on *sorted* line sets catches delete/modify (old
  line disappears) but **not a pure reorder** of existing lines. Low risk under additive-sibling
  discipline; worth a one-line note that AC3 guards deletion/rewrite, not relocation. The
  whitespace exclusion (`grep -vE '^\s*$'`) is safe — content lines can't be whitespace-only, and
  duplicate-line deletions are still caught by `comm` on sorted input (verified reasoning).
- **P2-2 (active-bundle representativeness — Focus 3 residual)**: only HF(L18)/CF(L22) are
  archive-scoped; reviews(L59), acceptance-tests(L71), traces(L82) are `evidence/`-rooted and
  active/archive-agnostic, so the "2-line change" claim holds and there is no hidden thinner-bundle
  drift from those sources — good. BUT at `*accept` time an active trajectory's `traces/*.jsonl` are
  still being written, so its bundle may carry fewer trace events than the fully-archived
  calibration set → mild calibration-representativeness drift. Note it in §10.2 alongside the
  existing "對比對餘量 0.25" caveat.
- **P2-3 (§4.2C Section 1 trace windowing)**: unspecified whether gates are windowed by event
  timestamp or by trace **file** date (`traces/YYYY-MM-DD.jsonl`). Pick one in the spec.
- **P2-4 (AC5 = structure, not correctness)**: AC5 verifies exit=0 + ≥4 `## ` sections + "複算命令"
  line + empty-window survival, but not that any *number* is right (validation-theater risk per the
  YOLO-audit principle). Largely data-analyst's lane, but consider one AC that hand-counts one
  metric (e.g. `bugfix-` prefix handoffs) and asserts the report matches.

---

## 4. Overall Assessment

**CONDITIONAL PASS.** Design is well-grounded: freeze prohibitions each have a matching AC, the AC3
SAFETY line-set diff is empirically verified sound (pinned commit exists, forward-missing=0 on the
unmodified file, count 5=5, mirrors identical), and both blast-radius checks are clean. Clear these
before Blake starts:

1. **P0-1** — add an active-slug AC (use `trajectory-eval-p3` itself); the sole new code path is
   otherwise untested and fails silently.
2. **P1-1** — scope AC1's 6 markers to the step4d block (`blocking: false` is vacuous at 4/file).
3. **P1-2** — extract a `step4d-run.sh` wrapper so AC7 (and P0-1) have a real exit code; makes NFR1
   mechanical. If declined, reframe AC7 as a documented agent walkthrough, not `exit=$?`.
4. **P1-3 / P1-4** — define the review-count window carrier and replace `**` with `find`.

P2s are polish and can be logged as carry-forward.

# Phase 1 Implementation Review — code-reviewer lens

**Handoff:** `.tad/active/handoffs/HANDOFF-surplus-detect-state-glob-arm-hazard.md`
**Completion Report:** `COMPLETION-surplus-detect-state-glob-arm-hazard.md` (worktree `wf_35a6e2d1-e8a-5`, commit `ee39d9d`)
**Reviewer:** code-reviewer (bash correctness / `set -e` / regression-fixture discriminative power)
**Date:** 2026-07-05
**Verdict:** CONDITIONAL — 1 P0 (validation-theater: fixture does not catch the hazard it exists to lock, empirically proven), 1 P1, 2 P2. Mechanically all 9 ACs are green and the code is clean, portable, and low-blast-radius; the gap is that the delivered fixture does not fulfil the task's stated purpose.

> Note: this file previously held the 2026-07-02 impl-review of the superseded dot-bounded-glob worktree run (commit 43c6972). This review targets the current fixture-only run committed at `ee39d9d`.

---

## What was verified (I re-ran everything in the worktree)

| Check | Result |
|---|---|
| `bash .tad/tests/detect-state-fixture.sh` | 10 PASS / 0 FAIL, exit 0 ✅ |
| `git diff main --stat` | 3 files, +243; fixture = 123 lines; **tad.sh not in diff** ✅ |
| AC1 `grep -cE '^[[:space:]]*2\.[0-9]+\*\)' tad.sh` | `0` ✅ |
| AC2 `git ls-files ...fixture.sh \| wc -l` | `1` ✅ |
| AC8 sub-check 1 `git diff --stat -- tad.sh \| wc -l` | `0` ✅ |
| AC8 sub-check 2 (filtered `git status --porcelain`) | **`1`** (report claims `0` — see P2-1) |
| detect_state / _tad_ver_cmp bodies (tad.sh L1330-1373) | match completion-report description ✅ |
| Extraction preflight (name grep + brace-count==2 + ≥20 lines + `bash -n` + `type` after source) | present & sound ✅ |

**Diff matches the completion report** on all load-bearing claims: 3 new files, 123-line fixture, tad.sh genuinely untouched, run evidence present. The `type _tad_ver_cmp` / `type detect_state` post-source checks (fixture L56-57) correctly address the design-review arch-P1-2 ("verify functions are callable, not just present").

---

## P0 — Blocking

### P0-1 — The fixture provides ZERO protection against the exact hazard it was built to lock (empirically proven)

The task's single stated purpose (§1.2 / §1.3 / §6.1 Human审查问题): *"任何未来把 `detect_state` 改回 order-sensitive glob 的编辑都会被 fixture 变红拦截。"* I tested this directly by injecting a realistic hazardous arm into `detect_state`'s cross-major `case "$ver"` block:

```
2.19*|2.2*)  echo "v1.8" ;;
```

Result — the fixture stayed **fully green**:
```
PASS: 2.19.1 -> upgrade
PASS: 2.19.1 hazard-check: not v1.8/v1.6/v1.4     <- passed with the v1.8 arm live in the code
...
Summary: 10 passed, 0 failed   exit=0
```
And AC1's structural grep against the injected file also returned **`0`** (the compound `2.19*|2.2*)` form is not matched by the anchored regex `^[[:space:]]*2\.[0-9]+\*\)`, which requires a line-leading `2.<digits>*)`).

**Both guard layers miss the reintroduced glob arm.** Root cause (matches design-review arch-P1-1, which was raised but not remediated): every 2.x input resolves on the exact-match / newer-than / **same-major→`upgrade`** path *before* control ever reaches the cross-major `case` block where a 2.x glob arm would live (`vmaj -eq tmaj` returns `upgrade` at tad.sh L1360; the glob block at L1362-1367 is only reachable when `vmaj < tmaj`). So the FR4 hazard-check (`case "$actual" in v1.8|v1.6|v1.4) FAIL`) is **tautologically green** for any 2.x input under a 2.x target — it can never fail, regardless of what glob arms exist.

Consequence: the completion report §4 FR4 claim ("Every 2.* input auto-triggers the hazard-check ... independent of the exact-match assertion") describes protection that does not exist. This is a textbook instance of the project's own L1 **"Validation Theater"** principle (principles.md, 2026-05-15): a green fixture that confirms file/behavior operations but does not prove the property it claims.

**Recommendation (do at least one; ideally a+b+c):**
- (a) Add ≥1 cross-major case that actually executes the glob block so it is live-tested: e.g. `run_case "1.9.0" "old"` and `run_case "1.8.0" "v1.8"`. Only then does an injected/broken arm turn the fixture red. This does NOT reopen out-of-scope v1.x *routing* work — it just gives the block one live assertion. (This is exactly arch-P1-1 rec (a), still unaddressed.)
- (b) Broaden AC1 so a compound/bracketed 2.x arm (`2.19*|2.2*)`, `2.1[0-9]*)`) cannot evade it — e.g. grep the extracted cross-major `case` region for any `2.` glob token, not just a line-leading anchor.
- (c) Add a real anti-hazard negative self-check: inject a 2.x glob arm into a *temp copy* of tad.sh and assert the fixture (or the AC1 grep) goes red. The current §5 self-check only flips the `9.9.9` expectation, which proves generic discrimination but NOT the hazard-specific property.

---

## P1 — Should fix before acceptance

### P1-1 — The recorded "discrimination proof" does not cover the hazard class, so the completion report over-claims

§5 Negative Self-Check tests two things: a flipped `9.9.9` expectation (generic red) and a renamed-function preflight (extraction red). Both are legitimate and pass. But neither exercises the **glob-reintroduction** scenario — the one property the fixture exists to guarantee. Combined with P0-1, the completion report presents the fixture as guarding the glob hazard when the only artifact that even partially does so is the AC1 grep (itself evadable). Fix: either add the hazard-specific self-check (P0-1c) or honestly reframe the report — the fixture locks the *numeric-routing behavior of the refactor* and catches *gross glob-first reversions*; the *anti-2.x-glob-arm* property is (weakly) guarded by AC1, which must not be deleted on the belief that "the fixture covers it."

---

## P2 — Note explicitly

### P2-1 — Completion report AC8 claims `0; 0`; the second sub-check actually returns `1` today
The filtered `git status --porcelain | grep -v '...' | wc -l` returns **1** in the worktree because the untracked trace file `.tad/evidence/traces/2026-07-05.jsonl` is not in the exclusion filter. The load-bearing claim (tad.sh untouched → sub-check 1 = `0`) holds, so scope discipline is genuinely fine — but the reported `0` is inaccurate and the sub-check is brittle. This is precisely design-review **cr-P1-1**, which recommended dropping the brittle `git status` sub-check; it was not applied. Low impact, but the report should match reality.

### P2-2 — AC1 structural grep is too narrow to be a reliable backstop
As shown in P0-1, `^[[:space:]]*2\.[0-9]+\*\)` only catches a line-leading literal `2.<digits>*)`. Any compound arm (`2.19*|2.2*)`), bracket form (`2.1[0-9]*)`), or a wholesale removal of the `_tad_ver_cmp` numeric guard evades it. Since AC1 is the *only* layer with any anti-glob teeth (P0-1), it should be hardened rather than left as the sole (leaky) net.

---

## What is solid (keep as-is)

- **No-source / sed-extraction** correctly avoids the unguarded `main` at EOF; extraction range terminates at the correct col-0 `}` for both functions (brace-count preflight == 2 verified against the live bodies).
- **Extraction-integrity preflight** is genuinely strong: name grep + brace count + ≥20-line floor + `bash -n` + post-source `type` check — a broken/renamed/truncated extraction FAILs loudly (addresses arch-P1-2).
- **Bash-enforcement guard** `[ -n "${BASH_VERSION:-}" ] || exec bash "$0" "$@"` (fixture L19) correctly defends the empirically-found zsh `local -a A=($1)` word-split hazard (📚 lesson 4).
- **`|| true` discipline** applied to all legal-no-match greps (TARGET_VERSION derivation L49, brace count L44) — no `set -e` ERR-trap surprise (📚 lesson 1).
- **Fail-safe `abc → old`** (undecidable input, 📚 lesson 2) and **never-downgrade `9.9.9 → current`** both trace correctly through the live body.
- **Evergreen FR6** (`hazard_expected = upgrade iff tmaj==2 else old`) matches the cross-major fall-through — survives a future 3.x bump.
- **Sandbox hygiene**: all work under one `mktemp -d $WORK` with `trap 'rm -rf "$WORK"' EXIT`; no side effects outside sandboxes; tad.sh genuinely untouched (AC8 sub-check 1 = 0).
- **PARTIAL 7th case** is the §10.2-sanctioned addition and traces correctly (`.claude/commands` without `.tad` → `partial`).
- **No `set -e` arithmetic gotcha**: counters use `X=$((X+1))` assignment form (always exit 0), not `((X++))`, so a failing case does not abort the run before the summary/exit-1 — confirmed by the report's own red self-check ("9 passed, 1 failed, exit=1").

---

## Recommendation

CONDITIONAL. **P0-1 is the material issue**: the fixture is a valid regression test for the numeric-routing refactor and catches gross reversions, but it provides no protection against — and its FR4 hazard-check gives false assurance about — the specific 2.x-glob-arm reintroduction the task was created to lock (empirically proven by injection: fixture stays 10/10 green with a live `2.19*→v1.8` arm; AC1 grep also misses it). Add a cross-major live case + a hazard-specific negative self-check + broaden AC1 (P0-1 a/b/c), and reframe the completion report's FR4 claim (P1-1). P2s are polish. No tad.sh change warranted; FR1 pre-verification holds (0 literal arms). Code quality itself is high; the defect is coverage/purpose, not correctness.

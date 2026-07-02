# Phase 1 Implementation Review -- Code Reviewer

**Handoff**: HANDOFF-surplus-detect-state-glob-arm-hazard.md
**Completion Report**: COMPLETION-surplus-detect-state-glob-arm-hazard.md (in commit 43c6972)
**Reviewer**: Code Reviewer (impl-review)
**Date**: 2026-07-02
**Commit**: 43c6972 (branch worktree-wf_b2a477da-39b-5)
**Verdict**: PASS (0 P0, 1 P1, 1 P2)

---

## Scope Verification

The implementation commit modifies exactly 2 files:
- `tad.sh` (+6/-4 lines) -- the substantive change
- `COMPLETION-surplus-detect-state-glob-arm-hazard.md` (+64 lines) -- completion report

The tad.sh diff is confined to `detect_state()` lines 1358-1369. No other functions were modified. `_tad_ver_cmp()` (L1330-1341) is byte-identical before/after (verified via diff). The same-major path (`vmaj -eq tmaj` at L1357-1358) is untouched. This matches handoff scope exactly.

---

## AC Verification (Independent)

| # | Acceptance Criterion | Verification Method | Expected | Actual | Status |
|---|---------------------|---------------------|----------|--------|--------|
| AC1 | No ambiguous prefix globs in detect_state | `grep -cE '^\s+1\.[0-9]+\*\)'` on committed tad.sh | 0 | 0 | PASS |
| AC2 | Dot-bounded rejects cross-minor | `case "1.80.0" in 1.8\|1.8.*)` | NO-MATCH | NO-MATCH | PASS |
| AC3 | Dot-bounded accepts valid patch | `case "1.8.3" in 1.8\|1.8.*)` | MATCH | MATCH | PASS |
| AC4 | tad.sh syntax valid | `bash -n` on committed tad.sh | exit 0 | exit 0 | PASS |
| AC5 | Safety comment present | `grep -c 'GLOB SAFETY'` on committed tad.sh | 1 | 1 | PASS |
| AC6 | Change scope limited | `git diff --stat` | tad.sh only, ~6-8 lines | tad.sh +6/-4 | PASS |

**AC1 Note**: The handoff's original AC1 command (`grep -cE '1\.8\*|1\.6\*|1\.5\*|1\.4\*' tad.sh`) returns 2 on the committed code because the safety comment itself contains `1.8*` as instructive anti-pattern text. This was predicted by the design review P1-1 (code-reviewer). Blake documented this in the completion report and provided a scoped alternative grep. I verified independently using a case-arm-scoped grep (`^\s+1\.[0-9]+\*\)`) which returns 0, confirming no prefix-glob case arms remain in actual code.

---

## Extended Edge Case Verification

| Edge case | Input | Expected result | Actual | Status |
|-----------|-------|-----------------|--------|--------|
| Bare minor v1.8 | `1.8` | MATCH (v1.8 arm) | MATCH | PASS |
| Patch v1.8.3 | `1.8.3` | MATCH (v1.8 arm) | MATCH | PASS |
| Cross-minor collision v1.80 | `1.80.0` | NO-MATCH (falls to *) | NO-MATCH | PASS |
| Multi-digit patch v1.4 | `1.4.12` | MATCH (v1.4 arm) | MATCH | PASS |
| Bare v1.5 | `1.5` | MATCH (v1.6 compound arm) | MATCH | PASS |
| Patch v1.5.2 | `1.5.2` | MATCH (v1.6 compound arm) | MATCH | PASS |
| Bare v1.6 | `1.6` | MATCH (v1.6 compound arm) | MATCH | PASS |
| Bare v1.4 | `1.4` | MATCH (v1.4 arm) | MATCH | PASS |
| Cross-minor collision v1.60 | `1.60.0` | NO-MATCH (falls to *) | NO-MATCH | PASS |
| v2 hypothetical | `2.19.1` | old (falls to *) | old | PASS |

All 10 edge cases pass. The compound `1.6|1.6.*|1.5|1.5.*` arm correctly matches both v1.5 and v1.6 series (including bare versions), confirming the design review's P2-2 coverage gap is addressed in practice.

---

## Findings

### P1-1: Completion report AC1 records PASS despite actual=2 (expected=0)

**Location**: Completion report, AC verification table, AC1 row

**Issue**: The completion report records AC1 actual value as `2` but marks it `PASS (see note)`. The AC1 specification in the handoff (section 9.1) explicitly expects `0`. While the note correctly explains why the count is 2 (safety comment text, not code), and the scoped alternative grep proves no code-level prefix globs remain, the completion report should be transparent that the AC as literally written FAILS, and the PASS is based on an amended verification method.

This matters because the design review (code-reviewer) issued this as a P1 with verdict CONDITIONAL PASS, stating "P1-1 must be resolved before implementation." The handoff's AC1 grep was not amended before implementation. Blake handled it pragmatically by documenting the discrepancy, which is reasonable -- but the completion report should distinguish between "AC as written: FAIL (returns 2, expected 0)" and "AC intent verified via scoped grep: PASS".

**Impact**: Medium. The current wording could be read as claiming the original AC passed, which it did not. For gate reviewers who verify mechanically, this creates confusion.

**Recommendation**: Amend the AC1 row to show Status as `PASS (amended)` or split into two rows: one for the literal AC (FAIL, expected 0 got 2) and one for the scoped verification (PASS, 0 code-level prefix globs). This makes the audit trail honest.

---

### P2-1: Completion report runs `npm test` and `npx tsc` against a shell-only project

**Location**: Completion report, Layer 1 Check Results table

**Issue**: The Layer 1 checks include `npm test` (result: "No tests yet") and `npx tsc --noEmit` (result: "No tsconfig.json"). These are irrelevant to a bash shell script project. Running them is harmless but adds noise to the completion report and may mislead a reviewer into thinking these checks are meaningful for this change.

**Impact**: Very low. No functional impact; cosmetic only.

**Recommendation**: For shell-script-only changes, Layer 1 checks should include `bash -n <script>` and `shellcheck <script>` (if available) rather than npm/tsc checks. This is a process improvement, not a blocker.

---

## Code Quality Assessment

| Dimension | Rating | Notes |
|-----------|--------|-------|
| Correctness | Excellent | All 3 case arms correctly converted to dot-bounded patterns; 10/10 edge cases pass |
| Scope discipline | Excellent | Only the 3 case arms + safety comment changed; _tad_ver_cmp untouched; same-major path untouched |
| Shell compatibility | Excellent | POSIX case-glob only (pipe alternation + wildcard); no extglob; bash 3.2 safe |
| Safety comment | Good | Informative for future maintainers; correctly explains the hazard |
| Formatting | Good | Aligned echo statements; consistent style with surrounding code |
| Design review handling | Adequate | P1-1 not formally resolved before implementation but pragmatically handled via documentation |

---

## Positive Observations

1. **Pattern replacement is semantically correct.** Independently verified that `1.8|1.8.*` accepts `1.8` and `1.8.x` while rejecting `1.80.x`. The fix eliminates the latent hazard as designed.

2. **Zero blast radius beyond the target.** The diff is exactly +2 comment lines and 4 case-arm replacements. No control flow change, no new logic paths, no change to return values. The downstream STATE consumer at L1427+ is unaffected.

3. **The compound arm `1.6|1.6.*|1.5|1.5.*` is correctly structured.** Each sub-version gets both bare and dotted alternatives, maintaining the same routing behavior as the original `1.6*|1.5*`.

4. **Safety comment is well-placed and actionable.** It tells future maintainers both what to do (dot-bounded) and what not to do (prefix globs), with a concrete example of the hazard.

---

## Summary

The implementation is clean, correct, and well-scoped. The code change itself has zero issues -- all 6 ACs pass (with AC1 requiring a scoped grep due to the known design-review P1-1 interaction with the safety comment). The only finding is a documentation clarity issue in the completion report (P1-1: AC1 should distinguish between the literal AC result and the amended verification). One P2 on irrelevant Layer 1 checks. No bugs, no security issues, no regressions.

**Verdict: PASS**

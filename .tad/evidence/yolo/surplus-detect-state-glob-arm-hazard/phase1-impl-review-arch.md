# Phase 1 Implementation Review -- Backend Architecture

**Handoff**: HANDOFF-surplus-detect-state-glob-arm-hazard.md
**Completion**: COMPLETION-surplus-detect-state-glob-arm-hazard.md
**Commit**: 43c6972 (branch worktree-wf_b2a477da-39b-5)
**Reviewer**: Backend Architecture Expert (implementation review)
**Date**: 2026-07-02
**Verdict**: PASS (0 P0, 0 P1, 3 P2)

---

## Scope Verification

**Commit diff**: +6 / -4 in tad.sh only, plus a 64-line completion report. The code change is confined to `detect_state()` lines 1361-1367: two comment lines added and three case arms replaced. No other files touched. No scope creep.

**Downstream consumer check**: The output strings (`"v1.8"`, `"v1.6"`, `"v1.4"`, `"old"`) are consumed by the `case $STATE in` block at L1427-1464. The strings are unchanged by this edit. No downstream breakage possible.

---

## AC Verification Audit

| AC | Handoff expected | Completion actual | Independent verification | Verdict |
|----|-----------------|-------------------|-------------------------|---------|
| AC1 | grep returns 0 | 2 (comment text, see note) | Scoped `grep -cE '^\s+1\.[4-8]\*\)' tad.sh` returns 0 on committed file. The 2 matches are in the safety comment, not in case-arm code. | PASS -- honest reporting, P1-1 from design review correctly handled |
| AC2 | `1.80.0` returns NO-MATCH | NO-MATCH | `bash -c 'case "1.80.0" in 1.8\|1.8.*) echo M;; *) echo N;; esac'` -> N | PASS |
| AC3 | `1.8.3` returns MATCH | MATCH | `bash -c 'case "1.8.3" in 1.8\|1.8.*) echo M;; *) echo N;; esac'` -> M | PASS |
| AC4 | `bash -n tad.sh` exit 0 | exit 0 | `git show 43c6972:tad.sh \| bash -n /dev/stdin` -> exit 0 | PASS |
| AC5 | `grep -c 'GLOB SAFETY' tad.sh` returns 1 | 1 | `git show 43c6972:tad.sh \| grep -c 'GLOB SAFETY'` -> 1 | PASS |
| AC6 | tad.sh only, ~6-8 lines delta | +6/-4 | `git show --stat 43c6972 -- tad.sh` -> 10 lines changed, only tad.sh | PASS |

All 6 ACs independently verified. No false greens detected.

---

## Pattern Correctness Verification

Each case arm independently tested against the committed code patterns:

| Pattern | Input | Expected | Actual | Notes |
|---------|-------|----------|--------|-------|
| `1.8\|1.8.*` | `1.8` | MATCH | MATCH | Bare minor version |
| `1.8\|1.8.*` | `1.8.3` | MATCH | MATCH | Standard patch |
| `1.8\|1.8.*` | `1.8.15` | MATCH | MATCH | Multi-digit patch |
| `1.8\|1.8.*` | `1.80.0` | NO-MATCH | NO-MATCH | Cross-minor -- the fix target |
| `1.8\|1.8.*` | `1.89.1` | NO-MATCH | NO-MATCH | Cross-minor -- the fix target |
| `1.8\|1.8.*` | `1.8.` | MATCH | MATCH | Trailing dot (degenerate) |
| `1.6\|1.6.*\|1.5\|1.5.*` | `1.5.2` | MATCH | MATCH | v1.5 on compound arm |
| `1.6\|1.6.*\|1.5\|1.5.*` | `1.6` | MATCH | MATCH | v1.6 bare |
| `1.4\|1.4.*` | `1.4.12` | MATCH | MATCH | Multi-digit patch |
| `*` | `2.19.1` | old | old | v2 fallthrough |

All patterns produce correct results.

---

## Findings

### P2-1: Behavioral change for non-dotted version suffixes not documented

**Location**: tad.sh L1364-1366 (committed)

**Issue**: The old prefix-glob `1.8*` matched any string starting with `1.8`, including non-dotted suffixes like `1.8a`, `1.8-beta`, `1.8rc1`. The new dot-bounded pattern `1.8|1.8.*` does NOT match these -- they fall through to `*)` and get `old`.

Independently verified:
```
bash -c 'case "1.8a" in 1.8|1.8.*) echo MATCH;; *) echo NO-MATCH;; esac'  -> NO-MATCH
bash -c 'case "1.8a" in 1.8*)      echo MATCH;; *) echo NO-MATCH;; esac'  -> MATCH
```

Same for `1.8-beta`:
```
bash -c 'case "1.8-beta" in 1.8|1.8.*) echo MATCH;; *) echo NO-MATCH;; esac'  -> NO-MATCH
bash -c 'case "1.8-beta" in 1.8*)      echo MATCH;; *) echo NO-MATCH;; esac'  -> MATCH
```

**Impact**: Very low. TAD controls the version string format (`X.Y.Z` semver written by TAD itself to `.tad/version.txt`). Non-dotted suffixes are not a realistic input. The new behavior (routing `1.8a` to `old` instead of `v1.8`) is actually more correct -- a malformed version string should not route to a specific migration path. However, the handoff's NFR2 states "No functional behavior change for any version string that currently exists (1.4.x through 1.8.x)," and while no real version like `1.8a` exists, the behavioral change is technically undocumented.

**Recommendation**: No code change needed. Document this in the completion report as an intentional narrowing of the match scope. If a future maintainer encounters a version string with non-dotted suffixes, the `old` fallback is the safer routing.

---

### P2-2: Missing `--verify-denylist` regression test evidence

**Location**: Completion report, "Layer 1 Check Results"

**Issue**: The handoff implementation step 6 explicitly calls for `bash tad.sh --verify-denylist` to confirm no regression in the installer self-check mechanism. The completion report does not include this test result. It shows `bash -n tad.sh` (syntax) and `npm test` (not applicable), but not the denylist verification.

**Impact**: Low. The edit changes only case-arm patterns within `detect_state()`, which is structurally independent from `verify_denylist_drift()` (at L696). The denylist mechanism operates on directory/file lists, not version routing. A regression is extremely unlikely. However, the handoff explicitly requested it as an integration test.

**Recommendation**: Run `bash tad.sh --verify-denylist` on the committed version and record the result. This is a 2-second confirmation.

---

### P2-3: v1.5 series edge case missing from completion report test matrix

**Location**: Completion report, "Edge Case Test Results"

**Issue**: Both design reviews (arch P2-2, code-reviewer P2-1) flagged that the test matrix does not cover the v1.5 series. The compound arm `1.6|1.6.*|1.5|1.5.*` was not tested with a `1.5.x` input in the completion report. Independent verification confirms `1.5.2` correctly matches and produces `v1.6`, so the implementation is correct. But the gap noted in design review was not closed in the implementation.

**Impact**: Very low. The pattern `|1.5|1.5.*` is structurally identical to the tested `|1.8|1.8.*` arm. The `|` operator in bash case statements is well-established. Independent testing confirms correctness. But not recording this test means a design-review finding went unaddressed without acknowledgment.

**Recommendation**: Add `1.5.2 -> MATCH (v1.6)` to the edge case table for completeness. This closes the design review finding.

---

## Positive Observations

1. **Implementation exactly matches the handoff spec.** Three case arms replaced, one safety comment added, no scope creep, no extraneous changes. The +6/-4 delta is the minimum possible change.

2. **AC1 discrepancy handled honestly.** The P1-1 from the code-reviewer's design review (AC1 grep conflicting with the safety comment) was resolved by honest reporting: the count is 2 because the comment contains the old pattern as anti-example, and a scoped grep demonstrates 0 code matches. This is transparent and correct.

3. **Shell compatibility preserved.** No extglob, no bash 4+ features, no `[[ ]]` in case arms. The patterns use only POSIX case-glob syntax. Compatible with macOS bash 3.2.

4. **Blast radius is textbook minimal.** One function, three pattern replacements, no control flow change, no data model change, no new functions, no API change. Downstream consumer strings unchanged.

5. **The safety comment adds real value.** The `GLOB SAFETY` comment at L1361-1362 explains both the correct pattern AND the hazard, making the intent clear for any future maintainer who might add new version-series arms.

---

## Architecture Assessment

| Dimension | Rating | Notes |
|-----------|--------|-------|
| Implementation fidelity | Excellent | Exact match to handoff spec, no deviations |
| Code correctness | Excellent | All patterns independently verified correct |
| Blast radius | Excellent | 3 case-arm patterns + 1 comment; no structural change |
| Shell compatibility | Excellent | POSIX case-glob only, bash 3.2 verified |
| Test coverage | Good | Core cases covered; v1.5 series and non-dotted suffix gaps are P2 |
| Completion report quality | Good | Honest AC1 reporting; missing denylist test and v1.5 test |

---

## Summary

The implementation is a clean, correct, minimal edit that exactly matches the handoff specification. All 6 ACs pass under independent verification. The three P2 findings are documentation and test-coverage gaps, not code defects. No P0 or P1 issues. The P1-1 from design review was handled honestly and correctly in the completion report. The code change is safe to merge.

**Verdict: PASS**

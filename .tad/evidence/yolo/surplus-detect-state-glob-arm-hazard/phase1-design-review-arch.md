# Phase 1 Design Review — Backend Architecture

**Handoff**: HANDOFF-surplus-detect-state-glob-arm-hazard.md
**Reviewer**: Backend Architecture Expert
**Date**: 2026-07-02
**Verdict**: PASS (0 P0, 0 P1, 2 P2)

---

## Scope Assessment

The handoff modifies a single function (`detect_state()`) in `tad.sh` (1853 lines), replacing three prefix-glob case arms with dot-bounded patterns. Files to modify: `tad.sh` only. This is a shell script installer -- the review domain is backend/infrastructure (shell scripting, version routing logic). No frontend, no API, no database.

---

## Findings

### P2-1: AC1 verification command has a regex escaping subtlety that could mislead

**Location**: Section 9.1, AC1 verification method

**Issue**: The AC1 grep command `grep -cE '1\.8\*|1\.6\*|1\.5\*|1\.4\*' tad.sh` uses `-E` (extended regex), where `\*` means a literal asterisk -- this is correct. However, the handoff's "pipe-escape note" in Section 9.1 says to un-escape `|` when extracting to bash, which would change the command to `grep -cE '1\.8*|1\.6*|1\.5*|1\.4*' tad.sh`. Under ERE, unescaped `*` is a quantifier (zero-or-more of the previous char), not a literal. `1\.8*` in ERE matches `1.` followed by zero or more `8`s -- it would match `1.` alone, `1.8`, `1.88`, etc. The command would still return >0 on the OLD code (matching the literal `1.8*` substring) and 0 on the NEW code (no `1.8*` substring), so it happens to produce the correct PASS/FAIL. But the regex semantics are wrong -- it is testing for the right thing by accident, not by design.

**Impact**: Low. The verification produces the correct result in practice. But a future maintainer copying this pattern for a different grep check could be bitten by the ERE `*` quantifier vs glob `*` confusion.

**Recommendation**: Use `grep -cF '1.8*' tad.sh` (fixed-string mode) OR `grep -cP '1\.8\*' tad.sh` (PCRE, where `\*` is unambiguously literal). Fixed-string mode is the simplest since we are looking for the literal substring `1.8*`. Alternatively, keep `-E` but note that the pipe-escape un-escaping instruction should NOT apply to the `\*` inside the regex -- the backslash-star is the regex literal, not a markdown escape.

---

### P2-2: Missing coverage for the `1.5` bare-version edge case in test matrix

**Location**: Section 8.3, Edge Cases table

**Issue**: The edge-case test matrix covers `1.8`, `1.8.3`, `1.80.0`, `1.4.12`, and `2.19.1`. It does not cover `1.5` or `1.5.x` versions. The `1.5` series is grouped with `1.6` in the same case arm (`1.6|1.6.*|1.5|1.5.*)`), and while the pattern is structurally identical to the `1.8` arm (which IS tested), the `1.5` arm is the second alternative in a compound pattern. A test confirming `1.5.2` matches and produces `v1.6` would verify that the compound `|`-separated pattern works as intended when the match occurs on a later alternative.

**Impact**: Very low. The bash case-statement `|` operator is well-established and the pattern is structurally identical to the tested `1.8` arm. But completeness of the test matrix for the compound arm is worth noting.

**Recommendation**: Add one row to the edge-case table: `1.5.2` input, expected MATCH on the `1.6|1.6.*|1.5|1.5.*` arm, outputting `v1.6`.

---

## Positive Observations

1. **Blast radius is minimal and well-bounded.** The change touches exactly 3 case-arm patterns + adds 1 comment. No control flow change, no new functions, no data model change. The `_tad_ver_cmp` function and the same-major path are explicitly out of scope. The downstream STATE consumer (L1427 case block) is unchanged. This is a textbook minimal-risk fix.

2. **The hazard is real and independently verified.** I confirmed that the old pattern `1.8*` matches `1.80.0` and `1.89.1` (false positives), while the new pattern `1.8|1.8.*` correctly rejects both. The fix is semantically correct.

3. **Shell compatibility is sound.** The proposed patterns use only POSIX case-glob syntax (`|` alternation + `*` wildcard). No `extglob`, no `[[ ]]` in the case arms, no bash 4+ features. Compatible with macOS's bash 3.2.

4. **Design alternatives are well-analyzed.** Section 11.1 considers four approaches (dot-bounded, `_tad_ver_cmp` restructuring, extglob, regex) and selects the one with the smallest blast radius. The rationale is sound.

5. **The handoff correctly identifies that `_tad_ver_cmp` is NOT the problem.** The numeric comparison function is already correct; the issue is specifically in the case-statement pattern matching that routes to the granular v1.x state labels. The fix targets the right layer.

---

## Architecture Assessment

| Dimension | Rating | Notes |
|-----------|--------|-------|
| Blast radius | Excellent | 3 lines changed in 1 file, no behavioral change for existing valid inputs |
| Design completeness | Good | All components specified, function locations verified, edge cases enumerated |
| Backward compatibility | Excellent | No existing valid version string changes behavior |
| Shell portability | Excellent | POSIX case-glob only, bash 3.2 safe |
| Testing coverage | Good | 5 edge cases; P2-2 notes one gap |
| Verification commands | Good | AC commands work; P2-1 notes a cosmetic regex issue |

---

## Summary

This is a clean, well-scoped, low-risk fix to a real (if latent) version-detection hazard. The design is complete, the alternatives analysis is thorough, and the blast radius is minimal. No P0 or P1 issues found. Two P2 observations on test coverage and verification command semantics, neither of which blocks implementation.

**Verdict: PASS**

# Design Review: surplus-detect-state-glob-arm-hazard

**Reviewer**: code-reviewer
**Date**: 2026-07-02
**Handoff**: `.tad/active/handoffs/HANDOFF-surplus-detect-state-glob-arm-hazard.md`
**Verdict**: CONDITIONAL PASS (1 P1 must be resolved before implementation)

---

## Summary

The handoff is well-structured, focused, and grounded. Line numbers for `_tad_ver_cmp()` (L1330), `detect_state()` (L1343), and `verify_denylist_drift()` (L696) all verified against the live source. The proposed dot-bounded patterns (`1.8|1.8.*`) are correct POSIX case-glob syntax, bash 3.2 safe, and correctly reject cross-minor collisions (`1.80.0` returns NO-MATCH) while accepting valid versions (`1.8`, `1.8.3` both return MATCH). File list is complete (only `tad.sh` needs changes). Downstream consumers at L1444/1449/1454 consume state strings (`"v1.8"`, `"v1.6"`, `"v1.4"`) that are unchanged by this edit.

One P1 found: AC1's verification grep conflicts with the safety comment required by FR4.

---

## Findings

### P1-1: AC1 grep conflicts with FR4 safety comment (MUST FIX)

**Location**: Section 9.1 AC1 vs Section 6 step 4

**Problem**: AC1 verification command (after markdown un-escape):
```
grep -cE '1\.8\*|1\.6\*|1\.5\*|1\.4\*' tad.sh
```
expects result `0` (no ambiguous prefix globs remain).

But the safety comment proposed in FR4 / step 4:
```bash
# GLOB SAFETY: use dot-bounded patterns (1.8|1.8.*), NOT prefix globs (1.8*).
# Prefix globs match across minor boundaries (1.8* matches 1.80.0).
```
contains the literal text `1.8*` in both lines. The grep ERE pattern `1\.8\*` matches literal `1.8*`, so it would match both comment lines, returning 2 instead of 0.

**Evidence** (verified live):
```
$ echo '# ...NOT prefix globs (1.8*).' | grep -cE '1\.8\*|...'
1
$ echo '# ...boundaries (1.8* matches 1.80.0).' | grep -cE '1\.8\*|...'
1
```

**Impact**: AC1 will FAIL at Gate 3 even with a correct implementation. Blake either (a) omits the comment to pass AC1 (violating FR4/AC5), or (b) adds the comment and AC1 fails. No way to satisfy both simultaneously as written.

**Fix options** (pick one):

Option A -- Scope the grep to the case block only:
```
AC1 verification: sed -n '/case "\$ver"/,/esac/p' tad.sh | grep -cE '1\.8\*|1\.6\*|1\.5\*|1\.4\*'
```
This restricts the match to case-arm lines, excluding comments.

Option B -- Reword the safety comment to avoid the literal old patterns:
```bash
# GLOB SAFETY: use dot-bounded patterns (X|X.*), NOT prefix globs (X*).
# Prefix globs match across minor boundaries (e.g. 1-dot-8-star matches 1.80.0).
```
Less natural but avoids the collision.

Option C -- Use a non-ERE grep that matches only the case-arm syntax:
```
grep -cE '^\s+1\.[0-9]+\*\)' tad.sh
```
This matches lines where the glob is part of a case arm (ending with `)`), not in a comment.

**Recommended**: Option A or C. Option A is simplest and most explicit.

---

### P2-1: Edge case table covers only v1.8 series

**Location**: Section 8.3

**Observation**: All 5 edge cases test the `1.8|1.8.*` pattern. The multi-alternative arm `1.6|1.6.*|1.5|1.5.*` is not tested. While the glob logic is identical, a typo in the `|`-joined alternatives would not be caught by the current edge case table.

**Suggestion**: Add one test for the v1.6/1.5 arm, e.g.:
```
| v1.5 patch version | 1.5.2 | MATCH on 1.6|1.6.*|1.5|1.5.*) | bash -c 'case "1.5.2" in 1.6|1.6.*|1.5|1.5.*) echo MATCH;; *) echo NO;; esac' |
```

---

### P2-2: Micro-task grep commands (section 6.1) lack pipe-escape note

**Location**: Section 6.1

**Observation**: Section 9.1 has the critical pipe-escape note ("un-escape `\|` to `|` when running in bash"). Section 6.1 micro-tasks contain grep commands with pipes but do not include this note. If Blake copy-pastes verification commands from section 6.1 without un-escaping, the grep will look for literal backslash-pipe and return 0 (false pass).

**Suggestion**: Add the same pipe-escape note at the top of section 6.1, or convert the micro-task verification commands to use a form that doesn't need escaping (e.g., use `-F` fixed string grep).

---

## Frontmatter Check

| Field | Value | Correct? |
|-------|-------|----------|
| task_type | code | YES -- single-file code edit |
| e2e_required | no | YES -- shell pattern replacement, no integration surface |
| research_required | no | YES -- no external research needed |
| skip_knowledge_assessment | yes | YES -- no new learnable knowledge from this fix |
| gate4_delta | [] | YES -- no knowledge entries expected |

---

## File List Completeness

Only `tad.sh` is listed. Verified: the prefix globs appear only in `detect_state()` at L1362-1364. No other files reference these patterns. The downstream `case $STATE in` block (L1427) consumes string values that are not changed. File list is complete.

---

## Design Coherence

Requirements (FR1-FR4, NFR1-NFR2) align with the technical design (pattern replacement table in section 4.2). The chosen approach (dot-bounded case patterns) is the minimal-risk fix. The alternatives analysis (section 11.1) is reasonable -- extglob and regex alternatives correctly rejected for compatibility/restructuring reasons.

---

## Verdict

**CONDITIONAL PASS** -- P1-1 must be resolved (either change the AC1 grep scope or reword the comment) before Blake begins implementation. P2s are optional improvements.

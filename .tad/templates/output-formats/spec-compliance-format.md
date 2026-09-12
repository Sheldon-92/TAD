# Spec Compliance Review Output Format

> Use this format when running spec-compliance-reviewer (Ralph Loop Layer 2 Group 0)

## Task Completion Matrix

| # | Acceptance Criterion | Status | Evidence (file:line) | Notes |
|---|---------------------|--------|---------------------|-------|
| 1 | {AC text from handoff} | SATISFIED / NOT_SATISFIED / PARTIALLY_SATISFIED | {file:line where implementation found} | {what was verified} |

## Summary

- Total ACs: {N}
- Satisfied: {N}
- Not Satisfied: {N}
- Partially Satisfied: {N}

## Verdict: PASS / FAIL

- PASS = zero NOT_SATISFIED items. Up to 3 PARTIALLY_SATISFIED items allowed.
- FAIL = any NOT_SATISFIED item, regardless of justification.

## Input Sources

1. **Handoff AC source**: § 9.1 Spec Compliance Checklist (preferred) OR § 9. Acceptance Criteria (fallback)
2. **Implementation files**: List of files read and verified

## Red Flags

- AC has no corresponding implementation code
- Implementation exists but does not match AC description
- File mentioned in AC was not created or modified
- Feature partially implemented but missing critical behavior

## Layer 2 dirty-tree adjudicate (P2 tax-cut)

Independent review is **required**. Before raising **P0** on a dirty worktree, paste/apply
`docs/process-tax-cut.md` §2 (also `patterns/process-tax-cut.md`):

1. Diff **this task’s pathspec** vs the finding path. Outside pathspec → not this knife unless a whole-tree fence was contracted.
2. Cross-check prior knives’ known dirty patterns (NEXT/PROJECT_CONTEXT riders, leftover twins, judge bundles, gitignored fixtures). Same class already recorded → **FALSE POSITIVE (pre-existing)** + pointer — do not mint a new P0.
3. Still write the finding. Adjudication is a label, not a skip of the second reviewer.
4. Record: `{path} | P0 vs FALSE_POSITIVE | pointer or “in-delta”`.

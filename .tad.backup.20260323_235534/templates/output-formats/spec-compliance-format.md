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

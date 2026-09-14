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

## Optional Layer 2 review habits (OCR thin borrow)

SSOT: docs/process-tax-cut.md §4; if drift, docs win.

### Optional Layer 2 review habits (OCR thin borrow, copy)

```
Status: optional paste. Not a Gate. Not a substitute for Gate 2 dual disk reviews or Alex ≠ Blake.

- K1 Asymmetric-bound, falsify-only second pass. A later look at the same delta sees less evidence (diff + claimed findings only). Veto only when the diff directly contradicts the claim. Do not mint new findings on this pass. Parse/format failure → fail-open (keep the finding).
- K2 Precision over recall as Layer 2 default. Prefer fewer P0/P1 with replayable evidence (path + command/hunk). Comment volume is not quality. Do not lower recall on security-auditor when that Group 2 trigger fired (see K5).
- K3 Dispatch is the pathspec, not agent whim. Review handoff §7 / allowed files only. Do not expand the file set like a free agent. Do not add a rule.json or language-md rule engine.
- K4 Claims must be localizable or labeled unanchored. Every finding cites path + command/hunk, or is labeled unanchored / extra-file. Do not treat model line numbers as SSOT.
- K5 Recall-up is opt-in for high-risk deltas. Extra budget is the existing security-auditor Group 2 trigger — not a named Ultra Gate and not an extra Ralph round by default.

Forbidden in this paste: OCR CLI or npm; replacing Gate 2 / Gate 3 / Layer 2; AACR-Bench as a TAD KPI; Alibaba language rule packs as SSOT.
```

K1 is Layer 2 only; do not paste it into Gate 2 dual-review spawn prompts as a "do not mint findings" replacement. Gate 2 stays two independent reviews on disk.

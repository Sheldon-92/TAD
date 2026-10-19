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

Independent review is **required**. Apply `docs/process-tax-cut.md` §2
(also `patterns/process-tax-cut.md`); retain original findings and severity.
Pathspec/old dirt alone cannot exempt a finding: prove prior existence, no task
introduction/worsening/new exposure, no AC violation, and no unresolved severe
security/delivery risk. Pure out-of-scope severe risk goes to Alex/human as
BLOCKED_RISK. Blake proposes; the independent reviewer responsible for that check
approves against the checked input. Blake self-review never substitutes.

## Finding Dispositions and Input Coverage

- Round: {R1/R2/R3}; input_id: {fixed input}; baseline: {task initial-byte manifest}.
- Group 0 reviewer last_reviewed_input: {input or never}; first execution reviews the
  complete task diff plus handoff §6/§9 and relevant §10. R2/R3 uses the diff from
  this reviewer's own last reviewed input, original findings with full reasons/evidence,
  proposed dispositions and proof, affected sections/ACs/consumers. Old PASS does not
  prove the current input. Even zero delta requires independent confirmation.
- Read-only consumer checks: {origin → proven edge → path+digest → check → result/proof/unproven}.
  No chain grants free exploration; read permission grants no out-of-scope write.

| ID | Origin reviewer / round | Original text / path+hunk or command / severity | Baseline evidence / task causality | Proposed disposition / reason+proof | Independent checker / checked input / evidence | Decision | Final disposition | Reopen link |
|----|-------------------------|------------------------------------------------|------------------------------------|-------------------------------------|------------------------------------------------|----------|-------------------|-------------|
| {stable ID} | {source report} | {original finding unchanged} | {introduced / worsened / newly exposed / unrelated / unproven} | {proposal, separate from approval} | {responsible independent reviewer} | open / approved | null / fixed / pre-existing / dismissed | {new evidence or none} |

- `fixed` requires verified repair and relevant AC/raw check evidence; `pre-existing`
  requires every exemption condition above; `dismissed` requires locatable counterevidence.
  Unreviewed proposals, missing evidence, or dispute stay open/final=null. Reuse stable IDs;
  retain immutable original reports and severity. Equivalent fresh independent replacements
  must preserve duty, scope and expertise and receive the original objective evidence.
- Raw counts by original severity: {counts}; effective open blocking counts/IDs: {counts/IDs};
  independently closed IDs and evidence: {references}. Threshold values remain unchanged.
- The Task Completion Matrix and every AC remain authoritative independently of labels:
  an AC_FAIL / NOT_SATISFIED never becomes SATISFIED through a disposition. At the round
  limit, open blockers/terminal missing applicable coverage require return to Alex.

## Optional Layer 2 review habits (OCR thin borrow)

SSOT: docs/process-tax-cut.md §4; if drift, docs win.

### Optional Layer 2 review habits (OCR thin borrow, copy)

```
Status: optional paste. Not a Gate. Not a substitute for Gate 2 dual disk reviews or Alex ≠ Blake.

- K1 Asymmetric-bound, falsify-only second pass is optional for the same unchanged delta/report (diff + claimed findings only). Veto only when the diff directly contradicts the claim. Do not mint new findings on this optional pass. Parse/format failure → fail-open (keep the finding). It does not advance coverage, consume a new round, or replace independent disposition approval. R2/R3 repair review is different: it must check fixes and may report new regressions at their actual severity; K1 does not suppress those findings.
- K2 Precision over recall as Layer 2 default. Prefer fewer P0/P1 with replayable evidence (path + command/hunk). Comment volume is not quality. Do not lower recall on security-auditor when that Group 2 trigger fired (see K5).
- K3 Dispatch starts at handoff §7 / task delta and §10. Follow only proven dependency edges (actual reference, configuration consumer, or call relation) for directed read-only checks, including newly identified consumers. Record origin → edge evidence → consumer path + content digest → check → result/proof/unproven. No proven chain means no free repository exploration; no search hit is not safety proof. An unproven dependency affecting AC, security, or necessary coverage stays open; an unrelated unsupported guess is not automatically P0. Read access never grants out-of-scope writes: return necessary changes to Alex. Do not add a rule.json or language-md rule engine.
- K4 Claims must be localizable or labeled unanchored. Every finding cites path + command/hunk, or is labeled unanchored / extra-file. Do not treat model line numbers as SSOT.
- K5 Recall-up is opt-in for high-risk deltas. Extra budget is the existing security-auditor Group 2 trigger — not a named Ultra Gate and not an extra Ralph round by default.

Forbidden in this paste: OCR CLI or npm; replacing Gate 2 / Gate 3 / Layer 2; AACR-Bench as a TAD KPI; Alibaba language rule packs as SSOT.
```

K1 is Layer 2 only; do not paste it into Gate 2 dual-review spawn prompts as a "do not mint findings" replacement. Gate 2 stays two independent reviews on disk.

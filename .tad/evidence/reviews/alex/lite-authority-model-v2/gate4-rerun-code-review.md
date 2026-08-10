# Gate 4 Rerun — Code / Architecture Review

**Date:** 2026-08-10  
**Task:** `FULL-RETIRE-P3B-LITE-AUTHORITY-V2`  
**Implementation commit:** `77479a0a4ada086f65930a2b1502c5713c49aad3`  
**Repair commit:** `c851046dc41b65f89dbe0acfbb51cc198d016c81`  
**Verdict:** **FAIL — P0=0, P1=1, P2=0**

## Scope and checks

- Inspected the repair range, verifier, fixture corpus, acceptance report, handoff reconciliation,
  Completion, and Gate 3 review carriers.
- Replayed AC1–AC12 three times; all three executions exited 0 and produced identical output SHA-256
  `b8c042114d77a2a980b553e3a8a155b78e93204479874a6b79b8c868163ba95f`.
- Independently recomputed 30 lines, 30 unique fixture IDs, 2 positive controls, 9 advertised
  mutation probes, five byte-identical mirrors, and the three byte budgets.
- Confirmed the repair range contains exactly ten evidence/governance paths and no diff in the 14
  live Lite implementation carriers.

## Closed findings

The prior Gate 4 semantic-outcome defect is closed for all seven normalized outcome fields. The
independent 30-case oracle now rejects recomputed-digest changes to consequence outcomes, lifecycle
outcomes, prompt flags, replay outcomes, and malformed JSON. AC10 now reports recorded-window
persistent endpoint equality without claiming continuous monitoring.

## P1 — the advertised strict JSONL schema is not closed

`normalize_fixture_semantics` validates and serializes seven required fields but never rejects unknown
object keys. A valid fixture row can therefore acquire a new authority-relevant field while both the
schema check and independent outcome oracle ignore it.

Independent reproduction:

1. Copy the fixture corpus and verifier to an isolated temporary directory.
2. Add `"technical_approval_prompt":true` to the `tool-failure-no-prompt` row.
3. Recompute the copied fixture SHA and update the copied verifier constant.
4. Run the copied verifier's fixture check.

Observed result: exit 0 and `RESULT: PASS`. The recomputed mutated fixture SHA was
`7976031d902bcc2caf5f9285b7beb9a34092f1b5b2559b3d961965b23220931d`.

The current corpus has three legitimate shapes:

- 27 rows: the seven required base keys only;
- `mandate-happy-release` and `mandate-happy-local`: base keys plus
  `control:"positive"`;
- `final-business-acceptance`: base keys plus
  `decision_class:"final_business_acceptance"`.

Because this corpus is an authority boundary, accepting undeclared keys is fail-open. The result is a
blocking P1 even though all advertised probes pass.

## Required repair

1. Enforce an exact allowed key set per fixture ID, not only types for known fields.
2. Permit `control` only on the two named positive controls and require its exact value.
3. Permit `decision_class` only on `final-business-acceptance` and require its exact value.
4. Put the optional metadata in the independent oracle, or enforce an equally independent exact
   per-ID rule.
5. Add a recomputed-digest unknown-field mutation probe that must fail.
6. Rerun AC1–AC12 three times and obtain fresh independent reviews.

No implementation change was made by this review.

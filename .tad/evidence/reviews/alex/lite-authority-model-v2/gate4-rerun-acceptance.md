# Gate 4 Rerun Acceptance — Lite Authority Model v2

**Date:** 2026-08-10  
**Task:** `FULL-RETIRE-P3B-LITE-AUTHORITY-V2`  
**Baseline:** `77479a0a4ada086f65930a2b1502c5713c49aad3`  
**Repair commit:** `c851046dc41b65f89dbe0acfbb51cc198d016c81`  
**Gate 3:** PASS  
**Gate 4 rerun:** **FAIL — RETURN TO BOUNDED DESIGN + IMPLEMENTATION REPAIR**  
**Open severity:** **P0=0, P1=2, P2=0**

## Executive verdict

The first Gate 4 repair closed the original outcome-oracle P1 and AC10 wording defect. Commit scope,
three deterministic AC replays, mirrors, budgets, stored zero-touch endpoints, and the absence of live
carrier changes all verify correctly. Gate 4 nevertheless cannot accept or archive this revision:

1. the strict JSONL validator still ignores unknown keys, allowing a recomputed-digest authority-field
   mutation to pass; and
2. the repair commit is a second local commit under a mandate revision that explicitly authorized one.

The second P1 is an Alex repair-contract error, not a missing human technical decision. Correcting it
must reduce formalistic authorization by separating human-visible blast radius from agent-owned Git
execution details.

## Independent acceptance checks

| Check | Result | Evidence |
|---|---|---|
| Repair identity | PASS | `HEAD=c851046`; parent is `77479a0`; one repair commit in the range |
| Repair scope | PASS | exactly ten Authority v2 evidence/governance paths |
| Live Lite implementation carrier diff | PASS | 0 paths across the 14 protected carriers |
| Bash syntax | PASS | verifier passes `bash -n` |
| Full AC replay | PASS mechanically | 3/3 exit 0; identical output SHA `b8c042114d77a2a980b553e3a8a155b78e93204479874a6b79b8c868163ba95f` |
| Fixture cardinality | PASS | 30 lines, 30 unique IDs, 30 strict-JSON rows |
| Outcome oracle | PASS for normalized fields | 30/30 expected rows; prior consequence/lifecycle/prompt/replay mutations rejected |
| Closed JSONL object schema | **FAIL — P1** | an added unknown authority key survives recomputed digest and still returns `RESULT: PASS` |
| Mirror parity | PASS | five canonical/Agents pairs byte-identical |
| Byte budgets | PASS | core 52,034/52,200; entry 8,469/9,500; refs 15,873/17,400 |
| Recorded-window endpoint equality | PASS | 4/4 stored pre/post planes equal; no continuous-monitoring claim |
| Accepted mandate compliance | **FAIL — P1** | `77479a0` and `c851046` are two commits under revision 1's one-commit bound |
| External mutation | PASS | no push/tag/publish/sync/live dogfood/registered-target write; lock absent |

## AC disposition

| AC | Gate 4 rerun result | Reason |
|---|---|---|
| AC1–AC6 | PASS | inventory, authority carriers, routing, transaction model, and mirrors remain coherent |
| AC7 | **FAIL — P1** | schema is typed but not closed; unknown keys are ignored by normalization/oracle comparison |
| AC8–AC10 | PASS | budgets, ledger, and precisely worded four-plane endpoint evidence verify |
| AC11 | **FAIL at Gate 4** | fresh code/security reviews each contain one accepted P1 |
| AC12 | **FAIL** | aggregate acceptance cannot pass with an authority-fixture false-PASS and mandate-bound violation |

## Independent reviews

| Review | Verdict | Disposition |
|---|---|---|
| Code / architecture | FAIL — P0=0, P1=1, P2=0 | closed-schema P1 accepted |
| Security / authority | FAIL — P0=0, P1=1, P2=0 | mandate revision/commit-bound P1 accepted |
| Performance / context cost | PASS — P0/P1/P2=0 | accepted |

## Reproduction: unknown-field false PASS

In an isolated temporary copy, Gate 4 added `technical_approval_prompt:true` to
`tool-failure-no-prompt`, recomputed the fixture SHA, updated the copied verifier constant, and ran the
fixture check. The verifier exited 0 with `RESULT: PASS`; the mutated fixture SHA was
`7976031d902bcc2caf5f9285b7beb9a34092f1b5b2559b3d961965b23220931d`.

The validator currently extracts seven known fields but never compares each JSON object's key set.
The corpus legitimately has 27 base rows, two `control:"positive"` rows, and one
`decision_class:"final_business_acceptance"` row. Those are the only allowed shapes.

## Bounded repair contract

### Track A — close the fixture schema

1. Enforce the exact base key set on all 30 rows.
2. Allow `control:"positive"` only on `mandate-happy-release` and `mandate-happy-local`.
3. Allow `decision_class:"final_business_acceptance"` only on
   `final-business-acceptance`.
4. Bind those optional fields in the independent oracle or an equivalent per-ID exact rule.
5. Add a recomputed-digest unknown-key mutation probe; it must fail for semantic/schema reasons.

### Track B — correct authority semantics without fake authorization

1. Retain the two-commit historical deviation as a P1 fact; do not rewrite history.
2. Alex must amend the prospective contract/handoff so `max_blast_radius` describes the exact source
   workspace, paths, consequence classes, and external reach—not local commit cardinality.
3. Gate-directed local repair commits within the already accepted outcome, target/path/consequence,
   and no-external-mutation boundary are agent-owned technical recovery. They do not trigger another
   human prompt.
4. A real outcome, target, consequence class, external reach, or user-visible recovery expansion still
   requires a human-domain contract decision.
5. The next Blake execution must cite the reviewed amended carrier and add a verifier assertion for
   the revised boundary. The user must not be asked to approve a Git command or commit count.

After both tracks, rerun AC1–AC12 three times and obtain fresh code, security, and performance reviews
with P0/P1/P2=0.

## Accountability and knowledge assessment

The prior Gate 4 report explicitly requested a separate repair commit while also saying mandate
revision 1 remained sufficient. Alex owns that contradiction; Blake correctly followed the issued
repair contract.

The unknown-key defect is another instance of the existing closed-world/discriminative-fixture rules
in `ac-verification.md`, so no duplicate knowledge entry is needed. The authority correction is a
clarification of the existing `AI/Human Judgment Domain Awareness` principle and the current Execution
Mandate pattern: humans own understandable outcomes and external blast radius; agents own commands,
commit mechanics, retry, and deterministic recovery. The prospective contract amendment should update
that existing pattern rather than create a parallel rule.

## Archive and release decision

**NOT ARCHIVED. NOT PUSHED.** The active handoff/completion pair remains active. Gate 4 performed no
push, tag, publish, sync, live dogfood, registered-target write, history rewrite, or implementation
carrier mutation.

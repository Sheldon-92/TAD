# Gate 4 Acceptance Report — Lite Authority Model v2

**Date:** 2026-08-10  
**Task:** `FULL-RETIRE-P3B-LITE-AUTHORITY-V2`  
**Baseline:** `cabe28755c581c1bddfdfe1a490471888d9f26df`  
**Implementation commit:** `77479a0a4ada086f65930a2b1502c5713c49aad3`  
**Gate 3:** PASS  
**Gate 4:** **FAIL — RETURN TO BLAKE**

## Executive verdict

The policy direction is correct and the live carriers are internally coherent, but Gate 4 found one
acceptance-grade false-PASS in AC7: the fixture verifier checks the evidence file's identity and
self-declared fields, not the authority outcome required for each input. Two independent reviewers
reproduced the same defect through different mutations. Because a fail-open authority mapping can still
produce `RESULT: PASS`, this revision is not yet a 10/10 closure and must not be archived.

## Prerequisites and independent recomputation

| Check | Result | Evidence |
|---|---|---|
| Completion and Gate 3 carriers | PASS | Completion exists; Gate 3 verdict reports P0/P1/P2=0 |
| Commit identity and baseline | PASS | `77479a0` exists, parent is `cabe287` |
| Commit scope | PASS | exact handoff allowlist: 40 actual, 40 allowed, no missing/extra path |
| Required Evidence Manifest | PASS | 28/28 named filesystem carriers exist and are non-empty |
| Full verifier replay | MECHANICAL PASS, acceptance insufficient | `--all` exits 0, but AC7 oracle gap allows a semantic false-PASS |
| Bash syntax | PASS | `bash -n verify-authority-model-v2.sh` |
| Mirror parity | PASS | five canonical/mirror pairs byte-identical |
| Post-commit reconciliation | PASS | only handoff/report/results plus untracked Completion; no implementation-semantic expansion |
| Push/tag/publish/sync | NOT PERFORMED | local branch evidence and completion/report declarations; no outward action performed by Gate 4 |

Independent quantitative recomputation matched the submitted evidence: 30 unique fixture IDs,
2/2 positive controls, 9/9 advertised probes, 14 registered targets, Lite core 52,034/52,200 bytes,
release entry 8,469/9,500, references 15,873/17,400, and four identical stored pre/post snapshot pairs.
Those counts do not cure AC7's missing semantic discriminator.

## AC disposition

| AC | Gate 4 result | Reason |
|---|---|---|
| AC1 | PASS | 13-path live-surface inventory independently counted |
| AC2 | PASS | mandate schema, accepted-state invariant, exact binding, lifecycle and transaction anchors align |
| AC3 | PASS | closed boundary reasons; obsolete technical approval model absent from operational Lite carriers |
| AC4 | PASS | single handoff owner, versioned CAS, replay/recovery and exact release guards present |
| AC5 | PASS | routing, bounded three-document composition, history/full exclusions and knowledge amendment align |
| AC6 | PASS | five byte-identical mirror pairs |
| AC7 | **FAIL — P1** | fixture/result semantics are self-asserted; digest probes cannot detect a valid-shape fail-open mapping |
| AC8 | PASS | all three byte budgets independently recomputed below their ceilings |
| AC9 | PASS | ledger overdue=0 and both current authority entries present |
| AC10 | PASS with P2 precision repair | stored execution-window endpoints match; `live_mutation_count` wording overclaims what snapshots prove |
| AC11 | PASS for Gate 3 evidence | three Blake review carriers end P0/P1/P2=0; fresh Gate 4 quality review separately fails |
| AC12 | **FAIL via AC7** | files and commit scope are replayable, but the aggregate PASS is not acceptance-grade while AC7 can false-pass |

## Independent quality reviews

| Review | Verdict | Gate 4 disposition |
|---|---|---|
| Code / architecture | FAIL — P0=0, P1=1, P2=0 | blocking AC7 semantic-oracle gap accepted |
| Security / authority | FAIL — reviewer P0=0, P1=2, P2=0 | AC7 P1 accepted; zero-touch proposal retained as P2 evidence precision |
| Performance / context cost | PASS — P0/P1/P2=0 | accepted |
| UX | N/A | no UI or human-interface surface changed |

The fresh architecture audit also found the D1–D10 direction sound: no unnecessary new agent/runtime,
one durable handoff state owner, bounded progressive context, exact least-authority intersections,
compaction/recovery state, observability fields, and explicit disaster/replay handling. The failure is in
test discrimination, not the selected authority architecture.

## Repair contract

Repair the existing handoff; do not create a new design cycle.

1. Add an independent expected-outcome oracle for all 30 fixture IDs. It must bind each ID to the exact
   mandate state, condition, result, prompt flag/reason, and pre-mutation verdict required by the design
   contract.
2. Make the semantic checks operate independently of fixture-file SHA. Keep the SHA as an integrity
   check only. A structurally valid fixture with `unlisted-consequence → ALLOW`, a lifecycle denial
   changed to allow, or a completed action made replayable must fail for semantic reasons even if its
   digest is recomputed.
3. Make the advertised fixture mutation probes call the semantic oracle; retain the existing source,
   index, ignored-file, target, and CAS scratch probes.
4. Tighten AC10 reporting without adding a monitoring subsystem: emit the zero-delta result only after
   all four stored-window comparisons pass, and call it recorded-window persistent endpoint equality.
   Do not claim that a later recapture proves no command ever ran.
5. Rerun AC1–AC12 and obtain fresh independent spec, implementation, and security reviews with
   P0/P1/P2=0. Create a separate exact-path local repair commit and update Completion with its SHA. Do
   not push, tag, publish, sync, or write registered targets.

## Advisory infrastructure finding

`layer2-audit.sh lite-authority-model-v2` returned exit 0 but recognized only
`spec-compliance-reviewer`; it classified the legitimate `implementation-reviewer` and
`security-reviewer` filenames as unknown (`DISTINCT_COUNT=1`). This is a P2 naming-registry gap in the
advisory smoke alarm, not evidence that the two review files are absent. `.tad/hooks/**` is outside this
handoff's write scope, so the repair must not widen scope to fix it; retain it for framework maintenance.

## Knowledge assessment

The AC7 defect is a concrete recurrence of the existing project-knowledge rules “Behavioral-Fixture
Discrimination” and “An Extracted Harness Cannot Prove Its Own Extraction Boundary” in
`ac-verification.md`; no duplicate knowledge entry is added. The current Authority Model v2 architecture
lesson is already distilled in `gate-design.md`. There is no separate Blake journal carrier to harvest,
and Completion explicitly reports no additional candidate.

## Archive decision

**NOT ARCHIVED.** The handoff/completion pair remains active until the AC7 P1 is repaired and Gate 4 is
rerun. No human approval question is needed during the repair; the existing accepted mandate remains the
authority carrier for the scoped technical work.

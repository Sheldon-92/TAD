# Gate 4 Independent Code / Architecture Review — Lite Authority Model v2

**Date:** 2026-08-10  
**Task:** `FULL-RETIRE-P3B-LITE-AUTHORITY-V2`  
**Revision:** `77479a0a4ada086f65930a2b1502c5713c49aad3` plus the declared post-commit reconciliation carriers  
**Harness self-report:** Codex / GPT-5.6-Sol / independent read-only Gate 4 review  
**Verdict:** **FAIL — P0=0, P1=1, P2=0**

## P1 — AC7 has no independent semantic oracle

The handoff requires the verifier to validate all 30 contract fixtures, including cross-field
invariants, exact bindings, replay/CAS behavior, lifecycle cases, and the closed prompt enum
(`HANDOFF-20260810-lite-authority-model-v2.md`, lines 529–546). The implementation does not validate
the condition-to-outcome mapping:

- `fixture_file_valid()` checks only the fixture file's pinned SHA, line count, and unique-ID count
  (`verify-authority-model-v2.sh`, lines 115–120).
- `check_fixtures()` checks only self-declared prompt fields and `mutation_before_verdict`; it does not
  compare `condition`, `mandate_state`, or `expected_result` with an independent expected matrix
  (`verify-authority-model-v2.sh`, lines 224–235).
- The first three advertised mutation probes alter fixture bytes and then call the same digest check
  (`verify-authority-model-v2.sh`, lines 150–159). They prove digest sensitivity, not authority
  semantics.

Reproduction in a disposable copy: change the `unlisted-consequence` fixture's expected result from
`BOUNDARY_CHANGE before mutation` to `ALLOW transaction`, update the pinned fixture digest, and run
`--check fixtures`. The check still reports `RESULT: PASS`.

Impact: a forbidden authority outcome can be changed together with the executor-controlled digest and
still satisfy AC7. The evidence therefore cannot distinguish the intended fail-closed matrix from a
fail-open one.

Required repair: add an independent, table-driven oracle for every fixture ID and its required state,
condition/result, prompt classification, reason, and pre-mutation property. Semantic mutation probes
must exercise that oracle and fail even when the mutated fixture is otherwise structurally valid; a
file digest may remain an integrity check but cannot serve as the behavioral oracle.

## Checks that passed

The reviewer independently replayed `verify-authority-model-v2.sh --all` and confirmed that the current
carriers report PASS. The authority intersection, accepted-state invariants, exact target bindings,
CAS/replay/crash rules, closed prompt reasons, release ref/MWS/no-force guards, role separation,
canonical/mirror parity, and commit scope were also inspected. No additional P0/P1/P2 was found.

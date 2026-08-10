# Gate 4 Independent Security / Authority Review — Lite Authority Model v2

**Date:** 2026-08-10  
**Task:** `FULL-RETIRE-P3B-LITE-AUTHORITY-V2`  
**Revision:** `77479a0a4ada086f65930a2b1502c5713c49aad3` plus the declared post-commit reconciliation carriers  
**Harness self-report:** Codex / GPT-5.6 / independent read-only Gate 4 security-authority review  
**Reviewer verdict:** **FAIL — P0=0, P1=2, P2=0**

## Proposed P1-1 — AC7 cannot detect a fail-open authority regression

Accepted by the Gate 4 primary reviewer as a blocking P1. `fixture_file_valid()` validates identity and
shape only, and the advertised binding/replay probes fail solely because the altered file no longer
matches the pinned SHA. `check_fixtures()` trusts each row's own `expected_result` and never executes an
independent condition-to-verdict mapping.

The reviewer reproduced the hole in an isolated copy by replacing Blake-Lite's required invalid-carrier
denial with a mutation-allowing statement while preserving the verifier's searched lifecycle tokens;
`--check lite-core` still passed. This is consistent with the code reviewer's independent fixture-level
reproduction.

Required repair: use an independent semantic oracle and table-driven tests for malformed,
out-of-scope, unknown, and replay cases. Assert `DENY`, `BLOCK`, or `BOUNDARY_CHANGE` before a
mutation-capable stub/marker can be reached. Do not treat a fixture digest as behavioral evidence.

## Proposed P1-2 — zero-touch is stored-window evidence, not a current-state recapture

The reviewer observed that `check_zero_touch()` compares committed pre/post artifacts but does not read
the current source worktree or registered targets. It then emits `live_mutation_count=0` unconditionally
after the loop (`verify-authority-model-v2.sh`, lines 255–272).

The Gate 4 primary reviewer retains the technical observation but reclassifies it as **P2 evidence
precision**, not a second blocking P1:

- AC10 defines a bounded implementation window and asks whether the frozen pre/post endpoints match.
  Re-reading targets later answers a different question and may conflate unrelated post-window drift
  with this task.
- A current recapture also cannot prove that no operation occurred and was reverted; it only proves a
  current endpoint.
- The four stored plane comparisons do contribute to the verifier's global failure count, so a stored
  pre/post mismatch does make the overall check fail even though the final status line is misleading.

Required non-blocking repair: emit `recorded_window_persistent_delta_count=0` only when all four local
comparisons pass, and make the acceptance report describe endpoint equality rather than real-time
monitoring or proof that no command ever ran. A future live dogfood phase may add separately scoped
current-state checks when they answer a real business question.

## Other security checks

The exact origin/root/ref/MWS bindings, physical self-target rejection, no-force ref rules,
delegated-worker limits, unknown/partial recovery rules, and credential boundary were inspected. No P0
authority escape was found, and no credential-pattern match was found in the implementation commit diff.

# Acceptance Verification Report

Task: `FULL-RETIRE-P3A-RELEASE-OPS`

## Canonical results

AC1: PASS
AC2: PASS
AC3: PASS
AC4: PASS
AC5: PASS
AC6: PASS
AC7: PASS
AC8: PASS
AC9: PASS
AC10: PASS
AC11: PASS

## Evidence totals

Coverage behaviors: 27
Fresh forward cases: 6
Forward rubric dimensions per case: 6
Forward live mutation count: 0
Negative fixture groups: 10
Registered targets captured: 14
Reachable targets: 12
Missing targets: 2
Independent implementation review P0: 0
Independent implementation review P1: 0
Independent implementation review P2: 0

## Stable-window authority

- Pre-state: `stable5-pre/`
- Post-state: `stable5-post/`
- Source status/refs/remote refs/registry/deprecation/carrier hashes: equal.
- Four derive interfaces stdout/stderr/exit and parsed TOP_DENY: equal; exits all `0`.
- Every registered target's reachability, git status/refs, expanded path classes, and managed manifest: equal to its own pre-state.
- Fresh sessions ran with `codex exec --ephemeral --sandbox read-only` between these captures.

## Safety result

No live push, tag, publish, sync, source-registry mutation, registered-target write, downstream commit, or downstream push was executed.

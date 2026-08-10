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

These results were replayed after the Gate 4 return repair on 2026-08-10. The repair moves the
source identity guard ahead of every operation route/read and rejects literal or symlink-resolved
self targets before any approval claim or state/write action.

## Evidence totals

Coverage behaviors: 27
Fresh forward cases: 6
Forward rubric dimensions per case: 6
Forward live mutation count: 0
Negative fixture groups: 10
Wrong-origin read-only operation cases: 4
Literal self-target operation cases: 2
Symlink self-target operation cases: 2
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
- The Gate 4 repair did not regenerate forward sessions: AC8 replays the persisted six-case evidence,
  while AC6 preserves `stable5-pre/` and `stable5-post/` as the sealed zero-mutation authority.

## Gate 4 return repair evidence

- `behavior-fixtures.sh` extracts and executes the source guard published in `SKILL.md`.
- Wrong-origin read-only fixtures cover `publish`, `sync`, `sync-add`, and `sync-list`; all stop before
  reference loading or registry access.
- `behavior-fixtures.sh` extracts and executes the target identity guard published in `sync-ops.md`.
- Literal and symlink-resolved self targets are rejected for both `sync` and `sync-add` before an
  approval claim; a distinct physical target is the positive control.
- `negative-results.txt` records the three explicit repair markers and `NEGATIVE FIXTURES PASS 10/10`.
- Canonical and generated release-runbook mirrors are byte-identical.
- Fresh independent spec and implementation reviews report `P0=0`, `P1=0`, `P2=0`.

## Safety result

No live push, tag, publish, sync, source-registry mutation, registered-target write, downstream commit, or downstream push was executed.

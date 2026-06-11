# Sync Safety Analysis — T1 Local Skills vs Release Structural Gate

**Date**: 2026-06-10
**FR**: FR6 (analysis) + FR7 (fix)

## Finding

`release-verify.sh` structural mode (L163) runs `diff -rq` on `.claude/skills` source-vs-target. The `diff -rq` reports **both** "Only in source" (missing in target — real omission) and "Only in target" (extra in target — local skill). Before FR7, both were counted as `fails`, meaning a project with a T1 local skill would cause the structural gate to FAIL on minor+ releases.

- **tad.sh copy** (`cp -R` per-dir, no target-side `rm`): safe — it never deletes extras. A local skill survives sync.
- **release-verify.sh structural**: the gate COUNTED the extras as failures — the allow-list disease on the verify side.
- **Current gate mode**: `TAD_RELEASE_GATE=warn` (shadow cutover, not yet hard-blocking).

## Fix (FR7)

Amended `release-verify.sh` L162-180: for `.claude/skills`, lines matching `^Only in {target}` are now:
- Reported as `ℹ️ local-skill:` INFO lines
- NOT counted toward `fails`
- Missing-in-target and differing files still fail as before

## Verification

- Expert review (config-manager, Gate 2): confirmed the risk at L163 and the fix approach.
- AC15: `grep -cE 'Only in.*local-skill|local-skill.*Only in' release-verify.sh` ≥ 1
- AC15b: fixture test (temp target with extra skill dir → structural run → exit 0 + INFO line)

## Citations

- config-manager Gate 2 finding CM-P0 (2026-06-10)
- release-verify.sh L162-180 (amended)
- NEXT.md follow-up (a): `TAD_RELEASE_GATE=warn` — gate not yet hard-blocking

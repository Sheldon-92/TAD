# Gate 4 Security and Release-Safety Review

**Date**: 2026-08-10  
**Commit**: `f8907a3`  
**Reviewer provenance**: `harness=codex | model=gpt-5.6-sol | route=native`  
**Mode**: independent read-only review

## Verdict

**FAIL — P0=0, P1=1, P2=0**

## P1 — Self-sync target is not rejected

Target validation requires an absolute/canonical readable TAD installation, but never requires the
resolved target to differ from `repo_root`. A registry entry or `sync-add` request pointing to the TAD
source root therefore satisfies the documented target checks and can reach copy/migration with the same
path as both `--source` and `--target`.

This is a wrong-target route. It must be rejected before approval/mandate consumption, Managed Write
Surface copying, migration, registry advancement, downstream commit, or push.

### Evidence

- Target validation: `.claude/skills/release-runbook/references/sync-ops.md` §2
- Migration command: `.claude/skills/release-runbook/references/sync-ops.md` §5
- `sync-add` validation: `.claude/skills/release-runbook/references/sync-ops.md` §8

## Required Repair

Resolve every candidate target with `pwd -P` and reject/skip when `target_physical == repo_root`.
Add both sync and sync-add fixtures for the literal source-root path and a symlink resolving to it.

## Preserved Safety Result

The Phase 3a zero-live-mutation claim remains valid: stable-window evidence shows no live push, tag,
publish, sync, registry write, target write, downstream commit, or downstream push. The accepted
Authority Model v2 remains correctly scheduled for Phase 3b and is not a blocker for this build-only
repair.

# Gate 4 Code-Quality Review

**Date**: 2026-08-10  
**Commit**: `f8907a3`  
**Reviewer provenance**: `harness=codex | model=gpt-5.6-sol | route=native`  
**Mode**: independent read-only review

## Verdict

**FAIL — P0=0, P1=1, P2=0**

## P1 — Source guard invocation was narrowed below the handoff contract

The handoff requires the physical-root/exact-origin guard before any release/sync command rendering,
and the source full sync carrier refuses before any sync step. The committed entry instead says:

> Before rendering any publish/sync mutation command

That wording permits `sync-list`, registry reads, and read-only sync planning to begin before source
identity is established. The same entry later says a sync-only task still runs the guard, so the product
is internally inconsistent about ordering.

The REL-01 fixture proves that the shell predicate accepts/rejects origins correctly, but does not prove
that routing invokes it before registry access or read-only planning. A downstream/fork invocation can
therefore reach sync behavior that the source carrier explicitly required to refuse.

### Evidence

- Handoff source-root order: `.tad/active/handoffs/HANDOFF-20260809-release-runbook-capability-migration.md` §4.5 / REL-01
- Source carrier: `.claude/skills/alex/references/sync-protocol.md` prerequisite guard
- Product narrowing: `.claude/skills/release-runbook/SKILL.md` §Source identity guard
- Premature registry path: `.claude/skills/release-runbook/references/sync-ops.md` §1
- Fixture gap: `.tad/evidence/acceptance-tests/release-runbook-capability-migration/behavior-fixtures.sh` `fixture_root_guard`

## Required Repair

Require the guard before routing or reading any `publish`, `sync`, `sync-add`, or `sync-list` operation.
Add a behavioral fixture proving a noncanonical-origin read-only `sync-list`/planning request is rejected
before registry access. Regenerate the `.agents` mirror and rerun the complete AC suite.

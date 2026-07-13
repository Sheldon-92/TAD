# EPHEMERAL Epic: session-health-check (Surplus)

> Ephemeral single-phase Epic created by Surplus Burn Mode. HUMAN-AUTHORIZED 2026-07-05/06
> (previously approved batch, killed by monthly spend limit mid-run; relaunched after recovery).

- **Epic ID**: EPHEMERAL-surplus-session-health-check
- **Source**: next backlog — IDEA-20260403
- **Status**: Active (single phase)
- **Date**: 2026-07-06

## Goal

Ship `session-health.sh`: a fast, read-only diagnostic script that verifies core TAD framework
components are correctly wired, replacing manual multi-file inspection after every sync/release.

## Single Phase

| Phase | Name | Deliverable | Gate |
|-------|------|-------------|------|
| 1 | session-health | `.tad/hooks/lib/session-health.sh` — SKILL.md presence (both platforms), hook wiring in settings.json, version consistency, pack registry coherence; exit 0 / annotated FAIL report | Gate 3 (self-verify via AC run) |

## Scope

- IN: new read-only bash script + its 4 check categories; annotated PASS/FAIL output; exit codes.
- OUT: auto-repair of drift, sync/publish logic changes, hook registration changes, CI integration.

## Value Rationale

Fast diagnosis of framework drift that currently requires manual inspection across many files;
reusable after every sync.

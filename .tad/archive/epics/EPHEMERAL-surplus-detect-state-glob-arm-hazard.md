# EPHEMERAL Epic: detect-state-glob-arm-hazard

> Ephemeral surplus Epic — single phase, auto-executed, archive on completion.

## Goal

Eliminate the tad.sh `detect_state` version-glob misclassification hazard (2.1*/2.2* arms matching 3-part versions like 2.19.x as v2.0-era) and lock the behavior with a regression fixture so future version bumps cannot silently reintroduce it.

## Current Ground Truth (2026-07-05)

`detect_state` (tad.sh ~L1343-1372) was already refactored to `_tad_ver_cmp` 3-part numeric comparison + major-version routing; the 2.1*/2.2* glob arms from the original surplus report no longer exist. What is MISSING is the regression fixture proving 2.20.0 / 2.33.0 are classified correctly — without it, a future edit can regress unnoticed.

## Phases

| Phase | Name | Status |
|-------|------|--------|
| 1 | verify-and-fixture | Active |

## Phase 1 Scope

- Verify no order-sensitive 2.x glob arms remain in `detect_state` (and fix any found).
- Add a regression fixture script exercising `detect_state` against key version.txt values (2.19.1, 2.20.0, 2.33.0, newer-than-target, unparseable).
- Run fixture; record evidence.

## Out of Scope

- v1.x arms (1.8*/1.6*/1.5*/1.4*) — legacy migration routing, no live hazard.
- Any other tad.sh installer logic.

## Handoff

`.tad/active/handoffs/HANDOFF-surplus-detect-state-glob-arm-hazard.md`

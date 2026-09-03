# Capability Builder — Evolve Protocol (Phase 2)

This reference is **mandatory** when `$capability-builder evolve` is selected. Read via the non-circular load in `SKILL.md`.

## 1. Entry Conditions

`evolve` starts from one trigger (signal-driven, never scheduled):

- real failure (fixture FAIL on a previously PASSing Skill);
- human correction (explicit fix request with evidence);
- behavioral regression (CONTROL/WITH inversion or threshold miss);
- relevant external change (dependency/tool contract change with proof);
- explicit new requirement (human-elevated Gate-4 P2 or equivalent).

Else exit without modifying the Skill → `NO_TRIGGER_NO_WRITES`.

## 2. State Machine

```
TRIGGERED
  │ capture failure fixture first (new regression fixture is part of the change)
  ▼
FAILURE_CAPTURED
  │ smallest Skill/runner edit only
  ▼
EDITED_MINIMAL
  │ rerun old fixtures (no regression)
  ├── regression ──► REGRESSION_BLOCKS_PROJECTION
  ▼
OLD_RERUN
  │ new fixture passes
  ▼
NEW_PASSES
  │ capability-skill.sh validate
  ▼
PROJECTED
  │ capability-skill.sh project + verify byte identity
  ├── divergent target ──► DRIFT_REFUSES_OVERWRITE
  ├── canonical drifted mid-run ──► TARGET_DRIFT_STOP
  ▼
GATE_3_READY ──► Gate 3 → human Gate 4
```

Named stops/blocks: `NO_TRIGGER_NO_WRITES`, `REGRESSION_BLOCKS_PROJECTION`, `DRIFT_REFUSES_OVERWRITE`, `TARGET_DRIFT_STOP`.

## 3. Fixture-First Rule

1. Write the failing fixture BEFORE any Skill edit (frontmatter `skill:`, `discriminative_pattern`, `min_discriminative`, `## Verification Command` with `grep -oE | sort -u | wc -l`).
2. Prove old runner/fixture state (CONTROL FAIL or bound SKIP as applicable; `SKIP` never proves `PASS`/`FAIL`).
3. Make the smallest edit that flips the new fixture to `PASS` while old fixtures stay green.
4. Rerun old + new (see `pack-eval-runner.sh` bounds: size caps, pattern caps, wall-clock guard; advisory exit-0, verdict text is authority).

## 4. Blake Materialization Order (sandbox)

1. Sandbox ONLY: `<FIXTURE_PROJ>` (`.tad/evidence/acceptance-tests/capability-builder-evolve/fixture-proj/`). Never framework `.agents/skills/`.
2. `bash .tad/scripts/capability-skill.sh validate <root> <skill>` — must exit 0.
3. Behavioral proof — same prompt, fresh outputs; `SKIP` never satisfies `FAIL`/`PASS`.
4. `bash .tad/scripts/capability-skill.sh project <root> <skill>` — only after 2+3 pass; divergent → exit 3, alter neither tree.
5. `bash .tad/scripts/capability-skill.sh verify <root> <skill>` + `diff -rq` — must pass.
6. Evidence under `.tad/evidence/acceptance-tests/capability-builder-evolve/` (raw outputs, manifests, digests; `LC_ALL=C`, `grep -F -e`, no `for x in $VAR`).

## 5. Eval Fixture Contract (reuse Phase-1, plus bounds)

- `skill:`-only valid; dual-field `SKIP`; missing Verification Command `SKIP`; `SKIP` never proves `PASS`/`FAIL`.
- New bound verdicts (frozen, `grep -F -e`): `OVERSIZE → SKIP (bounded)` (fixture >512 KiB or output >1 MiB), `TIMEOUT → SKIP (bounded)` (wall-clock trip), `SKIP (bad fixture: pattern oversize)` (either pattern >4 KiB). Advisory exit-0 preserved.

## 6. Out-of-Scope

Retirement/conversion of packs, Plugin/marketplace mutation (see package protocol), DSH, multi-Skill bundles, catalog/registry, scheduled refresh, TAD core/Gate/role/hook/installer edits.

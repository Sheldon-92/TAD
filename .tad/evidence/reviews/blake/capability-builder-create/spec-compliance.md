# Blake Spec Compliance — Capability Builder Phase 1 Create

**Reviewer:** spec-compliance-reviewer (independent subagent)
**Date:** 2026-08-31
**Handoff:** `.tad/active/handoffs/HANDOFF-20260831-capability-builder-phase1-create.md`
**Design:** `.tad/active/designs/DESIGN-20260831-capability-builder-phase1-create.md`
**Verdict:** PASS

## AC-by-AC Verification (literal commands)

| AC | Expected | Actual | Status |
|---|---|---|---|
| AC1 | `bash -n` all three scripts exit 0 | `capability-skill.sh:0`, `pack-eval-runner.sh:0`, `run-acceptance.sh:0` | PASS |
| AC2 | `run-acceptance.sh projection` → PASS projection | PASS projection, verify + diff -rq byte-identical | PASS |
| AC3 | `run-acceptance.sh structural` → all cases PASS, no mutation, no temp/lock | 54 cases PASS (incl. block >/\| (2), foreign temp, copy/diff wrapper parent-cleanup (2), diff wrapper rollback, cp wrapper concurrency, no-eval) | PASS |
| AC4 | `run-acceptance.sh eval-compat` → legacy byte-identical, skill/fallback valid, dual/missing/invalid regex/dash SKIP | legacy PASS preserved, skill FAIL/PASS, fallback PASS, dual SKIP, novc SKIP, invalid regex SKIP, leading-dash PASS (7/7) | PASS |
| AC5 | `run-acceptance.sh behavior` → hashes reconcile, FAIL then PASS, neither SKIP | prompt/skill/fixture/control/with hashes reconciled, FAIL → PASS, neither SKIP, provenance present | PASS |
| AC6 | `run-acceptance.sh routing` → builder routes create, legacy stop, baseline SHA equal, no old scaffold | builder trigger + mandatory load + future stops, upgrade routes + LEGACY_PACK_OUT_OF_SCOPE, baseline 69026199 == ref, obsolete scaffold absent | PASS |
| AC7 | `diff -rq` both mirrors exit 0 | builder parity PASS, upgrade parity PASS (including references) | PASS |
| AC8 | Obsolete scaffold absent in fixture output | `CAPABILITY.md`, `README.md`, `CHANGELOG.md`, `install.sh` absent | PASS |
| AC9 | `run-acceptance.sh claude-routing` → single row diff, contains builder+upgrade | exactly 2 diff lines (1 row), new row has capability-builder + capability-upgrade, old row absent | PASS |
| AC10 | `run-acceptance.sh scope` → bounded commit, protected identical, no unstaged protected edit, no temp/lock | bounded (2 files `2d7e359b`, pinned via `scope/implementation-commit.txt` honest marker, base `c0176f18` 31-file), protected 434 identical | PASS |
| AC11 | `rg` anchor `local-skill:.*target-only` + `platform-skills PASS` present | lines 1006,1018 present | PASS |
| AC12 | `rg` anchor `is_pack_skill()` + `pack-registry.yaml` present | lines 359,248 etc present | PASS |

## Handoff Checklist Compliance

- Circular trigger: builder body has `capability-builder create` trigger and explicit `load references/create-protocol.md` — not circular.
- Behavioral discrimination: discriminative markers are named rules/thresholds/output shapes (`EXAMPLE_RULE_ALPHA`, `EXAMPLE_THRESHOLD_42`, `EXAMPLE_EXIT_99`), not generic vocabulary; structural marker present; control 0/3 FAIL, with 3/3 PASS.
- Literal commands: all §9.1 commands executed literally, not simulated.
- Minimal viable cross-cutting: touched Builder producer + eval consumer only; no installer/catalog/core widen.
- Parallel-work attribution: used explicit task paths for staging (`git add -f` list), never `git add -A`; verified no yolo2 riders staged.

## Exclusions

- No Evolve/Plugin/Voice Studio/retirement/DSH work.
- No TAD core change (tad.sh, hooks, release-verify remain byte-identical per manifest).
- No marketplace/config writes.

All spec requirements satisfied.

# thin-tad-pilot — offline experiment-package tool (P1)

Offline, dependency-free (Node standard library only) verifier and rehearsal
pipeline for the TAD reliable-delivery-cost experiment, Phase 1.

- No models are started here. No network. No real external systems.
- Everything this tool scores is synthetic. Nothing it prints proves a model
  result, an arm-loading fidelity, or an OS-isolation claim — those are
  explicitly recorded as NOT verified (see `readiness.md` in the private
  evidence dir, never published).

## Run

Documented cwd convention is the repo root, but the script resolves all roots
from its own location and behaves identically from any cwd:

```sh
node --check experiments/thin-tad-pilot/pilot.mjs
node --test experiments/thin-tad-pilot/pilot.test.mjs
node experiments/thin-tad-pilot/pilot.mjs <command>
```

| Command | What it proves |
|---|---|
| `verify-sources` | 6 frozen source identities (path/mode/SHA256) still match; symlinks never followed; full text never printed |
| `verify-package` | 12 cases, 6 families × H/V, inputs present, schema/manifest consistent |
| `verify-arms` | Baseline files recomputed live at the fixed revision; candidate frozen; closure independently approved; loading fidelity explicitly unverified |
| `verify-export` | Exported paths match the allowlist; no oracle/answer leak; OS isolation explicitly NOT claimed |
| `verify-controls` | Correct deliveries accepted (evidence stays UNSCORED+rubic), error deliveries rejected with a critical; the scorer reads the approved oracle only |
| `dry-run` | 12×2 arms×2 replicates through the offline pipeline, H/V split, stable across two passes |
| `verify-accounting` | Hand-computed cost/pairing sample matches; missing costs stay partial, never zero-filled; zero success yields null |
| `verify-scope` | Staged files ⊆ tool allowlist; no private path staged/tracked; untracked files attributed |

Exit codes: `0` pass · `1` assertion failure (fail-closed; empty sets never
pass) · `2` missing file, illegal argument, or corrupt schema. Every command
prints one structured JSON document.

## Layout

- `pilot.mjs` — the tool (stdlib only; sole subprocess is a gated read-only
  `git show`/`ls-tree` at the fixed revision for baseline recompute).
- `pilot.test.mjs` — unit + negative-control tests. Negatives run on temp
  copies (`PILOT_PRIVATE_ROOT`) or temp source roots (`PILOT_SOURCE_ROOT`);
  the frozen bundle is never mutated by tests. These overrides are
  test-isolation hooks; a P2 harness must not expose them.
- `testdata/` — independent pure-synthetic scorer samples (values disjoint
  from the frozen bundle).
- The task bundle itself (cases, oracles, controls, arms, manifests,
  rehearsal records) lives under
  `.tad/evidence/experiments/thin-tad-pilot/` and is NEVER committed.

## Builder notes (how the private bundle was produced)

1. Executor packs were generated from case inputs plus per-family task cards
   (objective, allowed-known info, deliverable shapes, authorization,
   boundaries — no answers) and pinned in `exports/manifest.json`.
2. V (holdout) cases were authored in a fresh session that received only the
   family capability blurbs, the deliverable-shape spec, and safety
   boundaries — no H files, scores, controls, oracles, or candidate text.
3. Oracles were re-derived by a second fresh session from executor packs
   only, then adjudicated line-by-line against author wording (wording-only
   differences approved; keys match exactly) and frozen with hashes.
4. `scope.json` snapshots were captured with external `git` commands by the
   builder (the tool itself may only use its gated `show`/`ls-tree`
   interface); `verify-scope` checks the recorded snapshot. Re-capture
   before each gate run so the report stays fresh.

## Cost units

All amounts in rehearsal records are synthetic credits for pipeline testing.
Real model/harness prices are null until P2 fixes an authorized model,
harness, budget, and sampling plan. Human time is listed separately and is
never converted to money here.

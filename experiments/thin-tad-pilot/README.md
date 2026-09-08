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

## P2 runner (Phase 2, TASK-20260908-thin-tad-evaluation-p2) + Harness Alignment (TASK-20260908-thin-tad-harness-adapter)

Paired-evaluation driver for the single authorized model
`opencode-go/muse-spark-1.3-contributor` on the single subject harness
`OpenCode/oc-run`, wired exclusively through the in-repo adapter
`experiments/thin-tad-pilot/oc-adapter.sh` (override path via
`TAD_OPENCODE_BIN`, default `experiments/thin-tad-pilot/oc-adapter.sh`;
the adapter reaches the real binary via `TAD_OPENCODE_RAW_BIN`, default
`/home/box/.opencode/bin/opencode` then system `opencode`).
Locks: single model, single harness, timeout 300s. Requested decode
`temperature 0` / `seed 42` are Leg-1 capture only — the real CLI has no
such flags, so all runs proceed under engine-default sampling (adapter
absorbs the requested values with an honest stderr NOTE, never forwards
them; see `harness-contract-audit.md` §3; never cite these as locked
determinism).
24 planned runs
(12 cases x baseline/candidate, interleaved per case); at most 2 infra
retries total; hard ceiling 26 invocations (a 27th attempt throws
`BUDGET_EXCEEDED`); raw token accounting only; H (6) / V (6) strictly
segregated in `pair-summary.json` (top-level keys exactly
`H_calibration`, `V_holdout`, `metadata`).

Two-leg argv protocol: Runner→Adapter emits
`run --model <id> --dir <workDir> --prompt-file <path> --temperature 0 --seed 42`
so the adapter can transparently capture hyperparameters; Adapter→OpenCode
emits only native parameters
`run --dir <workDir> -m <model> --auto --format default -f <promptFile>`.
External `/home/box/pm/` scripts are never used; no system-wide shim exists.

```sh
node --check experiments/thin-tad-pilot/runner.mjs
node --test experiments/thin-tad-pilot/runner.test.mjs
node experiments/thin-tad-pilot/runner.mjs probe
node experiments/thin-tad-pilot/runner.mjs run-pair --case date-H
node experiments/thin-tad-pilot/runner.mjs run-all
node experiments/thin-tad-pilot/runner.mjs summary
```

- `probe` runs the two-tier start probe (Tier 1 env/symlink hygiene, Tier 2
  negative/positive controls) plus the 13-file baseline fidelity check.
  Any failure prints `adapter_eligible: false` and exits 1 (fail-closed);
  `run-pair`/`run-all` refuse to start until the probe passes.
- `run-pair`/`run-all` create one temp workspace per arm, sanitize the
  environment (only `PATH`/`HOME`/system locale plus `TAD_OPENCODE_BIN`
  and `TAD_OPENCODE_RAW_BIN` survive; `PILOT_*`, key material, and other
  `TAD_*` session state are stripped),
  spawn the in-repo adapter with argv arrays (no shell, detached process group,
  SIGTERM then SIGKILL on timeout, 50MB output cap), assert
  `reported_model_id`, and write `run.json` per arm (missing token fields
  stay `null` with `partial: true`; model-logic failures are never retried;
  infra failures retry at most once per arm / twice total; 3 consecutive
  infra failures open the global fuse).
- Adapter sandbox: `WORK_DIR` must not be a symlink, is normalized via
  `realpath -m`, and must sit inside `TAD_ALLOWED_WORK_ROOT` (default
  `/tmp/`); `PROMPT_FILE` must not be a symlink, must exist/readable, and
  must reside in `WORK_DIR` or the allowed root; violations exit 2 and map
  to `FAILED_HARNESS_USAGE` (no infra-retry budget consumed). Missing raw
  binary exits 127 (`FAILED_INFRA`, probe fail-closed).
- `summary` scores every produced artifact with the P1 engine
  (`scoreArtifact`/`judgeStatus` imported from `pilot.mjs`, never
  reimplemented), counts `FAILED_INFRA` arms without artifacts as
  `unscorable_infra_arms`, and writes the segregated `pair-summary.json`.
- Run evidence lives under `.tad/evidence/experiments/thin-tad-pilot/runs/`
  (gitignored, never committed): `isolation-probe-report.json`,
  `manifest.json`, `pair-summary.json`, `{case}/{arm}/run.json`.

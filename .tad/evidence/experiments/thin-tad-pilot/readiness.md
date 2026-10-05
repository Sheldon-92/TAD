# Readiness — thin-tad-pilot P1 (private)

Status: OFFLINE-PIPELINE READY. This is NOT a model-experiment readiness.

## What P1 completed (with evidence)
- 12 cases (6 families × H/V), inputs present, H/V split enforced by
  `verify-package` (raw: acceptance-tests `raw-verify-package.json`).
- 6 sources frozen with first-read hashes; live recompute passes
  (`raw-verify-sources.json`). 4/6 sources were hash-only (harness refused
  content display); all 6 cases are marked reconstructed with assumptions —
  reconstruction ratio 6/6 original-replay 0/6.
- Baseline (13 files at edce7606…) recomputed blob/mode/content live;
  candidate frozen; applicable closure independently approved with conditions
  (`arms/scope-approval.json`; raw: `raw-verify-arms.json`).
- Executor packs enumerated against the allowlist with leak negatives
  (raw: `raw-verify-export.json`).
- Oracles independently re-derived from executor packs only, adjudicated
  line-by-line (12/12 wording-only, keys match), frozen with hashes
  (`oracles/approved.json` + `oracles/review/`).
- Bidirectional controls: 12 correct accepted (evidence UNSCORED+rubric),
  12 error rejected with criticals (raw: `raw-verify-controls.json`).
- 12×2×2 offline rehearsal stable across two passes, H/V split
  (raw: `raw-dry-run.json`).
- Hand-computed accounting matches; no zero-fill; zero-success→null
  (raw: `raw-verify-accounting.json`).
- Scope/privacy: staged ⊆ tool allowlist; no private path staged or tracked
  (raw: `raw-verify-scope.json`).
- Unit + negative suite 26/26 (raw: `ac1.txt`).

## Explicitly NOT tested (do not claim)
1. Real task-solving ability — no model ever ran; dry-run artifacts are
   synthesized by the builder, not solved.
2. Arm loading fidelity — neither arm was loaded by any harness; the
   candidate is frozen text, not a registered skill.
3. OS/container/harness isolation — exports are same-shell readable; blind
   testing is NOT established.
4. Model behavior, cost, latency, human effort — all null/synthetic.
5. Statistical power — 12 rehearsal instances (6 holdout) support pipeline
   testing only, never win/lose claims.

## P2 entry checklist (all required before any model run)
- [ ] Human fixes model ID/version/params, price + cache accounting, total
      budget, per-run caps, replicate count, sample set, retry rules.
- [ ] Isolation probe passes (executor cannot read answers/source repos).
- [ ] Harness-loading verification passes for the chosen baseline exposure
      (else adapter-ineligible — stop, do not substitute a shrunken baseline).
- [ ] V holdout stays unseen by any rule optimizer; any candidate change
      after V freeze retires all V to seen.
- [ ] H calibration and V holdout reported separately, never merged.

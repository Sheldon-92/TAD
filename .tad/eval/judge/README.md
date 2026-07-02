# Judge Harness Run Protocol

## Per-Trajectory Evaluation

Each trajectory is evaluated by a **fresh Agent spawn** (model: sonnet):
- Prompt: Read `judge-prompt.md` then read `rubric.md` then read the bundle at `bundles/{slug}.md`
- The agent returns a JSON with D1-D5 scores and rationales
- Save the returned JSON to `results/round{N}/{slug}.json`
- Record subagent_tokens and duration_ms from the Agent tool return

## Blind Rules (CRITICAL)

The judge agent MUST NOT be given:
- Any golden-set file path or content
- Any prior round's results
- Any other trajectory's results
- The handoff or completion for the trajectory-eval task itself

## Iteration Protocol

- Round 1 = baseline (no prior)
- If gate metrics fail: diagnose divergences → modify judge-prompt.md wording and/or rubric anchor wording (scores frozen) → Round 2 = full 12-trajectory re-run
- Max 3 rounds total. Round 3 still failing → PIVOT

## EVAL_ERROR Handling

If a judge returns invalid JSON or refuses to evaluate:
1. Re-spawn once (fresh agent)
2. If still failing → create `results/round{N}/{slug}.EVAL_ERROR` marker
3. ≥2 EVAL_ERROR in a round → harness defect, fix and re-run (doesn't consume iteration)
4. GS-11/GS-03/GS-06 EVAL_ERROR after re-spawn → that gate is inconclusive → PIVOT

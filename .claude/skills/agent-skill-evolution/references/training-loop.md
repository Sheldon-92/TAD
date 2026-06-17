# Training Loop (TL1–TL4)

> The six-stage pipeline that turns agent experience into skill improvement.

---

### TL1: Six-Stage Pipeline Contract

Every self-evolution cycle follows this pipeline — skipping a stage breaks the feedback loop:

```
1. Rollout    — run the current skill on training tasks, collect transcripts
2. Reflect    — analyze transcripts for failure patterns and success factors
3. Aggregate  — merge reflections across trajectories into edit candidates
4. Select     — rank candidates by expected impact, pick top-K
5. Update     — apply selected edits to the skill document (bounded edit)
6. Gate       — validate updated skill on held-out set; accept or reject
```

SkillOpt implements this as `trainer.py` (~1,300 lines), with each stage as a named method. The pipeline is a single `for epoch in range(1, num_epochs + 1)` loop with `steps_per_epoch` steps inside each epoch.

**Why all six**: Rollout without Reflect produces data with no signal. Reflect without Aggregate loses cross-trajectory patterns. Update without Gate produces unvalidated drift (−52.8 pts, AD2). Gate without Rollout has nothing to validate.

> Source: SkillOpt paper §3 (ReflACT framework); `trainer.py` lines 780–1026.

---

### TL2: Reflect Modes — Shallow vs Deep

Two reflection modes, used at different training stages:

- **Shallow (per-trajectory)**: Analyze a single rollout transcript — what failed, what worked, what could be worded differently. Fast, produces localized patches. SkillOpt calls this the default reflection prompt.
- **Deep (cross-trajectory systemic)**: After aggregating K rollouts, look for systemic patterns — "3 of 5 failures share the same root cause." Produces structural edits (reorganize sections, add new rules). SkillOpt triggers this when aggregated failure patterns exceed a threshold.

**Practical guidance**: Start with shallow reflection for the first 2-3 epochs (builds the patch vocabulary). Switch to deep reflection when improvement plateaus — shallow patches address symptoms; deep reflection restructures the skill.

The reflect prompt receives: (a) the current skill text, (b) the rollout transcript, (c) the task description, (d) the evaluation outcome (pass/fail + error details). It produces a list of proposed edits with rationale.

> Source: SkillOpt `trainer.py` `_reflect()` method; AIDE harness uses `_cross_trajectory_reflect()` for deep mode.

---

### TL3: Hierarchical Aggregate — Failure Patches Priority

When multiple reflections produce competing edits, prioritize by impact:

1. **Failure patches** (edits addressing failed tasks) get priority — they fix known broken behavior.
2. **Success reinforcement** (edits strengthening successful patterns) come second — they're refinements, not fixes.
3. **Contradictory patches** (two reflections suggest opposite changes to the same rule) get flagged for human review or deeper reflection, not silently applied.

SkillOpt's aggregation is implicit in the `_select_best_edit()` method: it evaluates all candidate edits by running them through the gate, keeping only those that improve the score. Failure-driven edits tend to produce larger score deltas and win selection.

**Anti-pattern**: Averaging all reflections into one "consensus edit." This dilutes strong signals (a clear fix for a failure pattern) with noise (minor wording preferences from successful runs).

> Source: SkillOpt `trainer.py` aggregate + select logic; paper §3.2 (selection by gate score delta).

---

### TL4: Contrastive Reflection — K Rollouts and Spread-Based Selection

For better signal, run each training task K times (K ≥ 3 rollouts). Compare the best and worst rollouts on the same task to isolate what made the difference — this is contrastive reflection.

**Key mechanism**: `spread = max(scores) - min(scores)` across K rollouts. High spread means the skill's behavior is unstable on this task — the skill text is ambiguous or the task hits an edge case. Low spread means the skill consistently succeeds or fails — further optimization here has diminishing returns.

SkillOpt uses spread to prioritize: reflect on high-spread tasks first (most learnable), then on consistently-failing tasks (hardest to fix). Consistently-passing tasks are skipped.

**Cache key**: When caching rollout results, the cache key must include the rollout index (k=0, k=1, k=2), not just the task ID. Without the index, all K rollouts return the same cached result — defeating the purpose. SkillOpt uses SHA-256 of `(skill_content, task_id, rollout_k)` as the cache key.

**Practical minimum**: K = 3 rollouts gives a usable spread signal. K = 5 is more robust but 67% more expensive. K = 1 (no contrastive) still works but loses the spread signal — use when budget is tight.

> Source: SkillOpt `trainer.py` rollout caching logic; paper §4.3 (contrastive reflection design).

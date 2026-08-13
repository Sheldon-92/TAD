# Validation Gate (VG1–VG4)

> The safety mechanism that prevents self-improvement from becoming self-destruction.

---

### VG1: Strictly-Greater-Than Acceptance

The validation gate accepts a candidate skill ONLY if its score is **strictly greater than** the current skill's score. A tie means reject — the edit didn't improve anything, so it's not worth the risk of subtle regressions outside the held-out set.

SkillOpt implementation (`gate.py` line 123):
```python
if cand_score > current_score:      # strictly greater — tie = reject
    if cand_score > best_score:
        return GateResult(action="accept_new_best", ...)
    return GateResult(action="accept", ...)
return GateResult(action="reject", ...)
```

The gate tracks TWO baselines: `current_score` (the active skill) and `best_score` (the best skill seen so far across all steps). `accept_new_best` means the candidate beat the all-time best; `accept` means it beat the current but not the best.

**Why strictly-greater**: In small held-out sets (10-50 items), a tie often means the candidate changed behavior on some items but the errors cancelled out. Strictly-greater forces a net improvement.

> Source: SkillOpt `evaluation/gate.py` lines 76-130; paper §4.1 (gate design).

---

### VG2: Metric Selection — Hard / Soft / Mixed

Three gate metrics, chosen based on the evaluation setup:

| Metric | Formula | When to use |
|--------|---------|-------------|
| `hard` (default) | Exact-match accuracy (0 or 1 per item) | Large held-out set (> 50 items) with binary correctness |
| `soft` | Per-item partial credit (F1 / partial score, 0..1) | Small held-out set (< 30 items) where hard accuracy is insensitive to incremental improvements |
| `mixed` | `(1 - w) × hard + w × soft`, default w = 0.5 | Most stable for small validation sets — combines sensitivity of soft with discrimination of hard |

SkillOpt defaults to `hard` for backward compatibility. For production use with small held-out sets, `mixed` with default weights is recommended — it catches improvements that `hard` misses (partial progress on hard tasks) while still penalizing regressions that `soft` might tolerate (a wrong answer that scores 0.3 soft but 0 hard).

Configuration: `gate_metric: "mixed"` + optional `mixed_weight: 0.5` in the training config.

> Source: SkillOpt `evaluation/gate.py` `select_gate_score()` lines 46-72; added in the multi-metric extension.

---

### VG3: Selection Cache by Content Hash

Validation rollouts are expensive (each runs the full agent pipeline on held-out tasks). SkillOpt caches results by **SHA-256 hash of the skill content**, so identical skills don't re-run validation.

**Cache key**: `hashlib.sha256(skill_content.encode()).hexdigest()`. The cache maps this hash to the aggregated gate score.

**Why content hash, not step number**: The optimizer might produce the same skill text at step 5 and step 12 (e.g., a rejected edit was re-proposed). Content-based caching skips the redundant re-validation. Step-based caching would miss this and waste rollout budget.

**Cache invalidation**: The cache is valid only for a single training run. Between runs, the held-out set may change (items added/removed), so cached scores are stale. SkillOpt stores the cache in-memory per `Trainer` instance, not on disk.

**Interaction with TL4**: When using K > 1 rollouts for contrastive reflection (TL4), the cache key for rollout caching is `(skill_hash, task_id, rollout_k)` — not just `(skill_hash, task_id)`. The gate cache uses only `skill_hash` because the gate runs all held-out tasks together.

> Source: SkillOpt `trainer.py` gate caching logic; `evaluation/gate.py` is a pure function (cache is in the caller).

---

### VG4: Longitudinal 4-Quadrant Comparison

After K training epochs, classify each held-out item into one of four quadrants:

| Quadrant | Before → After | Interpretation |
|----------|---------------|----------------|
| **Improved** | Fail → Pass | The skill evolution fixed this case |
| **Regressed** | Pass → Fail | The skill evolution broke this case — investigate |
| **Persistent Fail** | Fail → Fail | Neither version handles this — may need different approach |
| **Stable Success** | Pass → Pass | Not affected by changes — good, no regression |

**When to use**: At the end of a training run, as a diagnostic. The gate (VG1) makes accept/reject decisions per step; the 4-quadrant analysis shows the cumulative effect across the entire training run.

**Red flag**: If `regressed > 0` at any point, the net score improvement masks individual regressions. The skill got better overall but got worse on specific items. This is where protected regions (ES3) and lapse/defect classification (ES4) help — the regressed items often correspond to behaviors that should have been protected.

> Source: SkillOpt paper §5 (per-item analysis); `docs/sleep/RESULTS.md` (longitudinal tracking across nights).

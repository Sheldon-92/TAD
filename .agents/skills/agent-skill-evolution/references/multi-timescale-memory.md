# Multi-Timescale Memory (MT1–MT3)

> Separating fast, slow, and meta-level skill updates by timescale.

---

### MT1: Three Independent Memory Tiers

Self-evolving agents need memory at three timescales — mixing them causes either thrashing (too-fast updates to stable knowledge) or stagnation (too-slow updates to dynamic patterns):

| Tier | Timescale | What it stores | Update frequency |
|------|-----------|---------------|-----------------|
| **Step buffer** | Per-interaction | Observations, lapse notes, immediate patches | Every step (within one training epoch) |
| **Slow update** | Per-epoch | Aggregated rules, structural skill sections, proven patterns | End of each epoch (after gate validation) |
| **Meta skill** | Cross-run | Training strategy itself — how to reflect, what to prioritize, hyperparameter heuristics | Manually or after multiple successful training runs |

SkillOpt implements the step buffer as in-memory state in the `Trainer` instance. The slow update is the skill file (only modified on gate-accept). The meta skill is stored in `ckpt/meta_skill/` — guidance that tells the optimizer HOW to optimize (e.g., "for MATH tasks, focus on step-by-step reasoning structure; for code tasks, focus on edge case coverage").

**Why three tiers**: Without tier separation, a step-level observation ("this specific task needed a comma-separated list") becomes a permanent rule in the skill. The three tiers provide appropriate retention: step buffer items expire at end-of-step, slow update items persist across steps but are revised across epochs, meta skill items persist across training runs.

> Source: SkillOpt `trainer.py` `_load_meta_skill_content()` line 376; `ckpt/` directory structure; paper §4.4 (multi-timescale design).

---

### MT2: Write Isolation — Step-Level Edits Cannot Modify Epoch-Level Regions

Within a single step, the optimizer can modify the **step buffer** (lapse notes, observations, immediate patches) but NOT the **slow update regions** (aggregated rules, structural sections). Slow update regions are only modified at epoch boundaries, after gate validation.

This prevents a single bad step from corrupting stable knowledge. If a step produces a harmful edit, it only affects the step buffer — which is reviewed and aggregated at epoch end before being considered for slow update.

**Implementation via protected regions (ES3)**: The slow update sections are wrapped in protected-region markers. Within a step, the optimizer prompt includes "do NOT modify PROTECTED regions — these are slow-update sections modified only at epoch boundaries."

**Interaction with ES4**: EXECUTION_LAPSE notes (ES4) go into the step buffer → appendix (MT3). SKILL_DEFECT edits go through the full pipeline and modify slow update regions only at epoch boundaries after gate validation.

> Source: SkillOpt `trainer.py` protected-region enforcement during per-step updates; paper §4.4.

---

### MT3: Appendix Consolidation

Lapse notes (ES4) accumulate in the skill's appendix section. Over time, this appendix grows unbounded — eventually degrading skill quality (a 2,000-token appendix that the model must read on every invocation adds latency and confusion).

**Solution**: Threshold-gated LLM consolidation. When the appendix note count exceeds `consolidate_threshold`, an LLM compacts the notes into a smaller set of generalized rules.

SkillOpt implementation (`trainer.py` lines 123-141):
```python
consolidate_threshold = int(cfg.get("skill_aware_consolidate_threshold", 0) or 0)
if consolidate_threshold > 0 and len(after_notes) > consolidate_threshold:
    compacted = consolidate_appendix_notes(after_notes, ...)
```

**Fail-safe**: If consolidation produces fewer rules than the original notes AND the new rules don't cover all failure cases from the originals, the original notes are preserved (consolidation is rejected). This prevents lossy compression from silently dropping important lapse patterns.

**Practical threshold**: Start with `consolidate_threshold = 15-20` notes. Below that, the appendix is small enough to keep raw. Above that, patterns should be emerging that the LLM can generalize.

Trained skill artifacts in SkillOpt's `ckpt/` directory show skills ranging from 300 to 2,000 tokens — the appendix typically accounts for 10-30% of the total skill length after consolidation.

> Source: SkillOpt `trainer.py` lines 123-141 (`consolidate_appendix_notes`); `ckpt/` trained skill artifacts.

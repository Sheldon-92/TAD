# Offline Consolidation (OC1–OC7)

> The "sleep cycle" — how an agent learns overnight from the day's sessions.

---

### OC1: Six-Stage Sleep Pipeline

The offline consolidation pipeline mirrors biological memory consolidation:

```
1. Harvest   — read the day's session transcripts (read-only, OC2)
2. Mine      — extract recurring task patterns and failure signals
3. Replay    — re-run identified tasks with current skill (+ associative recall, OC4)
4. Consolidate — reflect on replay results, generate edits (training loop, TL1)
5. Stage     — write candidate skill to staging directory (not live, OC6)
6. Adopt     — human reviews + approves staging → promote to live skill
```

SkillOpt-Sleep implements this as `cycle.py` `run_sleep_cycle()`. The cycle runs as a scheduled job (cron, launchd, or CI) overnight. Total runtime depends on training budget: 20-60 minutes for a 50-task training set with 3 epochs.

**Why six stages instead of "just retrain"**: Each stage has its own failure mode and safety boundary. Harvest is read-only (no accidental mutation). Mining is deterministic (no API cost if using heuristic miner). Replay produces fresh data for the gate. Staging prevents untested changes from going live.

> Source: SkillOpt-Sleep `cycle.py` `run_sleep_cycle()`; `docs/sleep/ARCHITECTURE.md`.

---

### OC2: Harvest Is Read-Only

The harvest stage reads session transcripts but **NEVER modifies them**. Transcripts are the ground truth of what happened — mutating them corrupts the training signal.

Implementation: Harvest opens transcript files in read-only mode. It copies relevant excerpts into a working directory for mining. The original transcript files are never written to.

**Anti-pattern**: "Clean up" transcripts during harvest (remove PII, fix formatting). Do this in a separate pre-processing step that produces cleaned copies, not by modifying originals.

> Source: SkillOpt-Sleep `cycle.py` harvest step; `backend.py` transcript reading.

---

### OC3: Heuristic Miner vs LLM Miner

Two approaches to mining task patterns from harvested transcripts:

| Miner | Cost | Accuracy | When to use |
|-------|------|----------|-------------|
| **Heuristic** (deterministic) | Zero API cost | Good for well-structured transcripts (clear task boundaries, explicit success/fail) | Default for cost-sensitive setups |
| **LLM** (AI-powered) | ~$0.01-0.10 per transcript | Better for unstructured conversations (ambiguous boundaries, implicit success signals) | When heuristic recall is < 70% |

SkillOpt-Sleep supports both: `backend.py` defines the `mine_tasks()` interface, with `MockBackend` using heuristic mining and `ClaudeBackend`/`OpenAIBackend` using LLM mining.

The heuristic miner uses keyword matching and structured markers (e.g., `TOOL_CALL:` markers in Claude Code transcripts) to extract task boundaries. The LLM miner prompts a model to identify tasks, their boundaries, and outcomes.

> Source: SkillOpt-Sleep `backend.py` `mine_tasks()` interface; `MockBackend` vs `ClaudeBackend`.

---

### OC4: Experience Replay — Associative Recall via Token Jaccard

Not all past tasks are relevant to tonight's learning. Experience replay uses **associative recall** to surface the K most-similar past tasks alongside tonight's new ones.

Similarity metric: **Token Jaccard overlap** between tonight's task and each past task. Jaccard = |A ∩ B| / |A ∪ B| where A, B are the token sets (lowercased, deduplicated). This is cheap (no embedding model needed) and surprisingly effective for task-level similarity.

Configuration: `recall_k` (default 0 — no recall). Set `recall_k = 10` or `recall_k = 20` to recall the top-K most similar past tasks into tonight's training batch. Higher K means more training data but longer replay time.

**Why Jaccard, not embeddings**: Embedding-based recall is more accurate but requires an embedding model API call per (tonight_task, past_task) pair. For a corpus of 500 past tasks × 20 tonight tasks = 10,000 comparisons — that's $0.01-0.10 in embedding costs per night. Token Jaccard is free and achieves ~80% of the recall quality for task-level matching (not sentence-level, where embeddings dominate).

> Source: SkillOpt-Sleep `dream.py` associative recall logic; config `recall_k`.

---

### OC5: Dream Augmentation — Synthetic Variants for Training Only

Dream augmentation generates **synthetic variants** of tonight's tasks to expand the training signal. The LLM takes each real task and produces `dream_factor` variants with modified parameters, constraints, or edge cases.

Configuration: `dream_factor` (default 0 — no dreaming). Set `dream_factor = 2` to triple the effective training set (1 real + 2 synthetic per task).

**Critical safety rule**: Synthetic (dreamed) tasks go into the **training** set ONLY. They MUST NOT be added to the validation/held-out set. Adding synthetic tasks to validation contaminates the gate — the gate would validate against tasks the optimizer designed for itself (anti-overfit violation).

SkillOpt-Sleep enforces this by keeping dream tasks in a separate `dream_tasks` list that never merges into the validation set. The gate runs exclusively on the original held-out items.

> Source: SkillOpt-Sleep `dream.py` `dream_augment(factor=)`; `config.py` `dream_factor` default.

---

### OC6: "Nothing Live Changes" Contract

During consolidation, the staging directory receives the candidate skill. The live skill is never modified until a human explicitly adopts the staged version.

Implementation contract:
```
1. Back up current live skill to .prev.md (snapshot)
2. Write candidate skill to staging/ directory
3. STOP — nothing live changes
4. Human reviews staging/ diff against .prev.md
5. Human runs `adopt` command → staging → live (atomic move)
```

SkillOpt-Sleep implements this via `skillopt_sleep/cycle.py` — the cycle ends at step 3. The `adopt` step is a separate command the user runs after reviewing.

**Why human-in-the-loop**: Even with a validation gate, a skill can pass the gate and still have subtle regressions on tasks outside the held-out set. The human review catches "yes it passes the test but it sounds wrong" — qualitative judgment the gate cannot provide.

> Source: SkillOpt-Sleep `cycle.py` staging logic; `docs/sleep/ARCHITECTURE.md` (adopt workflow).

---

### OC7: Task Guardrail — Inject Output Contract into Reflect Prompt

When the optimizer reflects on a target agent's rollout, it may not know the target's output format requirements (JSON schema, tool-call format, structured response constraints). Without this context, the optimizer's edits may improve task completion but break the output contract.

**Solution**: Inject the target's output contract into the reflect prompt. SkillOpt does this by including the target's system prompt (or a summary of its output format) in the reflection context.

**Example**: A target agent must produce `{"action": "...", "reasoning": "..."}` JSON. Without the output contract, the optimizer might edit the skill to produce free-form text (which scores 0 on the structured-output gate).

> Source: SkillOpt `trainer.py` reflect prompt construction; paper §4.2 (optimizer-target interface).

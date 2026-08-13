# Context Compaction Rules
<!-- capability: context_compaction -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| CC1 | Compact, don't inflate — attention is O(N²) in sequence length | deterministic |
| CC2 | Select the compaction strategy by horizon and payload — 4 named strategies | deterministic |
| CC3 | Lossy summarization fires at a token threshold (~70%), not "when it feels long" | semi-deterministic |
| CC4 | Route the summarizer subtask to a low-cost model (Haiku-class / gpt-4o-mini-class) | deterministic |
| CC5 | Compaction applies only to self-managed history, not service-managed context | deterministic |
| CC6 | Prefer native server-side context editing/compaction over hand-rolled (see context-editing-memory-tool.md) | deterministic |

---

## Rules

### CC1: Compact, Don't Inflate — Attention is O(N²)

The active context window is the primary bottleneck: transformer attention scales **quadratically (O(N²))** with sequence length N. Expanding the window to hold raw, uncompacted history introduces compounding latency and cost — every step recalculates KV tensors for the entire raw context (the prefill phase regenerates attention key-value tensors; the decode phase generates tokens autoregressively).

> Source: findings.md "Context Window Dynamics and Compaction Mechanics" [10, 11, 12, 13]

**Rule**: When history grows, the answer is compaction (an application-layer resource-allocation strategy that selects, condenses, and prioritizes what enters the window) — NOT a bigger window.

**determinismLevel**: deterministic.

### CC2: Select the Compaction Strategy by Horizon and Payload

Compaction operates on a structured message index that groups raw messages into atomic **message groups**. Four named strategies, each with a distinct trigger and trade-off:

| Strategy | Operational Trigger | Retention Mechanism | Trade-off | Primary Use Case |
|----------|---------------------|---------------------|-----------|------------------|
| **Sliding Window** | Turn/token threshold | Keeps only most recent N turns on logical boundaries | Low, predictable latency; discards older detail | Short-horizon, task-specific sessions |
| **Lossy Summarization** | Token threshold (e.g. 70% capacity) | Recursively summarizes older turns into a single block | Preserves semantic continuity; prone to drift/hallucination | Multi-session conversational agents |
| **Loss-Aware Pruning** | Perplexity / information density | Drops low-information tokens that minimally affect model loss | High fidelity; intensive pre-computation | Code execution; dense document queries |
| **Staged Compaction** | Graduated context pressure | Raw text → tool-output offloading → summaries | Maximizes preservation; complex state tracking | Multi-step workflows with large payloads |

> Source: findings.md "Context Window Dynamics and Compaction Mechanics" — Compaction Strategy table [11, 13, 14, 15, 16]

**Rule**: For long-running sessions, combine **sliding window + staged compaction** (offload large intermediate tool payloads to external storage), falling back to lossy summarization only when necessary.
> Source: findings.md "Architectural Synthesis"

**determinismLevel**: deterministic — strategy choice is architectural.

### CC3: Lossy Summarization Fires at a Token Threshold

Lossy summarization is NOT triggered by vibe. It fires at a defined token threshold (e.g. **70% of capacity**). It runs a recursive compression loop `S_t = Φ(S_{t-1}, M_t)` where `S_t` is the active summary, `M_t` is the new turn block, and `Φ` is the recursive summarizer — preserving semantic continuity while permanently removing redundant tool outputs and intermediate step logs.

> Source: findings.md "Context Window Dynamics and Compaction Mechanics" — incremental lossy summarization [13, 14, 15]

**Rule**: A summarization strategy without an explicit token-percentage trigger is undefined behavior. State the threshold. Note the cost: lossy summarization is prone to context drift and hallucination — it is NOT free.

**determinismLevel**: semi-deterministic — the threshold is fixed; summary content varies.

### CC4: Route the Summarizer Subtask to a Low-Cost Model

When you hand-roll incremental lossy summarization, the summarizing subtask should run on a highly-optimized, **low-cost summarizer model** — a Haiku-class / `gpt-4o-mini`-class model — not the primary reasoning model. (Model names deprecate; the rule is the COST TIER, not a specific SKU. As of 2026, picking a current cheap small model from your provider matters more than the literal name.) The summarizer permanently removes redundant tool outputs and intermediate step logs.

> Source: findings.md "Context Window Dynamics and Compaction Mechanics" [14]

**Rule**: Do not burn the primary model on summarization. Route `Φ` to a current low-cost model. But first ask whether you even need a separate summarizer: native server-side compaction (`compact_20260112`, CC6) summarizes with no separate model call at all.

**determinismLevel**: deterministic.

### CC5: Compaction Applies Only to Self-Managed History

Compaction applies ONLY to agents that manage their own conversation history in memory — NOT to agents relying on **service-managed context**, where the backend platform handles history aggregation automatically.

> Source: findings.md "Context Window Dynamics and Compaction Mechanics" [14]

**Rule**: Before building a compaction layer, confirm the agent actually owns its history. If the platform manages context, a hand-rolled compactor is redundant work.

**determinismLevel**: deterministic.

### CC6: Prefer Native Server-Side Context Editing/Compaction When Available

On Anthropic models you usually should NOT hand-roll the summarization/pruning loop at all. Two native, server-side primitives exist (full detail in `context-editing-memory-tool.md`):

- **Context editing** (`anthropic-beta: context-management-2025-06-27`): `clear_tool_uses_20250919` PRUNES old tool results (default trigger **100,000 input_tokens**, keep **3** tool_uses); `clear_thinking_20251015` prunes old thinking blocks.
- **Server-side compaction** (`anthropic-beta: compact-2026-01-12`, edit type `compact_20260112`): SUMMARIZES the long tail at a default **150,000-token** trigger.

Measured impact: memory tool + context editing gave **84% token savings** and **39% performance improvement** on a 100-turn web-search agent; context management cuts effective context **50–70%** on later calls.

> Source: context-editing docs + token-saving-updates (retrieved 2026-06-13); see `context-editing-memory-tool.md`

**Rule**: The four hand-rolled strategies in CC2 are the right model when you control history on a non-Anthropic stack OR need a custom retention policy. On Anthropic, reach for native context editing (prune) + compaction (summarize) first — and remember the #1 bug: append the FULL `response.content` (compaction block included), not just `.text`.

**determinismLevel**: deterministic.

---

## Anti-Patterns

- **"Just use a bigger window"**: ignores O(N²) attention cost; raw history recalculates KV tensors every step.
- **Threshold-less summarization**: "summarize when long" is undefined — name the token-percentage trigger.
- **Primary model as summarizer**: wastes the expensive model on a job a Haiku-class / gpt-4o-mini-class model should do.
- **Compaction over service-managed context**: redundant when the backend already aggregates history.
- **Summarization-only on large payloads**: staged compaction (offload tool output first) preserves more than blind summarization.
- **Hand-rolling on Anthropic**: ignoring native `clear_tool_uses_20250919` (prune) + `compact_20260112` (summarize) and writing your own loop — and the #1 native-compaction bug: appending only `response.text`, which drops the compaction block.

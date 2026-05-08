# D6: Context Overflow and Compression

**Decision**: When context fills up, what is the agent's response strategy?

Context overflow is not an edge case — it is the default operating condition for long-running agents. An agent without a compression strategy will stall, hallucinate, or crash. This decision must be made before the agent goes to production.

---

## Selection Matrix

| Constraint | Recommended Strategy |
|-----------|---------------------|
| Budget constraint only (context < 30% full) | Budget Reduction always active |
| Context approaching limit, non-critical content | Snip (remove flagged low-priority content) |
| Time-based cleanup between turns | Microcompact (always, time-based) |
| Context overflow OR feature flag | Context Collapse (summarize large blocks) |
| Last resort, context critically full | Auto-Compact (full history rewrite) |
| Independent safety net at 85% | Gateway hygiene pass |

---

## Claude Code: 5-Layer Graduated Pipeline [Source: Claude Code #15]

Claude Code implements compression as a waterfall — each layer activates only after the previous is exhausted.

**Layer 1 — Budget Reduction** (always active):
- Trim tool outputs to summaries
- Remove verbose API responses
- Strip whitespace and formatting overhead
- Applies on EVERY turn, not just when context is full
- Cost: negligible

**Layer 2 — Snip** (feature-flagged):
- Agents mark content blocks with `[low-priority]` or `[can-summarize]` tags during generation
- Snip pass removes flagged content first
- Preserves high-priority content (user messages, key decisions, active task state)
- Requires agents to proactively tag output — discipline cost

**Layer 3 — Microcompact** (always, time-based):
- Triggered by elapsed time between turns, not context fullness
- Compact stale tool results and old conversation turns
- Preserves semantic content, reduces token count
- Runs in background between agent turns

**Layer 4 — Context Collapse** (feature-flagged OR on overflow):
- Full summarization of large context blocks
- Summarizer LLM produces dense narrative replacement
- Preserves decisions, discards deliberation
- Significant quality loss for reasoning-heavy tasks

**Layer 5 — Auto-Compact** (last resort):
- Triggered when context critically full
- Rewrites full history as compressed summary
- Loses fine-grained detail
- Should never be the primary strategy

**Key insight** [Source: Claude Code #4]: Graduated over monolithic. Never jump to full compression when selective removal is sufficient. Each layer has a different fidelity cost — use the cheapest effective intervention.

---

## Hermes: Dual-Layer Compression with Anti-Thrashing [Source: Hermes #4-#9]

Hermes uses two independent compression triggers — agent-layer and gateway-layer — so either catches overflow before it becomes critical.

**Trigger 1 — Agent compressor at moderate fullness** [Source: Hermes #4]:
- Agent monitors its own context usage
- Hermes uses 50% of model context window — tune this threshold by workload and model context size
- Compresses old turns, keeps recent active work

**Trigger 2 — Gateway hygiene at high fullness** [Source: Hermes #4]:
- Gateway-level (outside agent loop) monitors context
- Hermes uses 85% — the gateway must trigger before a single large tool result can overflow remaining capacity
- Tuning formula: `gateway_threshold = 1 - (p99_single_tool_output / context_limit)` — ensure headroom exceeds worst-case single output
- Independent failure mode: even if agent compressor is broken, gateway catches overflow

**Threshold tuning note**: the 50%/85% numbers are Hermes-specific, calibrated for Anthropic's 200K context window and Hermes' tool output profile. At 1M context windows these thresholds are too conservative (compressing at 500K wastes capacity). Tune by workload; preserve the two-layer principle (independent triggers, different mechanisms).

**Why two layers**: both triggers must fail independently for context to overflow. If they shared a failure mode (e.g., both trigger on the same buffer counter), one bug disables both. [Source: Claude Code #2 — safety layers must have INDEPENDENT failure modes]

---

### Anti-Thrashing Rule [Source: Hermes #5]

```
If last 2 compressions each saved < 10% of tokens → skip compression
```

**The problem it solves**: an agent near its minimum compressible size will repeatedly compress, achieve <5% reduction, and waste LLM calls summarizing an already-dense context. Anti-thrashing detects this plateau and stops.

**Implementation**: track token counts before and after each compression. Store last 2 `(before, after)` pairs. If both `(before - after) / before < 0.10` → skip next compression cycle.

---

### Pre-LLM Output Pruning [Source: Hermes #6]

```
Strip tool outputs > 200 chars to 1-line metadata BEFORE calling summarizer LLM
```

**Why this matters**: A summarizer LLM given 10,000 tokens of raw tool output will use ~2,000 tokens to produce the summary. Strip first, then summarize — the summarizer sees 1,000 tokens of metadata and uses ~200 tokens to produce an equivalent summary. 10x efficiency gain.

**Format**: `[tool: read_file, path: src/main.py, lines: 1-120, result: function signatures + imports, 2026-05-07]`

---

### Atomic Tool-Call Boundaries [Source: Hermes #7]

```
NEVER split an assistant tool_call from its tool_result during compression boundary calculation
```

**The failure mode**: if a compression boundary falls between a tool invocation and its result, the agent loses the causal chain. In the next turn, the tool_call exists with no result (model assumes failure) or the result exists with no tool_call (model is confused about what caused it).

**Parallel tool-call extension**: modern agent frameworks emit MULTIPLE tool_calls in one assistant turn with matching tool_results. A compression boundary must preserve the ENTIRE assistant turn together with ALL its tool_results — not just individual pairs. A turn is fully resolved when every tool_call in it has a matching tool_result. Compressing half of a parallel-call turn leaves the model with unresolved calls in its context, which models handle unpredictably (may re-issue calls, may invent results).

**Implementation**: compression boundaries must only fall between fully-resolved assistant turns. Walk backwards from the compression target finding the last complete turn (all N tool_results present for all N tool_calls), compress everything before that point.

---

### Active Task Protection [Source: Hermes #8]

```
Always keep the most recent user message in the UNCOMPRESSED tail
```

Even at maximum compression, the agent must retain:
1. The current task/request (most recent user message)
2. Active tool call (if mid-execution)
3. Current agent state variables

**What to compress**: historical context, closed conversations, earlier turns in the current session.

**What NEVER to compress**: the live task. Compressing the task away causes the agent to forget what it was doing — it will either loop, stop, or fabricate a completed state.

---

### Iterative Summary Updates [Source: Hermes #9]

```
Pass previous summary + new turns → update in-place, don't rewrite from scratch
```

**The problem with rewriting**: a full history rewrite produces a new summary that may contradict the previous one (different framing, different emphasis, lost detail). An agent reading two contradictory summaries of its own history cannot reason reliably.

**Iterative pattern**:
```
Input to summarizer: [PREVIOUS SUMMARY] + [NEW TURNS SINCE LAST SUMMARY]
Output: updated summary (not replacement)
```

The summarizer treats the previous summary as ground truth and only appends/updates with new information. Continuity is preserved.

---

## OpenClaw: Fallback Model Compression [Source: OpenClaw #2]

When primary LLM fails during compression (timeout, capacity, error), OpenClaw routes to a fallback model rather than crashing.

**Design principle**: compression must degrade gracefully, never hard-fail. A failed compression attempt that crashes the agent loop is worse than imperfect compression that lets the loop continue.

**Fallback chain**: primary model → cheaper model → rule-based pruning (remove oldest N turns) → last resort: truncate to context limit

---

## The Anti-Pattern: No Strategy Until Crisis

The most common failure: agents ship without a compression strategy because "we'll fix it when context fills up." At that point:
1. The agent is in production
2. Context fills up during a critical user session
3. The agent crashes or degrades with no fallback
4. Fixing compression retroactively requires changes to the agent loop

**Design requirement**: compression strategy must be designed in the same session as the agent loop, not retrofitted.

---

## Cross-Reference

- **What to store (to reduce what fills context)**: see D3 (context-memory.md)
- **Tool output verbosity control**: see D4 (tool-management.md)
- **Token cost of different compression strategies**: see D7 (cost-token-economics.md)
- **Observing compression triggers in production**: see D8 (observability.md)
- **Disasters this decision prevents**: see D10 (production-disasters.md), all incidents involve agents that ran out of reliable state

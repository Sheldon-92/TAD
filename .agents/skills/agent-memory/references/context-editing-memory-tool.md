# Anthropic Native Context Editing & Memory Tool Rules

<!-- capability: native_context_management -->

> The pack's CoALA/MemGPT/Mem0 layers are framework-agnostic patterns. This reference
> covers Anthropic's **native, server-side** primitives — context editing (tool-result
> and thinking clearing) and the file-based memory tool — that a senior memory engineer
> in 2026 designs around. A pack that omits these is anchored to pre-2025 patterns.
> Source: https://platform.claude.com/docs/en/build-with-claude/context-editing (retrieved 2026-06-13)

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| CE1 | Context editing is one beta header: `context-management-2025-06-27` | deterministic |
| CE2 | Tool-result clearing `clear_tool_uses_20250919`: trigger 100K input_tokens, keep 3 tool_uses | deterministic |
| CE3 | Thinking clearing `clear_thinking_20251015`: model-class default keep behavior | semi-deterministic |
| CE4 | Server-side compaction `compact_20260112`: header `compact-2026-01-12`, 150K default trigger | deterministic |
| CE5 | Memory tool `memory_20250818` is file-based, OUTSIDE the context window — not a clearing strategy | deterministic |
| CE6 | Measured impact: 84% token savings + 39% performance on a 100-turn web-search agent | semi-deterministic |

---

## Rules

### CE1: Context Editing Is a Single Beta Header

Anthropic ships **native, server-side context management** behind one beta header:

```
anthropic-beta: context-management-2025-06-27
```

It is configured per-request via `context_management.edits[]` (an array of strategy objects). This is distinct from application-layer compaction (CC2 in `context-compaction.md`): the API clears stale spans for you, on the server, before the next prefill — you do NOT hand-roll the clearing loop. Two edit strategies live under this header (`clear_tool_uses_20250919`, `clear_thinking_20251015`); server-side compaction (`compact_20260112`) is a separate header (CE4).

> Source: context-editing docs (2026-06-13) — beta header `context-management-2025-06-27`

**determinismLevel**: deterministic.

### CE2: Tool-Result Clearing — `clear_tool_uses_20250919`

The primary context-editing strategy clears OLD tool-call results (the bulky, no-longer-needed payloads) while keeping recent ones. Exact default config:

| Field | Type | Default | Meaning |
|-------|------|---------|---------|
| `trigger` | `input_tokens` \| `tool_uses` | `{"type":"input_tokens","value":100000}` | When clearing activates |
| `keep` | `tool_uses` | `{"type":"tool_uses","value":3}` | How many recent tool-use/result pairs to preserve |
| `clear_at_least` | `input_tokens` | none (optional) | Minimum tokens to clear so the cache invalidation is worth it (e.g. `5000`) |
| `exclude_tools` | `string[]` | none (optional) | Tools whose results are NEVER cleared (e.g. `["web_search"]`) |
| `clear_tool_inputs` | `boolean` | `false` | Also clear the tool CALL parameters, not just results |

The response reports what was cleared: `context_management.applied_edits[]` with `cleared_tool_uses` + `cleared_input_tokens`.

> Source: context-editing docs (2026-06-13) — `clear_tool_uses_20250919` defaults table

**Rule**: This is the right answer to "old tool outputs are flooding my context." Do NOT hand-roll summarization for tool-result bloat — set `clear_tool_uses_20250919` with `exclude_tools` for any tool whose output is decision-relevant later, and `clear_at_least` so a clear actually beats the cache-write cost. It PRUNES (removes), it does NOT summarize — contrast with `compact_20260112` (CE4) which summarizes.

**determinismLevel**: deterministic — the config surface is fixed.

### CE3: Thinking-Block Clearing — `clear_thinking_20251015`

Extended-thinking blocks accumulate across turns. The `clear_thinking_20251015` strategy clears old ones. The default keep behavior is **model-class dependent** — this is the trap, because the default differs across models:

| Model class | Default |
|-------------|---------|
| Opus 4.5+ / Sonnet 4.6+ | Keep ALL prior thinking |
| Opus 4.1 & earlier / Sonnet 4.5 & earlier / all Haiku | Keep only LAST turn's thinking |

Override with `keep`: `{"type":"thinking_turns","value":N}` (keep last N turns) or `{"keep":"all"}`.

> Source: context-editing docs (2026-06-13) — `clear_thinking_20251015` default-by-model-class table

**Rule**: Do not assume thinking clearing behaves identically across models — a config that keeps all thinking on Opus 4.5+ silently keeps only one turn on Sonnet 4.5. State `keep` explicitly when behavior must be portable across the model fleet.

**determinismLevel**: semi-deterministic — the default depends on the deployed model class.

### CE4: Server-Side Compaction — `compact_20260112`

When a conversation approaches the context-window limit, server-side compaction SUMMARIZES earlier context into a compaction block (vs CE2/CE3 which PRUNE). Separate beta header:

```
anthropic-beta: compact-2026-01-12
```

Enabled via `context_management.edits: [{"type": "compact_20260112"}]`. Default trigger threshold is **150,000 tokens** (the API auto-summarizes earlier context as it approaches that). Supported on Fable 5, Opus 4.8/4.7/4.6, and Sonnet 4.6.

> ⚠️ **The critical client-side bug**: you MUST append the FULL `response.content` (the compaction blocks included) back to `messages` on every turn — NOT just the extracted text string. The API uses the compaction block to replace the compacted history on the next request; extracting only `.text` silently loses the compaction state and re-sends the raw history.

> Source: claude-api skill §Compaction (2026-06-13) — header `compact-2026-01-12`, default 150K trigger, `response.content` preservation rule

**Rule**: Compaction (summarize) and context editing (prune) are complementary, both server-side: prune stale tool results with `clear_tool_uses_20250919`, summarize the long tail with `compact_20260112`. The #1 failure is appending only `.text` and losing the compaction block.

**determinismLevel**: deterministic — header + edit type are fixed.

### CE5: Memory Tool — `memory_20250818` (Outside the Context Window)

The memory tool is a **client-side, file-based** store the model reads/writes via a `/memories` directory — it lives OUTSIDE the context window, so it is durable across context-editing clears and across sessions. It is NOT a clearing strategy; it is where the agent saves what it must keep BEFORE context editing prunes the live transcript.

- Type: `{"type": "memory_20250818", "name": "memory"}`
- Commands: `view`, `create`, `str_replace`, `insert`, `delete`, `rename`
- You implement the storage backend (the SDKs ship helper classes).
- Pairs with context editing: the agent writes durable facts to `/memories`, then `clear_tool_uses_20250919` safely prunes the in-context copies.

> ⚠️ Security: never store API keys / passwords / tokens in memory files; check GDPR/CCPA before persisting PII; the reference backend has NO access control — implement per-user memory directories + auth in multi-user systems.

> Source: claude-api skill §Memory tool + context-editing docs (2026-06-13) — `memory_20250818`, `/memories` commands

**Rule**: Map the memory tool to the CoALA layers — it is durable storage for **semantic** (durable facts/preferences) and **procedural** (saved how-tos) memory, distinct from the volatile working-memory context window that context editing prunes. "Save to memory, then clear" is the native analog of MemGPT paging core memory to external context (ML1).

**determinismLevel**: deterministic.

### CE6: Measured Impact — Don't Argue from O(N²) Alone

The pack's CC1 argues compaction from O(N²) attention cost in the abstract. Anthropic's published measurement gives a concrete threshold: on an internal **100-turn web-search agentic task**, the memory tool + context editing together delivered **84% token savings** and a **39% performance improvement**; broader context management reduces the effective context on later calls by **50–70%** without losing decision-relevant info.

> Source: https://www.anthropic.com/news/token-saving-updates (retrieved 2026-06-13) — 84% token savings, 39% performance, 50–70% context reduction

**Rule**: When justifying a context-management investment, cite the 84% / 39% / 50–70% figures rather than only the generic quadratic-attention argument. The numbers are workload-shaped (100-turn web-search agent) — re-measure on your own agent shape, but they set the expectation that native context management is a large win, not a marginal one.

**determinismLevel**: semi-deterministic — benchmark is workload-dependent.

---

## Anti-Patterns

- **Hand-rolling tool-result summarization** when `clear_tool_uses_20250919` (prune, server-side) is the right primitive — and forgetting `exclude_tools` for decision-relevant tools.
- **Appending only `response.text` with compaction enabled** — silently drops the `compact_20260112` block and re-sends raw history (the #1 compaction bug).
- **Assuming `clear_thinking_20251015` keeps all thinking on every model** — Sonnet 4.5/Haiku default to last-turn-only; state `keep` explicitly for fleet portability.
- **Treating the memory tool as a clearing strategy** — it is durable file storage OUTSIDE context; it complements editing, it doesn't replace it.
- **Storing secrets / unguarded PII in `/memories`** — no built-in access control.
- **Anchoring the whole compaction design to gpt-4o-mini-class summarizers** while ignoring that Anthropic now ships native server-side context editing + compaction (CE1–CE4) that needs no separate summarizer model at all.

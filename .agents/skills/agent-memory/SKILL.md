---
name: agent-memory
description: Agent memory and context engineering capability pack. Gives AI agents the judgment rules for memory architecture (CoALA working/episodic/semantic/procedural layers), context compaction strategy selection, MemGPT/Letta virtual context management, Mem0 extract-reconcile pipelines, LangGraph state persistence and time-travel debugging, and Anthropic prompt-caching topology. Research-grounded rules from MemGPT/Letta, Mem0, LangGraph, the CoALA framework, and Anthropic caching docs. Use for any agent memory design, context-window optimization, checkpointing, or long-horizon statefulness task.
keywords: ["记忆", "agent memory", "智能体记忆", "上下文工程", "context engineering", "compaction", "压缩", "checkpoint", "检查点", "MemGPT", "Letta", "Mem0", "prompt caching", "提示缓存", "CoALA", "时间旅行", "time travel", "LangGraph", "长期记忆", "context window", "上下文窗口"]
type: reference-based
---

**CONSUMES**: User agent description + memory/context requirements + optional existing memory configs, checkpointer setup, or prompt structure
**PRODUCES**: Applied memory-architecture judgment rules + compaction strategy selection + checkpointer/time-travel configs + caching breakpoint layout + memory-vs-vector-DB decision

# Agent Memory & Context Engineering Capability Pack

**Version**: 0.1.0
**Compatibility**: Claude Code (Phase 1); Codex / Cursor / Gemini in Phase 3
**License**: Apache 2.0

---

## What This Pack Does

AI agents build "memory" by appending every conversation turn to a vector store and calling it long-term memory. They expand the context window to fit raw history, paying quadratic attention cost. They summarize blindly at no fixed threshold, drifting and hallucinating. They store temporary events ("user bought coffee March 4") with the same weight as durable preferences ("user prefers black coffee"). They restart multi-step workflows from scratch on a crash because nothing was checkpointed. They place a timestamp at the top of the prompt and silently destroy every cache hit.

This pack embeds the judgment rules that memory and context engineers apply automatically — rules from MemGPT/Letta, Mem0, LangGraph, the CoALA framework, and Anthropic's caching documentation.

**Pack = memory & context judgment. Your workflow system = process constraints. No overlap.**

---

## Cross-Cutting Rule: Memory System ≠ Vector Database

> **A vector database is a stateless similarity index; an agent memory system is a stateful architecture that governs the cognitive lifecycle of information — deciding what to retain, consolidate, modify, and discard over time.** Appending every raw turn to an append-only vector store is NOT memory: it produces relevance drift and context dilution (near-duplicate entries flood the window), and vector similarity cannot do the multi-hop graph traversal real memory needs. A true memory layer MUST implement three cognitive processes on top of (or instead of) the vector store: **Consolidation** (dedupe/merge overlapping experiences), **Scoring** (importance weights + temporal decay so stale memories fade), and **Temporal Tracking** (index *when* facts change, e.g. Zep's Graphiti, so "used to code in Python" is distinguishable from "now codes in Rust").
> > Source: findings.md "Vector Storage vs. Stateful Memory Layers" [9, 31, 32, 33]

This rule applies to: memory architecture design, semantic-memory implementation, RAG-as-memory decisions, and any "store the conversation and search it later" proposal. It is surfaced here because burying it in one reference file causes agents to ship a vector store and call it done.

---

## Step 0: Context Detection

When the user mentions memory or context-engineering work, detect the context and load the right reference:

| User Signal | Reference to Load |
|-------------|-------------------|
| "memory architecture", "what memory do I need", "episodic", "semantic", "procedural", "working memory", "CoALA", "记忆架构", "记忆类型" | `references/memory-architecture.md` |
| "context too long", "compaction", "summarize history", "token budget", "sliding window", "上下文压缩", "context window" | `references/context-compaction.md` |
| "MemGPT", "Letta", "Mem0", "self-editing memory", "core memory", "extract facts", "user profile", "long-term memory layer" | `references/memgpt-letta-mem0.md` |
| "checkpoint", "persistence", "resume after crash", "time travel", "replay", "human-in-the-loop", "interrupt", "LangGraph state", "检查点", "时间旅行" | `references/state-persistence.md` |
| "prompt caching", "cache breakpoint", "cache hit", "cost reduction", "XML structure", "提示缓存", "缓存" | `references/prompt-caching.md` |
| "full memory design", "design the whole memory system", "stateful agent from scratch" | Load **all references** sequentially |

---

## Step 1: Apply Rules

After loading the relevant reference file(s):

1. **Read the reference completely** — do not skim
2. **Apply each rule as a judgment check** against the user's memory design, config, or request
3. **For each violated rule**: state the violation clearly, then give the specific fix
4. **Enforce the Memory System ≠ Vector Database cross-cutting rule** on every "store and retrieve" proposal — demand consolidation + scoring + temporal tracking
5. **Match the memory LAYER to the cognitive type** — do not store a durable preference in a FIFO queue, or a system rule in episodic logs. Use the CoALA mapping in `memory-architecture.md`.

Output format per finding:
```
[P0] Rule MA2 (memory-architecture): Storing user preferences in the FIFO conversation queue — they evaporate when the session ends.
→ Move durable preferences to semantic memory (Mem0 user memory / Core Memory human sub-block), not the working-memory queue.

[P1] Rule PC3 (prompt-caching): Timestamp placed at top of the cached system prompt — invalidates the entire prefix every request.
→ Move dynamic variables AFTER the last cache_control breakpoint; keep Tools → System Prompt prefix byte-stable.
```

---

## Step 2: Output

Produce a structured memory/context review:

```
## Memory & Context Review: [area reviewed]

### P0 — Blocking (must fix before shipping the agent)
- [finding + specific fix]

### P1 — Required (fix before production scale)
- [finding + specific fix]

### P2 — Advisory (improves cost/latency/fidelity)
- [finding + specific fix]

### Memory Layer Map
[table: each piece of state → CoALA layer → storage implementation]

### Tool Recommendation
[Letta / Mem0 / LangGraph checkpointer / Anthropic caching — based on user context]
```

---

## Anti-Skip Table

| Excuse | Counter |
|--------|---------|
| "We'll just put everything in a vector DB" | An append-only vector store is not memory — it drifts and dilutes. You need consolidation + scoring + temporal tracking. Mem0 scored 49.0% on one LongMemEval run (harness/version-dependent — re-eval on your data); plain RAG-as-memory is generally weaker but the exact gap varies by benchmark. |
| "Bigger context window solves history" | Attention is O(N²) in sequence length. Raw uncompacted history recalculates KV tensors every step — compounding cost and latency. Compact, don't inflate. |
| "We'll summarize when it gets long" | "When it gets long" is not a trigger. Lossy summarization fires at a token threshold (~70% capacity) and is prone to drift/hallucination — pair it with a sliding window and staged compaction. |
| "Persistence is a later concern" | Without a checkpointer, one API timeout restarts a multi-step workflow from the beginning. Checkpoints also support the audit trail regulated domains expect (necessary, not sufficient — pair with retention/privacy/legal controls). |
| "Caching is automatic" | Anthropic caching is prefix-based and developer-controlled. One dynamic variable left of a breakpoint causes a full cache miss. You lose the 0.1× read rate and 41–80% cost reduction. |

---

## Tool Quick Reference

| Tool | Role | Primary Use |
|------|------|-------------|
| Letta (MemGPT runtime) | Active self-editing memory OS | Virtual context, Core Memory, heartbeats, sleep-time compute |
| Mem0 | Decoupled continuous-learning layer | Passive extract-reconcile (ADD/UPDATE/DELETE/NOOP) user memory |
| LangGraph checkpointers | State persistence + time travel | `PostgresSaver`/`DynamoDBSaver`, replay/fork, HITL interrupts |
| Anthropic prompt caching | Prefix KV reuse | `cache_control: {"type":"ephemeral"}`, ≤4 breakpoints |
| Zep (Graphiti) | Temporal knowledge graph | Indexing *when* facts change (temporal tracking) |

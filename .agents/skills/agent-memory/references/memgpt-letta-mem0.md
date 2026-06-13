# MemGPT / Letta / Mem0 Rules
<!-- capability: memory_runtime -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| ML1 | Virtual context = 2 tiers; page data between Main Context and External Context | deterministic |
| ML2 | The model is an active memory manager — use the named self-editing tools | deterministic |
| ML3 | Stateless APIs need heartbeats to chain tool calls in one turn | deterministic |
| ML4 | Mem0 reconciles facts via 4 named operations: ADD / UPDATE / DELETE / NOOP | deterministic |
| ML5 | Letta self-edits actively; Mem0 extracts passively — pick by workload | deterministic |
| ML6 | Benchmark reality: Mem0 LOCOMO 66.88%, p95 1.44s, ~7K tok/conv; Zep DMR 94.8%; verify, don't assume | semi-deterministic |
| ML7 | File-as-memory can beat vector memory: Letta Filesystem = 74.0% on LoCoMo | semi-deterministic |

---

## Rules

### ML1: Virtual Context = Two Tiers (MemGPT / Letta)

MemGPT (now the production Letta runtime, from UC Berkeley) resolves the fixed context window by **virtual context management**, paging data between physical memory and disk like an OS:

- **Tier 1 — Main Context (physical RAM)**: the active fixed-size window. Contains read-only system instructions, a writeable **Core Memory** block (Persona + Human sub-blocks), and a **FIFO message queue** of recent turns, with the first slot reserved for a recursive summary of evicted data.
- **Tier 2 — External Context (disk)**: **Recall Storage** (complete indexable database of all historical message logs) + **Archival Storage** (infinite semantic store of reflections, documents, user preferences).

> Source: findings.md "Operating System Metaphors in Agentic Memory: MemGPT and Letta" [5, 10, 17]

**determinismLevel**: deterministic.

### ML2: The Model is an Active Memory Manager — Use the Named Tools

In MemGPT/Letta the model is NOT a passive recipient of context; it pages data in/out using explicit tool calls. Use the correct tool per sub-block:

| Sub-block | Tier | Write/Edit Tool | Read/Retrieval Tool |
|-----------|------|-----------------|---------------------|
| Persona | Main Context | `memory_replace` / `memory_rethink` | direct context access |
| Human | Main Context | `memory_insert` / `memory_replace` | direct context access |
| Conversation Queue | Main Context | automatic platform push | direct context access |
| Recall Storage | External | automatic DB logging | `conversation_search` |
| Archival Storage | External | `archival_memory_insert` | `archival_memory_search` |

> Source: Letta core-memory tool docs (https://docs.letta.com/guides/ade/core-memory/) — current memory-editing tools; findings.md "Operating System Metaphors" — MemGPT memory hierarchy [5, 10]

**Rule**: Edit in-context (core) memory with the current Letta tools — `memory_insert` (add content to a block), `memory_replace` (overwrite content in a block), `memory_rethink` (reorganize a block), and `memory_finish_edits` (finalize). Searching old turns is `conversation_search` (Recall), searching uploaded knowledge is `archival_memory_search` (Archival) — they are different stores.

**Compatibility note**: The legacy MemGPT tool names `core_memory_replace` (overwrite) and `core_memory_append` (append) are **deprecated** in current Letta and replaced by `memory_replace` / `memory_insert`. Use the new names for new projects; the old names may still appear in legacy MemGPT agents.

**determinismLevel**: deterministic.

### ML3: Stateless APIs Need Heartbeats

Standard LLM APIs are stateless and rely on external triggers. Letta implements **heartbeats**: an event-driven system signal that triggers the agent's execution loop at intervals or immediately after a tool call. By requesting immediate heartbeats, the agent chains multiple tool calls (search archival → edit core memory → compile response) autonomously in a single turn without yielding control to the user.

> Source: findings.md "Operating System Metaphors" — heartbeats [10, 18]

Letta extends this OS metaphor with continual-learning techniques:
- **Context Repositories** — Git-based versioning of system knowledge for coding agents.
- **Sleep-Time Compute** — runs memory consolidation ASYNCHRONOUSLY during idle (non-blocking), a Pareto improvement on AIME/GSM-style reasoning benchmarks (numbers in arXiv:2504.13171). It does NOT block the active inference path.
- **Skill Learning** — compile/save successful tool-execution sequences as reusable procedural skills.
- **Context-Bench** — Letta's open-sourced suite measuring chained file-ops / entity-tracing / long-horizon retrieval (the agentic-context-engineering benchmark).

> Source: findings.md "Operating System Metaphors" — Letta advanced techniques [20]; https://www.letta.com/blog/context-bench + https://www.letta.com/blog/sleep-time-compute (retrieved 2026-06-13)

**determinismLevel**: deterministic.

### ML4: Mem0 Reconciles Facts via Four Named Operations

Mem0 treats long-term memory as a **decoupled, passive continuous-learning layer** (organized as "user memory"). It uses a strictly **extraction-based** pipeline (not a summarization loop): an extraction model isolates candidate facts as discrete atomic statements, then reconciles each against the user's existing profile via one of four operations:

| Operation | Trigger | DB Action | Outcome |
|-----------|---------|-----------|---------|
| **ADD** | Candidate fact is semantically novel | Insert new atomic fact | Expands the profile |
| **UPDATE** | Candidate clarifies/details an existing entry | Overwrite with refined detail | Keeps fact fresh, preserves audit trail |
| **DELETE** | Candidate directly contradicts an existing entry | Delete the old contradicted fact | Retires stale preferences |
| **NOOP** | Candidate is redundant / already known | No modification | Prevents duplicate dilution |

> Source: findings.md "Decoupled Semantic Memory and Continuous Extraction Engines" — state operation matrix [2]

**Rule**: This extract-reconcile matrix is what solves episodic recall confusion and database duplication. A "store every utterance" design has no DELETE/NOOP and therefore accumulates stale, contradictory, duplicate facts.

**determinismLevel**: deterministic — the operation matrix is fixed.

### ML5: Letta Self-Edits Actively; Mem0 Extracts Passively

Two opposite paradigms — pick by workload:

- **Letta/MemGPT** — active, tool-driven self-editing; the model manages its own virtual memory tiers via heartbeats. Best when the agent must reason about and curate its own memory in-loop.
- **Mem0** — passive, decoupled extraction; dynamically queries a semantic layer and retrieves only the facts relevant to the active turn (avoids loading monolithic instruction files that inflate tokens and cause prompt drift). Mem0 also enables **multi-agent collaboration** via a shared memory context — e.g. a `TutorAgent` and `PracticeAgent` sharing one `Mem0Memory` instance keyed to a `student_id`. For edge deployments Mem0 uses write buffering, graceful degradation, bandwidth shaping, and offline-to-online consistency.

> Source: findings.md "Decoupled Semantic Memory and Continuous Extraction Engines" [2, 5, 6, 21, 22]

**Architectural synthesis**: separate session-bound state persistence (checkpointers) from durable user-profile learning (a decoupled layer like Mem0).
> Source: findings.md "Architectural Synthesis"

**determinismLevel**: deterministic.

### ML6: Benchmark Reality — Use Primary-Source Numbers, Not One Bare Score

No memory layer is a finished product, and a single benchmark score is harness/version-dependent. Carry the primary-source numbers, not a lone figure:

**Mem0 paper (LOCOMO, LLM-as-judge)** — arXiv:2504.19413:
- Mem0 (extract-reconcile) **66.88% ±0.15**; Mem0^g (graph variant) **68.44% ±0.17** — **+26% over OpenAI's memory**.
- By question type: single-hop **67.13**, multi-hop **51.15**, open-domain **72.93**, temporal **55.51** (Mem0^g temporal best at **58.13**).
- **p95 total latency 1.44s** (Mem0) / **2.59s** (Mem0^g) vs **17.12s** full-context (~91–92% latency reduction).
- **~7K tokens/conversation** (Mem0) / **14K** (Mem0^g) vs **26K** raw and **600K+** for the graph competitor.

**Zep / Graphiti paper** — arXiv:2501.13956:
- Zep beats MemGPT on **Deep Memory Retrieval: 94.8% vs 93.4%**.
- On **LongMemEval: up to +18.5% accuracy** while reducing response latency **~90%** vs baseline.
- **Graphiti** is the temporally-aware KG engine that non-lossily indexes the **validity intervals** of facts (when each fact became true / stopped being true).

**LongMemEval cross-tool landscape** (treat any single score as harness-dependent): on GPT-4o, **Mem0 ≈ 49.0% vs Zep ≈ 63.8%** (a 14.8pt gap); newer Zep/Graphiti runs report **71.2% / 2.6s latency**. LongMemEval measures temporal multi-hop conversational recall and explicitly does NOT measure latency, cost, or ops complexity.

> Source: arXiv:2504.19413 (Mem0), arXiv:2501.13956 (Zep), https://atlan.com/know/zep-vs-mem0/ (landscape) — all retrieved 2026-06-13

**Rule**: Quote the metric WITH its harness (LOCOMO LLM-judge vs LongMemEval vs DMR are different tasks and not comparable). Report latency + token cost alongside accuracy — Mem0's headline is the **1.44s p95 / ~7K tokens** efficiency, not just the accuracy. Always re-eval on your own data; do NOT invent per-tool scores.

**determinismLevel**: semi-deterministic — benchmark scores vary by harness/version.

### ML7: File-as-Memory Can Beat Fancy Vector Memory

A senior counter-intuition data point: **Letta Filesystem scores 74.0% on LoCoMo simply by storing conversation history in files** — beating specialized memory libraries that use vector stores. This is the native analog of the memory tool's `/memories` directory (see `context-editing-memory-tool.md` CE5).

> Source: https://www.letta.com/blog/context-bench (retrieved 2026-06-13) — Letta Filesystem 74.0% LoCoMo

**Rule**: Before reaching for a vector DB as the memory backend, ask whether plain file storage + good retrieval clears the bar. "You may not need a vector DB at all" — file-as-memory (74.0% LoCoMo) is a legitimate, often-simpler baseline that beats fancy vector memory on conversational recall. This does NOT contradict MA3 (Memory ≠ Vector DB): the point is the same — appending raw turns to a vector store is not memory; structured files with consolidation can be.

**determinismLevel**: semi-deterministic — benchmark is task-dependent.

---

## Anti-Patterns

- **Wrong self-editing tool**: using `memory_insert` (append) to overwrite a persona (should be `memory_replace`), or searching Archival when you meant Recall.
- **No heartbeat loop**: expecting a stateless API to chain tool calls without an execution-engine trigger.
- **Append-only "memory"**: no DELETE/NOOP means stale, contradictory, duplicate facts accumulate.
- **Monolithic instruction files**: inflate tokens and cause prompt drift — query a semantic layer for only the relevant facts.
- **Quoting one bare benchmark score**: cite the metric with its harness (LOCOMO 66.88% LLM-judge ≠ LongMemEval 49.0% ≠ DMR 94.8%) and pair accuracy with latency (Mem0 p95 1.44s) + token cost (~7K/conv).
- **Reaching for a vector DB by reflex**: Letta Filesystem (file-as-memory) hits 74.0% on LoCoMo — file storage may clear your bar without a vector store.
- **Blocking inference on consolidation**: Letta sleep-time compute runs consolidation ASYNC during idle — don't put it on the active path.

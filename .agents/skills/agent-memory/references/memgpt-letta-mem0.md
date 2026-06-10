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
| ML6 | Benchmark reality: Mem0 = 49.0% on LongMemEval; verify, don't assume | semi-deterministic |

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
- **Sleep-Time Compute** — offline optimization during idle ("the agent dreams"): consolidates, indexes, cleans memory tiers, reducing active inference latency.
- **Skill Learning** — compile/save successful tool-execution sequences as reusable procedural skills.
- **Context-Bench** — standardized suite benchmarking agentic context engineering (chaining file ops, tracing relationships, long-horizon retrieval).

> Source: findings.md "Operating System Metaphors" — Letta advanced techniques [20]

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

### ML6: Benchmark Reality — Verify, Don't Assume

On the **LongMemEval** benchmark (temporal, multi-hop, knowledge-update long-term retrieval), Mem0 achieved **49.0%**. Public developer reviews also report latency bottlenecks, unreliable extraction indexing, and data connectors hard to secure in production. Engineers contrast Mem0 with **Zep** (more production-ready, app-centric infra, but lacks Mem0's universal data model); Zep's **Graphiti** engine explicitly indexes *when* facts change.

> Source: findings.md "Decoupled Semantic Memory and Continuous Extraction Engines" — LongMemEval 49.0% [5, 9, 23]

**Rule**: No memory layer is a finished product. Cite the benchmark number (Mem0 = 49.0% on LongMemEval) and validate retrieval quality on your own data before trusting it. Do NOT invent per-tool scores that findings does not contain.

**determinismLevel**: semi-deterministic — benchmark scores vary by harness/version.

---

## Anti-Patterns

- **Wrong self-editing tool**: using `memory_insert` (append) to overwrite a persona (should be `memory_replace`), or searching Archival when you meant Recall.
- **No heartbeat loop**: expecting a stateless API to chain tool calls without an execution-engine trigger.
- **Append-only "memory"**: no DELETE/NOOP means stale, contradictory, duplicate facts accumulate.
- **Monolithic instruction files**: inflate tokens and cause prompt drift — query a semantic layer for only the relevant facts.
- **Assuming a memory layer "just works"**: Mem0 = 49.0% on LongMemEval; verify on your data.

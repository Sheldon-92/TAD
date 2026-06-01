# Memory Architecture Rules (CoALA)
<!-- capability: memory_architecture -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| MA1 | Classify every piece of state into a CoALA layer before choosing storage | deterministic |
| MA2 | Match the layer to the cognitive type — never store a durable fact in working memory | deterministic |
| MA3 | A memory system is NOT a vector DB — it must consolidate, score, and temporally track | deterministic |
| MA4 | Vector retrieval has 2 phases with a specific chunk size; know the failure modes | semi-deterministic |
| MA5 | Add the 5th layer (organizational context) for enterprise/regulated deployments | deterministic |

---

## Rules

### MA1: Classify State into a CoALA Layer First

Before choosing any database, classify each piece of agent state using the CoALA framework (Princeton, arXiv:2309.02427), which divides memory into **working memory** and **long-term memory**, with long-term subdivided into episodic, semantic, and procedural stores.

| CoALA Layer | Cognitive Origin | Technical Translation | Storage Implementation |
|-------------|------------------|-----------------------|------------------------|
| **Working Memory** | Baddeley & Hitch (1974) | Active context window / FIFO chat history (volatile scratchpad, lost at session end) | Volatile RAM |
| **Episodic Memory** | Tulving (1972) | Decision logs, intermediary steps, few-shot prompts | Relational / document DBs |
| **Semantic Memory** | Tulving (1972) | Knowledge graphs, fact registers, personal profiles/preferences | Vector stores / graph DBs |
| **Procedural Memory** | Squire (1987) | Execution prompts, routing logic, system code | Git repositories / model parameters |

> Source: findings.md "Theoretical Foundations and the CoALA Framework" — Memory Category table [1, 2, 3, 5, 6, 7, 8, 9]

**Rule**: The classification dictates storage. Working memory is volatile by definition — anything that must survive a session restart does NOT belong there.

**determinismLevel**: deterministic — classification is a design decision.

### MA2: Match the Layer to the Cognitive Type

The recurring failure is **episodic recall confusion**: temporary events get stored with the same weight and shape as durable preferences (e.g. "the user mentioned buying coffee on March 4" stored identically to "the user prefers black coffee").

- Durable user facts/preferences → **semantic** memory (not the FIFO queue, not episodic logs)
- Time-bound execution traces / decision histories → **episodic** memory
- System prompts, routing rules, executable skills → **procedural** memory
- Recent conversational turns → **working** memory (and ONLY there)

> Source: findings.md "Decoupled Semantic Memory and Continuous Extraction Engines" — episodic recall confusion [2]

**Performance grounding**: systematic episodic memory improves customer-satisfaction in automated support, and procedural-memory registers reduce task-completion time in enterprise automation — the magnitude depends entirely on domain, baseline, and metric definition, so measure it on your own workload rather than assuming a fixed lift.
> Source: findings.md "Theoretical Foundations" [4] (direction of effect only — the cited secondary source does not specify study design, sample, or baseline, so no portable percentage is claimed)

**determinismLevel**: deterministic.

### MA3: A Memory System Must Consolidate, Score, and Temporally Track

This is the pack's cross-cutting rule, applied at architecture level. To transition from raw vector retrieval to structured memory, the layer MUST implement three cognitive processes:

1. **Consolidation** — actively deduplicate, merge, and synthesize overlapping experiences. Without it, duplicate entity representations pollute retrieval.
2. **Scoring** — apply importance weights and temporal-decay models so low-value or rarely-accessed memories fade over time, preventing context clutter.
3. **Temporal Tracking** — index *when* facts change (e.g. Zep's Graphiti engine), distinguishing historical state ("used to code in Python") from current state ("now codes in Rust").

> Source: findings.md "Vector Storage vs. Stateful Memory Layers" — three core cognitive processes [9]

**determinismLevel**: deterministic.

### MA4: Vector Retrieval Phases and Failure Modes

A vector database (Milvus, Pinecone, FAISS, Chroma) is a stateless similarity index with two phases:

- **Indexing phase**: source documents split into chunks (typically **256 to 1,024 tokens**), embedded, stored with metadata.
- **Query phase**: query embedded with the same model, similarity search returns top-*k* nearest vectors, chunks injected into the prompt.

> Source: findings.md "Vector Storage vs. Stateful Memory Layers" — vector DB workflow [31, 33]

Architectural failure modes when used AS memory:
- **Relevance drift / noise**: appending every raw turn fills the window with near-identical redundant entries.
- **No transactional or graph guarantees**: vector similarity cannot do multi-hop reasoning ("Company X uses Product Y, which had Incident Z, similar to Case W") — that needs graph traversal; flat vector lists lack the transactional consistency for in-flight tasks.

> Source: findings.md "Vector Storage vs. Stateful Memory Layers" — failure modes [9, 32]

**determinismLevel**: semi-deterministic — chunk size is a tuning parameter within the stated range.

### MA5: Add the Organizational Context Layer for Enterprise

Enterprise/regulated environments require expanding the standard 4-layer CoALA taxonomy with a **fifth layer: organizational context memory** — governed data definitions, data lineage, cross-system entity identity resolution, and corporate access-policy enforcement (stored in metadata catalogs / governance systems).

> Source: findings.md "Theoretical Foundations" — fifth layer [1]

**Rule**: If the deployment is enterprise/regulated, a 4-layer design is incomplete — identity resolution and access policy are first-class memory, not an afterthought.

**determinismLevel**: deterministic.

---

## Anti-Patterns

- **"Vector DB = memory"**: a stateless similarity store with no consolidation/scoring/temporal-tracking is RAG, not memory.
- **Flat weighting**: storing a one-off event with the same shape as a durable preference causes episodic recall confusion.
- **Working-memory persistence**: putting anything that must survive a restart in the FIFO queue.
- **Skipping the 5th layer in enterprise**: governance and identity resolution are memory, not infra glue.

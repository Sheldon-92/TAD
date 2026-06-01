# Vector & Streaming Rules: Metadata Filtering, RRF, Kafka/Flink Inference
<!-- capability: vector_streaming -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| VEC1 | Use pre-filtering for tenant isolation — it guarantees k results; post-filtering risks recall collapse | deterministic |
| VEC2 | Always populate metadata fields on ingest — a missing field silently drops the document (missing-field trap) | deterministic |
| VEC3 | Combine dense + sparse search and merge with Reciprocal Rank Fusion (RRF), smoothing constant k = 60 | deterministic |
| VEC4 | Inline (Filtered HNSW) filtering is fast but watch for graph islanding under strict filters | non-deterministic |
| STR1 | Choose Kafka Streams (embedded, local RocksDB) vs Flink (distributed, checkpointed) by operational form | deterministic |
| STR2 | External RPC inference: use async I/O (Flink unordered wait) + exponential backoff with jitter | non-deterministic |
| STR3 | Embedded model inference gives sub-ms latency but model updates require a full rolling cluster restart | deterministic |
| STR4 | Apply Shift-Left validation at ingestion-time so open table formats receive clean data; Kappa for unified replay | deterministic |

---

## Rules

### VEC1: Pre-Filter for Tenant Isolation

Raw vector similarity search is rarely sufficient — enterprise queries must be bounded by metadata (subscription tier, date range, tenant). Choose the filtering strategy deliberately:

| Strategy | Mechanics | Trade-off |
|---|---|---|
| **Pre-filtering** | Apply structured metadata filter first (B-Tree/Hash Map), then ANN search on the subset | **Guaranteed to return k results if they exist; ensures secure tenant isolation.** High latency if the filter is highly selective (massive subset scans) |
| **Post-filtering** | Global ANN search first, then discard non-matching results | Fast initial search, but **risk of zero results ("recall collapse")** if no top-k global neighbor matches |
| **Inline (Filtered HNSW)** | Metadata validation inside graph traversal | High performance, but risk of **graph islanding** |

**Rule**: for tenant isolation and any case where you must return results if they exist, use **pre-filtering**. Never post-filter for security-bounded retrieval — recall collapse will silently starve the RAG context.

**determinismLevel**: deterministic — the isolation requirement selects pre-filtering.
> Source: findings.md "Vector Database Metadata Filtering" strategy table — pre-filter guarantees k results / tenant isolation; post-filter recall collapse [35, 37].

### VEC2: Populate Every Metadata Field — The Missing-Field Trap

Vector stores are highly sensitive to schema consistency. **If a document is ingested with a missing metadata field, queries that filter on that field will silently ignore the document entirely** — the "missing field trap" — leading to hallucinations or missing context in downstream RAG models. **Rule**: enforce metadata-field completeness at ingestion; never allow a filterable field to be null/absent on a document you expect to retrieve.

**determinismLevel**: deterministic — field completeness is a hard ingestion requirement.
> Source: findings.md "if a document is ingested with a missing metadata field, queries utilizing filters on that field will silently ignore the document entirely (the 'missing field trap')" [35].

### VEC3: Hybrid Search with RRF (k = 60)

To improve precision, combine **dense vector search** (semantic intent) with **sparse keyword search** (exact terms). Merge the two rankings with **Reciprocal Rank Fusion (RRF)** — a rank-based merge that needs no score normalization:

`RRF_Score(d) = Σ over retrieval models m of  1 / (k + r_m(d))`

where `r_m(d)` is the rank of document d in model m, and **k is a smoothing constant typically set to 60**. **Rule**: for production RAG, do not rely on dense-only retrieval; fuse dense + sparse via RRF with k = 60.

**determinismLevel**: deterministic — RRF with k=60 is the recommended fusion.
> Source: findings.md "production RAG pipelines combine dense vector search... with sparse keyword search... merged using Reciprocal Rank Fusion (RRF)... k is a smoothing constant (typically set to 60)" [36, 37].

### VEC4: Inline Filtering — Watch for Graph Islanding

Inline (in-query) filtering integrates metadata validation directly into the graph traversal (e.g., a Filtered HNSW index), combining pre-filter precision with vector-search efficiency. **Rule**: it is high-performance but can cause **graph islanding** — "dead ends" where HNSW navigation fails because strict filters block connecting traversal nodes. If strict filters yield degraded recall on a Filtered HNSW index, suspect islanding and fall back to pre-filtering.

**determinismLevel**: non-deterministic — islanding depends on filter selectivity and graph topology.
> Source: findings.md inline (in-query) filtering row — "graph islanding or 'dead ends' where HNSW navigation fails" [35].

### STR1: Kafka Streams vs Flink by Operational Form

| Vector | Kafka Streams | Apache Flink |
|---|---|---|
| Operational form | Lightweight client **library embedded in a JVM app** | Distributed cluster with dedicated compute nodes |
| State management | Local **RocksDB**, backed by changelog Kafka topics | Distributed checkpoints to persistent object storage |
| Processing semantics | Streaming-only | Unified batch + stream |
| Infra dependencies | None beyond the Kafka cluster | Requires external storage for checkpoints |
| Fault recovery | Hot standby tasks → near-instant local failover | Failure stops topology, rolls back to last global checkpoint |

**Rule**: pick Kafka Streams for embedded, low-dependency streaming with fast local failover; pick Flink for distributed stateful windowing across batch + stream.

**determinismLevel**: deterministic.
> Source: findings.md "Streaming Pipelines" Kafka Streams vs Flink comparison table [41].

### STR2: External RPC Inference — Async I/O + Backoff with Jitter

In external RPC inference, the stream processor reads an event, calls an external model API, and writes the enriched result downstream — decoupling streaming infra from compute-heavy models (ideal for deep learning). But network round-trips add latency. **Rule**:

- Use **asynchronous execution** to prevent blocked threads halting consumption — e.g., Flink **Async I/O operators with an unordered wait strategy**, emitting events as soon as async requests complete.
- On network failures, use **exponential backoff with random jitter** to prevent "thundering herd" where retrying consumers overwhelm the recovering model server.

**determinismLevel**: non-deterministic — network latency and failure timing vary.
> Source: findings.md "Pattern 1: External RPC Inference" — Flink Async I/O unordered wait, exponential backoff with random jitter, thundering herd [39].

### STR3: Embedded Model Inference — Sub-ms but Restart Cost

In embedded inference, the model is loaded into the host process memory and runs locally via lightweight runtimes (**ONNX Runtime, TensorFlow Lite**), eliminating network serialization for **sub-millisecond latency**. **Rule**: accept the coupling costs — **model updates require a full rolling restart of the streaming cluster**, JVM-side model compute creates high memory pressure, and a memory leak in the model's native C++ library can crash the entire streaming node. Choose embedded only when sub-ms latency justifies the operational rigidity.

**determinismLevel**: deterministic — the trade-offs are structural.
> Source: findings.md "Pattern 2: Embedded Model Inference" — ONNX Runtime/TF Lite, sub-ms latency, full rolling restart, native C++ crash risk [39].

### STR4: Shift-Left Validation and Kappa Replay

Two core real-time architecture concepts:

- **Kappa Architecture**: treat all data — historical and real-time — as one continuous stream, eliminating separate batch/streaming code paths; historical reprocessing is done by **replaying event logs**.
- **Shift-Left Architecture**: move validation, structural shaping, and feature computation **earlier — to ingestion-time** — so downstream operational sinks and open table formats (**Apache Iceberg, Delta Lake**) receive clean, consistent data in real time.

**Rule**: validate at ingestion-time (shift-left), not after the data has fanned out; use Kappa replay instead of maintaining a parallel batch code path.

**determinismLevel**: deterministic — these are architectural selections.
> Source: findings.md "Kappa Architecture" and "Shift-Left Architecture" [41].

---

## Anti-Patterns

- **Post-filtering for tenant isolation**: recall collapse silently returns zero results (VEC1).
- **Tolerating missing metadata fields**: the missing-field trap silently drops documents from filtered queries (VEC2).
- **Dense-only retrieval**: misses exact terms; fuse dense + sparse via RRF k=60 (VEC3).
- **Synchronous external model calls in a stream**: blocked threads halt consumption — use async I/O + backoff with jitter (STR2).
- **Hot-swapping an embedded model**: updates require a full rolling cluster restart (STR3).
- **Validating after fan-out**: shift validation left to ingestion-time so Iceberg/Delta sinks stay clean (STR4).

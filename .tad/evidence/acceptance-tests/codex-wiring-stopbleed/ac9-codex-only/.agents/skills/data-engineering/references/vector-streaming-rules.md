# Vector & Streaming Rules: Metadata Filtering, RRF, Kafka/Flink Inference
<!-- capability: vector_streaming -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| VEC1 | Use pre-filtering for tenant isolation — it guarantees k results; post-filtering risks recall collapse | deterministic |
| VEC2 | Always populate metadata fields on ingest — a missing field silently drops the document (missing-field trap) | deterministic |
| VEC3 | Combine dense + sparse search and merge with Reciprocal Rank Fusion (RRF), smoothing constant k = 60 | deterministic |
| VEC4 | Inline (Filtered HNSW) filtering risks graph islanding; prefer ACORN (2–1,000x at fixed recall) where available | non-deterministic |
| STR1 | Choose Kafka Streams (embedded, local RocksDB) vs Flink (distributed, checkpointed) by operational form | deterministic |
| STR2 | External RPC inference: use async I/O (Flink unordered wait) + exponential backoff with jitter | non-deterministic |
| STR3 | Embedded model inference gives sub-ms latency but model updates require a full rolling cluster restart | deterministic |
| STR4 | Shift-Left validate at ingestion-time; Kappa replay; default Iceberg 1.10.1 (Flink/RisingWave) vs Delta 4.1.0 (Spark) | deterministic |

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

where `r_m(d)` is the rank of document d in model m, and **k is a smoothing constant — 60 is the widely-used default** (from the original Cormack et al. RRF paper / Elasticsearch & OpenSearch / Azure AI Search defaults), not a corpus-independent optimum.

**Auditable tuning band (replaces the lone magic constant)**: subsequent IR / hybrid-search benchmarks find **k in [40, 80] performs comparably**, and most vendors converged on 60. The mechanism: **low k sharpens the rank-1 advantage** (the top result of each list dominates); **high k flattens the curve → better recall/consensus**, so a buried rank-#10 result still surfaces in the fused list. **Rule**: for production RAG, do not rely on dense-only retrieval; fuse dense + sparse via RRF starting at k = 60, then tune within [40, 80] on retrieval metrics (recall@k / MRR) for your corpus — raise k when you need a long-tail item to surface, lower it when rank-1 precision matters most.

**determinismLevel**: semi-deterministic — RRF fusion is the recommended pattern; k = 60 is a default starting point to tune within [40, 80] per corpus.
> Source: OpenSearch RRF hybrid-search blog (k tuning band, vendor default 60) — https://opensearch.org/blog/introducing-reciprocal-rank-fusion-hybrid-search/ (retrieved 2026-06-13); Azure AI Search hybrid ranking (k=60 default) — https://learn.microsoft.com/en-us/azure/search/hybrid-search-ranking (retrieved 2026-06-13). Originally findings.md [36, 37]; Cormack et al. RRF paper.

### VEC4: Inline Filtering — Graph Islanding, and the ACORN SOTA

Inline (in-query) filtering integrates metadata validation directly into the graph traversal (e.g., a Filtered HNSW index), combining pre-filter precision with vector-search efficiency. The classic failure is **graph islanding** — "dead ends" where HNSW navigation fails because strict filters block connecting traversal nodes.

**SOTA — ACORN (predicate-agnostic filtered ANN)**: rather than choosing pre/post/inline by hand, named algorithm **ACORN** achieves **2–1,000x higher throughput at fixed recall** vs prior filtered-ANN methods, and is **predicate-agnostic** (no per-filter index build). Weaviate's ACORN integration measures **up to ~10x QPS at very low filter-correlation** and **~2x at 20% selectivity**, and **auto-falls back to filtered sweeping / flat-scan on high-selectivity filters** (where the graph would island anyway). **Rule**: on a vector DB that exposes ACORN (e.g., Weaviate), enable it for correlated/low-selectivity filters instead of hand-tuning pre-vs-inline; on engines without it, keep the pre-filter fallback when strict filters degrade recall (islanding).

**determinismLevel**: non-deterministic — islanding and the ACORN speedup both depend on filter selectivity and graph topology.
> Source: Weaviate ACORN filtered-search blog (2–1,000x at fixed recall; ~10x QPS low-correlation, ~2x at 20% selectivity; flat-scan fallback) — https://weaviate.io/blog/speed-up-filtered-vector-search (retrieved 2026-06-13); ACORN paper https://arxiv.org/pdf/2403.04871 (retrieved 2026-06-13). Islanding originally findings.md [35].

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
- **Shift-Left Architecture**: move validation, structural shaping, and feature computation **earlier — to ingestion-time** — so downstream operational sinks and open table formats receive clean, consistent data in real time.

**Table-format selection (versioned, replaces the bare "Iceberg, Delta Lake" mention)**:

| Format | Version | Profile | Pick when |
|---|---|---|---|
| **Apache Iceberg** | **1.10.1** (Dec 2025; full `MERGE` in PyIceberg) | **Engine-agnostic** — Spark / Flink / Trino / RisingWave / StarRocks read+write concurrently | **Flink or RisingWave is the primary streaming ingestion engine** (multi-engine lakehouse, unified real-time + batch) |
| **Delta Lake** | **4.1.0** (Mar 2026) | Spark-optimized; declarative pipelines | Your stack is Spark-centric and you want declarative pipeline tooling |

**Rule**: validate at ingestion-time (shift-left), not after the data has fanned out; use Kappa replay instead of maintaining a parallel batch code path; default to **Iceberg 1.10.1** when the streaming ingest engine is Flink/RisingWave (engine-agnostic concurrency), reserve **Delta Lake 4.1.0** for Spark-centric stacks.

**determinismLevel**: deterministic — these are architectural selections.
> Source: RisingWave Iceberg-vs-Delta streaming-workloads blog (versions + engine-agnostic concurrency) — https://risingwave.com/blog/iceberg-vs-delta-lake-streaming-workloads/ (retrieved 2026-06-13); Kai Waehner data-streaming-meets-lakehouse — https://www.kai-waehner.de/blog/2025/11/19/data-streaming-meets-lakehouse-apache-iceberg-for-unified-real-time-and-batch-analytics/ (retrieved 2026-06-13). Kappa/Shift-Left originally findings.md [41].

---

## Anti-Patterns

- **Post-filtering for tenant isolation**: recall collapse silently returns zero results (VEC1).
- **Tolerating missing metadata fields**: the missing-field trap silently drops documents from filtered queries (VEC2).
- **Dense-only retrieval**: misses exact terms; fuse dense + sparse via RRF k=60 (VEC3).
- **Synchronous external model calls in a stream**: blocked threads halt consumption — use async I/O + backoff with jitter (STR2).
- **Hot-swapping an embedded model**: updates require a full rolling cluster restart (STR3).
- **Validating after fan-out**: shift validation left to ingestion-time so Iceberg/Delta sinks stay clean (STR4).
- **Defaulting to Delta on a Flink/RisingWave streaming stack**: Delta is Spark-optimized; Iceberg 1.10.1 is engine-agnostic — pick it for multi-engine streaming ingest (STR4).

---

## Sources (URL + retrieval date)

| Ref | Source | URL | Retrieved |
|-----|--------|-----|-----------|
| VEC3 | OpenSearch — Reciprocal Rank Fusion hybrid search | https://opensearch.org/blog/introducing-reciprocal-rank-fusion-hybrid-search/ | 2026-06-13 |
| VEC3 | Azure AI Search — hybrid search ranking (RRF k=60) | https://learn.microsoft.com/en-us/azure/search/hybrid-search-ranking | 2026-06-13 |
| VEC4 | Weaviate — speed up filtered vector search (ACORN) | https://weaviate.io/blog/speed-up-filtered-vector-search | 2026-06-13 |
| VEC4 | ACORN paper (predicate-agnostic filtered ANN) | https://arxiv.org/pdf/2403.04871 | 2026-06-13 |
| STR4 | RisingWave — Iceberg vs Delta Lake for streaming | https://risingwave.com/blog/iceberg-vs-delta-lake-streaming-workloads/ | 2026-06-13 |
| STR4 | Kai Waehner — data streaming meets lakehouse | https://www.kai-waehner.de/blog/2025/11/19/data-streaming-meets-lakehouse-apache-iceberg-for-unified-real-time-and-batch-analytics/ | 2026-06-13 |

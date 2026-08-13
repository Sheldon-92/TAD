# Vector Database Selection & Indexing Rules
<!-- capability: vector_database -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| VD1 | Vector DB routing by scale & deployment matrix | deterministic |
| VD2 | pgvector + pgvectorscale: 471 QPS @ 99% recall, 11.4× Qdrant — don't add a 2nd datastore < 100M | deterministic |
| VD3 | HNSW vs IVFFlat: memory/recall vs build-speed trade-off | deterministic |
| VD4 | Metadata filtering: pre-filter fragments HNSW recall; post-filter wastes compute | semi-deterministic |
| VD5 | Pinecone namespace ceiling is plan-specific (e.g. Free 100, Enterprise 100,000) — verify for your plan | deterministic |

---

## Rules

### VD1: Vector Database Routing Matrix

When selecting a vector database, route by vector count, deployment model, and query needs:

| Database | Deployment | Index Structures | Scale Ceiling | Best For |
|----------|-----------|-----------------|---------------|----------|
| **pgvector** | PostgreSQL extension | HNSW, IVFFlat | Under 50M–100M | Existing Postgres, unified SQL queries |
| **Qdrant** | Dedicated Rust (OSS + SaaS) | HNSW | Under 50M | Fast queries, complex payload filtering, budget SaaS |
| **Weaviate** | Dedicated Go (OSS + SaaS) | HNSW | Under 500M | Hybrid search, built-in vectorization modules |
| **Milvus** | Distributed C++/Go (OSS + Zilliz) | HNSW, IVF, DiskANN | Petabytes (Billions+) | Ultra-scale enterprise, GPU acceleration |
| **Pinecone** | Fully managed serverless SaaS | Proprietary serverless | Billions+ | Zero-ops, multi-tenant SaaS (namespaces/index plan-specific: up to 100,000 on Standard/Enterprise) |
| **Chroma** | Lightweight embedded (OSS) | HNSW (default) | Under 1M | Local prototyping, fast Python setup |
| **LanceDB** | Embedded columnar (OSS) | Columnar IVFFlat | Millions | Edge, zero-copy local storage, multimodal |
| **Vespa** | Distributed (OSS + SaaS) | HNSW (customized) | Petabytes (Billions+) | Complex hybrid queries, custom scoring |

**Rule**: Chroma is for prototyping (< 1M); do not ship a multi-million-vector production system on it. Match the scale ceiling to the projected corpus, not the demo.

> Source: findings.md "Performance and Scalability Profiles" table [11, 19, 20, 21]

**determinismLevel**: deterministic — DB selection is a design decision.

### VD2: Relational pgvector Beats Dedicated DBs Under 100M

When the corpus is **under 100M vectors** and the team already runs PostgreSQL, default to **pgvector + pgvectorscale** before reaching for a dedicated vector DB.

Benchmark: pgvector + pgvectorscale achieved **471 QPS at 99% recall on 50M vectors** — an **11.4× improvement over Qdrant's 41 QPS** under identical conditions. Unified Postgres also lets you store application data, transactional metadata, and embeddings in one ACID database, **eliminating data-sync pipelines** across disparate stores.

**Rule**: "We need a dedicated vector DB at our scale" is usually premature below 100M vectors. Adding a second datastore introduces synchronization risk for no recall benefit at this scale.

> Source: findings.md "The Relational-Extension Disruption" [11, 20, 21]

**determinismLevel**: deterministic.

### VD3: HNSW vs IVFFlat Index Trade-off

When choosing an ANN index, weigh memory/recall against build speed:

- **HNSW**: multi-layered graph, logarithmic scaling, low-latency, high recall — but the **entire graph must reside in RAM**, giving a high memory footprint.
- **IVFFlat**: k-means cluster partitioning, searches only the nearest clusters. **Builds faster and uses less memory** than HNSW, but exhibits **lower search recall**.

**Rule**: Choose HNSW when latency/recall dominate and RAM is available; choose IVFFlat when memory or index-build time is the constraint and some recall loss is acceptable.

> Source: findings.md "Database Core Indexing Methodologies" [11]

**determinismLevel**: deterministic.

### VD4: Metadata Filter Ordering (Pre vs Post)

When a query pairs vector search with metadata constraints (tenant ID, timestamp), choose the filter order deliberately — it drastically impacts latency and recall:

- **Pre-filtering**: applies metadata filter BEFORE the vector search. Limits search to valid candidates, but **can fragment the HNSW graph**, stranding traversal in disconnected subgraphs and **significantly degrading recall**.
- **Post-filtering**: runs ANN search first, then removes non-matching results. **Preserves recall** but can return **fewer than k** results when most top vectors are filtered out, and wastes compute scanning non-matching vectors.

**Rule**: There is no free lunch — if a query has a highly selective metadata filter, pre-filtering risks recall collapse on HNSW; if the filter is loose, post-filtering is safer. Test recall@k under the actual filter distribution.

> Source: findings.md "Architectural Optimization of Metadata Filtering" [11]

**determinismLevel**: semi-deterministic — recall impact depends on data/filter distribution.

### VD5: Pinecone Namespace Ceiling

When designing multi-tenant isolation on Pinecone, note that the namespaces-per-index ceiling is **plan-specific**: the Free tier allows ~100 namespaces per index, while Standard/Enterprise plans allow up to **100,000** (higher counts may be available via support). **Verify the current limit for your target plan before designing tenant isolation.** Architect tenant partitioning within that ceiling (e.g., metadata-based sub-partitioning) rather than one namespace per tenant once you approach the limit.

> Source: findings.md "Performance and Scalability Profiles" table (Pinecone row) [11]; Pinecone database-limits docs (plan-specific namespace quotas)

**determinismLevel**: deterministic.

---

## Anti-Patterns

- **Prototyping DB in production**: Chroma (< 1M) and embedded DBs are for local dev. Migrate before crossing their scale ceiling.
- **Premature dedicated vector DB**: Below 100M vectors, pgvector + pgvectorscale outperforms Qdrant 11.4× and avoids a sync pipeline.
- **Blind pre-filtering on HNSW**: A selective pre-filter can fragment the HNSW graph and crater recall. Measure recall@k under the real filter.
- **One namespace per tenant past the plan limit**: Pinecone's namespaces-per-index ceiling is plan-specific (up to 100,000 on Standard/Enterprise, far fewer on Free) — verify your plan's limit and design partitioning that respects it.

## Data Engineering Review: customer-support AI pipeline (features + RAG + dimension table)

Reviewed against the data-engineering pack rules in `transformation-stack-rules.md` (TRN), `vector-streaming-rules.md` (VEC), and `dimensional-modeling-rules.md` (DIM). Three of your four design choices hit named anti-patterns the pack flags as silent, production-only failures.

---

### P0 — Blocking (must fix before pipeline goes to production)

**[P0] Rule TRN1 (transformation) — Train-serve skew: 30-day order count computed twice.**
You compute the customer's 30-day order count once in the training notebook and again in the live inference service. That is the textbook train-serve skew failure (pack Cross-Cutting Rule + TRN1, Anti-Pattern "Two copies of feature logic"). Two copies of the same feature WILL drift — a different window boundary (rolling 30d vs calendar month), timezone, dedup, or null-handling rule between notebook and service produces **silent production degradation: invalid predictions in production while offline validation accuracy stays high.** No offline test catches it.
→ Fix: serve the 30-day-order-count transformation from a **single version-controlled source** — a **dbt** model compiled into the warehouse — that feeds BOTH the historical batch training table AND the low-latency serving table (TRN1, `deterministic`). Then register it as an **entity-keyed Feature View** (customer entity) so offline training and online inference read the identical governed feature (TRN5). Delete the duplicate notebook/service logic; both sides must read the one source. Counter to "same feature logic, I'll write it twice": that IS the skew.

**[P0] Rule VEC1 (vector_streaming) — Post-filtering for tenant isolation: recall collapse + security risk.**
You run a global vector search across all tenants and then drop results that aren't the asking tenant's. This is **post-filtering**, which the pack explicitly forbids for security-bounded retrieval (VEC1, Anti-Pattern "Post-filtering for tenant isolation"). Two failures: (1) **recall collapse** — if none of the top-k global neighbors belong to the asking tenant, you return zero results and silently starve the RAG context, even when relevant tenant documents exist; (2) it is not real isolation — you embed cross-tenant content into the candidate set and rely on a post-step to scrub it (a leakage hazard if the drop step is ever buggy).
→ Fix: switch to **pre-filtering** — apply the tenant metadata filter FIRST (B-Tree/Hash Map), then run ANN search only on that tenant's subset (VEC1, `deterministic`). Pre-filtering **guarantees k results if they exist and enforces secure tenant isolation.** If a Filtered-HNSW (inline) index is available and a strict tenant filter degrades recall, suspect **graph islanding** and fall back to pre-filtering (VEC4).

**[P0] Rule DIM3 / DIM1 (dimensional_modeling) — Overwriting customer attributes (SCD Type 1) destroys training context.**
Customer tier and city live in a dimension table where you overwrite the old value on change. That is **SCD Type 1**, which **permanently deletes historical context** (DIM3, Anti-Pattern "Type 1 on history-relevant attributes"). For a customer-support AI this is actively harmful: when a model trains on a past support interaction, it needs the tier/city that existed *at the time of that event*, not today's value. Overwrite makes that reconstruction impossible, and it silently corrupts any retrospective analysis or audit.
→ Fix: model tier and city as **SCD Type 2** — the AI default (DIM2, `deterministic`). Each change inserts a new row with a surrogate key + business key + `valid_from` / `valid_to` / `is_current`, enabling **time-travel queries that reproduce the exact attribute context when a historical event occurred.** Assign SCD type per attribute (DIM1): truly fixed attributes (e.g., signup date) can stay Type 0; tier/city — which matter to the model and to audit — must be Type 2, not Type 1.

---

### P1 — Required (fix before trusting the data)

**[P1] Rule VEC3 (vector_streaming) — Embedding-only retrieval misses exact terms.**
Retrieval is embedding-only (dense). For a customer-support corpus this loses exact-match signal — order IDs, SKUs, error codes, product names — where dense semantic similarity is weak (VEC3, Anti-Pattern "Dense-only retrieval").
→ Fix: run **hybrid search** — dense vector search (semantic intent) + sparse keyword search (exact terms) — and merge the two rankings with **Reciprocal Rank Fusion (RRF)**, smoothing constant **k = 60** (`RRF_Score(d) = Σ_m 1/(k + r_m(d))`). RRF is rank-based and needs no score normalization (VEC3, `deterministic`).

**[P1] Rule VEC2 (vector_streaming) — Missing-field trap on the tenant metadata field.**
Pre-filtering on tenant is only safe if EVERY indexed document carries a populated tenant field. If any document is ingested with the tenant field missing/null, **filtered queries silently ignore that document entirely** (VEC2, the "missing-field trap") — it never appears for its own tenant, producing missing context or hallucinations.
→ Fix: enforce tenant-field completeness at ingestion; reject/repair any document whose filterable tenant field is null or absent before it enters the index (VEC2, `deterministic`). Pair this with VEC1 — pre-filtering and field-completeness are co-requirements.

---

### P2 — Advisory (improves robustness / cost)

**[P2] Rule DIM4 (dimensional_modeling) — Plan the `is_current = true` filter now (SCD Type 2 follow-on).**
Once tier/city become SCD Type 2, the dimension grows continuously. The pack's bloat example: a 10M-record customer dimension with ~3 updates/entity/year adds 30M rows/year → 150M rows over 5 years, of which only 10M are active. Any current-state query that omits `is_current = true` is forced to scan the full 150M rows.
→ Fix: every current-state lookup of tier/city MUST filter `is_current = true` (DIM4, `deterministic`); reserve unfiltered scans for deliberate time-travel/history queries.

**[P2] Rule DIM5 (dimensional_modeling) — Idempotent surrogate keys for the SCD Type 2 load.**
When you adopt Type 2, the load runs repeatedly. Duplicate load runs or task retries **write colliding surrogate keys** if key generation isn't idempotent (DIM5).
→ Fix: make surrogate-key generation idempotent so a retried/duplicated load does not create duplicate keys (`semi-deterministic`).

**[P2] Rule TRN6 (transformation) — State the aggregation granularity of the 30-day count explicitly.**
"30-day order count" hides granularity choices (rolling window vs calendar month, customer-level vs customer×channel). Too coarse loses predictive signal; too fine overfits (TRN6, `semi-deterministic`). Defining this once in the dbt model (TRN1) also forces notebook and service to agree — removing a class of skew at the source.

---

### Architecture Decision Log

- **Feature computation (30-day order count)**: single dbt model → registered customer-entity Feature View feeding both training and serving. Driver: TRN1 (train-serve skew defense, `deterministic`) + TRN5.
- **RAG tenant isolation**: **pre-filtering** (tenant metadata filter before ANN), NOT post-filtering. Driver: VEC1 (`deterministic`) — guarantees k results + secure isolation; avoids recall collapse.
- **RAG retrieval mode**: **hybrid** dense + sparse merged with RRF, **k = 60**. Driver: VEC3 (`deterministic`).
- **Metadata hygiene**: enforce tenant-field completeness at ingest. Driver: VEC2 (`deterministic`, missing-field trap).
- **Customer dimension (tier, city)**: **SCD Type 2** (`valid_from`/`valid_to`/`is_current`, surrogate + business key), assigned per-attribute. NOT Type 1 overwrite. Driver: DIM1 + DIM2 + DIM3 (`deterministic`). Query contract: `is_current = true` for current-state (DIM4); idempotent surrogate keys (DIM5).

### Tool Recommendation

- **dbt** (`pip install dbt-core`) — single version-controlled source for the 30-day-order-count feature, compiled into the warehouse; the train-serve-skew defense (TRN1/TRN5).
- **DuckDB** (`pip install duckdb`) — in-process vectorized engine for the feature transforms if data is medium-scale; do not reach for Spark by reflex (TRN2). Use **Polars LazyFrame** (`pip install polars`) for any heavy DataFrame step (predicate + projection pushdown over Pandas, TRN3).
- **Vector store with native pre-filtering / Filtered-HNSW + sparse (BM25) index** for hybrid RRF retrieval (VEC1, VEC3, VEC4).

**Bottom line:** three of the four choices are named silent-failure anti-patterns in this pack — duplicated feature logic (TRN1 train-serve skew), post-filter tenant isolation (VEC1 recall collapse), and overwrite-on-change attributes (DIM3 Type 1 context loss). All three fail invisibly: they pass offline tests and return plausible results right up until production. Fix the three P0s before this pipeline ships.

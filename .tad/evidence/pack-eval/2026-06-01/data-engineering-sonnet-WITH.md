## Data Engineering Review: Customer-Support AI Pipeline

---

### P0 — Blocking (must fix before pipeline goes to production)

**[P0] Rule TRN1 (transformation): Train-serve skew — 30-day order count computed twice.**

You compute `30-day order count` in your training notebook and again in the live inference service. This is the canonical TRN1 violation: **two copies of feature logic that will silently diverge**. The result is invalid predictions in production despite high offline validation accuracy — silent model degradation with no offline test to catch it.

→ Move the `30-day order count` computation into a single version-controlled **dbt model** (e.g., `fct_customer_features.sql`) that both the historical batch training table AND the low-latency serving table read from. If you use a feature store, register this model as an entity-keyed **Feature View** (keyed on `customer_id`) so both offline training runs and online inference pull the same materialized value (TRN5).

**determinismLevel**: deterministic — there is one correct answer: one code path, not two.

---

**[P0] Rule VEC1 (vector/RAG): Post-filtering for tenant isolation risks recall collapse.**

You run a global vector search across ALL tenants and then drop results that do not belong to the asking tenant. This is the exact anti-pattern VEC1 calls out: **post-filtering risks recall collapse** — if none of the top-k global ANN neighbors happen to belong to the asking tenant, the RAG context is starved of results (zero results returned) while silently appearing to succeed. For a customer-support AI this means the model answers with no retrieved context, producing hallucinated or generic responses, with no error surfaced.

→ Switch to **pre-filtering**: apply a structured metadata filter on `tenant_id` first (B-Tree or Hash Map index on that field), then run ANN search only on the resulting subset. Pre-filtering **guarantees k results if they exist** and is the required pattern for security-bounded tenant isolation.

→ Also enforce **Rule VEC2**: ensure every document in the vector store has `tenant_id` populated at ingest time. If any document is missing the `tenant_id` metadata field, filtered queries will silently ignore it (the "missing-field trap") — it will never be retrieved regardless of relevance.

**determinismLevel**: deterministic — the tenant-isolation requirement selects pre-filtering.

---

**[P0] Rule DIM3 (dimensional modeling): SCD Type 1 overwrite on customer attributes destroys AI training context.**

You overwrite `tier` and `city` in-place on a dimension table whenever they change. This is SCD **Type 1** behavior. For a customer-support AI that trains on historical data, **Type 1 permanently deletes the state that existed when each past support interaction happened**. A model trained today will see the customer's current tier/city, not the tier/city they had at the time of each historical ticket — poisoning the training labels (a customer who was `Tier: Free` during a complaint but is now `Tier: Pro` will look like a Pro customer raised that complaint).

→ Migrate to **SCD Type 2**: insert a new row on each change, carrying `customer_id` (business key), a surrogate key, `tier`, `city`, `valid_from`, `valid_to`, and an `is_current` boolean. This enables **time-travel queries** — joining support interactions to the customer state that was active at `interaction_timestamp` via `valid_from <= ts < valid_to` — which is exactly what training on historical context requires (DIM2).

**determinismLevel**: deterministic — SCD Type 2 is the AI default for any attribute whose historical state matters to a model.

---

### P1 — Required (fix before trusting the data)

**[P1] Rule VEC3 (RAG retrieval): Embedding-only retrieval misses exact-term matches.**

Your RAG pipeline uses embedding-only (dense vector) retrieval. Dense search captures semantic similarity but misses exact keyword matches — e.g., an exact product SKU, error code, or customer-reported phrase that appears verbatim in a support document. For customer-support use cases where customers quote specific terms (order numbers, product names, policy clauses), dense-only retrieval systematically under-retrieves the most directly relevant documents.

→ Add sparse keyword search alongside the dense search and merge the two rankings with **Reciprocal Rank Fusion (RRF)**:

`RRF_Score(d) = Σ_m  1 / (k + r_m(d))`

Start with the conventional default **k = 60** (the original RRF paper default, also used by Elasticsearch and OpenSearch), then tune k on retrieval metrics (recall@k / MRR) against your corpus. Do not treat k = 60 as a permanent production constant — it is a starting point.

**determinismLevel**: semi-deterministic — RRF fusion is the recommended pattern; k = 60 is a tunable default.

---

**[P1] Rule DIM4 (dimensional modeling): SCD Type 2 queries MUST filter with `is_current = true`.**

Once you migrate to SCD Type 2 (P0 fix above), every current-state analytical query — feature lookups, customer dashboards, real-time serving — must include a strict `is_current = true` filter. Without it, queries scan the entire history table. Concrete scale: with 10 million distinct customers and three attribute changes per customer per year, the table reaches ~160 million rows after five years (10M initial + 30M/year × 5), of which only 10 million are current. A missing filter forces a full 160M-row scan on every current-state lookup.

→ Add `WHERE is_current = true` to every current-state query. For the training join, use `valid_from <= interaction_ts AND interaction_ts < valid_to` instead of the `is_current` filter so you get the historically correct row.

**determinismLevel**: deterministic.

---

### P2 — Advisory (improves robustness / cost)

**[P2] Rule VEC4 (vector/RAG): If you adopt Inline Filtered HNSW, watch for graph islanding.**

If your vector store uses an inline (Filtered HNSW) index for the pre-filter migration, be aware that strict per-tenant filters can cause **graph islanding** — HNSW graph traversal reaches "dead ends" because connecting nodes are excluded by the filter, degrading recall without an obvious error signal.

→ Monitor per-tenant recall@k after switching to pre-filtering. If a tenant with a small corpus shows degraded recall, suspect islanding and fall back to explicit pre-filtering (subset-then-ANN) rather than inline filtered traversal.

**determinismLevel**: non-deterministic — islanding depends on filter selectivity and graph topology.

---

**[P2] Rule TRN6 (transformation): Verify 30-day aggregation granularity is deliberate.**

A 30-day rolling window is a semi-arbitrary granularity choice. For a customer-support AI, coarser windows (90-day) may better capture relationship tenure; finer windows (7-day) may better signal recent dissatisfaction. Neither is obviously wrong without validation.

→ Experiment with 7-day and 90-day variants alongside 30-day in offline evaluation. Choose by downstream model metric (precision/recall on support escalation prediction, or whatever the model optimizes), not by convention. Per TRN6: too coarse loses predictive signal; too fine overfits to recent noise.

**determinismLevel**: semi-deterministic — correct granularity is data- and model-dependent.

---

### Architecture Decision Log

| Decision | Rule | Rationale |
|---|---|---|
| Feature transformation: dbt single-source | TRN1 | Eliminates train-serve skew on `30-day order count` |
| Feature registration: entity-keyed Feature View (customer_id) | TRN5 | Governed single source for offline training + online serving |
| RAG filtering: pre-filter on tenant_id → ANN on subset | VEC1 | Guarantees k results; required for tenant security isolation |
| Metadata completeness: enforce tenant_id non-null at ingest | VEC2 | Prevents missing-field trap silently dropping documents |
| RAG retrieval: dense + sparse → RRF (k = 60, tune per corpus) | VEC3 | Hybrid search improves recall for exact-term support queries |
| Customer dimension: SCD Type 2 (valid_from/valid_to/is_current) | DIM2, DIM3 | Preserves historical attribute state for time-travel training joins |
| Current-state queries: always filter `is_current = true` | DIM4 | Avoids 160M-row full scans at 10M customers × 5 years |

---

### Tool Recommendations

| Need | Tool | Install |
|---|---|---|
| Single-source feature transformation | **dbt** | `pip install dbt-core` |
| Offline training feature table + online serving Feature View | **dbt + Feature Store** (e.g., Snowflake Feature Store) | `pip install snowflake-ml-python` |
| Medium-scale feature computation without Spark | **DuckDB** | `pip install duckdb` |
| DataFrame transforms (replace Pandas) | **Polars LazyFrame** | `pip install polars` |
| Data quality gate on feature pipeline | **Great Expectations v1.0** or **Soda Core v4** | `pip install great_expectations` / `pip install soda-core` |

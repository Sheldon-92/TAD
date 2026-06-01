## Data Engineering Review: Customer-Support AI Pipeline

### P0 — Blocking

- [P0] Rule VEC1 (vector retrieval): RAG uses global vector search, then post-filters by tenant.
  → Replace with metadata pre-filtering on `tenant_id` before ANN search. Post-filtering can cause recall collapse and can leak security assumptions across tenants. Pre-filtering guarantees `k` tenant-scoped results if they exist.

- [P0] Rule TRN1 / Cross-Cutting Train-Serve Skew (transformation): `30-day order count` is computed once in the training notebook and again in the live inference service.
  → Move this feature into one version-controlled transformation source, preferably a dbt model or registered Feature View, feeding both the historical training table and the low-latency serving table.

### P1 — Required

- [P1] Rule VEC3 (vector retrieval): Retrieval is embedding-only.
  → Add sparse keyword retrieval and fuse dense + sparse rankings with Reciprocal Rank Fusion. Start with `RRF k = 60`, then tune on `recall@k` and `MRR`.

- [P1] Rule DIM3 (dimensional modeling): Customer attributes `tier` and `city` are overwritten on change.
  → Do not use SCD Type 1 for history-relevant customer attributes. Use SCD Type 2 with surrogate key, business key, `valid_from`, `valid_to`, and `is_current` so training can reproduce the customer state at event time.

- [P1] Rule DIM2 (dimensional modeling): AI training needs historical customer context, but the dimension table deletes it.
  → Model `tier` and likely `city` as SCD Type 2. This enables time-travel joins for historical support tickets, orders, and model labels.

### P2 — Advisory

- [P2] Rule DIM4 (dimensional modeling): Once SCD Type 2 is introduced, current-state queries must filter current rows.
  → Add `is_current = true` to current customer lookups. Without it, Type 2 dimensions can bloat badly: a 10M-customer table with 3 updates per customer per year reaches roughly 160M rows after 5 years.

- [P2] Rule VEC2 (vector retrieval): Tenant filtering depends on complete metadata.
  → Enforce non-null `tenant_id` on every ingested RAG document. Missing filter fields silently drop documents from filtered queries.

### Architecture Decision Log

- Feature computation: use one dbt model or Feature View for `customer_30d_order_count` to eliminate train-serve skew. Driven by TRN1.
- RAG filtering: use tenant pre-filtering, not post-filtering. Driven by VEC1.
- RAG ranking: use hybrid dense + sparse retrieval with RRF, starting at `k = 60`. Driven by VEC3.
- Customer dimension: use SCD Type 2 for `tier` and `city`, not overwrite. Driven by DIM2/DIM3.

### Tool Recommendation

Use `dbt` for the shared feature transform, a feature store / Feature View layer for offline + online serving, and a vector store configuration that supports metadata pre-filtering plus hybrid dense/sparse retrieval with RRF.

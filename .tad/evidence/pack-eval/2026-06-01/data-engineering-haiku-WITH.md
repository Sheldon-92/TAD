# Data Engineering Review: Customer-Support AI Pipeline

## P0 — Blocking (Must Fix Before Production)

### [P0-1] Rule VEC1 (Vector Streaming): Post-Filtering for Tenant Isolation Risks Recall Collapse

**Violation**: "For RAG, I run a global vector search across all tenants and then drop results that aren't the asking tenant's."

**Finding**: Post-filtering is **deterministically unsafe for tenant isolation**. Your pipeline searches *globally*, then discards non-matching results. If no top-k global neighbor matches the asking tenant's metadata, you get **zero results** (recall collapse) — the RAG model will hallucinate or omit relevant context that *should have existed* in the tenant's slice.

**Fix**: Switch to **pre-filtering** per VEC1. Apply the tenant-isolation metadata filter first (B-Tree/Hash on tenant_id in the vector index), then run ANN search on that pre-filtered subset. This **guarantees k results if they exist** and enforces secure isolation by construction.

**Implementation**: In your vector-store configuration (e.g., Pinecone, Weaviate, Milvus), add the tenant_id as a filterable metadata field, and rewrite the query as:
```python
# Before (POST-filtering — UNSAFE):
results = vector_store.search(embedding, k=5)
results = [r for r in results if r.metadata['tenant_id'] == asking_tenant_id]

# After (PRE-filtering — SAFE):
results = vector_store.search(embedding, k=5, 
    filter={'tenant_id': asking_tenant_id})
```

**Determinism**: Deterministic — tenant isolation requirement selects pre-filtering. No tuning needed.

---

### [P0-2] Rule TRN1 (Transformation): Feature Logic in Training Notebook ≠ Live Service = Train-Serve Skew

**Violation**: "I compute the customer's 30-day order count in my training notebook, and again in the live inference service."

**Finding**: **Two copies of feature logic = train-serve skew**. Your model achieves high validation accuracy offline (on the notebook-computed feature) but produces invalid predictions in production (where the service computes the feature *differently*). The logic diverges — due to rounding, timezone, cutoff date interpretation, missing-value handling — and neither you nor your monitoring will catch the degradation because the offline accuracy remains high.

This is a **silent killer**: the model degrades in production while reporting no signal.

**Fix**: Move the 30-day order count computation into a **single version-controlled source** (dbt) that feeds *both* the historical training table AND the low-latency serving table.

**Implementation**:
1. Create a dbt model `models/features/customer_order_count_30d.sql`:
```sql
select
  customer_id,
  current_timestamp() as computed_at,
  count(*) as order_count_30d
from {{ ref('orders') }}
where order_date >= current_date - interval 30 day
  and customer_id is not null
group by customer_id
```

2. Materialize this model in the warehouse (either as a table or incremental view).

3. **Training path**: Join the historical orders table with this dbt model's output to fetch the computed feature at training time.

4. **Serving path**: Query the same dbt-computed feature table in low-latency inference (via a pre-computed cache, feature store, or real-time endpoint pointing to the warehouse).

Both paths consume the same compiled SQL, same logic, same definitions. **One source of truth**, zero skew.

**Determinism**: Deterministic — single-source-of-truth is mandatory, not optional (per TRN1).

---

### [P0-3] Rule DIM3 (Dimensional Modeling): SCD Type 1 (Overwrite) on Customer Attributes Permanently Destroys History

**Violation**: "Customer attributes (tier, city) live in a dimension table where I just overwrite the old value on change."

**Finding**: **SCD Type 1 permanently deletes historical context**. When a customer moves from city A to city B, you overwrite the old city value — the old city is gone forever. Your model, trained on historical order data with "city" as a feature, cannot reproduce the context that existed when those historical orders occurred. If customer_id=123 was in tier="standard" when they placed an order, and you later upgrade them to tier="premium", the overwrite erases the original tier. Retraining the model becomes impossible because you've lost the ground truth.

**Fix**: Switch to **SCD Type 2** (row history). Each update inserts a new row with:
- The new attribute value
- `valid_from` timestamp (when the change took effect)
- `valid_to` timestamp (when the next change took effect, or NULL for current)
- `is_current` boolean (true for the active row, false for historical rows)

**Implementation**:
```sql
-- Current: overwrite old row
update customer_dim set tier = 'premium' where customer_id = 123;

-- SCD Type 2: insert new row, close old row
update customer_dim 
  set valid_to = current_timestamp(), is_current = false 
  where customer_id = 123 and is_current = true;

insert into customer_dim (customer_id, tier, city, valid_from, valid_to, is_current)
  values (123, 'premium', old_city, current_timestamp(), null, true);
```

**Why this matters for your ML pipeline**: When you train the model, you can reconstruct the exact customer state at any historical point:
```sql
select * from customer_dim 
where customer_id = 123 
  and valid_from <= order_date 
  and (valid_to is null or order_date < valid_to);
```

This is **time-travel context** — critical for AI models trained on historical events (DIM2).

**Determinism**: Deterministic — history-relevant attributes require Type 2.

---

## P1 — Required (Fix Before Trusting the Data)

### [P1-1] Rule DIM4 (Dimensional Modeling): SCD Type 2 Queries Must Filter `is_current = true` or Face Table Bloat

**Violation**: If/when you adopt SCD Type 2 (per P0-3 fix), any query retrieving "current" customer state without filtering `is_current = true` will scan a bloated historical table.

**Finding**: After 5 years, a customer dimension with 10 million distinct entities and 3 updates per entity annually accumulates **~160 million rows** (10M initial + 30M/year × 5 years), of which only 10M are current. A query that omits `is_current = true` forces a full table scan — severe performance degradation.

**Fix**: **Always** filter to current rows in any query where you need the active state:
```sql
-- During inference, fetch current customer tier:
select tier, city from customer_dim 
where customer_id = ? 
  and is_current = true;  -- MANDATORY

-- NOT:
select tier, city from customer_dim 
where customer_id = ?;  -- BLOAT SCAN — will scan ~160M rows
```

**Determinism**: Deterministic — the filter is mandatory for current-state queries.

---

### [P1-2] Rule VEC2 (Vector Streaming): Populate Every Metadata Field at Ingest or Silent Loss

**Violation**: "Retrieval is embedding-only" — no mention of metadata field completeness during ingestion.

**Finding**: If you ingest documents into your vector store with missing metadata (e.g., missing `tenant_id` on some documents), queries filtering on `tenant_id` will **silently omit those documents** — the "missing-field trap". Your RAG system will appear to work (it returns results) but will be missing context it shouldn't be missing.

**Fix**: Enforce metadata-field completeness at ingestion-time. Before writing any document to the vector store, validate:
- `tenant_id` is present and non-null
- `document_type` is present (if needed for filtering)
- `created_at` is present (if doing time-range filtering)

Example validation:
```python
required_fields = {'tenant_id', 'document_type', 'created_at'}
for doc in documents:
    missing = required_fields - set(doc['metadata'].keys())
    if missing:
        raise ValueError(f"Document {doc['id']} missing fields: {missing}")
    
vector_store.upsert(documents)
```

**Determinism**: Deterministic — field completeness is a hard ingestion requirement.

---

## P2 — Advisory (Improves Robustness / Cost)

### [P2-1] Rule VEC3 (Vector Streaming): Dense-Only Retrieval Misses Exact Terms — Use RRF with k=60

**Violation**: "Retrieval is embedding-only" (dense vectors only, no hybrid search).

**Finding**: Dense embeddings capture semantic intent ("customer wants refund") but miss exact terms ("refund policy", "policy number 12345"). For customer-support RAG, exact-term matching is often critical — users search for order numbers, ticket IDs, policy names. Dense-only retrieval will miss these.

**Fix**: Implement **hybrid search**: combine dense vector search + sparse keyword search, merged with **Reciprocal Rank Fusion (RRF)** at smoothing constant **k = 60** (the widely-used default per RRF literature and Elasticsearch/OpenSearch).

Example (pseudocode for a vector store like Pinecone + Weaviate):
```python
# Dense search
dense_results = vector_store.search(embedding, k=5, filter={'tenant_id': tenant_id})

# Sparse search (keyword-based)
sparse_results = keyword_store.search(query_text, k=5, filter={'tenant_id': tenant_id})

# RRF merge (k = 60)
def reciprocal_rank_fusion(dense_results, sparse_results, k=60):
    rrf_scores = {}
    for rank, doc in enumerate(dense_results, start=1):
        rrf_scores[doc['id']] = rrf_scores.get(doc['id'], 0) + 1 / (k + rank)
    for rank, doc in enumerate(sparse_results, start=1):
        rrf_scores[doc['id']] = rrf_scores.get(doc['id'], 0) + 1 / (k + rank)
    return sorted(rrf_scores.items(), key=lambda x: x[1], reverse=True)[:5]
```

**Determinism**: Semi-deterministic — RRF k=60 is a default starting point; tune on retrieval metrics (recall@k, MRR) for your corpus after deployment.

---

### [P2-2] Rule TRN2 (Transformation): DuckDB for Medium-Scale Feature Transforms, Not Spark

**Assumption**: If you're computing the 30-day order count (P0-2 fix) and it involves medium-scale transformations (millions of rows, not billions), consider the operational cost.

**Finding**: Spark clusters are heavyweight (scheduler, worker coordination, serialization latency). For medium-scale data, **DuckDB** — an in-process, vectorized analytical database — can **speed pipelines 10x or more** without the operational overhead.

**Recommendation**: If your feature transform currently runs on Spark (or you're planning one), try DuckDB first:
```python
import duckdb

conn = duckdb.connect()
conn.execute("""
  select customer_id, count(*) as order_count_30d
  from read_parquet('s3://orders/*.parquet')
  where order_date >= current_date - interval 30 day
  group by customer_id
""").pl()  # Returns a Polars DataFrame
```

DuckDB reads Parquet/CSV/JSON directly, executes vectorized, and returns results in-process. No cluster, no serialization, sub-second latency for millions of rows.

**Determinism**: Deterministic — for medium-scale local data, DuckDB is the correct engine choice.

---

## Architecture Decision Log

| Decision | Rule Applied | Rationale |
|----------|--------------|-----------|
| **Tenant Isolation Strategy** | VEC1 (Pre-filtering) | Global post-filter risks recall collapse; pre-filter guarantees k results + secure isolation |
| **Feature Computation Source** | TRN1 (dbt single-source) | One version-controlled dbt model feeding both training and serving prevents train-serve skew |
| **Customer Dimension SCD Type** | DIM2 (Type 2 row history) | Time-travel queries enable historical context for model retraining; Type 1 overwrite permanently destroys it |
| **Current-State Customer Queries** | DIM4 (is_current = true filter) | Mandatory for SCD Type 2 to avoid ~160M-row table bloat scans |
| **Metadata Field Completeness** | VEC2 (validate at ingest) | Missing fields silently drop documents in filtered queries; enforce at ingestion-time |
| **Retrieval Strategy** | VEC3 (Hybrid RRF k=60) | Dense-only misses exact terms (order/ticket IDs); RRF fusion (k=60) combines dense + sparse |
| **Feature Transform Engine** | TRN2 (DuckDB) | If medium-scale, DuckDB (in-process, vectorized) outperforms Spark 10x without cluster overhead |

---

## Tool Recommendation

For this customer-support AI pipeline, recommend:

1. **dbt** (https://www.getdbt.com/) for feature transformation — single source of truth for the 30-day order count and any other features
2. **Pinecone** or **Weaviate** with **pre-filtering** for tenant-isolated RAG (both support tenant_id metadata filters)
3. **DuckDB** or **Polars** for batch feature engineering / ELT transformations (if using dbt, no separate compute needed; if standalone features, DuckDB eliminates Spark overhead)
4. **PostgreSQL** or **Snowflake** for the customer dimension table in SCD Type 2 (both support efficient time-travel queries)

---

## Summary

- **P0-1 (VEC1)**: Switch from post-filtering to pre-filtering for tenant isolation — post-filtering risks zero results.
- **P0-2 (TRN1)**: Move 30-day order count into dbt to eliminate train-serve skew.
- **P0-3 (DIM3 + DIM2)**: Adopt SCD Type 2 for customer attributes to preserve historical context.
- **P1-1 (DIM4)**: Always filter SCD Type 2 queries with `is_current = true`.
- **P1-2 (VEC2)**: Validate metadata field completeness at vector ingestion.
- **P2-1 (VEC3)**: Implement hybrid dense + sparse retrieval with RRF (k=60).
- **P2-2 (TRN2)**: Use DuckDB for medium-scale transforms instead of Spark.

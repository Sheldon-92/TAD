# Data Engineering Review: Customer-Support AI Pipeline

## Executive Summary
The pipeline has **three critical production hazards** affecting correctness, performance, and auditability:
1. **30-day order count drift** between training and inference (data freshness/consistency)
2. **Multi-tenant RAG leakage** via embedding-only filtering (privacy/security)
3. **Dimension table lossy overwrites** (audit trail loss, recovery impossibility)

---

## Finding 1: Order Count Train-Serve Skew

**Issue**: Computing `order_count_30d` in the training notebook and again in live inference creates two independent implementations prone to divergence.

**Root Causes**:
- **Different code paths**: notebook query may use pandas/SQL syntax that differs from the inference service's SQL dialect
- **Different snapshots**: training snapshot captured at notebook-run time; inference runs on live DB state, which may have new orders, cancellations, or corrections
- **Schema drift**: if the orders table schema changes (new columns, renamed fields, type changes), one path may silently fail or return wrong results while the other succeeds

**Specific Risks**:
- A customer with 29 orders gets different recommendations if they cross 30 at inference time than during training
- Batch features (training-time computation) and online features (inference-time) are inconsistent; no single source of truth
- No test coverage for the training-inference gap; bugs surface only when customer complains

**Recommendations**:
1. **Implement a shared feature store** (e.g., Feast, Tecton) that computes `order_count_30d` ONCE and serves to both training and inference pipelines
2. **If feature store is overkill**, create a **single canonical SQL view** (`customer_order_count_30d`) in your data warehouse; both training and inference must query the same view
3. **Add schema change detection**: materialize the computation result with a timestamp; if the result hasn't updated in >30 seconds during inference, alert and fall back to a cached value
4. **Test the gap explicitly**: run training and inference on the SAME customer cohort, compare results; failures here are non-negotiable

---

## Finding 2: RAG Multi-Tenant Leakage via Embedding-Only Filtering

**Issue**: Global vector search across all tenants, then post-hoc filtering by tenant ID is a **multi-tenant access control anti-pattern**.

**Root Causes**:
- **Late filtering**: embeddings are dense vectors with no metadata; the search index doesn't know tenant boundaries, so it returns results from ALL tenants
- **Reliance on filtering**: if the post-search filtering logic breaks (null tenant ID, bug in the filter predicate), results leak between tenants with zero detection
- **No isolation guarantees**: the vector DB has no semantic knowledge of "tenant" — it's just data the app-layer adds/removes

**Specific Risks**:
- A bug in the tenant-filtering code (off-by-one, missing null check, boolean negation) exposes one customer's documents to another
- If you ever parallelize or cache search results (e.g., serving the top-k embeddings), a misconfiguration returns unfiltered results
- Compliance audit will flag this as a control weakness: "filtering happens after search, not enforced by the system"
- Vector DB outages or accidental bulk imports can bypass your filtering entirely

**Recommendations**:
1. **Partition embeddings by tenant**: store each tenant's vectors in a separate index (e.g., `customer_docs_tenant_123`), or add `tenant_id` as a dense metadata field that the vector search natively filters BEFORE returning results
2. **If your vector DB supports metadata filtering** (Pinecone, Weaviate, Milvus), make the tenant filter MANDATORY in the search query: `search(query_vector, filter={"tenant_id": customer_tenant_id})` — this moves filtering from app-layer to DB-layer
3. **No post-hoc filtering at all**: if tenant filtering isn't part of the vector DB query, don't retrieve the results in the first place
4. **Test tenant isolation**: write an adversarial test that searches as customer A and verifies ZERO results from customer B in the top-k (not just "filtered out later", but genuinely absent from the result set)

---

## Finding 3: Dimension Table Lossy Overwrites

**Issue**: Overwriting customer attributes (tier, city) in place loses the audit trail and makes it impossible to recover prior values.

**Root Causes**:
- **No versioning**: each `UPDATE` statement replaces the old value with no record of what changed or when
- **No history table**: there's no secondary table tracking historical values
- **No soft deletes**: the dimension table is the only record; once overwritten, the old value is gone

**Specific Risks**:
- Customer disputes: "I was on the Premium tier last month, why didn't I get the discount?" — you can't verify the claim
- ML model retraining: if you want to see which features changed and when, you have no data
- Debugging: a feature suddenly breaks for a cohort; you can't correlate it to a recent attribute change
- Regulatory: some compliance regimes (PII handling, financial services) require an audit log of all data changes

**Recommendations**:
1. **Implement a slowly-changing dimension (SCD Type 2)**: keep two tables:
   - `dim_customer_current` (your active dimension table, updated in place)
   - `dim_customer_history` (append-only log with `effective_date` and `end_date` for each version)
   - When a customer's tier changes, INSERT a new row in the history table (closing the old row's `end_date`) and UPDATE the current table
2. **If history is overkill**, add a **`last_updated` timestamp** and **`previous_value_json`** column to track the most recent change
3. **Make the history queryable**: in training, JOIN on history to pull the feature value AS OF the order date (not the current date)
4. **Test the data quality**: for a sample of customers, verify that `current_tier` matches the most recent `history` row

---

## Summary Table

| Finding | Category | Severity | Mitigation |
|---------|----------|----------|-----------|
| Order count train-serve skew | Data consistency | HIGH | Shared feature store or canonical SQL view |
| RAG embedding-only multi-tenant filtering | Security/Privacy | CRITICAL | Partition by tenant or enforce DB-level filtering |
| Dimension table lossy overwrites | Auditability | MEDIUM | Implement SCD Type 2 or append audit log |

---

## Questions for Clarification
1. **Embedding storage**: which vector DB? (Pinecone, Weaviate, Milvus, others?)
2. **Order count freshness requirement**: can you tolerate 1-hour stale data, or must it be real-time?
3. **Customer volume**: how many customers and documents? (affects feasibility of per-tenant partitioning)
4. **Compliance requirements**: are you subject to SOC 2, HIPAA, or other auditing standards?

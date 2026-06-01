## Data Engineering Review: Customer-Support AI Pipeline

### P0 — Blocking (must fix before pipeline goes to production)
- **[P0] Rule TRN1 (transformation): Feature logic computed separately in training notebook and live inference service.**
  → Move the 30-day order count transformation into a single version-controlled source (e.g., a **dbt** model or a registered Feature View) that feeds both the historical training table and the low-latency serving table. Writing feature logic twice introduces silent train-serve skew, degrading production models despite high offline accuracy.
- **[P0] Rule VEC1 (vector): Global vector search followed by post-filtering for tenant isolation.**
  → Switch to **pre-filtering** (applying the metadata filter before the ANN search). Post-filtering risks "recall collapse"—returning zero results if none of the top-k global neighbors belong to the asking tenant. Pre-filtering guarantees k results if they exist and ensures secure tenant isolation.
- **[P0] Rule DIM3 (dimensional modeling): Customer attributes use SCD Type 1 (overwrite old value on change).**
  → Switch to **SCD Type 2**. Overwriting permanently deletes historical context. For AI training, you must be able to perform "time travel" queries to reproduce the exact customer attributes (e.g., tier, city) that existed at the time of a historical event. Use row history with a unique surrogate key and `valid_from`/`valid_to`/`is_current` metadata fields.

### P1 — Required (fix before trusting the data)
- **[P1] Rule VEC3 (vector): Retrieval relies on dense embedding-only search.**
  → Implement hybrid search. Combine your dense vector search (for semantic intent) with sparse keyword search (for exact terms) and merge the rankings using **Reciprocal Rank Fusion (RRF)**. Start with the smoothing constant **k = 60**, then tune k based on your corpus retrieval metrics.

### P2 — Advisory (improves robustness / cost)
- **[P2] Rule DIM4 (dimensional modeling): Querying the new SCD Type 2 dimension.**
  → Once you migrate to SCD Type 2, ensure any current-state analytical queries strictly apply an `is_current = true` filter. Omitting this filter forces the database to scan the entire bloated history of the dimension, severely degrading performance.

### Architecture Decision Log
- **Transformation Strategy:** Single version-controlled transformation (dbt) selected to enforce identical mathematical logic across training and serving, preventing train-serve skew (TRN1).
- **Tenant Isolation:** Pre-filtering selected over post-filtering to guarantee secure isolation and prevent RAG recall collapse (VEC1).
- **Retrieval Strategy:** Hybrid search with Reciprocal Rank Fusion (k=60) selected to combine semantic intent with exact keyword matching (VEC3).
- **Dimensional Modeling:** SCD Type 2 selected over Type 1 for customer attributes to preserve the time-travel context required for AI training (DIM2, DIM3).

### Tool Recommendation
- **Transformation / Feature Store:** **dbt** (`dbt-core`) to unify offline and online transformations.
- **Vector Search:** A vector database supporting robust **pre-filtering** and **hybrid search** (dense + sparse with RRF).

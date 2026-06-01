# Data Pipeline Review: Customer-Support AI
**Reviewer**: Senior Data Engineer
**Date**: 2026-06-01

---

## Summary

The pipeline has four distinct design areas to review: feature computation, vector search architecture, retrieval strategy, and dimension table modeling. Each has meaningful issues worth addressing before production.

---

## 1. Feature Computation: Training vs. Inference Skew (Training-Serving Skew)

**Issue: Dual-implementation of the 30-day order count is a training-serving skew risk.**

Computing the same feature in two separate places (notebook vs. inference service) means they can silently diverge. Common causes:

- Different timezone handling (notebook uses UTC, service uses local time; or vice versa)
- Different definitions of "30 days" — calendar days vs. rolling 86400-second window
- Different handling of cancelled/returned orders
- Different cutoff logic — does the window include today? Does it include the exact boundary timestamp?

When these two implementations disagree, your model trains on feature distribution A but scores against feature distribution B. This degrades model quality in a way that is very hard to diagnose because both sides appear to work correctly in isolation.

**Recommendation**: Centralize feature computation in a feature store or a shared SQL view/function. Both the training pipeline and the inference service should call the same materialized or on-demand computation. Tools like Feast, Tecton, or even a shared dbt model with a well-defined macro can eliminate this dual-implementation. At minimum, write a single SQL function, version-control it, and call it from both contexts.

---

## 2. Vector Search: Global Search Followed by Post-Hoc Tenant Filtering

**Issue: This is an expensive and leaky architecture.**

Running a global ANN (approximate nearest neighbor) search across all tenants and then discarding non-matching results has two serious problems:

**2a. Data isolation / privacy leak risk**: Retrieving documents belonging to other tenants into the inference context, even transiently, creates audit and compliance exposure. In a multi-tenant SaaS context, this likely violates your data isolation requirements. Even if you discard them before returning results to the user, they've been loaded into memory and processed.

**2b. Recall degradation**: If a tenant's relevant documents are ranked 25th-50th globally but get bumped out of a top-20 recall window by other tenants' documents, they're silently dropped before your post-hoc filter even sees them. You end up with fewer relevant results than you think, with no visibility into the loss.

**Recommendation**: Use tenant-scoped vector search from the start. Most vector databases (Pinecone, Weaviate, Qdrant, pgvector) support namespace partitioning or metadata pre-filters that can restrict the ANN search space to a single tenant before scoring. This gives you both correct isolation and better recall for smaller tenants.

---

## 3. Retrieval Strategy: Embedding-Only

**Issue: Embedding-only retrieval underperforms on exact-match and keyword queries.**

Dense vector search excels at semantic similarity but struggles when the user query contains exact product SKUs, order numbers, ticket IDs, or short highly-specific strings. A customer asking "where is order #A-8827341?" benefits very little from semantic similarity — the correct document needs to be retrieved by exact string match.

**Recommendation**: Implement hybrid retrieval combining dense embedding search with sparse BM25/keyword search, then fuse scores (reciprocal rank fusion or a learned ranker). This is now standard practice for production RAG systems. Most vector databases support hybrid search natively. For a customer support context, exact-match recall on structured identifiers (order IDs, case numbers, product codes) is particularly high value.

---

## 4. Dimension Table: Overwrite on Change (No History)

**Issue: Overwriting customer attributes loses historical context needed for model correctness and debugging.**

When you overwrite `tier` or `city` on change, you lose the ability to:

- Reproduce past predictions (what tier was the customer when the model made this decision?)
- Audit complaints ("why did I get this response six weeks ago?")
- Train on historical snapshots accurately — if a customer was `tier=bronze` when an interaction happened but is now `tier=gold`, training on current state introduces label leakage

This is a Slowly Changing Dimension (SCD) problem. Overwriting is SCD Type 1, which is appropriate only for truly immutable corrections (fixing a data entry error), not for genuine business state changes.

**Recommendation**: Implement SCD Type 2 for attributes that represent real state changes over time: add `valid_from`, `valid_to` (NULL = current), and `is_current` columns. For training data generation, join on the timestamp of the interaction to get the attribute value that was true at inference time. For live inference, join on `is_current = true`. This ensures training and serving use temporally consistent feature values.

---

## Priority Order for Fixes

| Priority | Issue | Risk |
|----------|-------|------|
| P0 | Global vector search + post-hoc filter | Privacy/compliance, silent recall degradation |
| P0 | Dimension table overwrites (SCD Type 1) | Training-serving skew, audit failure, label leakage |
| P1 | Dual feature computation (training vs. inference) | Silent model quality degradation |
| P2 | Embedding-only retrieval | Reduced recall on exact-match queries |

The two P0 items should block production launch. The P1 and P2 items are important but can be addressed post-launch with careful monitoring.

---

## One Additional Note

For the RAG pipeline, consider adding a **re-ranking step** after retrieval regardless of whether you switch to hybrid search. A cross-encoder re-ranker (e.g., a small BERT-class model) applied to the top-k retrieved chunks before generation significantly improves answer quality in customer support contexts where the user's actual intent often differs from the surface-level query wording.

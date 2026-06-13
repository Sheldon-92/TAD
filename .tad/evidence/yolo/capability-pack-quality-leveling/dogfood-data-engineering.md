# Dogfood Judgment: data-engineering pack — Customer-Support AI Pipeline Review

Date: 2026-06-13
Judge: independent technical judge (blind to which answer used the skill)

## Task
Review a customer-support AI data pipeline with 4 embedded problems:
1. 30-day order count computed twice (Pandas training notebook + live inference) → train-serve skew
2. RAG global vector search + post-filter to asking tenant → recall collapse + tenant leak
3. tier+region metadata filter applied inside HNSW traversal → filtered-ANN recall risk
4. Embedding-only retrieval → misses exact-term matches
5. Dimension table overwrites tier/city → SCD Type 1, destroys history

## WebSearch verification of specific claims

| Claim | Answer | Verified? | Source |
|-------|--------|-----------|--------|
| ACORN 2–1,000x throughput at fixed recall, auto flat-scan fallback on high selectivity | A1 | CORRECT | weaviate.io/blog/speed-up-filtered-vector-search; emergentmind ACORN paper (2-1,000x); Vespa blog (ACORN-1 ~4x QPS @95% recall) |
| RRF default k=60, tune within [40,80] on recall@k/MRR | A1 | CORRECT | Cormack et al. 2009 TREC; Milvus/Azure/OpenSearch docs all default 60; [40,80] empirical sweet spot |
| Polars streaming ~94x faster than Pandas at SF-10 | A1 (hedged) | DEFENSIBLE | pola.rs official says ">order of magnitude / 12-15x"; TDS independent says ~30x. 94x is single-thread-streaming-vs-Pandas, high end of range; A1 attributes it to skill source. Not wrong, but most-favorable framing. |
| DuckDB v1.4-LTS out-of-core to ~27TB single node (SF-100,000, 7TB spill) | A1 | CORRECT (per skill source) | matches skill citation duckdb.org 1.4-LTS; plausible, not contradicted |
| SCD Type 1 = overwrite (no history); Type 2 = new row + valid_from/valid_to/is_current + surrogate key | BOTH | CORRECT | Coalesce, Microsoft Fabric, DataCamp — textbook-correct |
| Post-filtering → zero results if no top-k global neighbor matches metadata (recall collapse) | BOTH | CORRECT | well-documented filtered-ANN behavior (yudhiesh, Weaviate docs) |
| Filtered-HNSW in-traversal → graph dead-ends / recall drop on selective filters | BOTH | CORRECT | TDS "Effects of filtered HNSW on Recall and Latency" (Dilocker); ACORN paper motivation |
| Native filtered-ANN falls back to brute-force when filtered set small | A2 | CORRECT | Qdrant/Weaviate documented payload-index + flat fallback behavior |

**No specific-but-WRONG claims found in either answer.** A1's 94x is the one figure on the aggressive end of the verified range, but it is hedged ("~94x slower than Polars streaming at SF-10") and traceable to the skill's cited benchmark — not a fabrication. Both answers are factually clean.

## Scoring (1-5)

### Answer 1
- Correctness: 5 — all named numbers/tools verified correct; no fabrication. Diagnoses all 5 problems correctly. Adds correct extras (missing-field trap VEC2, idempotent surrogate keys, bitemporal for late arrivals).
- Actionability: 5 — every finding has a named tool + concrete config (dbt model → Feature View, pre-filter on tenant_id, ACORN, GX/Soda ingestion gate, scd2-bloat-check.sql). P0/P1/P2 triage + Architecture Decision Log + Tool Recommendation.
- Specificity: 5 — highest specificity, all verified: ACORN throughput, RRF k=60 [40,80], DuckDB 27TB, dbt Feature View, named ingestion validators.
- Completeness: 5 — covers all 5 problems + 2 second-order issues (missing-field null trap, is_current bloat discipline, bitemporal late-arrival). Most thorough.

### Answer 2
- Correctness: 5 — all diagnoses correct; the standout is the explicit **point-in-time / as-of leakage** framing: overwriting the dimension means training joins use *current* tier/city, leaking future state into past rows and inflating offline metrics. This is the deepest and most correct senior insight in either answer. No wrong specifics.
- Actionability: 4 — concrete fixes (partition-per-tenant namespace, native pre-filter, hybrid+cross-encoder, as-of joins, skew-detection CI test) but fewer pinned tool names/versions; "Feast-style" is illustrative rather than prescriptive.
- Specificity: 4 — names Feast, Qdrant/Weaviate/pgvector, BM25, RRF, cross-encoder, but no numeric thresholds (no k value, no benchmark figures). Less numeric anchoring than A1; correspondingly lower fabrication surface.
- Completeness: 5 — covers all 5 problems + adds cross-encoder reranking (A1 omits), per-tenant partitioning as strongest isolation, and the cross-cutting point-in-time theme that unifies 3 of the 5 bugs. The synthesis ("anchor every feature and dimension join to an explicit as-of timestamp") is a genuine value-add.

## Winner: TIE → leaning Answer 1 by slight margin

Both answers are excellent and factually clean — no wrong specifics in either. This is the rare case where the skill-user (Answer 1, which reviewed the data-engineering SKILL.md) did NOT win on hallucinated specificity; its specifics are all verified correct, and it adds real second-order findings (VEC2 missing-field trap, bitemporal late arrivals, is_current bloat with a concrete check script).

Answer 2 matches it on correctness and arguably exceeds it on ONE dimension: the point-in-time/as-of leakage insight, which correctly connects the SCD-1 overwrite to *training-time future leakage* (not just "lost history"), and adds cross-encoder reranking. That is the single best individual insight across both.

Decision: **Answer 1 wins by a slight margin.** It wins on CORRECT specifics (not verbosity): verified ACORN/RRF/DuckDB numbers, pinned tools, the missing-field null trap (a real isolation bug A2 misses entirely — a null tier/region makes a tenant's docs silently invisible), idempotent keys, bitemporal late-arrival handling, and an executable bloat-check. Its specificity is load-bearing and accurate, which is exactly what should be rewarded. Answer 2's point-in-time framing and cross-encoder are genuine wins but don't outweigh A1's broader verified coverage. Margin is slight because A2's correctness is equal and its deepest insight is arguably sharper.

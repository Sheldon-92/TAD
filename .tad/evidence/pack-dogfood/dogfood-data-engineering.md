# Pack Dogfood Judgment — data-engineering

**Task**: Review customer-support AI data pipeline (30-day order count feature computed twice; global vector search + post-filter for tenant + inline tier/region HNSW filter; embedding-only retrieval; SCD Type 1 dimension overwrite).

**Date**: 2026-06-13
**Judge**: independent technical judge (blind to which answer used the skill)

---

## Verification of key specific claims (WebSearch against primary docs)

| Claim | Answer | Verdict | Source |
|-------|--------|---------|--------|
| Post-filter top-k can return zero in-tenant results; pre-filter guarantees k if they exist | Both | CORRECT | Weaviate/Qdrant filtering docs |
| Filtered-HNSW with selective filter → graph disconnection/islanding → recall collapse, no error | Both | CORRECT | "Effects of filtered HNSW searches on Recall and Latency" (TDS/Dilocker); Qdrant filterable-HNSW course; Weaviate ACORN blog |
| ACORN fixes disconnected-graph search, predicate-agnostic, auto-falls-back to flat-scan on high selectivity, Weaviate 1.27+ | A2 | CORRECT | Weaviate ACORN blog (ACORN in 1.27+); ACORN paper 2403.04871 |
| ACORN "2–1,000x at fixed recall" | A2 | CORRECT (number is real) | ACORN paper abstract: "2-1,000x higher throughput at a fixed recall." NOTE: A2 attributes this to "Weaviate" — Weaviate's own blog claims "up to 10x"; the 2–1,000x is the academic paper's figure. Minor source conflation, number itself accurate. |
| RRF k=60, tune within [40,80] on recall@k/MRR | A2 | CORRECT | Cormack et al. 2009 (TREC); k=60 is the cross-vendor default (OpenSearch/Azure/Weaviate/Milvus); [40,80] comparable band confirmed |
| RRF (fuse dense+sparse), cross-encoder reranker on fused top-k | A1 | CORRECT | standard hybrid-search practice |
| Polars streaming order-of-magnitude faster; Pandas OOMs at SF-100; 40GB within single-node out-of-core | A2 | DIRECTIONALLY CORRECT | Polars PDS-H May 2025 benchmark: Pandas cannot complete SF-100 on 64GB; Polars streaming finishes. SF-10 Polars >10x. The exact "3.89s vs 365.71s (~94x)" pair is a precise number I could not match to a published source — plausible but UNVERIFIED specific (not contradicted). |
| DuckDB out-of-core to ~27TB on one node, v1.4-LTS | A2 | CORRECT | DuckDB v1.4 LTS benchmark (Oct 2025): SF-100000 (~100TB CSV), final DB ~27TB, 1.5TB-RAM single instance. v1.4 LTS is real. |
| SCD Type 1 = overwrite destroys history; Type 2 = valid_from/valid_to/is_current row versioning; point-in-time join on event_ts BETWEEN valid_from AND valid_to | Both | CORRECT | Kimball SCD canon |
| SCD Type 2 bloat / missing is_current full-scan trap | A2 | CORRECT (real failure mode) | standard dimensional-modeling caution; the "~160M-row / 10M×3/yr×5yr" figure is an illustrative arithmetic example, internally consistent, not a sourced benchmark |
| Bitemporal (valid time + transaction time) for late-arriving records | A2 | CORRECT | bitemporal modeling canon |
| Train-serve skew: two engines for same feature drift; high offline acc + silent prod degradation; window-boundary/timezone/cancelled-order edges | Both | CORRECT | feature-store / MLOps canon |
| Point-in-time / as-of join leak from single now()-window over full history | A1 (explicit #2), A2 (folded into DIM3 join-side skew) | CORRECT | feature-store canon |
| Airflow 3.2 / Dagster 1.13 / Prefect 3.7 / GE v1.0 / Soda v4 | (skill desc only, NOT in A2's review) | N/A — Airflow 3.2 (Apr 2026) confirmed; others unverified but not used in the answer | — |

**Wrong-claim count: 0 hard-wrong specifics in either answer.** A2 has one minor source-attribution imprecision (2–1,000x is ACORN-paper, presented as Weaviate's figure) and one unverified-but-plausible micro-benchmark pair (3.89s/365.71s). Neither is a falsified claim. A1 contains no specific numbers/versions at all, so it has zero exposure to wrong-specific risk and also zero credit for correct-specifics.

---

## Substantive coverage

Both answers nail the same five core defects, and both are genuinely strong:
1. Train-serve skew on the doubly-computed 30-day count → single governed definition.
2. Point-in-time leak (now()-window + Type-1 dimension) → as-of join.
3. SCD Type 1 overwrite destroys the attribute-at-event-time → Type 2.
4. Tenant post-filter = recall starvation + isolation/security weakness → pre-filter/partition.
5. Filtered-HNSW selectivity → recall cliff; embedding-only → add lexical + RRF.

**Where they differ:**

- **A1** adds a sharper *security framing* on tenant isolation ("cross-tenant data read into the query path before filtering; one logging line / one reranker that sees pre-filter results → leak"), and explicitly argues tier/region arguably should NOT gate retrieval at all (soft signal vs hard partition) — a genuinely insightful design call A2 doesn't make as crisply. A1 also flags the missing-key dedup edge (Pandas groupby drops NaN keys) which A2 doesn't.

- **A2** adds three correct dimensions A1 misses entirely: (a) **engine choice** — Pandas over 40GB is the wrong tool, with quantified DuckDB/Polars alternatives and a correct out-of-core ceiling; (b) the **SCD Type-2 bloat/`is_current` scan trap** that the Type-1→Type-2 fix itself introduces (second-order consequence A1 never reaches); (c) **missing-field trap** at ingestion (docs lacking tenant_id silently dropped by pre-filter) and **late-arriving records / bitemporal** modeling. A2 also names ACORN specifically with the correct selectivity-fallback behavior, whereas A1 stays at "check whether your DB does filtered-HNSW vs brute-force."

- A2 is more actionable (per-rule IDs, P0/P1/P2 severity, an architecture decision log, tool+version recommendations, a CI guard script). A1 is more readable and slightly better at the *isolated* security argument and priority narrative.

**Verbosity check:** A2's win is NOT verbosity. Its extra length carries *additional correct, verified, load-bearing content* (engine selection, second-order bloat trap, ingestion missing-field trap, bitemporal) that A1 simply does not contain. Every extra A2 section maps to a real, verifiable pipeline risk for THIS pipeline. A1 is tight and correct but covers a strict subset of A2's ground (minus A1's security-framing edge and the NaN-key note).

---

## Scores (1–5)

| Dimension | A1 | A2 |
|-----------|----|----|
| Correctness | 5 | 5 |
| Actionability | 4 | 5 |
| Specificity | 3 | 5 |
| Completeness | 4 | 5 |

A1 correctness 5: no wrong claims; everything stated is accurate. A1 specificity 3: deliberately avoids numbers/versions — safe but leaves quantified guidance on the table.
A2 correctness 5: all hard specifics verified true; the two soft spots (ACORN attribution, one micro-benchmark pair) are not falsifiable errors. A2 specificity/completeness 5: quantified, version-pinned, scoped correctly to the task (no orchestrator over-recommendation), and catches second-order failure modes.

---

## Verdict

**Winner: Answer 2. Margin: clear.**

Both answers are correct and would help the user. A2 wins on a foundation of *verified correct specifics* (DuckDB ~27TB out-of-core, Polars SF-100 OOM, ACORN 2–1,000x/Weaviate 1.27/flat-scan fallback, RRF k=60∈[40,80]) plus three additional real risk classes A1 never reaches (wrong compute engine, the Type-2 bloat trap its own fix creates, ingestion missing-field + late-arriving/bitemporal). This is the signature of domain-pack assistance: not more words, but more *correct, quantified, second-order* coverage with citations.

A1's one genuine edge — the crisp "post-filter is a security boundary, not just inefficiency" argument and the suggestion that tier/region maybe shouldn't gate retrieval — keeps this from being decisive. A2 also covers tenant isolation as a security issue, just less vividly.

Not a tie because A2 strictly dominates on specificity and completeness while matching on correctness, and its extra material is verified true rather than padding.

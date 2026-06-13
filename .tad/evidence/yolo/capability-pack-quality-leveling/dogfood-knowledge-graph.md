# Dogfood Judgment — Knowledge Graph / GraphRAG Plan Review

Task: Review a plan to build full Microsoft GraphRAG over 40k internal docs (mostly single-fact lookups), extract every entity, skip dedup, store in Kuzu, use Global search for everything.

One answer used the `knowledge-graph` capability pack; one did not. Judged purely on merit.

## WebSearch verification of load-bearing specifics

| Claim | Answer | Verdict |
|---|---|---|
| Kuzu acquired by Apple, repo archived ~2025-10 | A1 | CORRECT — deal Oct 9 2025, GitHub repo archived Oct 10 2025; website removed. Community fork exists. |
| LazyGraphRAG ~0.1% indexing cost, 700x lower query cost, matches Global quality | both | CORRECT — Microsoft Research blog: indexing identical to vector RAG = 0.1% of full GraphRAG; >700x lower query cost at comparable global quality. |
| Full Microsoft GraphRAG large-corpus indexing ~ $33K (2024) | A1 | CORRECT/corroborated — "GraphRAG cost cliff: $33,000 → $33" (Medium/Graph Praxis) tracks this figure. |
| GraphRAG outputs Parquet + LanceDB default vector store; NO graph DB required | A2 | CORRECT — Microsoft Research "Moving to GraphRAG 1.0"; LanceDB is the default embedded vector store; pipeline runs with no external graph DB. This is the single most decisive correct fact in either answer. |
| FalkorDB p99 136ms vs Neo4j 46,924ms on Pokec; 22,784 rows/s bulk @ batch 5k | A1 | CORRECT (vendor-published) — matches FalkorDB benchmark repo/blog. A1 correctly labels these vendor numbers and says validate on own data. |
| GraphRAG-Bench (ICLR'26), flat wins single-fact / graph wins multi-hop aggregation | A1 | CORRECT — arXiv 2506.02404, official repo "(ICLR'26)". Directional finding confirmed (NaiveRAG competitive single-fact; graph wins multi-fact aggregation). |
| "Novel-domain best 60.92%" exact figure | A1 | UNVERIFIED-SPECIFIC — could not pin exact number to primary source; directionally plausible. Minor risk, not a clear error. |

No outright WRONG specifics found in either answer. Both are unusually well-calibrated.

## Scoring

### Answer 1 (pack-style, ARC/GDB/ER rule citations)
- Correctness 5 — every checkable specific verified true; vendor numbers honestly labeled; only soft spot is the unverified 60.92%.
- Actionability 4 — strong fixes (two-path arch, LazyGraphRAG, ER2 pipeline, governed merges, route by intent), but somewhat rule-citation-heavy ("Rule ARC7", "GDB1") which reads as internal-jargon to an external operator.
- Specificity 5 — densest correct specifics: cost tiers, benchmark numbers, ER pipeline params (S-BERT, k-means n/128, top-K=16), DB latency figures.
- Completeness 4 — covers all four flaws + dedup. MISSES the biggest architectural truth: GraphRAG needs no graph DB at all (Parquet+LanceDB). Treats "pick a graph DB" as legitimate and only re-selects the engine — perpetuating the user's framing error.

### Answer 2 (plain-language, mechanism-first)
- Correctness 5 — all specifics correct; nails the Parquet/LanceDB/no-graph-DB fact that A1 missed; correctly explains Global vs Local mechanism (map-reduce over community summaries, lossy on specifics).
- Actionability 5 — concrete buildable plan: router first, hybrid RRF + cross-encoder rerank for the 95%, LazyGraphRAG for the 5%, explicit 3-step sequencing ("ship hybrid first, log global queries, add graph only if justified"). An operator can execute this directly.
- Specificity 4 — fewer hard numbers than A1 (no benchmark figures), but the specifics it gives are correct and load-bearing (RRF, cross-encoder top-50, Parquet/LanceDB).
- Completeness 5 — covers all four flaws AND the deeper "you may not need a graph DB at all" insight, AND challenges the user's premise rather than accepting it.

## Winner: Answer 2 — margin: slight

Both answers reach the same correct architecture (two-path: hybrid+rerank for the 95%, LazyGraphRAG for the 5%, never skip dedup, don't default to Kuzu). Both are factually clean. So the decision turns on two things:

1. **Decisive correct insight A1 missed**: Microsoft GraphRAG does not require a graph database — it runs on Parquet + LanceDB. A2 catches that the entire "store it in Kuzu" premise may be a category error (picking a DB for a pipeline that needs none), and only conditionally recommends a graph DB for ad-hoc exploration/concurrency. A1 accepts the graph-DB framing and merely swaps Kuzu→Neo4j/FalkorDB. A1's path would have the user stand up a graph DB they likely don't need. This is the most important correction in the whole task and only A2 makes it.

2. **Actionability**: A2's router-first + explicit ship-then-measure sequencing is directly executable. A1 is heavier on internal rule-IDs (ARC7/GDB1/ER2), which is more impressive as a demonstration of structured knowledge but slightly less usable for an outside operator.

A1 wins on raw specific density (benchmark numbers, ER pipeline params, DB latency) — and that depth is genuinely valuable and all correct. But A2 wins on the one fact that most changes the user's decision, and on actionability. The win is on a CORRECT specific (the no-graph-DB architecture fact), not on verbosity.

Margin is only slight because A1 is not wrong about anything and its added specificity (ER pipeline, cost guardrails, benchmark grounding) has real value; a user who reads both gets the most from A1's depth plus A2's framing correction.

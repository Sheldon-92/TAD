# Pack Dogfood Judgment — knowledge-graph

Task: Review a plan to build full Microsoft GraphRAG over 40K internal docs (mostly single-fact lookups), extract every entity, skip dedup, store in Kuzu, use Global search for everything.

## Verdict: Answer 1 wins — clear margin

Both answers reach the SAME correct diagnosis (5 compounding errors). The differentiator is verified-correct, load-bearing specificity. Answer 1 backs every claim with a benchmark number/source that WebSearch confirms correct; Answer 2 is correct but hedges on exactly the specifics Answer 1 nails. No wrong specifics found in either — Answer 1 wins on CORRECT specifics, not verbosity.

## WebSearch verification of specific claims

| Claim | Answer | Verdict |
|---|---|---|
| Kuzu GitHub repo archived after Apple acquisition (Oct 2025) | A1 (definite), A2 (hedged "uncertain") | CORRECT — repo archived 2025-10-10, Apple acquisition confirmed via EU DMA filing |
| GraphRAG default = Parquet + embedded LanceDB, no graph DB | A1 (definite), A2 (LanceDB default, definite) | CORRECT — LanceDB is default vector store; no graph DB as default storage; Neo4j is a requested-feature/optional add-on |
| GraphRAG-Bench Novel Fact Retrieval: RAG+rerank 60.92 > HippoRAG2 60.14 (arXiv 2506.05690) | A1 only | CORRECT — exact figures verified |
| LazyGraphRAG indexing = 0.1% of full GraphRAG (= vector RAG), >700x lower query cost | A1 (both numbers), A2 (qualitative only) | CORRECT — verified vs Microsoft Research blog |
| ~$33K full GraphRAG indexing on ~5GB legal corpus | A1 (flagged "secondary-source") | CORRECT — matches the "$33,000 → $33" Graph Praxis secondary source; honestly hedged |
| Global = map-reduce over community report levels; Local = entity-specific 1-2 hop | A1 + A2 | CORRECT — matches GraphRAG docs |
| LightRAG cheaper indexing / dual-level / incremental | A2 only | CORRECT (consistent with LightRAG positioning) |

**Wrong specifics found: NONE in either answer.** Both are factually clean. A1 simply commits to more verifiable specifics and they all check out.

## Scoring

### Answer 1
- Correctness 5 — every specific verified; appropriately hedges the one secondary-source figure ($33K)
- Actionability 5 — concrete two-tier arch, routing rule, ER pipeline (S-BERT→k-means→fused BM25+vector top-K=16→LLM), governed-merge bands, explicit "no graph DB" decision
- Specificity 5 — benchmark numbers, exact cost ratios, default-pipeline config keys (output.type=file, vector_store.type=lancedb)
- Completeness 5 — covers all 5 errors + cost guardrails, selective extraction, ontology-at-extraction, P0/P1/P2 triage

### Answer 2
- Correctness 5 — no wrong specifics; ends with an honest caveat to verify model-dependent costs and Kuzu status
- Actionability 5 — clear "what I'd build" tiering, router heuristic, eval harness, incremental-update story (a dimension A1 under-weights)
- Specificity 3 — strong on mechanism, weak on numbers; "many dollars to low-thousands," "more than X" stay qualitative where A1 cites exact figures
- Completeness 4 — adds eval+incremental-update (good), but lighter on entity-resolution mechanics and the "default GraphRAG needs NO graph DB at all" category-error framing (A2 says vector index is load-bearing, which is right, but doesn't state the default pipeline ships no graph DB)

## Rationale
Tie on correctness (both clean, zero wrong specifics) and actionability. A1 wins decisively on specificity: it stakes claims on exact, WebSearch-confirmed numbers (60.92 vs 60.14; 0.1%; 700x; archived-repo date; default config keys) and is right on all of them — this is the hallmark of pack-grounded depth, not verbosity. A2 is an excellent generalist answer that correctly hedges where it lacks the numbers (intellectually honest, and it uniquely raises the incremental-update operational cost). But "GraphRAG default needs no graph DB at all" (the cleanest refutation of the Kuzu premise) and the benchmark-backed "flat rerank actually beats graph on fact retrieval" are sharper in A1. Winner on correct specifics.

Margin: clear (not decisive — A2 is genuinely strong and adds eval+incremental angles A1 underweights).

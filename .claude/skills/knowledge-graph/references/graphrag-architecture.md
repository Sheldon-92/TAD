# GraphRAG Architecture & Search Rules
<!-- capability: graphrag_architecture -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| ARC0 | Microsoft GraphRAG needs NO graph database by default — it writes Parquet + LanceDB. A graph DB is an OPTIONAL downstream add-on, not a pipeline dependency | deterministic |
| ARC1 | Architecture selection: full GraphRAG vs LazyGraphRAG vs LightRAG by data volatility + cost | deterministic |
| ARC2 | Indexing pipeline order is fixed: chunk → extract → finalize → Leiden → community reports → embed | deterministic |
| ARC3 | Default chunk size is 1,200 tokens; gleanings = multi-pass extraction for recall | semi-deterministic |
| ARC4 | Leiden is hierarchical (Level 0 broad → higher specific); `resolution` γ (default 1.0) controls community granularity | deterministic |
| ARC5 | Search paradigm: Global (Map-Reduce), Local (1-2 hop), Drift (agentic) — match to query intent | semi-deterministic |
| ARC6 | Community context overflow → Hierarchical Substitution then Trimming, never raw truncation | deterministic |
| ARC7 | Graph-vs-flat decision threshold: don't reflex-pick GraphRAG — flat RAG still wins single-fact + high-coverage summary | deterministic |

---

## Rules

### ARC0: Microsoft GraphRAG Requires NO Graph Database by Default (Storage Precedes Engine)

**The single most common framing error: "we'll build GraphRAG, which graph database should we store it in?"** That question is a category error for the default Microsoft GraphRAG pipeline. **Resolve storage BEFORE engine selection** — most of the time there is no graph DB to select.

When someone proposes "build GraphRAG and store it in [Neo4j / Kuzu / FalkorDB / any graph DB]", first establish what the pipeline actually emits:

| Layer | Microsoft GraphRAG default | Config key |
|-------|----------------------------|-----------|
| **Knowledge artifacts** | **Parquet files on the local filesystem** (entities, relationships, communities, community reports, text units) | `output: type` — default `file` (also `memory` / `blob` / `cosmosdb`) |
| **Vector store** | **LanceDB, embedded, written locally alongside the Parquet artifacts** | `vector_store: type` — default `lancedb` (also `azure_ai_search` / `cosmosdb`) |
| **Graph database** | **NONE.** No graph-DB option exists anywhere in the storage or vector_store config. The standard `graphrag index` + `graphrag query` pipeline runs end-to-end with zero external graph DB. | — (no such key) |

The GraphRAG 1.0 refactor consolidated embeddings into the vector store and reported **80% Parquet disk savings and 43% total disk reduction** by removing redundant embedding copies from the Parquet output. Global/Local/Drift search all run directly over the Parquet + LanceDB artifacts.

**When you DO add a graph database (it is a downstream add-on, never a dependency):**

- **Visualization / ad-hoc Cypher exploration / GDS algorithms** over the extracted graph. The standard path is: run the default Parquet pipeline first, then *import* the Parquet output into Neo4j (Neo4j publishes the import writeup: "These parquet files can be easily imported into the neo4j graph database for downstream analysis, visualization, and retrieval").
- **High-concurrency / multi-user serving** of graph queries where an embedded LanceDB local store is insufficient.
- **You already operate a graph DB** and want one storage substrate.

If none of those apply, **adding a graph DB is pure operational overhead** — you stand up, secure, and pay for an engine the pipeline never asked for. The deprecated-engine debate (Kuzu vs FalkorDB, GDB1) only begins *after* ARC0 establishes that a graph DB is actually wanted; do not skip ARC0 and jump straight to "which engine."

**Anti-pattern**: accepting "store GraphRAG in <graph DB X>" and merely re-selecting the engine (Kuzu→Neo4j). That perpetuates the category error. The senior move is to surface that the default pipeline is Parquet + LanceDB and make the graph DB *conditional* on a stated visualization/concurrency need.

> Source (refreshed): Microsoft Research — "Moving to GraphRAG 1.0: streamlining ergonomics" — https://www.microsoft.com/en-us/research/blog/moving-to-graphrag-1-0-streamlining-ergonomics-for-developers-and-users/ (retrieved 2026-06-14), section "Streamlined vector stores": LanceDB default written locally alongside artifacts; 80% parquet / 43% total disk reduction. Config keys: GraphRAG official YAML config — https://microsoft.github.io/graphrag/config/yaml/ (retrieved 2026-06-14), "Outputs and Storage": `output.type` default `file` (file|memory|blob|cosmosdb); `vector_store.type` default `lancedb` (lancedb|azure_ai_search|cosmosdb) — no graph-DB option exists. Neo4j import path (downstream add-on): Neo4j — "Microsoft GraphRAG into Neo4j" by Tomaž Bratanič — https://neo4j.com/blog/developer/microsoft-graphrag-neo4j/ (retrieved 2026-06-14): "These parquet files can be easily imported into the neo4j graph database for downstream analysis, visualization, and retrieval." ⚠️ The former Microsoft community-contrib import notebook (`examples_notebooks/community_contrib/neo4j/graphrag_import_neo4j_cypher.ipynb`) was REMOVED from `microsoft/graphrag` main in the 2026-01 V3 refactor — cite the Neo4j blog, not a microsoft/graphrag main-branch path (it 404s).

**determinismLevel**: deterministic — a fixed fact about the default pipeline's storage contract.

### ARC1: Architecture Selection by Volatility and Cost

When choosing a GraphRAG architecture, decide on data volatility and budget — NOT on which is "most standard":

| Choose | When | Why (from research) |
|--------|------|---------------------|
| **Microsoft GraphRAG** (Leiden) | Static/batch corpus, broad global "synthesize the themes" queries, high-performance offline indexing | Deep semantic synthesis but extremely high upfront LLM pre-summarization cost. Best on Neo4j for large historical graphs. |
| **LazyGraphRAG** | Large or volatile corpus, cost-sensitive, dynamic communities at query time | Replaces LLM pre-summarization with lightweight NLP (noun-phrase + co-occurrence). Indexing cost is **identical to vanilla vector RAG = 0.1% of full GraphRAG indexing** (Microsoft's exact phrasing — see honesty note below). Matches full GraphRAG global-search quality at **>700x lower query cost**; and at **4% of GraphRAG global-search query cost it significantly outperforms all competing methods**. |
| **LightRAG** | Frequently-updated corpus, low retrieval-overhead budget | Dual-level KV index; **<100 tokens for the retrieval keyword-generation step in the LightRAG-reported setup** (total per-query cost still includes retrieved context + answer generation); incremental updates touch only affected nodes/relationships (no full rebuild). |

**Absolute cost anchor (so the agent has a magnitude prior, not only relative multipliers):** full GraphRAG indexing of a **large corpus cost ~$33K in 2024** (≈5 GB legal-case dataset). LightRAG / LazyGraphRAG-class methods cut that by **~100x** while preserving multi-hop accuracy. **LazyGraphRAG** specifically: indexing cost identical to vanilla vector RAG (**0.1% of full GraphRAG indexing**), comparable global-query quality, **>700x lower query cost** (96/96 win rate vs alternatives, nearly all statistically significant), and at **4% of GraphRAG global-search query cost it beats all competing methods**. Use the **$33K@2024-large-corpus** figure as the order-of-magnitude alarm before greenlighting a full build.

> ⚠️ **Honesty / source-fidelity notes (do not overstate):** (1) Microsoft's blog states LazyGraphRAG indexing is "**0.1% of the costs of full GraphRAG**" — it does NOT use the phrase "**99.9% reduction**" (the two are arithmetically equal, but quote the 0.1% figure, not a "99.9%" Microsoft attribution). (2) The **$33K@2024** number is a **secondary-source / practitioner** figure (Graph Praxis / Medium tracking one ~5 GB legal dataset), **not** a Microsoft-published number — present it as an order-of-magnitude prior, not a vendor guarantee.

> ⚠️ **Old-patterns / version timeline (time-sensitive — isolate from the rules above):** Microsoft GraphRAG version line: first release **2024-04** → **DRIFT search 2024-10** → **GraphRAG 1.0 2024-12** → **LazyGraphRAG 2025-06**. Workflow/API names and cost ratios are version-pinned; verify against the installed version before hardcoding. These dated figures are deprecated the moment a newer release lands — re-check before quoting.

> Source: findings.md §"Alternative Architectures" + §"Strategic Syntheses" — LazyGraphRAG indexing 0.1% of full GraphRAG & >700x cheaper global queries [19, 21]; LightRAG <100 tokens for the retrieval keyword-generation step (LightRAG-reported setup; NOT total per-query cost) & incremental updates [18, 23, 24]. Cost ratios (refreshed, primary): Microsoft Research — "LazyGraphRAG: setting a new standard for quality and cost" — https://www.microsoft.com/en-us/research/blog/lazygraphrag-setting-a-new-standard-for-quality-and-cost/ (retrieved 2026-06-14): exact quotes "data indexing costs are identical to vector RAG and **0.1% of the costs of full GraphRAG**", "more than **700 times lower query cost**", "for **4% of the query cost** of GraphRAG global search, LazyGraphRAG significantly outperforms all competing methods", 96/96 win rate. The "**99.9%**" phrasing is NOT in this source (= 0.1% restated). The **$33K@2024** anchor is secondary-source: Graph Praxis — "The GraphRAG Cost Cliff: How $33,000 Became $33" — https://medium.com/graph-praxis/the-graphrag-cost-cliff-how-33-000-became-33-in-eighteen-months-be1b0fbe37e4 (retrieved 2026-06-14), one ~5 GB legal dataset; NOT a Microsoft figure.

**determinismLevel**: deterministic — architecture is an upfront design decision.

### ARC2: Fixed Indexing Pipeline Order

When building a Microsoft GraphRAG index, the pipeline stages run in this exact order — skipping or reordering breaks downstream search:

```
create_base_text_units (1200-token chunks)
  → create_final_documents (doc → text-unit registry)
  → extract_graph (NER + relation extraction + gleanings)
  → finalize_graph (NetworkX; node degrees + edge weights)
  → create_communities (Leiden clustering)
  → create_community_reports (hierarchical substitution / trimming)
  → generate_text_embeddings (text units, entity descriptions, community reports)
```

Workflow step names are version-specific (current Microsoft GraphRAG uses `generate_text_embeddings` for the embedding stage); pin the GraphRAG version and verify exact workflow names against the installed version before hardcoding them into configs.

The `extract_graph` module records the **exact occurrence frequency** of each entity across the corpus; raw occurrences are consolidated into a single representation downstream (this is why entity resolution matters — see entity-resolution.md).

> Source: findings.md §"Microsoft GraphRAG Indexing" pipeline diagram + §1-4 [14].

**determinismLevel**: deterministic — the pipeline DAG is fixed.

### ARC3: Chunk Size and Gleanings

When configuring extraction, the Microsoft GraphRAG **verified defaults** (from `defaults.py` in the repo, not invented) are:

| Config key | Default | Notes |
|------------|---------|-------|
| `chunks.size` | **1,200 tokens** | `ChunkingDefaults.size = 1200` — do not change without a measured reason |
| `chunks.overlap` | **100 tokens** | `ChunkingDefaults.overlap = 100` — overlap preserves cross-boundary entities/relations |
| `extract_graph.max_gleanings` | **1** | `ExtractGraphDefaults.max_gleanings = 1` — i.e. ONE extra glean pass by default, NOT unlimited |

- **Gleanings** = additional extraction passes (default 1) to maximize factual recall by re-prompting the model to find entities/relations missed on the first pass. Each extra pass roughly re-runs extraction → token-intensive; deploy a cheaper model (e.g. a small/mini model) for the gleaning passes, and raise `max_gleanings` only on hard, dense text where recall measurably improves.
- The default `max_gleanings = 1` is a deliberate cost/recall balance — agents that assume "gleaning runs until convergence" overbudget; it's a fixed pass count you set.

> Source: findings.md §1 "Ingestion, Chunking, and Extraction" — 1,200-token default [14], gleaning cost mitigation [15]. Verified defaults (refreshed, primary): microsoft/graphrag `config/defaults.py` — https://github.com/microsoft/graphrag/blob/main/packages/graphrag/graphrag/config/defaults.py (retrieved 2026-06-14): `ChunkingDefaults.size=1200`, `ChunkingDefaults.overlap=100`, `ExtractGraphDefaults.max_gleanings=1`; key documentation at https://microsoft.github.io/graphrag/config/yaml/ (retrieved 2026-06-14), `chunks` + `extract_graph` subsections.

**determinismLevel**: semi-deterministic — chunking is fixed; gleaning recall varies by pass.

### ARC4: Edge Importance and Hierarchical Community Levels

When reasoning about which entities/edges matter:

- **Combined Degree of an edge = Degree(u) + Degree(v)** (sum of source and target node degrees). High-combined-degree edges are key topological bridges.
- Leiden partitions the graph into a **multi-layered hierarchy**:
  - **Level 0 (root):** broad, generic parent communities — large entity counts, high-level domains
  - **Higher levels (e.g. Level 3):** specific, localized sub-communities / micro-domains
- Pick the Leiden **level** to match query breadth: broad "summarize the field" → low level; specific sub-topic → higher level.
- Community reports carry a numerical **importance rank (1 to 10)** plus a rating explanation.

**The Leiden `resolution` parameter (γ) is the knob that controls community granularity — tune it, don't accept the default blindly:**

- **Default `resolution_parameter = 1.0`** (in both `leidenalg` `RBConfigurationVertexPartition` / `CPMVertexPartition` and igraph `cluster_leiden`). The original Leiden paper (Traag, Waltman & van Eck 2019) ran experiments at **γ = 1**.
- **Directional rule (exact igraph wording):** "*Higher resolutions lead to more smaller communities, while lower resolutions lead to fewer larger communities.*" So if your community reports are too coarse (each lumps unrelated topics) → **raise** resolution; if they're too fragmented → **lower** it.
- ⚠️ **Library-specific default**: `leidenalg` and igraph `cluster_leiden` default to **1.0**, but some wrappers differ (e.g. R's `leidenbase` defaults to **0.1**). State the library when you quote a default.

> Source: findings.md §2-4 — Combined Degree formula [14], Level 0 vs Level 3 hierarchy [12, 14], importance rank 1-10 [14]. Leiden resolution (refreshed, primary): leidenalg reference — https://leidenalg.readthedocs.io/en/stable/reference.html (retrieved 2026-06-14, `resolution_parameter=1.0` default); igraph `cluster_leiden` — https://r.igraph.org/reference/cluster_leiden.html (retrieved 2026-06-14, "The default resolution parameter is 1" + the higher/lower directional quote); Traag, Waltman & van Eck 2019, "From Louvain to Leiden", Scientific Reports — https://www.nature.com/articles/s41598-019-41695-z (retrieved 2026-06-14, γ=1 experiments).

**determinismLevel**: deterministic — degree math and level structure are fixed.

### ARC5: Search Paradigm Selection

When routing a query, pick the search paradigm by intent:

| Paradigm | Mechanism | Use For | Cost | Limitation |
|----------|-----------|---------|------|-----------|
| **Global Search** | Parallel **Map-Reduce over entire community-report levels**. Map step runs `MATCH (c:__Community__) WHERE c.level = $level RETURN c.full_content AS output`; each batch gets a **helpfulness score 0-100**; score-0 answers filtered immediately; survivors sorted + packed for the Reduce step. | Summarizing broad themes, comparative/global trend questions | High (processes massive text in parallel) | Prohibitively expensive; ignores granular edge details |
| **Local Search** | Semantic vector search over **entity embeddings** → nearest-neighbor seed nodes → traverse adjacent edges to pull related nodes, relationships, text units, community summaries | Entity-driven, localized factual queries | Low (narrow sub-graph) | Cannot synthesize broad cross-document themes |
| **Drift Search** | Agentic multi-stage: **Primer** (compare query vector to community-report embeddings, top-K reports → broad answer + follow-up questions) → **Follow-Up** (route follow-ups through local retrievers, each expansion gated by a confidence metric) → **Output Hierarchy** (re-rank + consolidate) | Hybrid: broad context mapped to precise local facts | Moderate-High (balanced by confidence pruning) | High latency from iterative loops; complex prompt config |

**Anti-pattern**: defaulting to Global search for every query. Entity-specific questions belong in Local search at a fraction of the cost.

**Method-tier selection by task type (no single method wins all tiers — GraphRAG-Bench, ICLR'26, Novel + Medical domains, 4 difficulty tiers: fact retrieval → complex reasoning → contextual summarization → creative generation).** Pick the retrieval/graph method by the *task tier*, not by which is "most advanced":

| Task tier | Novel-domain best | Medical-domain signal |
|-----------|-------------------|------------------------|
| **Single-fact retrieval** | RAG **with rerank** — **60.92%** (flat reranked RAG, not a graph method) | base RAG competitive |
| **Complex / multi-hop reasoning** | **HippoRAG2** — **53.38%**; HippoRAG hits **87.9–90.9%** evidence recall on L2–L3 multi-hop | **HippoRAG2 61.98%** > base RAG **58.64%** |
| **Contextual summarization** | **MS-GraphRAG** (community summaries) — **64.40%** | community-style GraphRAG strongest at summarization |
| **Creative generation** | **HippoRAG** faithfulness **71.53%** | **LightRAG** creative faithfulness **78.76%** |

Structural takeaway: **hierarchical / densely-connected** structures (**RAPTOR**, **HippoRAG**) are strongest overall; **community-style GraphRAG** (Microsoft GraphRAG) dominates **summarization**; **PageRank-style HippoRAG** dominates **multi-hop**. There is **no method that wins every tier** — route by tier.

> Source: findings.md §"Algorithmic Traversal" + comparison table — Map-Reduce + helpfulness 0-100 + score-0 filter [12, 13], Local 1-2 hop [13, 17], Drift primer/follow-up/output with confidence pruning [16, 17]. Method-tier table (refreshed): "When to use Graphs in RAG" / GraphRAG-Bench — https://arxiv.org/abs/2506.05690 (retrieved 2026-06-13), **Table 2 (Generate Evaluation), Novel dataset, Fact Retrieval column**: RAG (w rerank) ACC = **60.92** (next-best HippoRAG2 60.14; GraphRAG-local 49.29) — flat reranked RAG wins single-fact. Other tiers (same paper): reasoning 53.38% (HippoRAG2), summarize 64.40% (MS-GraphRAG), creative 71.53% (HippoRAG); Medical LightRAG creative 78.76%, HippoRAG2 reasoning 61.98% vs base 58.64%; HippoRAG L2–L3 recall 87.9–90.9%.

**determinismLevel**: semi-deterministic for Global/Local (fixed mechanism, LLM scoring varies); non-deterministic for Drift (agentic confidence loop).

### ARC6: Community Context Overflow Handling

When a community's raw node/relationship lists exceed the LLM's max input token limit, reduce in this order — never raw-truncate:

1. **Hierarchical Substitution:** replace a parent community's raw data with the pre-generated reports of its nested sub-communities. Substitute the **largest sub-communities first** for maximum token reduction.
2. **Trimming:** if still too large, sort entities by **node degree** and relationships by **combined degree**, discarding the lowest-ranking elements until the context fits.

> Source: findings.md §4 "Community Report Generation and Context Management" — hierarchical substitution (largest-first) + degree-sorted trimming [14].

**determinismLevel**: deterministic — the reduction order is fixed.

### ARC7: Graph-vs-Flat Decision Threshold (Don't Reflex-Pick GraphRAG)

When "knowledge graph" / "GraphRAG" appears, do NOT reflexively build a graph pipeline. **GraphRAG-Bench** (ICLR'26) measured graph vs flat NaiveRAG across difficulty tiers and found the advantage is **concentrated, not universal**:

| Task shape | First choice | Why |
|------------|--------------|-----|
| **Multi-hop aggregation / cross-document reasoning** | **Graph methods** (HippoRAG, MS-GraphRAG) | graph clearly wins — HippoRAG **87.9–90.9% evidence recall** on L2–L3 multi-hop; flat RAG cannot chain the hops |
| **Single-fact retrieval** | **Flat NaiveRAG / reranked RAG first** | flat stays competitive (Novel-dataset Fact Retrieval ACC: RAG+rerank **60.92** vs best graph method HippoRAG2 60.14, GraphRAG-local 49.29 — Table 2); the graph build buys little |
| **High-coverage / summary recall** | **Flat RAG first** | broader context coverage → higher recall; evaluate flat before paying graph indexing cost |

**Rule**: before building GraphRAG, classify the dominant query shape. If it's **single-fact** or **high-coverage summary**, benchmark **flat RAG first** — only commit to graph when the workload is **multi-hop aggregation**. Pairs with the cross-cutting cost rule: graph indexing cost is only justified where graph retrieval measurably wins.

**Anti-pattern**: building full GraphRAG for a single-fact lookup task — you pay extraction + Leiden + community-report cost for a job a reranked flat retriever does at **60.92%** with no graph build.

> Source (refreshed): "When to use Graphs in RAG" / GraphRAG-Bench — https://arxiv.org/abs/2506.05690 (retrieved 2026-06-13), **Table 2, Novel dataset, Fact Retrieval column** (RAG w/rerank ACC 60.92 > all graph methods): graph wins on multi-hop (HippoRAG L2–L3 evidence recall 87.9–90.9%); flat NaiveRAG/reranked RAG competitive on single-fact retrieval + summary recall (broader context coverage → higher recall).

**determinismLevel**: deterministic — a task-shape classification + threshold decision.

---

## Anti-Patterns

- **"Which graph DB do we store GraphRAG in?" as the first question**: a category error — the default Microsoft GraphRAG pipeline stores Parquet + LanceDB and needs no graph DB (ARC0). Resolve storage before engine; only add a graph DB for a stated visualization/concurrency need.
- **Reflexive full GraphRAG**: paying complete LLM pre-summarization when LazyGraphRAG matches global quality at >700x lower query cost.
- **Global-search-for-everything**: running Map-Reduce over whole community levels for a question one Local 1-hop traversal would answer.
- **Raw context truncation**: chopping community text to fit the window instead of Hierarchical Substitution → Trimming, losing the highest-degree bridges.
- **Ignoring the Leiden level knob**: querying Level 0 for a micro-topic (too broad) or a high level for a field summary (too narrow).
- **Reflexive GraphRAG on single-fact / summary tasks**: building extraction + Leiden + community reports when a reranked flat RAG (Novel fact best 60.92%) wins at near-zero index cost — graph's edge is multi-hop aggregation (HippoRAG 87.9–90.9% recall), not single-fact lookup.

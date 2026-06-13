# GraphRAG Architecture & Search Rules
<!-- capability: graphrag_architecture -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| ARC1 | Architecture selection: full GraphRAG vs LazyGraphRAG vs LightRAG by data volatility + cost | deterministic |
| ARC2 | Indexing pipeline order is fixed: chunk → extract → finalize → Leiden → community reports → embed | deterministic |
| ARC3 | Default chunk size is 1,200 tokens; gleanings = multi-pass extraction for recall | semi-deterministic |
| ARC4 | Leiden is hierarchical: Level 0 broad, higher levels specific — pick the level for query breadth | deterministic |
| ARC5 | Search paradigm: Global (Map-Reduce), Local (1-2 hop), Drift (agentic) — match to query intent | semi-deterministic |
| ARC6 | Community context overflow → Hierarchical Substitution then Trimming, never raw truncation | deterministic |
| ARC7 | Graph-vs-flat decision threshold: don't reflex-pick GraphRAG — flat RAG still wins single-fact + high-coverage summary | deterministic |

---

## Rules

### ARC1: Architecture Selection by Volatility and Cost

When choosing a GraphRAG architecture, decide on data volatility and budget — NOT on which is "most standard":

| Choose | When | Why (from research) |
|--------|------|---------------------|
| **Microsoft GraphRAG** (Leiden) | Static/batch corpus, broad global "synthesize the themes" queries, high-performance offline indexing | Deep semantic synthesis but extremely high upfront LLM pre-summarization cost. Best on Neo4j for large historical graphs. |
| **LazyGraphRAG** | Large or volatile corpus, cost-sensitive, dynamic communities at query time | Replaces LLM pre-summarization with lightweight NLP (noun-phrase + co-occurrence). Reduces upfront indexing cost by up to **99.9%**. Matches full GraphRAG global-search quality at **700x lower query cost**; outperforms vector RAG on local queries at comparable cost. |
| **LightRAG** | Frequently-updated corpus, low retrieval-overhead budget | Dual-level KV index; **<100 tokens for the retrieval keyword-generation step in the LightRAG-reported setup** (total per-query cost still includes retrieved context + answer generation); incremental updates touch only affected nodes/relationships (no full rebuild). |

**Absolute cost anchor (so the agent has a magnitude prior, not only relative multipliers):** Microsoft's full GraphRAG indexing of a **large corpus cost ~$33K in 2024**. LightRAG / LazyGraphRAG-class methods cut that by **~100x** while preserving multi-hop accuracy. **LazyGraphRAG** specifically: indexing cost on par with vanilla vector RAG (**0.1% of full GraphRAG indexing**), comparable global-query quality, and **700x lower query cost** (96/96 win rate vs alternatives, nearly all statistically significant). Use the **$33K@2024-large-corpus** figure as the order-of-magnitude alarm before greenlighting a full build.

> ⚠️ **Old-patterns / version timeline (time-sensitive — isolate from the rules above):** Microsoft GraphRAG version line: first release **2024-04** → **DRIFT search 2024-10** → **GraphRAG 1.0 2024-12** → **LazyGraphRAG 2025-06**. Workflow/API names and cost ratios are version-pinned; verify against the installed version before hardcoding. These dated figures are deprecated the moment a newer release lands — re-check before quoting.

> Source: findings.md §"Alternative Architectures" + §"Strategic Syntheses" — LazyGraphRAG 99.9% indexing reduction & 700x cheaper global queries [19, 21]; LightRAG <100 tokens for the retrieval keyword-generation step (LightRAG-reported setup; NOT total per-query cost) & incremental updates [18, 23, 24]. Cost anchor + timeline (refreshed): Microsoft Research — LazyGraphRAG: setting a new standard for quality and cost — https://www.microsoft.com/en-us/research/blog/lazygraphrag-setting-a-new-standard-for-quality-and-cost/ (retrieved 2026-06-13): $33K@2024 large-corpus index, ~100x reduction, 0.1% indexing / 700x query cost, 96/96 win rate.

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

When configuring extraction:

- **Default chunk size = 1,200 tokens** for `create_base_text_units`. Do not invent a different default without a measured reason.
- **Gleanings** = a multi-pass extraction configuration to maximize factual recall. Multiple passes are token-intensive; deploy a cheaper model (e.g. `gpt-4o-mini`) for the gleaning passes to mitigate API expenditure.

> Source: findings.md §1 "Ingestion, Chunking, and Extraction" — 1,200-token default [14], gleaning + gpt-4o-mini cost mitigation [15].

**determinismLevel**: semi-deterministic — chunking is fixed; gleaning recall varies by pass.

### ARC4: Edge Importance and Hierarchical Community Levels

When reasoning about which entities/edges matter:

- **Combined Degree of an edge = Degree(u) + Degree(v)** (sum of source and target node degrees). High-combined-degree edges are key topological bridges.
- Leiden partitions the graph into a **multi-layered hierarchy**:
  - **Level 0 (root):** broad, generic parent communities — large entity counts, high-level domains
  - **Higher levels (e.g. Level 3):** specific, localized sub-communities / micro-domains
- Pick the Leiden **level** to match query breadth: broad "summarize the field" → low level; specific sub-topic → higher level.
- Community reports carry a numerical **importance rank (1 to 10)** plus a rating explanation.

> Source: findings.md §2-4 — Combined Degree formula [14], Level 0 vs Level 3 hierarchy [12, 14], importance rank 1-10 [14].

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

- **Reflexive full GraphRAG**: paying complete LLM pre-summarization when LazyGraphRAG matches global quality at 700x lower query cost.
- **Global-search-for-everything**: running Map-Reduce over whole community levels for a question one Local 1-hop traversal would answer.
- **Raw context truncation**: chopping community text to fit the window instead of Hierarchical Substitution → Trimming, losing the highest-degree bridges.
- **Ignoring the Leiden level knob**: querying Level 0 for a micro-topic (too broad) or a high level for a field summary (too narrow).
- **Reflexive GraphRAG on single-fact / summary tasks**: building extraction + Leiden + community reports when a reranked flat RAG (Novel fact best 60.92%) wins at near-zero index cost — graph's edge is multi-hop aggregation (HippoRAG 87.9–90.9% recall), not single-fact lookup.

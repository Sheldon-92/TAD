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

---

## Rules

### ARC1: Architecture Selection by Volatility and Cost

When choosing a GraphRAG architecture, decide on data volatility and budget — NOT on which is "most standard":

| Choose | When | Why (from research) |
|--------|------|---------------------|
| **Microsoft GraphRAG** (Leiden) | Static/batch corpus, broad global "synthesize the themes" queries, high-performance offline indexing | Deep semantic synthesis but extremely high upfront LLM pre-summarization cost. Best on Neo4j for large historical graphs. |
| **LazyGraphRAG** | Large or volatile corpus, cost-sensitive, dynamic communities at query time | Replaces LLM pre-summarization with lightweight NLP (noun-phrase + co-occurrence). Reduces upfront indexing cost by up to **99.9%**. Matches full GraphRAG global-search quality at **700x lower query cost**; outperforms vector RAG on local queries at comparable cost. |
| **LightRAG** | Frequently-updated corpus, ultra-low query token budget | Dual-level KV index; **<100 tokens per standard query**; incremental updates touch only affected nodes/relationships (no full rebuild). |

> Source: findings.md §"Alternative Architectures" + §"Strategic Syntheses" — LazyGraphRAG 99.9% indexing reduction & 700x cheaper global queries [19, 21]; LightRAG <100 tokens/query & incremental updates [18, 23, 24].

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
  → generate_embeddings (text units, entity descriptions, community reports)
```

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

> Source: findings.md §"Algorithmic Traversal" + comparison table — Map-Reduce + helpfulness 0-100 + score-0 filter [12, 13], Local 1-2 hop [13, 17], Drift primer/follow-up/output with confidence pruning [16, 17].

**determinismLevel**: semi-deterministic for Global/Local (fixed mechanism, LLM scoring varies); non-deterministic for Drift (agentic confidence loop).

### ARC6: Community Context Overflow Handling

When a community's raw node/relationship lists exceed the LLM's max input token limit, reduce in this order — never raw-truncate:

1. **Hierarchical Substitution:** replace a parent community's raw data with the pre-generated reports of its nested sub-communities. Substitute the **largest sub-communities first** for maximum token reduction.
2. **Trimming:** if still too large, sort entities by **node degree** and relationships by **combined degree**, discarding the lowest-ranking elements until the context fits.

> Source: findings.md §4 "Community Report Generation and Context Management" — hierarchical substitution (largest-first) + degree-sorted trimming [14].

**determinismLevel**: deterministic — the reduction order is fixed.

---

## Anti-Patterns

- **Reflexive full GraphRAG**: paying complete LLM pre-summarization when LazyGraphRAG matches global quality at 700x lower query cost.
- **Global-search-for-everything**: running Map-Reduce over whole community levels for a question one Local 1-hop traversal would answer.
- **Raw context truncation**: chopping community text to fit the window instead of Hierarchical Substitution → Trimming, losing the highest-degree bridges.
- **Ignoring the Leiden level knob**: querying Level 0 for a micro-topic (too broad) or a high level for a field summary (too narrow).

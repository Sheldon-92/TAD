---
name: graphrag-build-review
description: "Tests cost-architecture cross-cutting rule (LazyGraphRAG 700x / 99.9%) + entity-resolution pipeline + Global/Local search + graph-DB selection on a full-GraphRAG build request"
pack: knowledge-graph
tests_rules:
  - "ARC0 (DECISIVE): default Microsoft GraphRAG = Parquet + LanceDB, needs NO graph DB — 'store it in Kuzu' is a category error, not an engine-swap"
  - "Cross-Cutting Rule: extraction cost scales with document volume (LazyGraphRAG indexing 0.1% of full GraphRAG / >700x query cost / $33K@2024 secondary anchor)"
  - "ARC7: graph-vs-flat threshold — single-fact lookup belongs on flat RAG, not reflex GraphRAG"
  - "ARC5: Global Map-Reduce vs Local 1-2 hop + per-task method tiers (HippoRAG 87.9-90.9% multi-hop recall)"
  - "ARC3/ARC4: verified GraphRAG defaults — chunk 1,200 / overlap 100 / max_gleanings 1 / Leiden resolution γ 1.0"
  - "ER2/ER3: two-stage resolution (k-means 128) + governed SAME_AS merge + NO magic cutoff (Splink publishes none)"
  - "GDB1: Neo4j vs Memgraph (136 B/node) vs FalkorDB by benchmark numbers (p99 136 ms vs 46,924 ms); Neo4j clustering = Enterprise-only"
  - "Deprecated-DB isolation: Kuzu archived (Apple 2025-10) / RedisGraph EOL → FalkorDB"
  - "QT2/QT3: Text2Cypher ~30% blind execution-match → verification + ≤4-iteration self-correction"
min_marker_count: 4
# DISCRIMINATIVE gate: ONLY pack-specific markers — named architectures + the
# specific numbers/thresholds from findings.md + refreshed 2026 primary sources.
# EXCLUDES generic domain nouns (knowledge graph, entity, node, database, GraphRAG)
# and any word from the input scenario. A no-pack control may say "use a knowledge
# graph" but will NOT produce the DECISIVE ARC0 fact ("Parquet + LanceDB, no graph DB
# required", "output.type=file / vector_store.type=lancedb"), nor "0.1% of full GraphRAG
# indexing", "k-means cluster size 128", "helpfulness score 0-100", "SAME_AS edge to a
# human", "2,668 MB JVM heap vs 415 MB", "136 B per node" (Memgraph), "max_gleanings 1",
# "Leiden resolution 1.0", "Splink publishes no fixed cutoff", "Kuzu archived after the
# Apple acquisition", "~30% execution-match", or "HippoRAG 87.9-90.9% evidence recall".
discriminative_pattern: "Parquet|LanceDB|output\\.type|vector_store|no graph (database|DB)|LazyGraphRAG|LightRAG|HippoRAG|MS-GraphRAG|RAPTOR|700x|0\\.1%|99\\.9%|\\$33K|k-means.{0,12}128|SAME_AS|helpfulness score|<100 tokens|2,?668 MB|415 MB|136 ?B|max_gleanings|resolution.{0,6}1\\.0|Splink|136\\.2 ?ms|46,?9[0-9][0-9]|22,?784|6,?693 QPS|60\\.92%|87\\.9|90\\.9|~?30% execution|N ?= ?2F ?\\+ ?1|τ ?= ?0\\.5|Kuzu|RedisGraph|60\\.92|78\\.76"
min_discriminative: 5
---

# Fixture: Full GraphRAG Build Review

## Input Scenario

"We have 40,000 internal documents. Most queries are single-fact lookups ('what was the Q3 revenue figure for product X'), but some ask 'what are the themes across all of this'. Plan: build full Microsoft GraphRAG, extract every entity, skip dedup, store it in **Kuzu** (we heard it's a lightweight embedded option), and use Global search for everything. Review the plan."

## Expected Markers

When an AI agent processes the Input Scenario with the knowledge-graph pack loaded,
the output MUST contain these markers (grep-verifiable):

0. **ARC0 — no-graph-DB category-error catch** [structural, DECISIVE]: catches that default Microsoft GraphRAG stores **Parquet + LanceDB and needs NO graph database**, so "store it in Kuzu" is a category error — not merely the wrong engine. Makes any graph DB CONDITIONAL on a stated visualization/concurrency need, rather than swapping Kuzu→Neo4j.
   grep pattern: `Parquet|LanceDB|no graph (database|DB)|output\.type|vector_store|category error|optional.{0,20}graph (database|DB)`
1. **Cost-architecture cross-cutting rule** [structural]: flags that extraction cost scales with the 40k-document volume and prescribes a cheaper architecture by name + number — with the source-faithful ratio (0.1% indexing / >700x query), not a generic "watch your costs"
   grep pattern: `LazyGraphRAG|LightRAG|700x|0\.1%|\$33K|<100 tokens|document volume`
2. **Graph-vs-flat threshold (ARC7)** [structural]: catches that single-fact lookups should be benchmarked on flat RAG first, not reflex GraphRAG; cites the per-task numbers
   grep pattern: `flat RAG|NaiveRAG|single.?fact|60\.92%|HippoRAG|87\.9|90\.9|multi.?hop`
3. **Search-paradigm correction**: rejects "Global search for everything" and routes entity-specific queries to Local 1-2 hop; cites the Map-Reduce helpfulness score
   grep pattern: `Local search|1.?2.?hop|helpfulness score|Map.?Reduce`
4. **Entity-resolution pipeline**: flags the skipped resolution stage with the specific pipeline numbers AND that no fixed merge cutoff is published
   grep pattern: `entity resolution|k-means.{0,12}128|top.?K.{0,6}16|S-BERT|SAME_AS|Splink`
5. **Deprecated-DB catch** [structural]: flags **Kuzu** as archived (post-2025-10 Apple acquisition) and — only IF a graph DB is warranted — re-selects by benchmark / memory numbers
   grep pattern: `Kuzu|archived|2,?668 MB|415 MB|136 ?B|136\.2 ?ms|46,?9[0-9][0-9]|Memgraph|FalkorDB|N ?= ?2F ?\+ ?1`

At least three markers are [structural] — they verify the agent APPLIED the rule (the no-graph-DB category-error catch + named architecture + caught the deprecated engine), not just named the domain. Marker 0 (ARC0) is the DECISIVE one the prior no-pack control won on; the pack must now produce it.

## Verification Command

```bash
grep -oE 'Parquet|LanceDB|output\.type|vector_store|LazyGraphRAG|LightRAG|HippoRAG|MS-GraphRAG|700x|0\.1%|\$33K|k-means.{0,12}128|SAME_AS|helpfulness score|<100 tokens|2,?668 MB|415 MB|136 ?B|max_gleanings|Splink|136\.2 ?ms|46,?9[0-9][0-9]|22,?784|60\.92%|87\.9|90\.9|~?30% execution|N ?= ?2F ?\+ ?1|τ ?= ?0\.5|Kuzu|RedisGraph|Local search|Leiden' knowledge-graph-fixture-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 5
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ **[DECISIVE]** "default Microsoft GraphRAG writes Parquet files + an embedded LanceDB vector store and requires NO graph database (`output.type=file`, `vector_store.type=lancedb`); 'store it in Kuzu' is a category error — make any graph DB conditional on a visualization/concurrency need" (the ARC0 storage-precedes-engine catch the prior control won on)
- ✅ "LazyGraphRAG matches global-search quality at >700x lower query cost; indexing = 0.1% of full GraphRAG (Microsoft's exact phrasing, NOT '99.9%'); full GraphRAG indexed a ~5 GB corpus for ~$33K@2024 (secondary-source anchor)" (named + quantified cost rule + source-faithful framing)
- ✅ "single-fact lookups belong on flat/reranked RAG (GraphRAG-Bench Novel-dataset Fact Retrieval ACC 60.92, arXiv 2506.05690 Table 2); graph's edge is multi-hop aggregation (HippoRAG 87.9–90.9% evidence recall)" (the ARC7 graph-vs-flat threshold)
- ✅ "k-means cluster size 128 → fused BM25+vector top-K 16" (the entity-resolution pipeline numbers)
- ✅ "SAME_AS edge routed to a human" (the governed-merge threshold rule)
- ✅ "Kuzu's repo was archived after the 2025-10 Apple acquisition — don't pick it; re-select by benchmark (FalkorDB p99 136 ms vs Neo4j 46,924 ms)" (the deprecated-engine isolation rule + refreshed latency number)
- ✅ "Global search runs Map-Reduce with a helpfulness score 0-100" (the named search mechanism)
- ❌ "build a knowledge graph" (restates the input — any agent says this)
- ❌ "extract entities and relationships" (generic domain vocabulary)
- ❌ "consider performance and cost" (generic — no named architecture or number)
- ❌ "Kuzu is an embedded graph database" (restates input; NOT the deprecation catch)
- ❌ "store the graph in a graph database like Neo4j" (accepts the category error — the ARC0 catch is that the default pipeline needs NO graph DB at all)

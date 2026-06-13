---
name: graphrag-build-review
description: "Tests cost-architecture cross-cutting rule (LazyGraphRAG 700x / 99.9%) + entity-resolution pipeline + Global/Local search + graph-DB selection on a full-GraphRAG build request"
pack: knowledge-graph
tests_rules:
  - "Cross-Cutting Rule: extraction cost scales with document volume (LazyGraphRAG 700x / 99.9% / $33K@2024 anchor)"
  - "ARC7: graph-vs-flat threshold — single-fact lookup belongs on flat RAG, not reflex GraphRAG"
  - "ARC5: Global Map-Reduce vs Local 1-2 hop + per-task method tiers (HippoRAG 87.9-90.9% multi-hop recall)"
  - "ER2/ER3: two-stage resolution (k-means 128) + governed SAME_AS merge"
  - "GDB1: Neo4j vs Memgraph vs FalkorDB by benchmark numbers (p99 136 ms vs 46,924 ms)"
  - "Deprecated-DB isolation: Kuzu archived (Apple 2025-10) / RedisGraph EOL → FalkorDB"
  - "QT2/QT3: Text2Cypher ~30% blind execution-match → verification + ≤4-iteration self-correction"
min_marker_count: 4
# DISCRIMINATIVE gate: ONLY pack-specific markers — named architectures + the
# specific numbers/thresholds from findings.md + refreshed 2026 benchmarks.
# EXCLUDES generic domain nouns (knowledge graph, entity, node, database, GraphRAG)
# and any word from the input scenario. A no-pack control may say "use a knowledge
# graph" but will NOT produce "700x lower query cost", "k-means cluster size 128",
# "helpfulness score 0-100", "SAME_AS edge to a human", "2,668 MB JVM heap vs 415 MB",
# "Kuzu archived after the Apple acquisition", "~30% execution-match", or
# "HippoRAG 87.9-90.9% evidence recall".
discriminative_pattern: "LazyGraphRAG|LightRAG|HippoRAG|MS-GraphRAG|RAPTOR|700x|99\\.9%|\\$33K|k-means.{0,12}128|SAME_AS|helpfulness score|<100 tokens|2,?668 MB|415 MB|136\\.2 ?ms|46,?9[0-9][0-9]|22,?784|6,?693 QPS|60\\.92%|87\\.9|90\\.9|~?30% execution|N ?= ?2F ?\\+ ?1|τ ?= ?0\\.5|Kuzu|RedisGraph|60\\.92|78\\.76"
min_discriminative: 5
---

# Fixture: Full GraphRAG Build Review

## Input Scenario

"We have 40,000 internal documents. Most queries are single-fact lookups ('what was the Q3 revenue figure for product X'), but some ask 'what are the themes across all of this'. Plan: build full Microsoft GraphRAG, extract every entity, skip dedup, store it in **Kuzu** (we heard it's a lightweight embedded option), and use Global search for everything. Review the plan."

## Expected Markers

When an AI agent processes the Input Scenario with the knowledge-graph pack loaded,
the output MUST contain these markers (grep-verifiable):

1. **Cost-architecture cross-cutting rule** [structural]: flags that extraction cost scales with the 40k-document volume and prescribes a cheaper architecture by name + number — with the absolute $ anchor, not a generic "watch your costs"
   grep pattern: `LazyGraphRAG|LightRAG|700x|99\.9%|\$33K|<100 tokens|document volume`
2. **Graph-vs-flat threshold (ARC7)** [structural]: catches that single-fact lookups should be benchmarked on flat RAG first, not reflex GraphRAG; cites the per-task numbers
   grep pattern: `flat RAG|NaiveRAG|single.?fact|60\.92%|HippoRAG|87\.9|90\.9|multi.?hop`
3. **Search-paradigm correction**: rejects "Global search for everything" and routes entity-specific queries to Local 1-2 hop; cites the Map-Reduce helpfulness score
   grep pattern: `Local search|1.?2.?hop|helpfulness score|Map.?Reduce`
4. **Entity-resolution pipeline**: flags the skipped resolution stage with the specific pipeline numbers
   grep pattern: `entity resolution|k-means.{0,12}128|top.?K.{0,6}16|S-BERT|SAME_AS`
5. **Deprecated-DB catch** [structural]: flags **Kuzu** as archived (post-2025-10 Apple acquisition) and re-selects by benchmark — p99 / memory numbers
   grep pattern: `Kuzu|archived|2,?668 MB|415 MB|136\.2 ?ms|46,?9[0-9][0-9]|Memgraph|FalkorDB|N ?= ?2F ?\+ ?1`

At least two markers are [structural] — they verify the agent APPLIED the rule (named architecture + number / caught the deprecated engine), not just named the domain.

## Verification Command

```bash
grep -oE 'LazyGraphRAG|LightRAG|HippoRAG|MS-GraphRAG|700x|99\.9%|\$33K|k-means.{0,12}128|SAME_AS|helpfulness score|<100 tokens|2,?668 MB|415 MB|136\.2 ?ms|46,?9[0-9][0-9]|22,?784|60\.92%|87\.9|90\.9|~?30% execution|N ?= ?2F ?\+ ?1|τ ?= ?0\.5|Kuzu|RedisGraph|Local search|Leiden' knowledge-graph-fixture-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 5
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "LazyGraphRAG matches global-search quality at 700x lower query cost / 99.9% lower indexing; full GraphRAG indexed a large corpus for ~$33K@2024" (named + quantified cost rule + absolute anchor)
- ✅ "single-fact lookups belong on flat/reranked RAG (GraphRAG-Bench Novel-dataset Fact Retrieval ACC 60.92, arXiv 2506.05690 Table 2); graph's edge is multi-hop aggregation (HippoRAG 87.9–90.9% evidence recall)" (the ARC7 graph-vs-flat threshold)
- ✅ "k-means cluster size 128 → fused BM25+vector top-K 16" (the entity-resolution pipeline numbers)
- ✅ "SAME_AS edge routed to a human" (the governed-merge threshold rule)
- ✅ "Kuzu's repo was archived after the 2025-10 Apple acquisition — don't pick it; re-select by benchmark (FalkorDB p99 136 ms vs Neo4j 46,924 ms)" (the deprecated-engine isolation rule + refreshed latency number)
- ✅ "Global search runs Map-Reduce with a helpfulness score 0-100" (the named search mechanism)
- ❌ "build a knowledge graph" (restates the input — any agent says this)
- ❌ "extract entities and relationships" (generic domain vocabulary)
- ❌ "consider performance and cost" (generic — no named architecture or number)
- ❌ "Kuzu is an embedded graph database" (restates input; NOT the deprecation catch)

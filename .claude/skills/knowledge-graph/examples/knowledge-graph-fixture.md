---
name: graphrag-build-review
description: "Tests cost-architecture cross-cutting rule (LazyGraphRAG 700x / 99.9%) + entity-resolution pipeline + Global/Local search + graph-DB selection on a full-GraphRAG build request"
pack: knowledge-graph
tests_rules:
  - "Cross-Cutting Rule: extraction cost scales with document volume (LazyGraphRAG 700x / 99.9%)"
  - "ARC5: Global Map-Reduce vs Local 1-2 hop search selection"
  - "ER2/ER3: two-stage resolution (k-means 128) + governed SAME_AS merge"
  - "GDB1: Neo4j vs Memgraph vs FalkorDB by benchmark numbers"
min_marker_count: 4
# DISCRIMINATIVE gate: ONLY pack-specific markers — named architectures + the
# specific numbers/thresholds from findings.md. EXCLUDES generic domain nouns
# (knowledge graph, entity, node, database, GraphRAG) and any word from the input
# scenario. A no-pack control may say "use a knowledge graph" but will NOT produce
# "700x lower query cost", "k-means cluster size 128", "helpfulness score 0-100",
# "SAME_AS edge to a human", or "2,668 MB JVM heap vs 415 MB".
discriminative_pattern: "LazyGraphRAG|LightRAG|700x|99\\.9%|k-means.{0,12}128|SAME_AS|helpfulness score|<100 tokens|2,?668 MB|415 MB|N ?= ?2F ?\\+ ?1|τ ?= ?0\\.5"
min_discriminative: 4
---

# Fixture: Full GraphRAG Build Review

## Input Scenario

"We have 40,000 internal documents and want to answer broad 'what are the themes across all of this' questions. Plan is to build full Microsoft GraphRAG, extract every entity, store it in Neo4j, and use Global search for everything. Review the plan."

## Expected Markers

When an AI agent processes the Input Scenario with the knowledge-graph pack loaded,
the output MUST contain these markers (grep-verifiable):

1. **Cost-architecture cross-cutting rule** [structural]: the agent flags that extraction cost scales with the 40k-document volume and prescribes ruling out a cheaper architecture by name + number — not a generic "watch your costs"
   grep pattern: `LazyGraphRAG|LightRAG|700x|99\.9%|<100 tokens|document volume`
2. **Search-paradigm correction** [structural]: rejects "Global search for everything" and routes entity-specific queries to Local 1-2 hop; cites the Map-Reduce helpfulness score
   grep pattern: `Local search|1.?2.?hop|helpfulness score|Map.?Reduce`
3. **Entity-resolution pipeline**: flags the missing resolution stage with the specific pipeline numbers
   grep pattern: `entity resolution|k-means.{0,12}128|top.?K.{0,6}16|S-BERT|SAME_AS`
4. **Graph-DB selection by benchmark**: questions the reflexive Neo4j choice with the memory/quorum numbers
   grep pattern: `2,?668 MB|415 MB|Memgraph|FalkorDB|N ?= ?2F ?\+ ?1`

At least one marker is [structural] — verifies the agent APPLIED the rule (named architecture + number), not just named the domain.

## Verification Command

```bash
grep -oE 'LazyGraphRAG|LightRAG|700x|99\.9%|k-means.{0,12}128|SAME_AS|helpfulness score|<100 tokens|2,?668 MB|415 MB|N ?= ?2F ?\+ ?1|τ ?= ?0\.5|Local search|Leiden' knowledge-graph-fixture-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 4
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "LazyGraphRAG matches global-search quality at 700x lower query cost / 99.9% lower indexing" (the pack's specific named+quantified cost rule)
- ✅ "k-means cluster size 128 → fused BM25+vector top-K 16" (the pack's specific entity-resolution pipeline numbers)
- ✅ "SAME_AS edge routed to a human" (the pack's governed-merge threshold rule)
- ✅ "Neo4j 2,668 MB JVM heap vs Memgraph 415 MB for 16k nodes" (the pack's specific benchmark deciding the DB)
- ✅ "Global search runs Map-Reduce with a helpfulness score 0-100" (the pack's named search mechanism)
- ❌ "build a knowledge graph" (restates the input — any agent says this)
- ❌ "extract entities and relationships" (generic domain vocabulary)
- ❌ "consider performance and cost" (generic — no named architecture or number)
- ❌ "Neo4j is a graph database" (generic fact, not the selection benchmark)

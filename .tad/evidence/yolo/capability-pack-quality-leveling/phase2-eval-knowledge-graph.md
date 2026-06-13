# Phase 2 Discriminative Eval — knowledge-graph

**Date**: 2026-06-13
**Pack**: knowledge-graph (v0.1.0)
**Fixture**: `.claude/skills/knowledge-graph/examples/knowledge-graph-fixture.md` (scenario: `graphrag-build-review`)
**min_discriminative**: 5
**discriminative_pattern**:
```
LazyGraphRAG|LightRAG|HippoRAG|MS-GraphRAG|RAPTOR|700x|99\.9%|\$33K|k-means.{0,12}128|SAME_AS|helpfulness score|<100 tokens|2,?668 MB|415 MB|136\.2 ?ms|46,?9[0-9][0-9]|22,?784|6,?693 QPS|60\.92%|87\.9|90\.9|~?30% execution|N ?= ?2F ?\+ ?1|τ ?= ?0\.5|Kuzu|RedisGraph|60\.92|78\.76
```

## Method

Took the fixture Input Scenario verbatim (40,000 internal docs; mostly single-fact lookups; plan = full Microsoft GraphRAG + extract every entity + skip dedup + store in Kuzu + Global search for everything). Produced two answers:
- **WITH-PACK**: applied `.claude/skills/knowledge-graph/SKILL.md` rules (Cross-Cutting cost rule, ARC7 graph-vs-flat, ARC5 search-paradigm, ER2/ER3 entity resolution, GDB1 + deprecated-engine isolation).
- **CONTROL**: generalist KG review, no pack.

Applied `grep -oE PATTERN | sort -u | wc -l` to each.

## Results

| Answer | Unique discriminative markers |
|--------|-------------------------------|
| WITH-PACK | **20** |
| CONTROL | **1** |

### WITH-PACK markers (20)
`<100 tokens`, `$33K`, `136.2 ms`, `2,668 MB`, `22,784`, `415 MB`, `46,924`, `60.92%`, `700x`, `87.9`, `90.9`, `99.9%`, `helpfulness score`, `HippoRAG`, `Kuzu`, `LazyGraphRAG`, `LightRAG`, `N=2F+1`, `RedisGraph`, `SAME_AS`

### CONTROL markers (1)
`Kuzu` — and only because the input scenario names Kuzu. The fixture explicitly flags `"Kuzu is an embedded graph database"` as restating the input, NOT the deprecation catch. So the lone control hit is input-echo, not applied pack judgment. The control otherwise produced only generic advice ("watch your costs", "add an entity resolution step", "consider performance and cost") with zero named architectures, numbers, or thresholds.

## Gate Decision

- with-pack disc (20) >= min_discriminative (5): PASS
- control disc (1) < min_discriminative (5): PASS
- **discriminative_pass = TRUE**

The pack produces a clearly discriminative behavioral delta: every structural marker the fixture requires (cost rule with $33K/700x/99.9% anchor, ARC7 60.92%/HippoRAG 87.9–90.9% threshold, ER pipeline numbers + SAME_AS, Kuzu-archived re-selection with FalkorDB 136.2 ms vs Neo4j 46,924 ms / 415 MB vs 2,668 MB, helpfulness-score Global/Local correction) appeared in the WITH-PACK answer and was absent from the control.

# Entity Resolution & Knowledge Fusion Rules
<!-- capability: entity_resolution -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| ER1 | Unresolved duplicates fragment paths + distort topology — resolution is mandatory, not optional | deterministic |
| ER2 | Two-stage pipeline: lowercase → S-BERT → k-means(128) → fused BM25+vector top-K(16) → LLM consolidation | semi-deterministic |
| ER3 | Governed merges: Auto-Merge / SAME_AS-to-human / New-Node by similarity threshold | deterministic |
| ER4 | Reified match assertions carry confidence + source + timestamp + approval status (auditability) | deterministic |
| ER5 | LLM consolidation must account for plurals, abbreviations, and tenses | semi-deterministic |

---

## Rules

### ER1: Resolution Is Mandatory

When extracting entities from unstructured text, expect synonymous / variant / duplicate nodes. If left unresolved they:

- duplicate one concept across multiple entities,
- split relationship paths,
- distort topological metrics (node degree, combined degree),
- produce redundant or fragmented retrieval context.

Entity resolution + knowledge fusion is a required pipeline stage, not a nice-to-have. Example: "Olympic Winter Games" and "winter Olympic games" must collapse to one canonical node.

> Source: findings.md §"Entity Resolution and Knowledge Fusion" intro — fragmentation effects [5, 33]; canonical-collapse example [32].

**determinismLevel**: deterministic — the requirement is non-negotiable.

### ER2: Two-Stage Semantic Resolution Pipeline

When deduplicating at scale, run the hybrid two-stage pipeline (do NOT do naive O(n²) pairwise LLM comparison):

```
Raw nodes
  → Aggregation: normalize to lowercase (kill simple casing dups)
  → S-BERT semantic embeddings
  → k-means clustering (cluster size = 128)         ← makes pairwise comparison feasible
  → within each cluster: fused BM25 + vector search, top K = 16 candidates per entity
  → LLM-guided canonical consolidation
  → canonical representative + alias mapping (Wikidata-style)
```

Starting hyperparameters from the source pipeline (findings.md [32]): **cluster target ≈ 128 entities per cluster**, **fused-retrieval top K = 16 candidates per entity**. These are that pipeline's reported defaults, NOT universal constants — they bound comparison cost, but tune both on your own precision/recall and reviewer workload before committing. (Note: standard k-means is parameterized by the *number* of clusters `k`, not a fixed cluster size; pick `k ≈ n/128` to target ~128 entities per cluster, then validate.)

> Source: findings.md §1 "Two-Stage Semantic Resolution" — lowercase + S-BERT + k-means + fused BM25/vector top-K + LLM consolidation; the ≈128-per-cluster and top-K=16 values are that source pipeline's reported defaults, to be validated per dataset [32].

**determinismLevel**: semi-deterministic — pipeline + numbers fixed; LLM merge calls vary.

### ER3: Threshold-Driven Governed Merges

When deciding to merge, do NOT auto-merge everything. Route by similarity threshold (OntoDup governance):

| Similarity band | Action |
|-----------------|--------|
| **Above high-confidence threshold** | **Auto-Merge** automatically |
| **Moderate review threshold** | Connect via a temporary **`SAME_AS` edge** and route to a **human administrator** for review |
| **Below threshold** | Keep as **separate, unique New Node** |

This is critical in legal / clinical / scholarly domains where automated merging introduces operational and audit risk.

> Source: findings.md §2 "Governed Assertion Workflows" — Auto-Merge / SAME_AS-to-human / New-Node thresholds [5]; auditability rationale [34, 35].

**determinismLevel**: deterministic — threshold routing is a fixed decision rule.

### ER4: Reified, Auditable Match Assertions

When auditability is required, record potential duplicates as explicit, queryable graph assertions — not silent in-place merges:

- **Reified match assertion**: `ontodup:MatchAssertion` node per candidate pair.
- Each assertion maps: **confidence score**, the **source algorithm/model**, **extraction timestamp(s)**, and current **approval status**.
- This stateful pipeline keeps every merge fully auditable, preserves historical lineage, and allows updates to be **reverted** if conflicts arise.

> Source: findings.md §2 — reified `ontodup:MatchAssertion` + confidence/source/timestamp/status metadata + revertibility [23, 35].

**determinismLevel**: deterministic — the assertion schema is fixed.

### ER5: LLM Consolidation Must Handle Morphology

When the LLM evaluates the top-K candidate list to pick a canonical representative, it must explicitly account for:

- **plurals** (game → games)
- **abbreviations** (USA → United States of America)
- **tenses / morphological variants**

It then selects a canonical representative for each duplicate set and maps the variations into alias structures.

> Source: findings.md §1 — LLM-guided consolidation handling plurals, abbreviations, tenses + canonical/alias mapping [32].

**determinismLevel**: semi-deterministic — the checklist is fixed; LLM output varies.

---

## Anti-Patterns

- **Skipping resolution**: leaving variant nodes split → fragmented paths and wrong degree metrics feeding GraphRAG search.
- **Naive pairwise LLM dedup**: O(n²) LLM calls; the k-means(128) + top-K(16) pre-filter exists precisely to avoid this.
- **Auto-merge everything**: destroys auditability; moderate-confidence pairs belong on a human-reviewed `SAME_AS` edge.
- **Silent in-place merge**: no reified assertion → no lineage, no revert path when a merge turns out wrong.
- **Casing-only dedup**: lowercasing catches trivial dups but misses plurals/abbreviations/tenses — the LLM stage is still required.

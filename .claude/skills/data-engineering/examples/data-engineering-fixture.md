---
name: rag-feature-pipeline-review
description: "Tests Train-Serve Skew rule + RRF k=60 hybrid retrieval + pre-filter-vs-post-filter recall collapse + SCD Type 2 is_current bloat on a RAG+feature pipeline"
pack: data-engineering
tests_rules:
  - "Cross-Cutting Rule: Train-Serve Skew (single dbt source feeds training + serving)"
  - "VEC1: pre-filtering for tenant isolation vs post-filter recall collapse"
  - "VEC3: hybrid dense+sparse merged with RRF, k=60"
  - "DIM4: SCD Type 2 queries must filter is_current = true (150M-row bloat)"
  - "P0/P1/P2 finding output format"
min_marker_count: 4
# DISCRIMINATIVE gate: ONLY pack-specific markers (named rules + specific numbers from findings).
# Excludes generic domain nouns ("vector database", "feature store", "data quality"),
# severity tags, and any word lifted from the input scenario. These are markers a
# WITH-pack agent emits that a no-pack control would NOT (no-pack agent says
# "add metadata filtering" / "store history" — not "recall collapse" / "RRF k=60" / "is_current = true").
discriminative_pattern: "train.?serve skew|recall collapse|Reciprocal Rank Fusion|RRF|k ?= ?60|is_current ?= ?true|missing.?field trap|pre.?filter|SCD Type 2|graph islanding"
min_discriminative: 4
---

# Fixture: RAG + Feature Pipeline Review

## Input Scenario

"I'm building a customer-support AI. For features, I compute the customer's 30-day order count in my training notebook, and again in the live inference service. For RAG, I run a global vector search across all tenants and then drop results that aren't the asking tenant's. Retrieval is embedding-only. Customer attributes (tier, city) live in a dimension table where I just overwrite the old value on change. Review my data pipeline."

## Expected Markers

When an AI agent processes the Input Scenario with the data-engineering pack loaded,
the output MUST contain these markers:

1. **Train-serve skew named + single-source fix** [structural]: the agent names train-serve skew for the duplicated 30-day-count logic and prescribes ONE version-controlled dbt source / Feature View feeding both training and serving — not a generic "keep them consistent"
   grep pattern: `train.?serve skew|single (dbt|version.?controlled) source|Feature View`
2. **Post-filter recall collapse → pre-filter** [structural]: the agent flags the global-search-then-drop pattern as post-filtering, names the recall-collapse / zero-result risk, and prescribes pre-filtering for tenant isolation
   grep pattern: `recall collapse|post.?filter|pre.?filter|tenant isolation`
3. **Hybrid retrieval with RRF k=60**: the agent rejects embedding-only retrieval and prescribes dense+sparse fusion via Reciprocal Rank Fusion with k=60
   grep pattern: `Reciprocal Rank Fusion|RRF|k ?= ?60|dense.{0,10}sparse`
4. **SCD Type 1 overwrite → Type 2 with is_current**: the agent flags the overwrite as SCD Type 1 destroying history and prescribes SCD Type 2 (valid_from/valid_to/is_current) with the is_current = true filter to avoid bloat
   grep pattern: `SCD Type [12]|is_current ?= ?true|valid_from|time.?travel`
5. **Severity-tagged findings**: P0/P1/P2 output structure
   grep pattern: `\[P0\]|\[P1\]|\[P2\]`

## Verification Command

```bash
grep -oE 'train.?serve skew|Feature View|recall collapse|pre.?filter|post.?filter|tenant isolation|Reciprocal Rank Fusion|RRF|k = 60|SCD Type 2|is_current = true|missing.?field trap|graph islanding' data-engineering-fixture-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 4
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "train-serve skew → single dbt source / Feature View" (the pack's named failure mode + the single-source fix, not generic "keep consistent")
- ✅ "recall collapse → use pre-filtering for tenant isolation" (the pack's specific consequence of post-filtering; a no-pack agent says "filter by tenant" without naming the zero-result risk)
- ✅ "Reciprocal Rank Fusion (RRF), k = 60" (the pack's specific named algorithm + the specific smoothing constant)
- ✅ "SCD Type 2 with is_current = true" (the pack's named dimensional pattern + the specific filter that prevents the 150M-row bloat scan)
- ✅ "missing-field trap / graph islanding" (the pack's named vector-store failure modes)
- ❌ "add metadata filtering" (generic — any agent suggests filtering without naming pre-filter/recall-collapse)
- ❌ "store the history" (generic — does not name SCD Type 2 / is_current)
- ❌ "use a vector database" (restates the input; non-discriminative)
- ❌ "make features consistent" (generic — does not name train-serve skew or the single-source fix)

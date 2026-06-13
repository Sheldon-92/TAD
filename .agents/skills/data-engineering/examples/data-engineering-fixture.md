---
name: rag-feature-pipeline-review
description: "Tests Train-Serve Skew rule + RRF k=60 (tune within [40,80]) hybrid retrieval + ACORN filtered-search + pre-filter-vs-post-filter recall collapse + SCD Type 2 is_current bloat + Polars-vs-Pandas (~94x) on a RAG+feature pipeline"
pack: data-engineering
tests_rules:
  - "Cross-Cutting Rule: Train-Serve Skew (single dbt source feeds training + serving)"
  - "VEC1: pre-filtering for tenant isolation vs post-filter recall collapse"
  - "VEC3: hybrid dense+sparse merged with RRF, k=60 (tune within [40,80] per corpus)"
  - "VEC4: ACORN predicate-agnostic filtered ANN (2–1,000x at fixed recall) vs graph islanding"
  - "TRN3: Polars streaming over Pandas (~94x at SF-10; Pandas OOMs at SF-100)"
  - "DIM4: SCD Type 2 queries must filter is_current = true (~160M-row bloat)"
  - "P0/P1/P2 finding output format"
min_marker_count: 4
# DISCRIMINATIVE gate: ONLY pack-specific markers (named rules + specific numbers from refreshed sources).
# Excludes generic domain nouns ("vector database", "feature store", "data quality"),
# severity tags, and any word lifted from the input scenario. These are markers a
# WITH-pack agent emits that a no-pack control would NOT (no-pack agent says
# "add metadata filtering" / "store history" / "use Polars" — not "recall collapse" /
# "RRF k=60" / "ACORN" / "is_current = true" / "~94x").
discriminative_pattern: "train.?serve skew|recall collapse|Reciprocal Rank Fusion|RRF|k ?= ?60|\\[40, ?80\\]|ACORN|is_current ?= ?true|missing.?field trap|pre.?filter|SCD Type 2|graph islanding|94x|streaming engine"
min_discriminative: 4
---

# Fixture: RAG + Feature Pipeline Review

## Input Scenario

"I'm building a customer-support AI. For features, I compute the customer's 30-day order count in my training notebook (in Pandas over ~40GB of order history), and again in the live inference service. For RAG, I run a global vector search across all tenants and then drop results that aren't the asking tenant's; I also apply a tier+region metadata filter inside the HNSW traversal. Retrieval is embedding-only. Customer attributes (tier, city) live in a dimension table where I just overwrite the old value on change. Review my data pipeline."

## Expected Markers

When an AI agent processes the Input Scenario with the data-engineering pack loaded,
the output MUST contain these markers:

1. **Train-serve skew named + single-source fix** [structural]: the agent names train-serve skew for the duplicated 30-day-count logic and prescribes ONE version-controlled dbt source / Feature View feeding both training and serving — not a generic "keep them consistent"
   grep pattern: `train.?serve skew|single (dbt|version.?controlled) source|Feature View`
2. **Post-filter recall collapse → pre-filter** [structural]: the agent flags the global-search-then-drop pattern as post-filtering, names the recall-collapse / zero-result risk, and prescribes pre-filtering for tenant isolation
   grep pattern: `recall collapse|post.?filter|pre.?filter|tenant isolation`
3. **Hybrid retrieval with RRF k=60, tunable [40,80]**: the agent rejects embedding-only retrieval and prescribes dense+sparse fusion via Reciprocal Rank Fusion with k=60, noting k tunes within [40,80] per corpus
   grep pattern: `Reciprocal Rank Fusion|RRF|k ?= ?60|\[40, ?80\]|dense.{0,10}sparse`
4. **Inline HNSW filter → graph islanding / ACORN**: the agent flags the in-traversal metadata filter as risking graph islanding under strict filters and prescribes ACORN (predicate-agnostic, 2–1,000x at fixed recall) or a pre-filter fallback
   grep pattern: `graph islanding|ACORN|2.?1,?000x|pre.?filter`
5. **Pandas over 40GB → Polars streaming (~94x)**: the agent flags single-threaded Pandas on ~40GB and prescribes Polars LazyFrame / streaming engine (~94x faster than Pandas at SF-10; Pandas OOMs at SF-100)
   grep pattern: `Polars|streaming engine|94x|LazyFrame`
6. **SCD Type 1 overwrite → Type 2 with is_current**: the agent flags the overwrite as SCD Type 1 destroying history and prescribes SCD Type 2 (valid_from/valid_to/is_current) with the is_current = true filter to avoid bloat
   grep pattern: `SCD Type [12]|is_current ?= ?true|valid_from|time.?travel`
7. **Severity-tagged findings**: P0/P1/P2 output structure
   grep pattern: `\[P0\]|\[P1\]|\[P2\]`

## Verification Command

```bash
grep -oE 'train.?serve skew|Feature View|recall collapse|pre.?filter|post.?filter|tenant isolation|Reciprocal Rank Fusion|RRF|k = 60|\[40, ?80\]|ACORN|SCD Type 2|is_current = true|missing.?field trap|graph islanding|Polars|streaming engine|94x' data-engineering-fixture-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 4
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "train-serve skew → single dbt source / Feature View" (the pack's named failure mode + the single-source fix, not generic "keep consistent")
- ✅ "recall collapse → use pre-filtering for tenant isolation" (the pack's specific consequence of post-filtering; a no-pack agent says "filter by tenant" without naming the zero-result risk)
- ✅ "Reciprocal Rank Fusion (RRF), k = 60, tune within [40,80]" (the pack's specific named algorithm + smoothing constant + the auditable tuning band, not a lone magic number)
- ✅ "ACORN — predicate-agnostic filtered ANN, 2–1,000x at fixed recall" (the pack's named SOTA for the inline-HNSW-filter problem; a no-pack agent says "filter inside the index" without naming ACORN or islanding)
- ✅ "Polars streaming engine, ~94x faster than Pandas at SF-10; Pandas OOMs at SF-100" (the pack's countable benchmark threshold, not "Polars is faster")
- ✅ "SCD Type 2 with is_current = true" (the pack's named dimensional pattern + the specific filter that prevents the ~160M-row bloat scan)
- ✅ "missing-field trap / graph islanding" (the pack's named vector-store failure modes)
- ❌ "add metadata filtering" (generic — any agent suggests filtering without naming pre-filter/recall-collapse/ACORN)
- ❌ "store the history" (generic — does not name SCD Type 2 / is_current)
- ❌ "use a vector database" (restates the input; non-discriminative)
- ❌ "use Polars, it's faster" (generic — does not carry the ~94x / SF-10 / streaming-engine threshold)
- ❌ "make features consistent" (generic — does not name train-serve skew or the single-source fix)

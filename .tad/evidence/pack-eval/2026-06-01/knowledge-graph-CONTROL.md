# Review: Full GraphRAG + Neo4j + Global Search for 40K-Doc Theme Discovery

## Verdict

The instinct is right, the execution plan is over-built and likely to be expensive, slow, and operationally heavy for what you're actually trying to do. Your core use case — "what are the themes across all of this" — is *exactly* the question Microsoft GraphRAG's **Global Search** was designed for, so you've identified the right tool category. But three decisions in the plan ("full GraphRAG," "extract every entity," "store in Neo4j," "Global search for everything") each deserve to be challenged. Below is a fair, specific critique with recommended adjustments.

---

## What's right about the plan

- **GraphRAG Global Search is genuinely the correct primitive for corpus-level thematic ("sensemaking") queries.** Standard vector RAG fails on "what are the major themes" because top-k chunk retrieval only ever sees a tiny local slice of the corpus; it cannot summarize the whole. GraphRAG answers global questions by pre-computing **community summaries** (via hierarchical Leiden clustering over the entity graph) and doing a map-reduce over those summaries. This is the right mechanism for your question type.
- Building structure once and querying it many times is the right shape for a recurring analytical workload.

---

## Where the plan is likely wrong or risky

### 1. "Full Microsoft GraphRAG" — beware the indexing cost at 40K docs
Microsoft's default GraphRAG indexing pipeline makes **many LLM calls per text unit** (entity+relationship extraction, optional gleanings/repeated extraction passes, claim/covariate extraction, then community report generation for every community at every hierarchy level). At 40,000 documents this can mean **hundreds of thousands to low-millions of LLM calls**, which translates to real money (commonly four-to-five figures USD depending on model and gleaning settings) and many hours-to-days of indexing wall-clock time. This is the single most underestimated line item in the plan.

**Recommendations:**
- **Run a pilot on 500–2,000 representative documents first.** Measure cost, time, and — critically — answer quality on your real theme questions before committing to all 40K. Extrapolate cost linearly (extraction cost scales roughly with token volume).
- Use a **cheap model for extraction** (the bulk of the calls) and reserve a stronger model only for community-report summarization and final query synthesis. Tune `max_gleanings` down (0–1) — extra gleaning passes multiply extraction cost for diminishing entity recall.
- **Seriously evaluate LazyGraphRAG and/or LightRAG as alternatives.** Microsoft's own *LazyGraphRAG* defers the expensive LLM summarization to query time and reports comparable global-query quality at a small fraction of the indexing cost. If your query *volume* is low relative to corpus size, lazy/deferred approaches can be dramatically cheaper. LightRAG is another lighter-weight, lower-cost option. For pure theme discovery these are worth a head-to-head against full GraphRAG in your pilot.

### 2. "Extract every entity" — this is a goal, not a strategy, and it will hurt you
"Extract every entity" with no typed ontology produces an enormous, noisy, generic graph (every PERSON, ORG, DATE, MISC). For thematic sensemaking this is counterproductive:
- More entities → more, smaller communities → more community reports → more cost, and **noise dilutes the themes** you actually care about.
- Untyped extraction without a **domain ontology / entity-type allowlist** yields inconsistent, redundant nodes that need heavy cleanup downstream.

**Recommendations:**
- Define a **small, domain-specific entity-type list** in the GraphRAG extraction prompt (it supports tuning entity types). Extract what's thematically relevant, not everything.
- For "themes," the **community reports and their summaries are the product**, not the raw entities. Optimize for good community structure (tune Leiden resolution / hierarchy levels), not maximal entity count.

### 3. "Store it in Neo4j" — likely unnecessary for your stated use case, and a possible architectural mismatch
This is the part of the plan I'd push back on hardest. Microsoft GraphRAG's reference pipeline does **not require Neo4j** — it persists artifacts as **Parquet files** (entities, relationships, communities, community_reports, text_units) and uses **LanceDB** for vector embeddings by default. Global Search reads the **community_reports parquet**; it does not query a graph database at all. So:
- If your *only* use case is corpus-level theme discovery via Global Search, **Neo4j buys you nothing for that path** — you'd be standing up and maintaining a graph database that the query you care about never touches.
- Neo4j becomes valuable when you need **Local Search / DRIFT search done graph-natively**, ad-hoc **Cypher traversals**, entity-centric exploration, multi-hop questions, a graph UI for humans, or to serve the graph to other applications. There *is* an official neo4j-graphrag integration and Neo4j import tooling for GraphRAG parquet — it's a legitimate option — but it's a "we have broader graph needs" decision, not a "theme discovery" requirement.

**Recommendation:** Don't put Neo4j on the critical path for v1. Run GraphRAG with its default parquet/LanceDB storage, validate Global Search quality, and **only adopt Neo4j if/when you have concrete graph-query or local-exploration needs.** If you do adopt it, also consider whether a lighter graph store (Memgraph, FalkorDB, Kùzu) fits, but for most teams Neo4j is the safe default once a graph DB is actually warranted.

### 4. "Global search for everything" — wrong default for most real queries
Global Search is the most expensive query mode (it map-reduces over many community reports per question) and it's only the right tool for **broad, corpus-wide sensemaking**. The moment a user asks something specific — "what did we decide about vendor X," "summarize the Q3 incident" — Global Search is **slow, costly, and often worse** than Local Search (entity-anchored) or DRIFT (hybrid). "Everything is global" will give you bad latency/cost and mediocre answers on the majority of real-world questions.

**Recommendation:** Implement **query routing**: route broad thematic questions to Global, entity/specific questions to Local, and use DRIFT for mixed. Even a simple LLM-classifier router in front of the three modes is worth it.

---

## Things the plan omits that will bite you

- **Entity resolution / deduplication.** "Acme Inc.", "Acme", "ACME Corporation" will become separate nodes. Across 40K docs this is severe and degrades both graph quality and theme coherence. Plan an explicit ER step (blocking + similarity + merge), or accept noisier communities.
- **Incremental indexing.** 40K internal docs are presumably a living corpus. Full re-index on every update is cost-prohibitive. GraphRAG has incremental-update support — design for it from day one rather than treating indexing as one-shot.
- **Evaluation.** "Themes look reasonable" is not evaluation. Define a held-out set of theme questions with expected coverage, and measure **comprehensiveness, diversity, and groundedness/faithfulness** (GraphRAG's own evaluation used exactly these LLM-judged dimensions for global queries). Without this you can't tell GraphRAG from LazyGraphRAG from plain map-reduce summarization, or justify the cost.
- **Naive baseline.** Before any of this, try the cheapest thing that could work: **hierarchical map-reduce summarization** (or even topic modeling — BERTopic/LDA — for a first read on themes) over the corpus. If that's "good enough" for theme discovery, you may not need a graph at all. GraphRAG's advantage over map-reduce summarization is real but not infinite — prove you need it.
- **Data governance / PII / access control.** 40K *internal* docs almost certainly contain sensitive content and mixed access levels. Entity extraction + community summaries can **surface or aggregate sensitive info across permission boundaries**. Decide on document-level access controls and whether summaries can leak restricted content before indexing, not after.
- **Chunking / text-unit size** materially affects extraction quality and cost — tune it, don't take the default blindly.

---

## Recommended revised plan

1. **Baseline first:** hierarchical map-reduce summarization (and/or BERTopic) over the 40K docs. Capture cost/quality. This is your floor.
2. **Pilot GraphRAG on ~1–2K representative docs** with a **typed entity ontology** (not "every entity"), cheap extraction model, `max_gleanings` low. Measure indexing cost/time and Global Search answer quality on a fixed set of theme questions.
3. **Head-to-head LazyGraphRAG / LightRAG** in the same pilot — they may match quality at a fraction of indexing cost for your low-query-volume, broad-question profile.
4. **Use default parquet/LanceDB storage.** Defer Neo4j until you have a concrete graph-query / local-exploration / multi-app-serving need.
5. **Add an explicit entity-resolution step** if entity quality matters to your themes.
6. **Build query routing** (Global / Local / DRIFT), not "Global for everything."
7. **Stand up evaluation** (comprehensiveness, diversity, groundedness) so you can make the scale-up and tooling decisions on evidence.
8. **Design for incremental indexing** before going to full corpus.
9. Only then **scale to 40K**, and adopt Neo4j if v1 surfaced real graph-native needs.

## Bottom line
Right tool family (GraphRAG Global Search for thematic sensemaking), wrong defaults on almost every parameter. The biggest wins: **pilot before committing**, **don't extract "every" entity**, **drop Neo4j from the v1 critical path** (Global Search reads parquet, not a graph DB), **route queries instead of forcing everything through Global**, and **evaluate against a naive baseline + lazy alternatives** so the substantial cost is justified by measured quality.

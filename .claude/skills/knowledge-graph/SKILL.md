---
name: knowledge-graph
description: Knowledge Graph & GraphRAG capability pack. Gives AI agents the judgment rules for building graph-enhanced retrieval systems — Microsoft GraphRAG indexing (Leiden communities, Global/Local/Drift search), LazyGraphRAG vs LightRAG cost selection, LLM knowledge-graph construction (ontology design, extraction prompting), entity resolution & deduplication, graph database selection (Neo4j/Memgraph/FalkorDB, LPG vs RDF-Star), and Text2Cypher/SPARQL-Star query translation. Research-grounded rules from Microsoft Research, Neo4j, LightRAG, OntoDup, and graph database benchmarks. Use for any GraphRAG pipeline, knowledge-graph construction, entity-resolution, graph-DB selection, or graph-query-translation task.
keywords: ["知识图谱", "knowledge graph", "GraphRAG", "图谱", "图检索", "graph rag", "实体消歧", "entity resolution", "本体", "ontology", "图数据库", "graph database", "Neo4j", "Cypher", "LightRAG", "三元组", "triple", "Leiden", "RDF"]
type: reference-based
---

**CONSUMES**: User knowledge-graph / GraphRAG task + corpus description + optional existing graph schema, extraction configs, or DB choice
**PRODUCES**: Applied graph judgment rules + GraphRAG architecture recommendation + extraction prompting plan + entity-resolution pipeline + graph-DB selection + Text2Cypher/SPARQL-Star query patterns + cost guardrails

# Knowledge Graph & GraphRAG Capability Pack

**Version**: 0.1.0
**Compatibility**: Claude Code (Phase 1); Codex / Cursor / Gemini in Phase 3
**License**: Apache 2.0

---

## What This Pack Does

AI agents reach for GraphRAG the moment "knowledge graph" appears, then default to full Microsoft GraphRAG — paying complete LLM pre-summarization cost when LazyGraphRAG would match global-search quality at a 700x lower query cost. They pick Global search for every query, ignoring that it runs a parallel Map-Reduce over entire community-report levels. They extract entities with a bare zero-shot prompt and skip entity resolution, splitting "Olympic Winter Games" and "winter Olympic games" into two nodes that fragment every traversal. They pick Neo4j by reflex without checking whether the workload needs sub-millisecond in-memory traversal (Memgraph) or a compressed-sparse-matrix throughput profile (FalkorDB).

This pack embeds the judgment rules a senior graph/GraphRAG engineer applies automatically — rules from Microsoft Research, Neo4j, LightRAG, OntoDup, and head-to-head graph-database benchmarks.

**Pack = graph judgment. Your workflow system = process constraints. No overlap.**

---

## Cross-Cutting Rule: Extraction Cost Scales with DOCUMENT Volume, Not Query Volume

> **GraphRAG indexing cost scales with the number of documents you extract over, NOT with how many queries you ask.** Standard vector RAG cost scales with query volume; GraphRAG extraction cost scales with corpus size — running extraction passes over tens of thousands of chunks scales costs unpredictably. Before any full GraphRAG build, install proactive guardrails: a hard spend limit, a pipeline circuit breaker, and per-pipeline cost attribution. If the corpus is large or volatile, prefer LazyGraphRAG (defers LLM work to query time, ~0.1% of GraphRAG indexing cost) or LightRAG (incremental updates) BEFORE committing to full Leiden pre-summarization.

This rule applies to: architecture selection, indexing, extraction prompting, and entity resolution. It is surfaced here because burying it in one reference file causes agents to over-build the index and then discover the cost at production scale.

---

## Step 0: Context Detection

When the user mentions knowledge-graph or GraphRAG work, detect the context and load the right reference:

| User Signal | Reference to Load |
|-------------|-------------------|
| "GraphRAG", "global search", "local search", "drift", "community", "Leiden", "LightRAG", "LazyGraphRAG", "图检索" | `references/graphrag-architecture.md` |
| "build a knowledge graph", "extract entities", "ontology", "schema", "triples", "extraction prompt", "本体", "三元组" | `references/kg-construction.md` |
| "deduplicate", "entity resolution", "merge entities", "canonical", "same entity", "实体消歧" | `references/entity-resolution.md` |
| "which graph database", "Neo4j", "Memgraph", "FalkorDB", "RDF", "LPG", "triple store", "Kuzu", "RedisGraph", "图数据库" | `references/graph-database.md` (incl. deprecated-engine isolation block) |
| "Text2Cypher", "natural language to Cypher", "SPARQL", "query translation", "Cypher-RAG", "查询翻译" | `references/query-translation.md` |
| "should I even use a graph", "graph vs vector", "is GraphRAG worth it", "single fact", "summary recall" | `references/graphrag-architecture.md` → **ARC7 (graph-vs-flat threshold)** |
| "full GraphRAG build", "design the whole pipeline", "end to end" | Load **all references** sequentially |

**Determinism check:** run `bash scripts/graph-arch-lint.sh` for a deterministic structural lint (fixture gate parseable, references one-level-deep, every rule annotated with determinismLevel, no deprecated DB recommended outside the isolation block). Use it as a pre-flight before shipping pack edits.

---

## Step 1: Apply Rules

After loading the relevant reference file(s):

1. **Read the reference completely** — do not skim
2. **Apply each rule as a judgment check** against the user's graph design, extraction config, or DB choice
3. **For each violated rule**: state the violation clearly, then give the specific fix (with the named threshold / CLI / query from the reference)
4. **Enforce the cross-cutting cost rule** on every full-GraphRAG-build proposal — confirm a cheaper architecture (LazyGraphRAG / LightRAG) was ruled out on evidence, not reflex
5. **Check determinismLevel annotations** — they tell you how much variance to expect:
   - `deterministic`: architectural/classification decision, stable
   - `semi-deterministic`: config fixed but LLM extraction/scoring varies — run multiple passes
   - `non-deterministic`: agentic loops (Drift, self-correcting Cypher) — outcomes depend on traversal/confidence dynamics

Output format per finding:
```
[P0] Rule KGC2 (kg-construction): Extraction is bare zero-shot with no schema classification — noise/hallucinations enter the graph.
→ Adopt OntologyRAG-style schema classification at extraction time, or upgrade to Chain-of-Thought / Stepwise-Decomposition prompting.

[P1] Rule GDB1 (graph-database): Neo4j chosen for a streaming, sub-ms-latency workload.
→ Memgraph (native C++, in-memory, native Kafka/Redpanda connectors) fits real-time ingestion; Neo4j's JVM cold-start and heap overhead hurt here.
```

---

## Step 2: Output

Produce a structured graph-architecture report:

```
## Knowledge Graph Review: [area reviewed]

### P0 — Blocking (must fix before building)
- [finding + specific fix]

### P1 — Required (fix before production)
- [finding + specific fix]

### P2 — Advisory (improves quality / cost)
- [finding + specific fix]

### Architecture Recommendation
[Microsoft GraphRAG vs LazyGraphRAG vs LightRAG, with the data-volatility + cost rationale]

### Graph Database Recommendation
[Neo4j / Memgraph / FalkorDB based on workload, with the benchmark numbers that decided it]
```

---

## Anti-Skip Table

| Excuse | Counter |
|--------|---------|
| "Just use full GraphRAG, it's the standard" | Full GraphRAG pre-summarizes every entity and community with an LLM. LazyGraphRAG matches its global-search quality at 700x lower query cost via query-time lazy evaluation. Rule it out on evidence first. |
| "We'll extract entities and we're done" | Without entity resolution, "Olympic Winter Games" and "winter Olympic games" stay two nodes — splitting relationship paths and distorting node-degree metrics. Run the two-stage S-BERT → k-means → fused BM25 pipeline. |
| "Global search is most thorough, use it always" | Global search runs a Map-Reduce over entire community-report levels — prohibitively expensive and blind to granular edges. Local search (1-2 hop) answers entity-specific queries far cheaper. |
| "Neo4j is the graph database" | Neo4j pre-allocates 4-5 GB JVM heap and has slow cold starts. For 16k nodes Memgraph used 415 MB vs Neo4j's 2,668 MB. Match the engine to the workload. |
| "Auto-merge all the duplicates" | Auto-merge above a high threshold only. Moderate-confidence pairs get a temporary SAME_AS link routed to a human; auto-merging everything destroys auditability in legal/clinical graphs. |
| "Skip the ontology, let the LLM figure it out" | Bottom-up-only extraction drifts. Use top-down OWL guidance for competency questions + bottom-up LLM refinement; classify each entity against the schema BEFORE storing it. |
| "Just use GraphRAG, the task mentions a knowledge graph" | GraphRAG's edge is multi-hop aggregation (HippoRAG 87.9–90.9% L2–L3 evidence recall). For single-fact lookup, a reranked flat RAG wins (Novel fact best 60.92%) at near-zero index cost. Classify the query shape first (ARC7) — only build graph when it's multi-hop. |
| "Kuzu embedded is a lightweight option" / "use RedisGraph" | Stale knowledge. Kuzu's repo was archived after the 2025-10 Apple acquisition (abandonment risk); RedisGraph hit EOL 2025-01 → migrate to FalkorDB (its direct successor). Neither belongs in a new long-term build. |

---

## Tool / Framework Quick Reference

| Tool / Framework | Role | Primary Use |
|------------------|------|-------------|
| Microsoft GraphRAG | Indexing + search | Leiden communities, Global/Local/Drift search over static/batch corpora |
| LazyGraphRAG | Cost-optimized GraphRAG | Lazy query-time evaluation; ~0.1% indexing cost; 700x cheaper global queries |
| LightRAG | Incremental GraphRAG | Dual-level KV retrieval, <100 tokens for the retrieval keyword-generation step (LightRAG-reported setup; total query cost adds retrieved context + generation), incremental updates |
| Neo4j | LPG database | Large historical graphs; index-free adjacency; Causal Clustering (N=2F+1) |
| Memgraph | In-memory LPG | Sub-ms latency; native Kafka/Redpanda/Pulsar streaming connectors |
| FalkorDB | Matrix-based LPG | Compressed sparse matrices on Redis; high QPS, bounded p99 (136 ms vs Neo4j 46,924 ms on Pokec); bulk-import throughput (22,784 rows/s @ batch 5k); successor to EOL'd RedisGraph |
| ~~Kuzu (embedded)~~ | ⚠️ DEPRECATED | Repo archived after 2025-10 Apple acquisition — do NOT pick for new long-term builds; no first-party successor (re-match via GDB1) |
| ~~RedisGraph~~ | ⚠️ DEPRECATED (EOL 2025-01) | Migrate to FalkorDB (direct, drop-in successor) |

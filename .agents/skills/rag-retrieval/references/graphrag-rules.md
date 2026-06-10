# GraphRAG & Relational Retrieval Rules
<!-- capability: graphrag -->

> **Pack boundary (cross-reference):** This section covers the *in-RAG decision* — when to reach for graph-structured retrieval inside a RAG pipeline. For deep knowledge-graph **construction** (ontology design, LLM entity/relation extraction, entity resolution), **graph-DB selection** (Neo4j / Memgraph / FalkorDB, LPG vs RDF-Star), or **query translation** (Text2Cypher / SPARQL), defer to the dedicated **`knowledge-graph`** capability pack — it owns that depth. Use these GR rules only for the lightweight "do I need graph retrieval here?" judgment.

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| GR1 | Use GraphRAG for multi-hop/relational queries — reduces factual errors 35–45% | deterministic |
| GR2 | Ingestion pipeline: NER → Relation Extraction → Coreference → Canonicalization | deterministic |
| GR3 | Enforce metadata governance — ungoverned data yields 30–40% more duplicate/ambiguous nodes | semi-deterministic |
| GR4 | Traversal selection: Local (targeted) / Global (Leiden corpus-wide) / Agentic | deterministic |
| GR5 | Unified storage (pgvector + JSONB + recursive CTEs) avoids 3-database sprawl | deterministic |
| GR6 | Zero-ETL engine (PuppyGraph) — multi-hop over massive data in under 3s | deterministic |

---

## Rules

### GR1: Use GraphRAG for Multi-Hop / Relational Queries

When queries require **reasoning across multiple documents** — change-impact analysis, dependency tracing, multi-hop QA — vector RAG is the wrong tool. Vector RAG flattens text into isolated chunks retrieved by raw semantic similarity and **cannot follow logical connections** across sources.

GraphRAG structures information as a knowledge graph of explicit entity-relationship paths. A Stanford study on knowledge-intensive NLP found graph-augmented retrieval **reduced factual errors by 35% to 45%** vs vector-only approaches on multi-hop QA benchmarks.

**Rule**: Single-fact lookup → vector RAG. Multi-hop / highly-connected-structure queries → GraphRAG. The 35–45% factual-error reduction is the payoff for the higher ingestion cost.

> Source: findings.md "GraphRAG Architectures and Relational Knowledge Integration" + Vector-vs-Graph trade-off table [32, 33, 34]

**determinismLevel**: deterministic.

### GR2: Knowledge Graph Ingestion Pipeline

When building the knowledge graph, run the multi-stage NLP pipeline in order. Building blocks are semantic triples `[Entity A] --[relationship]--> [Entity B]`:

1. **Named Entity Recognition (NER)** — extract entities (systems, personnel, packages)
2. **Relation Extraction** — identify connections (`Service A` "depends on" `Service B`)
3. **Coreference Resolution** — link variations ("Dr. Smith", "John Smith", "he") to one node
4. **Entity Canonicalization** — normalize and deduplicate nodes

Ingestion chunks for this pipeline are **500–1000 overlapping tokens** (see chunking-rules CH7) to capture entity co-occurrence.

> Source: findings.md "Knowledge Graph Construction and Ingestion" + "GraphRAG Pipeline" [32, 34]

**determinismLevel**: deterministic.

### GR3: Enforce Metadata Governance During Extraction

When extracting entities, **enforce strict metadata governance**. Extraction pipelines run on **ungoverned source data produce 30% to 40% more duplicate or ambiguous nodes** — e.g., failing to distinguish "Customer" the trial user from "Customer" the paying account — which causes downstream retrieval errors.

**Rule**: Governance is not optional polish; it directly determines graph quality. Budget canonicalization/deduplication effort proportional to source-data cleanliness.

> Source: findings.md "Knowledge Graph Construction and Ingestion" [34]

**determinismLevel**: semi-deterministic — duplicate rate depends on source-data governance.

### GR4: Graph Traversal Method Selection

When querying the graph, pick the traversal method by query shape:

| Method | Use For | Mechanism |
|--------|---------|-----------|
| **Local GraphRAG** | Specific, targeted queries | Map seed entities to nodes; traverse neighbors via DFS/BFS to a local subgraph |
| **Global GraphRAG** | Corpus-wide / exploratory | Cluster the graph into hierarchical communities via **Leiden community detection**; summarize each; query across summaries |
| **Agentic GraphRAG** | Complex, open-ended | An LLM agent plans, executes, and iteratively refines multiple graph queries |

> Source: findings.md "Graph Traversal and Retrieval Methodologies" [32]

**determinismLevel**: deterministic.

### GR5: Unified Storage Avoids Multi-Database Sprawl

When deploying GraphRAG, avoid the standard 3-system split (vector DB + graph DB like Neo4j + relational DB for metadata), which multiplies infrastructure complexity, **synchronization risk, and operational cost**.

Instead deploy a **unified database** (e.g., YugabyteDB): `pgvector` columns for embeddings, **JSONB** columns for flexible entity properties, and recursive SQL **Common Table Expressions (CTEs)** for graph traversal — one store, no sync pipelines.

> Source: findings.md "Multi-Database Sprawl vs. Unified Storage" + "Scaled Relational Reasoning Architecture" [22]

**determinismLevel**: deterministic.

### GR6: Zero-ETL Graph Engines

When the graph must stay in sync with production systems in real time, avoid maintaining traditional ETL pipelines into a dedicated graph DB. Use a **Zero-ETL graph query engine** (e.g., **PuppyGraph**) that runs directly on existing SQL databases / lakehouse tables, mapping relational tables to nodes and edges via JSON config — bypassing migration and executing **multi-hop neighbor searches over massive datasets in under 3 seconds**.

> Source: findings.md "Traditional ETL vs. Zero-ETL Graph Engines" [32]

**determinismLevel**: deterministic.

---

## Anti-Patterns

- **GraphRAG for simple lookups**: Its ingestion overhead is very high (multi-stage extraction + dedup). Use vector RAG for independent-fact retrieval; reserve GraphRAG for multi-hop.
- **Skipping coreference/canonicalization**: Ungoverned extraction yields 30–40% more duplicate/ambiguous nodes that corrupt retrieval.
- **Three-database sprawl by default**: Unified storage (pgvector + JSONB + recursive CTEs) avoids sync risk for most workloads.
- **Hand-built ETL into a graph DB**: Zero-ETL engines (PuppyGraph) query SQL tables as a virtual graph with no migration and sub-3-second multi-hop search.

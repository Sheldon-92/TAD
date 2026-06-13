# Query Translation (Text2Cypher / Cypher-RAG / SPARQL-Star) Rules
<!-- capability: query_translation -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| QT1 | Retrieval branches into query-based (NL→graph query) vs content-based (pre-structured paths) | deterministic |
| QT2 | Cypher-RAG generates executable Cypher from NL; verify syntax + schema-match before running | semi-deterministic |
| QT3 | Self-correcting loop: feed DB error back to model, retry up to 4 refinement iterations | non-deterministic |
| QT4 | Softmax routing: route to GraphRAG vs VectorRAG by a selection threshold τ = 0.5 | semi-deterministic |
| QT5 | RDF stores: query edge metadata with SPARQL-Star embedded-triple patterns | deterministic |

---

## Rules

### QT1: Query-Based vs Content-Based Retrieval

When designing the retrieval layer, branch into the two methodologies:

- **Query-based retrieval:** translate the natural-language question directly into a structured graph query (**Cypher** or **Gremlin**) and execute it against the DB to return explicit subgraphs and entities.
- **Content-based retrieval:** extract and feed pre-structured graph content — specific nodes, **triple paths**, and subgraphs — directly as LLM context.

Query-based gives absolute multi-hop precision; content-based avoids generation/execution risk. Pick per query type.

> Source: findings.md §"Evolution of Context-Aware Information Retrieval" — query-based (Cypher/Gremlin) vs content-based (nodes/triple paths/subgraphs) [6].

**determinismLevel**: deterministic — an architectural branch.

### QT2: Cypher-RAG Generation with Verification

When translating NL → Cypher (Text2Cypher / Cypher-RAG), do NOT execute the first generated query blindly. Use the multi-agent coordination pattern:

- A representative Cypher-RAG system uses **seven specialized agents** for: NL→Cypher generation, **syntactic verification**, **schema matching**, feedback collection, and answer synthesis.
- Verify syntax AND schema-match the generated query against the live schema **before** execution.

**Calibrate your success expectation — "generate then execute" without verification is a near-coin-flip-down failure.** On the Neo4j **Text2Cypher (2024)** dataset (4 fine-tuned models + 10 base models evaluated), top systems (OpenAI **GPT-4o** and the fine-tuned **tomasonjo_text2cypher**) reached only **~30% execution-based match rate**. That is the empirical ceiling for blind generation — which is exactly why QT2's **syntactic verification + schema matching** and QT3's **self-correction loop** are non-optional, not nice-to-haves. Design the pipeline assuming ~70% of first-shot generations need repair or rejection.

> Source: findings.md §2 "Cypher-RAG Agentic Query Translation" — seven-agent orchestration (generation, syntactic verification, schema matching, feedback, synthesis) [2]. Execution-match calibration (refreshed): Neo4j — Benchmarking the Neo4j Text2Cypher (2024) dataset — https://neo4j.com/blog/developer/benchmarking-neo4j-text2cypher-dataset/ (retrieved 2026-06-13): GPT-4o / tomasonjo_text2cypher ~30% execution-based match. New grounded eval anchor: IBM "Mind the Query" (EMNLP 2025), 27,529 NL→Cypher pairs across 11 real graph DBs, each with an executable Neo4j graph for grounded validation — https://research.ibm.com/publications/mind-the-query-a-benchmark-dataset-towards-text2cypher-task (retrieved 2026-06-13).

**determinismLevel**: semi-deterministic — pipeline fixed; generated queries vary.

### QT3: Self-Correcting Execution Loop (≤4 Iterations)

When a generated Cypher query fails at execution:

1. **Catch the database error** (do not surface it to the user).
2. **Pass the error log + schema back to the model.**
3. The agent **reconstructs the query** from the error + schema.
4. Retry — execute **up to 4 refinement iterations** to maximize success, then stop.

Hard-cap at 4 iterations; an uncapped retry loop burns tokens on unfixable queries. This loop is load-bearing precisely because blind first-shot generation only executes-matches **~30%** of the time (see QT2 calibration) — the 4 iterations are where most of the remaining successes are recovered, but the cap stops the unfixable ~tail from burning unbounded tokens.

> Source: findings.md §2 — self-correcting execution loop, error-log + schema feedback, up to 4 refinement iterations [2, 42]. Calibration cross-ref: Neo4j Text2Cypher ~30% blind execution-match — https://neo4j.com/blog/developer/benchmarking-neo4j-text2cypher-dataset/ (retrieved 2026-06-13).

**determinismLevel**: non-deterministic — outcome depends on the model's repair of each error.

### QT4: Softmax Routing Between GraphRAG and VectorRAG

When a system can serve a query from either a graph retriever or a vector retriever, route with the orchestration controller's **softmax** distribution over retrieval modes:

- Compute a probability distribution over retrieval modes and route to **GraphRAG or VectorRAG** based on a **selection threshold τ = 0.5**.

This prevents sending every query down the expensive graph path when vector retrieval suffices.

> Source: findings.md §2 — Softmax routing over retrieval modes, selection threshold τ = 0.5 [2].

**determinismLevel**: semi-deterministic — threshold fixed; per-query scores vary.

### QT5: SPARQL-Star for Edge Metadata (RDF Stores)

When the store is RDF and the query targets relationship-level metadata (confidence, timestamp on an edge), use **SPARQL-Star** embedded-triple patterns rather than reification joins:

```sparql
# Legacy SPARQL-star syntax (RDF-star CG spec) — may fail on RDF/SPARQL 1.2 engines; verify target-store support
PREFIX ex: <http://example.org/>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
SELECT ?person ?age ?certainty WHERE {
  <<?person foaf:age ?age>> ex:certainty ?certainty .
}
```

The `<< ... >>` quoted triple lets you bind a property asserted ON a triple in one pattern. ⚠️ This is **legacy SPARQL-star** (RDF-star Community Group spec); RDF/SPARQL 1.2 revised the triple-term model, so confirm whether your engine implements legacy RDF-star or RDF 1.2 and use the matching syntax.

> Source: findings.md §1 "Labeled Property Graphs versus RDF Star" — SPARQL-Star edge-metadata query over embedded triples [39, 40]. NOTE: cited syntax is legacy SPARQL-star; RDF/SPARQL 1.2 differs — verify engine support.

**determinismLevel**: deterministic — a query-syntax rule.

---

## Anti-Patterns

- **Executing generated Cypher unverified**: skip syntactic verification + schema matching and you run hallucinated queries against production.
- **Uncapped retry loop**: without the 4-iteration cap a self-correcting agent burns tokens on unfixable queries.
- **Routing everything to GraphRAG**: ignoring the τ=0.5 softmax gate sends cheap vector-answerable queries down the expensive graph path.
- **Reification joins for edge metadata in RDF**: SPARQL-Star embedded triples express it directly without the join blowup.
- **Query-based when content-based fits**: generating + executing a query when a pre-structured triple-path context would answer it.

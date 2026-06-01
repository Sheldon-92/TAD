# Graph Database Selection Rules
<!-- capability: graph_database -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| GDB1 | Engine selection: Neo4j (disk/historical) vs Memgraph (in-mem/streaming) vs FalkorDB (matrix/throughput) | deterministic |
| GDB2 | Storage model: LPG (closed-world) vs RDF triple store (open-world, global URIs) | deterministic |
| GDB3 | Edge metadata on RDF → use RDF-Star embedded triples, not reification | deterministic |
| GDB4 | Indexing is decisive: latency drops orders of magnitude when indexed | semi-deterministic |
| GDB5 | Neo4j HA quorum is N=2F+1; FalkorDB throughput plateaus beyond 8 threads | deterministic |

---

## Rules

### GDB1: Engine Selection by Workload

When choosing the LPG engine, match it to the workload — do not pick Neo4j by reflex:

| Engine | Architecture | Choose When | Watch Out For |
|--------|-------------|-------------|---------------|
| **Neo4j** | Native graph on JVM with page caching; **index-free adjacency** (nodes hold direct pointers to adjacent relationships) | Large historical graphs that must scale **past physical RAM** (on-disk + page cache); need ACID + Causal Clustering | Significant JVM heap overhead; slower cold starts |
| **Memgraph** | Native **C++ in-memory-first**; WAL + periodic snapshots for durability | Real-time / streaming ingestion, **sub-millisecond** query latency; native **Kafka / Redpanda / Pulsar** connectors | Vertical memory scaling — active graph must fit in RAM |
| **FalkorDB** | In-memory on **Redis**; nodes/relationships as **compressed sparse matrices** → graph ops map to linear-algebra | Cost-sensitive in-memory apps needing high throughput + low memory footprint | Redis single-threaded core → concurrent throughput **plateaus beyond 8 threads** |

**Benchmark numbers (use these to decide, not vibes):**

| Metric | Neo4j | Memgraph | FalkorDB |
|--------|-------|----------|----------|
| Avg Query QPS (8 threads) | 738 | 467 | 837 |
| Peak Memory (16k nodes) | 2,668 MB JMX heap (pre-allocates 4-5 GB) | 415 MB | 496 MB |
| Streaming | External connectors / ETL | Native Kafka/Redpanda/Pulsar | External via Redis commands |

> Source: findings.md §3 "Operational Database Profiles" + operational-metric table — QPS 738/467/837, memory 2668/415/496 MB, native streaming connectors, index-free adjacency [36, 43, 44, 45].

**determinismLevel**: deterministic — selection from fixed architectural profiles.

### GDB2: LPG vs RDF Storage Model

When choosing the storage paradigm:

- **Labeled Property Graph (LPG)** — Neo4j, Memgraph, FalkorDB. Nodes, relationships, and properties are first-class citizens. **Closed-world assumption**. Intuitive for app developers; efficient multi-hop traversals.
- **RDF triple store** — subject-predicate-object statements with global **URIs** under an **open-world assumption**. Best for integrating distributed datasets with semantic interoperability.

Rule: pick LPG for application-centric, traversal-heavy GraphRAG; pick RDF when you must federate distributed data under global identifiers.

> Source: findings.md §1 "Labeled Property Graphs versus RDF Star" — LPG closed-world first-class properties [7]; RDF global URIs open-world [7, 38].

**determinismLevel**: deterministic — paradigm choice.

### GDB3: Edge Metadata via RDF-Star (Not Reification)

When you need properties ON an edge (timestamp, confidence score on a relationship) in an RDF store, historically RDF required **reification**, which significantly increases graph size and query complexity. Use **RDF-Star** instead — embedded triples in double angle brackets:

```turtle
<<:bob :age 23>> :certainty 0.9 .
<<:man :hasSpouse :woman>> :startDate "2020-02-11"^^xsd:date .
```

Query relationship-level metadata directly with **SPARQL-Star**:

```sparql
PREFIX ex: <http://example.org/>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
SELECT ?person ?age ?certainty WHERE {
  <<?person foaf:age ?age>> ex:certainty ?certainty .
}
```

This bridges RDF's semantic interoperability with LPG-style expressive edge metadata.

> Source: findings.md §1 — RDF-Star embedded triples + SPARQL-Star query, reification size/complexity penalty [38, 39, 40].

**determinismLevel**: deterministic — a syntax/modeling decision.

### GDB4: Indexing Is Decisive

When tuning query latency, indexing is not optional — its impact is order-of-magnitude:

- **Neo4j**: latency drops **1712x** when indexed.
- **Memgraph**: latency drops **160-898x** depending on query.
- **FalkorDB**: low index sensitivity — Redis hashes serve as implicit indexes.

Always profile indexed vs unindexed before declaring a latency problem an architecture problem.

> Source: findings.md §3 operational-metric table "Index Sensitivity" — Neo4j 1712x, Memgraph 160-898x, FalkorDB Redis-hash implicit [45].

**determinismLevel**: semi-deterministic — speedup ranges depend on query shape.

### GDB5: Clustering Quorum and Concurrency Ceilings

When designing for availability/scale:

- **Neo4j Causal Clustering** uses the **Raft** consensus protocol. To tolerate **F** concurrent faults the cluster needs a primary quorum of **N = 2F + 1** primary servers.
- **FalkorDB** concurrent throughput **plateaus beyond 8 threads** (Redis single-threaded core) — do not plan for linear scaling past 8 threads.
- **Memgraph** scales vertically (replication) and is bounded by RAM — the active graph must fit in physical memory.

> Source: findings.md §3 Neo4j — Raft quorum N=2F+1 [36]; FalkorDB §3 8-thread plateau [45]; Memgraph RAM bound [36, 43].

**determinismLevel**: deterministic — formula + documented limits.

---

## Anti-Patterns

- **Neo4j by reflex**: pre-allocates 4-5 GB JVM heap (2,668 MB for 16k nodes vs Memgraph 415 MB) and cold-starts slowly — wrong for lean/streaming workloads.
- **RDF reification for edge metadata**: bloats the graph and complicates queries — RDF-Star solves it natively.
- **Planning FalkorDB past 8 threads**: throughput plateaus at the Redis single-threaded core.
- **Blaming architecture for latency before indexing**: a missing index costs up to 1712x on Neo4j.
- **Streaming through Neo4j ETL when Memgraph has native connectors**: adds an avoidable pipeline hop.

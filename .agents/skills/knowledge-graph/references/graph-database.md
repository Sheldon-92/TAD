# Graph Database Selection Rules
<!-- capability: graph_database -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| GDB1 | Engine selection: Neo4j (disk/historical) vs Memgraph (in-mem/streaming) vs FalkorDB (matrix/throughput) | deterministic |
| GDB2 | Storage model: LPG (closed-world) vs RDF triple store (open-world, global URIs) | deterministic |
| GDB3 | Edge metadata on RDF → use RDF-Star embedded triples, not reification | deterministic |
| GDB4 | Indexing is decisive: latency drops orders of magnitude when indexed | semi-deterministic |
| GDB5 | Neo4j HA quorum is N=2F+1; FalkorDB plateaus beyond 8 threads; ingestion throughput is batch-dependent (Memgraph small / FalkorDB bulk / Neo4j flat) | deterministic |

> ⚠️ **Deprecated engines** (do NOT recommend for new builds): **Kuzu** embedded (archived after 2025-10 Apple acquisition) and **RedisGraph** (EOL 2025-01 → migrate to FalkorDB). See the "Deprecated / Old-Pattern Engines" section at the end of this file.

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

**Refreshed latency profile (2026 vendor benchmark, FalkorDB vs Neo4j).** On the SNAP Pokec social graph, 16-CPU / 32 GB, 82% read / 18% write across 11 templated queries:

| Engine | p50 | p90 | p99 | p50→p99 amplification | Cold start |
|--------|-----|-----|-----|------------------------|-----------|
| **FalkorDB** | 55 ms | 108 ms | **136.2 ms** | **2.5x** (tail stays bounded) | 1.1 ms (first query 0.4 ms); ~6,693 QPS |
| **Neo4j** | 577.5 ms | 4,784.1 ms | **46,923.8 ms** | **~81x** (tail blows up) | accepts first query ~90 ms after restart; first warm-up query 274 ms; settles to ~34 ms after ~3 queries |

The decision signal is the **p99 magnitude** (FalkorDB 136 ms vs Neo4j 46,924 ms) and the **tail amplification** (2.5x vs ~81x), not p50 alone — a workload with SLO on the tail cannot absorb Neo4j's p99 blow-up here. ⚠️ These are **vendor self-published** numbers on one synthetic workload; treat as a magnitude prior to confirm on your own data, not a production guarantee.

> Source (refreshed): FalkorDB vs Neo4j graph-database performance benchmark — https://www.falkordb.com/blog/graph-database-performance-benchmarks-falkordb-vs-neo4j/ (retrieved 2026-06-13). p50/p90/p99 55/108/136.2 ms vs 577.5/4784.1/46923.8 ms; 6,693 QPS; cold-start 1.1 ms vs ~90/274/34 ms.

**determinismLevel**: deterministic — selection from fixed architectural profiles.

### GDB2: LPG vs RDF Storage Model

When choosing the storage paradigm:

- **Labeled Property Graph (LPG)** — Neo4j, Memgraph, FalkorDB. Nodes, relationships, and properties are first-class citizens. **Closed-world assumption**. Intuitive for app developers; efficient multi-hop traversals.
- **RDF triple store** — subject-predicate-object statements with global **URIs** under an **open-world assumption**. Best for integrating distributed datasets with semantic interoperability.

Rule: pick LPG for application-centric, traversal-heavy GraphRAG; pick RDF when you must federate distributed data under global identifiers.

> Source: findings.md §1 "Labeled Property Graphs versus RDF Star" — LPG closed-world first-class properties [7]; RDF global URIs open-world [7, 38].

**determinismLevel**: deterministic — paradigm choice.

### GDB3: Edge Metadata via RDF-Star (Not Reification)

When you need properties ON an edge (timestamp, confidence score on a relationship) in an RDF store, historically RDF required **reification**, which significantly increases graph size and query complexity. The **legacy RDF-Star / Turtle-star** approach embeds triples in double angle brackets:

```turtle
# Legacy RDF-star / Turtle-star (RDF-star CG spec) — verify target-store support
<<:bob :age 23>> :certainty 0.9 .
<<:man :hasSpouse :woman>> :startDate "2020-02-11"^^xsd:date .
```

> ⚠️ This `<< ... >>` embedded-triple notation is **legacy RDF-star/Turtle-star** (RDF-star Community Group spec), NOT current RDF 1.2. RDF 1.2 substantially revised this area — it introduces **triple terms** and `rdf:reifies`-based reification with new syntax (e.g. `<<( ... )>>` triple terms and reifiedTriple shorthand) and changed semantics. Triplestore support varies widely. Before adopting, confirm whether your target store implements legacy RDF-star or RDF 1.2, and use the matching syntax.

Query relationship-level metadata directly with **SPARQL-Star** (legacy; the RDF 1.2 equivalent differs):

```sparql
# Legacy SPARQL-star — may fail on RDF/SPARQL 1.2-compliant engines
PREFIX ex: <http://example.org/>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
SELECT ?person ?age ?certainty WHERE {
  <<?person foaf:age ?age>> ex:certainty ?certainty .
}
```

This bridges RDF's semantic interoperability with LPG-style expressive edge metadata.

> Source: findings.md §1 — RDF-Star embedded triples + SPARQL-Star query, reification size/complexity penalty [38, 39, 40]. NOTE: the cited syntax is legacy RDF-star/SPARQL-star; RDF 1.2 (W3C rdf12-turtle) changed the model — check target-store support.

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

**Ingestion throughput depends on BATCH size — pick the engine by your write pattern, not a single "fastest" label:**

| Batch size | Fastest engine | Numbers |
|------------|----------------|---------|
| **batch = 1** (real-time, per-event writes) | **Memgraph** | ~1,427 rows/s — leads at small batches |
| **batch ≈ 500** (crossover) | FalkorDB overtakes Memgraph | FalkorDB rises steeply with batch size |
| **batch = 5,000** (bulk import) | **FalkorDB** | 22,784 rows/s (**77x** its own batch-1 rate) |
| any batch | **Neo4j plateaus** | flat at **~10,600 rows/s** regardless of batch size |

Rule: small-batch / streaming inserts → **Memgraph**; large bulk imports → **FalkorDB** (its batched insert is the dominant lever); Neo4j's ingestion is batch-insensitive, so increasing your batch buys you nothing there.

> Source: findings.md §3 Neo4j — Raft quorum N=2F+1 [36]; FalkorDB §3 8-thread plateau [45]; Memgraph RAM bound [36, 43]. Ingestion tiering (refreshed): AIMultiple graph-database benchmark — https://aimultiple.com/graph-databases (retrieved 2026-06-13): batch-1 Memgraph 1,427/s; crossover ~batch 500; FalkorDB batch-5,000 22,784/s; Neo4j flat ~10,600/s.

**determinismLevel**: deterministic — formula + documented limits.

---

## Anti-Patterns

- **Neo4j by reflex**: pre-allocates 4-5 GB JVM heap (2,668 MB for 16k nodes vs Memgraph 415 MB) and cold-starts slowly — wrong for lean/streaming workloads.
- **RDF reification for edge metadata**: bloats the graph and complicates queries — RDF-Star solves it natively.
- **Planning FalkorDB past 8 threads**: throughput plateaus at the Redis single-threaded core.
- **Blaming architecture for latency before indexing**: a missing index costs up to 1712x on Neo4j.
- **Streaming through Neo4j ETL when Memgraph has native connectors**: adds an avoidable pipeline hop.

---

## ⚠️ Deprecated / Old-Pattern Engines (DO NOT recommend for new long-term builds)

> This section is **deliberately isolated** so the engine-selection rules above stay free of time-sensitive failure modes. An engine listed here was once a reasonable candidate but has been **archived or end-of-lifed** — recommending it for a new project plants a future migration burden. Verify status against the source before relying on any of these.

| Engine | Status | What to do instead |
|--------|--------|--------------------|
| **Kuzu** (embedded LPG, columnar, Cypher) | **Archived.** Kuzu was acquired by **Apple in 2025-10**; following the acquisition the GitHub repo was **archived** and most public resources were taken down. A community fork exists but carries **abandonment risk** (no guaranteed maintainer, security patches, or release cadence). | Do **not** pick Kuzu embedded as a long-term dependency for a new project. If you already depend on it, **plan a migration** (to an actively maintained embedded option or to Neo4j/Memgraph/FalkorDB per the GDB1 workload match). If you must stay on the fork, pin the version and budget for self-maintenance. |
| **RedisGraph** (matrix-based graph module on Redis) | **EOL 2025-01.** No further releases or support. | Migrate to **FalkorDB**, its **direct successor** — same compressed-sparse-matrix / linear-algebra architecture on Redis, actively maintained. The GDB1 FalkorDB profile applies. |

**Rule**: when an agent's training data surfaces Kuzu-embedded or RedisGraph as a candidate, treat that as **stale knowledge** — both are off the new-build menu as of 2026-06-13. RedisGraph → FalkorDB is a drop-in lineage; Kuzu-embedded has **no first-party successor**, so its replacement is a workload re-match via GDB1.

> Source: Kuzu/Apple acquisition + repo archive — https://9to5mac.com/2026/02/11/kuzu-database-company-joins-apples-list-of-recent-acquisitions/ and https://cs.uwaterloo.ca/news/waterloo-based-graph-database-start-up-kuzu-acquired-apple (retrieved 2026-06-13). RedisGraph EOL 2025-01 / FalkorDB succession — FalkorDB benchmark + positioning, https://www.falkordb.com/blog/graph-database-performance-benchmarks-falkordb-vs-neo4j/ (retrieved 2026-06-13).

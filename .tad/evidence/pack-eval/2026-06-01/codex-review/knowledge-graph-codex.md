[P0] “Level 0 (root): broad, generic parent communities … Higher levels (e.g. Level 3): specific”
Why wrong: This reverses Microsoft GraphRAG’s documented level semantics; lower hierarchy levels are the more detailed/community-heavy reports, and higher levels are broader/coarser. Microsoft also references C2 as the third hierarchy level, not “Level 0 root.” Source: https://microsoft.github.io/graphrag/query/global_search/
Fix: Say “verify level semantics from the generated index; in Microsoft GraphRAG, lower levels are more detailed and higher levels are broader/coarser.”

[P0] “broad ‘summarize the field’ → low level; specific sub-topic → higher level”
Why wrong: Same inversion. This routes queries to the wrong community level and can inflate cost or miss detail.
Fix: Reverse the routing guidance and add a calibration step over representative queries.

[P0] “Use RDF-Star instead — embedded triples in double angle brackets: `<<:bob :age 23>> :certainty 0.9 .`”
Why wrong: This is legacy Turtle-star syntax, not current RDF 1.2 Turtle syntax; current RDF 1.2 triple terms changed substantially and triplestore support varies. Source: https://www.w3.org/TR/rdf12-turtle/
Fix: Either label this explicitly as legacy RDF-star/SPARQL-star syntax, or update to RDF/SPARQL 1.2-compatible modeling and require checking target-store support.

[P0] “Query relationship-level metadata directly with SPARQL-Star: `<<?person foaf:age ?age>> ex:certainty ?certainty .`”
Why wrong: Same legacy SPARQL-star assumption. It may fail as written in RDF/SPARQL 1.2-compliant tools.
Fix: Provide separate examples for legacy RDF-star engines and RDF/SPARQL 1.2 engines.

[P1] “Fixed Indexing Pipeline Order … `create_base_text_units` … `generate_embeddings`”
Why wrong: Current Microsoft GraphRAG docs describe configurable workflows and the current embedding workflow is `generate_text_embeddings`, not `generate_embeddings`; hardcoding old/internal step names invites broken configs. Source: https://microsoft.github.io/graphrag/index/overview/
Fix: Describe conceptual phases, or update exact workflow names to the currently supported version and pin the GraphRAG version.

[P1] “Global Search … Map step runs `MATCH (c:__Community__) WHERE c.level = $level RETURN c.full_content AS output`”
Why wrong: This is Neo4j-specific, but the pack presents it as Microsoft GraphRAG’s generic global-search mechanism. Microsoft GraphRAG global search operates over indexed community reports; Neo4j/Cypher is optional integration-specific. Source: https://microsoft.github.io/graphrag/query/global_search/
Fix: Mark the Cypher as “Neo4j implementation example only” and give the generic table/vector-store flow separately.

[P1] “LightRAG … `<100 tokens/query`”
Why wrong: The cited LightRAG number is typically retrieval/keyword-generation overhead, not total query prompt cost after retrieved context and answer generation. This underestimates production token spend.
Fix: Say “<100 tokens for retrieval keyword generation in the reported setup; total query cost includes retrieved context and generation.”

[P1] “k-means clustering (cluster size = 128) … top K = 16 candidates per entity”
Why wrong: These are suspiciously over-specific defaults from one pipeline, not universal graph-entity-resolution constants. Also, standard k-means controls number of clusters, not fixed cluster size.
Fix: Present 128 and 16 as starting hyperparameters, then require validation on precision/recall and review workload.

[P1] “Softmax routing … selection threshold τ = 0.5”
Why wrong: A fixed 0.5 threshold assumes calibrated probabilities and equal error costs. Retriever-router scores are usually uncalibrated and domain/cost dependent.
Fix: Calibrate τ on a labeled query set, tune for cost/quality tradeoff, and expose it as config.

[P1] “Labeled Property Graph … Closed-world assumption”
Why wrong: LPG is a data model, not inherently a formal closed-world semantics. RDF/OWL can be open-world, but SPARQL over a dataset is often operationally closed-world.
Fix: Rephrase as “LPG systems are commonly used with application-level closed-world assumptions; RDF/OWL supports open-world semantic reasoning.”

[P1] “the graph executes real-time fact invalidation based on these timestamps”
Why wrong: Bi-temporal timestamps enable invalidation logic; they do not by themselves execute invalidation. You still need validity intervals, supersession rules, conflict policy, and query filters.
Fix: Say “timestamps support real-time invalidation when paired with explicit invalidation rules and temporal query policy.”

[P1] “Best on Neo4j for large historical graphs”
Why wrong: Microsoft GraphRAG does not require Neo4j and stores outputs as indexed tables/vector data by default. This bakes in a vendor choice without workload evidence.
Fix: Separate GraphRAG architecture choice from graph database choice; pick Neo4j only when the serving/query workload justifies it.

VERDICT: FIX-FIRST

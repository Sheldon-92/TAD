**Findings**

**P0 - Cross-tenant RAG search leaks data boundaries.**  
Running global vector search first and filtering tenants afterward is not a safe multi-tenant design. Even if final results are dropped, candidate retrieval, logs, scores, traces, caches, metrics, or timing behavior can expose other tenants’ data. Tenant filtering must happen inside the retrieval query/index access path, ideally with tenant-scoped indexes or mandatory pre-filtering enforced by the vector store.

**P0 - Feature computation is duplicated between training and inference.**  
Computing 30-day order count separately in a notebook and live service is a classic training-serving skew risk. Differences in time windows, timezone handling, late-arriving orders, refunds/cancellations, deduplication, and boundary inclusivity can make the model train on one feature definition and serve on another. Move this into a shared feature pipeline or feature store with one tested definition used for both offline and online paths.

**P1 - 30-day order count may have temporal leakage in training.**  
If the notebook computes “last 30 days” relative to notebook execution time instead of each training example’s prediction timestamp, the model can see future orders. Training features must be point-in-time correct: for every label event, compute order count using only data available before that event.

**P1 - Overwriting customer dimension attributes loses historical correctness.**  
Tier and city as Type 1 overwritten dimensions will corrupt historical training examples. A customer’s current tier/city may be joined onto past support events, causing leakage and incorrect model behavior. Use slowly changing dimensions, typically SCD Type 2, with effective start/end timestamps and point-in-time joins.

**P1 - Embedding-only retrieval is weak for support RAG.**  
Embedding similarity alone may miss exact identifiers, product names, policy versions, error codes, order IDs, or tenant-specific terminology. Customer support RAG usually needs hybrid retrieval: metadata filters, lexical/BM25 matching, structured constraints, recency/version filters, and reranking.

**P1 - RAG retrieval lacks authorization-aware document filtering.**  
Tenant filtering alone may be insufficient. Support content often has access levels: customer-specific records, internal notes, region-specific policies, draft docs, deleted docs, or agent-only materials. Retrieval should enforce the same authorization model as the source systems before ranking results.

**P2 - Notebook-based training feature generation is not production-grade.**  
Training notebooks are hard to test, version, schedule, monitor, and reproduce. Promote feature logic into a versioned pipeline with data quality checks, lineage, schema validation, and backfills.

**P2 - Missing freshness and consistency controls.**  
The live 30-day count and dimension attributes need defined freshness SLAs. If orders or customer attributes update asynchronously, the model may receive stale or inconsistent features. Track feature timestamps and expose freshness metrics.

**P2 - Missing retrieval observability and evaluation.**  
For RAG, track recall, precision, tenant-filter behavior, empty-result rates, reranker quality, and answer attribution. Build eval sets with real support questions, tenant boundaries, and exact-match cases like policy IDs or product names.

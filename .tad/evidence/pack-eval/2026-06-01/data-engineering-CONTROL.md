# Data Pipeline Review — Customer-Support AI

Reviewer: Senior Data Engineer
Scope: Feature computation, RAG retrieval, customer dimension modeling

Overall: There are four distinct issues here, two of which are serious correctness/safety problems (train-serve consistency and multi-tenant data isolation), and two of which are design limitations that will hurt quality (retrieval-only embedding search, destructive dimension updates). I'll go through each.

---

## 1. 30-day order count computed twice (training notebook + inference service)

**Severity: High — this is a classic train/serve skew bug.**

You compute the same feature ("customer's 30-day order count") in two separate code paths: a training notebook and a live inference service. These will drift. They almost always do, for reasons that are easy to underestimate:

- **Definition mismatch.** Is "30-day" a rolling 30 days, or the trailing 30 calendar days? Inclusive/exclusive of today? Computed in UTC or the customer's local timezone? The notebook (often pandas) and the service (often SQL or a streaming store) will make different implicit choices.
- **Point-in-time correctness / leakage.** In training you compute the count "as of" each historical label time. If the notebook naively counts orders in the last 30 days relative to *now* instead of relative to the label timestamp, you leak future information and inflate offline metrics. At serving time you can only see the past, so the model underperforms in production versus the notebook.
- **Late-arriving and cancelled orders.** Training reads a settled historical table; the live service sees in-flight data where orders may still be pending, cancelled, or refunded. Counts differ.
- **Boundary/edge handling.** Null customers, returns counted or not, multiple line items vs. distinct orders — two implementations will diverge on these.

**Recommendations (in order of preference):**

1. **Single definition, shared code path.** Extract the feature logic into one library/SQL transformation that both training and serving import. Don't re-implement it in the notebook.
2. **Adopt a feature store** (Feast, Tecton, or a homegrown equivalent). The core value of a feature store here is exactly this: it provides *point-in-time correct* historical features for training and *low-latency online* features for serving from the *same definition*, plus offline/online consistency guarantees.
3. **If you can't do a feature store yet:** at minimum, log the feature values that the live service actually computed at inference time, and build your training set from those logged feature vectors ("log-and-wait" / feature logging). This guarantees training sees exactly what serving produced, eliminating skew by construction. The cost is you can't backfill features you didn't log.
4. **Add a skew monitor.** Periodically recompute a sample of training-time features through the serving path and assert they match within tolerance. Alert on divergence.

The decision between rolling vs. batch precompute matters for latency: a 30-day count can be served from a precomputed daily aggregate (cheap, slightly stale) or computed on-read (fresh, slower). Pick one definition and document the staleness SLA.

---

## 2. Global vector search across all tenants, then filter to the asking tenant

**Severity: Critical — this is both a data-isolation/security risk and a retrieval-quality bug.**

Doing a global ANN search and then post-filtering to the requesting tenant ("post-filtering") has two serious problems:

### 2a. Multi-tenant data leakage and security risk
You are searching across *all* customers' data in one index and relying on application code to drop the wrong-tenant results afterward. This is fragile:
- A bug, a refactor, or a logging statement that captures pre-filter results can leak Tenant B's support content into Tenant A's session. For a customer-support product this is a confidentiality breach (potentially PII / contractual / regulatory).
- The model/prompt assembly step sits between retrieval and the user; if any intermediate logs, caches, or traces the raw retrieved set, cross-tenant data ends up where it shouldn't.

### 2b. Retrieval quality — the "top-k then filter" recall problem
This is the part people miss. ANN search returns the top-k *globally nearest* vectors **before** your tenant filter runs. If a tenant is small relative to the corpus, the global top-k can be dominated by other tenants' documents, and after filtering you're left with very few (or zero) results for the asking tenant — even though that tenant has perfectly relevant documents that simply weren't in the global top-k. You silently lose recall, and it's worst for your smallest tenants.

**Recommendations:**

1. **Filter during the search, not after** ("pre-filtering" / metadata-filtered ANN). Modern vector DBs (Qdrant, Weaviate, Pinecone, pgvector with filtered indexes, Milvus) support filtering by a `tenant_id` payload/metadata field as part of the query so the k nearest are computed *within* the tenant's subset. This fixes the recall problem directly.
2. **Strong isolation for multi-tenancy.** Depending on your isolation requirements and tenant count:
   - **Partition / namespace per tenant** (e.g., Pinecone namespaces, Qdrant collections/shard keys, Weaviate multi-tenancy mode). Good default — strong isolation, good performance, scales to many tenants.
   - **Separate index/collection per tenant** for the highest isolation (few large tenants).
   - **Single index with mandatory `tenant_id` filter** enforced at a layer the application can't bypass — acceptable only if the DB does indexed pre-filtering and you treat the filter as a security control, not a convenience.
3. **Make tenant scoping non-bypassable.** The tenant filter should be injected by a trusted retrieval layer from the authenticated session, never passed in by the caller or assembled in prompt code. Add a test that asserts cross-tenant queries return zero foreign documents.

Treat the tenant boundary as a security boundary, not a ranking detail.

---

## 3. Retrieval is embedding-only

**Severity: Medium — quality limitation, not a correctness bug.**

Pure dense (embedding) retrieval has well-known weaknesses for a support use case:
- **Exact-match / rare tokens:** order IDs, SKUs, error codes, product names, account numbers. Embeddings are bad at exact lexical matches; a customer pasting `ERR-50321` or order `#A8842193` will often retrieve semantically-similar-but-wrong docs. Dense models also struggle with out-of-vocabulary terms and acronyms specific to your domain.
- **No keyword anchoring:** support content is full of specific product names and feature flags that benefit from lexical (BM25) matching.

**Recommendations:**

1. **Hybrid retrieval.** Combine dense (embedding) with sparse/lexical (BM25, or a learned sparse model like SPLADE) and fuse with **Reciprocal Rank Fusion (RRF)** or a weighted score. This is now the standard baseline for production RAG and reliably beats either method alone, especially on the exact-match cases above.
2. **Add a reranking stage.** Retrieve a larger candidate set (e.g., top-50 to top-100) with hybrid search, then rerank with a cross-encoder (e.g., Cohere Rerank, bge-reranker, or a hosted reranker) down to the top-3–5 you actually feed the model. Reranking typically gives a larger quality jump than swapping embedding models.
3. **Mind chunking and metadata.** Make sure chunks carry structured metadata (product, doc type, recency) so you can filter/boost — and so the tenant filter from #2 is even possible.
4. **Evaluate it.** Stand up a small retrieval eval set (questions → known-relevant docs) and measure recall@k / MRR / nDCG before and after adding hybrid + rerank. Don't tune retrieval by vibes.

Embedding-only is a fine *starting* point, but for support (lots of identifiers and product-specific jargon) hybrid + rerank is where the real gains are.

---

## 4. Customer dimension overwrites old values on change (tier, city)

**Severity: Medium-High — depending on whether you need history, this can corrupt training labels and break auditability.**

Overwriting the row in place is **Slowly Changing Dimension Type 1 (SCD Type 1)**. It keeps only the current value and destroys history. That's a deliberate, valid choice *for some attributes* — but it's almost certainly wrong here for two reasons:

1. **Point-in-time correctness for ML (again).** If a customer was `tier = free` when a support interaction happened and later upgraded to `tier = pro`, an SCD-1 table will tell your training pipeline they were `pro` at the time of every past interaction. Your features become retroactively wrong, you leak future state into historical training rows, and your offline metrics lie. The exact same leakage failure mode as #1.
2. **Auditability / debugging.** "Why did the bot route this customer to enterprise support last month?" is unanswerable if you've overwritten the tier they had last month.

**Recommendations:**

1. **Use SCD Type 2** for attributes that (a) change over time and (b) you need to reason about historically — `tier` is a prime candidate, and probably `city` too. Keep a row per version with `valid_from` / `valid_to` (and an `is_current` flag). Then your feature joins are "the tier *as of* the event timestamp," which is point-in-time correct.
2. **Cheaper alternatives if full SCD-2 is too much:**
   - **SCD Type 4 / history table:** keep current values in the dimension and push prior versions to a separate history table.
   - **Event log:** append a `customer_attribute_changed` event with a timestamp; you can reconstruct as-of state and it doubles as audit.
3. **Decide per attribute.** Not everything needs history. A corrected typo in a name is fine as SCD-1. But anything that feeds a model feature or a routing/eligibility decision should be versioned. Document the SCD type per column.
4. **Capture change timestamps regardless.** Even if you stay SCD-1 short-term, start recording `updated_at` and ideally CDC (change data capture) on this table now, so you can build history later. You can't recover history you never captured.

---

## Cross-cutting theme

Three of these four issues (#1, #2b, #4) are the **same root problem in different clothes: point-in-time correctness and consistency between the historical/training view and the live/serving view.** Your training data is being computed from a "now" snapshot while serving sees a different reality. The unifying fixes are:

- One feature definition, shared between train and serve (feature store or feature logging).
- As-of joins everywhere historical state matters (versioned dimensions, label-time feature computation).
- A skew/consistency monitor so drift is caught, not discovered in production.

And #2a / #3 are the support-domain specifics: **tenant isolation is a security boundary** (pre-filter or partition, never post-filter), and **embedding-only retrieval underperforms hybrid + rerank** for identifier-heavy support content.

### Suggested priority order
1. **Fix tenant isolation (#2a)** — security/confidentiality, highest risk.
2. **Fix train/serve feature skew (#1)** — correctness, affects every prediction.
3. **Switch dimension to SCD-2 / start capturing CDC (#4)** — correctness + the longer you wait the more history you lose.
4. **Pre-filtered/partitioned vector search (#2b)** — recall, ties into #2a.
5. **Hybrid retrieval + reranking (#3)** — quality uplift.

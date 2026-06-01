[P0] “Asymmetric models (Voyage AI, E5): MUST prepend prefixes — `query:` to queries and `passage:` to documents”
Why wrong: Voyage’s API uses `input_type: "query" | "document"` and automatically prepends its prompt; manual `query:` / `passage:` is wrong API guidance and can double-encode intent. Voyage docs: https://docs.voyageai.com/reference/embeddings-api-1
Fix: “For Voyage, set `input_type="query"` or `input_type="document"`. For E5-style open models, use the model-documented textual prefixes.”

[P0] “Cohere `embed-v4` and BGE-M3 produce dense, multi-vector, AND sparse retrieval in a single model execution”
Why wrong: Cohere Embed v4 exposes float/int8/uint8/binary/ubinary/base64 embedding types, not native sparse or multi-vector retrieval outputs. Cohere docs: https://docs.cohere.com/v2/reference/embed
Fix: Keep BGE-M3 as dense+sparse+multi-vector. Describe Cohere Embed v4 as multimodal embedding with quantized output types, not sparse/multi-vector hybrid.

[P0] “Voyage 3.5 | Dims | Low (3–8× shorter)”
Why wrong: This is not a dimension value. Voyage docs list `voyage-3.5` as 1024 default, configurable to 256/512/2048. Docs: https://docs.voyageai.com/docs/embeddings
Fix: Replace with actual dimensions: `1024 default; supports 256, 512, 2048`.

[P0] “When chunks are highly co-dependent... run the entire unsegmented document through a long-context embedding model FIRST to produce token-level vectors”
Why wrong: Standard embedding APIs return one vector per input, not token-level vectors. This advice is not implementable with OpenAI/Voyage/Cohere embedding APIs as written.
Fix: State that late chunking requires a local/model endpoint exposing token hidden states or token embeddings; otherwise use contextual chunk headers, parent-document retrieval, or overlapping windows.

[P0] “Causal language modeling... autoregressive decoding... needs multiple sequential passes”
Why wrong: Rerankers based on decoder LMs often score a yes/no token with one forward pass, or generate one token; they do not inherently require “multiple sequential passes.” The latency issue is architecture/size/prompt length, not necessarily repeated passes.
Fix: Say “decoder-only/prompt-based rerankers are often slower because they use larger generative models and longer pair prompts; measure batch latency against sequence-classification cross-encoders.”

[P0] “Pinecone namespace ceiling = 100,000”
Why wrong: Pinecone limits are plan-specific: 100 Starter, 1,000 Builder, 100,000 Standard/Enterprise, with larger namespace counts possible by support. Pinecone docs: https://docs.pinecone.io/reference/api/database-limits
Fix: “Namespaces per serverless index are plan-specific; validate current Pinecone limits for the target plan before designing tenant isolation.”

[P1] “Any Faithfulness score below 1.0 means the model is fabricating or relying on parametric memory”
Why wrong: Faithfulness measures support by retrieved context. A lower score can mean missing retrieval context, ambiguous claim extraction, evaluator error, or legitimate unstated reasoning, not necessarily fabrication or parametric-memory use. Ragas defines it as factual consistency with retrieved context: https://docs.ragas.io/en/latest/concepts/metrics/available_metrics/faithfulness/
Fix: “Faithfulness < 1.0 means at least one judged claim is unsupported by the provided context; investigate retrieval coverage, answer grounding, and judge variance.”

[P1] “gate production deployments on Faithfulness = 1.0”
Why wrong: This is an absolute gate on a noisy LLM-as-judge metric. It will create brittle false blocks unless paired with confidence intervals, sample size, judge calibration, and severity tiers.
Fix: Gate high-risk domains on zero critical unsupported claims plus human review; for general RAG, use calibrated thresholds over a representative eval set with repeated judge runs.

[P1] “Faithfulness 0.8... means 1 in 5 claims is hallucinated”
Why wrong: It means 1 in 5 extracted claims was judged unsupported by retrieved context. Unsupported is not synonymous with hallucinated.
Fix: Replace “hallucinated” with “unsupported by the retrieved context under the evaluator.”

[P1] “Reranking the top-50 captures roughly 90% of the accuracy gain of reranking the top-200... keeps end-to-end reranking under... 120ms P95”
Why wrong: This universalizes a latency/quality result that depends on reranker model, hardware, batching, document length, and corpus. The 120ms P95 claim is not portable.
Fix: Present it as a benchmark-derived starting point: “Start with top-50, then plot quality vs latency for your reranker/hardware.”

[P1] “Top 100 Candidates” and “Restrict Candidate Pool to ≤ 50”
Why wrong: The pack gives contradictory defaults for the same stage.
Fix: Use one rule: “Retrieve 100–200 for offline/high-recall evaluation; cap rerank candidates around 50 for latency-sensitive production unless eval proves otherwise.”

[P1] “For < 100M vectors, pgvector + pgvectorscale hit 471 QPS @ 99% recall — 11.4× Qdrant’s 41 QPS... Don’t add a second datastore prematurely.”
Why wrong: This turns a vendor/context-specific benchmark into a general routing rule. It omits filter workload, update rate, memory, HA/ops, query mix, index settings, and licensing/cloud constraints.
Fix: Say pgvector is the default candidate when Postgres ownership and relational joins matter, then benchmark against Qdrant/Weaviate/Milvus on the actual workload.

[P1] “the entire graph must reside in RAM”
Why wrong: Too absolute for HNSW. Many implementations persist the graph and may mmap/cache it; performance often expects RAM residency, but “must” is not generally true.
Fix: “HNSW has high memory pressure and performs best when the working graph fits in memory.”

[P1] “Page-Level chunking for paginated files (PDFs) containing tables”
Why wrong: Tables can span pages, and page-level chunking can split rows/headers across page boundaries. This is missing the critical caveat.
Fix: Use layout-aware/table-aware extraction; page-level is a baseline when tables are page-contained, with header carry-forward and cross-page table stitching.

[P1] “Always cite the specific threshold/number... a recommendation without the grounded number is generic advice”
Why wrong: This incentivizes false precision. Several thresholds in the pack are benchmark-specific, not universal engineering constants.
Fix: Require numbers only when scoped to corpus/model/hardware/eval conditions; otherwise require a measurement plan.

[P2] “Context | 8,000” for `text-embedding-3-large` / `text-embedding-3-small`
Why wrong: OpenAI commonly documents the embedding context around 8191 tokens, not exactly 8,000; this is a minor precision issue.
Fix: Use “~8k / 8191 tokens, verify current model docs.”

VERDICT: FIX-FIRST

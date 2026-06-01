[P0] “Instead append a `{"role": "system"}` block to the active messages list”
Why wrong: Anthropic Messages API does not accept `"system"` inside `messages`; system content belongs in the top-level `system` field. This would error as written. Official docs: https://docs.anthropic.com/en/api/messages  
Fix: Say “append dynamic guidance as a `user` message/content block or keep it in uncached top-level `system` content after the cached prefix if the provider supports block-level system arrays.”

[P0] “Use the correct tool per sub-block: … `core_memory_replace` … `core_memory_append`”
Why wrong: Letta docs now mark `core_memory_replace` and `core_memory_append` as deprecated; current tools are `memory_insert`, `memory_replace`, `memory_rethink`, and `memory_finish_edits`. Official docs: https://docs.letta.com/guides/ade/core-memory/  
Fix: Replace the table with current Letta memory tools, and mention legacy MemGPT tool names only in a compatibility note.

[P0] “immutable checkpoint logging of intermediary node states is the technical mitigation for discrimination-lawsuit and regulatory-fine exposure”
Why wrong: This is legal/compliance overclaiming. Checkpoints can support auditability, but they do not by themselves satisfy regulated-domain requirements or mitigate lawsuit/fine exposure.  
Fix: Say “checkpoint logs can support audit and incident reconstruction; regulated deployments still need domain-specific retention, privacy, access-control, explainability, and legal review.”

[P1] “Use a low-cost model (gpt-4o-mini) for the summarizer subtask”
Why wrong: Hard-coding one OpenAI model inside a Claude Code/Codex/Cursor/Gemini compatibility pack is brittle and provider-specific. It also becomes outdated as model catalogs change.  
Fix: “Use a cheaper, sufficiently capable summarizer model, selected per provider and validated for summary fidelity; examples may include small/mini models.”

[P1] “Mem0 achieved 49.0% on LongMemEval”
Why wrong: This treats one benchmark result as canonical. Current public benchmark numbers vary heavily by harness/version, and the pack itself later admits scores vary. A fixed 49.0% claim will age badly.  
Fix: “Report the exact benchmark, version, date, evaluator, and harness; treat any score as non-portable and require local eval.”

[P1] “raw RAG-as-memory scores worse”
Why wrong: Unsupported comparative claim. No raw-RAG number or benchmark setup is given, and some benchmarks make verbatim storage/RAG unusually competitive.  
Fix: Either cite the exact baseline and score or remove the comparison.

[P1] “System-prompt length — not tool count — is the primary driver of cache efficiency.”
Why wrong: Anthropic caching covers `tools`, `system`, and `messages` in order; large tool definitions absolutely affect cached-token economics. “Tool count” is the wrong metric, but tool-definition token mass matters. Official docs: https://platform.claude.com/docs/en/build-with-claude/prompt-caching  
Fix: “Cache efficiency is driven by stable reusable prefix token volume across tools, system prompt, and messages.”

[P1] “A memory system … MUST implement … Consolidation, Scoring, and Temporal Tracking”
Why wrong: Over-absolute. Some valid memory designs are intentionally scoped: e.g. short-lived project memory may need consolidation but not decay, audit logs may need temporal tracking but not mutation, and compliance stores may forbid deletion/decay.  
Fix: “For durable adaptive user/agent memory, require explicit policies for consolidation, relevance/importance, and temporal validity; justify omissions by use case.”

[P1] “Lossy summarization fires at a token threshold (e.g. 70% of capacity)”
Why wrong: The 70% trigger is presented as a general rule but is an unsupported magic number. Appropriate thresholds depend on reserved output budget, tool-call overhead, model context size, latency budget, and expected retrieval needs.  
Fix: “Set an explicit threshold based on reserved response/tool budget; 60–80% can be an initial tuning range, validated with truncation and recall tests.”

[P1] “pre-warm: send an empty warmup request with `max_tokens` set to `0`”
Why wrong: The advice omits Anthropic’s important failure cases: `max_tokens: 0` is rejected with streaming, extended thinking, structured outputs, forced/any tool choice, and batch requests. Official docs: https://platform.claude.com/docs/en/build-with-claude/prompt-caching  
Fix: Add the limitations and require checking `usage.cache_creation_input_tokens` to confirm the warmup actually wrote a cache entry.

[P1] “Claude models are trained to parse XML-style tags… Internal evaluations: structured XML formatting improves response consistency by 20% to 40% and accuracy…”
Why wrong: Suspicious specific percentages with no reproducible eval, model version, task set, or public source. This is exactly the kind of benchmark-sounding slop reviewers should block.  
Fix: Remove the percentages or attach a precise, public citation with model, dataset, metric, and date.

[P1] “systematic episodic memory improves customer-satisfaction scores by 43%… procedural memory registers reduce task-completion time by 58%”
Why wrong: Unsupported specific numbers with no study design, sample, domain, baseline, or metric definition.  
Fix: Remove the numbers or cite the exact empirical source and scope the claim to that setting.

[P2] “CouchbaseSaver”
Why wrong: Current LangGraph docs prominently list in-memory, SQLite, Postgres, AWS, MongoDB, Azure Cosmos DB, Redis, CockroachDB, and Aerospike checkpointers; Couchbase may be third-party or stale, but the pack presents it as a first-class production backend. Official docs: https://docs.langchain.com/oss/python/integrations/checkpointers/index  
Fix: Replace with documented current production options, or label Couchbase as third-party/community if still intentionally supported.

VERDICT: FIX-FIRST

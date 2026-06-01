# Prompt Caching & Context Structuring Rules (Anthropic)
<!-- capability: prompt_caching -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| PC1 | Caching is prefix-based and hierarchical: Tools → System Prompt → Messages | deterministic |
| PC2 | Know the billing multipliers: 1.25× / 2.0× write, 0.1× read | deterministic |
| PC3 | Place dynamic variables AFTER the last breakpoint — never in the cached prefix | deterministic |
| PC4 | Respect the limits: ≤4 breakpoints/request, 20-block lookback window | deterministic |
| PC5 | Pre-warm the cache with a max_tokens=0 warmup request | deterministic |
| PC6 | Structure context with nested XML tags; documents-first, query-last | semi-deterministic |

---

## Rules

### PC1: Caching is Prefix-Based and Hierarchical

Anthropic's ephemeral caching stores computed key-value (KV) tensors so the model resumes from a designated prefix, avoiding redundant attention calculation on repeated prefixes. The cache builds strictly in this order:

```
Tools → System Prompt → Messages Queue
```

Any change to the LEFT of a cache breakpoint invalidates the cache and forces full recalculation of all subsequent tokens. Annotate stable boundaries with `cache_control: {"type": "ephemeral"}`.

> Source: findings.md "Anthropic Context Engineering and Caching Topologies" [12, 34, 35, 36]

Empirical benefits: caching reduces total API costs by **41% to 80%**; Time-To-First-Token improves **13% to 31%**; savings scale with prompt size (**10–45% at 500 tokens, 54–89% at 50,000 tokens**). System-prompt length — not tool count — is the primary driver of cache efficiency.

> Source: findings.md "Anthropic Context Engineering" — empirical evaluations [12]

**determinismLevel**: deterministic.

### PC2: Know the Billing Multipliers

Caching applies multipliers to the base input-token rate:

| Operation | Multiplier |
|-----------|-----------|
| Cache write — 5-minute TTL | **1.25×** |
| Cache write — 1-hour TTL | **2.0×** |
| Cache read (hit) | **0.1×** |

Total input cost: `T_total = T_read + T_write + T_active` (cached reads + new cache-creation tokens + active uncached input).

> Source: findings.md "Anthropic Context Engineering" — billing structure [35]

**Rule**: A cache write costs MORE than an uncached token (1.25× or 2.0×). Caching only pays off when the prefix is read back enough times at 0.1× to amortize the write — cache STABLE prefixes, not one-shot content.

**determinismLevel**: deterministic.

### PC3: Dynamic Variables Go AFTER the Last Breakpoint

Because caching requires prefix alignment, placing a dynamic variable (timestamp, fluctuating tool output, user message) in the MIDDLE of a cached block invalidates the breakpoint → cache miss. Specific constraints:

- **Mid-conversation system messages**: do NOT modify the top-level `system` field mid-conversation — it invalidates the entire cache prefix. Instead append a `{"role": "system"}` block to the active messages list, keeping the cached system instructions intact.
- **Key serialization ordering**: Swift/Go can randomize JSON key order, changing the compiled prompt hash on consecutive calls. Enforce deterministic key ordering.
- **Cross-provider isolation**: caches are provider-specific and workspace-isolated. Identical prompts split across Anthropic Direct, AWS Bedrock, and Google Vertex AI do NOT share cache entries.

> Source: findings.md "Anthropic Context Engineering" — developer implementation constraints [12, 35, 36]

**determinismLevel**: deterministic.

### PC4: Respect the Limits — 4 Breakpoints, 20-Block Lookback

- Anthropic allows up to **4 explicit breakpoints** per request.
- The API lookback search is limited to a maximum of **20 blocks**. If an incoming request's breakpoint is pushed **20 or more blocks** past the last written cache entry, the lookback fails to find a match → full cache miss + new cache write.

> Source: findings.md "Anthropic Context Engineering" — limits [34, 35, 36]

**Rule**: In long, rapidly-growing conversations, the active breakpoint can drift past the 20-block lookback window — re-anchor breakpoints so the cached prefix stays within 20 blocks of the new turn.

**determinismLevel**: deterministic.

### PC5: Pre-Warm the Cache

To avoid latency on the first request of the day, pre-warm: send an empty warmup request with **`max_tokens` set to `0`** and a placeholder user message, placing the `cache_control` breakpoint on the final block of the static system prompt or tool definitions. The API executes the cache write and returns an empty content array with stop reason `max_tokens`. Subsequent requests then benefit from the 0.1× read rate and lower latency.

> Source: findings.md "Anthropic Context Engineering" — pre-warming [35]

**determinismLevel**: deterministic.

### PC6: Structure Context with Nested XML — Documents First, Query Last

Claude models are trained to parse XML-style tags (`<task>`, `<context>`, `<instructions>`, `<document>`) as unambiguous boundaries between instructions and data. Internal evaluations: structured XML formatting improves response consistency by **20% to 40%** and accuracy on complex reasoning by **30% to 40%** vs unstructured plain text.

Layout rules:
- Use nested XML for multi-document inputs (`<documents><document index="1"><source>…</source><document_content>…</document_content></document></documents>`).
- Place long documents at the TOP of the prompt and the query at the END — improves response quality by up to **30%** on complex multi-document tasks.
- To reduce hallucination, instruct the model to locate and extract exact quotes from the XML documents BEFORE synthesizing its answer.

> Source: findings.md "Anthropic Context Engineering" — XML structuring [37, 38]

**Rule**: XML structuring and caching reinforce each other — static instructions/tools/long-form data at the prompt head under ephemeral breakpoints maximize cache hits AND steerability.

**determinismLevel**: semi-deterministic — improvement percentages are evaluation-dependent.

---

## Anti-Patterns

- **Dynamic variable in the cached prefix**: a timestamp at the top of the system prompt destroys every cache hit.
- **Mutating the top-level `system` field mid-conversation**: invalidates the whole prefix — append a system-role message block instead.
- **Caching one-shot content**: a write costs 1.25×/2.0×; it only pays off when read back at 0.1×.
- **Ignoring the 20-block lookback**: long conversations push the breakpoint out of the lookback window → silent full miss.
- **Plain-text mega-prompts**: forgoing XML structure loses the 20–40% consistency / 30–40% accuracy gains.
- **Assuming cross-provider cache reuse**: Bedrock/Vertex/Direct caches are isolated.

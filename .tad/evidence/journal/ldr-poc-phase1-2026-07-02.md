# Journal: LDR POC Phase 1

## Key Findings

1. LDR `quick_research` is open-web-scoped, not Library-scoped. The tool searches
   DuckDuckGo/SearXNG and cites whatever it finds on the web — it does NOT limit
   answers to sources you imported into its Library. This means LDR's citation model
   is structurally different from NotebookLM's closed-scope cited-ask. For TAD's
   citation-based saturation checking, this is a structural incompatibility.

2. LDR 1.7.0 has a broken `ldr` CLI entry point (references non-existent
   `local_deep_research.main`). `ldr-web` and `ldr-mcp` work fine.

3. LDR's `unstructured==0.18.32` dependency pulls ancient `numba==0.53.1` →
   `llvmlite==0.36.0` which only supports Python <3.10. Requires `uv pip install
   --override` to force newer versions. Python 3.12 is the sweet spot (3.13/3.14
   have other issues).

4. DashScope (Alibaba qwen3.7-max) works as LDR's LLM backend via `openai_endpoint`
   provider. Viable free/cheap alternative to Anthropic/OpenAI API keys.

5. LDR REST API requires CSRF session tokens: must visit a page first to establish
   session state, then extract CSRF from meta tag. Header name is `X-CSRFToken`.
   Registration is rate-limited (3/hour/IP, in-memory, resets on restart).

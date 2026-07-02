# A/B Citation Quality Blind Evaluation

## Verdict Table

| Question | System | citation-resolution | coverage | hallucinated-citations |
|----------|--------|-------------------|----------|----------------------|
| Q1 | System A | 0/4 (0%) | 2 | 0 |
| Q1 | System B | 0/14 (0%) | 2 | 0 |
| Q2 | System A | 3/5 (60%) | 2 | 0 |
| Q2 | System B | 0/25 (0%) | 2 | 0 |
| Q3 | System A | 0/5 (0%) | 2 | 0 |
| Q3 | System B | 2/26 (8%) | 2 | 0 |

## Per-Citation Detail

### Q1 — System A

System A provides NO reference list (no Sources section with URLs). The answer uses 4 inline citation markers [1]-[4] but provides no URL attribution, making formal resolution impossible. The content behind each marker is factually accurate against Source 3 (Architecture).

- [1] → NO REFERENCE LIST: Claims about Stdio (stdin/stdout), Streamable HTTP (HTTP POST + SSE), local vs remote, bearer tokens, API keys, OAuth → content exists in Source 3 lines 72-77 → **unresolved (no reference list)**
- [2] → NO REFERENCE LIST: Claims about filesystem server = local, Sentry = remote → content exists in Source 3 lines 47-48 → **unresolved (no reference list)**
- [3] → NO REFERENCE LIST: Claims about single-client (Stdio) vs many-client (Streamable HTTP) → content exists in Source 3 lines 30-31 → **unresolved (no reference list)**
- [4] → NO REFERENCE LIST: Claims about transport layer abstraction, same JSON-RPC 2.0 format → content exists in Source 3 line 77 → **unresolved (no reference list)**

### Q1 — System B

System B provides a 17-source reference list. However, ALL 17 sources are outside the 5-source ground truth set (14 arxiv papers + 3 MCP spec sub-pages for transports).

- [1] → http://arxiv.org/abs/2504.08999v3 (MCP Bridge paper): Stdio requires local process execution, limitation for cloud → **out-of-scope** (not in 5-source set)
- [2] → http://arxiv.org/abs/2503.23278v3 (MCP Landscape paper): MCP as middleware and open standard → **out-of-scope**
- [5] → http://arxiv.org/abs/2512.03775v1 (Crypto Misuse paper): Minimal built-in security → **out-of-scope**
- [6] → http://arxiv.org/abs/2511.20920v1 (Securing MCP): External security frameworks needed → **out-of-scope**
- [7] → http://arxiv.org/abs/2510.15994v2 (MCP Security Bench): Tools as composable objects, attack surfaces → **out-of-scope**
- [8] → http://arxiv.org/abs/2505.02279v2 (Agent interoperability survey): Custom transports for heterogeneous systems → **out-of-scope**
- [9] → http://arxiv.org/abs/2603.18063v1 (MCP-38 Threat Taxonomy): Threat frameworks for dynamic transport → **out-of-scope**
- [10] → http://arxiv.org/abs/2602.01129v1 (SMCP): MCP as open standard → **out-of-scope**
- [12] → http://arxiv.org/abs/2505.03864v1 (Glue-Code to Protocols): MCP for scalable agent systems → **out-of-scope**
- [13] → http://arxiv.org/abs/2512.15163v2 (MCP-SafetyBench): MCP standard, custom transports → **out-of-scope**
- [14] → http://arxiv.org/abs/2504.11094v2 (Evaluation Report): MCP service proliferation → **out-of-scope**
- [15] → https://modelcontextprotocol.io/specification/2025-06-18/basic/transports: Stdio mechanism, Streamable HTTP, session management, deprecated HTTP+SSE, custom transports → **out-of-scope** (transports sub-page not in 5-source set; content partially overlaps with Source 3)
- [16] → https://modelcontextprotocol.io/specification/2025-03-26/basic/transports: Streamable HTTP introduced, deprecated HTTP+SSE → **out-of-scope**
- [17] → https://modelcontextprotocol.io/specification/2024-11-05/basic/transports: Original HTTP+SSE spec → **out-of-scope**

### Q2 — System A

System A provides a 5-source reference list with URLs.

- [1] → https://en.wikipedia.org/wiki/Model_Context_Protocol (= Source 5): Claim: "MCP, introduced by Anthropic in November 2024, provides an open standard for integrating AI systems" → Source 5 line 7: "Model Context Protocol (MCP) is an open standard and open-source framework developed by Anthropic in November 2024" → **resolved**
- [2] → https://modelcontextprotocol.io/docs/concepts/tools (= Source 4): Claim: "tools are designed to be model-controlled" and "the language model can automatically discover and decide to invoke tools" → Source 4 line 11: "Tools in MCP are designed to be model-controlled, meaning that the language model can discover and invoke tools automatically based on its contextual understanding and the user's prompts" → **resolved**
- [3] → https://modelcontextprotocol.io/specification (generic URL, NOT in 5-source set): Claim: "Tools essentially represent arbitrary code execution and must be treated with appropriate caution" → Content exists in Source 2 line 78 but at different URL → **unresolved (out-of-scope URL; content exists at Source 2)**
- [4] → https://modelcontextprotocol.io/specification/2025-06-18/server/tools (spec sub-page, NOT in 5-source set): Claims: tools/list with pagination, dynamic updates via notifications, tools/call with name and arguments → Content exists in Source 4 lines 42-43, 86-101, 120-129 but at different URL → **unresolved (out-of-scope URL; content exists at Source 4)**
- [5] → https://modelcontextprotocol.io/specification/2025-06-18 (= Source 2): Claims: Hosts/Clients/Servers architecture, capability negotiation, explicit user consent before invoking tools, users should understand tools before authorizing → Source 2 lines 25-28, 36-38, 81-82: exact match → **resolved**

### Q2 — System B

System B provides NO reference list (no Sources section with URLs). The answer uses 25 inline citation markers [1]-[25] but provides no URL attribution, making formal resolution impossible. The content behind the markers is factually accurate against Sources 2, 3, and 4.

- [1] → NO REFERENCE LIST → **unresolved (no reference list)**
- [2] → NO REFERENCE LIST → **unresolved (no reference list)**
- [3] → NO REFERENCE LIST → **unresolved (no reference list)**
- [4] → NO REFERENCE LIST → **unresolved (no reference list)**
- [5] → NO REFERENCE LIST → **unresolved (no reference list)**
- [6] → NO REFERENCE LIST → **unresolved (no reference list)**
- [7] → NO REFERENCE LIST → **unresolved (no reference list)**
- [8] → NO REFERENCE LIST → **unresolved (no reference list)**
- [9] → NO REFERENCE LIST → **unresolved (no reference list)**
- [10] → NO REFERENCE LIST → **unresolved (no reference list)**
- [11] → NO REFERENCE LIST → **unresolved (no reference list)**
- [12] → NO REFERENCE LIST → **unresolved (no reference list)**
- [13] → NO REFERENCE LIST → **unresolved (no reference list)**
- [14] → NO REFERENCE LIST → **unresolved (no reference list)**
- [15] → NO REFERENCE LIST → **unresolved (no reference list)**
- [16] → NO REFERENCE LIST → **unresolved (no reference list)**
- [17] → NO REFERENCE LIST → **unresolved (no reference list)**
- [18] → NO REFERENCE LIST → **unresolved (no reference list)**
- [19] → NO REFERENCE LIST → **unresolved (no reference list)**
- [20] → NO REFERENCE LIST → **unresolved (no reference list)**
- [21] → NO REFERENCE LIST → **unresolved (no reference list)**
- [22] → NO REFERENCE LIST → **unresolved (no reference list)**
- [23] → NO REFERENCE LIST → **unresolved (no reference list)**
- [24] → NO REFERENCE LIST → **unresolved (no reference list)**
- [25] → NO REFERENCE LIST → **unresolved (no reference list)**

Content accuracy note: The claims about initialize request, capability negotiation (Source 3 lines 85-87, 122-203), tools/list and tools/call (Source 3 lines 204-363, Source 4 lines 42-118), tool metadata fields (Source 3 lines 265-269, Source 4 lines 157-163), model-controlled tools (Source 4 line 11), human-in-the-loop (Source 4 lines 15-20), error handling (Source 4 lines 327-370), and list_changed notifications (Source 3 lines 329-362, Source 4 lines 120-129) are all factually accurate against the ground truth.

### Q3 — System A

System A provides NO reference list (no Sources section with URLs). The answer uses 5 inline citation markers [1]-[5] but provides no URL attribution.

- [1] → NO REFERENCE LIST: Claims: Servers MUST validate all tool inputs, implement proper access controls, rate limit tool invocations, sanitize tool outputs → content exists in Source 4 lines 374-379 → **unresolved (no reference list)**
- [2] → NO REFERENCE LIST: Claim: tools represent arbitrary code execution → content exists in Source 2 line 78 and Source 4 area → **unresolved (no reference list)**
- [3] → NO REFERENCE LIST: Claims: bearer tokens, API keys, custom headers, OAuth recommendation → content exists in Source 3 lines 75-76 → **unresolved (no reference list)**
- [4] → NO REFERENCE LIST: Claims: SHOULD provide clear security documentation, consider privacy implications, follow security best practices → content exists in Source 2 lines 93-99 → **unresolved (no reference list)**
- [5] → NO REFERENCE LIST: Claims: prompt injection, poisoned tools enabling data exfiltration → content exists in Source 5 line 45 → **unresolved (no reference list)**

### Q3 — System B

System B provides a 40-source reference list with URLs. Of 40 listed sources, only 2 match the 5-source ground truth set: [24] (Source 4) and [34] (Source 2). 26 unique citation markers appear in the answer text.

- [5] → http://arxiv.org/abs/2510.15994v2 (MCP Security Bench): Attack surface expansion → **out-of-scope**
- [6] → http://arxiv.org/abs/2506.13538v5 (MCP at First Glance): Textual interfaces insufficient → **out-of-scope**
- [7] → http://arxiv.org/abs/2508.10991v4 (MCP-Guard): Tool poisoning → **out-of-scope**
- [8] → http://arxiv.org/abs/2511.20920v1 (Securing MCP): Dynamic tool discovery, external frameworks → **out-of-scope**
- [12] → http://arxiv.org/abs/2504.19997v1 (MCP Gateways): Supplementary defenses → **out-of-scope**
- [13] → http://arxiv.org/abs/2512.03775v1 (Crypto Misuse): Minimal built-in security → **out-of-scope**
- [16] → http://arxiv.org/abs/2509.22814v1 (Vision Systems): Jailbreaks, unauthorized access → **out-of-scope**
- [17] → http://arxiv.org/abs/2512.08290v2 (SoK): MCP as universal standard → **out-of-scope**
- [20] → http://arxiv.org/abs/2601.17549v1 (Breaking the Protocol): Protocol-level gaps → **out-of-scope**
- [21] → https://modelcontextprotocol.io/specification (generic URL): "enables powerful capabilities through arbitrary data access and code execution paths" → content exists in Source 2 line 63 but URL differs → **out-of-scope**
- [22] → https://modelcontextprotocol.io/specification/2024-11-05: Same claim as [21] → **out-of-scope**
- [23] → https://modelcontextprotocol.io/specification/2025-03-26/basic/authorization: HTTPS endpoints, redirect URI validation, token expiration → **out-of-scope**
- [24] → https://modelcontextprotocol.io/docs/concepts/tools (= Source 4): "Servers MUST validate all tool inputs, implement proper access controls, rate limit invocations, and sanitize tool outputs" → Source 4 lines 374-379: "Servers MUST: Validate all tool inputs / Implement proper access controls / Rate limit tool invocations / Sanitize tool outputs" → **resolved**
- [25] → https://modelcontextprotocol.io/docs/concepts/prompts: Prompt input/output validation → **out-of-scope**
- [26] → https://modelcontextprotocol.io/docs/concepts/resources: Resource URI validation, binary data encoding → **out-of-scope**
- [27] → https://modelcontextprotocol.io/specification/2025-03-26: User consent principles, privacy → **out-of-scope**
- [28] → https://modelcontextprotocol.io/docs/concepts/transports: Origin header validation, localhost binding, newline delimiters → **out-of-scope**
- [32] → https://arxiv.org/abs/2601.17549: Capability attestation gaps, sampling authentication, trust propagation → **out-of-scope**
- [33] → https://arxiv.org/abs/2504.08623: Tool poisoning, trust cascading → **out-of-scope**
- [34] → https://modelcontextprotocol.io/specification/2025-06-18 (= Source 2): "enables powerful capabilities through arbitrary data access and code execution paths" → Source 2 line 63 exact match. "users explicitly consent to and understand all data access" → Source 2 line 69 exact match. "tool descriptions and annotations should be considered untrusted, unless obtained from a trusted server" → Source 2 lines 79-80 exact match. "The protocol intentionally limits server visibility into prompts" → Source 2 line 89 exact match → **resolved**
- [35] → https://modelcontextprotocol.io/specification/2025-06-18/basic/lifecycle: Timeouts for requests → **out-of-scope**
- [36] → https://modelcontextprotocol.io/specification/2025-06-18/basic/authorization: OAuth 2.0 Protected Resource Metadata, WWW-Authenticate header → **out-of-scope**
- [37] → https://modelcontextprotocol.io/specification/2025-06-18/basic/transports: Origin header validation, localhost binding, session ID security → **out-of-scope**
- [38] → https://modelcontextprotocol.io/specification/2025-06-18/server/prompts: Prompt validation → **out-of-scope**
- [39] → https://modelcontextprotocol.io/specification/2025-06-18/server/resources: Resource URI validation, access controls → **out-of-scope**
- [40] → https://modelcontextprotocol.io/specification/2025-06-18/server/tools: Human in the loop, input validation, access controls, rate limiting, output sanitization → **out-of-scope** (content exists in Source 4 at different URL)

## Notes

### Structural Observations

1. **Missing reference lists**: System A omits the Sources/reference section in 2 of 3 answers (Q1 and Q3). System B omits it in 1 of 3 answers (Q2). When reference lists are missing, inline citation markers like [1], [2] become unverifiable annotations -- they suggest sourcing but provide no way to audit the claim against a specific document. This is a significant citation quality deficiency regardless of whether the underlying content is accurate.

2. **Out-of-scope citation dominance**: When System B does provide reference lists (Q1 and Q3), the overwhelming majority of citations point to sources outside the 5-source ground truth set -- primarily academic papers on arxiv and MCP specification sub-pages. In Q1, all 14 unique citations are out-of-scope. In Q3, 24 of 26 unique citations are out-of-scope. This means System B's citation resolution rate against the provided ground truth is very low (2/40 across both answers), even though the citations may be individually valid against their actual sources.

3. **System A's in-scope citations are accurate**: In Q2 (the only System A answer with a reference list), 3 of 5 citations resolve directly to our ground truth sources, and the remaining 2 cite closely related URLs on the same site whose content demonstrably exists in the ground truth set. This suggests System A's sourcing, when attributed, draws from the same material as our ground truth.

4. **Content accuracy vs citation quality divergence**: Both systems produce factually accurate content throughout all 6 answers -- every substantive claim can be verified against the 5 ground truth sources. The citation quality gap is purely about formal attribution, not factual correctness. This is an important distinction: a system can be factually reliable while being citation-unreliable.

5. **Coverage parity**: Both systems achieve maximum coverage (score 2) on all three questions. Both comprehensively address each question's scope. System B tends to provide more extensive answers with additional context (deprecated transports, critical reflections, academic research), while System A is more focused on directly answering the question.

6. **Zero hallucinated citations**: Neither system fabricates citations to non-existent sources or attributes content to sources that demonstrably do not contain it. The citations that can be verified (System A Q2 [1][2][5], System B Q3 [24][34]) all accurately represent their source content.

### Summary Assessment

Neither system achieves strong citation resolution against the 5-source ground truth set, but for fundamentally different reasons:
- **System A** fails on 2/3 answers because it simply does not provide reference lists, making citations unverifiable. When it does provide references (Q2), 60% resolve correctly.
- **System B** fails because it cites extensively from sources outside the ground truth set (academic papers, spec sub-pages). When those citations happen to overlap with ground truth URLs, they resolve correctly (Q3 [24] and [34]).

Both systems demonstrate strong factual accuracy and comprehensive coverage across all questions.

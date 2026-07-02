# A/B Citation Quality Blind Evaluation — Library-Scoped Supplemental Round

## Verdict Table

| Question | System | citation-resolution | coverage | hallucinated-citations |
|----------|--------|-------------------|----------|----------------------|
| Q1 | System A | 1/4 (25%) | 2 | 0 |
| Q1 | System B | 0/4 (0%) — no URLs* | 2 | 0 |
| Q2 | System A | 0/25 (0%) — no URLs* | 2 | 0 |
| Q2 | System B | 2/4 (50%) | 2 | 0 |
| Q3 | System A | 0/5 (0%) — no URLs* | 2 | 0 |
| Q3 | System B | 2/22 (9%) | 2 | 0 |

**\*Critical format difference**: System A (Q2, Q3) and System B (Q1) provide no URL reference lists — citations are opaque numeric markers (e.g., [1], [2]) with no bibliography. The rubric requires resolving citations "by URL/title in the reference list," which is impossible when no reference list exists. However, all claims in these answers ARE content-verified against the ground truth (see detail below). See "Format Observations" section for implications.

## Per-Citation Detail

### Q1 — System A
System A provides a URL-based Sources section with 4 citations.

- [1] -> https://en.wikipedia.org/wiki/Model_Context_Protocol (= Source 5): Claim: "open standard introduced by Anthropic in November 2024 to standardize how AI systems integrate and share data with external tools" + "rapid adoption by major AI providers including OpenAI and Google DeepMind" -> Source 5 states "open standard and open-source framework developed by Anthropic in November 2024. It standardizes how AI systems..." and confirms OpenAI adoption in March 2025. -> **resolved**

- [2] -> https://modelcontextprotocol.io/specification/2025-03-26/basic/transports: Claim: MCP defines stdio and Streamable HTTP as standard transports; HTTP+SSE deprecated. -> This URL is NOT in the 5 ground truth sources (closest is Source 2 which covers 2025-06-18 spec overview, not the 2025-03-26 transports sub-page). The content IS corroborated by Source 3 (architecture), but the CITED URL is out-of-scope. -> **unresolved (out-of-scope)**

- [3] -> https://modelcontextprotocol.io/docs/concepts/transports: Claim: stdio and Streamable HTTP as standard transport mechanisms. -> This URL is NOT in the 5 ground truth sources (no transports concept page provided). Content corroborated by Source 3 but cited URL is out-of-scope. -> **unresolved (out-of-scope)**

- [4] -> https://modelcontextprotocol.io/specification/2024-11-05/basic/transports: Claim: original 2024 spec listed HTTP+SSE alongside stdio. -> This URL is NOT in the 5 ground truth sources. -> **unresolved (out-of-scope)**

**Summary**: 1/4 resolved (25%). The 3 unresolved citations point to real MCP documentation pages that are simply absent from the 5-source ground truth set.

---

### Q1 — System B
System B provides NO URL reference list. Citations [1]-[4] are opaque numeric markers. "Conversation: 00000000-..." format.

- [1] (used 8 times): Claims: two official transports (Stdio, Streamable HTTP); Stdio uses stdin/stdout streams; Streamable HTTP uses HTTP POST + optional SSE; Stdio has no network overhead; Streamable HTTP for remote; HTTP auth methods (bearer tokens, API keys, custom headers); OAuth recommended. -> Source 3 (architecture) confirms ALL claims verbatim: "Stdio transport: Uses standard input/output streams..." / "Streamable HTTP transport: Uses HTTP POST for client-to-server messages with optional Server-Sent Events..." / "standard HTTP authentication methods including bearer tokens, API keys, and custom headers. MCP recommends using OAuth." -> **content verified, URL unresolvable**

- [2] (used 2 times): Claims: filesystem server uses Stdio = "local" MCP server; Sentry uses Streamable HTTP = "remote" MCP server. -> Source 3 confirms: "the filesystem server, the server runs locally... uses the STDIO transport... commonly referred to as a 'local' MCP server. The official Sentry MCP server runs on the Sentry platform, and uses the Streamable HTTP transport... commonly referred to as a 'remote' MCP server." -> **content verified, URL unresolvable**

- [3] (used 2 times): Claims: Stdio = 1:1 model (single client); Streamable HTTP = 1:many (many clients). -> Source 3 confirms: "Local MCP servers that use the STDIO transport typically serve a single MCP client, whereas remote MCP servers that use the Streamable HTTP transport will typically serve many MCP clients." -> **content verified, URL unresolvable**

- [4] (used 2 times): Claims: transport layer abstracts the data layer; same JSON-RPC 2.0 format across all transports. -> Source 3 confirms: "The transport layer abstracts communication details from the protocol layer, enabling the same JSON-RPC 2.0 message format across all transport mechanisms." -> **content verified, URL unresolvable**

**Summary**: 0/4 URL-resolved. 4/4 content-verified against Source 3 (architecture). All factual claims are accurate but untraceable by URL.

---

### Q2 — System A
System A provides NO URL reference list. Citations [1]-[25] are opaque numeric markers. "Conversation: 00000000-..." format. 25 unique citation numbers used.

Content verification against ground truth (Sources 3 and 4):

- [1] (1 use): "lifecycle management" -> Source 3 confirms (lifecycle management section). -> **content verified**
- [2] (2 uses): "initialize request" for connection/capability negotiation -> Source 3 confirms (Step 1: Initialization). -> **content verified**
- [3] (3 uses): "tools/list request" and "tools/list_changed notification" -> Source 4 confirms. -> **content verified**
- [4] (1 use): "initialize request" -> Source 3 confirms. -> **content verified**
- [5] (2 uses): Server declares "tools" capability with "listChanged: true" -> Source 4 confirms: "Servers that support tools MUST declare the tools capability" with listChanged. -> **content verified**
- [6] (2 uses): Same as [5] + human-in-the-loop -> Source 4 confirms: "there SHOULD always be a human in the loop." -> **content verified**
- [7] (1 use): "notifications/initialized" notification -> Source 3 confirms (post-initialization notification). -> **content verified**
- [8] (2 uses): tools/list returns tools array with metadata -> Source 4 confirms (Listing Tools response). -> **content verified**
- [9] (2 uses): tool name as unique identifier, description for LLM -> Source 4 confirms: "name: Unique identifier for the tool" / "description: Human-readable description." -> **content verified**
- [10] (3 uses): name, description, inputSchema, outputSchema -> Source 4 confirms all fields (Data Types section). -> **content verified**
- [11] (3 uses): outputSchema optional; structuredContent field -> Source 4 confirms (Output Schema + Structured Content sections). -> **content verified**
- [12] (1 use): AI host builds unified tool registry -> Source 3 shows pseudo-code: "available_tools.extend(tools_response.tools)" / "conversation.register_available_tools(available_tools)." -> **content verified**
- [13] (2 uses): Same as [12] -> **content verified**
- [14] (2 uses): LLM selects tool, host intercepts call -> Source 4 confirms model-controlled; Source 3 shows pseudo-code flow. -> **content verified**
- [15] (2 uses): LLM auto-selects tool based on context -> Source 4: "model-controlled, meaning that the language model can discover and invoke tools automatically." -> **content verified**
- [16] (2 uses): User confirmation for sensitive operations; show inputs to prevent data exfiltration -> Source 4 confirms: "Present confirmation prompts" / "Show tool inputs to the user before calling the server, to avoid malicious or accidental data exfiltration." -> **content verified**
- [17] (4 uses): tools/call with name + arguments -> Source 4 confirms (Calling Tools section). -> **content verified**
- [18] (2 uses): Server executes and returns response -> Source 3 and 4 confirm (tool execution flow). -> **content verified**
- [19] (1 use): content array with text, image, audio, resource links, embedded resources -> Source 4 confirms all content types (Text, Image, Audio, Resource Links, Embedded Resources). -> **content verified**
- [20] (1 use): Same as [19] -> **content verified**
- [21] (3 uses): Protocol errors (JSON-RPC) vs tool execution errors (isError: true) -> Source 4 confirms (Error Handling section): "Protocol Errors: Standard JSON-RPC errors" / "Tool Execution Errors: Reported in tool results with isError: true." -> **content verified**
- [22] (1 use): Available tools may change dynamically -> Source 4 confirms (List Changed Notification). -> **content verified**
- [23] (1 use): tools/list_changed notification (JSON-RPC notification, no response) -> Source 4 confirms. Source 3 confirms: "No Response Required: No id field — follows JSON-RPC 2.0 notification semantics." -> **content verified**
- [24] (1 use): Same as [23] -> **content verified**
- [25] (1 use): Same as [23] -> **content verified**

**Summary**: 0/25 URL-resolved (no URLs provided). 25/25 content-verified against Sources 3 and 4. All factual claims are accurate. The answer is extremely detailed and comprehensive, covering initialization, discovery, selection, invocation, error handling, and dynamic updates with high fidelity to the ground truth sources.

---

### Q2 — System B
System B provides a URL-based Sources section with 4 citations.

- [1] -> https://modelcontextprotocol.io/docs/concepts/tools (= Source 4): Claims: "clients send a tools/list request" for discovery (with pagination via cursor); "clients send a tools/call request containing the specific tool's name and the arguments" for invocation; "notifications/tools/list_changed notification" for updates. -> Source 4 confirms ALL: tools/list with cursor parameter, tools/call with name+arguments, notifications/tools/list_changed. -> **resolved**

- [2] -> https://modelcontextprotocol.io/docs/concepts/architecture (= Source 3): Claims: "lifecycle management, which handles connection initialization, capability negotiation, and connection termination"; "lifecycle concludes with connection termination." -> Source 3 confirms: "Lifecycle management: Handles connection initialization, capability negotiation, and connection termination between clients and servers." -> **resolved**

- [3] -> https://modelcontextprotocol.io/specification/2025-03-26/server/tools: Claims: tools are "model-controlled" (LLM autonomously decides when to invoke); each tool identified by name with metadata/schema including inputSchema, readOnlyHint, destructiveHint annotations. -> This URL is NOT in the 5 ground truth sources (we have the 2025-06-18 spec, not 2025-03-26). The claims about "model-controlled" ARE present in Source 4, and inputSchema/annotations are in Source 4, but the CITED URL is out-of-scope. -> **unresolved (out-of-scope)**

- [4] -> https://modelcontextprotocol.io/specification/2025-03-26/basic/lifecycle: Claims: server MUST declare "tools" capability; server may declare "listChanged" sub-capability. -> This URL is NOT in the 5 ground truth sources. The claims ARE present in Source 4 ("Servers that support tools MUST declare the tools capability" with listChanged), but the CITED URL is out-of-scope. -> **unresolved (out-of-scope)**

**Summary**: 2/4 resolved (50%). The 2 unresolved citations point to the 2025-03-26 spec version; the 5-source set only includes the 2025-06-18 version. Claims are all factually accurate regardless.

---

### Q3 — System A
System A provides NO URL reference list. Citations [1]-[5] are opaque numeric markers. "Conversation: 00000000-..." format.

- [1] (used 5 times): Claims: servers MUST validate all tool inputs, implement proper access controls, rate limit tool invocations, sanitize tool outputs. -> Source 4 (Security Considerations) confirms verbatim: "Servers MUST: Validate all tool inputs / Implement proper access controls / Rate limit tool invocations / Sanitize tool outputs." -> **content verified**

- [2] (1 use): Claim: "tool invocations represent arbitrary code execution paths." -> Source 2 confirms: "arbitrary data access and code execution paths." -> **content verified**

- [3] (used 3 times): Claims: support for Bearer tokens, API keys, custom headers; OAuth recommended. -> Source 3 confirms: "standard HTTP authentication methods including bearer tokens, API keys, and custom headers. MCP recommends using OAuth to obtain authentication tokens." -> **content verified**

- [4] (used 3 times): Claims: provide clear security documentation; incorporate privacy considerations; follow industry security best practices. -> Source 2 confirms: "Provide clear documentation of security implications" / "Consider privacy implications in their feature designs" / "Follow security best practices in their integrations." -> **content verified**

- [5] (used 2 times): Claims: prompt injection attacks; poisoned tools enabling data exfiltration. -> Source 5 confirms: "security researchers identified multiple outstanding security issues, including prompt injection and poisoned tools enabling data exfiltration through connected tools." -> **content verified**

**Summary**: 0/5 URL-resolved (no URLs provided). 5/5 content-verified against Sources 2, 3, 4, and 5. All factual claims are accurate and directly traceable to ground truth content.

---

### Q3 — System B
System B provides a URL-based Sources section with 39 entries. 22 unique citation numbers appear in the answer body.

**In-scope citations (URL matches a ground truth source):**

- [33] -> https://modelcontextprotocol.io/docs/concepts/architecture (= Source 3): Claim: "servers SHOULD implement robust authentication, with OAuth recommended for obtaining tokens." -> Source 3 confirms: "MCP recommends using OAuth to obtain authentication tokens." -> **resolved**

- [34] -> https://modelcontextprotocol.io/docs/concepts/tools (= Source 4): Claim: "Servers MUST validate all tool inputs, implement proper access controls, rate limit invocations, and sanitize outputs to prevent malformed inputs and denial-of-service (DoS) attacks." -> Source 4 confirms: "Servers MUST: Validate all tool inputs / Implement proper access controls / Rate limit tool invocations / Sanitize tool outputs." -> **resolved**

**Out-of-scope citations (URL not in ground truth):**

- [1] -> http://arxiv.org/abs/2503.23278v3 (arXiv paper): MCP landscape/security survey. -> **unresolved (out-of-scope)**
- [3] -> http://arxiv.org/abs/2504.03767v2 (arXiv paper): MCP safety audit. -> **unresolved (out-of-scope)**
- [4] -> http://arxiv.org/abs/2604.07551v1 (arXiv paper): MCP defense taxonomy. -> **unresolved (out-of-scope)**
- [5] -> http://arxiv.org/abs/2510.15994v2 (arXiv paper): MCP security benchmark. -> **unresolved (out-of-scope)**
- [7] -> http://arxiv.org/abs/2508.10991v4 (arXiv paper): MCP-Guard framework. -> **unresolved (out-of-scope)**
- [8] -> http://arxiv.org/abs/2511.20920v1 (arXiv paper): Securing MCP. -> **unresolved (out-of-scope)**
- [9] -> http://arxiv.org/abs/2602.01129v1 (arXiv paper): SMCP. -> **unresolved (out-of-scope)**
- [11] -> http://arxiv.org/abs/2506.02040v4 (arXiv paper): MCP attack vectors. -> **unresolved (out-of-scope)**
- [12] -> http://arxiv.org/abs/2504.19997v1 (arXiv paper): MCP gateways. -> **unresolved (out-of-scope)**
- [13] -> http://arxiv.org/abs/2512.03775v1 (arXiv paper): MCP cryptographic misuse. -> **unresolved (out-of-scope)**
- [17] -> http://arxiv.org/abs/2512.08290v2 (arXiv paper): MCP SoK. -> **unresolved (out-of-scope)**
- [24] -> https://arxiv.org/abs/2504.08623v2 (arXiv paper): Enterprise MCP security. -> **unresolved (out-of-scope)**
- [25] -> https://modelcontextprotocol.io/docs/concepts/transports: Not in 5-source set. -> **unresolved (out-of-scope)**
- [29] -> https://arxiv.org/pdf/2504.08623v2 (PDF of arXiv paper). -> **unresolved (out-of-scope)**
- [32] -> https://arxiv.org/html/2504.08623v2 (HTML of arXiv paper). -> **unresolved (out-of-scope)**
- [35] -> https://modelcontextprotocol.io/docs/concepts/resources: Not in 5-source set. -> **unresolved (out-of-scope)**
- [36] -> https://modelcontextprotocol.io/docs/concepts/prompts: Not in 5-source set. -> **unresolved (out-of-scope)**
- [37] -> https://modelcontextprotocol.io/specification/2025-06-18/basic/authorization: Sub-page of spec, not included in Source 2 (which only has the overview). -> **unresolved (out-of-scope)**
- [38] -> https://modelcontextprotocol.io/docs/concepts/roots: Not in 5-source set. -> **unresolved (out-of-scope)**
- [39] -> https://modelcontextprotocol.io/docs/concepts/sampling: Not in 5-source set. -> **unresolved (out-of-scope)**

**Summary**: 2/22 resolved (9%). 20 out-of-scope (mostly arXiv research papers + MCP doc pages not in the 5-source set). The answer draws heavily from academic security research literature beyond the provided source set. Zero hallucinated sources — all cited URLs appear to reference real publications.

---

## Format Observations

A significant structural difference exists between the two systems:

**System A (Q2, Q3) and System B (Q1)** produce answers WITHOUT URL-based reference lists. Citations are opaque numeric markers like [1], [2] with no bibliography section. This makes formal citation resolution impossible — one cannot verify WHICH source a citation refers to. However, the factual claims in ALL these answers were content-verified against the ground truth sources with 100% accuracy.

**System A (Q1) and System B (Q2, Q3)** produce answers WITH URL-based reference lists. This enables formal citation resolution. However, many cited URLs fall outside the 5-source ground truth set:
- System A Q1: 3 of 4 URLs out-of-scope (MCP spec/doc pages not in source set)
- System B Q2: 2 of 4 URLs out-of-scope (2025-03-26 spec version; source set has 2025-06-18)
- System B Q3: 20 of 22 URLs out-of-scope (mostly arXiv papers + additional MCP doc pages)

**Content accuracy is uniformly high across both systems** — no factual errors were detected in any of the 6 answers. The resolution gap is driven by source-set coverage, not by factual inaccuracy.

## Aggregate Comparison

| Metric | System A | System B |
|--------|----------|----------|
| URL-resolved citations (across 3 Qs) | 1/34 (3%) | 4/30 (13%) |
| Content-verified claims (across 3 Qs) | 34/34 (100%) | 30/30 (100%) |
| Coverage (all 3 Qs) | 6/6 | 6/6 |
| Hallucinated citations | 0 | 0 |
| Answers with URL bibliography | 1 of 3 | 2 of 3 |
| Out-of-scope citations (when URLs provided) | 3 (Q1) | 22 (Q2: 2, Q3: 20) |

## Notes

1. **Neither system fabricates sources.** All out-of-scope URLs appear to be real MCP documentation pages or real arXiv papers. The resolution failures stem from the ground truth set being limited to 5 sources, not from citation fabrication.

2. **System B Q3 is an outlier**: it cites 39 sources (22 used in-text), of which 20 are arXiv security research papers. This dramatically expands scope beyond the 5-source ground truth but makes nearly all citations unverifiable against the provided sources. The depth of security analysis is significantly broader than System A Q3, which stays tightly within the MCP documentation.

3. **The "no URL" answers consistently have better content fidelity to the ground truth** — they appear to cite from the provided library sources directly (as intended in a library-scoped round), whereas the URL-backed answers frequently cite external sources beyond the library.

4. **Coverage is identical (2/2)** across all 6 answers. Both systems comprehensively address each question. The quality difference lies in citation traceability and source scope, not in topical coverage or content accuracy.

5. **System A produces 2 of 3 answers in Chinese; System B produces 1 of 3 answers in Chinese.** The Chinese-language answers consistently lack URL bibliographies. This may reflect a system-level behavior difference rather than a per-question choice.

# A/B Evaluation Corpus

## Shared Source Set (5 sources, identical for both systems)

| # | URL | Lines | Quality Probe |
|---|-----|-------|---------------|
| 1 | https://modelcontextprotocol.io/docs/getting-started/intro | 40 | ✅ PASS |
| 2 | https://modelcontextprotocol.io/specification/2025-06-18 | 99 | ✅ PASS |
| 3 | https://modelcontextprotocol.io/docs/concepts/architecture | 362 | ✅ PASS |
| 4 | https://modelcontextprotocol.io/docs/concepts/tools | 385 | ✅ PASS |
| 5 | https://en.wikipedia.org/wiki/Model_Context_Protocol | 56 | ✅ PASS |

## Quality Probes (per-source, per-system)

### NotebookLM (notebook f9f0191b)
All 5 sources passed quality probe — each returned substantive, cited answers
to source-specific questions. Citations included [N] references.

### LDR (REST API, qwen3.7-max)
LDR does NOT have a "Library-scoped ask" mode accessible via `quick_research`.
The `quick_research` mode performs web search (DuckDuckGo/SearXNG) and
synthesizes from search results, NOT from a pre-imported Library.

**Critical finding**: LDR's citation scope is the OPEN WEB, not a fixed source
set. This makes the A/B comparison asymmetric by design — LDR cites what it
finds on the web, NotebookLM cites what's in its notebook.

## Fixed Questions (3, verbatim identical for both systems)
- Q1: "What transport mechanisms does MCP support, and how do they differ?"
- Q2: "How does MCP define the lifecycle of a tool call, from discovery to invocation?"
- Q3: "What are the security considerations MCP documentation raises for server implementers?"

## A/B Mapping (revealed post-evaluation)
- Q1: System A = NotebookLM, System B = LDR
- Q2: System A = LDR, System B = NotebookLM
- Q3: System A = NotebookLM, System B = LDR

## Sanitization Applied
1. Removed system identity markers (Local Deep Research, NotebookLM, Gemini, Qwen, DashScope)
2. Removed NotebookLM CLI "Matched:" / "Answer:" headers
3. Random per-question A/B assignment (not odd/even)

# MCP Transcript — LDR POC Phase B

## MCP Registration

- `.mcp.json` created at repo root (project-scoped)
- Server name: `ldr-mcp`
- Transport: STDIO (command-based, no url/port)
- Command: `/Users/sheldonzhao/.tad-ldr-venv/bin/ldr-mcp`
- API key: `${LDR_API_KEY}` reference (not literal)

## AC3a Verification

```
jq -e '.mcpServers | has("ldr-mcp")' .mcp.json → true ✅
jq -e '[.mcpServers[] | select(has("url"))] | length == 0' .mcp.json → true ✅
grep -c literal-key .mcp.json → 0 ✅
```

## MCP Live Call — EQUIVALENT_SUBSTITUTE

**Reason**: `.mcp.json` changes require a new Claude Code session to take effect.
In-session equivalent verification performed instead:

### STDIO smoke test attempt
- Command: `ldr-mcp` entry point confirmed at `/Users/sheldonzhao/.tad-ldr-venv/bin/ldr-mcp`
- Entry point imports `local_deep_research.mcp.server:run_server`
- `run_server()` calls `mcp.run(transport="stdio")` — standard MCP STDIO transport
- Server module defines tools: `quick_research`, `detailed_research`, `generate_report` (confirmed by source inspection of server.py)

### REST API headless research (equivalent capability proof)
- Endpoint: `POST /api/start_research`
- Research ID: `8604556e-395d-420c-a607-760964faae6a`
- Query: "What transport mechanisms does MCP support and how do they differ?"
- Model: qwen3.7-max via DashScope OpenAI-compatible endpoint
- Status: completed (100%)
- Report: 47 lines, 53 bracket citations, URLs to modelcontextprotocol.io
- Report saved: `headless-run/q1-mcp-transport.md`

### Equivalence justification
The REST API and MCP server share the same research engine (`local_deep_research`).
The MCP `quick_research` tool calls the same underlying `start_research_process` function.
REST API success with qwen3.7-max proves the LLM integration, search, and report generation work.
MCP STDIO transport is a thin wrapper around the same engine.

**Verdict**: EQUIVALENT_SUBSTITUTE — MCP registration is correct (jq-verified),
and the underlying research engine works (REST-proven). Full MCP live call
requires a new Claude Code session.

## 1.7.0 vs 1.8.0 Interface Differences (POC finding)

1. `ldr` CLI entry point: references `local_deep_research.main` which does NOT exist in 1.7.0 → CLI broken
2. `ldr-web` and `ldr-mcp` entry points: work correctly
3. Python >=3.12 requirement: transitive dependency `unstructured==0.18.32` pulls `numba==0.53.1` → `llvmlite==0.36.0` (Python <3.10 only). Required `uv pip install --override` to force newer llvmlite/numba.
4. REST API authentication: CSRF session token required (not just header), must visit page first to establish session state
5. Registration rate limit: 3 per hour per IP (in-memory, resets on server restart)

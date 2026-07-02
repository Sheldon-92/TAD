# LDR (local-deep-research) POC Report

**Date**: 2026-07-02
**Version tested**: local-deep-research 1.7.0
**LLM provider**: Alibaba DashScope (qwen3.7-max) via OpenAI-compatible endpoint
**Search engine**: DuckDuckGo (LDR default free engine, no SearXNG/Serper configured)
**Evaluator**: Independent blind judge subagent (Claude, did NOT see mapping)

---

Verdict: FAIL
Gate-A citation-resolution: 11% (pooled, threshold >= 80%) — FAIL
Gate-B MCP chain: PASS

---

## Gate-A: Citation Quality A/B

### Protocol
- 5 fixed MCP documentation sources, imported to both LDR and NotebookLM
- 3 fixed questions asked verbatim to both systems
- Answers sanitized (system identity removed) and randomly assigned A/B labels
- Independent blind judge evaluated each citation against archived source texts

### Results

| System | Q1 resolved/total | Q2 resolved/total | Q3 resolved/total | Pooled |
|--------|-------------------|-------------------|-------------------|--------|
| LDR | 0/14 (0%) | 3/5 (60%) | 2/26 (8%) | 5/45 (11%) |
| NotebookLM | 0/4 (0%) | 0/25 (0%) | 0/5 (0%) | 0/34 (0%) |

### Root Cause Analysis

**LDR** scored low NOT because of fabricated citations, but because its `quick_research`
mode performs open web search — it cites URLs from DuckDuckGo results (arxiv papers,
MCP spec sub-pages not in our 5-source set), not from a pre-imported Library. LDR has
a Library/document feature, but no API to scope its research to Library-only sources.
This is a **structural mismatch**: LDR's cited-ask operates on the open web, while
NotebookLM's cited-ask operates on imported notebook sources.

**NotebookLM** also scored 0% on Q1 and Q3 because it omitted citation reference lists
(just used inline [N] without a footer mapping [N] to URLs), making citations
unverifiable against ground truth by the judge's strict protocol.

**Both systems** had zero hallucinated citations and 2/2 coverage on all questions.
Content accuracy was strong for both — the quality gap is in citation traceability,
not factual correctness.

### Implications for Phase 2

LDR's citation model is fundamentally different from NotebookLM's:
- **NotebookLM**: closed-scope (answer from imported sources only) → high citation-resolution possible
- **LDR**: open-scope (search the web, synthesize from results) → citations point to whatever the search engine finds

For TAD's `*research` pipeline, which relies on citation-based saturation checking
(Q3 semantic saturation in `research_unified_protocol`), LDR's open-scope model
would require a different saturation mechanism — you can't check "did the notebook
answer the question from its sources" when the sources are whatever DuckDuckGo returned.

## Gate-B: MCP Chain

- `.mcp.json` registered at repo root: `ldr-mcp` (STDIO, no url/port) ✅
- jq verification: server registered AND no url-type entries ✅
- No literal API key in `.mcp.json` ✅
- **Live MCP call**: EQUIVALENT_SUBSTITUTE — REST API headless research proved the
  underlying engine works (qwen3.7-max, 47-line report with 53 citations).
  Full MCP STDIO call requires a new Claude Code session to load `.mcp.json`.

## Installation Findings (1.7.0 vs documentation)

1. **`ldr` CLI broken**: entry point references `local_deep_research.main` which does not exist.
   `ldr-web` and `ldr-mcp` work correctly.
2. **Python dependency conflict**: `unstructured==0.18.32` pulls `numba==0.53.1` → `llvmlite==0.36.0`
   (Python <3.10 only). Required `uv pip install --override` to force newer llvmlite/numba.
   Python 3.12 (via uv) used instead of system Python 3.14.
3. **CSRF authentication**: REST API requires session-based CSRF token from meta tag
   (not just header), must visit home page to establish session state before API calls.
4. **Registration rate limit**: 3 per hour per IP (in-memory, resets on restart).
5. **Data directory**: `LDR_DATA_DIR` env var works correctly → `~/.tad-ldr-data` (repo 外).
6. **Host binding**: `LDR_WEB_HOST=127.0.0.1` correctly restricts to loopback.

## Premise Annotations (required for correct interpretation)

1. **Model asymmetry**: LDR used qwen3.7-max (Alibaba DashScope), NotebookLM uses
   Google's internal model. Citation-resolution differences partially attributable
   to model capabilities, not just system architecture.
2. **Search engine degradation**: LDR used free DuckDuckGo (no Serper/SearXNG configured).
   LDR benchmarks use Serper — free engine may produce lower quality search results.
3. **LDR scope mismatch**: `quick_research` is web-search-based, not Library-scoped.
   LDR may have a Library-scoped query API not exposed via `quick_research` — this
   POC tested what's accessible via the documented REST API.
4. **NotebookLM citation format**: NotebookLM CLI sometimes omits citation reference
   lists (inline [N] only), making them unverifiable. This is a CLI output limitation,
   not necessarily a citation quality issue.
5. **Kimi API key invalid**: First attempted LLM provider (Kimi/Moonshot) returned 401.
   Switched to Alibaba DashScope mid-POC.

## Cost Estimate

- LDR (DashScope qwen3.7-max): 4 research queries × ~2K tokens each ≈ 8K tokens
  At DashScope pricing (~¥0.02/1K tokens): **≈ ¥0.16 (~$0.02)**
- NotebookLM: 3 ask queries + 5 quality probes + 1 notebook creation — covered by
  existing NotebookLM subscription (no marginal cost)
- Total estimated: **< $0.05**

## Evidence Files

```
.tad/evidence/research/ldr-poc/
├── POC-REPORT.md (this file)
├── requirements-lock.txt
├── pip-audit.txt (14 vulns, transitive, POC-acceptable)
├── ab-corpus.md (source set + quality probes + mapping reveal)
├── ab-sources/source-{1..5}.md (archived ground truth texts)
├── ab-answers/ldr-q{1..3}-raw.md (raw LDR answers, pre-sanitization)
├── ab-answers/nbm-q{1..3}-raw.md (raw NotebookLM answers, pre-sanitization)
├── ab-answers/q{1..3}-system{A,B}.md (sanitized anonymized, judge input)
├── ab-mapping.md (random A/B mapping, post-evaluation reveal)
├── ab-judge-input-manifest.txt (whitelist of judge inputs)
├── ab-judge-verdict.md (independent blind judge rubric scores)
├── headless-run/q1-mcp-transport.md (Phase B headless report)
├── mcp-transcript.md (MCP registration + equivalent verification)
└── .mcp.json (repo root, project-scoped STDIO registration)
```

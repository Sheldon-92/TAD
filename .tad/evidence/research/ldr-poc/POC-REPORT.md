# LDR (local-deep-research) POC Report

**Date**: 2026-07-02 (updated after Gate 4 rework — Library-scoped supplemental)
**Version tested**: local-deep-research 1.7.0
**LLM provider**: Alibaba DashScope (qwen3.7-max) via OpenAI-compatible endpoint
**Search engine**: DuckDuckGo (default mode) / Library collection RAG (supplemental)
**Evaluator**: Independent blind judge subagents (Claude, did NOT see mapping; separate judges per round)

---

Verdict: FAIL
Gate-A citation-resolution: 23% (pooled, threshold >= 80%) — FAIL
Gate-B MCP chain: PASS

---

## Gate-A: Citation Quality A/B

### Protocol
- 5 fixed MCP documentation sources, imported to both LDR and NotebookLM
- 3 fixed questions asked verbatim to both systems
- Answers sanitized (system identity removed) and randomly assigned A/B labels
- Independent blind judge evaluated each citation against archived source texts
- **Two rounds**: (1) LDR default `quick_research` (open web), (2) LDR Library-scoped
  (`search_tool=collection_{id}` after Gate 4 rework — the decisive mode)

### Round 1: Default quick_research (open web search)

| System | Q1 resolved/total | Q2 resolved/total | Q3 resolved/total | Pooled |
|--------|-------------------|-------------------|-------------------|--------|
| LDR (web) | 0/14 (0%) | 3/5 (60%) | 2/26 (8%) | 5/45 (11%) |
| NotebookLM | 0/4 (0%) | 0/25 (0%) | 0/5 (0%) | 0/34 (0%) |

Root cause: `quick_research` searches the open web. Citations point to DuckDuckGo results
(arxiv papers, MCP spec sub-pages not in 5-source set). This mode is NOT Library-scoped.

### Round 2: Library-scoped (search_tool=collection) — DECISIVE ROUND

Collection `MCP-POC-Sources` created with 5 source files uploaded + RAG-indexed.
Research run with `search_tool=collection_cf98d582-311a-410f-830c-fa08b39f6925`.

| System | Q1 resolved/total | Q2 resolved/total | Q3 resolved/total | Pooled |
|--------|-------------------|-------------------|-------------------|--------|
| LDR (library) | 1/4 (25%) | 2/4 (50%) | 0/5 (0%)* | 3/13 (23%) |
| NotebookLM | 0/4 (0%)* | 0/25 (0%)* | 2/22 (9%) | 2/51 (4%) |

\* = answer lacks URL bibliography (citations are opaque [N] markers with no reference list)

**Gate-A uses Round 2 (Library-scoped) numbers: LDR pooled = 3/13 = 23%**

### Root Cause Analysis (updated after supplemental round)

1. **LDR Library-scoped mode EXISTS and WORKS** — `search_tool=collection_{id}` correctly
   routes research to the collection's RAG index. Alex's primary-source check (v1.7.0 tag
   docs/library-and-rag.md) was correct; Blake's initial root cause ("no Library-scoped API")
   was wrong.

2. **Citation resolution remains low (23%) for a different reason**: even in Library-scoped
   mode, LDR's LLM synthesis step does not constrain citations to collection sources. Q1
   still cited 3 out-of-scope MCP sub-pages (real docs, but not in the 5-source set). Q3's
   answer lacked a URL bibliography entirely (qwen3.7-max responded in Chinese without refs).

3. **NotebookLM also scored poorly (4%)** in this round — most answers omitted URL reference
   lists (NotebookLM CLI format limitation), making citations unverifiable by the rubric.

4. **Both systems have 100% content accuracy** — zero hallucinated citations, 2/2 coverage on
   all questions. The gap is in formal citation traceability, not factual correctness.

5. **Model language issue**: qwen3.7-max sometimes responds in Chinese, omitting URL
   bibliographies. This is a model behavior, not an LDR architectural limitation. A different
   LLM (e.g., Claude via Anthropic API) might produce better-structured citations.

### Implications for Phase 2

The Library-scoped mode exists but citation resolution (23%) is far below the 80% threshold.
Contributing factors are partially architectural (LLM not constrained to cite only collection
sources) and partially model-specific (qwen3.7-max Chinese output format). Phase 2 would need:
- **LLM swap test**: re-run with Claude or GPT-4o to isolate model vs architecture effect
- **Citation format enforcement**: investigate LDR's prompt engineering for citation formatting
- Neither is guaranteed to reach 80% — the A/B test design may need adaptation

## Gate-B: MCP Chain

- `.mcp.json` registered at repo root: `ldr-mcp` (STDIO, no url/port) ✅
- jq verification: server registered AND no url-type entries ✅
- No literal API key in `.mcp.json` ✅
- **Live MCP call**: EQUIVALENT_SUBSTITUTE — REST API headless research proved the
  underlying engine works (qwen3.7-max, 46-line report with 25 citations).
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
7. **Library RAG indexing**: DetachedInstanceError on batch index (SQLAlchemy session bug);
   resolved by sequential retries (5/5 indexed after 4 attempts).
8. **Collection search_tool**: `search_tool=collection_{uuid}` correctly scopes research
   to collection documents via RAG semantic search.

## Premise Annotations (required for correct interpretation)

1. **Model asymmetry**: LDR used qwen3.7-max (Alibaba DashScope), NotebookLM uses
   Google's internal model. Citation format differences partially attributable to model.
2. **Search engine degradation**: Round 1 used free DuckDuckGo (no Serper/SearXNG).
   LDR benchmarks use Serper — free engine produces lower quality search results.
3. **Library-scoped mode tested**: Round 2 used `search_tool=collection_{id}` to scope
   research to the 5-source collection. LDR does have this capability (contra Round 1 claim).
4. **NotebookLM citation format**: NotebookLM CLI omits URL reference lists in most answers,
   making citations unverifiable. Both systems share this issue with qwen3.7-max.
5. **Kimi API key invalid**: First LLM provider (Kimi/Moonshot) returned 401.
   Switched to Alibaba DashScope. Model choice affects citation format behavior.

## Cost Estimate

- LDR (DashScope qwen3.7-max): 7 research queries (4 Round 1 + 3 Round 2) ≈ 14K tokens
  At DashScope pricing (~¥0.02/1K tokens): **≈ ¥0.28 (~$0.04)**
- NotebookLM: 3 ask queries + 5 quality probes + 1 notebook creation — existing subscription
- Total estimated: **< $0.10**

## Evidence Files

```
.tad/evidence/research/ldr-poc/
├── POC-REPORT.md (this file)
├── requirements-lock.txt
├── pip-audit.txt (14 vulns, transitive, POC-acceptable)
├── ab-corpus.md (source set + quality probes + mapping reveal)
├── ab-sources/source-{1..5}.md (archived ground truth texts)
├── ab-answers/
│   ├── ldr-q{1..3}-raw.md (Round 1: LDR web-search raw)
│   ├── ldr-lib-q{1..3}-raw.md (Round 2: LDR Library-scoped raw)
│   ├── nbm-q{1..3}-raw.md (NotebookLM raw, shared across rounds)
│   ├── q{1..3}-system{A,B}.md (Round 1: sanitized anonymized)
│   └── lib-q{1..3}-system{A,B}.md (Round 2: sanitized anonymized)
├── ab-mapping.md (Round 1 random mapping)
├── ab-mapping-lib.md (Round 2 random mapping)
├── ab-judge-input-manifest.txt (Round 1 whitelist)
├── ab-judge-input-manifest-lib.txt (Round 2 whitelist)
├── ab-judge-verdict.md (Round 1 blind judge)
├── ab-judge-verdict-lib.md (Round 2 blind judge)
├── headless-run/q1-mcp-transport.md (Phase B headless report)
├── mcp-transcript.md (MCP registration + equivalent verification)
└── .mcp.json (repo root, project-scoped STDIO registration)
```

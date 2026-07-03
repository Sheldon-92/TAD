# Gate Decision: gbrain POC for TAD Knowledge Search

**Date**: 2026-07-03
**Epic**: EPIC-20260703-gbrain-tad-integration (Phase 1/2)
**Threshold**: ≥3/5 queries "有用" → PASS

## Summary

| # | Query | Verdict | Key Finding |
|---|-------|---------|-------------|
| Q1 | Terminal isolation design rationale | ❌ 无用 | BM25 can't connect "terminal isolation" to its design rationale |
| Q2 | Hardcoded allow-list problems | ✅ 有用 | Found principle + 4 related evidence files across directories |
| Q3 | Rationalization history | ❌ 无用 | Found keyword matches but not actual rationalization instances |
| Q4 | Safety patterns interaction | ❌ 无用 | Self-referenced handoff; didn't find SAFETY entries in principles |
| Q5 | Coverage gap analysis | ❌ 无用 | Zero search results; think requires Anthropic API key |

**Score: 1/5 ✅**

## Gate Decision: ❌ FAIL (1/5 < 3/5 threshold)

## Analysis

### Why Q2 Succeeded Where Others Failed
Q2 worked because "allow-list" and "deny-list" are EXACT KEYWORDS used consistently across principles.md, decision records, and implementation evidence. BM25 excels when terminology is uniform across documents. The other queries required semantic understanding:
- Q1: "terminal isolation" → "Terminal 隔离" (mixed language, different phrasing)
- Q3: "rationalization" → "⚠️ ANTI-RATIONALIZATION:" (marker format, not natural language)
- Q4: "safety patterns" → "⚠️ SAFETY ENTRY" (domain-specific marker vs common English)
- Q5: "coverage gaps" → analytical question about absence (impossible for retrieval)

### What This Tells Us

1. **BM25 alone is insufficient for TAD's knowledge queries** — TAD uses mixed CJK/English, domain-specific markers, and varied phrasing for the same concepts. Keyword matching can't bridge these gaps.

2. **Entity graph was empty (0 links)** — TAD's markdown files don't use `[[wikilink]]` format that gbrain looks for. The graph feature, a key differentiator of gbrain, adds zero value without format adaptation. Note: Alex approved testing "BM25 + 实体图谱" — the actual test was BM25 ONLY (both planned features, embeddings AND entity graph, were absent). The POC tested a MORE degraded configuration than approved.

3. **`think` synthesis exists but requires API key** — gbrain's synthesis pipeline (gather → LLM-synthesize → cite) could potentially answer Q3-Q5, but it needs Anthropic API key. This reintroduces the external dependency the POC tried to avoid.

4. **Import was flawless** — 2282/2286 files imported in 50.2s, 10255 chunks, 0 errors. The ingest pipeline handles TAD's file structure well (CJK content, YAML frontmatter, large files).

### Technical Observations

| Metric | Value |
|--------|-------|
| gbrain version | 0.42.56.0 |
| Pages imported | 2282 |
| Chunks created | 10255 |
| Embeddings | 0 (no-embedding mode) |
| Links extracted | 0 (TAD doesn't use wikilinks) |
| Import time | 50.2s |
| Import errors | 0 |
| Files skipped | 4 (frontmatter slug conflicts) |
| Search mode | conservative (no LLM expansion) |
| DB path | /Users/sheldonzhao/.gbrain/brain.pglite |
| Install path | ~/.gbrain-poc/node_modules/.bin/gbrain |

### Deviation from Handoff
- **Planned**: Local llama.cpp embedding (zero cost)
- **Actual**: `--no-embedding` mode (gbrain does NOT support llama.cpp; only OpenAI/Voyage/ZeroEntropy API)
- **Impact**: No vector semantic search available, only BM25 keyword search
- **Alex approved**: "如果纯 BM25 + 实体图谱就能 ≥3/5 有用 → 说明价值在图谱和结构化搜索"

### Recommendation for Alex

**Option A: Close Epic (NEGATIVE-RESULT)**
gbrain without embedding or LLM synthesis does not meet TAD's semantic search needs. BM25 keyword search is not meaningfully better than `grep`.

**Option B: Re-test with embedding API key**
The 1/5 score reflects BM25-only testing. gbrain's architecture (hybrid RRF search + graph + think synthesis) COULD perform better with:
- Embedding API key (OpenAI/Voyage) for vector search
- Anthropic API key for `think` synthesis
Estimated cost: ~$2-5 for initial embedding + ~$0.01/query for think.

**Option C: Pivot to TAD-native approach**
Instead of gbrain, build a minimal TAD-specific tool:
- Use Claude Code's existing Explore agents for semantic search (already available, no extra cost)
- Add `[[wikilink]]` cross-references to .tad/ files for graph traversal
- This leverages what TAD already has rather than adapting to an external tool's format expectations

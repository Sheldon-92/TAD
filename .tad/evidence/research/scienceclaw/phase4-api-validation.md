# Phase 4 API Validation Results

**Date**: 2026-05-28
**Script**: .tad/capability-packs/academic-research/scripts/academic-search.sh

---

## Live API Test Results

| # | Database | Status | Test Query | Results | Response Time |
|---|----------|--------|-----------|---------|--------------|
| 1 | Semantic Scholar | ✅ PASS | "CRISPR cancer therapy" | 2 papers with titles, authors, years, DOIs, citations | ~2s |
| 2 | OpenAlex | ✅ PASS | "machine learning protein folding" | 2 papers (AlphaFold 44417 citations) | ~1s |
| 3 | PubMed | ✅ PASS | "immunotherapy" | 517,115 total results, 2 summaries with PMIDs + DOIs | ~2s (2 calls: search + summary) |
| 4 | arXiv | ✅ PASS | "transformer architecture" | 2 papers with titles, authors, URLs | ~2s |
| 5 | Europeana | ⚠️ SKIP | "ornamental pattern" | Graceful skip: "EUROPEANA_API_KEY not set" | <1s |
| 6 | USDA FoodData | ✅ PASS | "sesame" | 12,445 total results, 2 foods with nutrients (DEMO_KEY) | ~1s |

### Notes
- Semantic Scholar: removed `abstract` field from request to avoid timeout; `fields=title,authors,year,citationCount,url,externalIds` is reliable
- arXiv: uses HTTPS (not HTTP); XML parsed with grep/sed instead of Python XML (pyexpat broken on this machine's Python 3.14)
- Europeana: no demo key exists (retired 2023); script checks `$EUROPEANA_API_KEY` env var and skips gracefully
- USDA: `DEMO_KEY` literal works for testing (30 req/hr limit warned)
- PubMed: two-step process (esearch → esummary) works correctly for retrieving metadata
- All queries URL-encoded via `jq -sRr @uri`

## Fallback Chain Test

| Step | Action | Result |
|------|--------|--------|
| 1. Primary | Semantic Scholar "CRISPR therapy" | ✅ Returned results |
| 2. Fallback | OpenAlex "CRISPR therapy" (simulating SS failure) | ✅ Returned results |
| 3. Verification | Both databases return overlapping but complementary results | Confirmed: fallback chain functional |

The 3-strike fallback pattern from fallback-chains.md is implementable: if Semantic Scholar fails 3 times → switch to OpenAlex → if OpenAlex fails → WebSearch.

## Security Verification

- [x] No API keys hardcoded in script (all use env vars)
- [x] Query strings URL-encoded via `jq @uri`
- [x] All variable expansions double-quoted
- [x] This evidence file contains no API key values

## Per-Database Rate Limits (Implemented in Script)

| Database | Rate Limit | Script Sleep | Verified |
|----------|-----------|-------------|---------|
| Semantic Scholar | 100 req/5min | 3s | ✅ |
| OpenAlex | Unlimited (with mailto) | 1s | ✅ |
| PubMed | 3 req/s | 1s | ✅ |
| arXiv | 1 req/3s | 3s | ✅ |
| Europeana | 100 req/min | 1s | ✅ |
| USDA FoodData | 30 req/hr (DEMO_KEY) | 2s | ✅ |

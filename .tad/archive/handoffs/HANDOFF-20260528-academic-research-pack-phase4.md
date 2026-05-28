---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: [".tad/capability-packs/academic-research", ".claude/skills/academic-research"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Academic Research Pack — Phase 4: Database + Tool Integration

**From:** Alex | **To:** Blake | **Date:** 2026-05-28
**Epic:** EPIC-20260527-academic-research-pack.md (Phase 4/6)

---

## 🔴 Gate 2: ✅ PASS

---

## 1. Task Overview

### 1.1 What We're Building
Validate and enhance the database API templates in Phase 3's reference files by testing against live APIs. Add 2 domain-specific databases for the user's research topics (cultural artifact databases for pattern research + USDA FoodData for food science). Write a reusable query helper script. Test fallback chains end-to-end.

### 1.2 Why
Phase 3 wrote API templates from ScienceClaw's skill files, but they haven't been tested against live endpoints. An untested curl template is a promise, not a tool. After this Phase, Blake can actually execute `curl` commands from the reference files and get real search results.

### 1.3 Intent Statement
**不是要做的**:
- ❌ NOT building MCP servers (curl wrappers are sufficient per blueprint Decision 3)
- ❌ NOT rewriting reference files (Phase 3 content stays — this Phase adds tested examples + helper script)
- ❌ NOT multimodal/memory (Phase 5)

---

## 📚 Project Knowledge

**⚠️ Blake 必须注意**:
1. **Hook Shell Portability Rules** (architecture.md) — No `grep -P` on macOS. Use `grep -o` + `sed`.
2. **Source Import Quality: False Success Patterns** (architecture.md) — API responses may return HTML error pages instead of JSON. Validate response content type.

---

## 2. Source Material

- `.claude/skills/academic-research/references/database-apis-general.md` — existing API templates to validate
- `.claude/skills/academic-research/references/database-apis-life-sciences.md` — existing API templates to validate
- `.claude/skills/academic-research/references/fallback-chains.md` — fallback chain definitions to test
- Blueprint Decision 3: `.tad/evidence/research/scienceclaw/tad-mapping-blueprint.md` (database strategy table)

---

## 3. Technical Design

### 3.1 Three Deliverables

**A. Query Helper Script** (`scripts/academic-search.sh`)
A reusable bash script that wraps the most common academic search operations:
```bash
academic-search.sh semantic-scholar "CRISPR cancer therapy" --limit 10
academic-search.sh openalex "machine learning protein folding" --limit 5
academic-search.sh pubmed "immunotherapy" --limit 10
academic-search.sh arxiv "transformer architecture" --limit 5
academic-search.sh europeana "ornamental plant pattern" --limit 10
academic-search.sh usda-food "sesame paste nutrition" --limit 5
```
Each subcommand: constructs the correct curl with URL-encoded query (`jq -rn --arg q "$query" '$q|@uri'`), handles per-database rate limiting (see table below), parses JSON response to structured output (title, authors, year, DOI/URL, abstract snippet). All variable expansions MUST be double-quoted to prevent shell injection.

**Per-database rate limits (MANDATORY in script):**
| Database | Rate Limit | Sleep Between Calls |
|----------|-----------|-------------------|
| Semantic Scholar | 100 req/5min (free) | 3s |
| OpenAlex | Unlimited (with mailto) | 1s |
| PubMed | 3 req/s (no key) | 1s |
| arXiv | 1 req/3s | 3s |
| Europeana | 100 req/min (with key) | 1s |
| USDA FoodData | 30 req/hr (DEMO_KEY) / 3600 req/hr (registered) | 2s |

**B. Live API Validation** — test each database endpoint in the reference files:
| Database | Endpoint | Test Query | Expected |
|----------|----------|-----------|----------|
| Semantic Scholar | `api.semanticscholar.org/graph/v1/paper/search` | "CRISPR" | JSON with papers array |
| OpenAlex | `api.openalex.org/works?search=` | "protein folding" | JSON with results |
| PubMed | `eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi` | "immunotherapy" | XML with IdList |
| arXiv | `export.arxiv.org/api/query?search_query=` | "transformer" | XML/Atom feed |
| Europeana | `api.europeana.eu/record/v2/search.json` | "ornamental pattern" | JSON with items |
| USDA FoodData | `api.nal.usda.gov/fdc/v1/foods/search` | "sesame" | JSON with foods |

**C. Domain-Specific Database Addition** — add 2 databases for user's research topics:
1. **Europeana** (cultural heritage — 50M+ digital objects from European museums): for plant/artifact pattern research
2. **USDA FoodData Central** (food composition — 400K+ food items): for food science research

Add these to `database-apis-general.md` (Europeana) and a new section or existing life-sciences file (USDA).

### 3.2 Fallback Chain Testing
Test the 3-strike fallback pattern from fallback-chains.md:
1. Query Semantic Scholar → success (primary)
2. Simulate failure (bad query) → fallback to OpenAlex → success
3. Both fail → fallback to WebSearch

Document test results in evidence.

---

## 4. Implementation Steps

### Task 1: Write academic-search.sh (30 min)
1. Create `.tad/capability-packs/academic-research/scripts/academic-search.sh`
2. Implement subcommands for: semantic-scholar, openalex, pubmed, arxiv, europeana, usda-food
3. Each subcommand: build curl command, handle rate limiting, parse response, format output
4. Include `--help` flag and error handling
5. Make executable: `chmod +x`

### Task 2: Live API Validation (20 min)
1. Run each subcommand against live endpoints
2. Capture successful response for each (save to evidence)
3. Fix any broken curl templates in reference files
4. Document: which APIs need keys, which are free, actual rate limits observed

### Task 3: Add Domain Databases (15 min)
1. Get Europeana API key (free, instant at apis.europeana.eu) OR test with demo key
2. Get USDA FoodData API key (free at fdc.nal.usda.gov/api-key-signup.html) OR test with DEMO_KEY
3. Add Europeana section to database-apis-general.md
4. Add USDA FoodData section to database-apis-life-sciences.md (food science = applied life science)
5. Add both to academic-search.sh

### Task 4: Fallback Chain Test (10 min)
1. Test primary → secondary fallback (bad Semantic Scholar query → OpenAlex)
2. Document results in evidence file
3. Update fallback-chains.md if observed behavior differs from documented

### Task 5: Re-install + Verify (5 min)
1. Re-run install.sh
2. Verify scripts/ directory copied
3. Verify updated reference files installed

---

## 5. Files to Create/Modify

| # | File | Action |
|---|------|--------|
| 1 | .tad/capability-packs/academic-research/scripts/academic-search.sh | CREATE |
| 2 | .tad/capability-packs/academic-research/references/database-apis-general.md | MODIFY (add Europeana) |
| 3 | .tad/capability-packs/academic-research/references/database-apis-life-sciences.md | MODIFY (add USDA FoodData) |
| 4 | .tad/capability-packs/academic-research/references/fallback-chains.md | MODIFY (if test reveals corrections) |
| 5 | .tad/capability-packs/academic-research/install.sh | MODIFY (add scripts/ copy) |
| 6 | .tad/evidence/research/scienceclaw/phase4-api-validation.md | CREATE (test results) |
| 7 | .claude/skills/academic-research/ (via re-install) | MODIFY |

---

## 9. Acceptance Criteria

| # | Requirement | Verification |
|---|------------|-------------|
| AC1 | academic-search.sh exists and is executable | `test -x .tad/capability-packs/academic-research/scripts/academic-search.sh` |
| AC2 | ≥4 database subcommands work against live APIs | `for db in semantic-scholar openalex pubmed arxiv; do bash .tad/capability-packs/academic-research/scripts/academic-search.sh $db "test query" --limit 1 2>&1 \| head -5; done` — each returns structured data |
| AC3 | Europeana subcommand returns cultural heritage results | `bash .../academic-search.sh europeana "ornamental pattern" --limit 3` returns ≥1 result |
| AC4 | USDA FoodData subcommand returns food data | `bash .../academic-search.sh usda-food "sesame" --limit 3` returns ≥1 result |
| AC5 | Fallback chain tested | phase4-api-validation.md documents primary→secondary fallback test |
| AC6 | Per-database rate limiting | `grep -cE 'sleep [0-9]' .tad/capability-packs/academic-research/scripts/academic-search.sh` ≥ 4 (each subcommand has its own sleep value) |
| AC7 | Reference files updated with Europeana + USDA | `grep -c 'europeana' .../references/database-apis-general.md` ≥ 1 AND `grep -c 'USDA\|FoodData' .../references/database-apis-life-sciences.md` ≥ 1 |
| AC8 | install.sh copies scripts/ | `ls .claude/skills/academic-research/scripts/academic-search.sh` exists after install |
| AC9 | API validation evidence saved | `test -f .tad/evidence/research/scienceclaw/phase4-api-validation.md` |
| AC10 | Query strings URL-encoded (no shell injection) | `grep -c '@uri' .tad/capability-packs/academic-research/scripts/academic-search.sh` ≥ 1 |
| AC11 | Evidence file has no leaked API keys | `grep -ciE 'wskey=[a-z0-9]{8}\|api_key=[a-z0-9]{8}' .tad/evidence/research/scienceclaw/phase4-api-validation.md` = 0 |

---

## 10. Important Notes

### 10.1 API Key Handling
- Semantic Scholar, OpenAlex, PubMed, arXiv: FREE, no key required for basic access
- Europeana: free key required (instant signup at apis.europeana.eu) — use `EUROPEANA_API_KEY` env var. ⚠️ NO demo key exists (retired 2023). Script MUST check `$EUROPEANA_API_KEY` is set; if missing → print "Set EUROPEANA_API_KEY (free: https://pro.europeana.eu/page/get-api)" and skip gracefully (exit 0, not error)
- USDA FoodData: free key — use `USDA_API_KEY` env var. `DEMO_KEY` literal works for testing but limited to 30 req/hr. Script should warn if using DEMO_KEY: "Using DEMO_KEY (30 req/hr). Get free key: https://fdc.nal.usda.gov/api-key-signup.html"
- ⚠️ NEVER hardcode API keys in scripts. Use env vars only.
- ⚠️ Evidence files (phase4-api-validation.md) MUST redact API keys from captured curl commands/URLs. Replace key values with `[REDACTED]` before writing to file.

### 10.2 Sub-Agent Suggestions
- code-reviewer: verify script quality (error handling, rate limiting, portability)
- test-runner: run the API validation suite

---

## 11. Decision Summary

| # | Decision | Chosen | Rationale |
|---|----------|--------|-----------|
| 1 | Integration approach | bash script wrapper (not MCP) | Blueprint Decision 3: curl-based wrappers are natural for Claude Code |
| 2 | Domain databases | Europeana + USDA FoodData | User's research topics: plant patterns (cultural heritage) + food science |
| 3 | API key strategy | env vars with demo fallback | Security: no hardcoded keys; usability: works without signup for testing |

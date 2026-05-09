---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: [".tad/cross-model/handlers"]
skip_knowledge_assessment: yes
gate4_delta: []
---

# Mini-Handoff: Bugfix — Source Preprocessor Handler Fixes

**From:** Alex | **To:** Blake | **Date:** 2026-05-09
**Type:** Express Bugfix (E2E testing revealed 3 P0 + 4 P1)
**Priority:** P0

## Bug Description

E2E testing of add-smart against real URLs revealed handler bugs. The article mode is completely non-functional (jq path mismatch), curl has no timeout on stock macOS, and Jina handler crashes on nested URLs.

## Root Cause Analysis

1. **x-handler.sh article**: API returns `.article.contents` (plural) but jq path uses `.article.content` (singular). 73 content blocks exist but jq falls through to `[]`. Tweet jq paths also unverified.
2. **All handlers curl**: No `--max-time` flag. Parent's `run_with_timeout` is a no-op on stock macOS without `gtimeout`/`timeout`. Hung API connection blocks indefinitely.
3. **jina-handler.sh**: curl exit 3 for nested `https://r.jina.ai/https://...` URLs under `set -e`. Fix (`|| true`) already applied but needs commit.
4. **scholar-handler.sh**: md5 portability bug (macOS `md5` outputs `MD5 (...) = hash`, `cut -c1-8` grabs garbage). S2 API all-null fields fall through to stub without title-search retry.

## Fixes Required

### P0-1: x-handler.sh — Fix article jq path (line 77)

```bash
# BEFORE (broken):
.data.article.content // .article.content // .content // [] |

# AFTER (fixed):
.data.article.contents // .article.contents // .contents // .data.article.content // .article.content // .content // [] |
```

Also: empirically verify tweet endpoint (line 127) jq paths by curling `https://api.twitterapi.io/twitter/tweets?tweet_ids=1905545699552375179` and checking whether `.tweets[0].text` or `.data[0].text` matches.

### P0-2: All 4 handlers — Add `--connect-timeout 10 --max-time 25` to every curl call

```bash
# Add to every curl invocation across x-handler.sh (3 calls), jina-handler.sh (1), scholar-handler.sh (2), bilibili-handler.sh (0 — yt-dlp not curl)
curl -s --connect-timeout 10 --max-time 25 -w "\n%{http_code}" \
  -H "X-API-Key: ${API_KEY}" \
  -- "https://api.twitterapi.io/..." 2>/dev/null
```

### P0-3: jina-handler.sh — Commit the `|| true` fix + add empty response guard

Already applied at line 24. Add guard after line 27:
```bash
if [ -z "$response" ]; then
  echo "ERROR: Jina Reader returned no response (network/DNS failure?)" >&2
  exit 1
fi
```

### P1-1: scholar-handler.sh — Fix md5 portability (line 100)

```bash
# BEFORE:
paper_id="${s2_id:-$(echo "$url" | md5 2>/dev/null | cut -c1-8 || echo "paper")}"

# AFTER (matches bilibili-handler.sh pattern):
paper_id="${s2_id:-$(printf '%s' "$url" | { md5 2>/dev/null || md5sum 2>/dev/null; } | awk '{print substr($NF,1,8)}')}"
```

### P1-2: scholar-handler.sh — Add title-search fallback for all-null S2 responses

After line 82 (response check), before line 84 (PDF extraction):
```bash
# If all fields null, try title-based re-search
s2_title=$(echo "$response" | jq -r '.title // empty' 2>/dev/null)
s2_abstract=$(echo "$response" | jq -r '.abstract // empty' 2>/dev/null)
if [ -z "$s2_title" ] && [ -z "$s2_abstract" ]; then
  # Extract human-readable query from URL path
  fallback_query=$(echo "$url" | sed 's|.*/paper/||' | sed 's|/[a-f0-9]*$||' | sed 's/%3A/:/g; s/-/ /g; s/+/ /g')
  if [ -n "$fallback_query" ]; then
    encoded_q=$(printf '%s' "$fallback_query" | jq -sRr '@uri')
    response=$(curl -s --connect-timeout 10 --max-time 25 \
      -- "https://api.semanticscholar.org/graph/v1/paper/search?query=${encoded_q}&fields=title,abstract,openAccessPdf,externalIds&limit=1" \
      2>/dev/null || true)
    response=$(echo "$response" | jq '.data[0] // empty' 2>/dev/null)
  fi
fi
```

### P1-3: All handlers — Use `printf '%s'` instead of `echo` for body piping

Replace `echo "$body" | jq` with `printf '%s\n' "$body" | jq` in x-handler.sh (3 sites), scholar-handler.sh (2 sites). `echo` can interpret backslash sequences on some shells.

## Affected Files

| File | Changes |
|------|---------|
| `.tad/cross-model/handlers/x-handler.sh` | P0-1 jq path + P0-2 curl timeout + P1-3 printf |
| `.tad/cross-model/handlers/jina-handler.sh` | P0-3 commit || true + empty guard + P0-2 curl timeout |
| `.tad/cross-model/handlers/scholar-handler.sh` | P1-1 md5 + P1-2 title fallback + P0-2 curl timeout + P1-3 printf |

## Acceptance Criteria

- [ ] AC1: x-handler article mode produces non-empty .md for tweet_id 1905545699552375179
- [ ] AC2: `grep -c 'contents' .tad/cross-model/handlers/x-handler.sh` ≥ 1
- [ ] AC3: `grep -c 'max-time' .tad/cross-model/handlers/x-handler.sh` ≥ 3 (one per curl call)
- [ ] AC4: `grep -c 'max-time' .tad/cross-model/handlers/jina-handler.sh` ≥ 1
- [ ] AC5: `grep -c 'max-time' .tad/cross-model/handlers/scholar-handler.sh` ≥ 1
- [ ] AC6: jina-handler.sh handles empty curl response without crash
- [ ] AC7: scholar-handler.sh md5 produces valid 8-char hex on macOS (`printf '%s' 'test' | md5 | awk '{print substr($NF,1,8)}'`)
- [ ] AC8: `grep -c 'printf.*%s' .tad/cross-model/handlers/x-handler.sh` ≥ 1

## Blake Instructions

- Express bugfix — apply fixes, run Ralph Loop Layer 1, verify ACs
- P0-1 critical: verify x-handler article mode works with real API call before committing
- P0-2: add `--connect-timeout 10 --max-time 25` to ALL curl calls in all 3 handler files
- If fix turns out more complex than described, escalate to user

## Expert Review

| Reviewer | Issue | Resolution | Status |
|----------|-------|------------|--------|
| code-reviewer | P0 x-handler jq `.content` vs `.contents` | §P0-1 fix | Resolved |
| code-reviewer | P0 all handlers no `--max-time` | §P0-2 fix | Resolved |
| code-reviewer | P1 scholar md5 portability | §P1-1 fix | Resolved |
| code-reviewer | P1 echo vs printf | §P1-3 fix | Resolved |
| code-reviewer | P1 jina empty response guard | §P0-3 fix | Resolved |
| code-reviewer | P0 tweet jq paths unverified | §P0-1 note: Blake must verify empirically | Open (Blake verifies) |

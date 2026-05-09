---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/research-notebook", ".tad/cross-model"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: NotebookLM Source Preprocessor Pipeline

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-05-09
**Project:** TAD
**Task ID:** TASK-20260509-001
**Handoff Version:** 3.1.0
**Epic:** N/A

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-05-09

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Router + modular handlers + quality verification. 6 P0 from expert review resolved v2. |
| Components Specified | ✅ | Handler contract defined (input/output/exit codes). URL patterns as shell case. |
| Functions Verified | ✅ | Existing `ingest` reused for import+verify. twitterapi.io endpoint verified via docs. |
| Data Flow Mapped | ✅ | URL → normalize → detect type → preprocess or direct → source add → verify → fallback |

**Gate 2 结果**: ✅ PASS (post expert review v2)

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史教训**
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 1.1 What We're Building

A **source preprocessor pipeline** for TAD's `*research-notebook` tool that enables importing high-value content that NotebookLM cannot handle directly. This adds a new `source add-smart` command that auto-detects URL types, applies appropriate preprocessing (API extraction, subtitle extraction, content scraping), converts to local Markdown, imports via `source add`, and verifies content quality post-import.

### 1.2 Why We're Building It

**业务价值**: Current NotebookLM research is limited to sources it can directly ingest — mostly simple web pages and PDFs. High-value sources (X/Twitter expert threads, Bilibili tutorials, academic papers behind WAF, Substack newsletters, Medium articles) are all inaccessible. This means TAD research notebooks are filled with SEO-quality content instead of expert-level knowledge.

**用户受益**: Researchers can import ANY high-value source regardless of platform restrictions, paywalls, or rendering technology. One command (`source add-smart`) handles everything.

**成功的样子**: When a user can run `*research-notebook add-smart https://x.com/expert/status/123` and get the full article content imported into their notebook with verified quality.

### 1.3 Intent Statement

**真正要解决的问题**: NotebookLM's source import has a large blind spot — 10/14 source types tested fail or produce useless content. TAD's research quality ceiling is capped by this limitation.

**不是要做的**:
- ❌ Not replacing NotebookLM — it's still the knowledge synthesis engine
- ❌ Not building a general web scraper — only specific high-value source types
- ❌ Not doing local Whisper transcription (too CPU-heavy) — cloud-based is future work
- ❌ Not parallelizing the pipeline (v2 optimization) — v1 is serial-correct

---

## 📚 Project Knowledge (Blake 必读)

### 步骤 1：相关类别
- [x] architecture - CLI tool integration patterns, NotebookLM behavior

### 步骤 2：历史经验摘录

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| architecture.md | 8 条 | NotebookLM CLI patterns, venv paths, API quirks |

**⚠️ Blake 必须注意的历史教训**:

1. **Venv Absolute Path for AI-Invoked CLI Tools** (architecture.md, 2026-05-03)
   - All CLI invocations must use absolute path `~/.tad-notebooklm-venv/bin/notebooklm`, never bare `notebooklm`
   - Same applies to any new CLI tools (yt-dlp, curl) — verify they're in PATH or use absolute

2. **NotebookLM YouTube Source: Caption Requirement** (architecture.md, 2026-05-03)
   - YouTube fails with "API returned no data" when video has no captions
   - Conference talks / official channels always have auto-generated captions

3. **Knowledge Feedback Loop Requires source add, Not note create** (architecture.md, 2026-05-04)
   - Notes do NOT appear in `ask` context — only `source add` items participate
   - Local .md → `source add local.md` is the confirmed working path for injecting content

4. **NotebookLM CLI Capability Matrix** (architecture.md, 2026-05-04)
   - `source add` exit 0 ≠ content success — status can be "ready" with useless content
   - `source stale`: exit 0 = stale, exit 1 = fresh (inverted shell convention)

5. **notebooklm-py Minimum 0.3.4 Required** (architecture.md, 2026-05-04)
   - Older versions have broken RPC endpoints

---

## 2. Background Context

### 2.1 Previous Work
- `*research-notebook add <url>` — existing simple passthrough to NotebookLM CLI
- `*research-notebook research --mode deep/fast` — auto-research via CLI
- SPIKE-20260509-notebooklm-import-boundary.md — boundary test (this handoff's foundation)

### 2.2 Current State
- NotebookLM source add succeeds on: arXiv PDF (excellent), arXiv abstract (marginal), ACM paywall (abstract only)
- NotebookLM source add FAILS on: YouTube (2/2), Substack, Medium
- NotebookLM source add FALSE SUCCESS on: Bilibili (nav only), AWS docs (TOC only), GitHub (UI nav), X/Twitter (privacy warning), Semantic Scholar (403), Google Scholar (error)

### 2.3 Dependencies
- **twitterapi.io API**: Key at `~/.openclaw/workspace/data/twitterapi.key`, GET /twitter/article (100 credits/article), GET /twitter/tweets (search + thread)
- **yt-dlp**: Bilibili subtitle extraction (`--write-sub --sub-lang zh-Hans`). Verify: `command -v yt-dlp`
- **Jina Reader API**: `https://r.jina.ai/<URL>` — converts any URL to Markdown. Free tier available
- **Semantic Scholar API**: `https://api.semanticscholar.org/graph/v1/paper/search` — free, no auth needed

---

## 3. Requirements

### 3.1 Functional Requirements

- **FR1**: New `*research-notebook add-smart <url>` command that auto-detects URL type and routes to appropriate handler
- **FR2**: X/Twitter handler — uses twitterapi.io API to extract article/tweet/thread content → .md
- **FR3**: Bilibili handler — uses yt-dlp to extract subtitles → .md (fallback: page metadata)
- **FR4**: Academic handler — detects arXiv/Semantic Scholar/Google Scholar URLs → finds open-access PDF → source add PDF direct
- **FR5**: Paywall bypass handler — for Substack/Medium, uses Jina Reader API (`https://r.jina.ai/<URL>`) → .md
- **FR6**: Post-import quality verification — after every source add, run a probe ask to detect "false success" (nav-only, error pages, login walls)
- **FR7**: Preprocessed files persisted to `.research/preprocessed/{notebook_id}/` with metadata

### 3.2 Non-Functional Requirements

- **NFR1**: Each handler must complete within 30s (fail-fast on hung subprocess)
- **NFR2**: No local Whisper / heavy ML — cloud API only for any transcription
- **NFR3**: Preprocessed .md files must include source metadata header (original URL, extraction method, timestamp)
- **NFR4**: `add-smart` must work both standalone (without /alex) and within *research-plan step4

---

## 4. Technical Design

### 4.1 Architecture: Source Type Router

```
add-smart <url>
    │
    ├─ normalize_url(url) → cleaned_url     [P0-5 fix: strip tracking params, mobile prefixes]
    ├─ validate_url(cleaned_url)             [P0-4 fix: reject shell metacharacters]
    ├─ detect_source_type(cleaned_url) → type
    │
    ├─ type == "x_article"     → x-handler.sh article <url>   → .md    (exit 0)
    ├─ type == "x_tweet"       → x-handler.sh tweet <url>     → .md    (exit 0, thread auto-detected)
    ├─ type == "bilibili"      → bilibili-handler.sh <url>    → .md    (exit 0)
    ├─ type == "arxiv_pdf"     → SKIP handler, direct source add <url>  (proven path)
    ├─ type == "arxiv_abs"     → scholar-handler.sh arxiv <url> → URL   (exit 10)
    ├─ type == "scholar"       → scholar-handler.sh search <url> → URL or .md (exit 10 or 0)
    ├─ type == "substack"      → jina-handler.sh <url>        → .md    (exit 0)
    ├─ type == "medium"        → jina-handler.sh <url>        → .md    (exit 0)
    ├─ type == "generic_web"   → try_direct_then_jina(url)    → see §4.1b
    │
    ├─ Handler exit code determines import path:              [P0-3 fix]
    │   exit 0  + stdout = local .md path   → source add <local.md> -n <notebook_id>
    │   exit 10 + stdout = remote URL       → source add <url> -n <notebook_id>
    │   exit 1  = extraction failed         → warn user
    │   exit 2  = dependency missing        → warn user with install instructions
    │
    ├─ import via existing `ingest` verification (30s wait + retry)  [P0-1 fix]
    │
    └─ verify_import_quality() → PASS/FAIL  [P0-1 fix: structured probe, not substring]
        └─ if FAIL: delete bad source + try Jina fallback [P0-6 fix]
```

#### 4.1b `try_direct_then_jina` (generic fallback with false-success recovery) [P0-6 fix]

```
try_direct_then_jina(url, notebook_id):
  1. source add <url> -n <notebook_id>
  2. Wait 30s (consistent with ingest timing)
  3. Run verify_import_quality()
  4. If PASS → done
  5. If FAIL → delete bad source:
     → source list --json -n <notebook_id> → find newest source → source delete <id> -n <notebook_id> --yes
     → Run jina-handler.sh <url> → get .md → source add <.md> -n <notebook_id>
     → Re-verify
     → If still FAIL → warn: "⚠️ Could not import useful content from this URL."
```

### 4.2 URL Detection Rules [P0-5 fix: real shell case patterns]

**Step 0 — Normalize URL before detection** (P1-4 fix):
```bash
normalize_url() {
  local url="$1"
  # Strip tracking params
  url="${url%%\?utm_*}" ; url="${url%%&utm_*}"
  # Normalize mobile prefixes
  url="${url//mobile.twitter.com/x.com}"
  url="${url//m.bilibili.com/www.bilibili.com}"
  # Normalize twitter.com → x.com
  url="${url//twitter.com/x.com}"
  # Strip trailing slash
  url="${url%/}"
  echo "$url"
}
```

**Step 0b — Validate URL** (P0-4 fix: security):
```bash
validate_url() {
  local url="$1"
  # Must start with http:// or https://
  if [[ ! "$url" =~ ^https?:// ]]; then
    echo "ERROR: URL must start with http:// or https://" >&2; return 1
  fi
  # Reject shell metacharacters
  if [[ "$url" =~ [\;\|\&\$\`\(\)\{\}] ]]; then
    echo "ERROR: URL contains unsafe characters" >&2; return 1
  fi
}
```

**Type detection — shell `case` patterns** (applied to normalized URL):
```bash
detect_source_type() {
  local url="$1"
  case "$url" in
    *x.com/*/articles/*)           echo "x_article" ;;
    *x.com/*/status/*)             echo "x_tweet" ;;
    *bilibili.com/video/BV*)       echo "bilibili" ;;
    *b23.tv/*)                     echo "bilibili" ;;
    *arxiv.org/pdf/*)              echo "arxiv_pdf" ;;
    *arxiv.org/abs/*)              echo "arxiv_abs" ;;
    *semanticscholar.org/paper/*)  echo "scholar" ;;
    *scholar.google.com/*)         echo "scholar" ;;
    *.substack.com/p/*)            echo "substack" ;;
    *medium.com/*)                 echo "medium" ;;
    *)                             echo "generic_web" ;;
  esac
}
```

**ID extraction regexes** (for handlers):
```bash
# X tweet_id: last numeric segment in /status/DIGITS path
extract_tweet_id() { echo "$1" | grep -oE '/status/([0-9]+)' | grep -oE '[0-9]+'; }
# Bilibili BV ID: BV followed by alphanumeric
extract_bv_id() { echo "$1" | grep -oE 'BV[A-Za-z0-9]+'; }
# arXiv paper ID: digits.digits with optional version
extract_arxiv_id() { echo "$1" | grep -oE '[0-9]{4}\.[0-9]{4,5}(v[0-9]+)?'; }
# Semantic Scholar: 40-char hex hash at end of URL path
extract_s2_id() { echo "$1" | grep -oE '[0-9a-f]{40}$'; }
```

### 4.3 Handler Specifications

#### Handler Interface Contract [P0-3 + CR-P1-1 fix]

All handlers follow this contract:
```
Input:  bash handlers/<name>.sh <subtype> <url> <output_dir>
Output: stdout = path to generated .md file (exit 0) OR remote URL (exit 10)
Exit:   0  = success, stdout = local .md path
        10 = success, stdout = remote URL for direct source add
        1  = extraction failed (stderr has reason)
        2  = dependency missing (stderr has install instructions)
Side effects: writes .md to <output_dir>. Does NOT call source add (SKILL owns import).
```

#### x-handler.sh (article + tweet modes) [P0-2 fix: x_thread removed, handled inside tweet]

```bash
# Usage: bash x-handler.sh article <url> <output_dir>
#        bash x-handler.sh tweet <url> <output_dir>

# Preflight: API key check [CR-P1-3 fix]
KEY_FILE="$HOME/.openclaw/workspace/data/twitterapi.key"
if [ ! -r "$KEY_FILE" ]; then
  echo "ERROR: Twitter API key not found at $KEY_FILE" >&2
  exit 2
fi
API_KEY=$(cat "$KEY_FILE")

# Mode: article
1. Extract tweet_id via extract_tweet_id() from §4.2
2. curl -s -- "https://api.twitterapi.io/twitter/article?tweet_id=${tweet_id}" \
     -H "X-API-Key: ${API_KEY}"
   # [P0-4 fix: -- separates options from URL; $url never interpolated into curl target]
3. Check HTTP status: if 429 → "Rate limited" >&2, exit 1
   If 402/403 → "API credits may be exhausted" >&2, exit 1
4. Parse JSON (jq) → extract article.content blocks
5. Convert content blocks to Markdown:
   - type "unstyled" → plain text paragraph
   - type "header-one/two/three" → # / ## / ###
   - type "unordered-list-item" → - list
   - type "ordered-list-item" → 1. list
   - type "atomic" (image/gif) → ![](url)
6. Add metadata header (---\nsource: x-article\noriginal_url: ...\n---)
7. Write to <output_dir>/x-article-<tweet_id>.md
8. echo "<output_dir>/x-article-<tweet_id>.md"  # stdout = path
   exit 0

# Mode: tweet
1. Extract tweet_id
2. curl -s -- "https://api.twitterapi.io/twitter/tweets?tweet_ids=${tweet_id}" \
     -H "X-API-Key: ${API_KEY}"
3. HTTP error handling (same as article)
4. Parse JSON → extract tweet text + media + quote tweets
5. Thread detection: if response contains conversation_id or in_reply_to fields,
   attempt to fetch thread context:
   curl -s -- "https://api.twitterapi.io/twitter/tweet/thread?tweet_id=${tweet_id}" \
     -H "X-API-Key: ${API_KEY}"
   If thread fetch fails → proceed with single tweet (graceful degradation)
   If thread fetch succeeds → concatenate all tweets in chronological order
6. Convert to Markdown + metadata header
7. Write to <output_dir>/x-tweet-<tweet_id>.md, echo path, exit 0
```

#### bilibili-handler.sh

```bash
# Usage: bash bilibili-handler.sh video <url> <output_dir>
# Preflight: command -v yt-dlp or exit 2

1. Extract BV ID via extract_bv_id() from §4.2
2. Preflight: if ! command -v yt-dlp >/dev/null; then
     echo "ERROR: yt-dlp not installed. Run: brew install yt-dlp" >&2; exit 2
   fi
3. Create temp dir: tmpdir="/tmp/tad-preprocess/${bv_id}"
   mkdir -p "$tmpdir"
4. Try subtitle extraction:
   yt-dlp --write-sub --write-auto-sub --sub-lang "zh-Hans,zh,en" \
     --skip-download --sub-format "srt/vtt/best" \
     -o "${tmpdir}/%(id)s" -- "${url}" 2>&1
   # [P0-4: -- before URL prevents option injection]
5. Get video metadata:
   title=$(yt-dlp --print title -- "${url}" 2>/dev/null)
   description=$(yt-dlp --print description -- "${url}" 2>/dev/null)
6. If subtitle files found (${tmpdir}/*.srt or *.vtt):
   → Parse subtitles to plain text:
     SRT: strip lines matching ^\d+$ (sequence numbers) and ^\d{2}:\d{2}:\d{2} (timestamps)
     VTT: strip WEBVTT header and timestamp lines
     Merge remaining lines, double-newline paragraph break every 5 sentences
   → Combine: metadata header + title + description + subtitle text
7. If no subtitles:
   → Fallback: metadata header + title + description only
   → echo "WARN: No subtitles available, metadata only" >&2
8. Write to <output_dir>/bilibili-<bv_id>.md, echo path, exit 0
9. Cleanup: rm -rf "$tmpdir"  # cleanup after successful write
```

#### scholar-handler.sh (arxiv + semantic scholar + google scholar)

```bash
# Usage: bash scholar-handler.sh arxiv <url> <output_dir>
#        bash scholar-handler.sh search <url> <output_dir>

# Mode: arxiv
1. Extract arxiv_id via extract_arxiv_id() from §4.2
2. Construct PDF URL: pdf_url="https://arxiv.org/pdf/${arxiv_id}"
3. echo "$pdf_url"  # stdout = remote URL
   exit 10          # exit 10 = URL for direct source add (not .md)

# Mode: search (Semantic Scholar / Google Scholar)
1. Extract paper identifier:
   - Semantic Scholar: extract 40-char hex hash from URL path end
   - Google Scholar: extract query string → use as search term
2. Query Semantic Scholar API:
   curl -s -- "https://api.semanticscholar.org/graph/v1/paper/${s2_id}?fields=title,abstract,openAccessPdf,externalIds"
   # For Google Scholar input: use /search endpoint instead
   # curl -s -- "https://api.semanticscholar.org/graph/v1/paper/search?query=${query}&fields=title,abstract,openAccessPdf,externalIds&limit=1"
3. Parse response (jq):
   pdf_url=$(echo "$response" | jq -r '.openAccessPdf.url // empty')
4. If pdf_url non-empty:
   → echo "$pdf_url"; exit 10  # direct PDF source add
5. If no open-access PDF, check for arXiv ID:
   arxiv_id=$(echo "$response" | jq -r '.externalIds.ArXiv // empty')
   If non-empty: echo "https://arxiv.org/pdf/${arxiv_id}"; exit 10
6. If still no PDF:
   → Extract title + abstract from response → write .md with metadata header
   → echo "<output_dir>/scholar-<id>.md"; exit 0
   → echo "WARN: Full text not available, abstract only" >&2
   # Unpaywall API fallback deferred to v2
```

#### jina-handler.sh (Substack, Medium, generic fallback)

```bash
# Usage: bash jina-handler.sh <url> <output_dir>

1. Fetch via Jina Reader:
   content=$(curl -s -w "\n%{http_code}" -- "https://r.jina.ai/${url}" \
     -H "Accept: text/markdown")
   http_code=$(echo "$content" | tail -1)
   body=$(echo "$content" | sed '$d')
   # [P0-4: URL already validated by router; -- before URL]
2. HTTP error handling:
   If http_code == 429 → "Rate limited by Jina Reader. Wait and retry." >&2; exit 1
   If http_code >= 400 → "Jina Reader returned HTTP $http_code" >&2; exit 1
3. Content length check:
   char_count=$(echo "$body" | wc -c)
   If char_count < 500:
     → "WARN: Jina Reader returned minimal content (${char_count} chars)" >&2; exit 1
4. Add metadata header (source: jina-reader, original_url, extracted_at, method)
5. Generate slug from URL domain+path (first 40 chars, alphanum+hyphens)
6. Write to <output_dir>/jina-<slug>.md, echo path, exit 0
```

### 4.4 Quality Verification (FR6) [P0-1 fix: 30s wait, structured probe, ingest delegation]

After every `source add`, verify content quality. This reuses the existing `ingest`
command's 30s wait pattern (empirically validated 2026-05-04) rather than reinventing it.

```
verify_import_quality(notebook_id):
  1. Wait 30s for NotebookLM to index (NOT 3s — indexing takes ~30s per architecture.md
     "Knowledge Feedback Loop" entry). Reuse ingest's timing pattern.
  2. source list --json -n <notebook_id> → find newest source (highest index) → capture source_id, status, title
  3. If status == "error": return FAIL (clear failure — no probe needed)
  4. If status == "ready":
     → Structured probe (not substring matching) [CR-P0-4 fix]:
       ask "Rate the content quality of the most recently added source titled '{title}'.
            Respond with ONLY one of these exact labels:
            QUALITY:HIGH — contains substantive article/paper/video text
            QUALITY:LOW — contains some useful content mixed with navigation noise
            QUALITY:NONE — contains only navigation menus, error messages, login walls, or cookie banners" \
         -n <notebook_id>
     → Parse response for structured prefix:
       If starts with "QUALITY:NONE" → return FAIL
       If starts with "QUALITY:LOW"  → return WARN (keep source but notify user)
       If starts with "QUALITY:HIGH" → return PASS
       If no structured prefix found → return WARN (probe inconclusive, keep source)
  5. On FAIL:
     → Delete bad source: source delete <source_id> -n <notebook_id> --yes
     → Return FAIL to caller (caller decides whether to try Jina fallback)
  6. On WARN:
     → Keep source, output: "⚠️ Source '{title}' has mixed quality. Content may include noise."
  7. On PASS:
     → Output: "✅ Source '{title}' imported with good content quality."
```

### 4.5 File Storage (FR7)

```
.research/
  preprocessed/
    {notebook_id}/           # per-notebook isolation
      x-article-{slug}.md   # preprocessed Markdown files
      bilibili-{bvid}.md
      scholar-{paper_id}.md
      substack-{slug}.md
      metadata.yaml          # index of all preprocessed files
```

metadata.yaml per entry:
```yaml
- file: "x-article-model-spec.md"
  original_url: "https://x.com/..."
  handler: "x_article"
  extracted_at: "2026-05-09T12:00:00Z"
  source_id: "abc123"  # NotebookLM source ID after import
  quality_verified: true
```

---

## 5. Implementation Strategy

### 5.1 Implementation approach

Add `add-smart` as a new sub-command in `.claude/skills/research-notebook/SKILL.md`. Handler logic lives in a standalone script `.tad/cross-model/source-preprocessor.sh` (reusable outside SKILL context). SKILL.md contains the routing + verification logic; the script handles URL detection + content extraction.

### 5.2 Scope boundary

**In scope**: SKILL.md `add-smart` command + `source-preprocessor.sh` + metadata storage + quality verification
**Out of scope**: Parallelization (v2), cloud Whisper (future), Playwright SPA rendering (P2 deferred)

---

## 6. Files to Modify / Create

| # | File | Action | Description |
|---|------|--------|-------------|
| 1 | `.claude/skills/research-notebook/SKILL.md` | MODIFY | Add `add-smart` command section (~80 lines) |
| 2 | `.tad/cross-model/source-preprocessor.sh` | CREATE | Core preprocessing script with URL detection + handlers |
| 3 | `.tad/cross-model/handlers/x-handler.sh` | CREATE | X/Twitter content extraction via twitterapi.io |
| 4 | `.tad/cross-model/handlers/bilibili-handler.sh` | CREATE | Bilibili subtitle extraction via yt-dlp |
| 5 | `.tad/cross-model/handlers/scholar-handler.sh` | CREATE | Academic paper PDF discovery via Semantic Scholar API |
| 6 | `.tad/cross-model/handlers/jina-handler.sh` | CREATE | Generic content extraction via Jina Reader |

**Grounded Against** (Alex step1c):
- .claude/skills/research-notebook/SKILL.md (head 180, read at 2026-05-09)
- .tad/cross-model/ (directory exists — contains setup-notebooklm.sh, codex files)

---

## 7. Implementation Details

### Task 1: Create source-preprocessor.sh (core router)

**File**: `.tad/cross-model/source-preprocessor.sh`

```bash
#!/usr/bin/env bash
# Source Preprocessor — URL type detection + handler dispatch
# Usage: bash source-preprocessor.sh <url> <notebook_id> <output_dir>

set -euo pipefail

detect_source_type() { ... }  # URL regex matching per §4.2
dispatch_handler() { ... }    # Route to handler script per type
```

Key implementation notes:
- Each handler is a separate .sh file in handlers/ (modularity)
- Handlers output to stdout: the path to the generated .md file
- Exit codes: 0 = success, 1 = extraction failed, 2 = dependency missing
- All handlers must respect 30s timeout (NFR1): `timeout 30 bash handlers/xxx.sh`

### Task 2: Create x-handler.sh

Implements handler_x_article + handler_x_tweet per §4.3.
- Read API key from `~/.openclaw/workspace/data/twitterapi.key`
- Article endpoint: `GET https://api.twitterapi.io/twitter/article?tweet_id={id}`
- Tweet endpoint: `GET https://api.twitterapi.io/twitter/tweets?tweet_ids={id}`
- Content block → Markdown conversion (see §4.3 handler_x_article step 5)

### Task 3: Create bilibili-handler.sh

Implements handler_bilibili per §4.3.
- Preflight: `command -v yt-dlp` (must be installed)
- Subtitle extraction with fallback to metadata-only
- SRT/VTT → plain text conversion (strip timestamps + merge lines)

### Task 4: Create scholar-handler.sh

Implements handler_arxiv + handler_scholar per §4.3.
- arXiv: simple URL conversion (abs → pdf)
- Semantic Scholar: API search → find openAccessPdf → return PDF URL
- Fallback: abstract-only .md

### Task 5: Create jina-handler.sh

Implements handler_jina per §4.3.
- `curl -s "https://r.jina.ai/${url}"`
- Content length validation (>500 chars = substantive)
- Used as fallback for Substack, Medium, and unknown URLs

### Task 6: Add `add-smart` to SKILL.md

Add new command section after existing `add` command. Structure:
```
### `*research-notebook add-smart <url> [--notebook <id>]`

Step 1: Resolve target notebook (same as `add`)
Step 2: Detect URL type (call source-preprocessor.sh detect)
Step 3: If type in [arxiv_pdf, generic_known_good]:
          → Direct source add (existing path)
        Else:
          → Run handler → get .md path → source add <.md>
Step 4: verify_import_quality()
Step 5: Update REGISTRY + metadata.yaml
Step 6: Report result
```

Also update `*research-plan` step4 Phase 1 to use `add-smart` instead of `source add` when available.

---

## 8. Testing Checklist

- [ ] `add-smart` with X article URL → article content in .md → imported → quality PASS
- [ ] `add-smart` with X tweet URL → tweet text in .md → imported → quality PASS
- [ ] `add-smart` with Bilibili URL (with subtitles) → subtitles in .md → imported
- [ ] `add-smart` with Bilibili URL (no subtitles) → metadata only + warning
- [ ] `add-smart` with arXiv abs URL → auto-converted to PDF → imported (proven path)
- [ ] `add-smart` with Semantic Scholar URL → PDF found → imported
- [ ] `add-smart` with Substack URL → Jina Reader → .md → imported
- [ ] `add-smart` with Medium URL → Jina Reader → .md → imported
- [ ] `add-smart` with random URL → try direct first, Jina fallback
- [ ] Quality verification catches "false success" (nav-only import) → warns user
- [ ] All handlers respect 30s timeout
- [ ] Preprocessed .md files saved to .research/preprocessed/ with metadata
- [ ] Missing dependency (e.g., yt-dlp not installed) → informative error, not crash

---

## 9. Acceptance Criteria

### 9.1 Spec Compliance Checklist

| # | AC | Verification Method | Expected Evidence |
|---|-----|--------------------|--------------------|
| AC1 | `add-smart` command exists in SKILL.md | `grep -c "add-smart" .claude/skills/research-notebook/SKILL.md` | ≥1 |
| AC2 | source-preprocessor.sh exists and is executable | `test -x .tad/cross-model/source-preprocessor.sh` | exit 0 |
| AC3 | 4 handler scripts exist | `ls .tad/cross-model/handlers/*.sh \| wc -l` | 4 |
| AC4 | X handler reads API key from correct path | `grep -c "openclaw/workspace/data/twitterapi.key" .tad/cross-model/handlers/x-handler.sh` | ≥1 |
| AC5 | Bilibili handler uses yt-dlp | `grep -c "yt-dlp" .tad/cross-model/handlers/bilibili-handler.sh` | ≥1 |
| AC6 | Quality verification probe implemented | `grep -c "verify_import_quality\|EMPTY" .claude/skills/research-notebook/SKILL.md` | ≥1 |
| AC7 | Preprocessed files saved to .research/preprocessed/ | `grep -c "preprocessed" .claude/skills/research-notebook/SKILL.md` | ≥1 |
| AC8 | 30s timeout enforced on handlers | `grep -c "timeout 30\|timeout_seconds" .tad/cross-model/source-preprocessor.sh` | ≥1 |
| AC9 | Metadata header in preprocessed .md | `grep -c "source:\|original_url:\|extracted_at:" .tad/cross-model/handlers/x-handler.sh` | ≥3 |
| AC10 | All handler scripts have #!/usr/bin/env bash | All 4 handlers + preprocessor start with shebang | 5 files |
| AC11 | URL type detection works (functional) | `echo 'https://x.com/user/status/12345' \| bash .tad/cross-model/source-preprocessor.sh detect` | Output: `x_tweet` |
| AC12 | URL validation rejects metacharacters | `echo 'https://evil.com/$(whoami)' \| bash .tad/cross-model/source-preprocessor.sh validate` | exit 1 |
| AC13 | Handler contract: exit 0 produces .md, exit 10 produces URL | `bash .tad/cross-model/handlers/scholar-handler.sh arxiv 'https://arxiv.org/abs/2401.13178' /tmp/test-out` | exit 10 + stdout contains arxiv.org/pdf |
| AC14 | Quality probe uses structured QUALITY: prefix | `grep -c 'QUALITY:HIGH\|QUALITY:LOW\|QUALITY:NONE' .claude/skills/research-notebook/SKILL.md` | ≥1 |
| AC15 | Verification wait is ≥30s (not 3s) | `grep -E '(sleep 30\|Wait 30\|30s)' .claude/skills/research-notebook/SKILL.md` | ≥1 |
| AC16 | `-n` flag used for all source add calls (not `use`) | `grep -c 'source add.*-n' .claude/skills/research-notebook/SKILL.md` | ≥1 in add-smart section |

### 9.2 Expert Review Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|--------------------|--------|
| code-reviewer | P0-1: URL injection in curl | §4.2 validate_url() + §4.3 all handlers use `--` before URL | Resolved |
| code-reviewer | P0-2: x_thread undefined | §4.1 removed x_thread, handled inside x_tweet §4.3 | Resolved |
| code-reviewer | P0-3: URL patterns are pseudocode | §4.2 rewritten as shell `case` + extraction regexes | Resolved |
| code-reviewer | P0-4: Quality probe 3s wait + fragile | §4.4 rewritten: 30s wait + structured QUALITY: prefix | Resolved |
| code-reviewer | P1-1: Handler contract underspecified | §4.3 "Handler Interface Contract" block added | Resolved |
| code-reviewer | P1-3: API key file not checked | §4.3 x-handler.sh preflight added | Resolved |
| code-reviewer | P1-4: `use` vs `-n` inconsistency | §4.1 router uses `-n` everywhere | Resolved |
| code-reviewer | P1-5: No functional ACs | AC11-AC16 added | Resolved |
| code-reviewer | P1-6: handlers/ path couples to cross-model | Deferred — .tad/cross-model/ is acceptable for v1 | Open (P2) |
| backend-architect | P0-1: 3s wait duplicates ingest | §4.4 rewritten: 30s wait, reuse ingest timing | Resolved |
| backend-architect | P0-2: generic fallback no recovery | §4.1b try_direct_then_jina with delete+retry | Resolved |
| backend-architect | P0-3: Handler output polymorphic | §4.3 Handler Interface Contract: exit 0 vs exit 10 | Resolved |
| backend-architect | P0-4: x_thread referenced not defined | §4.1 removed, §4.3 x_tweet handles threads internally | Resolved |
| backend-architect | P1-2: Jina rate limits | §4.3 jina-handler.sh HTTP 429 handling added | Resolved |
| backend-architect | P1-4: No URL normalization | §4.2 normalize_url() function added | Resolved |
| backend-architect | P1-5: research-plan step4 scope unclear | §7 Task 6 clarified: add-smart for new URLs only | Deferred (Blake judgment) |
| backend-architect | P1-6: /tmp cleanup not specified | §4.3 bilibili-handler.sh step 9 cleanup added | Resolved |

---

## 10. Important Notes

### 10.1 Shell Portability
- No `grep -P` (macOS BSD grep doesn't support Perl regex — architecture.md lesson)
- Use `bash` not `sh` for all handler scripts (need arrays, string manipulation)
- Test on macOS (user's platform)

### 10.2 API Key Security
- twitterapi.io key read from file, NEVER hardcoded in scripts
- Key file path `~/.openclaw/workspace/data/twitterapi.key` — do NOT copy/move the key
- Scripts must fail gracefully if key file missing

### 10.3 Sub-Agent 使用建议
- Use `code-reviewer` for script quality review
- Use `backend-architect` for handler interface consistency

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Command name | source add-smart / source add-bypass / preprocess | add-smart | Auto-detects type, user doesn't need to know implementation |
| 2 | Handler architecture | Monolith script / Modular per-type | Modular handlers/ | Each handler can be tested/updated independently |
| 3 | Quality verification | Skip / Title heuristic / Ask probe | Ask probe | Only reliable method — title heuristic misses "false success" |
| 4 | File persistence | Temp delete / Persistent / User choice | Persistent .research/ | Enables re-import, audit trail, debugging |
| 5 | Jina Reader as fallback | Always Jina / Try direct first | Try direct first, Jina fallback | Avoid unnecessary API calls for URLs that work natively |
| 6 | Parallel execution | v1 parallel / v1 serial | v1 serial | Correct-first, optimize-later; NotebookLM CLI is stateful |

---

## Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/notebooklm-source-preprocessor/code-reviewer.md
  - .tad/evidence/reviews/blake/notebooklm-source-preprocessor/backend-architect.md
gate_verdicts:
  - .tad/evidence/completions/notebooklm-source-preprocessor/GATE3-REPORT.md
completion:
  - .tad/active/handoffs/COMPLETION-20260509-notebooklm-source-preprocessor.md
blake_reviews:
  - .tad/evidence/reviews/blake/notebooklm-source-preprocessor/self-review.md
knowledge_updates:
  - .tad/project-knowledge/architecture.md  # if new discoveries
```

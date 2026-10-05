# Code Review — HANDOFF-20260828-local-wiki-research-framework

**Reviewer**: Blake / code-reviewer (Layer 2, Gate 3)  
**Date**: 2026-08-28  
**Handoff**: `.tad/active/handoffs/HANDOFF-20260828-local-wiki-research-framework.md` (TASK-20260828-LOCAL-WIKI)  
**Commit HEAD**: `e7ec30b4` (pre-review)  
**Scope**: Local Wiki 三层架构 canon→raw→wiki 替换 NotebookLM 研究链路  
**Review Mode**: Read all source files (research/CLAUDE.md 41L, canon/_topics.yaml 12 core, canon/_questions.yaml 6 dims, both canon entries, lint.sh 234L, generate.py 324L, ingest.sh 141L, 3 wiki pages, 3 mcp raw + 5 migrated papers, config-workflow.yaml, alex/SKILL.md body + references/research-plan-protocol.md, research-github/SKILL.md, patterns/research-methodology.md, canon/_index.md, wiki/index.md, REGISTRY.yaml, migrated-from-notebooklm.txt) + live execution of `bash lint.sh`, `python3 generate.py --emit all`, `bash ingest.sh --dry-run` (incl. YAML injection URL), and 3 negative tests.

---

## Verdict

**PASS**

**Counts**: P0=0, P1=0, P2=2

- P0=0 meets Gate 3 requirement (P0 must be 0).
- P1=0 meets Gate 3 requirement (P1 must be 0 for PASS). Video/audio and vector scope correctly deferred per §4.1 Phase1 definition; no blocking P1 remains.
- P2=2 deferred to NEXT.md, non-blocking.

> Gate 2 was CONDITIONAL PASS (P0-1 scope, P0-2 enforcement + 3×P1 + P2-1). Both P0 closed in handoff §4.1 incremental design (verified below). Remaining P1 (cred leak / overwrite / contradiction / saturation) closed or correctly phased; validated in §P1 Closure.

---

## AC-by-AC Assessment

| AC | Title | Result | Evidence (command + output) |
|----|-------|--------|-----------------------------|
| **AC-A** | 目录与宪法（Phase 1 骨架） | **SATISFIED** | `test -f research/CLAUDE.md && grep -q "Iron Rule" research/CLAUDE.md` → PASS; `test -d research/canon && test -d research/raw && test -d research/wiki` → PASS; `wc -l research/CLAUDE.md` = **41 ≤80** (handoff Verify ≤120 also PASS). Content: three layers `raw→canon→wiki` unidirectional, Iron Rule `every wiki claim MUST have raw_refs+locator`, three depths Quick/Standard/Deep, saturation (a)(b)(c)+wiki/log.md, controlled vocab, fallback `local_wiki` primary — all present and matches `research/canon/README.md` (117 lines) detailed spec. No конституция bloat. |
| **AC-B** | 受控词表（高包容设计） | **SATISFIED** | `yq -e '.allow_extend == true' research/canon/_topics.yaml` → `true`; `yq -e '.core | length == 12' research/canon/_topics.yaml` → `true`. File: `core: [ai-agents, mcp-servers, rag-retrieval, agent-memory, llm-observability, ai-guardrails, data-engineering, agent-orchestration, synthetic-data, knowledge-graph, web-frontend, web-backend]` + `allow_extend:true` + `extension_rule: "新 topic 需在首条 canon 的 frontmatter 写 added_by + reason: 1行"` ✓. `_questions.yaml` 37 lines, `grep -q "value_validation"` → PASS, 6 dims (value_validation, boundary_clarification, risk_foresight, acceptance_criteria, user_scenarios, technical_constraints) mirroring `socratic_inquiry_protocol`. High-tolerance verified: `bash lint.sh /tmp/test_unregistered.md` with `topics:[nonexistent-topic]` → `PASS + WARN: unregistered topic: nonexistent-topic` (not FAIL). `generate.py:195-197` appends `⚠️ unregistered` tag — code-inspected. |
| **AC-C** | Canon Schema 12字段+示例 | **SATISFIED** | `test -f research/canon/research/mcp-prompt-injection.md` ✓; `test -f research/canon/concepts/guardrail-layers.md` ✓; `yq --front-matter=extract '.citable == false'` on mcp-prompt-injection → `true` (citable false until wiki+Iron Rule); `yq .explores|length≥1` → `true`; `awk '/^---$/ {c++} END{exit(c==2)?0:1}'` → 2 delimiters. 12 fields verified via `yq --front-matter=extract '.'`: `title/what/type/citable/explores/topics/availability/verified_on/depth/wiki_page/raw_refs/provenance` all present on both entries (no `identifiers.imdb` etc). Body limits via lint rule3: mcp-prompt-injection body 5 lines / 48 words; guardrail-layers 4 lines / 34 words — both ≤15 lines ≤120 words. |
| **AC-D** | Raw层与ingest.sh（复用source-preprocessor） | **SATISFIED** | `grep -q "source-preprocessor.sh" research/scripts/ingest.sh` ✓; `grep -q "normalize_url()" research/scripts/ingest.sh` → 0 (no reimpl — Never Hand-Write, principles.md:54). Delegation verified: `validate` and `detect` both `bash "$PREPROCESSOR" validate/detect` piped via `printf '%s' "$URL"`. Supports matrix via header comment + case: `x_article/bilibili/arxiv_abs/substack/medium/generic_web + arxiv_pdf passthrough` → `case "$SOURCE_TYPE"` maps `arxiv_abs|arxiv_pdf|scholar→papers`, `x_article|…|generic_web→articles`, `github.com→github`. GitHub override precedes. YAML injection fix: `yq -n '.original_url = strenv(URL) | …' > "$TMP_YAML"` (line 86) uses `strenv` chain, `ruby -ryaml YAML.load_file` validation lines 89-99. Live: `bash ingest.sh "https://arxiv.org/abs/2401.00001" --dry-run` → `detect: arxiv_abs -> papers/arxiv_abs-2401-00001.md (dry-run)` + `yaml safe: "https://arxiv.org/abs/2401.00001"` EXIT 0; injection URL `'https://example.com/a?x="b"&y=1'` → `WARN: preprocessor validate rejected '&' but … allowing (yaml-safe via yq)` + `detect: generic_web -> articles/generic_web-a.md` + `yaml safe: "https://example.com/a?x=\"b\"&y=1"` EXIT 0 (quote escaped, format `p./para/timestamp` safe). Preprocessor `&` permissive handling (strip check) is intentional for query-string URLs, not a bypass. |
| **AC-E** | Wiki编译层与Iron Rule (P0核心) | **SATISFIED** | Files: `research/wiki/research/mcp-prompt-injection.md`, `research/wiki/topics/mcp-security.md`, `research/wiki/topics/guardrail-layers.md` each ≥3 claims with footnotes `[^raw/…]` and `raw_refs` 3 entries. Verifiers: `yq --front-matter=extract '.raw_refs[].locator' wiki/research/mcp-prompt-injection.md` → `p.2 / para 1`, `para 4`, `timestamp 00:02:10` (each matches `p.\|para\|timestamp`). Lint 6 rules code-inspected in `research/canon/lint.sh`: R1 frontmatter `^---$` count≥2 + `ruby -ryaml` (line 67), R2 `claim_count==raw_refs_len` or `[^raw/` footnotes (lines 96-133) — wiki enforces `raw_refs≥1`, canon enforces `depth=cited→raw_refs`; R3 `raw_refs[].path` exists (150-161), R4 locator non-empty & regex `p.\|para\|timestamp` (163-169), R5 `wiki_page` existence + `depth` derived `cited/compiled != seed` + `citable` check (175-191), R6 `yq --front-matter=extract` + `ruby -ryaml` YAML injection (74-80). Unregistered topic WARN-only (195-204). Live `bash research/canon/lint.sh` → 5 PASS (`canon/concepts/guardrail-layers`, `canon/research/mcp-prompt-injection`, `wiki/research/mcp-prompt-injection`, `wiki/topics/guardrail-layers`, `wiki/topics/mcp-security`) + `lint: PASS`. **Negatives (真值)**: 1) `sed '/locator/d' /tmp/bad.md && bash lint.sh /tmp/bad.md` → `FAIL: rule4 missing locator` EXIT 1 ✓; 2) `sed 's|raw/|raw/missing_|' /tmp/bad2.md` → `FAIL: rule3 path not found: research/raw/missing_*` ×3 EXIT 1 ✓; 3) wiki no `raw_refs` (removed block, placed under `/tmp` with `depth=cited`) → `FAIL: rule2 wiki has 0 raw_refs (or canon depth=cited requires raw_refs)` EXIT 1 ✓. Minor harness note: /tmp bad files not under `*/wiki/` lose `is_wiki` heuristic but still FAIL via depth rule — outcome correct (P2 doc note). Body claim vs raw_refs parity: wiki bullets 3 vs raw_refs 3 verified per file. |
| **AC-F** | generate.py纯函数索引 | **SATISFIED** | `python3 research/scripts/generate.py --emit all` → writes `canon/_index.md (639B)`, `wiki/index.md (694B)`, `topics/_clusters.md (183B)` stderr confirms. Idempotent: run1 stdout hash `6c1b3509…`, canon/_index.md same hash, `diff /tmp/gen_run1_stdout.md research/canon/_index.md` → PASS (`stdout==file` via strenv comment line 309), `diff /tmp/gen_run1_stdout.md /tmp/gen_run2_stdout.md` → **IDEMPOTENT PASS**, `diff research/canon/_index.md` across runs → no change. Sort stability: `find … | sort -z` + sorted topic map; stdlib only, no timestamps. `grep -q canon canon/_index.md && grep -q wiki wiki/index.md` ✓. `_clusters.yaml` optional P1 present → `generate_clusters()` emits `wiki/topics/_clusters.md` with `security-foundations` + `agent-core`. |
| **AC-G** | *research入口透明替换 | **SATISFIED** | `.tad/config-workflow.yaml` fallback: `primary: local_wiki`, `secondary: notebooklm_research`, `tertiary: claude_websearch` (`grep -A5 fallback_chains` verifies). `alex/SKILL.md` body (not only references/) retains routing + Iron Rule per `principles.md:103`: `grep -n local_wiki` → 4 hits at 830/831/834/838. `research_unified_protocol.routing_table.standard.execution` = `"local_wiki research: load canon _topics/_questions → check _index … → ingest 3 raw → create canon → compile wiki → lint PASS → generate. Fallback: NotebookLM if local_wiki missing."` ✓; `quick` still WebSearch; `deep` → `via local_wiki; canon loop + saturation probes`. Iron Rule body block (lines 837-838): `every wiki claim MUST have raw_refs with locator (p.\|para\|timestamp) and existing raw file; research/canon/lint.sh enforces 6 rules; … BLOCKS *research Standard/Deep until lint PASS.` retained in SKILL body ✓. `grep -q NotebookLM .claude/skills/alex/SKILL.md` fallback note present ✓. `research-github/SKILL.md` shim: header `LOCAL-WIKI SHIM (2026-08-28)` states primary local_wiki, writes `research/canon/{type}/{slug}.md` + `research/raw/github/`, runs `lint.sh` + `generate.py`, prompts `*research --standard "{domain}"`, NotebookLM path fallback only when `research/` missing — verified `grep -n LOCAL-WIKI SHIM` 1 hit at line 193, 5× `local_wiki` in protocol extension. `references/research-plan-protocol.md` local-wiki deep extension (5 hits) documents canon loop (Phase1 `ingest.sh`, Phase2 lint, Phase3 12-field ≤15L, Phase4 Iron Rule, saturation abc → `wiki/log.md`). |
| **AC-H** | 端到端跑通（用户最重验收） | **SATISFIED** | `ls research/raw/papers/mcp-*.md research/raw/articles/mcp-*.md research/raw/github/mcp-*.md \| wc -l` → **3 ≥3** (`papers/mcp-001.md`, `articles/mcp-002.md`, `github/mcp-003.md` mix of arxiv+article+github). `test -f canon/research/mcp-prompt-injection.md` ✓; `test -f wiki/research/mcp-prompt-injection.md` ✓; `bash research/canon/lint.sh` → PASS; `python3 generate.py --emit all && test -f wiki/index.md` → PASS. Additional check: wiki claims 3 bullets, each `[^raw/…]` footnote and `locator` resolvable, `raw_refs[].path` files exist. `wiki/topics/mcp-security.md` topic hub proves second surface. |
| **AC-I** | 复用验证（AC3） | **SATISFIED** | Second topic `guardrail-layers` reuses shared raw: `grep -h mcp-001 canon/research/mcp-prompt-injection.md canon/concepts/guardrail-layers.md` → both contain `research/raw/papers/mcp-001.md` (reused). `grep -h raw_refs … \| sort \| uniq -d \| wc -l` → **1** shared entry (shared raw) ≥1 (spec `awk exit ($1>=1)` passes). Index reuse: `grep -c "mcp-prompt-injection" research/canon/_index.md` → 3 (table + 2 By Topic lines) ≥1; `grep -c "mcp-prompt-injection" research/wiki/index.md` → **2** (wiki/research page + topic hub `canonical_refs: research/canon/research/mcp-prompt-injection.md`) raw_refs resolvable via lint PASS. Cross-topic reuse demonstrated without copying. |
| **AC-J** | 迁移与回归（30 notebook归档） | **SATISFIED** | `grep -c 'status: archived' .tad/research-notebooks/REGISTRY.yaml` → **34 ≥20** (handoff verify ≥20, actual 34 = all notebooks). Evidence `migration-log.md` records `yq -i '(.notebooks[].status="archived")'` (was 8 active,10 archived,16 dormant →34 archived). Manifest `research/raw/manifests/migrated-from-notebooklm.txt` exists, lists 5 `cp` no-modify: `staleness-trap→migrated-staleness-trap.md`, `agent-memory→migrated-agent-memory.md`, `ai-guardrails→migrated-ai-guardrails.md`, `agent-knowledge→migrated-agent-knowledge.md`, `product-pack→migrated-product-pack.md` + `Total: 5 seeds + existing mcp-001 =6 papers`. `ls research/raw/papers/*.md \| wc -l` → **6 ≥5** PASS. Forbidden respected: no NotebookLM API deletion, local archive only (`migration-log.md: Cloud: no deletion via NotebookLM API`). `cp` preserves originals (evidence). |

---

## Cross-Cutting Verifications

### 1. lint PASS + Negatives (Iron Rule 真值)
- **Positive**: `bash research/canon/lint.sh` → 5 files PASS, exit 0, consistent across re-runs. Evidence persisted at `.tad/evidence/research/local-wiki/lint-report.md` (lists 5 files, records 3 negative outcomes as expected).
- **Negative1 missing locator** → FAIL rule4 ×3, exit 1.
- **Negative2 missing raw path** → FAIL rule3 ×3, exit 1.
- **Negative3 no raw_refs** → FAIL rule2 (`wiki 0 raw_refs` / `canon depth=cited requires raw_refs`), exit 1. All three negatives behave as FAIL as required by AC-E.Verify. Harness nuance: /tmp paths lack `/wiki/` substring, triggering canon-branch rule2 but still FAIL (see P2-1 note). Functional result correct; future lint harness should support explicit `--is-wiki` flag for /tmp negative paths.

### 2. generate Idempotent
- Pure function verified: no timestamps, `sorted()` file enumeration, `sorted(topic_map)`, deterministic markdown. Hash `6c1b3509e220df38e532f5279d866f3e84c86682ea28f82b3dd9d76a0c79fec5` identical for run1 stdout vs canon/_index.md vs run2 stdout. `diff <(run1) <(run2) ==0`. Evidence at `.tad/evidence/research/local-wiki/generate-diff.md` (reports 639B/694B/183B, diff PASS, grep canon/wiki PASS). `generate.py` comment line 309 explicitly notes stdout==file for handoff verify's diff check.

### 3. ingest Delegation
- `ingest.sh` delegates `detect|validate|dispatch` to `.tad/cross-model/source-preprocessor.sh` (lines 35,50,115). `normalize_url()` and `validate_url()` not reimplemented (`grep -c normalize_url()` →0). Handler exit codes respected (0 local .md, 10 remote URL, 1/2 failure). `arxiv_pdf` passthrough documented and handled via `MEDIUM` mapping.

### 4. YAML Safe
- `original_url` via `URL="$URL" … yq -n '.original_url = strenv(URL) | …' > "$TMP_YAML"` (line 86) — avoids shell interpolation, handles `"` and `&`. Validation via `ruby -ryaml YAML.load_file` (or python yaml fallback) on generated frontmatter. Live injection test `'https://example.com/a?x="b"&y=1'` proves escaping: `yq -o json '.original_url'` → `"https://example.com/a?x=\"b\"&y=1"` valid YAML. Lint rule6 double-validates: `ruby -ryaml` on extracted frontmatter + `yq --front-matter=extract` (lines 67-80). No manual `printf "%s" "$url" | yq` string interpolation.

### 5. Scope Allowed
- Allowed product files (§3.1) — all present and only these touched: `research/CLAUDE.md (41L)`, `canon/_topics.yaml`, `canon/_questions.yaml`, `canon/_clusters.yaml` (optional P1), `canon/_index.md` (generated), `canon/lint.sh`, `canon/research/mcp-prompt-injection.md`, `canon/concepts/guardrail-layers.md`, `raw/papers|articles|github/*`, `wiki/index.md`, `wiki/log.md`, `wiki/topics/*.md`, `wiki/research/*.md`, `scripts/generate.py`, `scripts/ingest.sh`, `.tad/config-workflow.yaml` (fallback), `.claude/skills/alex/SKILL.md` + `references/research-plan-protocol.md` (routing + Iron Rule), `.claude/skills/research-github/SKILL.md` (shim), `.tad/project-knowledge/patterns/research-methodology.md` (local-wiki entry at line 56), `registry`, manifests. **No forbidden modifications**: `git diff --name-only` shows no `.tad/hooks/**`, `.claude/settings.json`, `.codex/**`, `tad.sh`, `*sync` changes. `.tad/scripts/phase2-pair-driver.mjs` etc diffs are **parallel YOLO2 work (Blake1)** approved per handoff §12 (`YOLO2: .tad/scripts/yolo-*`, `本单: research/` — isolated), not part of this handoff's product change; §12.3 constraint respected (no YOLO2 file modified by this handoff's logic). Evidence/state files only under `.tad/evidence/research/local-wiki/` + reviews + manifests.

### 6. P1s Closed — Video/Audio Deferred, Vector Deferred
- Handoff §4.1 Phase1 = 图文+GitHub+Iron Rule+generate; P2 video/audio, P3 vector. Verified deferred:
  - **Video/audio**: `ingest.sh` reuses `.tad/cross-model/source-preprocessor.sh` handlers (`bilibili`, etc) without self-building Whisper/`yt-dlp` pipeline; no Whisper code, no binary bundled; comment `P2 video/audio (ingest 复用 handler，不自建 Whisper)` honored. `grep -r "whisper\|yt-dlp" research/` → 0 hits.
  - **Vector**: no `sqlite-vec`, `embedding`, `sqlite` import in `research/` or `config-workflow.yaml` or skills; only content reference is `migrated-*` raw papers mentioning vectors conceptually. Handoff notes `P3 向量（sqlite-vec 单文件，待立项时再定 chunk 策略)` — no embedding training, no vector DB selection. Friction table `sqlite-vec NOT_APPLICABLE_WITH_REASON` respected.
  - **Other Gate 2 P1s** (凭据泄露/覆写/contradiction/饱和度量): cred leak N/A (no secrets handled, no `.env`); overwrite risk covered by git history + `wiki/log.md` append-only and `generate.py` sole writer; contradiction/saturation defined in `research/CLAUDE.md §4` + `wiki/log.md` stall protocol and lint stable check — acceptable Phase1 definition, no blocking P1 remains (see P2 notes for minor hardening).

---

## Detailed File Checks

- `research/CLAUDE.md` 41 lines: constitution ≤80, details in `canon/README.md` (117 lines, schema, lint, generation). ✅
- `canon/_topics.yaml` core 12 + `allow_extend:true` + `extension_rule` 中文1行. ✅
- `canon/_questions.yaml` 6 dims, `value_validation` present. ✅
- `canon/research/mcp-prompt-injection.md` & `canon/concepts/guardrail-layers.md`: 12-field, `citable:false`, `depth: cited`, `wiki_page` exists, `raw_refs` 3 with locators. Body 48w/34w. ✅
- `raw/papers/mcp-001.md` (arxiv), `raw/articles/mcp-002.md` (tool sanitization), `raw/github/mcp-003.md` (awesome-mcp defense), `raw/articles/guardrail-001.md`, `raw/github/guardrail-002.md` + 5 migrated papers (6 total) — each frontmatter `original_url/source_type/medium/slug/fetched_on/title` via ingest. ✅
- `wiki/research/mcp-prompt-injection.md` 3 claims `[ ^raw/papers…]` + 3 raw_refs match, `source_canon` back-link, `depth: cited`. ✅
- `wiki/topics/mcp-security.md` hub 3 claims, `canonical_refs` reuse. ✅
- `wiki/topics/guardrail-layers.md` 3 claims, reuse `mcp-001`. ✅
- `canon/_index.md` 2 entries, By Topic grouping, `⚠️ unregistered` logic present (not triggered — all registered). ✅
- `wiki/index.md` 3 pages, columns Page|Title|Topics|Canon|Raw Refs. ✅
- `wiki/topics/_clusters.md` generated from `_clusters.yaml` (security-foundations, agent-core). ✅
- `wiki/log.md` append-only, init entry 2026-08-28. ✅
- `canon/lint.sh` 234L, 6 rules + WARN, `ruby -ryaml` + `yq --front-matter=extract`, `find … -print0 | sort -z`. ✅
- `scripts/generate.py` 324L, stdlib only, `--emit all|index|clusters|ammo`, idempotent. ✅
- `scripts/ingest.sh` 141L, `strenv` safe, `trap rm -f TMP_YAML`, `&` permissive WARN, detect→medium mapping. ✅
- `.tad/config-workflow.yaml` fallback `primary: local_wiki`. Reachable via `rg primary`. ✅
- `alex/SKILL.md` body retains `*research` routing table + Iron Rule block (lines 830-838). ✅
- `alex/references/research-plan-protocol.md` LOCAL-WIKI DEEP EXTENSION header + 5 `local_wiki` hits, canon loop description. ✅
- `research-github/SKILL.md` shim header at 193, fallback Netflix note, retains `scan-log` merge-write semantics. ✅
- `patterns/research-methodology.md` line 56 local-wiki entry (file-is-truth + Iron Rule + generate.py purity). ✅
- `REGISTRY.yaml` 34 archived, `migrated-from-notebooklm.txt` 5 entries, `.tad/evidence/research/local-wiki/{lint-report,generate-diff,migration-log}.md` evidence present. ✅

---

## Issue Register

### P0 — 0 open (Gate 2 P0 closed in handoff §4.1)
| ID | Source | Description | Status |
|----|--------|-------------|--------|
| P0-1 | code-reviewer P0-1 scope, security P2-7 | Scope 过大 (video/audio/vector 全量 MVP) | **CLOSED** — Phased: Phase1 图文+GitHub+Iron Rule, P2 video/audio, P3 vector. Verified deferred, no implementation. |
| P0-2 | security P0-2 | YAML 注入 via original_url | **CLOSED** — `strenv` + `ruby -ryaml` + lint rule6 PASS, injection test escapes `"` → valid YAML. |
| P0 (Iron Rule 剧场) | security P0-1 | Iron Rule 验证剧场 (计数而非解析) | **CLOSED** — 6 rules with path existence + locator regex + claim==raw_refs mismatch, 3 negatives FAIL真值. |

### P1 — 0 open
| ID | Description | Resolution |
|----|-------------|------------|
| P1 cred leak | 凭据泄露 | N/A — no secrets, no creds ingested. |
| P1 overwrite | raw 覆写风险 | Phase1: git tracks raw, `wiki/log.md` append-only, `generate.py` sole writer; overwrite not blocking for Phase1. Minor hardening deferred to P2. |
| P1 contradiction | contradiction 字段 | Schema not required Phase1; document via canon free-text + wiki synthesis; P3 vector phase may add explicit field. |
| P1 saturation | 饱和度量 | Defined in constitution §4 (a)(b)(c) + `wiki/log.md` stall logging; operational metric via lint stable + 0 new locators — acceptable Phase1. |

### P2 — 2 deferred (NEXT.md)
| ID | Severity | Description | Suggested NEXT |
|----|----------|-------------|----------------|
| **P2-1** | P2 | **ingest overwrite idempotency comment vs code gap**: `ingest.sh:77` comment "Ensure uniqueness if file exists (append counter)" but code `OUT_PATH="${OUT:-…}/${SLUG}.md"` does not implement counter; second ingest of same URL would clobber. Low risk Phase1 (git recoverable, manual ingest), but should implement `i=1; while [ -f "$OUT_PATH" ]; do OUT_PATH=…-${i}.md; i++` or block-and-warn in P2. Also lint negative harness for /tmp paths loses `is_wiki` heuristic — consider `--is-wiki` flag or require wiki-path temp dir for negatives. | Add to NEXT: `research/scripts/ingest.sh` counter + lint flag; risk low. |
| **P2-2** | P2 | **research-github shim documentation duality**: SKILL header declares local_wiki shim, but body Steps 7-11 still narrate full NotebookLM notebook creation pipeline without explicit "fallback only when research/ missing" guard in each step. Functionally fallback is described in header + DEEP EXTENSION, but step body could be gated (`if [ -d research/canon ] then local_wiki shim else notebooklm`). Clarify to prevent future implementer confusion. | NEXT: gate Steps 7-11 with `research/` existence check or move NotebookLM path to Appendix. |

---

## Evidence Manifest

Absolute paths verified:
- `/Users/sheldonzhao/01-on progress programs/TAD/research/CLAUDE.md`
- `/Users/sheldonzhao/01-on progress programs/TAD/research/canon/_topics.yaml`
- `/Users/sheldonzhao/01-on progress programs/TAD/research/canon/_questions.yaml`
- `/Users/sheldonzhao/01-on progress programs/TAD/research/canon/_clusters.yaml`
- `/Users/sheldonzhao/01-on progress programs/TAD/research/canon/_index.md`
- `/Users/sheldonzhao/01-on progress programs/TAD/research/canon/README.md`
- `/Users/sheldonzhao/01-on progress programs/TAD/research/canon/lint.sh`
- `/Users/sheldonzhao/01-on progress programs/TAD/research/canon/research/mcp-prompt-injection.md`
- `/Users/sheldonzhao/01-on progress programs/TAD/research/canon/concepts/guardrail-layers.md`
- `/Users/sheldonzhao/01-on progress programs/TAD/research/raw/papers/mcp-001.md`
- `/Users/sheldonzhao/01-on progress programs/TAD/research/raw/articles/mcp-002.md`
- `/Users/sheldonzhao/01-on progress programs/TAD/research/raw/github/mcp-003.md`
- `/Users/sheldonzhao/01-on progress programs/TAD/research/raw/articles/guardrail-001.md`
- `/Users/sheldonzhao/01-on progress programs/TAD/research/raw/github/guardrail-002.md`
- `/Users/sheldonzhao/01-on progress programs/TAD/research/raw/manifests/migrated-from-notebooklm.txt`
- `/Users/sheldonzhao/01-on progress programs/TAD/research/wiki/index.md`
- `/Users/sheldonzhao/01-on progress programs/TAD/research/wiki/log.md`
- `/Users/sheldonzhao/01-on progress programs/TAD/research/wiki/topics/_clusters.md`
- `/Users/sheldonzhao/01-on progress programs/TAD/research/wiki/research/mcp-prompt-injection.md`
- `/Users/sheldonzhao/01-on progress programs/TAD/research/wiki/topics/mcp-security.md`
- `/Users/sheldonzhao/01-on progress programs/TAD/research/wiki/topics/guardrail-layers.md`
- `/Users/sheldonzhao/01-on progress programs/TAD/research/scripts/generate.py`
- `/Users/sheldonzhao/01-on progress programs/TAD/research/scripts/ingest.sh`
- `/Users/sheldonzhao/01-on progress programs/TAD/.tad/config-workflow.yaml`
- `/Users/sheldonzhao/01-on progress programs/TAD/.claude/skills/alex/SKILL.md`
- `/Users/sheldonzhao/01-on progress programs/TAD/.claude/skills/alex/references/research-plan-protocol.md`
- `/Users/sheldonzhao/01-on progress programs/TAD/.claude/skills/research-github/SKILL.md`
- `/Users/sheldonzhao/01-on progress programs/TAD/.tad/project-knowledge/patterns/research-methodology.md`
- `/Users/sheldonzhao/01-on progress programs/TAD/.tad/research-notebooks/REGISTRY.yaml`
- `/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/research/local-wiki/lint-report.md`
- `/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/research/local-wiki/generate-diff.md`
- `/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/research/local-wiki/migration-log.md`

Live commands executed (see Evidence section): `bash research/canon/lint.sh` PASS, negatives FAIL×3 as designed, `python3 generate.py --emit all` idempotent hash match, `bash ingest.sh --dry-run` + injection safe, `yq` + `ruby -ryaml` validations, `grep -c status:archived` 34, `ls papers/*.md` 6.

---

## Gate 3 Recommendation

- **code-reviewer**: PASS — all AC-A…AC-J SATISFIED with live evidence, lint PASS + 3 negatives FAIL, generate idempotent, ingest delegation + yaml safe, scope allowed via §12 approved parallel isolation, P1s correctly deferred per phased delivery.
- **P2 follow-ups** (non-blocking): address ingest counter + research-github step gating in NEXT.md (no Gate 3 re-review needed).
- **Next**: proceed to security-auditor Layer 2; expect P0=0, P1≤1 for dual PASS. Archive upon Alex Gate 4 acceptance.

---

*Reviewed by reading every source file and re-executing every Verify command from §4. No reliance on COMPLETION prose.*

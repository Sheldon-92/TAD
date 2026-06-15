---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/reading-companion"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 — Sinks + Multi-Format

**From:** Alex  **To:** Blake  **Date:** 2026-06-14
**Project:** TAD — AI-Native Reading Companion
**Task ID:** TASK-20260614-001
**Epic:** EPIC-20260613-ai-native-reading-companion.md (Phase 4/4 — FINAL)
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness
| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | New adapters all normalize to the SAME content.json schema → reuse Phase 2/3 reader/render/plan/bridge unchanged |
| Components Specified | ✅ | text-ingest / url-ingest / pdf-ingest + export-notes (structured-by-chapter MD) |
| Functions Verified | ✅ | content.json schema (chapters→paragraphs+pid+source_hash) + reading-state thread[] already exist (Phase 2/3); reuse export-annotations.py |
| Data Flow Mapped | ✅ | {pdf,txt,md,url} → content.json → (existing) render/plan/bridge; reading-state → export-notes → notes.md |

**Gate 2 结果**: ✅ PASS

**说明**: code-reviewer + backend-architect 双审（均 CONDITIONAL PASS→resolved）。核心 P0：两位独立收敛到「§4.3 schema 漏了 `tag`（plan-gen 靠它分标题/正文，漏了计划质量悄悄烂）+ `href/title`」「AC1 证明不了 schema-match → 改成跨 4 适配器的 key-set shape-diff」「pid 决定性未规定 → PDF/URL 重解析会静默错挂标注 → 加纯函数契约 + 共享 hash helper + 重跑字节一致 AC」「FR4 问题提取不可实现（thread 无问题类型）→ 明确提取规则」「无 fixtures → ACs 跑不了 → 加 Phase A.0」。P1：URL 安全（script→text/SSRF/重定向/超时/大小/content-type + AC）、图像版 PDF fail-loud、全适配器 ≥1 章否则 fail-loud、subprocess shell=False。全部整合。架构（一个归一化内容模型复用 render/plan/bridge）两位都认可。

---

## 1. Task Overview
### 1.1 What
Final phase: (a) extend ingestion beyond EPUB to **PDF / TXT / Markdown / URL**, all normalizing into the SAME `content.json` schema so the existing reader/plan/bridge work unchanged; (b) make reading produce a durable **sink**: structured-by-chapter notes + open-question list + full Markdown export of a reading session.

### 1.3 Intent
**真正要解决的**: 让阅读伴侣不只吃 EPUB(任意文档都能读) + 读完能带走一份真正有结构的沉淀。
**不是要做的**:
- ❌ 不是新的 reader/bridge 机制(Phase 2/3 稳定,不动)
- ❌ 不是闪卡/KM 同步(用户本期只要 结构化笔记+问题清单+MD 导出)
- ❌ 不是 PDF 的高保真版面还原(文本重排即可,图表丢失可接受 v1)

---

## 📚 Project Knowledge（Blake 必读）
- patterns/shell-portability.md — macOS/BSD 兼容；pdftotext 是外部 CLI，需 preflight。
- patterns/ac-verification.md — §9.1 可跑且可区分。
- principles.md — UI/交互类必须真验；honest_partial（PDF 无 pdftotext 时 BLOCKED 而非假装）。

**⚠️ 历史教训**:
1. **stdlib-only(Python)** 仍是约束 — PDF **不引 python 依赖**，改 shell-out 到系统 `pdftotext`(poppler)。URL/TXT/MD 用 stdlib(urllib + html.parser)。
2. **复用而非重造** — 所有适配器产出 Phase 2 的同一 `content.json`；不要改 render/plan/bridge。export 复用/扩展现有 `export-annotations.py`。

---

## 3. Requirements
- **FR1 text-ingest** (`tools/text-ingest.py`, stdlib): TXT + Markdown → content.json. Markdown 按 `#`/`##` 标题切章；TXT 按空行/启发式切段。稳定 pid `c{n}-p{m}` + source_hash（与 epub-ingest 同 schema）。
- **FR2 url-ingest** (`tools/url-ingest.py`, stdlib urllib + html.parser): 抓取 URL → 提取正文 → content.json（单章，或按 `<h1/h2>` 切章）。**安全/健壮（必须）**: 复用 epub-ingest 的 `_BlockExtractor` + SKIP_TAGS 并**加 `nav/footer/aside/header`**；`html` 字段走同一转义+白名单（**绝不放原始 `<script>`/事件处理器**——存储型 XSS）；`urlopen(timeout=…)` + 读取上限 `read(MAX_BYTES)`；强制 `Content-Type: text/html`（否则 fail loud）；只允许 `http(s)` scheme，**拒绝重定向到非 http(s)/内网/file://**（SSRF）；404/二进制/超时 → 非零退出 + 不写 content.json。robots v1 可不做（若做用 `urllib.robotparser`）。
- **FR3 pdf-ingest** (`tools/pdf-ingest.py`): preflight `command -v pdftotext`；`subprocess.run([...], shell=False)`（文件名用户可控，**禁止 shell 字符串**）跑 `pdftotext -layout <pdf> -`。**章节化阶梯**: (1) 以 `\f`(换页)为基线章节/段落单元；(2) best-effort 把 ALL-CAPS/短独立行提升为 `tag=h2`（明确标注 lossy）；(3) 永远 ≥1 章。**失败要响亮**: 无 pdftotext → BLOCKED（`brew install poppler` 提示）；**图像版 PDF / 提取出 <N 非空白字符 → BLOCKED**（"无文本层，v1 不支持 OCR"），绝不写空书。
- **FR4 export-notes** (`tools/export-notes.py`): content.json + reading-state.json → 完整会话 Markdown。**问题提取（明确规则，不许猜）**: (a) plan.md 的问题 = 解析 `## Questions` 标题下的列表项（非全文 grep `?`）；(b) thread 的问题 = `role=="user" 且 text.rstrip() 以 "?"/"？" 结尾` 的 turn（排除 assistant 反问）。**按章节组织**: 高亮/批注的分组键 = 其 anchor 起始 `refinedBy.pid` 所属章节；**无锚点/跨章的问题 → 归入「General / 未定位」桶**。结构：每章 `## {chapter title}` 下列其高亮(附段落上下文 blockquote) + 该章问题；末尾 `## Open Questions` 汇总 + `## 对话精华`(thread 摘要)。
- **FR5 统一入口**: SKILL.md 文档化 `ingest <file-or-url>` 自动按扩展名/scheme 路由到正确适配器（.epub→epub-ingest, .pdf→pdf-ingest, .txt/.md→text-ingest, http(s)→url-ingest）。

### NFR
- NFR1 Python stdlib-only（PDF 例外：shell-out 到系统 pdftotext，记 friction）。NFR2 macOS/BSD 兼容。NFR3 所有适配器产出**字节级同 schema** 的 content.json（现有 render/plan/bridge 零改动即可消费）。

---

## 4. Technical Design
### 4.1 Architecture
```
{.epub → epub-ingest(Phase2)}  ┐
{.txt/.md → text-ingest}        ├─→ content.json (SAME schema) ─→ render/plan/bridge (UNCHANGED, Phase 2/3)
{http(s) → url-ingest}          │                                  reading-state.json ─┐
{.pdf → pdf-ingest(pdftotext)} ┘                                                       ▼
                                                              export-notes ─→ notes.md (by-chapter highlights + question list + thread digest)
```
The whole value: ONE normalized content model means every reader/plan/bridge feature built in Phase 2/3 works for every format for free.

### 4.3 content.json schema (MUST match epub-ingest.py EXACTLY — re-derived from the real producer)
> ⚠️ The real epub-ingest output has MORE fields than a naive read suggests. Missing any silently breaks downstream (esp. `tag`, which plan-gen uses to separate headings from body).
```
{ "source_hash": "<sha256>", "title": "<non-empty>",
  "chapters": [ { "chapter_id": "c{n}", "title": "...", "href": "...",
      "paragraphs": [ { "pid": "c{n}-p{m}", "tag": "p|h1|h2|h3|li|blockquote",
                        "text": "<normalized>", "html": "<escaped, inline-whitelist only>" } ] } ] }
```
- **`tag`** (REQUIRED): plan-gen separates headings (`h1/h2/h3`) from body via `tag`; render picks the HTML element from it. MD `#/##/###`→`h1/h2/h3`; URL `<h1/h2>`→headings; PDF promoted heading lines→`h2`; everything else→`p`.
- **`href`** (chapter): epub emits it; new adapters may use a synthetic value (e.g. `"#c{n}"`) but the KEY must exist.
- **`title`**: non-empty guarantee per format (TXT→filename stem; URL→`<title>`; PDF→metadata or filename; fallback `"Untitled"`).
- **`html`**: escaped text with epub's inline-tag whitelist ONLY — never raw source markup (stored-XSS guard; reuse epub-ingest `_escape_text` discipline).

**Determinism contract (P0 — Phase 2 annotation re-attach depends on it)**: every adapter MUST be a **pure deterministic function of input bytes** — identical input → byte-identical content.json (identical `source_hash` AND identical pid→text mapping). source_hash = `sha256` over each paragraph's `_norm_ws(text)` + `\n` in order — **use ONE shared helper** imported by all adapters (do NOT re-implement per file; that's how the invariant drifts). Re-fetching a URL later legitimately yields new bytes → new source_hash → new document identity (old annotations simply don't re-attach — the safe failure; never try to "update in place").

**Minimum-viable / fail-loud (all adapters)**: every adapter MUST emit ≥1 chapter with ≥1 paragraph, OR **fail loud** (non-zero exit + reason, write NO content.json) — never a silent empty/near-empty book. Generalizes §10.1's PDF rule to TXT/MD/URL too (empty TXT, extraction-yielded-nothing URL, image-only PDF all → BLOCKED-not-silent).

**Shared adapter interface** (for the §FR5 dispatcher): each adapter exposes `ingest(path_or_url) -> content_dict` + all use ONE shared `write_content(content, out)` (same `-o`/stdout/stderr-summary convention as epub-ingest). The shared normalize+hash+write helpers are the single enforcement point for the schema + determinism invariants.

---

## 6. Implementation Steps (Blake)
- **Phase A.0 — fixtures + shared helper** (REQUIRED first): create `fixtures/sample.md`, `sample.txt`, `sample.html` (with `<nav>/<script>alert(1)</script>/<style>/<footer>` noise + a real `<article>` to test stripping), a tiny **text** PDF + (note) an image-only/text-less PDF case, and a `reading-state.json` fixture (≥2 annotations in DIFFERENT chapters + ≥1 user `?` thread turn) + a `plan.md` with a `## Questions` section. Extract the shared `normalize_ws + source_hash + write_content` helper (from epub-ingest) into a small module all adapters import. Without fixtures the post-impl ACs are un-runnable.
- **Phase A — text-ingest** (TXT+MD → content.json, emits `tag` from `#/##/###`). Verify: render the output through existing render.py → opens fine (AC1/AC2).
- **Phase B — url-ingest** (stdlib fetch+extract). Verify on a simple article URL (AC3).
- **Phase C — pdf-ingest** (pdftotext shell-out + preflight + BLOCKED-if-absent). Verify on a text PDF (AC4) + the no-pdftotext error path (AC4b).
- **Phase D — export-notes** (by-chapter notes + question list + thread digest). Verify structured (not flat) output (AC5).
- **Phase E — unified `ingest` router** in SKILL.md + a thin `tools/ingest.py` dispatcher by extension/scheme. Verify routing (AC6).

## 7. File Structure
### 7.1 Create
```
.claude/skills/reading-companion/tools/text-ingest.py
.claude/skills/reading-companion/tools/url-ingest.py
.claude/skills/reading-companion/tools/pdf-ingest.py
.claude/skills/reading-companion/tools/export-notes.py
.claude/skills/reading-companion/tools/ingest.py        # dispatcher by ext/scheme
```
### 7.2 Modify
```
.claude/skills/reading-companion/SKILL.md               # unified ingest + export-notes docs
```
### 7.3 Grounded Against
- tools/epub-ingest.py (content.json schema source of truth — read head), tools/render.py (consumes content.json), tools/export-annotations.py (extend for export-notes), SKILL.md — read 2026-06-14.
- new files — (new — will be created).

## 8.4 Friction Preflight
| Friction | Required step | Fix path | Substitute | Gate impact |
|---|---|---|---|---|
| pdftotext absent | PDF ingest | `brew install poppler` | none for PDF; TXT/MD/URL unaffected | PDF path BLOCKED (explicit error), not silent empty book |
| URL extraction quality | readable text from arbitrary HTML | stdlib html.parser main-content heuristic | accept lower fidelity v1; note it | none (best-effort, documented) |
| Sample PDF/URL fixtures for ACs | tests need inputs | make a tiny text PDF via pdftotext-roundtrip / use a stable simple URL or a local .html fixture | local .html fixture for url-ingest test | no fixture → AC un-runnable → BLOCKED |

## 8.5 Feedback Collection
```yaml
feedback_required: false
notes: "Mostly backend adapters + export; reuses the Phase 2/3 reader UI unchanged. No new UI surface to feedback."
```

## 9.1 Spec Compliance Checklist
| # | AC | Type | Verification Method | Expected |
|---|----|------|--------------------|----------|
| AC1 | **schema-match: key-set shape == epub (all 4 adapters)** | post-impl | for each adapter output X: `diff <(jq -S 'paths(scalars)\|join(".")\|gsub("[0-9]+";"N")' epub.json\|sort -u) <(jq -S 'paths(scalars)\|join(".")\|gsub("[0-9]+";"N")' X.json\|sort -u)` | empty diff (incl. `chapters.N.paragraphs.N.tag` + `.href` + `.title`) |
| AC2 | renders via EXISTING render.py | post-impl | `python3 tools/render.py <X.json> -o /tmp/x.html` → exit 0 + `grep -c data-pid /tmp/x.html` | exit 0, ≥1 |
| AC2b | **tag emitted (headings≠body)** | post-impl | MD fixture w/ `#`/`##` → `jq -r '[.chapters[].paragraphs[].tag]\|unique' X.json` | contains a heading tag (h1/h2/h3), not all "p" |
| AC3 | URL → content.json (local .html fixture) | post-impl | ingest sample.html → chapters≥1, paragraphs≥1 | ≥1 |
| AC3b | **URL strips script/nav (no stored XSS / boilerplate)** | post-impl | ingest sample.html (has `<script>alert(1)</script>`+`<nav>`) → `jq -r '..\|.text?,.html?' X.json \| grep -cE 'alert\(1\)\|<script\|<nav'` | 0 |
| AC3c | URL non-HTML/404 → fail loud | post-impl | ingest a non-HTML or 404 URL/fixture | non-zero exit + reason; NO content.json written |
| AC4 | PDF → content.json (pdftotext) | post-impl | ingest a text PDF fixture → chapters≥1 | ≥1 (mark NOT_APPLICABLE if pdftotext absent, with note) |
| AC4b | PDF no-pdftotext → BLOCKED | post-impl | `PATH=/nonexistent` (or `--pdftotext-bin /bin/false`) → pdf-ingest | non-zero exit + `brew install poppler` hint; NO content.json |
| AC4c | **image-only/no-text-layer PDF → BLOCKED** | post-impl | pdf-ingest on a text-less PDF (or pdftotext yields <N non-ws chars) | non-zero exit + "no text layer/OCR unsupported"; NO content.json |
| AC5 | **determinism: re-ingest twice byte-identical** | post-impl | ingest same fixture twice → `diff a.json b.json` | empty (identical source_hash + pid mapping) |
| AC5b | empty input → fail loud (not empty book) | post-impl | ingest an empty .txt | non-zero exit + reason; NO content.json |
| AC6 | export-notes by-chapter + question extraction | post-impl | reading-state w/ 2 annots in diff chapters + 1 user `?` thread turn + plan.md `## Questions` → `python3 tools/export-notes.py … -o notes.md` | grouped under per-chapter `## ` headings (not flat); `## Open Questions` lists BOTH plan + thread `?` questions; unanchored → "General" bucket |
| AC7 | unified ingest routes by ext/scheme | post-impl | `tools/ingest.py` on `.epub/.md/http://…/unknown.docx` | routes correctly; unknown → clear non-zero error |
| AC8 | stdlib-only + subprocess hygiene | post-impl | ast allow-set per file: subprocess appears ONLY in pdf-ingest; no other 3rd-party; grep pdf-ingest for `shell=True` | NON_STDLIB []; subprocess only in pdf-ingest; 0 `shell=True` |
| AC9 | scope | post-impl | `git diff --name-only \| grep -vE '^\.claude/skills/reading-companion/'` | empty |

## 9.2 Expert Review Status
### Audit Trail
| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer + backend-architect | P0: §4.3 schema omits `tag`/`href`/`title` (plan-gen depends on tag) | §4.3 re-derived schema (tag/href/title required) + AC2b | Resolved |
| code-reviewer + backend-architect | P0: AC1 proves keys-exist not schema-match | AC1 → key-set shape-diff vs epub across all 4 adapters | Resolved |
| backend-architect | P0: pid determinism unspecified → PDF/URL re-ingest mis-attaches | §4.3 determinism contract + shared hash helper + AC5 (re-ingest byte-identical) | Resolved |
| backend-architect | P0-3: PDF chapterization underspecified + page-as-chapter cost | FR3 `\f` ladder + lossy heading promote + ≥1 chapter | Resolved |
| code-reviewer | P0-3: FR4 question-extraction unimplementable (thread has no question type) | FR4 explicit rules (plan `## Questions` parse + user `?` turns) + grouping key + General bucket + AC6 | Resolved |
| code-reviewer | P0-4: no fixtures → ACs un-runnable | §6 Phase A.0 fixture+helper step | Resolved |
| code-reviewer + backend-architect | P1: URL security (script→text/SSRF/redirect/timeout/size/content-type) no AC | FR2 security spec + AC3b/AC3c | Resolved |
| code-reviewer | P1: image-only PDF silent empty book | FR3 + AC4c | Resolved |
| both | P1: min ≥1 chapter or fail-loud (all adapters) | §4.3 min-viable rule + AC5b | Resolved |
| code-reviewer | P1: subprocess shell=False, subprocess-only-pdf | FR3 + AC8 | Resolved |
| backend-architect | P1: shared normalize+hash helper + adapter interface (DRY invariant) | §4.3 shared-helper + §6 Phase A.0 | Resolved |
| backend-architect | P2: title non-empty per format; html escaped/whitelist | §4.3 title + html rules | Resolved |
### Experts Selected
1. **code-reviewer** — parser robustness, schema-match, stdlib+subprocess hygiene, fail-loud paths.
2. **backend-architect** — adapter normalization, determinism/pid-stability, chapterization, export data lineage.
### Overall Assessment (post-integration)
- code-reviewer: CONDITIONAL PASS → 4 P0 + 5 P1 integrated (schema/tag, shape-diff AC, FR4 extraction, fixtures, URL security, image-PDF, subprocess).
- backend-architect: CONDITIONAL PASS → 3 P0 + 4 P1 integrated (schema completeness, determinism contract, PDF chapterization, shared helper/interface).

## 10. Important Notes
### 10.1 Critical
- ⚠️ All adapters MUST emit the byte-compatible content.json schema or they silently break render/plan/bridge — AC1 schema-match is load-bearing.
- ⚠️ pdf-ingest: NEVER write an empty/garbage content.json when pdftotext is missing or the PDF is image-only — fail loud (honest_partial).
- ⚠️ url-ingest: stdlib only; sanitize fetched HTML to TEXT (strip script/style/nav); do not execute or embed remote content.
### 10.4 Pack Anti-Patterns
- ⚠️ Don't re-implement render/plan/bridge — reuse. The phase's whole point is the shared content model.

---
**Handoff Created By**: Alex  **Date**: 2026-06-14  **Version**: 3.1.0

---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/reading-companion"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-13
**Project:** TAD — AI-Native Reading Companion
**Task ID:** TASK-20260613-001
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260613-ai-native-reading-companion.md (Phase 2/4)
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-06-13 (post expert review)

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | EPUB→normalized content model→render HTML from template+sidecar; anchoring model specified (W3C TextQuote) |
| Components Specified | ✅ | ingest / render / plan-gen scripts + reader.html template + SKILL.md |
| Functions Verified | ✅ | All-new code (greenfield skill dir); no existing functions to verify; stdlib-only EPUB parse path specified |
| Data Flow Mapped | ✅ | EPUB → content.json → (reader.html + reading-state.json) → highlight → sidecar → re-attach |

**Gate 2 结果**: (filled after expert review integration)

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 1. Task Overview

### 1.1 What We're Building
Phase 2 of the AI-Native Reading Companion: turn an **EPUB** into an **e-reader-grade
HTML reading surface** plus an auto-generated **reading/research plan**, with **in-flow
annotation** that persists to a **sidecar data file** and survives HTML regeneration.
This phase is the READING SURFACE only — there is NO live bridge / terminal conversation
yet (that is Phase 3).

### 1.2 Why We're Building It
**业务价值**：这是「重新设计阅读体验」的地基。先把「读得下去 + 想法不丢」做扎实，桥和共读才有意义。
**用户受益**：丢一个 EPUB → 立刻得到一个排版舒服、能划重点、带结构地图的阅读页，标注永不丢失。
**成功的样子**：当用户能打开生成的 HTML 沉浸阅读、划线后关掉再打开标注还在、并看到一份「这本书在讲什么 + 该带哪些问题读」的计划时，本 Phase 成功。

### 1.3 🆕 Intent Statement（意图声明）

**真正要解决的问题**：把任意 EPUB 变成「电子阅读器级」的、可标注、带结构地图的本地 HTML 阅读面，且标注的真相源在数据文件里（HTML 只是渲染视图）。

**不是要做的（避免误解）**：
- ❌ 不是做实时对话 / 桥接服务（那是 Phase 3）
- ❌ 不是支持 PDF/TXT/URL（那是 Phase 4；本 Phase 只做 EPUB）
- ❌ 不是把标注存在 HTML 里（标注必须落 sidecar，HTML 可重新生成）
- ❌ 不是让 AI 自动总结全书（北极星：让人想得更多，不是更少）

**Blake请确认理解**：用你自己的话回答 3 个问题（解决什么问题 / 用户怎么用 / 成功标准），Human 确认后再实现。

---

## 📚 Project Knowledge（Blake 必读）

**⚠️ MANDATORY READ** — Blake 实现前必读：

### 步骤 1：相关类别
- [x] architecture - 渲染管线 + 锚定数据模型
- [x] code-quality - 脚本可移植性
- [x] frontend-design - 阅读排版 (66 CPL / 1.5 行高 / 米色暗色主题)

### 步骤 2：历史经验摘录

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| principles.md | L1 | 通用方法论规则；遵守 Gate 链 |
| patterns/shell-portability.md | 1 条 | 脚本必须 macOS/BSD 兼容（grep/awk/sed/jq 写法、heredoc 安全、CJK locale）——本 Phase 有 shell/python 脚本 |
| patterns/ac-verification.md | 1 条 | AC 设计、dry-run 纪律、fixture 区分度——本 Phase §9.1 多为 post-impl，需可运行命令 |
| frontend-design.md | 1 条 | Warm Palette 规则（与阅读主题色相关，仅参考） |

**⚠️ Blake 必须注意的历史教训**：
1. **Shell Portability** (patterns/shell-portability.md) — 本机是 macOS/BSD。脚本里 `grep -P`、GNU-only `sed -i` 写法会炸；CJK 文件名/内容要注意 locale。优先 Python stdlib 处理解析，shell 只做编排。
2. **AC Verification** (patterns/ac-verification.md) — §9.1 的验证命令必须真能跑；fixture（示例 EPUB）要能区分「真渲染对」和「假装对」。

### Blake 确认
- [ ] 我已阅读上述历史经验

---

## 🔧 Capability Pack References (Blake 必读)

| Pack | File | Matched Capabilities |
|------|------|---------------------|
| web-ui-design | .claude/skills/web-ui-design/SKILL.md | 阅读排版 / anti-AI-slop token / 视觉层级 / 主题 |
| web-frontend | .claude/skills/web-frontend/SKILL.md | HTML/CSS/JS 结构、可访问性、design token 消费 |

**⚠️ Blake 必须在开始实现前 Read 上述 pack 文件。** 阅读排版的硬数字（measure 66 CPL、line-height 1.5、避免纯白炫光）见 §4 + DESIGN-FINDINGS.md。

---

## 2. Background Context

### 2.1 Previous Work
Phase 1 (研究) 已完成。Grounding 文档：`.tad/evidence/research/ai-native-reading/DESIGN-FINDINGS.md`（必读）。NotebookLM 库 `ai-native-reading` 可随时再查。

### 2.2 Current State
现状：空目录（greenfield skill）。目标：`.claude/skills/reading-companion/` 下产出 ingest/render/plan 脚本 + reader.html 模板 + SKILL.md，能把 EPUB 变成可标注阅读页。

### 2.3 Dependencies
**优先零外部依赖**：EPUB = zip + XHTML + OPF，用 Python stdlib（`zipfile` + `xml.etree.ElementTree` + `html.parser`）即可解析。若确需库，用 venv 装 `ebooklib`（pinned 版本），不污染全局——见 §8.4 Friction Preflight。

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1: `ingest <file.epub>` 解析 EPUB（spine 顺序、章节 XHTML、TOC），归一化为 `content.json`（章节→段落，每段稳定 id + 纯文本 + 轻量 inline 标记）。
- FR2: `render` 从 `content.json` + `reading-state.json` 生成 `index.html`：分章页面、TOC、进度指示、分页与滚动两种模式、米色/暗色主题、measure ~66 CPL、line-height 1.5。
- FR3: 标注——选中文本高亮，行内批注（不做脱离正文的孤立列表）；标注写入 `reading-state.json`，使用 W3C TextQuoteSelector（exact + prefix/suffix）refinedBy 段落锚点 + 源 content-hash。
- FR4: 重渲染稳定——删除/重生成 `index.html` 后，从 source+sidecar 重新渲染，标注按 quote-match 在正确段落重新挂载，零丢失。
- FR5: `plan` 生成 `plan.md`：结构地图（章节大纲）+ 阅读路径 + ≥5 个由内容生成的阅读问题。

### 3.2 Non-Functional Requirements
- NFR1: 脚本 macOS/BSD 兼容；优先 Python stdlib，零外部依赖（或 venv pinned）。
- NFR2: 排版遵守 DESIGN-FINDINGS：measure 50–75（目标 66）CPL、line-height 1.5、米色+暗色主题、避免纯白炫光。
- NFR3: 标注锚定避开已知失败模式（不用纯字符偏移；TextQuote 多匹配时用 prefix/suffix 加宽或 Range 回退）。

---

## 4. Technical Design

### 4.1 Architecture Overview
```
EPUB (zip)
  └─ ingest (python stdlib: zipfile + xml + html.parser)
       └─ content.json   ← normalized: [{chapter_id, title, paragraphs:[{pid, text, html}]}], + source_hash
  └─ plan-gen → plan.md  (structure map + reading path + ≥5 questions)
  └─ render (content.json + reading-state.json) → index.html
                                  ▲ writes        │ reads on load → re-attach highlights
                              reading-state.json ◀┘  (W3C TextQuote anchors + thread placeholder)
```
HTML = rendered VIEW. Source of truth = content.json (text) + reading-state.json (annotations).

### 4.2 Component Specifications
- `tools/epub-ingest.py` — EPUB → content.json. Parse OPF spine for order, extract each XHTML, strip to normalized paragraphs with stable `pid` (e.g., `c{chap}-p{n}`), keep minimal inline html. Compute `source_hash` (sha256 of concatenated normalized text).
- `tools/plan-gen.py` — content.json → plan.md. Structure map from chapter titles + first-paragraph gist; ≥5 reading questions (template-driven from chapter headings; AI-assisted optional but must produce ≥5 deterministically).
- `tools/render.py` — content.json + reading-state.json → index.html (inlines CSS/JS from template; self-contained single file so it's portable).
- `templates/reader.html` — the reader shell: TOC sidebar, content area, progress bar, theme toggle (cream/dark), pagination/scroll toggle, selection→highlight handler that writes anchors to reading-state.json (Phase 2: writes to a local JSON via a "save" mechanism — since no bridge yet, persistence is via a download/save-to-file step OR a `render --save` round-trip; see §10 note).
- `SKILL.md` — how to invoke ingest/render/plan; the reading workspace layout; anchoring model doc.

### 4.3 Data Models
`content.json`:
```json
{ "source_hash": "sha256…", "title": "…",
  "chapters": [ { "chapter_id": "c1", "title": "…",
    "paragraphs": [ { "pid": "c1-p1", "text": "plain text", "html": "<p>…</p>" } ] } ] }
```
`reading-state.json`:
```json
{ "source_hash": "sha256…", "current": {"chapter_id":"c1","scroll_pct":0.0},
  "annotations": [ { "id":"a1", "chapter_id":"c1", "anchor": {
      "type":"TextQuoteSelector", "exact":"…", "prefix":"…", "suffix":"…",
      "refinedBy":{"type":"paragraph","pid":"c1-p3"} },
    "note":"user note", "color":"yellow", "created":"2026-06-13T…" } ],
  "thread": [] }
```

### 4.5 User Interface Requirements
- Reading area: measure ~66 CPL (use `max-width` in `ch` units, ≈ 66ch), line-height 1.5, generous margins.
- Themes: cream (off-white) default + dark; toggle persists to reading-state.
- Navigation: TOC (jump to chapter), visible progress (% or chapter X/Y).
- Layout toggle: paginated vs continuous scroll.
- Annotation: select text → inline highlight + optional note; highlights render in-place (never a detached list as the only view).
- Anti-AI-slop: follow web-ui-design token rules; no generic gradient/emoji-soup aesthetic.

---

## 5. 强制问题回答（Evidence Required）
- MQ1 历史代码搜索: 否 — greenfield skill, 无 "之前的方案" 复用。
- MQ2 函数存在性: N/A — 全新代码，无对既有函数的调用。
- MQ3 数据流: 见 §4.1 + §4.3（EPUB→content.json→html+sidecar→re-attach）。
- MQ4 视觉层级: 高亮/批注/主题状态见 §4.5。
- MQ5 状态同步: 主状态 = content.json(文本) + reading-state.json(标注)；HTML 为派生视图，无双写真相源冲突。

---

## 6. Implementation Steps（分Phase）

### Blake Phase A: EPUB ingest → content.json（预计 1.5h）
#### 交付物
- [ ] `tools/epub-ingest.py`（stdlib only）
- [ ] 对一个示例 EPUB 产出 `content.json`（章节顺序正确、段落有稳定 pid、source_hash 存在）
#### 验证
- `python tools/epub-ingest.py sample.epub -o /tmp/content.json && jq '.chapters|length' /tmp/content.json` → ≥1
- `jq -r '.chapters[0].paragraphs[0].pid' /tmp/content.json` → 形如 `c1-p1`

### Blake Phase B: render → e-reader index.html（预计 2h）
#### 交付物
- [ ] `templates/reader.html` + `tools/render.py`
- [ ] 生成的 `index.html` 自包含（内联 CSS/JS）、measure≈66ch、line-height 1.5、米色+暗色主题、TOC、进度、分页/滚动切换
#### 验证
- 生成 index.html 后，grep 确认 `line-height:1.5` 与 `ch`-based max-width 存在
- 浏览器打开能读、能切主题、TOC 能跳转（feedback HTML 验证，见 §8.5）

### Blake Phase C: 标注 + sidecar 锚定 + 重挂载（预计 2.5h）
#### 交付物
- [ ] 选中→高亮→写 reading-state.json（W3C TextQuote + prefix/suffix + refinedBy pid）
- [ ] 重渲染后按 quote-match 在正确段落重挂载；多匹配用 prefix/suffix 消歧或 Range 回退
#### 验证
- 划一段 → reading-state.json 出现对应 annotation（exact/prefix/suffix/refinedBy 齐全）
- 删除 index.html → 重新 render → 该高亮回到原段落（§9.1 AC5）

### Blake Phase D: plan-gen → plan.md（预计 1h）
#### 交付物
- [ ] `tools/plan-gen.py` 产出结构地图 + 阅读路径 + ≥5 问题
#### 验证
- `python tools/plan-gen.py /tmp/content.json -o /tmp/plan.md && grep -c '^- ' /tmp/plan.md` → 问题/条目 ≥5

---

## 7. File Structure

### 7.1 Files to Create
```
.claude/skills/reading-companion/SKILL.md            # invocation + workspace layout + anchoring doc
.claude/skills/reading-companion/tools/epub-ingest.py
.claude/skills/reading-companion/tools/render.py
.claude/skills/reading-companion/tools/plan-gen.py
.claude/skills/reading-companion/templates/reader.html
.claude/skills/reading-companion/fixtures/            # a small sample EPUB for tests
```
Runtime output (gitignored): `.reading/<doc-slug>/{index.html,content.json,reading-state.json,plan.md}`

### 7.2 Files to Modify
```
.gitignore   # add .reading/
```

### 7.3 Grounded Against
- `.claude/skills/reading-companion/*` — (new — will be created)
- `.tad/evidence/research/ai-native-reading/DESIGN-FINDINGS.md` — (read at 2026-06-13, design rules source)
- `.gitignore` — (Blake reads head before adding .reading/ entry)

---

## 8. Testing Requirements

### 8.1 / 8.2 / 8.3
- Unit: ingest produces stable pids across re-runs (deterministic); render emits required CSS; anchor round-trips.
- Edge cases: EPUB with nested TOC; chapter with repeated identical sentence (anchor multi-match → must disambiguate); non-ASCII/CJK content (locale-safe).

## 8.4 Friction Preflight

| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|----------------|---------------|-------------------|--------------------|-------------|
| EPUB parse may tempt external lib | Parse EPUB | Use Python **stdlib** (zipfile+xml+html.parser) — no install needed | If stdlib insufficient: `pip install ebooklib==<pinned>` **inside a venv** (never global) — DEGRADED_WITH_APPROVAL noting why | Unjustified global install = BLOCKED |
| Sample EPUB fixture needed | Tests need a real .epub | Create a tiny hand-made EPUB in fixtures/ (zip of 2 XHTML + OPF) | Download a public-domain EPUB (Gutenberg) into fixtures/ | No fixture → AC un-runnable → BLOCKED |
| Browser to verify reading UI | Visual check of reader | Open generated feedback HTML; user reviews | claude-in-chrome screenshot | None (visual feedback via §8.5) |

**Status Enum**: `READY` / `BLOCKED` / `DEGRADED_WITH_APPROVAL` / `EQUIVALENT_SUBSTITUTE` / `NOT_APPLICABLE_WITH_REASON`

## 8.5 Feedback Collection (Non-Code Artifacts)
```yaml
feedback_required: true
artifact_type: frontend_page
suggested_dimensions:
  - "typography & readability (measure, line-height, font)"
  - "theme comfort (cream/dark, glare)"
  - "navigation (TOC, progress) clarity"
  - "highlight/annotation interaction feel"
notes: "Blake generates an overlay feedback HTML alongside the reader so the human can mark up the reading UI. North star: does the layout invite deep reading?"
```

---

## 9. Acceptance Criteria
- [ ] FR1–FR5 实现并验证
- [ ] 所有 Blake Phase 完成并提供证据
- [ ] reader.html 视觉符合 DESIGN-FINDINGS 排版规则（feedback HTML 截图）
- [ ] 标注重挂载零丢失（删 HTML 重渲染验证）
- [ ] Human 验证"这是我期望的阅读面"

## 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE — Gate 3 executes each row

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| AC1 | EPUB 解析出章节 | post-impl-verifiable | `python .claude/skills/reading-companion/tools/epub-ingest.py <fixture.epub> -o /tmp/c.json && jq '.chapters\|length' /tmp/c.json` | ≥ 1 | (post-impl) |
| AC2 | 段落有稳定 pid | post-impl-verifiable | `jq -r '.chapters[0].paragraphs[0].pid' /tmp/c.json` | 匹配 `^c[0-9]+-p[0-9]+$` | (post-impl) |
| AC3 | 排版规则落地 | post-impl-verifiable | `python tools/render.py /tmp/c.json -o /tmp/index.html && grep -Ec 'line-height:[[:space:]]*1.5' /tmp/index.html` | ≥ 1 | (post-impl) |
| AC4 | 米色+暗色主题存在 | post-impl-verifiable | `grep -Eic 'theme|--bg|sepia|cream|dark' /tmp/index.html` | ≥ 2 | (post-impl) |
| AC5 | 标注重挂载零丢失 | post-impl-verifiable | 划线写 sidecar → `rm /tmp/index.html` → re-render → `grep -c 'data-annot' /tmp/index.html` | = 标注数 (>0) | (post-impl) |
| AC6 | 锚点用 TextQuote+prefix/suffix | post-impl-verifiable | `jq -e '.annotations[0].anchor | has("exact") and has("prefix") and has("suffix") and has("refinedBy")' /tmp/<slug>/reading-state.json` | true | (post-impl) |
| AC7 | plan 含 ≥5 问题/条目 | post-impl-verifiable | `python tools/plan-gen.py /tmp/c.json -o /tmp/plan.md && grep -c '^- ' /tmp/plan.md` | ≥ 5 | (post-impl) |
| AC8 | 脚本无外部依赖(或 venv) | post-impl-verifiable | `grep -En '^import |^from ' tools/epub-ingest.py | grep -vE 'zipfile|xml|html|hashlib|json|sys|os|argparse|re|pathlib'` | 空（或 venv-pinned 才有第三方） | (post-impl) |
| AC9 | 变更范围符合计划 | post-impl-verifiable | `git diff --stat` | 仅 §7 文件 | (post-impl) |

> 说明：AC 全部 post-impl（greenfield，工件尚不存在）。Alex step1d 已对命令做 syntax dry-run（见 §6.7）。

## 6.7 AC Dry-Run Log
**AC Dry-Run Log** (Alex step1d, 2026-06-13)：所有 §9.1 行为 post-impl-verifiable（工件由 Blake 创建）。已对每条命令做 Sub-rule 2 语法校验：jq filter 合法、grep -E 模式合法（无 `\|`-in-ERE 误用，表格内为展示转义，运行时用裸 `|`）、`git diff --stat` 标准命令。无 pre-impl 行可实跑（无既有工件）。

## 9.2 Expert Review Status (Alex 必填)

### Audit Trail
| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| (filled after step3) | | | |

### Experts Selected
1. **ux-expert-reviewer** — reading UI 是本 Phase 核心交付，排版/可访问性/标注交互需专家审。
2. **code-reviewer** — 锚定数据模型 + stdlib 解析 + 脚本可移植性正确性。

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ 标注真相源 = reading-state.json；HTML 可删可重生成。**绝不**把标注只存在 HTML 里。
- ⚠️ Phase 2 无桥：HTML 写 sidecar 的持久化机制——本 Phase 用「render --save 回合 + 浏览器内导出/写本地 JSON」过渡；真正的实时回写在 Phase 3 由桥服务接管。Blake 选一个 Phase-2 可行的简单方案（如：高亮动作把 annotation JSON 追加到一个可被 render 读取的文件，或先用浏览器 download + 手动放回 workspace），不要为此提前造桥。
- ⚠️ EPUB 解析注意 CJK locale 与 XHTML 命名空间。

### 10.2 Known Constraints
- 仅 EPUB；分页/滚动两模式都要；自包含单文件 HTML（便于携带）。

### 10.4 Pack Anti-Patterns
- ⚠️ [web-ui-design] 不要 AI-slop 审美（滥用渐变/emoji/泛型卡片）；用 design token + 阅读专用排版。
- ⚠️ [web-frontend] 不要用内联 style 堆布局；CSS 变量驱动主题。

### 10.3 Sub-Agent 使用建议
- [ ] test-runner — 每个 Blake Phase 后
- [ ] bug-hunter — 锚点重挂载若不稳

---

## 11. Learning Content

### 11.1 Decision Rationale: EPUB 解析路径
**选择**：Python stdlib（zipfile+xml+html.parser）服务端归一化 → 自渲染 HTML。
| 方案 | 优点 | 缺点 | 为什么没选 |
|------|------|------|-----------|
| stdlib 服务端归一化（选中）| 零依赖、锚定稳定、完全可控 | 自己处理 XHTML 细节 | ✅ 选中 |
| epub.js 浏览器内渲染 | 现成、省事 | 锚定依赖其内部 CFI、定制难、引入 JS 依赖 | 锚定稳定性 + 可控性优先 |
| ebooklib | 解析省事 | 外部依赖（违背零依赖偏好）| 留作 stdlib 不够时的 venv 回退 |

**💡 Human学习点**：先归一化成自有内容模型，再渲染——锚定/导出/多格式都受益（Phase 4 复用同一管线）。

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-06-13
**Version**: 3.1.0

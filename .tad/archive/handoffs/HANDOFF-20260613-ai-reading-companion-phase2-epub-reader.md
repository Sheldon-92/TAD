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
| Data Flow Mapped | ✅ | EPUB → content.json → (reader.html + reading-state.json) → highlight → sidecar → §4.4 re-attach |

**Gate 2 结果**: ✅ PASS

**说明**: 2 位专家（ux-expert-reviewer + code-reviewer）审查，各 CONDITIONAL PASS；6 个 P0 + 10 个 P1 全部已整合修复（见 §9.2 Audit Trail）。核心修复：§4.4 重挂载算法（source_hash gate + 段内 quote-match + Range/stale 回退）、§9.1 全部 AC 改为可区分（AC5 重复句证伪 / AC8 ast 整词遍历三脚本 / AC3-4 真排版与双主题校验）、§10.1 持久化方案锁定（只读渲染+download+--save，禁浏览器写本地以防 Phase3 范围蔓延）、字体/键盘/对比度/导出补齐。少数增强（reading ruler、触控目标）Deferred 到后续 Phase。

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
- FR2: `render` 从 `content.json` + `reading-state.json` 生成 `index.html`：分章页面、TOC、进度指示、分页与滚动两种模式、米色/暗色主题、measure ~66 CPL（`max-width` 用 `ch` 单位）、line-height 1.5、**指定阅读字体（serif 默认）+ 基础字号 ≥18px + 字号可调 + `hyphens:auto`（配合 `<html lang>`）**。
- FR3: 标注——选中文本高亮，行内批注（不做脱离正文的孤立列表）；标注写入 `reading-state.json`，使用 W3C TextQuoteSelector（exact + prefix/suffix）refinedBy 段落锚点 + 源 content-hash。
- FR4: 重渲染稳定——删除/重生成 `index.html` 后，从 source+sidecar 重新渲染，标注**按 §4.4 重挂载算法**在正确段落重新挂载，零丢失（含 source 变更时的 stale 标记）。
- FR5: `plan` 生成 `plan.md`：结构地图（章节大纲）+ 阅读路径（建议阅读顺序/可跳过章节/每章估时）+ **≥5 个基于段落内容（非仅标题）生成的阅读问题，其中 ≥2 个为「请论证/反驳某论点」的对抗式问题**（北极星：逼读者思考，而非理解检查）。
- FR6: `export-annotations` 生成「带上下文的高亮」Markdown（每条高亮连同所在段落文本，绝非孤立列表）——满足研究结论「标注不可被困在工具里」。

### 3.2 Non-Functional Requirements
- NFR1: 脚本 macOS/BSD 兼容；优先 Python stdlib，零外部依赖（或 venv pinned + lockfile）。
- NFR2: 排版遵守 DESIGN-FINDINGS：measure 50–75（目标 66）CPL、line-height 1.5、serif 阅读字体、字号 ≥18px 可调、米色+暗色主题、避免纯白炫光。
- NFR3: 标注锚定避开已知失败模式（不用纯字符偏移；quote-match **限定在 refinedBy.pid 段落内**；多匹配用 prefix/suffix 在该段内消歧；跨元素用 Range 回退；匹配失败 → 标 stale，**绝不静默错挂**）。
- NFR4: 两套主题的正文对比度均满足 WCAG AA（正文 ≥4.5:1）；主题色值在 §4.5 明确给出（米色 bg/暗色 bg + 对应前景）。
- NFR5: 键盘可达——分页（←/→ 或 j/k）、TOC 切换、主题切换、字号增减均有快捷键；交互元素 Tab 顺序合理。

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
  **⚠️ stdlib 解析三个必踩坑（明示以免 Blake 转去装 lxml）**：
  1. OPF 与 XHTML 都有命名空间——`ElementTree` 返回 `{http://www.idpf.org/2007/opf}spine` / `{http://www.w3.org/1999/xhtml}p`，必须显式注册/剥离命名空间，否则 `.find('spine')` 恒为 None。
  2. spine→文件解析：经 manifest `idref`→`href`，且 href **相对 OPF 自身目录**（常见 `OEBPS/`），从 zip 根直接拼会 404。
  3. 部分 EPUB 的 XHTML 不严格合规——`xml.etree` 遇畸形会抛异常，需对单文件回退到 `html.parser` 容错解析。
  **`chap` 编号基准**：用 spine index（不是 TOC index）；nested TOC 与 spine 可能不一致，以 spine 为准。
  **pid 稳定性契约**：pid 仅在「同一 source_hash」内稳定；跨 ingester 版本/重排 spine **不保证**稳定——这正是 source_hash gate（§4.4）存在的理由。
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

### 4.4 Re-attach Algorithm (P0 — annotation 重挂载契约，必须实现这个，不可由 Blake 自由发挥)
重渲染时对每条 annotation：
1. **source_hash gate**：比较 `reading-state.source_hash` 与 `content.source_hash`。
   - 相等 → 可信重挂载，进 step 2。
   - 不等（源变了）→ 仍尝试 best-effort，但把该 annotation 标 `stale: true`（UI 显示「源已变更，位置可能不准」），**绝不静默重锚**。
2. **限定段落**：在 `refinedBy.pid` 指定的那一个段落内做 quote-match（不是全书 `indexOf`——这是击败多匹配的关键）。
3. **段内消歧**：若该段内 `exact` 出现多次，用 `prefix`/`suffix` 锁定唯一一处。
4. **回退**：段内仍无法唯一定位 → 用 Range（startSelector/endSelector）回退；再不行 → 标 `stale`，保留 annotation 数据（不丢），UI 提示需人工重定位。
> 反模式：全文 `indexOf(exact)` 取首个匹配——会在重复句场景错挂（§8.3 fixture 必须含重复句来证伪）。

### 4.5 User Interface Requirements
- Reading area: measure ~66 CPL (`max-width: 66ch` on the content/`<article>` element specifically), line-height 1.5, generous margins.
- **Typography**: serif 阅读字体（如 system serif stack / Georgia 类）；基础字号 ≥18px；提供字号增减控件（A−/A+）持久化到 reading-state；`hyphens:auto` + `<html lang>`。
- **Themes (具体色值，满足 WCAG AA ≥4.5:1)**: cream 默认（bg `#f5f0e6` 类、前景 `#2b2620` 类）+ dark（bg `#1a1a1a` 类、前景 `#d6d3cc` 类，避免纯黑配中灰导致 <4.5:1）。用 CSS 自定义属性（`--bg`/`--fg`）+ `[data-theme="dark"]` 覆盖；toggle 持久化。
- Navigation: TOC (jump to chapter); 进度指示——**滚动模式用 % 滚动位置；分页模式用「章 X/Y」**（分页下 47% 无意义）。
- Layout toggle: paginated vs continuous scroll.
- **Keyboard**: ←/→（或 j/k）翻页、`t` 切 TOC、`d` 切主题、`-`/`+` 调字号；交互元素可 Tab 聚焦，不干扰浏览器 find-in-page。
- Annotation: select text → inline highlight + optional note; highlights render in-place (never a detached list as the only view); 高亮颜色存语义 token（如 `hl-1`）按主题解析，保证暗色下仍清晰。
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

### Blake Phase C: 标注 + sidecar 锚定 + 重挂载（预计 3h）
#### 交付物
- [ ] 选中→高亮→（内存）annotation（W3C TextQuote + prefix/suffix + refinedBy pid）；保存走 §10.1 download+`--save` 合并
- [ ] **实现 §4.4 重挂载算法**：source_hash gate + 限定 refinedBy.pid 段内 quote-match + prefix/suffix 段内消歧 + Range/stale 回退
- [ ] **fixture 必须含一个重复句**（同一句在同章出现 ≥2 次）用于证伪首匹配错挂
- [ ] **负控**：一条 `exact` 已不存在于 source 的 annotation → 必须被标 `stale` 且数据保留（不静默丢/错挂）
#### 验证
- 划一段 → annotation 含 exact/prefix/suffix/refinedBy 齐全
- 删除 index.html → 重新 render → 高亮回到**正确**段落，且其外层元素 pid == annotation.refinedBy.pid（§9.1 AC5，重复句 fixture 验证）
- 改一字使 source_hash 变化 → 重渲染 → 受影响 annotation 标 stale（§9.1 AC5b）

### Blake Phase D: plan-gen → plan.md（预计 1.5h）
#### 交付物
- [ ] `tools/plan-gen.py` 产出结构地图 + 阅读路径（顺序/可跳过/估时）+ ≥5 个基于段落内容的问题，其中 ≥2 为对抗式（论证/反驳）
#### 验证
- `python tools/plan-gen.py /tmp/content.json -o /tmp/plan.md`；`## Questions` 段下以 `?` 结尾的条目 ≥5（§9.1 AC7）

### Blake Phase E: export-annotations → 带上下文 Markdown（预计 0.5h）
#### 交付物
- [ ] `tools/export-annotations.py`：每条高亮连同所在段落文本导出为 Markdown（非孤立列表）
#### 验证
- `python tools/export-annotations.py /tmp/<slug>/reading-state.json -o /tmp/highlights.md`；每条高亮下方有其段落上下文（§9.1 AC10）

---

## 7. File Structure

### 7.1 Files to Create
```
.claude/skills/reading-companion/SKILL.md            # invocation + workspace layout + anchoring doc
.claude/skills/reading-companion/tools/epub-ingest.py
.claude/skills/reading-companion/tools/render.py
.claude/skills/reading-companion/tools/plan-gen.py
.claude/skills/reading-companion/tools/export-annotations.py
.claude/skills/reading-companion/templates/reader.html
.claude/skills/reading-companion/fixtures/            # a small sample EPUB (MUST contain a duplicated sentence for AC5)
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
| AC1 | EPUB 解析出章节 | post-impl-verifiable | `python tools/epub-ingest.py <fixture.epub> -o /tmp/c.json && jq '.chapters\|length' /tmp/c.json` | ≥ 1 | (post-impl) |
| AC2 | 段落 pid 稳定+格式 | post-impl-verifiable | 跑两次 ingest 比对：`python tools/epub-ingest.py <fx.epub> -o /tmp/a.json; python tools/epub-ingest.py <fx.epub> -o /tmp/b.json; diff <(jq -S .chapters /tmp/a.json) <(jq -S .chapters /tmp/b.json)` 且 `jq -r '.chapters[0].paragraphs[0].pid' /tmp/a.json` | diff 为空 且 pid 匹配 `^c[0-9]+-p[0-9]+$` | (post-impl) |
| AC3 | measure 66ch + 行高 1.5 落在正文元素 | post-impl-verifiable | `python tools/render.py /tmp/c.json -o /tmp/index.html` 后对正文选择器块校验：`grep -Ec 'max-width:[[:space:]]*6[0-9]ch' /tmp/index.html` 与 `grep -Ec 'line-height:[[:space:]]*1\.5(;|[[:space:]]|})' /tmp/index.html` | 两者均 ≥ 1 | (post-impl) |
| AC4 | 两套主题有不同 bg 值 | post-impl-verifiable | `python - <<'PY'`（解析 `--bg` 在默认与 `[data-theme="dark"]` 块的取值并断言不相等）`PY`（或 `grep -Eo '\-\-bg:[^;]+' /tmp/index.html \| sort -u \| wc -l`） | ≥ 2 个不同 `--bg` 值 | (post-impl) |
| AC5 | 重挂载到**正确**段落（重复句证伪） | post-impl-verifiable | 用含重复句 fixture：划第 2 处 → 保存合并 → `rm /tmp/index.html` → re-render → 断言被高亮元素外层 pid == annotation.refinedBy.pid 且命中第 2 处（脚本对比 offset） | 高亮落在 refinedBy.pid 段且为 prefix/suffix 指定那处 | (post-impl) |
| AC5b | source 变更 → 标 stale 不静默错挂 | post-impl-verifiable | 改一字使 source_hash 变 → re-render → `jq -e '[.annotations[]|select(.stale==true)]\|length>0' /tmp/<slug>/reading-state.json` | true（受影响 annotation 标 stale，数据保留） | (post-impl) |
| AC6 | 锚点用 TextQuote+prefix/suffix+refinedBy | post-impl-verifiable | `jq -e '.annotations[0].anchor\|has("exact") and has("prefix") and has("suffix") and has("refinedBy")' /tmp/<slug>/reading-state.json` | true | (post-impl) |
| AC7 | plan 含 ≥5 真问题(含 ≥2 对抗式) | post-impl-verifiable | `python tools/plan-gen.py /tmp/c.json -o /tmp/plan.md`；`awk '/^## Questions/{f=1;next}/^## /{f=0}f' /tmp/plan.md \| grep -c '?$'` 且人工/grep 确认 ≥2 含「论证\|反驳\|argue\|defend\|refute」 | `?`结尾问题 ≥5，对抗式 ≥2 | (post-impl) |
| AC8 | 三脚本均无外部依赖(或 venv+lock) | post-impl-verifiable | 见下方 AC8 脚本：抽取顶层模块 token，与 stdlib allow-set 做**整词**比对，遍历 `tools/*.py` | 无非 stdlib 导入；若有第三方则 `requirements.txt`/lockfile 存在且为 venv | (post-impl) |
| AC9 | 变更范围符合计划 | post-impl-verifiable | `git diff --name-only \| grep -vE '^(\.claude/skills/reading-companion/\|\.gitignore$)'` | 输出为空 | (post-impl) |
| AC10 | 导出为带上下文高亮(非孤立列表) | post-impl-verifiable | `python tools/export-annotations.py /tmp/<slug>/reading-state.json -o /tmp/hl.md && grep -c '> ' /tmp/hl.md` | ≥ 每条高亮 1 行段落上下文（blockquote） | (post-impl) |

**AC8 verifier script**（整词锚定 allow-set，遍历三脚本——修复子串 deny-list 漏判）：
```bash
python - <<'PY'
import ast, pathlib, sys
ALLOW={'zipfile','xml','html','hashlib','json','sys','os','argparse','re','pathlib','io','collections','urllib','base64','difflib','unicodedata','datetime'}
bad=[]
for f in pathlib.Path('.claude/skills/reading-companion/tools').glob('*.py'):
    t=ast.parse(f.read_text())
    for n in ast.walk(t):
        if isinstance(n,ast.Import):
            for a in n.names:
                if a.name.split('.')[0] not in ALLOW: bad.append((f.name,a.name))
        elif isinstance(n,ast.ImportFrom) and n.level==0:
            if (n.module or '').split('.')[0] not in ALLOW: bad.append((f.name,n.module))
print('NON_STDLIB:',bad)
sys.exit(1 if bad else 0)
PY
```
> 期望：exit 0（无第三方）。若团队批准 venv 第三方 → 该脚本会列出，需同时存在 `requirements.txt`（pinned）+ venv 证据，否则 AC8 FAIL。

## 6.7 AC Dry-Run Log
**AC Dry-Run Log** (Alex step1d, 2026-06-13)：§9.1 全部为 post-impl-verifiable（greenfield，工件由 Blake 创建，无 pre-impl 行可实跑）。已做 Sub-rule 2 语法校验并修正专家发现的命令缺陷：
- AC3 行高正则已转义 `1\.5`（原 `1.5` 的 `.` 是 ERE 元字符，会误配 `1x5`）；并新增 `max-width:..ch` 检查（原只查 line-height）。
- AC4 改为断言 ≥2 个**不同** `--bg` 取值（原 `grep ≥2` 任意关键字命中即过，单暗色表也能蒙混）。
- AC5 改为「外层 pid == refinedBy.pid 且命中 prefix/suffix 指定那处」+ 重复句 fixture（原仅数 `data-annot` 个数，错挂也过）；新增 AC5b 测 source 变更标 stale。
- AC8 改为 `ast` 抽取整词模块名 + allow-set 比对，遍历三脚本（原 `grep -vE` 子串 deny-list：`lxml`/`htmlmin`/`jsonschema`/`subprocess` 全漏判——principles.md 记录的同类坑）。
- AC7 改为 `## Questions` 段下 `?` 结尾计数（原 `grep '^- '` 数任意 bullet，5 个章节条目即可蒙混）。
- AC9 改为 `git diff --name-only | grep -vE '<允许路径>'` 返回空（原「仅 §7 文件」靠肉眼）。
jq filter 与运行时裸 `|` 已确认合法（表格内 `\|` 为 markdown 单元格转义，运行时去转义）。

## 9.2 Expert Review Status (Alex 必填)

### Audit Trail
| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0-1: 重挂载算法缺失，source_hash 带而未用，多匹配防御只是声称 | §4.4 Re-attach Algorithm（新增）+ FR4 + NFR3 | Resolved |
| code-reviewer | P0-2: AC8 deny-list 子串匹配，lxml/htmlmin/subprocess 漏判 | §9.1 AC8 改 ast 整词 allow-set 遍历三脚本 + §6.7 | Resolved |
| code-reviewer | P0-3: AC5 只数 data-annot 个数，错挂也过 | §9.1 AC5 改「外层 pid==refinedBy.pid+命中指定处」+重复句 fixture + AC5b stale | Resolved |
| code-reviewer | P1-1: pid 决定性断言但未处理破坏因素 | §4.2 pid 稳定性契约（同 source_hash 内稳定）+ AC2 双跑 diff | Resolved |
| code-reviewer | P1-2: AC3/AC4 弱代理（未转义 1.5、未查 66ch、单主题蒙混） | §9.1 AC3/AC4 重写 | Resolved |
| code-reviewer | P1-3: §6.7 dry-run 声称过度 | §6.7 重写，列明各 AC 缺陷与修正 | Resolved |
| code-reviewer | P1-4: §10.1 持久化菜单含偷渡 Phase3 选项 | §10.1 锁定只读渲染+download+--save 合并，禁止浏览器写本地 | Resolved |
| code-reviewer | P1-5: stdlib 命名空间/spine 解析陷阱未点明 | §4.2 三个坑明示 | Resolved |
| code-reviewer | P2: AC7 数 bullet / range schema 缺 / color 字面值 | AC7 改 `?` 计数；Range 在 §4.4 回退提及；§4.5 高亮用语义 token | Resolved |
| ux-expert-reviewer | P0-A: 标注持久化甩给 Blake（架构决策，不是实现选择） | §10.1 锁定方案（同 P1-4） | Resolved |
| ux-expert-reviewer | P0-B: AC3/AC4 grep 字符串证明不了阅读体验 | §9.1 AC3/AC4 重写（同 P1-2）+ §8.5 feedback 视觉验证 | Resolved |
| ux-expert-reviewer | P0-C: 字体规格完全缺失 | §4.5 + FR2/NFR2 加 serif/≥18px/可调/hyphens | Resolved |
| ux-expert-reviewer | P1-A: plan 是 TOC dump 非主动阅读脚手架 | FR5 改基于段落内容+≥2 对抗式问题；AC7 改 | Resolved |
| ux-expert-reviewer | P1-B: 无键盘导航 | §4.5 Keyboard + NFR5 | Resolved |
| ux-expert-reviewer | P1-D: 导出/三路 sink 缺失 | FR6 + Blake Phase E + AC10（带上下文 MD） | Resolved |
| ux-expert-reviewer | P1-E: 暗色对比度未规定 | NFR4 WCAG AA + §4.5 具体色值 | Resolved |
| ux-expert-reviewer | P1-C/P2: 进度指示器/reading ruler/触控目标 | §4.5 进度按模式区分（分页用章X/Y）；reading ruler 记入 Epic Phase later | Resolved/Deferred |

### Experts Selected
1. **ux-expert-reviewer** — reading UI 是本 Phase 核心交付，排版/可访问性/标注交互需专家审。
2. **code-reviewer** — 锚定数据模型 + stdlib 解析 + 脚本可移植性正确性。

### Overall Assessment (post-integration)
- code-reviewer: CONDITIONAL PASS → 3 P0 + 5 P1 + 多 P2 全部 Resolved（reading ruler 等增强 Deferred 到后续 Phase）。
- ux-expert-reviewer: CONDITIONAL PASS → 3 P0 + 5 P1 全部 Resolved（触控目标/reading ruler Deferred）。

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ 标注真相源 = reading-state.json；HTML 可删可重生成。**绝不**把标注只存在 HTML 里。
- ⚠️ **Phase 2 持久化机制（已锁定，不是 menu，Blake 不得自选）**：采用**只读渲染 + 浏览器原生 download + `render --save` 合并**模型：
  1. `index.html` 在浏览器内捕获高亮/批注到内存；
  2. 用户点「保存」→ 浏览器用 Blob `download` 导出一个 annotations JSON（`file://` 页面零依赖可行）；
  3. 用户把该文件放回 workspace → `python tools/render.py … --save <annot.json>` 把它**合并**进 `reading-state.json` 并重渲染。
  - ❌ **禁止**「浏览器高亮动作直接写本地文件」方案——`file://` 页面无法写任意本地文件，那需要 Phase 3 的本地服务/native-host，属于**范围蔓延到 Phase 3**，本 Phase 严禁。
  - 真正的实时回写在 Phase 3 由桥服务接管；Phase 2 接受「保存需一次 download+合并」的轻微摩擦。
- ⚠️ EPUB 解析注意 CJK locale 与 XHTML 命名空间（见 §4.2 三个坑）。

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

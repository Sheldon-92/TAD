---
task_type: research
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: NotebookLM 知识层 Spike — 验证 "外部记忆层" 可行性
**From:** Alex (Agent A) | **To:** Blake (Agent B)
**Date:** 2026-05-03
**Project:** TAD Framework
**Epic:** EPIC-20260503-cross-model-orchestration.md (Spike — 可能扩展 Epic scope)
**Priority:** P2
**Time Cap:** 90 minutes hard

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 4 步线性流程：安装 → 建库 → 喂源 → 查询评估 |
| Components Specified | ✅ | notebooklm-py CLI (PyPI)，需 venv 安装 |
| Functions Verified | ✅ | CLI 命令来自 [官方 README](https://github.com/teng-lin/notebooklm-py) |
| Data Flow Mapped | ✅ | 多源输入 → NotebookLM 知识库 → CLI 查询 → 评估输出质量 |

**Gate 2 结果**: ✅ PASS

---

## 1. Task Overview

**核心假设**：NotebookLM 的真正价值不是生成播客/PPT（那是副产品），而是它能处理大规模异构数据源（YouTube 视频、PDF、网页、播客）并在语料库上做跨源推理。如果这个能力可以通过 CLI 被 TAD agent 调用，NotebookLM 就能成为 **TAD 的外部记忆层**——不受 context window 限制的知识基础设施。

**验证方法**：独立验证（不与其他平台对比）。只回答一个问题：**NotebookLM 通过 CLI 查询多源语料库时，能不能产出有实际价值的跨源洞察？**

**真实研究场景**：使用 NEXT.md 待解决问题 "AI agent bash deny patterns"。喂入 YouTube 技术访谈 + 博客文章 + 框架文档 + 学术论文，然后用 CLI 查询跨源综合答案。

---

## 2. 实验步骤

### Step 1: 安装 + 认证（15 min cap）

```bash
# ⚠️ 必须用 venv（全局 CLAUDE.md 安全原则）
python3 -m venv /tmp/notebooklm-spike-venv
source /tmp/notebooklm-spike-venv/bin/activate

# 安装（含 browser 支持用于 auth）
pip install "notebooklm-py[browser]"
playwright install chromium

# 认证（需要用户 Google 账号登录）
notebooklm login
```

⚠️ **认证需要用户介入**：`notebooklm login` 会打开浏览器让用户登录 Google 账号。Blake 执行到这一步时必须通知用户手动完成登录。

⚠️ **非官方包警告**：notebooklm-py 使用未公开的 Google API，可能随时失效。这是 spike 性质——验证当前可用性，不承诺长期稳定。

**判定**：
- `notebooklm login` 成功 + `notebooklm list` 返回结果 → 继续 Step 2
- 认证失败 / 包安装失败 → 记录错误，标注 **SKIP**，spike 结束

### Step 2: 创建知识库 + 喂入多源数据（25 min cap）

```bash
# 创建研究笔记本
notebooklm create "TAD AI Agent Security Research"
# 记录返回的 notebook_id

# ⚠️ 必须选中 notebook（CR-P0-1）
notebooklm use <notebook_id>

# 如果后续命令报 'no active notebook'，用 --notebook <id> 显式传入（CR-P1-5 fallback）
```

添加多源数据（目标：≥5 个源，≥3 种类型）：

**数据源清单**（Blake 从以下列表选取实际可用的 ≥5 个）：

| # | 类型 | 来源 | 为什么选这个 |
|---|------|------|-------------|
| 1 | YouTube | 搜索 "AI agent security sandbox dangerous commands 2026" 选一个 ≥10min 的技术访谈 | 测试视频转录 + 理解能力 |
| 2 | YouTube | 搜索 "Claude Code safety permissions hooks" 选一个相关视频 | 测试平台特定内容的理解 |

⚠️ YouTube 源 fallback（BA-P1-2 + CR-P1-4）：
- 如果 10 分钟内找不到相关 YouTube 视频 → 用播客/会议演讲替代
- YouTube 视频无字幕/CC 时会静默失败为空源 → 如果 Q3 查询无视频内容，检查视频是否有 captions enabled
- 至少 1 个 YouTube/视频源成功是 INTEGRATE 的必要条件
| 3 | 网页 | OpenAI Codex CLI sandbox 文档页 (developers.openai.com/codex/cli/features) | 测试网页抓取 |
| 4 | 网页 | Anthropic Claude Code 安全相关博客/文档 | 跨平台对比源 |
| 5 | 网页 | 搜索一篇 "LLM agent security best practices 2026" 博客文章 | 通用安全视角 |
| 6 | PDF（可选） | 如果能找到 AI agent 安全相关的 PDF 论文/白皮书 | 测试 PDF 处理 |

```bash
# 添加源的命令模式
notebooklm source add "https://youtube.com/watch?v=XXXXX"
notebooklm source add "https://developers.openai.com/codex/cli/features"
notebooklm source add "https://example.com/blog-post"
# ...
```

**记录每个源的添加结果**：成功/失败 + 处理时间 + 源类型。

**判定**：
- ≥5 个源成功添加（含 ≥1 个 YouTube）→ 继续 Step 3
- YouTube 源添加失败但其他成功 → 继续 Step 3，标注 YouTube 能力 DEFER
- ≤2 个源成功 → 标注 **DEFER**，记录失败原因

### Step 3: 查询 + 评估（30 min cap）

用 4 个递进层次的问题测试查询能力：

**Q0: 基线捕获（BA-P1-1）**
在 NotebookLM 查询之前，先用 Claude WebSearch 问同一个 Q3 问题作为基线：
```
用 WebSearch 搜索 "AI agent bash command deny patterns regex categories 2026"，综合结果写出按类别组织的 regex 模式列表。
```
保存基线输出到 query-outputs.md §Q0。这让质量评分 1-5 有锚点：3 分 = 与此基线相当。

**Q1: 单源事实提取**
```bash
notebooklm ask "What specific bash commands does the Codex CLI sandbox restrict by default?"
```
评估：答案是否准确引用了 Codex 文档源？

**Q2: 跨源综合**
```bash
notebooklm ask "Compare how Claude Code and Codex CLI handle dangerous bash operations. What are the key differences in their security models?"
```
评估：答案是否综合了多个来源？是否指出了具体差异？

**Q3: 跨媒体推理（YouTube + 文档）**
```bash
notebooklm ask "Based on all sources including video content, what bash command patterns should an AI agent deny? Provide specific regex patterns organized by category (file destruction, database, network, privilege escalation, git destructive)."
```
评估：答案是否包含来自 YouTube 视频的信息（不只是文档）？regex 是否具体可用？

**Q4: 洞察生成（超越搜索能力的价值）**
```bash
notebooklm ask "What security gaps exist across all the frameworks discussed in these sources? What dangerous patterns are NOT covered by any of them?"
```
评估：这个答案是不是比简单搜索能得到的更深？是否提出了源材料中没有明确说的 insight？

**每个查询记录**：
- 原始输出（完整）
- 引用了哪些源？
- 是否包含来自 YouTube 的信息？
- Wall-clock 时间
- 主观质量评分（1-5）：1=无用 2=不如搜索 3=与搜索相当 4=比搜索好 5=搜索做不到的洞察

### Step 4: 副产品测试（10 min cap，可选）

如果 Step 1-3 顺利且有剩余时间：
```bash
# 测试 audio podcast 生成（CR-P0-2: 正确语法是 generate audio）
notebooklm generate audio "Focus on security model comparisons across Claude Code and Codex" --wait
```
记录输出但不作为核心判定依据。

---

## 5. SPIKE-REPORT Template

```markdown
# SPIKE-REPORT: NotebookLM Knowledge Layer Feasibility

## Verdict: [INTEGRATE / DEFER / SKIP]

## Environment
- notebooklm-py version: {version}
- Python: {version}
- Auth method: {browser login / SSO}

## Source Ingestion Results
| # | Type | URL/Path | Status | Processing Time |
|---|------|----------|--------|----------------|
| 1 | YouTube | ... | ✅/❌ | Xs |
| ... | | | | |

## Query Results
| Q# | Question Type | Quality (1-5) | Cross-Source? | YouTube Content? | Latency | Time |
|----|--------------|---------------|---------------|-----------------|---------|------|
| Q0 | Baseline (Claude WebSearch) | X | N/A | N/A | Xs | Xs |
| Q1 | Single-source extraction | X | N/A | N/A | Xs | Xs |
| Q2 | Cross-source synthesis | X | Y/N | N/A | Xs | Xs |
| Q3 | Cross-media reasoning | X | Y/N | Y/N | Xs | Xs |
| Q4 | Insight generation | X | Y/N | Y/N | Xs | Xs |

## Key Finding
{1-2 sentences: what did we learn?}

## Phase 1 Scope Impact
- If INTEGRATE: NotebookLM 加入 Epic scope 作为 "知识层" 通道
- If DEFER: {retest conditions}
- If SKIP: {reason}

## Byproduct Tests (optional)
- Audio: {result}
- Mind map: {result}

## Time Log
- Step 1 (install+auth): {duration}
- Step 2 (create+sources): {duration}
- Step 3 (queries): {duration}
- Step 4 (byproducts): {duration}
- Total: {total}
```

---

## 6. Files to Create

| File | Purpose |
|------|---------|
| `.tad/evidence/spikes/SPIKE-20260503-notebooklm/SPIKE-REPORT.md` | 主报告 |
| `.tad/evidence/spikes/SPIKE-20260503-notebooklm/query-outputs.md` | Q1-Q4 原始输出 |

**Grounded Against** (Alex step1c):
- notebooklm-py PyPI page verified exists
- CLI 命令来自 GitHub README (verified via WebSearch)
- 无现有文件修改（spike 创建新 evidence）

---

## 9. Acceptance Criteria

| AC# | Criteria | Verification |
|-----|----------|-------------|
| AC1 | notebooklm-py 安装成功（venv 内） | SPIKE-REPORT Environment section |
| AC2 | ≥5 个数据源添加到知识库（含 ≥1 YouTube） | SPIKE-REPORT Source Ingestion 表 ≥5 行 ✅ |
| AC3 | 4 个查询全部执行并记录原始输出 | query-outputs.md 含 Q1-Q4 |
| AC4 | 每个查询有质量评分 (1-5) | SPIKE-REPORT Query Results 表 |
| AC5 | 至少 1 个查询的回答引用了 YouTube 视频内容 | SPIKE-REPORT Q3 YouTube Content = Y |
| AC6 | SPIKE-REPORT 含 INTEGRATE/DEFER/SKIP 判定 | grep verdict |
| AC7 | SPIKE-REPORT 含 Phase 1 Scope Impact | grep "Phase 1" |

**综合判定规则**：
- Q3/Q4 质量评分 ≥4 且 YouTube 内容成功引用 → **INTEGRATE**
- CLI 能用但质量评分 ≤3 → **DEFER**（等工具成熟）
- CLI 不能用 / auth 失败 / 源添加全部失败 → **SKIP**

---

## 9.2 Expert Review

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0-1: 缺 `notebooklm use <id>` 步骤 | §2 Step 2 已加 | Resolved |
| code-reviewer | P0-2: `audio generate` 语法反了 | §2 Step 4 改为 `generate audio` | Resolved |
| code-reviewer | P0-3: `generate mindmap` 不存在 | §2 Step 4 已删除 | Resolved |
| code-reviewer | P1-4: YouTube 无字幕会静默失败 | §2 数据源清单后加提示 | Resolved |
| code-reviewer | P1-5: `notebooklm use` 可能不跨 shell | §2 Step 2 加 `--notebook` fallback | Resolved |
| backend-architect | P1-1: Q1 浪费应加 WebSearch 基线 | §2 Step 3 新增 Q0 基线 | Resolved |
| backend-architect | P1-2: YouTube 源选择太模糊 | §2 加 fallback 分支 + 时间上限 | Resolved |
| backend-architect | P1-3: 缺每次查询延迟记录 | §5 Query Results 表加 Latency 列 | Resolved |

---

## 10. Important Notes

### 10.1 用户介入点
Step 1 的 `notebooklm login` 需要用户在浏览器中登录 Google 账号。Blake 必须在这一步暂停并通知用户。

### 10.2 venv 必须
全局 CLAUDE.md 安全原则：实验性依赖必须用虚拟环境。notebooklm-py 是非官方包，更需要隔离。

### 10.3 非官方 API 随时可能失效
如果 API 报错或行为异常，详细记录错误信息。spike 的价值在于确定"现在能不能用"，不在于修复问题。

### 10.4 YouTube 源是核心测试
YouTube 视频处理是 NotebookLM 区别于所有其他平台的独特能力。如果 YouTube 源添加失败，这个 spike 的价值大幅降低——应该标注 DEFER 而非 INTEGRATE。

### 10.5 质量评分标准
- 1 = 无用（答非所问或幻觉）
- 2 = 不如直接 WebSearch（浅且不准确）
- 3 = 与 WebSearch ×5 相当（准确但无跨源增量）
- 4 = 比 WebSearch 好（有明确的跨源综合 + 更深洞察）
- 5 = WebSearch 做不到的（引用视频内容 + 发现源材料间的矛盾/互补）

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训

- **包安装安全原则 (全局 CLAUDE.md)**: 永远用 venv，不污染全局环境
- **Shell access = 万能集成层 (architecture.md, 2026-05-03)**: NotebookLM CLI 是又一个通过 shell 可调用的工具，遵循同一编排模式

### Required Evidence Manifest
```yaml
spike_report: ".tad/evidence/spikes/SPIKE-20260503-notebooklm/SPIKE-REPORT.md"
query_outputs: ".tad/evidence/spikes/SPIKE-20260503-notebooklm/query-outputs.md"
completion: ".tad/active/handoffs/COMPLETION-20260503-notebooklm-knowledge-layer-spike.md"
```

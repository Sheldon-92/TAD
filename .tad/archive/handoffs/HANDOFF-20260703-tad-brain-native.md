---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: [".tad/hooks/lib", ".claude/skills"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-07-03
**Project:** TAD Framework
**Task ID:** TASK-20260703-002
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260703-gbrain-tad-integration.md (Phase 2/2 — FINAL)

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-07-03

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Index generator → index file → Explore agent wrapper |
| Components Specified | ✅ | bash script + skill definition + SKILL.md edits |
| Functions Verified | ✅ | Explore agent type exists in Claude Code, Agent tool available |
| Data Flow Mapped | ✅ | .tad/ files → brain-index-gen.sh → brain-index.md → Explore agent → answer |

**Gate 2 结果**: ✅ PASS (expert review complete — 5 P0 + 5 P1 resolved, see §9.2)

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] **阅读了 Phase 1 POC 结果** (`.tad/evidence/poc/gbrain-poc/gate-decision.md`)
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 1.1 What We're Building
TAD-native 知识搜索工具 `tad-brain`：一个 bash 脚本生成索引 + 一个 skill/wrapper 调用 Explore agent 做语义搜索。零外部依赖，用 Claude 本身的语义理解能力代替 embedding 向量搜索。

### 1.2 Why We're Building It
**业务价值**：Phase 1 证明了 gbrain 的 BM25 关键词搜索 ≈ grep（1/5 FAIL）。但问题本身是真实的——TAD 有 2000+ 文件，需要语义搜索。Phase 1 的关键洞察：**Claude 本身就是最好的语义搜索引擎**，只需要一个好的索引帮它定位文件。

### 1.3 Intent Statement

**真正要解决的问题**：让 Alex/Blake 能用自然语言查询 TAD 积累的知识，得到跨文档综合回答。

**不是要做的**：
- ❌ 不是要装任何外部工具（gbrain, embedding API, 向量数据库）
- ❌ 不是要替换 @import 或 grep（tad-brain 是补充，不是替代）
- ❌ 不是要替换 NotebookLM（那是外部研究，这是内部知识）

---

## 📚 Project Knowledge

### 历史教训

1. **Phase 1 gbrain POC 发现** (gate-decision.md)
   - BM25 搜索只在关键词完全匹配时有用（Q2 "allow-list" 成功因为术语统一）
   - TAD 的混合 CJK/English + 域标记（⚠️ SAFETY, ANTI-RATIONALIZATION:）是关键词搜索的天敌
   - Q1 失败因为答案在 CLAUDE.md（不在 .tad/），索引必须包含 CLAUDE.md
   - Q5 `think` 是分析性问题（"什么缺了"），需要 LLM 推理能力

2. **Never Hand-Write What an Existing Tool Already Does** (principles.md)
   - Explore agent 已经存在且能做语义搜索 — 不要重写搜索逻辑

---

## 2. Background Context

### 2.1 Phase 1 Findings (must read)
```
Score: 1/5 FAIL
Q1 ❌ — answer not in .tad/ (in CLAUDE.md §4)
Q2 ✅ — keyword match worked (uniform terminology)
Q3 ❌ — "rationalization" vs "ANTI-RATIONALIZATION:" marker format mismatch
Q4 ❌ — "safety patterns" vs "⚠️ SAFETY ENTRY" domain marker
Q5 ❌ — analytical question about absence (impossible for retrieval)
Import: 2282 files, 50.2s, 0 errors — file ingestion is not the bottleneck
```

### 2.2 What Already Exists
- `Agent` tool with `subagent_type: "Explore"` — fast read-only search agent
- `.tad/project-knowledge/patterns/_index.md` — existing pattern index (small-scale precedent)
- `.tad/hooks/lib/` — established location for TAD helper scripts

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1: `brain-index-gen.sh` 扫描 .tad/ + CLAUDE.md，为每个文件生成：路径、类型、关键词、1行摘要
- FR2: 索引文件 `brain-index.md` 小于 1000 行（agent 能一次读完）。Evidence 按目录级索引（不是 per-file）
- FR3: Alex/Blake 通过 SKILL.md 定义的 `tad_brain_protocol` 调用 Agent tool 执行搜索（不是 bash 脚本）
- FR4: 搜索结果包含文件引用（哪个文件的哪部分回答了问题）
- FR5: Phase 1 的 5 个查询中 ≥3 个能得到有用回答

### 3.2 Non-Functional Requirements
- NFR1: 索引生成 < 30 秒（纯文件扫描，无 LLM 调用）
- NFR2: 零外部依赖（只用 bash + 标准工具 grep/awk/sed/find）
- NFR3: 索引格式人类可读可编辑（markdown）

---

## 4. Technical Design

### 4.1 Architecture

```
[brain-index-gen.sh]
    ↓ scans .tad/ + CLAUDE.md
[.tad/brain-index.md]  (~1000-2000 lines)
    ↓ read by
[tad-brain search "<query>"]
    ↓ spawns
[Explore agent]
    ↓ reads index → finds relevant files → reads files → synthesizes
[Answer with file citations]
```

### 4.2 Index File Format (brain-index.md)

```markdown
# TAD Brain Index
Generated: YYYY-MM-DD HH:MM
Files: N

## Principles (15 entries)
| File | Entry | Keywords | Summary |
|------|-------|----------|---------|
| project-knowledge/principles.md#two-agent-system | Two-Agent System | alex, blake, terminal isolation, design review | Alex designs, Blake implements, terminal isolation enforced |
| project-knowledge/principles.md#deny-list | Deny-List Beats Allow-List | sync, allow-list, deny-list, omission | Deny-list for growing sets; diff -r as universal catcher |
...

## Patterns (9 files)
| File | Topic | Keywords | Summary |
|------|-------|----------|---------|
| patterns/gate-design.md | Gate Design | gate, honest_partial, verification, PASS/FAIL | Gate responsibility, rubric gates, quality gate patterns |
...

## Active Handoffs
...

## Archived Handoffs (last 50)
...

## Evidence
...

## CLAUDE.md Sections
| Section | Keywords | Summary |
|---------|----------|---------|
| §1 Handoff Rules | handoff, blake, gate 3, gate 4 | Read handoff → must invoke /blake → must pass gates |
| §4 Terminal Isolation | terminal, alex, blake, bridge | Alex=T1, Blake=T2, human is only info bridge |
...
```

### 4.3 Index Generator Design (brain-index-gen.sh)

**策略**：纯 bash 文件扫描，不用 LLM。

1. **Principles**: 解析 `### ` headers in principles.md → extract title + 第一句话作 summary
2. **Patterns**: 读 `_index.md` (已有!) → 直接复用其格式
3. **Active/Archive handoffs**: 从 frontmatter 提取 task_type + 从 §1.1 提取 1 行摘要
4. **Evidence**: 列目录结构 + 从文件名推断主题
5. **CLAUDE.md**: 解析 `## ` headers → 提取关键词和首句
6. **Project-knowledge files**: 解析 `### ` entries
7. **Config files**: 列出 config-*.yaml 的 `contains:` 字段

**关键词提取方法**（无 LLM）：
- 从 `### ` header 中提取（strip date suffixes: `sed 's/ *[-—] *\(inception\|AMENDED \)\{0,1\}[0-9]\{4\}-[0-9][0-9]-[0-9][0-9]$//'`）
- 从文件名的 slug 中提取（`-` 分词）
- 从特殊标记中提取（`⚠️ SAFETY`, `AR-001`, `ANTI-RATIONALIZATION`）
- Principles/patterns 的 failure_mode 第一行

**⚠️ Pipe 转义**（P0 — 353 个文件内容含 `|`）：
- 所有提取的文本在写入表格前必须转义 pipe：`sed 's/|/\\|/g'`
- 不转义 = 破坏整个表格格式

**⚠️ 路径处理**（项目路径含空格 `01-on progress programs`）：
- 所有 `find` 用 `-print0 | while IFS= read -r -d '' file`
- 所有变量展开双引号包裹
- 参考 `derive-sync-set.sh` 的 quoting 规范

**Evidence 索引策略**（控制行数 <1000）：
- Evidence 按**目录级**索引（~26 个子目录），不是 per-file（~1700 个文件）
- 每个 evidence 子目录一行：目录名 + 文件数 + 从目录名推断主题
- Line budget: Principles ~18 + Patterns ~12 + Handoffs top-50 ~53 + Evidence dirs ~30 + CLAUDE.md ~13 + Project-knowledge ~23 + Others ~50 ≈ **~200 行数据**（含 headers ~250 行总计）

### 4.4 Search Protocol Design (SKILL.md protocol, NOT bash script)

⚠️ 搜索通过 SKILL.md 定义的协议调用 Agent tool 执行。**不是 bash 脚本**（bash 不能调用 Agent tool）。

Alex/Blake 在需要搜索知识时，调用 Agent tool（general-purpose，不用 Explore — Explore 明确禁止 open-ended analysis）：

```
Agent({
  description: "tad-brain search",
  prompt: "Read .tad/brain-index.md — it is a file index organized by category (Principles, Patterns, Handoffs, Evidence, CLAUDE.md Sections). For the query '{query}': 1. Scan the Keywords and Summary columns for semantic matches. 2. Select the top 5 most relevant file paths. 3. Read each file completely. 4. Synthesize a cross-document answer. Format: start with a 2-3 sentence answer, then list [Source: filepath] for each cited file. If the query is analytical (asks 'what is missing' or 'what should we do'), state that explicitly and base analysis on the files read. If no relevant files found in the index, say so."
})
```

⚠️ 不指定 `subagent_type`（默认 general-purpose）— Explore agent 不能做跨文件综合分析。

### 4.5 Re-test Query Plan

Phase 1 的 5 个查询重新测试，预期改进：

| # | Query | Phase 1 结果 | Phase 2 预期改进 |
|---|-------|-------------|-----------------|
| Q1 | Terminal isolation rationale | ❌ (answer outside .tad/) | ✅ — index 包含 CLAUDE.md §4 |
| Q2 | Hardcoded allow-list problems | ✅ (keyword match) | ✅ — semantic match 应更好 |
| Q3 | Rationalization history | ❌ (marker format mismatch) | ✅ — Claude 理解 ANTI-RATIONALIZATION: marker |
| Q4 | Safety patterns interaction | ❌ (domain marker) | ✅ — Claude 理解 ⚠️ SAFETY ENTRY |
| Q5 | Coverage gap analysis | ❌ (needs LLM reasoning) | ✅/❌ — Explore agent 能推理，但可能受限于读文件数 |

---

## 5. 强制问题回答

- MQ1-5: 全部跳过（不涉及项目代码修改、函数调用、数据流、UI、状态同步）

---

## 6. Implementation Steps

### Step A: Index Generator (预计 30 分钟)

#### 交付物
- [ ] `.tad/hooks/lib/brain-index-gen.sh` 可运行
- [ ] 生成 `.tad/brain-index.md` 覆盖 ≥500 文件

#### 实施步骤
1. 创建 `brain-index-gen.sh`，按 §4.3 设计实现各文件类型的扫描
2. 先做 principles.md 解析（最结构化，容易验证）
3. 加入 patterns/_index.md 直接复用
4. 加入 handoffs（active + archive last 50）
5. 加入 CLAUDE.md sections
6. 加入 evidence 目录列表
7. 运行 `bash .tad/hooks/lib/brain-index-gen.sh`，验证输出

#### 验证方法
- `wc -l .tad/brain-index.md` < 2000
- `grep -c '|' .tad/brain-index.md` ≥ 500（至少 500 行表格数据）
- `grep -c 'CLAUDE.md' .tad/brain-index.md` ≥ 1（确认 CLAUDE.md 被索引）

### Step B: Search Wrapper + Integration (预计 45 分钟)

#### 交付物
- [ ] `tad-brain` search 可调用
- [ ] Alex SKILL.md 有 ≥2 个集成点
- [ ] 5 个查询重新测试完毕

#### 实施步骤
1. 在 Alex SKILL.md 中添加 `tad_brain_protocol`：定义何时调用、prompt template、Explore agent 参数
2. 在 Blake SKILL.md 中添加对应的引用
3. 在 tool-quick-reference-alex.md 中添加 tad-brain 命令
4. 运行 5 个查询重新测试（手动调用 Agent tool with Explore type）
5. 记录结果到 `.tad/evidence/poc/tad-brain-native/`
6. 评估：≥3/5 有用 → Phase 2 PASS

#### 验证方法
- `grep -c 'tad.brain\|tad_brain' .claude/skills/alex/SKILL.md` ≥ 2
- `ls .tad/evidence/poc/tad-brain-native/q*.md | wc -l` = 5

### Step C: Auto-rebuild Hook (预计 15 分钟)

#### 交付物
- [ ] 索引在 *accept 时自动重建

#### 实施步骤
1. 在 acceptance-protocol 或 *accept 流程中添加触发：*accept 完成后运行 `brain-index-gen.sh`
2. 或者：添加为 knowledge_maintain_protocol 的一个步骤

#### 验证方法
- 修改一个 project-knowledge 文件 → 运行 *accept → brain-index.md 更新

---

## 7. File Structure

### 7.1 Files to Create
```
.tad/hooks/lib/brain-index-gen.sh     # Index generator script
.tad/brain-index.md                    # Generated index (auto-generated, .gitignore — derived from git-tracked content)
.tad/evidence/poc/tad-brain-native/    # Re-test results
```

### 7.2 Files to Modify
```
.claude/skills/alex/SKILL.md           # Add tad_brain_protocol integration points
.claude/skills/blake/SKILL.md          # Add tad-brain reference
.tad/guides/tool-quick-reference-alex.md  # Add tad-brain commands
```

### 7.3 Grounded Against

- .claude/skills/alex/SKILL.md (exists, ~2500 lines, will add tad_brain_protocol section)
- .tad/hooks/lib/ (exists, contains derive-sync-set.sh, release-verify.sh, etc.)
- .tad/project-knowledge/patterns/_index.md (exists, precedent for index format)
- .tad/evidence/poc/gbrain-poc/gate-decision.md (Phase 1 results, informing this design)

---

## 8. Testing Requirements

### 8.1 Index Generator Tests
- Script runs without errors on current .tad/ directory
- Output < 2000 lines
- All document types represented (principles, patterns, handoffs, evidence, CLAUDE.md)

### 8.2 Search Quality Tests
- Re-run Phase 1's 5 queries via Explore agent
- ≥3/5 produce useful cross-document answers

### 8.3 Edge Cases
- Empty .tad/ subdirectories (e.g., active/handoffs/ may be empty)
- Files with spaces in path (TAD project path has spaces)
- Very large files (handoff template ~600 lines) — summary should still be 1 line

## 8.4 Friction Preflight

No friction-sensitive prerequisites identified. All tools are bash standard + Claude Code's built-in Agent tool.

## 8.5 Feedback Collection

N/A — code/config only.

---

## 9. Acceptance Criteria

- [ ] AC1: `brain-index-gen.sh` 生成 `brain-index.md`，覆盖所有文档类别（principles/patterns/handoffs/evidence/CLAUDE.md），< 1000 行
- [ ] AC2: 索引包含 CLAUDE.md sections（修复 Phase 1 Q1 根因）
- [ ] AC3: General-purpose agent 读索引 + 相关文件后能回答自然语言查询（返回含 [Source: filepath] 引用的综合回答）
- [ ] AC4: Phase 1 的 5 个查询重测，每个有结果文档。≥3/5 判定为"有用"由 Alex 在 Gate 4 评判（Blake 记录原始结果，不做主观判定）
- [ ] AC5: Alex SKILL.md 有 tad_brain_protocol 集成点

---

## 9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output |
|---|---------------------|-------------------|--------------------|--------------------|-----------------|
| 1 | Index <1000 lines, all categories present | post-impl-verifiable | `wc -l .tad/brain-index.md` AND `grep -cE '^\#\# (Principles\|Patterns\|Handoffs\|Evidence\|CLAUDE)' .tad/brain-index.md` | lines < 1000 AND categories ≥ 5 | (post-impl) |
| 2 | Index includes CLAUDE.md | post-impl-verifiable | `grep -c 'CLAUDE.md' .tad/brain-index.md` | ≥ 1 | (post-impl) |
| 3 | Search produces results | post-impl-verifiable | Agent call (general-purpose, no subagent_type) returns answer with [Source:] citations | Non-empty answer | (post-impl) |
| 4 | 5 query results documented | post-impl-verifiable | `ls .tad/evidence/poc/tad-brain-native/q*.md \| wc -l` | 5 files with raw results (有用 judgment deferred to Alex Gate 4) | (post-impl) |
| 5 | SKILL integration | post-impl-verifiable | `grep -c 'tad.brain\|tad_brain' .claude/skills/alex/SKILL.md` | ≥ 2 | (post-impl) |

---

## 9.2 Expert Review Status

### Experts Selected

1. **code-reviewer** — AC specificity, implementation clarity, index format, agent prompt design
2. **backend-architect** — Bash scripting robustness, scale feasibility, path handling, agent type selection

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0: Bash wrapper is dead code (bash can't call Agent tool) | §4.4 — removed bash script, search is SKILL protocol only | Resolved |
| code-reviewer | P0: Line budget contradiction (Epic <1000 vs handoff <2000) | §3.1 FR2, §9 AC1 — unified to <1000, evidence at directory-level | Resolved |
| code-reviewer | P0: "有用" not Blake-verifiable | §9 AC4 — Blake records raw results, Alex judges at Gate 4 | Resolved |
| code-reviewer | P1: Explore agent prompt too thin | §4.4 — expanded prompt with structured instructions | Resolved |
| code-reviewer | P1: git_tracked_dirs incomplete | Noted — will update if needed at Gate 3 | Open |
| code-reviewer | P1: brain-index.md git-tracked + auto-rebuild = noise | §7.1 — changed to .gitignore (derived content) | Resolved |
| backend-architect | P0: 353 entries have pipe chars breaking tables | §4.3 — mandatory `sed 's/\|/\\|/g'` sanitization | Resolved |
| backend-architect | P0: Explore agent forbids open-ended analysis | §4.4 — changed to general-purpose (no subagent_type) | Resolved |
| backend-architect | P1: Path with spaces not addressed | §4.3 — added -print0/xargs-0 mandate + derive-sync-set.sh reference | Resolved |
| backend-architect | P1: "500 files" vs "<2000 lines" unreconciled | §4.3 — added line budget table (~250 lines), AC1 updated | Resolved |
| backend-architect | P1: grep -c pipe over-counts | §9.1 AC1 — changed to category-header count | Resolved |

### Overall Assessment (post-integration)

- code-reviewer: PASS (3 P0 resolved, 2 P1 resolved, 1 P1 open)
- backend-architect: PASS (2 P0 resolved, 3 P1 resolved)

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ brain-index.md 是生成文件但应 git-tracked（人类可能需要编辑/审查）
- ⚠️ Explore agent 有读窗口限制——索引必须够精简，agent 要能一次读完
- ⚠️ 每次 tad-brain 查询消耗 token（Explore agent spawn）——不是免费的，但包含在 Claude Code 已有费用中

### 10.2 Known Constraints
- Explore agent 不能读全部 2000 文件——索引是关键的过滤层
- 索引的关键词质量决定了搜索定位的准确度
- 没有持久化索引（每次重建）——对 ~2000 文件应 < 30s

---

## 11. Decision Rationale

### 11.1 Why TAD-native (not gbrain fork)

| 方案 | 优点 | 缺点 | 为什么没选 |
|------|------|------|-----------|
| TAD-native（选中）| 零依赖、Claude 原生语义理解、能搜 CLAUDE.md | 每次查询耗 token | ✅ 选中 |
| gbrain fork | 持久化索引、向量搜索 | 需要 embedding API 或本地模型 | POC 1/5 FAIL（无 embedding 价值极低）|
| gbrain + API key | 完整功能 | 违反用户"不用额外 AI key"约束 | 用户明确拒绝 |
| 纯 grep | 简单 | 不理解语义、不能跨文档综合 | 就是现状的问题 |

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-07-03
**Version**: 3.1.0

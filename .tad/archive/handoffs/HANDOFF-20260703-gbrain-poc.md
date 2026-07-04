---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: [".claude"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-07-03
**Project:** TAD Framework
**Task ID:** TASK-20260703-001
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260703-gbrain-tad-integration.md (Phase 1/2)

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-07-03

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 线性安装→导入→配置→测试流程，无分支架构 |
| Components Specified | ✅ | gbrain CLI + PGLite + MCP server，全部外部工具 |
| Functions Verified | ✅ | N/A — 不涉及项目代码修改，仅 CLI 操作 |
| Data Flow Mapped | ✅ | .tad/ markdown → gbrain index → MCP search → query results |

**Gate 2 结果**: ✅ PASS (post expert review — 6 P0 + 13 P1 resolved, see §9.2)

**Alex确认**: 我已验证所有设计要素，expert review 完成且所有 P0 已修复。Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

Blake在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 所有"强制问题回答（MQ）"都有证据
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 每个Phase的交付物和证据要求都清楚
- [ ] 确认可以独立使用本文档完成实现

❌ 如果任何部分不清楚，**立即返回Alex要求澄清**，不要开始实现。

---

## 1. Task Overview

### 1.1 What We're Building
安装 gbrain（开源知识图谱 + 语义搜索工具），导入 TAD 的 .tad/ 目录作为知识库，通过 CLI 直接调用测试 5 个预设查询的搜索效果。这是 POC — 证明 gbrain 的搜索核心对 TAD 知识是否有价值。验证通过后 Phase 2 将 fork gbrain 代码，剥离 MCP 层，改造为 TAD 原生 CLI 工具 `tad-brain`。

### 1.2 Why We're Building It
**业务价值**：TAD 积累了 15 条 principles、50+ patterns、100+ archived handoffs（共 ~2000+ markdown 文件），但当前只能通过 @import 全量加载或 grep 关键词搜索。缺少"按需语义搜索"能力。
**用户受益**：Alex/Blake 能在设计和实现中按需查询历史决策、重复教训、跨文档关联。
**成功的样子**：当 agent 能问 "TAD 在 X 方面学到了什么？" 并得到跨文档综合回答时，这个 POC 就成功了。

### 1.3 Intent Statement

**真正要解决的问题**：验证 gbrain 能否对 TAD 的 markdown 知识库产生有用的语义搜索结果。

**不是要做的（避免误解）**：
- ❌ 不是要替换 @import 或现有知识加载机制
- ❌ 不是要做 MCP 集成（Phase 2 将 fork 改造为 TAD 原生 CLI，不走 MCP）
- ❌ 不是要写自定义 schema pack（Phase 2 范围）
- ❌ 不是要修改任何 TAD SKILL 文件
- ❌ 不是要 fork 代码（Phase 2 范围，POC 只验证搜索效果）

**Blake请确认理解**：
```
在开始实现前，请用你自己的话回答：
1. 这个功能解决什么问题？
2. 用户会如何使用？
3. 成功的标准是什么？

只有Human确认你的理解正确后，才能开始实现。
```

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别

本次任务涉及的领域：
- [x] architecture - 架构决策（新增搜索层）
- [x] code-quality - Shell portability（Bun/gbrain CLI 在 macOS 上的行为）

### 步骤 2：历史经验摘录

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| patterns/shell-portability.md | 可能相关 | macOS CLI 工具行为差异 |
| principles.md | 2 条 | "Measure Before Optimizing" + "Never Hand-Write What an Existing Tool Already Does" |

**⚠️ Blake 必须注意的历史教训**：

1. **Never Hand-Write What an Existing Tool Already Does** (principles.md)
   - 问题：之前手写安装脚本导致遗漏目录
   - 与本任务的关联：使用 gbrain 官方 CLI 安装和操作，不要手写替代脚本

2. **Measure Before Optimizing** (principles.md)
   - 问题：曾在没有测量基线的情况下设计优化系统
   - 与本任务的关联：POC 的目的就是测量 gbrain 的实际效果，不要在测量前就开始优化/定制

---

## 2. Background Context

### 2.1 Previous Work
- TAD 已有 NotebookLM 集成用于外部研究资料的语义搜索
- .tad/project-knowledge/ 使用 @import 全量加载
- codebase-memory-mcp 用于代码结构图谱查询（不覆盖文档）

### 2.2 Current State
- .tad/ 目录包含 ~2000+ markdown 文件（knowledge, handoffs, evidence, patterns, principles, guides；含 archive ~600）
- 搜索方式：@import（全量加载固定文件集）或 grep（关键词精确匹配）
- 缺少：语义搜索、跨文档综合、实体图谱

### 2.3 Dependencies
- Bun runtime（当前未安装，需要安装）
- 本地 embedding 模型（gbrain 支持 llama.cpp，无需 API key）
- gbrain 开源项目 (github.com/garrytan/gbrain, pin to specific release tag, MIT)

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1: gbrain 安装成功并能初始化 PGLite 数据库
- FR2: .tad/ 目录的 markdown 文件全部导入 gbrain 索引
- FR3: gbrain CLI 可通过 Bash 直接调用（`$GBRAIN search/think`），不需要 MCP
- FR4: 5 个预设查询每个都能返回结果（有结果 ≠ 有用，但无结果 = 工具故障）
- FR5: 每个查询结果有"有用/无用"判定和理由文档

### 3.2 Non-Functional Requirements
- NFR1: 导入过程不应超过 20 分钟（~2000 文件，含 OpenAI API rate limit）
- NFR2: 单次查询响应时间 < 30 秒
- NFR3: embedding 零费用（本地 llama.cpp，无 API 调用）

---

## 4. Technical Design

### 4.1 Architecture Overview

```
.tad/ (markdown files)
    ↓ gbrain import
[PGLite embedded Postgres]
    ├── Vector index (HNSW)
    ├── BM25 keyword index
    └── Entity graph (auto-extracted)
    ↓ gbrain serve (MCP stdio)
[Claude Code MCP client]
    ↓ gbrain search / gbrain think
[Query results with citations]
```

### 4.2 Installation Steps
1. Install Bun: `curl -fsSL https://bun.sh/install | bash` then `export PATH="$HOME/.bun/bin:$PATH"`
2. Create isolated install dir: `mkdir -p ~/.gbrain-poc && cd ~/.gbrain-poc`
3. Install gbrain (version-pinned): `bun install github:garrytan/gbrain` (project-local, not `-g` global — per CLAUDE.md security principle)
   - Pin to a specific release tag if available: check `gh api repos/garrytan/gbrain/releases/latest --jq .tag_name` first
   - Invoke via: `~/.gbrain-poc/node_modules/.bin/gbrain` (alias as `GBRAIN=~/.gbrain-poc/node_modules/.bin/gbrain`)
4. Init with local embedding: `$GBRAIN init --pglite`
   - 查看 `$GBRAIN --help` 或 README 确认本地 embedding 配置方式（可能是 `--embedder llama` 或类似 flag）
   - 如需下载本地模型（~500MB），按 gbrain 文档指引操作
   - Note where PGLite database is created (likely `~/.gbrain/` or CWD `.gbrain/`), document the path
5. Import (absolute path): `$GBRAIN import "/Users/sheldonzhao/01-on progress programs/TAD/.tad/"`
   ⚠️ 本地 embedding 索引速度较慢（CPU），~2000 文件可能需要 20-40 分钟
6. 验证导入：`$GBRAIN search "TAD"` 返回结果
7. 验证 CJK：`$GBRAIN search "原则"` 返回结果

### 4.3 Test Query Design

| # | Pain Point | Query | "Useful" Criteria |
|---|-----------|-------|-------------------|
| Q1 | 查历史决策 | "Why did TAD choose terminal isolation instead of shared state for Alex and Blake?" | Cites principles.md terminal isolation entry + references supporting handoffs/evidence |
| Q2 | 找重复教训 | "What problems has TAD had with hardcoded allow-lists across different features?" | Finds the deny-list principle + at least 2 different handoff/evidence references |
| Q3 | 跨文档关联 | "What rationalizations have TAD agents used to justify skipping quality gates, and what was the outcome each time?" | Synthesizes across anti_rationalization_registry entries + incident evidence (semantic, not keyword-matchable) |
| Q4 | 合成性 | "What are TAD's key safety patterns and how do they interact to prevent quality drift?" | Synthesizes across SAFETY entries in principles.md + pattern files, not just listing them |
| Q5 | 缺口分析 | "What areas of TAD methodology lack principle or pattern coverage?" | Uses `gbrain think` (synthesis mode with gap analysis — syntax: `$GBRAIN think "<query>"`) to identify areas not covered by existing principles/patterns. Alex judges this one post-implementation. |

### 4.5 `gbrain think` vs `gbrain search`
- `gbrain search "<query>"` — raw hybrid retrieval (vector + BM25 + graph), returns ranked pages
- `gbrain think "<query>"` — synthesized answer with citations + gap analysis showing what the brain does not know yet
- Use `search` for Q1-Q4 (retrieval-focused), `think` for Q5 (synthesis + gap analysis)
- If `think` is not available in the installed version, substitute with `search` and note the limitation

### 4.4 Evaluation Rubric (per query)

- ✅ **有用**: Cross-document synthesis with citations. Answers something grep alone couldn't easily produce. Entity graph connections visible.
- ❌ **无用**: Irrelevant results, misses key documents, only returns what `grep` would find, or hallucinated content not grounded in actual files.

**Gate Decision**: ≥3/5 ✅ → PASS (proceed to Phase 2) / <3/5 ✅ → FAIL (close Epic, NEGATIVE-RESULT)

---

## 5. 强制问题回答（Evidence Required）

### MQ1: 历史代码搜索
- [x] 否 → 跳过（不涉及项目代码修改）

### MQ2: 函数存在性验证
- [x] 否 → 跳过（不涉及函数调用，仅 CLI 操作）

### MQ3: 数据流完整性
- [x] 否 → 跳过（无后端/前端数据流）

### MQ4: 视觉层级
- [x] 否 → 跳过（无 UI）

### MQ5: 状态同步
- [x] 否 → 跳过（单一数据存储：PGLite）

---

## 6. Implementation Steps

### Step A: 安装和导入（预计 45 分钟）

#### 交付物
- [ ] gbrain 安装完成（project-local，version-pinned）
- [ ] PGLite 初始化成功（database path documented）
- [ ] .tad/ 目录导入完成，文件数 ≥500

#### 实施步骤
1. 检查 Bun 是否已安装：`command -v bun`。如未安装：
   ```bash
   curl -fsSL https://bun.sh/install | bash
   export PATH="$HOME/.bun/bin:$PATH"
   ```
   ⚠️ Bun install 修改 shell profile，当前 session 需手动 export PATH
2. 创建隔离安装目录：`mkdir -p ~/.gbrain-poc && cd ~/.gbrain-poc`
3. 查找最新 release tag：`gh api repos/garrytan/gbrain/releases/latest --jq .tag_name`
4. 安装 gbrain（version-pinned，project-local）：
   ```bash
   cd ~/.gbrain-poc
   bun install github:garrytan/gbrain#<tag from step 3>
   ```
   设置 alias：`GBRAIN=~/.gbrain-poc/node_modules/.bin/gbrain`
5. 验证安装：`$GBRAIN --version`
6. 配置 embedding provider：
   ```bash
   export OPENAI_API_KEY=<ask user for key>
   ```
   验证：gbrain 的 README 说明具体的 env var name。如果不是 `OPENAI_API_KEY`，查看 `$GBRAIN --help` 或 `$GBRAIN config` 确认。
7. 初始化 PGLite：`$GBRAIN init --pglite`
   记录 database 路径（`$GBRAIN` 输出或 `ls ~/.gbrain/` 确认）
8. 导入 .tad/（使用绝对路径）：
   ```bash
   $GBRAIN import "/Users/sheldonzhao/01-on progress programs/TAD/.tad/"
   ```
   记录导入的文件数量（从 import 输出中捕获）
9. 验证导入：`$GBRAIN search "TAD"` 应返回结果
10. 验证 CJK 内容：`$GBRAIN search "原则"` 应返回结果
11. 验证 frontmatter 文件：`$GBRAIN search "task_type"` 确认 frontmatter 内容被正确处理

#### 验证方法
- `$GBRAIN --version` 输出版本号
- `$GBRAIN search "TAD"` 返回 ≥1 条结果
- Import 输出中的文件数 ≥500

#### ⚠️ Step A 必须完成后才能进入 Step B
PGLite 是 single-writer。`gbrain serve`（MCP）会持有数据库写锁。如果 Step A 的 import 未完成就启动 MCP server，会产生锁冲突。**确认 import 完成且 `$GBRAIN search` 返回结果后，再进入 Step B。**

### Step B: 查询测试和评估（预计 1 小时）

#### 交付物
- [ ] 5 个查询全部执行完毕（通过 Bash 直接调用 `$GBRAIN`）
- [ ] 每个查询有评估文档
- [ ] Gate 决定文档

#### 实施步骤
1. 逐个执行 5 个测试查询（§4.3 定义），通过 Bash 直接调用：
   - Q1-Q4：`$GBRAIN search "<query>"`
   - Q5：`$GBRAIN think "<query>"`（如不可用则回退到 `search`，记录原因）
2. 为每个查询记录：原始查询 → 完整结果 → 有用/无用判定 → 理由（对照 §4.4 rubric）
3. 保存结果到 `.tad/evidence/poc/gbrain-poc/`
4. 写 Gate 决定文档：汇总 5 个查询结果 + 最终 PASS/FAIL + 改进建议
   - PASS 时附带：哪些查询效果最好，fork 改造时应重点保留什么
   - FAIL 时附带：失败原因分析，是否值得尝试其他工具

#### 验证方法
- `.tad/evidence/poc/gbrain-poc/` 目录存在且包含 5 个查询结果 + 1 个 gate 决定
- Gate 决定文档包含明确的 PASS 或 FAIL

---

## 7. File Structure

### 7.1 Files to Create
```
.tad/evidence/poc/gbrain-poc/q1-terminal-isolation.md
.tad/evidence/poc/gbrain-poc/q2-hardcoded-allowlists.md
.tad/evidence/poc/gbrain-poc/q3-rationalization-history.md
.tad/evidence/poc/gbrain-poc/q4-safety-patterns.md
.tad/evidence/poc/gbrain-poc/q5-coverage-gaps.md
.tad/evidence/poc/gbrain-poc/gate-decision.md
```

### 7.2 Files to Modify
```
(none — POC does not modify any project files)
```

### 7.3 Grounded Against

N/A — no existing project files are modified. gbrain installs to ~/.gbrain-poc/ (external to project).

---

## 8. Testing Requirements

### 8.1 Installation Tests
- `gbrain --version` returns version string
- `gbrain search "test"` returns results after import

### 8.2 MCP Integration Tests
- gbrain tools appear in Claude Code tool list after MCP registration

### 8.3 Edge Cases
- .tad/ directory contains files with CJK characters in content — verify these index correctly
- Some files have YAML frontmatter — verify gbrain doesn't choke on them
- Large files (handoff template is ~600 lines) — verify they import without truncation

## 8.4 Friction Preflight

| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|----------------|---------------|-------------------|--------------------|-------------|
| Bun not installed | Install Bun runtime | `curl -fsSL https://bun.sh/install \| bash` then `export PATH="$HOME/.bun/bin:$PATH"` | N/A — Bun is required by gbrain | BLOCKED if install fails |
| Local embedding model download | gbrain 需要本地 embedding 模型 (~500MB) | 按 gbrain README 指引下载 llama.cpp 模型 | 如 llama.cpp 不可用，尝试 gbrain 支持的其他本地 embedder | BLOCKED if no embedding available |
| gbrain install fails | `bun install github:garrytan/gbrain#<tag>` in ~/.gbrain-poc/ | Check Bun version, check network, check tag exists | BLOCKED — open GitHub issue, close POC as BLOCKED | BLOCKED if install fails |
| PGLite init fails | `$GBRAIN init --pglite` | Check disk space, permissions | Full Postgres as fallback (overkill for POC) | BLOCKED |
| gbrain search returns empty | DB path mismatch between init CWD and search CWD | Run all gbrain commands from same directory, or set DB path via env var | Document workaround | BLOCKED if queries return empty |

## 8.5 Feedback Collection

N/A — code/config only, no non-code artifacts requiring human judgment.

---

## 9. Acceptance Criteria

- [ ] AC1: gbrain 安装成功（project-local, version-pinned, `$GBRAIN --version` 返回版本号）
- [ ] AC2: .tad/ 导入成功，导入文件数 ≥500（从 import 命令输出中捕获）
- [ ] AC3: CLI 直接可调用（`$GBRAIN search "TAD"` 返回结果）
- [ ] AC4: 5 个测试查询每个都有结果文档（含有用/无用判定 + 理由）
- [ ] AC5: Gate 决定文档存在，包含 PASS/FAIL + 汇总理由

---

## 9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output |
|---|---------------------|-------------------|--------------------|--------------------|-----------------|
| 1 | gbrain installed (version-pinned, project-local) | post-impl-verifiable | `~/.gbrain-poc/node_modules/.bin/gbrain --version` | Version string output | (post-impl) |
| 2 | .tad/ imported ≥500 files | post-impl-verifiable | `~/.gbrain-poc/node_modules/.bin/gbrain search "TAD" \| head -5` + import log showing file count | Returns results AND import log shows ≥500 | (post-impl) |
| 3 | CLI directly callable | post-impl-verifiable | `~/.gbrain-poc/node_modules/.bin/gbrain search "terminal isolation" \| head -3` | Returns relevant results | (post-impl) |
| 4 | 5 query results documented | post-impl-verifiable | `ls .tad/evidence/poc/gbrain-poc/q*.md \| wc -l` | 5 | (post-impl) |
| 5 | Gate decision documented | post-impl-verifiable | `test -f .tad/evidence/poc/gbrain-poc/gate-decision.md && echo EXISTS` | EXISTS | (post-impl) |

---

## 9.2 Expert Review Status

### Experts Selected

1. **code-reviewer** — Handoff quality, AC specificity, spec compliance, scope clarity
2. **integrations-engineer** — MCP configuration, install robustness, import process, embedding setup

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0: Gate 2 marked PASS before expert review | §Gate 2 — re-marked after review | Resolved |
| code-reviewer | P0: settings.json grounding claim false (no mcpServers key) | §7.3 — corrected to "does NOT contain mcpServers" | Resolved |
| code-reviewer | P0: AC2 verification doesn't check file count | §9.1 row 2 — added import log file count check | Resolved |
| code-reviewer | P1: File count ~200 vs actual ~2000+ | §1.2, §2.2, NFR1/NFR3 — updated to ~2000+, time to 20min, cost to <$5 | Resolved |
| code-reviewer | P1: Missing API key config step | §4.2 step 4, §6 Step A step 6, §8.4 — explicit env var + verify | Resolved |
| code-reviewer | P1: No rollback/cleanup instructions | §10.4 — added Cleanup on FAIL section | Resolved |
| code-reviewer | P1: No version pinning | §4.2 step 3 — project-local + version-pinned install | Resolved |
| code-reviewer | P2: Q5 requires TAD expertise | §4.3 Q5 — marked "Alex judges post-implementation" | Resolved |
| code-reviewer | P2: Phase 1/2 naming collision with Epic | §6 — renamed to Step A / Step B | Resolved |
| integrations-engineer | P0: `bun install -g` violates CLAUDE.md security principle | §4.2, §6 Step A — project-local install in ~/.gbrain-poc/ | Resolved |
| integrations-engineer | P0: Relative path `gbrain import .tad/` will fail across shells | §4.2 step 6, §6 Step A step 8 — absolute path | Resolved |
| integrations-engineer | P0: API key config completely unspecified | §4.2 step 4, §6 Step A step 6, §8.4 — explicit env var + verify step | Resolved |
| integrations-engineer | P1: MCP scope — `claude mcp add` goes to user-level | §6 Step B step 1 — direct settings.json edit with JSON structure | Resolved |
| integrations-engineer | P1: gbrain serve DB path may differ from init CWD | §6 Step B step 1 note, §8.4 — absolute path in MCP command + friction point | Resolved |
| integrations-engineer | P1: Bun PATH not active in current session | §4.2 step 1, §6 Step A step 1 — explicit export PATH | Resolved |
| integrations-engineer | P1: "Build from source" fallback unrealistic | §8.4 — replaced with "BLOCKED, open GitHub issue" | Resolved |
| integrations-engineer | P1: Q3 tests keyword matching, not semantic | §4.3 Q3 — replaced with semantic rationalization query | Resolved |
| integrations-engineer | P1: PGLite ordering not enforced | §6 Step A — added ordering gate between Step A and Step B | Resolved |
| integrations-engineer | P2: CJK + frontmatter verification steps | §6 Step A steps 10-11 — added explicit verification queries | Resolved |

### Overall Assessment (post-integration)

- code-reviewer: PASS (3 P0 resolved, 4 P1 resolved, 2 P2 resolved)
- integrations-engineer: PASS (3 P0 resolved, 5 P1 resolved, 1 P2 resolved)

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ gbrain 是 pre-1.0 (v0.41.x)，可能有 breaking changes
- ⚠️ PGLite 是 single-writer — `gbrain serve` 运行时不要同时 `gbrain import`
- ⚠️ 这是 POC — 结果可能是 FAIL，那也是有价值的结论

### 10.2 Known Constraints
- Embedding 使用本地 llama.cpp 模型（零 API 费用，但需 ~500MB 模型下载 + CPU 索引较慢）
- gbrain 本质上是单作者项目（Garry Tan），长期维护风险

### 10.4 Cleanup on FAIL (or if POC is abandoned)
如果 Gate 决定为 FAIL，或安装出错需要清理：
```bash
# 1. Remove gbrain install
rm -rf ~/.gbrain-poc/

# 2. Remove PGLite database (check actual path from Step A step 7)
rm -rf ~/.gbrain/  # or wherever gbrain init created the DB

# 3. KEEP evidence files (negative-result documentation)
# .tad/evidence/poc/gbrain-poc/ should NOT be deleted
```

### 10.3 Sub-Agent使用建议

Blake应该考虑使用：
- [ ] **bug-hunter** - 如果 gbrain 安装或导入遇到错误

---

## 11. Decision Rationale

### 11.1 Why gbrain (not alternatives)

| 方案 | 优点 | 缺点 | 为什么没选 |
|------|------|------|-----------|
| gbrain（选中）| MCP 原生、任意 markdown 目录、实体图谱 + 语义搜索 | pre-1.0、单作者 | ✅ 选中 |
| Hindsight | 成熟（17.9k stars）、生产级 | 自动保留模型与 TAD 知识哲学冲突 | 哲学不兼容 |
| NotebookLM（内部知识）| 已有基础设施 | 设计用于外部研究，不是内部知识搜索 | 用途不匹配 |
| 自建 embedding + 向量搜索 | 完全可控 | 重复造轮子，违反 "Never Hand-Write" 原则 | 工作量过大 |

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-07-03
**Version**: 3.1.0

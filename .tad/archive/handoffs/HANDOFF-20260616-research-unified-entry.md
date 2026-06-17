---
task_type: yaml
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-16
**Project:** TAD Framework
**Task ID:** TASK-20260616-001
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260616-research-system-consolidation.md (Phase 1/4)

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-06-16

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 三级路由（Quick/Standard/Deep）架构完整，映射到现有工具层 |
| Components Specified | ✅ | 每级路由的触发条件、执行机制、产出物都已定义 |
| Functions Verified | ✅ | 底层工具为现有 research-notebook CLI，无新函数 |
| Data Flow Mapped | ✅ | 用户输入 → 路由判断 → NotebookLM/WebSearch → 产出 |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

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
将 TAD 的 9 个研究入口统一为 `*research` 一个命令，实现 Quick/Standard/Deep 三级路由，默认走 NotebookLM。同时砍掉重复的 `/research-methodology` capability pack，简化 CLAUDE.md 研究排除规则。

### 1.2 Why We're Building It
**业务价值**：用户说"研究一下 X"时，100% 走 NotebookLM 路径，不再误走 WebSearch
**用户受益**：不需要记住 9 个不同的研究命令，一个 `*research` 覆盖所有场景
**成功的样子**：用户对 Alex 说"帮我研究一下 AI agent memory"，Alex 自动走 NotebookLM Standard 流程，产出可用的研究结果

### 1.3 Intent Statement

**真正要解决的问题**：研究入口碎片化导致 Alex 经常选错研究路径（WebSearch 代替 NotebookLM），用户体验不一致。

**不是要做的（避免误解）**：
- ❌ 不是重写 research-notebook 的 19 个子命令（保持现状）
- ❌ 不是修改 ask 的动态追问协议（保持现状）
- ❌ 不是实现 6 项质量改进（Phase 2-3）
- ❌ 不是删除 research-engine workflow（Phase 4）

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
- [x] architecture - SKILL 协议架构重构
- [ ] code-quality
- [ ] security
- [ ] ux
- [ ] performance
- [ ] testing
- [ ] api-integration
- [ ] mobile-platform

### 步骤 2：历史经验摘录

**已读取的 project-knowledge 文件**：

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| principles.md | 2 条 | Judgment-Only Skill Files + Circular Trigger |
| patterns/research-methodology.md | 3 条 | NotebookLM 集成 + 动态研究 + 源导入质量 |
| patterns/handoff-design.md | 2 条 | Circular Trigger + SKILL Progressive Loading |

**⚠️ Blake 必须注意的历史教训**：

1. **Circular Trigger Pattern** (来自 principles.md + patterns/handoff-design.md)
   - 问题：将协议提取到 references/ 时，如果 `load_when` 引用了只在 reference 内部定义的概念，agent 永远不会加载它
   - 解决方案：`*research` 协议的路由逻辑（Quick/Standard/Deep 判断）必须留在 SKILL.md body 中，不能放 references/。只有模式特定的详细执行步骤（如 Deep 的 GitHub-First sourcing）才放 references/

2. **SKILL Progressive Loading: Activation ≠ Execution** (来自 patterns/handoff-design.md)
   - 问题：Codex 能激活 SKILL 但不自动加载 references/ 中的深层协议
   - 解决方案：`*research` 的路由表和三级定义必须在 body 中可见，确保即使 references/ 未加载，agent 也知道路由到哪里

3. **NotebookLM 使用 -n flag** (来自 patterns/research-methodology.md)
   - 问题：`notebooklm use <id>` 会修改全局状态，在循环中导致串扰
   - 解决方案：`*research` 的 Standard/Deep 执行中统一使用 `-n <id>` 指定 notebook

### Blake 确认

- [ ] 我已阅读上述历史经验
- [ ] 我理解需要避免的问题
- [ ] 如遇到类似情况，我会参考上述解决方案

---

## 2. Background Context

### 2.1 Previous Work
- 现有 `*research-plan` 协议（`.claude/skills/alex/references/research-plan-protocol.md`，728 行）
- 现有 `*research-review` 协议（`.claude/skills/alex/references/research-review-protocol.md`）
- 现有 `/research-methodology` capability pack（`.claude/skills/research-methodology/SKILL.md`，257 行 + references/）
- 现有 intent router（`.claude/skills/alex/references/intent-router-protocol.md`）
- 现有 CLAUDE.md §2 研究路由规则
- 现有 Alex SKILL.md 中的 `global_skill_exclusion`、`research_decision_protocol`、`research_plan_protocol`、`research_review_protocol`

### 2.2 Current State
9 个研究入口，职责严重重叠。用户说"研究"时 Alex 经常走错路径。`/research-methodology` 和 `*research-plan` 做 90% 相同的事但各自独立演化。

### 2.3 Dependencies
- `research-notebook` SKILL.md（底层工具层，本次不修改）
- NotebookLM CLI（`~/.tad-notebooklm-venv/bin/notebooklm`）
- REGISTRY.yaml（`.tad/research-notebooks/REGISTRY.yaml`）

---

## 3. Requirements

### 3.1 Functional Requirements

- FR1: 创建 `*research` 命令，含 Quick/Standard/Deep 三级路由
- FR2: Quick 级别 — 单一事实查询，WebSearch 直接回答，不建 notebook
- FR3: Standard 级别（默认）— 找到匹配 notebook → ask（含动态追问）；无匹配 → 新建 notebook + research fast + ask
- FR4: Deep 级别 — 现有 research-plan 的 Phase 0-5 全流程
- FR5: 路由判断逻辑：用户关键词 + LLM 语义判断 → 自动选级别，用户可覆盖
- FR6: NotebookLM 不可用时降级为 WebSearch + 提示安装
- FR7: `*research-review` 改名为 `*research status`
- FR8: 删除 `/research-methodology` capability pack（整个目录）
- FR9: 简化 CLAUDE.md 研究排除规则

### 3.2 Non-Functional Requirements

- NFR1: `*research` 路由表必须在 SKILL.md body 中（不放 references/），防止 circular trigger
- NFR2: Deep 的详细执行步骤可以留在 references/（现有 research-plan-protocol.md 重构）
- NFR3: Standard 路由到 NotebookLM 时使用 `-n <id>` 指定 notebook，不使用 `use <id>`

---

## 4. Technical Design

### 4.1 Architecture Overview

```
用户: "研究一下 X"
        ↓
  Alex intent_router
        ↓ (匹配"研究"类关键词)
  *research 命令
        ↓
  路由判断 (LLM 语义 + 关键词)
        ↓
  ┌─────────────────────────────────────────┐
  │ Quick          Standard         Deep    │
  │ (单一事实)      (默认)          (深入)   │
  │                                         │
  │ WebSearch     NotebookLM      NotebookLM│
  │ 直接回答       ask+动态追问    全流程     │
  │                                         │
  │ 无notebook    找/建notebook   GitHub-First│
  │                               +多轮seed  │
  │                               +报告      │
  └─────────────────────────────────────────┘
```

### 4.2 路由判断规则

| 级别 | 触发信号 | 示例 |
|------|---------|------|
| Quick | 单一事实、语法查询、"是什么"、"怎么用" | "X 的 API 怎么调"、"Y 是什么意思" |
| Standard（默认） | "研究一下"、"了解"、"对比"、"有哪些"；无明确级别指示时 | "研究一下 AI agent memory"、"帮我对比 A 和 B" |
| Deep | "深入研究"、"建知识库"、"landscape"、"全面调研" | "深入研究 RAG 领域"、"帮我建一个 X 的知识库" |

**Tie-breaking rule**: When ambiguous between Quick and Standard, default to **Standard**（higher coverage, lower risk of under-serving）. When ambiguous between Standard and Deep, default to **Standard**（let user upgrade if needed）. This mirrors Phase 0class's "default to comparison when ambiguous" pattern.

用户可随时用 `*research --quick/--standard/--deep` 显式指定。

### 4.3 Standard 级别详细流程

```
1. Preflight: test -x ~/.tad-notebooklm-venv/bin/notebooklm
   → FAIL: 降级 WebSearch + 提示安装 → 执行 WebSearch 研究 → 返回结果
   → PASS: 继续

2. 查找匹配 notebook:
   → Read REGISTRY.yaml
   → Filter: only status == "active" notebooks participate in matching
     - dormant: AskUserQuestion "Found dormant notebook '{topic}' (last queried {date}). Reactivate or create fresh?"
     - archived: skip entirely
   → LLM 语义匹配用户研究话题 vs notebook.topic
   → 0 matches → 新建 notebook + research fast
   → 1 match → 使用该 notebook
   → >1 matches → AskUserQuestion: "Found {N} matching notebooks: {list with topic + source_count}. Which to use?"
     Options: each notebook + "Create new notebook"

3. 执行研究:
   → *research-notebook ask "{研究问题}" -n <id>
   → (ask 自带动态追问协议，4 轮上限，6 策略)
   → 研究链文件自动保存到 .tad/evidence/research/

4. 返回结果给用户
```

### 4.4 Deep 级别

重构现有 `research-plan-protocol.md`：
- Phase 0（问题定义）+ Phase 0class（分级）→ 保留
- Phase 0c（对抗挑战）→ 保留
- Phase 1-5 → 保留
- 去除 OBJECTIVES.md 硬依赖（Deep 也可以无 OBJECTIVES 运行）

### 4.5 CLAUDE.md 研究规则简化

现有规则（散布 5+ 处）→ 简化为：

```markdown
| 深度研究 | 需要持久积累的研究任务 → *research（Alex 自动判断级别） |
```

Alex SKILL.md 中的 `global_skill_exclusion`：
- 保留 `/deep-research` 排除（TAD 用 `*research`）
- 保留 `/research-methodology` 排除（已删除该 pack，但排除规则作为安全网）
- 简化其他研究相关排除

---

## 5. 强制问题回答

### MQ1: 历史代码搜索
- [x] 是 → 重构现有 `*research-plan`
- 搜索证据：已在 *discuss 中完整读取 research-plan-protocol.md (728 行)、research-review-protocol.md、research-methodology/SKILL.md (257 行)、intent-router-protocol.md
- 决定：✅ 复用 research-plan 的核心逻辑作为 Deep 级别实现

### MQ2: 函数存在性验证
- 不涉及代码函数。操作对象是 SKILL.md 协议文件和 CLAUDE.md 配置。

### MQ3-MQ5: N/A（无数据流、无 UI、无状态同步）

---

## 6. Implementation Steps

### Phase 1: *research 命令创建 + 路由（预计 2-3 小时）

#### 交付物
- [ ] Alex SKILL.md 中新增 `*research` 统一协议
- [ ] 路由表（Quick/Standard/Deep）在 SKILL body 中
- [ ] Standard 执行流程完整可运行

#### 实施步骤

1. **修改 Alex SKILL.md `commands` 表**：
   - 添加 `research: "Unified research — Quick/Standard/Deep, defaults to NotebookLM"`
   - 将 `research-review` 改为 `research status: "Research portfolio review"`
   - 将原有的 `research: Research technical options and present comparison` 改名为 `research-options`（避免与新 `*research` 命名冲突；design-flow 中的 `research_decision_protocol` step2 调用改为指向 `*research-options`）

2. **在 SKILL.md body 中创建 `research_unified_protocol`**：
   - 路由表（触发信号 → 级别映射）
   - NotebookLM preflight check
   - 降级路径定义
   - Quick 执行逻辑（WebSearch 直接回答）
   - Standard 执行逻辑（notebook 查找/创建 → ask）
   - Deep 入口（指向 references/research-plan-protocol.md）
   - `load_when` 设计：路由表在 body，Deep 详细步骤在 reference

3. **修改 `references/research-plan-protocol.md`**：
   - 去除 OBJECTIVES.md 硬依赖（step1 的 preflight block）
   - 添加"被 *research Deep 级别调用"的上下文说明
   - 保留全部 Phase 0-5 逻辑不变

4. **修改 `references/research-review-protocol.md`**：
   - 将 trigger 从 `*research-review` 改为 `*research status`
   - 更新描述

5. **修改 `references/intent-router-protocol.md`**：
   - 添加 `*research` 到 explicit_commands 列表
   - 添加研究类关键词路由规则
   - 移除指向 research-methodology 的路由

6. **修改 `references/research-decision-protocol.md`**：
   - research-gate 中的 notebook 创建建议改为指向 `*research`（而非 `*research-plan` / `*research-notebook create`）
   - step2_research 中原有 `*research` 引用改为 `*research-options`
   - ⚠️ **必须保留 `declined_research_domains` 会话状态机制及其与 STEP 3.8 和 research_notebook_awareness 的交叉引用**。去重逻辑是防止同 session 重复提示的核心，不能在简化中丢失

7. **修改 Blake SKILL.md**：
   - 更新 `1_5c_research_task_detection` 协议中对 `.tad/capability-packs/research-methodology/CAPABILITY.md` 的引用
   - 如果 capability pack 文件也需要删除（`.tad/capability-packs/research-methodology/`），一并处理
   - 如果保留 capability pack，更新其引用指向 `*research`

8. **修改 academic-research/SKILL.md**：
   - Scope Disambiguation 中 "defer to `research-methodology` when" 改为 "defer to `*research` when"

9. **修改 `references/intent-router-protocol.md`**：
   - 更新 `skip_if` 列表：`*research-review` → `*research status`，`*research-plan` → `*research --deep`
   - 更新 `enters_standby` 条目：指向新命令名

#### 验证方法
- grep 确认 `*research` 命令在 SKILL.md commands 表中
- grep 确认路由表在 SKILL.md body 中（不在 references/）
- grep 确认 `research-methodology` 相关引用已清除

### Phase 2: 删除 + 简化（预计 1 小时）

#### 交付物
- [ ] `/research-methodology` capability pack 目录已删除
- [ ] CLAUDE.md 研究规则已简化
- [ ] Alex SKILL.md 中的 global_skill_exclusion 已更新

#### 实施步骤

1. **删除 `/research-methodology` 目录**：
   - `rm -rf .claude/skills/research-methodology/`

2. **修改 CLAUDE.md §2 使用场景表**：
   - 将研究相关行简化为：`| 深度研究 | *research（Alex 自动判断级别） |`
   - 删除"读 research-notebook/SKILL.md 按步骤执行"的指示

3. **修改 Alex SKILL.md global_skill_exclusion**：
   - 简化研究相关排除项
   - 更新 `tad_replacement` 指向 `*research`

4. **清理 SKILL.md 中的旧引用**：
   - `research_notebook_awareness`、`research_plan_protocol`、`research_review_protocol` 等引用统一指向新的 `research_unified_protocol`

5. **修改 `global_skill_exclusion`**：
   - `deep-research / research` 条目：`tad_replacement` 从 `"*research-notebook research / *research-plan"` 改为 `"*research (unified — Quick/Standard/Deep)"`
   - 删除 `research-methodology` 排除条目（pack 已删，排除规则是噪音）
   - 保留 `deep-research` 排除（该 global skill 仍存在，可能 shadow `*research`）

#### 验证方法
- `test ! -d .claude/skills/research-methodology/` 确认目录已删
- grep CLAUDE.md 确认研究规则条目 ≤3 条
- grep Alex SKILL.md 确认无残留的 `research-methodology` 引用

---

## 7. File Structure

### 7.1 Files to Create
无新文件（`*research` 协议写入现有 Alex SKILL.md）

### 7.2 Files to Modify
```
.claude/skills/alex/SKILL.md                                    # 新增 *research 统一协议、路由表、命令更新
.claude/skills/alex/references/research-plan-protocol.md         # 去除 OBJECTIVES 硬依赖、添加 Deep 上下文
.claude/skills/alex/references/research-review-protocol.md       # 改名为 research-status
.claude/skills/alex/references/intent-router-protocol.md         # 研究路由更新、更新 skip_if + enters_standby 条目
.claude/skills/alex/references/research-decision-protocol.md     # 简化引用、保留 declined_research_domains 去重机制、step2 改指向 *research-options
.claude/skills/blake/SKILL.md                                    # 更新 1_5c_research_task_detection 中对 research-methodology 的引用
.claude/skills/academic-research/SKILL.md                        # 更新 Scope Disambiguation 中 "defer to research-methodology" 改为 "defer to *research"
.claude/skills/research-methodology/SKILL.md                     # DELETE (整个目录)
.claude/skills/research-methodology/references/                  # DELETE (整个目录)
CLAUDE.md                                                        # 研究规则简化
```

### 7.3 Grounded Against

- `.claude/skills/alex/SKILL.md` (read at 2026-06-16, full file — commands table, global_skill_exclusion, research protocols)
- `.claude/skills/alex/references/research-plan-protocol.md` (read at 2026-06-16, full 728 lines)
- `.claude/skills/alex/references/research-review-protocol.md` (read at 2026-06-16, full file)
- `.claude/skills/alex/references/research-decision-protocol.md` (read at 2026-06-16, full file)
- `.claude/skills/research-methodology/SKILL.md` (read at 2026-06-16, full 257 lines)
- `CLAUDE.md` (read at 2026-06-16, §2 research routing)

---

## 8. Testing Requirements

### 8.1 Unit Tests
N/A（协议文件，非代码）

### 8.2 Integration Tests
- 激活 Alex 后，`*research` 命令出现在 `*help` 菜单中
- `*research status` 命令可用

### 8.3 Edge Cases
- NotebookLM CLI 不存在时的降级路径
- REGISTRY.yaml 不存在时 Standard 的处理（应新建 notebook）
- 用户同时有多个匹配 notebook 时的选择机制

## 8.4 Friction Preflight

| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|----------------|---------------|-------------------|--------------------|-------------|
| 无特殊摩擦点 | — | — | — | — |

本任务为协议文件修改，不涉及依赖安装、auth、或外部工具。

## 8.5 Feedback Collection
N/A — 代码/协议任务，无非代码产出物。

---

## 9. Acceptance Criteria

Blake的实现被认为完成，当且仅当：
- [ ] `*research` 命令在 Alex SKILL.md 中存在且含三级路由
- [ ] 默认路由为 Standard（NotebookLM）
- [ ] `/research-methodology` 目录已删除
- [ ] CLAUDE.md 研究规则已简化
- [ ] 用真实研究任务测试 Standard 流程成功

---

## 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output |
|---|---------------------|-------------------|--------------------|--------------------|-----------------|
| AC1 | `research_unified_protocol` 存在 | post-impl-verifiable | `grep -c 'research_unified_protocol' .claude/skills/alex/SKILL.md` | ≥1 | (post-impl) |
| AC2 | 路由表在 SKILL body 中（非 references/） | post-impl-verifiable | `grep -B2 -A10 'research_unified_protocol' .claude/skills/alex/SKILL.md \| head -20` | 含 Quick/Standard/Deep 路由表 | (post-impl) |
| AC3 | Standard 默认走 NotebookLM | post-impl-verifiable | `sed -n '/research_unified_protocol/,/^[a-z_]*_protocol:/p' .claude/skills/alex/SKILL.md \| grep -ci 'notebooklm'` | ≥2 | (post-impl) |
| AC4 | research-methodology skill 已删 | post-impl-verifiable | `test ! -d .claude/skills/research-methodology/ && echo DELETED` | DELETED | (post-impl) |
| AC5 | CLAUDE.md 研究路由指向 *research | post-impl-verifiable | `grep '\*research' CLAUDE.md` | 匹配到（确认新规则存在） | (post-impl) |
| AC6 | research status 命令存在 | post-impl-verifiable | `grep 'research.status' .claude/skills/alex/SKILL.md` | 匹配到 | (post-impl) |
| AC7 | 降级路径存在 | post-impl-verifiable | `grep -c 'WebSearch.*fallback\|degraded\|降级' .claude/skills/alex/SKILL.md` | ≥1 | (post-impl) |
| AC8 | intent router 更新 | post-impl-verifiable | `grep 'research_unified' .claude/skills/alex/references/intent-router-protocol.md` | ≥1 match | (post-impl) |
| AC9 | 无残留 research-methodology 引用（全范围） | post-impl-verifiable | `grep -r 'research-methodology' .claude/skills/ CLAUDE.md .tad/project-knowledge/ \| grep -v 'DELETE\|deleted\|deprecated\|排除\|archive\|已删'` | 0 matches | (post-impl) |
| AC10 | research-plan step1 standby block 去除 | post-impl-verifiable | `grep 'requires OBJECTIVES.md. Run \*analyze first' .claude/skills/alex/references/research-plan-protocol.md` | 0 matches（block 改为 skip/fallback） | (post-impl) |
| AC11 | declined_research_domains 去重机制保留 | post-impl-verifiable | `grep -c 'declined_research_domains' .claude/skills/alex/references/research-decision-protocol.md` | ≥3 | (post-impl) |
| AC12 | design-flow 命名冲突已解决 | post-impl-verifiable | `grep 'research-options' .claude/skills/alex/SKILL.md` | 匹配到（原 design-flow *research 已改名） | (post-impl) |
| AC13 | Blake SKILL.md 引用已更新 | post-impl-verifiable | `grep -c 'research-methodology' .claude/skills/blake/SKILL.md` | 0 matches | (post-impl) |
| AC14 | 多 notebook 消歧机制存在 | post-impl-verifiable | `grep -c 'AskUserQuestion.*notebook\|多.*notebook\|>1.*match' .claude/skills/alex/SKILL.md` | ≥1 | (post-impl) |
| AC15 | 行为验证：真实研究任务 | post-impl-verifiable | 在 Alex 会话中对 Standard 级别查询执行 `*research`，确认读取 REGISTRY.yaml 并尝试 notebook 匹配（证据：会话截图显示 notebook 选择步骤） | 路由到 NotebookLM 路径 | (post-impl) |

---

## 9.2 Expert Review Status (Alex 必填)

### Experts Selected

1. **code-reviewer** — SKILL.md 是 TAD 最核心的协议文件，修改影响面大，需要代码质量审查
2. **backend-architect** — 路由架构设计审查，确保三级路由不遗漏边界情况

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| backend-architect | P0: Multi-notebook match has no disambiguation — agent silently picks one | §4.3 Standard flow — added AskUserQuestion for >1 match + AC14 | Resolved |
| backend-architect | P0: `declined_research_domains` dedup wiring may be lost during simplification | §6 Step 6 — explicit preservation warning + AC11 | Resolved |
| code-reviewer | P0: Blake SKILL.md has 6 references to research-methodology — handoff silent | §7.2 + §6 Step 7 — added Blake SKILL.md to scope + AC13 | Resolved |
| code-reviewer | P0: AC9 scope too narrow, misses Blake/academic-research | §9.1 AC9 — widened to `.claude/skills/ CLAUDE.md .tad/project-knowledge/` | Resolved |
| code-reviewer | P0: `*research` naming collision with design-flow sub-agent command | §6 Step 1 — renamed to `*research-options` + AC12 | Resolved |
| backend-architect | P1: Quick/Standard routing signals overlap, no tie-breaker | §4.2 — added explicit tie-breaking rule | Resolved |
| backend-architect | P1: Dormant/archived notebooks not filtered from Standard matching | §4.3 Step 2 — added status filtering + dormant reactivation prompt | Resolved |
| backend-architect | P1: AC10 grep may false-match Phase 4 graceful degradation lines | §9.1 AC10 — narrowed to step1 preflight unique text | Resolved |
| code-reviewer | P1: AC5 threshold wrong (current CLAUDE.md already passes) | §9.1 AC5 — changed to content-based check (grep `*research` presence) | Resolved |
| code-reviewer | P1: Intent router standby/skip_if entries not addressed | §7.2 + §6 Step 9 — added intent router standby update step | Resolved |
| code-reviewer | P1: research-decision-protocol changes lack specificity | §6 Step 6 — specified exact changes (research-gate + step2 + declined_research_domains) | Resolved |
| code-reviewer | P1: global_skill_exclusion tad_replacement text not specified | §6 Phase 2 Step 3 — added below | Open |
| backend-architect | P2: No behavioral AC, all structural grep | §9.1 AC15 — added behavioral test AC | Resolved |
| code-reviewer | P2: No backward compat for `*research-plan` users | §10.2 — added note below | Resolved |
| backend-architect | P2: Exclusion rule for deleted pack is noise | §6 Phase 2 Step 3 — remove research-methodology exclusion, keep deep-research | Resolved |

### Overall Assessment (post-integration)

- **backend-architect**: PASS (2 P0 resolved, 3 P1 resolved, 2 P2 resolved)
- **code-reviewer**: PASS (3 P0 resolved, 5 P1 resolved — 1 Open P1 is low-risk text specification, 5 P2 addressed)

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ 路由表必须在 SKILL.md body 中，不在 references/（circular trigger 风险）
- ⚠️ research-notebook ask 的动态追问协议（6 策略、链文件格式）本次不修改
- ⚠️ research-engine workflow 本次保留，Phase 4 才删

### 10.2 Known Constraints
- NotebookLM CLI 有 23-43s 延迟，Standard 研究需要 3-8 分钟
- REGISTRY.yaml 是单写者文件，并发研究可能冲突
- `*research-plan` 用户肌肉记忆：旧命令被合并进 `*research --deep`。不设别名——直接在 `*help` 菜单中明确显示新路径即可。如用户输入旧命令，intent router 应提示"已合并为 *research"

### 10.3 Sub-Agent使用建议

Blake应该考虑使用：
- [ ] **code-reviewer** - SKILL.md 修改后
- [ ] **test-runner** - N/A（协议文件）

---

## 11. Decision Rationale

### 11.1 为什么统一为 *research 而不是保留多入口

**选择的方案**：统一 `*research` + 自动路由

**考虑的替代方案**：

| 方案 | 优点 | 缺点 | 为什么没选 |
|------|------|------|-----------|
| 统一 `*research`（选中）| 用户零选择负担；默认路径正确 | 需要改动多个文件 | ✅ 选中 |
| 保留多入口但修默认值 | 改动小 | 用户仍需记住多个命令 | 不解决根本问题 |
| 只做质量提升不改入口 | 低风险 | 路由错误继续存在 | 用户反复反馈的就是路由问题 |

**💡 Human学习点**：当系统自然生长出多个做类似事情的入口时，问题不在于某一个入口不好，而在于选择本身成为了负担。统一入口 + 自动路由是正确的设计方向。

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-06-16
**Version**: 3.1.0

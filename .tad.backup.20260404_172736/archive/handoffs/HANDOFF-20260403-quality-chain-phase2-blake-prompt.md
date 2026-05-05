---
task_type: code
e2e_required: no
research_required: no
---

# Handoff: 质量链修复 Phase 2 — Blake Prompt 层恢复

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-04-03
**Project:** TAD
**Task ID:** TASK-20260403-010
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260403-quality-chain-full-repair.md (Phase 2/4)

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-04-03 (pending expert review)

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 单文件插入，位置明确 |
| Components Specified | ✅ | 单文件修改，变更点明确 |
| Functions Verified | ✅ | tad-blake.md 路径已确认 |
| Data Flow Mapped | ✅ | frontmatter task_type → Blake 分支执行 |

**Expert Review**: code-reviewer CONDITIONAL PASS (0 P0, 2 P1 fixed)

**Gate 2 结果**: ✅ PASS

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 1.1 What We're Building
恢复并强化 Blake SKILL.md 中被 v2.7 精简删除的质量执行规则。

### 1.2 Why We're Building It
**根因**：v2.7 将约束性规则（防 LLM 走捷径的护栏）误归类为"机械性指令"删除。结果 Blake 跳过 Ralph Loop、E2E、研究、Layer 2 审查。Prompt 强制是防止 LLM 自我合理化的唯一手段 — Hook 检测不到过程。

### 1.3 Intent Statement

**真正要解决的问题**：Blake SKILL.md 缺少过程性执行规则，LLM 在 Hook 覆盖不到的地方恢复"能省则省"的默认行为。

**不是要做的**：
- ❌ 不是恢复到 v2.6 的 1052 行 — 只恢复约束性规则，不恢复已被 Hook/config 覆盖的机械性内容
- ❌ 不是修改 Alex SKILL.md — 那是 Phase 3
- ❌ 不是修改 Hook 脚本 — 那是 Phase 4

---

## 📚 Project Knowledge（Blake 必读）

| 文件 | 关键提醒 |
|------|----------|
| architecture.md | "Judgment-Only 76% Reduction" — 约束性规则被误删是本次修复根因 |
| architecture.md | "Hook-Native Mechanism Validation" — Hook 管不了过程，Prompt 必须管 |

---

## 2. Background Context

### 2.1 Current State of Blake SKILL.md

当前 `mandatory` 节（约第 796-809 行）已有 12 条规则，但都是**一句话声明**，缺少：
- 具体执行步骤（做什么、按什么顺序）
- 任务类型分支（代码任务 vs YAML 任务 vs 研究任务的 Layer 1 不同）
- Anti-rationalization 注释（防止 LLM 找理由跳过）
- 与 Phase 1 新增 frontmatter 字段的集成

### 2.2 What Was Lost in v2.7
从 v2.6 Blake SKILL.md (1047 行) 中删除的关键内容：
- 详细 Ralph Loop 执行步骤 (~150 行)
- Completion protocol 详细步骤 (~100 行)
- 完整 Mandatory Rules 列表 (~50 行)
- Anti-rationalization 注释 (~20 行)

---

## 3. Requirements

### 3.1 Functional Requirements

**FR1: 新增 EXECUTION CHECKLIST 节**

在 Blake SKILL.md 的 `mandatory:` 节之后、`domain_pack_trace_protocol:` 节之前，新增以下内容。标注"不可精简"。

```yaml
# ═══════════════════════════════════════
# ⚠️ EXECUTION CHECKLIST — 不可精简
# 每次执行 *develop 前读一遍。跳过任何一条 = VIOLATION。
# v2.8.1: 从 v2.7 精简中恢复。这些是约束性规则，不是机械性指令。
# ═══════════════════════════════════════

execution_checklist:
  description: "每个 handoff 必须按此清单检查。这不是建议，是强制要求。"

  before_start:
    - "读完 handoff 全部内容 — 包括所有 AC 和 BLOCKING 要求"
    - "读取 handoff YAML frontmatter — 确认 task_type / e2e_required / research_required"
    - "确认所有 AC 都有实现计划（不能'先做完再说'）"
    - "如果某个 AC 你认为不适用 → PAUSE → 问人确认 → 不能自己决定跳过"
    # ⚠️ ANTI-RATIONALIZATION: "这个 AC 明显是模板遗留，实际不需要"
    # → AC 是 Alex 经 Socratic Inquiry 和专家审查确定的。Blake 没有删除 AC 的权力。

  during_development:
    task_type_branching:
      description: "根据 handoff frontmatter 的 task_type 字段选择 Layer 1 检查方式"
      code: "build + lint + tsc + test（全部 PASS 才继续）"
      yaml: "python3 -c 'import yaml; yaml.safe_load(open(f))' + 结构验证 + 编造=FAIL 检查"
      research: "WebSearch 全部执行 + ≥3 来源 + 产出研究文件到指定路径"
      e2e: "测试脚本执行 + evidence 文件产出到 .tad/evidence/"
      mixed: "按子任务分别适用上述检查"
      # ⚠️ ANTI-RATIONALIZATION: "这个任务虽然标了 research 但我已经知道答案了"
      # → task_type 是 Alex 设计时决策。Blake 执行时不判断。标了 research 就必须搜索。

    layer1_self_check:
      - "按 task_type_branching 执行对应检查"
      - "全部 PASS 才进 Layer 2 — 一项 FAIL 就修复重跑"
      # ⚠️ ANTI-RATIONALIZATION: "只有 lint warning 不是 error，可以跳过"
      # → Layer 1 标准是全部 PASS。Warning 也要修。

    layer2_expert_review:
      - "Group 0: spec-compliance-reviewer（AC 全满足）"
      - "Group 1: code-reviewer（P0=0, P1=0）"
      - "Group 2: test-runner + security-auditor + performance-optimizer（按 trigger 规则）"
      - "Expert 说 PASS 才算完成 — 不是 Blake 自己判断"
      # ⚠️ ANTI-RATIONALIZATION: "已经跑过 npm test 全部通过，再调 subagent 是重复劳动"
      # → Layer 1 的 npm test 只检查是否通过。test-runner subagent 额外检查覆盖率和测试质量。两者目的不同。

    research_compliance:
      - "如果 handoff frontmatter research_required: yes → 必须执行搜索"
      - "搜索词必须全部执行 → Search Log 证明"
      - "不能用 LLM 知识替代搜索（'我已经知道了'不是跳过研究的理由）"
      - "研究产出文件必须写到 handoff 指定路径"
      # ⚠️ ANTI-RATIONALIZATION: "这些工具我都用过，不需要再搜索了"
      # → 研究的目的不只是获取信息，还有发现新工具和验证假设。LLM 训练数据有截止日期。

    e2e_compliance:
      - "如果 handoff frontmatter e2e_required: yes → 必须执行 E2E 测试"
      - "E2E 结果必须写入 .tad/evidence/ — Gate 3 Hook 将检查"
      - "不能自己决定'太简单不需要 E2E' — 这个决策已由 Alex 做出"
      # ⚠️ ANTI-RATIONALIZATION: "E2E 环境没配好，先跳过提交再说"
      # → 环境问题 = PAUSE 问人，不是跳过。

  after_development:
    - "*complete 创建 COMPLETION report — 必须使用更新后的模板（含 Knowledge Assessment + Evidence Checklist）"
    - "Evidence Checklist 中 required 项全部勾选 — 缺一项 Gate 3 不可通过"
    - "Knowledge Assessment 必须回答 Yes/No — 留空 = VIOLATION"
    - "/gate 3 正式质量检查 — 不能自己说 'Gate 3 Passed'"
    - "生成 Alex 消息"
    # ⚠️ ANTI-RATIONALIZATION: "代码写完且通过测试了，Completion Report 只是文书工作"
    # → Report 迫使 Blake 显式对比 handoff 计划 vs 实际交付。没有 Report = 没有偏差检测。

  absolute_forbidden:
    - "❌ 不能自己决定跳过任何 handoff AC（必须问人）"
    - "❌ 不能为了速度跳过研究、E2E、Layer 2"
    - "❌ 不能在 agent prompt 里写 'skip Phase X'"
    - "❌ 不能在没有 evidence 的情况下声称 Gate 3 Passed"
    - "❌ 不能编造 GitHub URL 或仓库名"
    - "❌ 不能忽略 handoff frontmatter 的 task_type / e2e_required / research_required"
```

**FR2: 在 mandatory 节补充 frontmatter 引用**

在现有 `mandatory:` 节末尾追加：

```yaml
  frontmatter_compliance: "MUST read and obey handoff YAML frontmatter (task_type, e2e_required, research_required) — these are Alex's design-time decisions, not Blake's runtime judgment"
```

**FR3: 在 develop_command 的 step 1_5_context_refresh 中追加 frontmatter 读取**

在现有 context refresh 步骤中，追加一步：

```yaml
          (append as next numbered step after existing steps):
             Read handoff YAML frontmatter (task_type, e2e_required, research_required)
             Announce: "Frontmatter: task_type={value}, e2e_required={value}, research_required={value}"
             Store these values — execution_checklist.during_development.task_type_branching will reference them
```

### 3.2 Non-Functional Requirements
- NFR1: 新增内容插入位置不能破坏现有 YAML 结构
- NFR2: EXECUTION CHECKLIST 标注"不可精简" — 未来 SKILL.md 精简时保留此区域
- NFR3: Anti-rationalization 注释使用 `# ⚠️ ANTI-RATIONALIZATION:` 前缀（与现有 v2.8 格式一致）

---

## 7. File Structure

### 7.1 Files to Modify
```
.claude/commands/tad-blake.md  # 新增 EXECUTION CHECKLIST + mandatory 补充 + context refresh 补充
```

---

## 9. Acceptance Criteria

- [ ] **AC1**: tad-blake.md 有 EXECUTION CHECKLIST 节，标注"不可精简"
- [ ] **AC2**: Checklist 覆盖 before_start / during_development / after_development / absolute_forbidden 四个阶段
- [ ] **AC3**: during_development 有 task_type_branching（code/yaml/research/e2e/mixed 五种分支）
- [ ] **AC4**: 至少 6 条 ANTI-RATIONALIZATION 注释（当前 handoff 提供了 7 条）
- [ ] **AC5**: mandatory 节有 frontmatter_compliance 规则
- [ ] **AC6**: develop_command step 1_5 有 frontmatter 读取步骤
- [ ] **AC7**: 现有 YAML 结构不被破坏
- [ ] **AC8 (BLOCKING)**: 必须走 Ralph Loop + Gate 3

### 9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Verification Method | Expected Evidence |
|---|---------------------|--------------------|--------------------|
| 1 | EXECUTION CHECKLIST 存在 | `grep 'EXECUTION CHECKLIST' .claude/commands/tad-blake.md` | 1+ matches |
| 2 | 不可精简标注 | `grep '不可精简' .claude/commands/tad-blake.md` | 1+ matches |
| 3 | 四阶段覆盖 | `grep 'before_start\|during_development\|after_development\|absolute_forbidden' .claude/commands/tad-blake.md` | 4 matches |
| 4 | task_type 分支 | `grep 'task_type_branching' .claude/commands/tad-blake.md` | 1+ matches |
| 5 | Anti-rationalization | `grep -c 'ANTI-RATIONALIZATION' .claude/commands/tad-blake.md` | ≥6 (现有 2 + 新增 ≥6) |
| 6 | frontmatter_compliance | `grep 'frontmatter_compliance' .claude/commands/tad-blake.md` | 1 match |
| 7 | frontmatter 读取 | `grep 'frontmatter' .claude/commands/tad-blake.md` | 3+ matches |

---

## 10. Important Notes

- ⚠️ EXECUTION CHECKLIST 与 Phase 3 (Alex SKILL.md) 并行开发 — 无文件冲突
- ⚠️ 新增内容是约束性规则，标注"不可精简"防止未来再被误删
- ⚠️ task_type_branching 引用 Phase 1 定义的 frontmatter 字段

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-04-03
**Version**: 3.1.0

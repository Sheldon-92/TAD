---
task_type: code
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
**Date:** 2026-06-08
**Project:** TAD Framework
**Task ID:** TASK-20260608-005
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260608-skill-progressive-loading.md (Phase 2/3)

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Phase 1 spike 验证了"移动不删除"模式 |
| Components Specified | ✅ | 18 个协议逐个列出，提取顺序（从底到顶）明确 |
| Functions Verified | ✅ | grep 定位每个协议，reference stub 格式已有 10 个先例 |
| Data Flow Mapped | ✅ | 同 Phase 1：body 协议 → reference stub + references/ 文件 |

**Gate 2 结果**: ✅ PASS

---

## 1. Task Overview

**目标**: 将 Alex SKILL.md body 中剩余 18 个内联协议全部提取到 references/，body 从 5361 行降到 ≤1500 行。

**方法**: 与 Phase 1 spike 完全相同——复制协议内容到 references/，原位替换为 4 行 reference stub。**从文件底部向顶部**提取（避免行号偏移）。

**⚠️ 安全基线**: body+references 安全关键词总计 = **142**（Phase 1 验证后数值）

---

## 2. Extraction List (从底到顶)

按在文件中的位置**从底到顶**排列。这样每次提取不影响后续协议的行号。

| # | Protocol | ~行数 | Reference 文件名 |
|---|----------|------|-----------------|
| 1 | dream_protocol | 421 | dream-protocol.md |
| 2 | sync_list_protocol + sync_add_protocol | 38+38 | sync-list-protocol.md, sync-add-protocol.md |
| 3 | sync_protocol | 230 | sync-protocol.md |
| 4 | publish_protocol | 137 | publish-protocol.md |
| 5 | evolve_protocol | 428 | evolve-protocol.md |
| 6 | optimize_protocol | 288 | optimize-protocol.md |
| 7 | cancel_protocol | 368 | cancel-protocol.md |
| 8 | skillify_command_protocol | 47 | skillify-command-protocol.md |
| 9 | workflow_completion_trigger | ~30 | workflow-completion-trigger.md |
| 10 | acceptance_protocol | 383 | acceptance-protocol.md |
| 10b | accept_command | 248 | accept-command.md |
| 11 | yolo_execution_protocol | 175 | yolo-execution-protocol.md |
| 12 | design_protocol | 305 | design-protocol.md |
| 13 | research_decision_protocol | 165 | research-decision-protocol.md |
| 14 | socratic_inquiry_protocol | 167 | socratic-inquiry-protocol.md |
| 15 | adaptive_complexity_protocol | 221 | adaptive-complexity-protocol.md |
| 16 | experiment_path_protocol | 110 | experiment-path-protocol.md |
| 17 | express_path_protocol | 88 | express-path-protocol.md |
| 18 | research_plan_protocol | 724 | research-plan-protocol.md |

**总计**: ~4908 行提取 → body 5361 - 4908 + (19×4 stubs) = **~529 行**

---

## 3. Technical Design

### 3.1 每个协议的提取步骤（与 Phase 1 一致）

```
For each protocol (bottom to top):
  1. 用 grep -n 定位协议起始行：grep -n '^{protocol_name}:' SKILL.md
  2. 定位结束行：下一个同级 key 或 section header 的前一行
  3. 复制该范围到 references/{filename}.md，加来源注释头：
     # {Protocol Name} (extracted from SKILL.md for progressive loading)
     # Source: .claude/skills/alex/SKILL.md
     # Extracted: 2026-06-08 (EPIC-20260608-skill-progressive-loading Phase 2)
  4. 替换原位为 4 行 stub：
     {protocol_name}:
       # Extracted for progressive loading — full protocol in the reference below.
       reference: ".claude/skills/alex/references/{filename}.md"
       load_when: "When {trigger}, Read the reference and follow it verbatim."
```

### 3.2 load_when 触发条件表

| Protocol | load_when |
|----------|----------|
| research_plan_protocol | "*research-plan is invoked" |
| express_path_protocol | "*express is entered via intent_router step4" |
| experiment_path_protocol | "*experiment is entered via intent_router step4" |
| adaptive_complexity_protocol | "User describes a task and adaptive complexity assessment begins" |
| socratic_inquiry_protocol | "Socratic Inquiry begins after adaptive_complexity assessment" |
| research_decision_protocol | "Research & Decision Protocol begins after Socratic Inquiry" |
| design_protocol | "*design workflow is entered" |
| yolo_execution_protocol | "YOLO or semi-auto mode is selected in step7_execution_mode" |
| acceptance_protocol | "*review or *accept is invoked" |
| workflow_completion_trigger | "Workflow tool returns with agent_count >= 3" |
| skillify_command_protocol | "*skillify is invoked" |
| cancel_protocol | "*cancel is invoked" |
| optimize_protocol | "*optimize is invoked" |
| evolve_protocol | "*evolve is invoked" |
| publish_protocol | "*publish is invoked" |
| sync_protocol | "*sync is invoked" |
| sync_add_protocol | "*sync-add is invoked" |
| sync_list_protocol | "*sync-list is invoked" |
| dream_protocol | "*dream is invoked" |

### 3.3 Body 中必须保留的内容（不提取）

以下内容留在 body 中——它们是"每次激活都跑的"或安全关键：

- YAML frontmatter (constraints)
- 4-step Activation Protocol (STEP 1-4)
- global_skill_exclusion
- commands 表
- exit_protocol (~14 行，太小不值得提取)
- test_review_protocol (~89 行——保留还是提取由 Blake 判断，如果提取后 body 仍 ≤1500 则保留)
- intent_router_protocol **核心路由逻辑**（step1-step4 + standby + path_transitions）
- subagent_shortcuts
- my_tasks / my_templates / my_gates / release_duties
- anti_rationalization_registry (**MUST stay** — 安全审计 grep 目标)
- forbidden actions
- interaction rules / success_patterns
- on_start greeting
- knowledge_bootstrap / project_context_update / next_md_rules
- mandatory_review (Gate 4 v2 checklist)
- triple_question_draft_rule
- 所有 `forbidden_implementations` 块如果它们在被提取协议之外独立存在
- research_citation_in_handoff (~17 行) — P0-2 fix: 小节，留 body
- notebook_consolidation_suggestion (~24 行) — P0-2 fix: 小节，留 body
- playground_reference (~21 行) — P1 fix: 小节，留 body

### 3.4 intent_router_protocol 特殊处理

intent_router_protocol (268 行) 比较特殊——它包含 step4_5 (Pack Awareness Scan) 是每次激活后都可能运行的。

**决策**: 提取 intent_router_protocol 到 references/，但保留一个**加强版 stub**（~20 行而非 4 行）。

**加强版 stub 内容（Blake 直接使用）**:

```yaml
intent_router_protocol:
  description: "Detect user intent and route to appropriate path before any other processing"
  trigger: "User describes a task or need (after adaptive_complexity_protocol)"
  blocking: true

  # Core routing — explicit commands bypass detection
  explicit_commands: ["*bug", "*discuss", "*idea", "*learn", "*express", "*experiment", "*analyze"]
  idle_patterns_zh: ["谢谢", "ok", "好的", "收到", "明白了"]
  idle_patterns_en: ["thanks", "ok", "got it", "sure", "noted"]

  route_targets:
    bug: bug_path_protocol
    discuss: discuss_path_protocol
    idea: idea_path_protocol
    learn: learn_path_protocol
    express: express_path_protocol
    experiment: experiment_path_protocol
    analyze: adaptive_complexity_protocol

  # Full detection logic (step2 signal analysis, step3 user confirmation, step4_5 pack scan)
  # in the reference file below.
  reference: ".claude/skills/alex/references/intent-router-protocol.md"
  load_when: "When user input is ambiguous (not an explicit command or idle pattern), Read the reference for full signal detection + AskUserQuestion confirmation flow."
```

这样模型在激活后能快速路由：显式命令直接跳转，idle 直接响应，只有歧义输入才需要读 reference。

### 3.5 安全验证（每批次）

建议每 5-6 个协议提取后做一次中间验证：

```bash
body=$(grep -c 'MUST\|MANDATORY\|VIOLATION\|BLOCKING\|forbidden' .claude/skills/alex/SKILL.md)
refs=$(cat .claude/skills/alex/references/*.md | grep -c 'MUST\|MANDATORY\|VIOLATION\|BLOCKING\|forbidden')
echo "Safety: body=$body refs=$refs total=$((body+refs)) (baseline=142)"
```

如果中间验证发现 total < 142 → 停下来排查。

---

## 5. Acceptance Criteria

### 9.1 Spec Compliance Checklist

| AC# | Description | Verification Method | Expected Evidence |
|-----|-------------|--------------------|--------------------|
| AC1 | Body ≤1500 行 | `wc -l < .claude/skills/alex/SKILL.md` | ≤1500 |
| AC2 | 安全计数 ≥142 | `{ cat .claude/skills/alex/SKILL.md .claude/skills/alex/references/*.md; } \| grep -c 'MUST\|MANDATORY\|VIOLATION\|BLOCKING\|forbidden'` | ≥142 |
| AC3 | 18 个新 reference 文件存在 | `ls .claude/skills/alex/references/*.md \| wc -l` | ≥28 (10 旧 + 18 新) |
| AC4 | anti_rationalization_registry 在 body | `grep -c 'anti_rationalization_registry' .claude/skills/alex/SKILL.md` | ≥1 |
| AC5 | 每个 stub 有 reference + load_when | `grep -c 'load_when:' .claude/skills/alex/SKILL.md` | ≥28 (10 旧 + 18 新) |
| AC6 | Claude Code /alex 正常 | Gate 4 验证 | *help 显示 + 至少 1 个 *mode 可用 |

---

## 6. Implementation Steps

**⚠️ 总原则: 从文件底部向顶部提取，避免行号偏移。**

### Batch 1: 文件底部 (#1-6, ~1340 行)
dream_protocol → sync_list + sync_add → sync_protocol → publish_protocol → evolve_protocol → optimize_protocol

中间安全验证。

### Batch 2: 中部 (#7-12, ~1010 行)
cancel_protocol → skillify_command_protocol → workflow_completion_trigger → acceptance_protocol → yolo_execution_protocol → design_protocol

中间安全验证。

### Batch 3: 顶部 (#13-18, ~1475 行)
research_decision_protocol → socratic_inquiry_protocol → adaptive_complexity_protocol → experiment_path_protocol → express_path_protocol → research_plan_protocol

最终安全验证 + intent_router_protocol 特殊处理 (§3.4)。

**Grounded Against**:
- .claude/skills/alex/SKILL.md (grep 定位所有协议, read at 2026-06-08)
- 安全基线: 142 (Phase 1 验证值)
- Phase 1 spike 模式: reference stub 4 行格式 (commit 96e02b9)

---

## 7. Files to Modify / Create

| File | Action |
|------|--------|
| `.claude/skills/alex/SKILL.md` | MODIFY — 18 个协议替换为 stub |
| `.claude/skills/alex/references/` 下 18 个 .md 文件 | CREATE |

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训
- **Judgment-Only Skill Files** (principles.md): 约束规则 (MUST/VIOLATION/forbidden) 不能在精简时丢失
- **v2.7 质量链失效**: 上次精简丢了 forbidden_actions → 本次"移动不删除" + grep 计数硬性 gate
- Phase 1 spike 验证：142=142 精确匹配——证明模式安全

---

## 9.2 Expert Review Status

| Expert | Focus | Result | Key Findings |
|--------|-------|--------|-------------|
| code-reviewer | 提取顺序、intent_router stub、安全验证 | CONDITIONAL PASS | P1: intent_router stub 未给出具体内容（已修复：§3.4 提供 verbatim stub） |
| backend-architect | 遗漏检测、行数验算 | CONDITIONAL PASS | P0-1: accept_command 248 行遗漏（已加入提取表 #10b）、P0-2: 3 个小节未归类（已加入 §3.3 keep） |

---

## 10. Important Notes

### 10.1 这是 Phase 1 spike 的规模化执行
操作模式与 Phase 1 完全一致。唯一新增：intent_router_protocol 的加强版 stub (§3.4)。

### 10.2 如果中间安全验证失败
立即停止，git stash 保存进度，排查哪个提取丢了安全关键词。不要等全部做完再验证。

### 10.3 test_review_protocol 判断
test_review_protocol (~89 行) 较小。如果提取后 body 已 ≤1500 行，可以保留不提取。如果差一点点，再提取它。Blake 自行判断。

---

## 11. Decision Summary

| # | Decision | Chosen | Rationale |
|---|----------|--------|-----------|
| 1 | 提取顺序 | 从底到顶 | 避免行号偏移，每次 grep 定位准确 |
| 2 | intent_router 处理 | 加强版 stub (~20行) | 路由逻辑每次激活都用，完整版太大但不能只留 4 行 |
| 3 | 批次验证 | 每 6 个一次中间检查 | 早发现问题，减少回滚范围 |

---

## Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/skill-slim-phase2/spec-compliance.md
completion:
  - .tad/active/handoffs/COMPLETION-20260608-skill-slim-phase2.md
```

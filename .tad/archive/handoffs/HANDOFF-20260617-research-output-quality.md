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
**Date:** 2026-06-17
**Project:** TAD Framework
**Task ID:** TASK-20260617-002
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260616-research-system-consolidation.md (Phase 3/4)

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-06-17

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Q4 决策简报 + Q5 轻量验证 + Q6 闭环反馈的插入点和机制明确 |
| Components Specified | ✅ | 模板结构、验证步骤、反馈循环都有具体设计 |
| Functions Verified | ✅ | 底层工具为 WebSearch（Q5）和现有 ask CLI（Q6） |
| Data Flow Mapped | ✅ | 研究结果 → 决策简报格式化 → claim 验证 → 交付 → 反馈 → 补充 |

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
在 Phase 1（路由）+ Phase 2（输入质量）基础上，添加三项输出端质量提升：(Q4) 决策简报固定格式，(Q5) 轻量 claim 验证，(Q6) 闭环反馈。

### 1.2 Why We're Building It
**业务价值**：研究产出从原始问答链变成结构化的决策参考文档
**用户受益**：每次研究都能拿到"选项→证据→推荐→风险"的简报，具体 claim 经过验证
**成功的样子**：研究完后用户看到的不是 NotebookLM 的原始回答，而是一份可以直接用于决策的简报

### 1.3 Intent Statement

**真正要解决的问题**：研究产出是原始问答链和通用 NotebookLM 报告，不是为决策设计的格式。具体数字 claim 没有 fact-check。研究交付后没有反馈机制。

**不是要做的**：
- ❌ 不是修改 NotebookLM report 命令（Q4 由 Alex 在对话中生成，不调 report）
- ❌ 不是修改 Deep 级别的 Codex/Gemini 对抗验证（保持现状）
- ❌ 不是修改 ask 动态追问协议（保持现状）

---

## 📚 Project Knowledge（Blake 必读）

### ⚠️ Blake 必须注意的历史教训

1. **Validation Theater** (principles.md — YOLO Audit Findings)
   - 问题：结构检查（grep、word count）证明文件存在但不证明功能质量
   - 解决方案：AC4 要求真实研究任务端到端测试，不只是 grep

2. **NotebookLM 使用 -n flag** (patterns/research-methodology.md)
   - Q6 闭环反馈的追问 ask 同样使用 `-n <id>`

---

## 2. Background Context

### 2.1 Current State (Phase 2 产出)
`standard_execution` 现在有 7 个步骤：
`0_decision_point` → `1_find_notebook` → `2_create_if_needed` → `2b_source_verify` → `3_ask` → `3b_semantic_saturation` → `4_return`

问题：Step 4 直接返回 ask 的原始结果，没有格式化、验证、或反馈机制。

---

## 3. Requirements

### 3.1 Functional Requirements

- FR1 (Q4): Step 4 重构为 `4_format_brief` — Alex 基于 ask 结果和 decision_context，在对话中生成决策简报。固定四段结构：选项列表 → 每个选项的证据引用 → 推荐及理由 → 未知风险/局限
- FR2 (Q4): 创建决策简报模板文件 `.tad/templates/research-decision-brief.md`，定义四段结构和格式规范
- FR3 (Q5): 在 `4_format_brief` 之后插入 `4b_verify_claims` — 从简报中提取 ≥3 个具体 claim（含数字/版本/名称的），用 WebSearch 验证，验证结果标注在简报中（✅ 已验证 / ⚠️ 待验证 / ❌ 与最新信息不符）
- FR4 (Q6): 在 `4b_verify_claims` 之后插入 `5_feedback_loop` — AskUserQuestion "这份研究回答了你的决策问题吗？"。如果"没到位"，用户指出哪部分 → Alex 用 ask 针对性追问 → 补充到简报中。最多 2 轮反馈
- FR5: Deep 级别也输出决策简报格式（在 Phase 5 Output 阶段应用模板）

### 3.2 Non-Functional Requirements

- NFR1: Q5 验证只用 WebSearch，不依赖 Codex/Gemini/NotebookLM
- NFR2: Q6 反馈追问用 `notebooklm ask` raw CLI（`-n <id>`），不触发 step3_5
- NFR3: Quick 级别不受 Q4/Q5/Q6 影响（Quick 直接回答，无简报）

---

## 4. Technical Design

### 4.1 Q4: 决策简报格式 — 重构 step 4

将现有 `4_return` 替换为 `4_format_brief`：

```yaml
4_format_brief: |
  基于以下输入生成决策简报：
  - research_decision_point（来自 step 0）
  - ask 结果 + 动态追问链（来自 step 3 + 3b）
  - topic

  格式（引用模板 .tad/templates/research-decision-brief.md）：

  ## 决策简报: {topic}
  **决策问题**: {research_decision_point}

  ### 选项
  列出研究发现的所有方案/工具/方法，每个选项一行。

  ### 证据
  每个选项对应的支撑证据，带 NotebookLM 引用标记 [N]。
  格式：
  - **{选项 A}**: {证据摘要} [1][3]
  - **{选项 B}**: {证据摘要} [2][5]

  ### 推荐
  基于证据的推荐选择及理由。如果证据不足以做推荐，明确说明。

  ### 未知风险
  研究未覆盖的领域、证据不足的维度、需要进一步调查的点。

  Alex 在对话中直接生成此简报（不调 notebooklm report 命令）。
  简报基于 ask 的回答内容组织，不是重新生成。

  Note: 此步骤替换原有的 `4_return`。结果交付现在在 `5_feedback_loop` 结束时发生。

  Context preservation (P1 fix): 在生成简报前，先将 ask 核心结果
  持久化到 .tad/evidence/research/{topic}/raw-ask-results-{date}.md，
  防止长对话 context compaction 导致 ask 结果被压缩。简报生成可以
  回读此文件作为补充输入。
```

### 4.2 决策简报模板文件

创建 `.tad/templates/research-decision-brief.md`：

```markdown
# 决策简报: {topic}

**决策问题**: {research_decision_point}
**研究日期**: {date}
**Notebook**: {notebook_id}
**研究级别**: Standard / Deep

---

## 选项
<!-- 列出研究发现的所有方案/工具/方法 -->
1. **{选项 A}** — 一句话描述
2. **{选项 B}** — 一句话描述

## 证据
<!-- 每个选项的支撑证据，带引用标记 -->
### {选项 A}
- {证据 1} [引用]
- {证据 2} [引用]

### {选项 B}
- {证据 1} [引用]

## 推荐
<!-- 基于证据的推荐及理由。证据不足时明确说明 -->
**推荐**: {选项} — {理由}

## 未知风险
<!-- 研究未覆盖的领域、证据不足的维度 -->
- {风险 1}
- {风险 2}

## Claim 验证
<!-- Q5 自动填充 -->
| Claim | 验证方式 | 结果 |
|-------|---------|------|
| {具体数字/版本/名称} | WebSearch | ✅/⚠️/❌ |
```

### 4.3 Q5: 轻量 claim 验证 — 新增 step 4b

```yaml
4b_verify_claims: |
  从 4_format_brief 生成的简报中提取具体 claim：
  - 数字型：性能数据、价格、用户量等
  - 版本型：软件版本号、API 版本
  - 名称型：工具名、公司名、项目名（可能过时/改名/不存在）

  提取规则：
  - 扫描简报的"证据"和"推荐"段落
  - 优先选择直接支撑"推荐"段落结论的 claim（如推荐说"X 快 3 倍且便宜 $50"，这两个必须验证）
  - 目标 3-5 个；如果少于 3 个具体 claim，验证所有存在的（哪怕只有 1 个）
  - 如果简报完全是定性描述（无数字/版本/名称），跳过 Q5，标注"无可验证的具体 claim"
  - 跳过纯定性描述（"性能好"、"社区活跃"）

  For each extracted claim:
    WebSearch: "{claim} {current_year}"
    Compare WebSearch result with claim:
    - 一致 → ✅ 已验证
    - 找不到 → ⚠️ 待验证（来源不可确认）
    - 不一致 → ❌ 与最新信息不符: {correct_value}

  将验证结果追加到简报的 "Claim 验证" 表格中。
  如果有 ❌ claim，同时修正简报正文中的相应描述。

  Note: 这是 WebSearch 验证，不依赖 NotebookLM 或外部 CLI。
  降级路径下（NotebookLM 不可用）Q5 仍可正常执行。
```

### 4.4 Q6: 闭环反馈 — 新增 step 5

```yaml
5_feedback_loop: |
  max_feedback_rounds: 2
  feedback_round: 0

  AskUserQuestion:
    question: "这份决策简报回答了你的问题吗？"
    options:
      - "是的，够了" → 结束研究，保存简报
      - "大方向对，但 {X} 部分没到位" → targeted follow-up
      - "不对，我的问题是 {Y}" → reframe (回到 0_decision_point 重新明确)
      - "需要更多细节" → deepen

  If "大方向对，但 X 没到位" AND feedback_round < max_feedback_rounds:
    → Extract gap_topic from user's answer
    → ~/.tad-notebooklm-venv/bin/notebooklm ask \
        "关于 {gap_topic}，在 {research_decision_point} 的上下文中，有什么更具体的信息？" \
        -n <id>
      (Raw CLI — 不触发 step3_5，避免嵌套)
    → 将追问结果补充到简报对应段落
    → 重新执行 4b_verify_claims（如果补充内容含新的具体 claim）
    → feedback_round += 1
    → LOOP back to AskUserQuestion

  If "不对，我的问题是 Y":
    → 更新 research_decision_point = Y
    → 重新执行 4_format_brief（基于已有 ask 结果重新组织）
    → Material sufficiency check (P0 fix):
      如果重新生成的简报"选项"段落少于 2 项或明显比原始简报薄：
      → AskUserQuestion: "现有研究不太覆盖 '{Y}'。怎么处理？"
        Options:
          - "用当前 notebook 针对 Y 追问" → 执行 ask "{Y}" -n <id> → 重新 4_format_brief
          - "开启新的 Standard 研究" → 回到 step 0（新 decision_point = Y）
          - "先用现有信息" → 继续，接受简报较薄
      如果简报内容充足：继续正常流程
    → feedback_round += 1
    → LOOP back to AskUserQuestion

  If "需要更多细节":
    → AskUserQuestion: "哪个选项需要更多细节？"
    → 对选中选项用 ask 追问
    → 补充到简报
    → feedback_round += 1
    → LOOP back

  If feedback_round >= max_feedback_rounds:
    → "已完成 2 轮反馈补充。如果还需要更深入，建议运行 *research --deep。"
    → 结束

  结束后保存简报:
    → Write to .tad/evidence/research/{notebook_topic}/{date}-decision-brief-{slug}.md
    → Report: "📋 决策简报已保存: {path}"

  降级路径（NotebookLM 不可用）：
    Q6 反馈追问改用 WebSearch 代替 ask。简报仍可补充，只是信息源不同。
```

### 4.5 Deep 级别的 Q4 集成

Deep 只需 Q4（格式）。Q5 由 Phase 4c adversarial challenge 覆盖（更强），Q6 由 Phase 5 step6 Research→Action Bridge 覆盖（已有类似反馈）。

**具体插入点**：在 `research-plan-protocol.md` Phase 5 Step 1（AC 提取完成后）、Step 1b（adversarial challenge）之前，插入 `step1c_decision_brief`：
- 基于 Phase 4 ask findings + Step 1 extracted ACs
- 按模板 `.tad/templates/research-decision-brief.md` 组织
- 如果有 `research_decision_point`（来自 Phase 0 step1b），用它作为简报的决策问题
- 如果无（OBJECTIVES.md 不存在时），用研究话题作为简报标题
- 简报与 AC 列表一起在 Step 2 展示给用户

---

## 5. 强制问题回答

### MQ1: 历史代码搜索
- [x] 是 → 在现有 `standard_execution` (SKILL.md L768-798) 基础上插入新步骤
- 决定：✅ 复用现有 step 结构，替换 `4_return` 为 `4_format_brief`

### MQ2: 函数存在性验证
- 不涉及代码函数。底层工具为 `notebooklm ask`（已验证存在）和 `WebSearch`（内置）。`AskUserQuestion`（内置 Claude Code 工具）。

### MQ3-MQ5: N/A（无数据流、无 UI、无状态同步）

---

## 6. Implementation Steps

### Step 1: 创建模板文件

创建 `.tad/templates/research-decision-brief.md`（§4.2 的设计）。

### Step 2: 修改 standard_execution (Alex SKILL.md)

- 将 `4_return` 替换为 `4_format_brief`（§4.1）
- 在 `4_format_brief` 之后插入 `4b_verify_claims`（§4.3）
- 在 `4b_verify_claims` 之后插入 `5_feedback_loop`（§4.4）

### Step 3: 修改 research-plan-protocol.md

在 Phase 5 (Output) 中添加决策简报格式生成步骤，引用模板。

---

## 7. File Structure

### 7.1 Files to Create
```
.tad/templates/research-decision-brief.md    # 决策简报模板
```

### 7.2 Files to Modify
```
.claude/skills/alex/SKILL.md                                    # standard_execution: 4_format_brief + 4b_verify_claims + 5_feedback_loop
.claude/skills/alex/references/research-plan-protocol.md         # Deep Phase 5 输出格式
```

---

## 8. Testing Requirements

### 8.1 Edge Cases
- ask 结果没有明确的选项对比（纯探索型 "了解全貌"）→ 简报的"选项"段改为"关键发现"，其余段落保持
- 简报中没有具体 claim 可提取（全是定性描述）→ 跳过 Q5，标注"无可验证的具体 claim"
- WebSearch 验证发现 ❌ claim → 修正简报正文，标注"[已更正: {原值}→{新值}]"
- 用户反馈"不对，我的问题是 Y"但已有 ask 结果不含 Y 相关信息 → 简报可能很薄，建议升级到 Deep
- 降级路径下 Q6 追问改用 WebSearch，简报仍可补充

## 8.4 Friction Preflight

| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|----------------|---------------|-------------------|--------------------|-------------|
| 无 | — | — | — | — |

---

## 9. Acceptance Criteria

- [ ] AC1: 决策简报模板文件存在
- [ ] AC2: Standard 研究在 ask 后生成决策简报（四段结构）
- [ ] AC3: 简报中有 claim 验证表格
- [ ] AC4: 研究交付后有反馈步骤
- [ ] AC5: Deep 级别 Phase 5 也生成决策简报

## 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output |
|---|---------------------|-------------------|--------------------|--------------------|-----------------|
| AC1 | 决策简报模板存在 | post-impl-verifiable | `test -f .tad/templates/research-decision-brief.md && echo EXISTS` | EXISTS | (post-impl) |
| AC2 | 4_format_brief 步骤存在 | post-impl-verifiable | `grep '4_format_brief' .claude/skills/alex/SKILL.md` | ≥1 match | (post-impl) |
| AC3 | 简报模板含四段结构 | post-impl-verifiable | `grep -c '## 选项\|## 证据\|## 推荐\|## 未知风险' .tad/templates/research-decision-brief.md` | = 4 | (post-impl) |
| AC4 | verify_claims 步骤存在 | post-impl-verifiable | `grep '4b_verify_claims' .claude/skills/alex/SKILL.md` | ≥1 match | (post-impl) |
| AC5 | WebSearch 验证（不依赖 NotebookLM） | post-impl-verifiable | `grep 'WebSearch' .claude/skills/alex/SKILL.md` 在 4b_verify_claims 段落 | ≥1 match | (post-impl) |
| AC6 | feedback_loop 步骤存在 | post-impl-verifiable | `grep '5_feedback_loop' .claude/skills/alex/SKILL.md` | ≥1 match | (post-impl) |
| AC7 | 反馈最多 2 轮 | post-impl-verifiable | `grep 'max_feedback_rounds.*2' .claude/skills/alex/SKILL.md` | ≥1 match | (post-impl) |
| AC8 | Deep Phase 5 引用决策简报 | post-impl-verifiable | `grep -c 'decision.brief\|决策简报' .claude/skills/alex/references/research-plan-protocol.md` | ≥1 | (post-impl) |
| AC9 | 反馈追问用 raw CLI 不触发 step3_5 | post-impl-verifiable | `grep 'Raw CLI\|不触发.*step3_5\|avoids.*step3_5' .claude/skills/alex/SKILL.md` 在 feedback 段落 | ≥1 match | (post-impl) |
| AC10 | 简报保存路径 | post-impl-verifiable | `grep 'decision-brief' .claude/skills/alex/SKILL.md` | ≥1 match (含保存路径模式) | (post-impl) |
| AC11 | reframe 内容充足性检查 | post-impl-verifiable | `grep -c 'sufficiency\|充足\|少于.*2' .claude/skills/alex/SKILL.md` 在 feedback 段落 | ≥1 match | (post-impl) |
| AC12 | context persistence 步骤 | post-impl-verifiable | `grep 'raw-ask-results' .claude/skills/alex/SKILL.md` | ≥1 match | (post-impl) |
| AC13 | 行为验证：端到端 Standard 测试 | post-impl-verifiable | 在 Alex 会话中跑完整 Standard 流程（步骤 0-5），确认产出决策简报含四段结构 | 简报可用 | (post-impl) |

---

## 9.2 Expert Review Status

### Experts Selected

1. **code-reviewer** — SKILL.md 修改质量 + 步骤间数据流
2. **backend-architect** — 反馈循环设计 + 降级路径完整性

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0-1: Section 5 (MQ) 缺失 | §5 — 新增 MQ1/MQ2 | Resolved |
| code-reviewer + backend-architect | P0-2: Q6 reframe 无内容充足性检查 | §4.4 reframe 路径 — 添加 material sufficiency check + AC11 | Resolved |
| backend-architect | P1-1: Context compression 导致简报基于压缩数据 | §4.1 — 添加 raw-ask-results 持久化步骤 + AC12 | Resolved |
| code-reviewer | P1-2: Step numbering 不清（4_return 去哪了） | §4.1 — 添加 note 说明替换 4_return | Resolved |
| code-reviewer | P1-3: 全部 AC 是 grep，无行为验证 | §9.1 AC13 — 添加端到端行为 AC | Resolved |
| code-reviewer | P1-4: Claim <3 个时行为不明 | §4.3 — 明确"验证所有存在的，哪怕只有 1 个" | Resolved |
| code-reviewer | P1-5: Deep Q4 插入点不明确 | §4.5 — 指定 step1c_decision_brief 在 Step 1 后 Step 1b 前 | Resolved |
| backend-architect | P1-2: 9 步太多 | §10.2 — 记为已知约束；Q5 在无具体 claim 时跳过（自然减少步数） | Deferred |
| backend-architect | P2-2: 模板与 SKILL 双源漂移 | §10.2 — 模板是参考格式，SKILL 中的描述是执行规则 | Deferred |

### Overall Assessment (post-integration)

- **code-reviewer**: PASS (2 P0 resolved, 5 P1 resolved)
- **backend-architect**: PASS (1 P0 resolved, 2 P1 resolved, 1 P1 deferred)

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ Q4 简报由 Alex 在对话中生成，不调 `notebooklm report`（避免额外 30-90s 延迟）
- ⚠️ Q6 反馈追问用 raw CLI ask，不触发 step3_5（避免嵌套动态追问）
- ⚠️ 探索型研究（"了解全貌"）的简报结构略有不同——"选项"改为"关键发现"

---

## 11. Decision Rationale

### 11.1 为什么 Alex 在对话中生成而不是用 NotebookLM report

| 方案 | 优点 | 缺点 | 为什么没选 |
|------|------|------|-----------|
| Alex 对话生成（选中）| 快（无额外 API 调用）、可定制格式 | 依赖 Alex LLM 组织能力 | ✅ 用户选择 |
| NotebookLM report | 利用 NotebookLM 的跨源综合 | 30-90s 额外延迟、格式不可控 | 延迟太高 |

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-06-17
**Version**: 3.1.0

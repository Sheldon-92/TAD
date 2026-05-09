---
task_type: yaml
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/alex"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Phase 2 — Autonomous Research Strategy

**From:** Alex | **To:** Blake | **Date:** 2026-05-04
**Project:** TAD | **Task ID:** TASK-20260504-006
**Epic:** EPIC-20260504-goal-driven-research.md (Phase 2/3)

---

## 🔴 Gate 2: ✅ PASS (compact — scope from Epic context)

---

## 1. Overview

让 Alex 在检测到研究空白后，能**主动提出研究计划并执行**（用户确认后）。从"告诉你缺什么"升级到"帮你补上"。

---

## 2. Requirements

### R1: Alex SKILL — 新命令 `*research-plan`

在 Alex SKILL `commands:` 列表中添加 `research-plan`，并添加协议：

```yaml
# 新增命令
research-plan: "基于 OBJECTIVES.md gap analysis，提出研究计划并执行"

# 协议定义
research_plan_protocol:
  description: "Alex 主动提出目标导向的研究计划，用户确认后执行"
  trigger: |
    手动: 用户输入 *research-plan
    自动建议: STEP 3.8 检测到 gap 时输出 "💡 运行 *research-plan 来填补研究空白"
  
  execution:
    step1:
      name: "读取目标 + 现有研究"
      action: |
        1. Read OBJECTIVES.md → extract all Objectives + Key Results with status ⬚/🔄
        2. Read REGISTRY.yaml → list all active notebooks with topics
        3. Identify gaps: which ⬚/🔄 KRs have NO aligned notebook research?
        4. If no gaps → "✅ 所有目标都有对应研究覆盖，暂无空白。" → standby
    
    step2:
      name: "生成研究计划"
      action: |
        For each identified gap:
        - Research Question: 为了推进 KR-X，需要回答什么问题？
        - Research Method: deep search / targeted ask / report generation
        - Expected Output: notebook 新增源 / 报告 / 决策依据
        - Estimated Time: fast (~1min) / deep (~4min) / report (~2min)
        
        Output as structured plan:
        ```
        ## 📋 研究计划 (基于 OBJECTIVES.md gap analysis)
        
        | # | 目标 KR | 研究问题 | 方法 | 预期产出 | 时间 |
        |---|---------|---------|------|---------|------|
        | 1 | O1-KR2 (TTS 工具链) | 哪个 TTS 工具最适合恐怖叙事？ | report | 工具对比报告 | ~2min |
        | 2 | O1-KR3 (分发平台) | 哪些平台对恐怖播客友好？ | deep search | 10+ 源 | ~4min |
        ```
    
    step3:
      name: "用户确认"
      action: |
        AskUserQuestion:
        "这是基于你的业务目标生成的研究计划。怎么处理？"
        Options:
          - "全部执行" → step4 (逐个执行)
          - "选择性执行" → user picks which rows → step4 (只执行选中的)
          - "调整计划" → user modifies → back to step3
          - "不执行，只记录" → save plan to .tad/evidence/research/research-plan-{date}.md → standby
    
    step4:
      name: "执行研究"
      action: |
        For each confirmed research item:
        
        a. 确定 target notebook:
           → If existing notebook matches topic → use it
           → If no match → *research-notebook create "{topic}" (new notebook)
        
        b. Execute based on method:
           - "deep search" → *research-notebook research "{question}" --mode deep
           - "report" → *research-notebook report "{question}"
           - "targeted ask" → *research-notebook ask "{question}" --save-as-note
        
        c. After each item completes (success OR failure):
           → SUCCESS: Display brief result summary
             → If report generated → "📄 Report saved: {path}"
             → If deep search → "🔍 {N} sources added to '{notebook}'"
           → FAILURE: Immediate inline notice (don't wait for final summary):
             → "⚠️ {item description} failed ({reason: auth/timeout/error}). Skipping."
             → Continue to next item (don't block)
        
        d. After ALL items complete:
           → *research-notebook ingest the research plan itself back to relevant notebook
             (plan document = metadata source for future "what was researched and why")
    
    step5:
      name: "更新 OBJECTIVES 研究覆盖"
      action: |
        For each executed research item:
        → Read OBJECTIVES.md
        → Fill "Research needed" field under the corresponding Objective:
          "Research needed: ✅ Covered — see notebook '{topic}', report '{path}'"
        → If a KR's prerequisite research is now complete, note it:
          "Research done. Ready for implementation."
        
        Output: "✅ 研究计划执行完成。{N} 项研究已完成，OBJECTIVES.md 已更新。"
    
  enters_standby: "After step5 completes → standby"
  
  constraints:
    - "每个 research item 执行前不再重复确认（step3 已整体确认）"
    - "如果某个 item 执行失败（auth/timeout）→ 跳过，在最终 summary 中标注失败"
    - "不自动创建 handoff（研究≠实现）— 研究结束后用户决定下一步"
    - "plan 中的 notebook 选择是 Alex LLM 判断，用户可在 step3 修改"
```

### R2: STEP 3.8 末尾连接 *research-plan

在 Phase 1 已添加的 STEP 3.8 gap analysis 输出之后，追加一行触发建议：

```yaml
# 在 STEP 3.8 现有的 gap detection (step 5) 之后：
step_5_enhanced:
  original: "💡 建议: 运行 *research-review 或 *research-notebook research 来填补研究空白"
  replace_with: "💡 建议: 运行 *research-plan 来生成目标导向的研究计划并执行"
```

### R3: *discuss 中主动触发研究建议

在 `discuss_path_protocol` 的 `research_notebook_awareness` 中，当检测到话题与 OBJECTIVES gap 相关时：

```yaml
# 在 A2 discuss awareness step4 ("no matching notebook AND topic needs deep research") 增加：
step4_enhanced:
  additional_option: |
    ⚠️ 此选项仅在 step4 (no matching notebook) 的 AskUserQuestion 中出现。
    如果 step3 fires (notebook found)，gap 信息作为 informational text 显示在
    AskUserQuestion 上方，不作为额外选项。

    如果话题匹配 OBJECTIVES.md 中一个 ⬚ KR 的 gap:
    → 在 step4 AskUserQuestion 中替换一个低优先级选项:
      "生成 *research-plan 并执行 (针对 {KR description})"
    → 选中后直接进入 research_plan_protocol step1 with pre-filled context
    → 保持 AskUserQuestion ≤4 选项 hard cap
```

---

## 3. Files to Modify

| # | File | Action | Lines ~Δ |
|---|------|--------|----------|
| 1 | `.claude/skills/alex/SKILL.md` | Edit | +80 (research_plan_protocol + commands entry + step3.8 link + discuss link) |

---

## 4. Acceptance Criteria

- [ ] AC1: `*research-plan` registered in Alex SKILL `commands:` section
- [ ] AC2: `research_plan_protocol` exists with 5-step execution (read→plan→confirm→execute→update)
- [ ] AC3: Step3 AskUserQuestion offers 4 options (全部执行/选择性/调整/只记录)
- [ ] AC4: Step4 correctly maps method → *research-notebook command (deep→research, report→report, ask→ask)
- [ ] AC5: Step5 updates OBJECTIVES.md "Research needed" field
- [ ] AC6: STEP 3.8 gap detection 输出建议 *research-plan（不再建议 *research-review）
- [ ] AC7: *discuss awareness 当话题匹配 OBJECTIVES gap 时增加 research-plan 选项
- [ ] AC8: `enters_standby` entry added for *research-plan completion

---

## 5. Important Notes

- 只改 Alex SKILL.md — 不改 research-notebook SKILL（已有的命令够用）
- *research-plan 是 Alex 命令（不是 research-notebook 命令） — Alex 编排，research-notebook 执行
- 不做自动执行：step3 必须用户确认。Phase 3 可能会加"自动执行低风险项"但现在不做
- OBJECTIVES.md 的 "Research needed" 字段是 Alex 写的（Alex 可以更新文档，这不是 code）

---

## 📚 Project Knowledge

- Phase 1 已创建 OBJECTIVES.md template + STEP 3.8 gap analysis
- STEP 3.8 的 suppress_if 用 AND 逻辑（REGISTRY 和 OBJECTIVES 独立检查）
- *research-notebook 已有 19 个命令，research/report/ask/ingest 都可直接调用

---

## 9.2 Expert Review

Compact phase — 单文件 ~80 行 YAML 协议添加。Layer 2 code-reviewer 审查协议一致性。

# Handoff: YOLO Execution Mechanism

**From:** Alex | **To:** Blake | **Date:** 2026-05-14
**Priority:** P1
**Type:** Protocol Enhancement (Core Feature)
**Epic:** EPIC-20260514-yolo-mode.md (Phase 2/3)

---
task_type: mixed
e2e_required: no
research_required: no
skip_knowledge_assessment: no
git_tracked_dirs:
  - .claude/skills/alex/
---

## 1. Executive Summary

给 Alex 加 YOLO 模式：当用户在 Epic 确认时选择"你跑完告诉我"，Alex 自动驱动完整 TAD 流程——为每个 Phase 设计 handoff、调 reviewer 审查、spawn Blake sub-agent 实现、再调 reviewer 审查实现、做 Gate 判断——所有过程文件持久化到磁盘。人类只在 Epic 定义和最终验收时参与。

## 2. TAD 端到端流程映射（Grounding 产物）

以下是现有 TAD 手动模式的**完整步骤列表**，以及 YOLO 模式下每一步的处理方式。这是本 handoff 的设计基础——任何被标记为 ✅ KEEP 的步骤在 YOLO 中都必须执行。

### Alex 侧（设计 + 审查）

| # | 现有步骤 | 现有行号 | YOLO 处理 | 理由 |
|---|---------|---------|-----------|------|
| A1 | Socratic Inquiry (3-5 rounds) | socratic_inquiry_protocol | ⚡ **SKIP/REDUCE** — Epic Phase Detail Block 已包含 scope + AC | Epic 是前置投资，Phase 级别提问已在 Epic 创建时完成 |
| A1b | step2b_phase_detail_check | step2b_phase_detail_check (新) | ✅ **KEEP** — 读 Phase Detail Block 判断是否足够 | 即使 YOLO 也要检查 Phase 定义质量 |
| A2 | Research Decision Protocol | research_decision_protocol | ⚡ **REDUCE** — 只在 Phase Detail Block 标注 research_required 时执行 | 大多数 Phase 不需要额外研究 |
| A3 | step0_5 Context Refresh (Knowledge reload) | line 2683 | ✅ **KEEP** — 必须读 project-knowledge | 避免设计脱离已知教训 |
| A4 | step0_5b Research Asset Check | line ~2758 | ✅ **KEEP** | 检查有没有现成的 notebook 可用 |
| A5 | step1 Draft Creation (write HANDOFF.md) | line 2759 | ✅ **KEEP** — 写入磁盘 | 核心制品，文件是 source of truth |
| A6 | step1a Domain Pack Injection | line 2749 | ✅ **KEEP** | Pack 质量标准仍然适用 |
| A7 | step1b Frontmatter Validation | line ~2851 | ✅ **KEEP** | 确保 task_type/e2e_required 正确 |
| A8 | step1c Grounding Pass (Read head 50) | line 2853 | ✅ **KEEP** — Conductor 已做过 grounding 并传给 Alex | 验证设计 vs 实际代码一致 |
| A9 | step1c_lsp (LSP impact analysis) | step1c_lsp (新) | ✅ **KEEP** | scope gap detection 不能跳 |
| A10 | step1d AC Dry-Run | line 2991 | ✅ **KEEP** | AC 验证命令必须预跑 |
| A11 | step2 Expert Selection | line 3059 | ⚡ **ADAPT** — Alex 不调 reviewer，由 Conductor (Alex 主 session) 在 sub-agent 返回后调 | sub-agent 没有 Agent tool |
| A12 | step3 Parallel Expert Review | line 3064 | ⚡ **ADAPT** — 同上，Conductor 调 | 但 reviewer 是真正的独立 sub-agent |
| A13 | step4 Feedback Integration | line 3139 | ✅ **KEEP** — P0 必须修进 HANDOFF.md | 修改结果写入磁盘 |
| A14 | step5 Gate 2 Check | line 3158 | ✅ **KEEP** | 设计完整性检查 |
| A15 | step7 STOP - Human Handover | line 3167 | ❌ **REPLACE** — 不生成 Blake message，直接 spawn Blake sub-agent | 这就是 YOLO 的核心变化 |

### Blake 侧（实现 + 自检）

| # | 现有步骤 | 现有行号 | YOLO 处理 | 理由 |
|---|---------|---------|-----------|------|
| B1 | 1_init (state file) | line 478 | ❌ **SKIP** — sub-agent 不需要 Ralph Loop state file | sub-agent 是一次性执行 |
| B2 | 1_5 Context Refresh | line 494 | ✅ **KEEP** — Blake 读 HANDOFF.md | sub-agent 指令就是"读这个文件" |
| B3 | 1_5b Notebook Check | line 509 | ⚡ **SKIP** — research 已在 Alex 侧处理 | 避免重复 |
| B4 | 1_5c Research Task Detection | line 545 | ⚡ **SKIP** — 同上 | |
| B5 | 1_5d LSP Blast Radius | line 637 | ✅ **KEEP** — 信息性检查有价值 | 帮 Blake 理解影响面 |
| B6 | 1_6 TDD Check | line 675 | ⚡ **SKIP** — sub-agent 不需要 TDD 引导 | 简化 sub-agent |
| B7 | 1_7 Worktree Setup | line 698 | ❌ **SKIP** — Agent tool 的 isolation:worktree 已处理 | |
| B8 | **IMPLEMENTATION** | (between 1_7 and 2_layer1) | ✅ **KEEP** — 核心！ | Blake 写代码 |
| B9 | 2_layer1_loop (build/test/lint/tsc) | line 814 | ✅ **KEEP** — 客观检查不可跳 | tsc + test 是质量底线 |
| B10 | 3_layer2_loop (Expert Review) | line 829 | ❌ **REPLACE** — Blake 不调 reviewer，Conductor 在 Blake 返回后调 | sub-agent 没有 Agent tool |
| B11 | 4_gate3_v2 | line 876 | ⚡ **ADAPT** — Blake 做 Layer 1 部分，Conductor 补 Layer 2 部分 | Gate 3 拆成两半 |
| B12 | completion_protocol (write COMPLETION.md) | line 1395 | ✅ **KEEP** — 写入磁盘 | 核心制品 |
| B13 | step8 Generate Alex Message | line 1415 | ❌ **REPLACE** — 不生成 message，直接返回 | Conductor 读 COMPLETION.md |

### Gate 4 验收（Alex/Conductor 侧）

| # | 现有步骤 | YOLO 处理 | 理由 |
|---|---------|-----------|------|
| G1 | step4 AC 逐条对照 | ✅ **KEEP** | 必须 |
| G2 | step4b Evidence 完整性 | ✅ **KEEP** | 必须 |
| G3 | step4c Layer 2 Audit | ⚡ **ADAPT** — 检查 Conductor 产出的 review 文件 | reviewer 是 Conductor 调的 |
| G4 | step7 Knowledge Assessment | ✅ **KEEP** | 经验积累不能跳 |
| G5 | *accept 归档 | ✅ **KEEP** | 必须 |

**总结：34 步中 18 步完全保留，7 步适配，5 步跳过（被 Epic/Conductor 覆盖），4 步替换（人工传递→自动传递）。**

## 3. Technical Design

### 3.1 YOLO 模式入口（step7_execution_mode）

在现有 step7 "STOP - Human Handover" 之前插入一个选择点：

```yaml
step7_execution_mode:
  name: "Execution Mode Selection"
  trigger: "Handoff 通过 Gate 2 AND handoff 有 Epic 字段（多 Phase 任务）"
  skip_if: "Handoff 没有 Epic 字段（单 handoff → 直接走手动 step7）"
  
  action: |
    AskUserQuestion:
    question: "Handoff 已通过设计审查。这是 Epic {slug} 的 Phase {N}/{M}。怎么执行？"
    options:
      - "我来传递给 Blake（手动）" → 执行现有 step7（生成 Blake message）
      - "你跑完告诉我（YOLO）" → 进入 yolo_execution_protocol
      - "你跑，每个 Phase 完了暂停（半自动）" → yolo_execution_protocol + pause_between_phases: true
```

**只有多 Phase Epic 才出现 YOLO 选项。** 单 handoff 任务永远走手动。

### 3.2 YOLO 执行协议（yolo_execution_protocol）

这是核心。放在 Alex SKILL.md 作为新的顶级 section。

```yaml
yolo_execution_protocol:
  description: "Alex 自动驱动 Epic 全部 Phase 执行，所有过程文件持久化"
  trigger: "step7_execution_mode 用户选了 YOLO 或半自动"
  
  # ⚠️ 核心约束
  constraints:
    - "文件是 source of truth — prompt 只传路径，不传业务内容"
    - "Review 必须是 Conductor 直接 spawn 的 sub-agent — 不信任 sub-agent 声称的 review"
    - "每步持久化 — 任何产物都写入磁盘再进入下一步"
    - "Blake sub-agent 只做实现 + Layer 1 自检 — 不做 Layer 2、不做 Gate"
  
  evidence_directory: ".tad/evidence/yolo/{epic-slug}/"
  
  per_phase_protocol:
    description: "For each ⬚ Planned Phase in Epic"
    
    step_Y1:
      name: "Phase Activation"
      action: |
        1. Read Epic Phase Detail Block for this Phase
        2. Update Phase status: ⬚ Planned → 🔄 Active in Epic file
        3. Write to disk: Epic file updated
        4. Announce: "🔄 Starting Phase {N}: {name}"
    
    step_Y2:
      name: "Grounding (Conductor reads target code → writes to file)"
      action: |
        1. Read target project code relevant to this Phase's scope
           (from Phase Detail Block "Files Likely Affected")
        2. Read project-knowledge files (same as step0_5 Context Refresh)
        3. Write grounding summary to:
           .tad/evidence/yolo/{epic-slug}/phase{N}-grounding.md
           Include: file paths read, key patterns found, line numbers, import conventions
        4. Update session-state.md: current_y_step: Y2
      output: "phase{N}-grounding.md on disk"
    
    step_Y3:
      name: "Design (Alex sub-agent — prompt only contains file paths)"
      action: |
        Spawn Alex sub-agent (subagent_type: backend-architect or appropriate type).
        ⚠️ CORE CONSTRAINT: prompt 只传文件路径，不传业务内容。
        Prompt template:
        ---
        You are Alex designing a feature. Follow these steps:
        1. Read the Epic: {epic_path} — find Phase {N} Detail Block for scope and ACs
        2. Read the grounding file: .tad/evidence/yolo/{epic-slug}/phase{N}-grounding.md
        3. Based on these two files, write a HANDOFF to: {handoff_path}
           Include: §6 Files to Modify, §9 ACs, implementation notes.
        4. Do NOT do expert review — Conductor handles that.
        ---
        No business content in prompt. Alex sub-agent reads everything from disk.
      output: "HANDOFF.md on disk"
      verify: "test -f {handoff_path} && wc -l > 100"
      session_state: "current_y_step: Y3"
    
    step_Y4:
      name: "Design Review (Conductor spawns ≥2 distinct reviewers)"
      action: |
        ⚠️ Must spawn ≥2 distinct reviewer types (matching production TAD hard_requirement_distinct_reviewers).
        1. Read HANDOFF.md from disk
        2. Spawn code-reviewer sub-agent (MANDATORY):
           prompt: "Review {handoff_path}. Focus on §6 file list completeness + §9 AC verifiability. Report P0/P1/P2."
        3. Spawn domain-expert sub-agent (select based on handoff scope):
           - backend work → backend-architect
           - frontend work → frontend-specialist
           - security-adjacent → security-auditor
           prompt: "Review {handoff_path}. Focus on architecture/design quality. Report P0/P1/P2."
        4. Write BOTH review results to disk:
           - .tad/evidence/yolo/{epic-slug}/phase{N}-design-review-cr.md
           - .tad/evidence/yolo/{epic-slug}/phase{N}-design-review-{domain}.md
        5. If ANY P0 found across either reviewer:
           a. Alex (main session) reads BOTH reviews from disk, fixes HANDOFF.md
           b. Write updated HANDOFF.md (v2) to disk
           c. Note in review files: "P0 fixed in HANDOFF v2"
        6. If no P0: proceed
        7. Gate 2 judgment: re-read raw review files from disk (not from memory)
      output: "2 review files on disk + HANDOFF.md (v2 if fixed)"
      session_state: "current_y_step: Y4"
    
    step_Y5:
      name: "Implementation (Blake sub-agent)"
      action: |
        Spawn Blake sub-agent (subagent_type: general-purpose, isolation: worktree).
        Prompt template (STANDARDIZED — Blake gets the same instructions every time):
        ---
        You are Blake implementing a feature. Follow these steps exactly:
        
        1. Read the handoff: {handoff_path}
        2. Implement all tasks described in the handoff
        3. Run these checks (Layer 1):
           - npx tsc --noEmit (must pass)
           - npm test (must pass)
           - npm run lint (if available)
        4. Write a completion report to: {completion_path}
           Include: files changed, tsc result, test result, AC verification table
        5. Git commit with message: "feat({scope}): {description} [YOLO Phase {N}]"
        
        LIMITS:
        - Max 3 Layer 1 retry attempts. If same error 3 times → write what you have to COMPLETION.md and exit
        - Max 200 tool calls. If reached → write progress to COMPLETION.md and exit
        - Only modify files within the current project root. If the Phase requires cross-project changes,
          write the change plan to COMPLETION.md §Escalations and flag for human execution
        
        DO NOT:
        - Call any reviewer or expert sub-agent (you cannot — Conductor handles review)
        - Make design decisions not in the handoff (escalate by noting in COMPLETION.md §Escalations)
        - Skip Layer 1 checks
        ---
      output: "COMPLETION.md on disk + git commit"
      verify: "test -f {completion_path}"
    
    step_Y6:
      name: "Implementation Review (Conductor spawns ≥2 distinct reviewers)"
      action: |
        ⚠️ Must spawn ≥2 distinct reviewer types (same as Y4).
        1. Read COMPLETION.md from disk
        2. Read git diff (Blake's commit)
        3. Spawn code-reviewer sub-agent (MANDATORY):
           prompt: "Review implementation at {completion_path}. Check code diff.
                   Verify ACs are met. Report P0/P1/P2."
        4. Spawn domain-expert sub-agent (same type as Y4):
           prompt: "Review implementation diff. Focus on architecture quality + blast radius. Report P0/P1/P2."
        5. Write BOTH review results to disk:
           - .tad/evidence/yolo/{epic-slug}/phase{N}-impl-review-cr.md
           - .tad/evidence/yolo/{epic-slug}/phase{N}-impl-review-{domain}.md
        6. If ANY P0 found across either reviewer:
           a. Decide: re-spawn Blake or fix directly?
           b. For simple P0: Alex fixes directly (Edit tool), re-run tsc
           c. For complex P0: re-spawn Blake with prompt:
              "Read {handoff_path} for original spec. Read {impl-review-cr.md} for P0 findings. Fix and re-commit."
              (Both paths are file references — no inline content)
           d. Circuit breaker: if re-spawn also fails P0 → honest_partial, pause for human
           e. Write fix result to impl-review appendix
        7. Re-read raw review files from disk before Gate judgment (not from memory)
      output: "2 review files on disk"
      session_state: "current_y_step: Y6"
    
    step_Y7:
      name: "Gate 3+4 (Conductor judges)"
      action: |
        1. Read: HANDOFF.md + COMPLETION.md + design-review.md + impl-review.md
        2. AC verification: for each AC in handoff, check completion report's AC table
        3. tsc re-run: Bash("npx tsc --noEmit") to independently verify
        4. Write gate report: .tad/evidence/yolo/{epic-slug}/phase{N}-gate-report.md
           Include: AC pass/fail table, reviewer summary, tsc result, verdict
        5. If PASS:
           a. Update Epic Phase status: 🔄 Active → ✅ Done
           b. Archive handoff + completion to .tad/archive/handoffs/
           c. Announce: "✅ Phase {N} complete. Moving to Phase {N+1}."
        6. If FAIL:
           a. Announce: "❌ Phase {N} Gate failed. Reason: {detail}"
           b. Decision: retry (back to Y5) or pause for human
      output: "phase{N}-gate-report.md on disk"
    
    step_Y8:
      name: "Knowledge Assessment"
      action: |
        1. Review all phase artifacts for new discoveries
        2. If discovery found: write to .tad/project-knowledge/{category}.md
        3. Record in gate report
      output: "KA entry (if any)"
    
    step_Y_pause:
      name: "Phase Pause (半自动 mode only)"
      trigger: "pause_between_phases: true AND Phase complete"
      action: |
        AskUserQuestion:
        "Phase {N} 完成。Gate PASS。要继续 Phase {N+1} 吗？"
        options:
          - "继续" → next Phase
          - "我先看看" → pause, 用户稍后说 "继续" 恢复
          - "停止" → exit YOLO, 剩余 Phase 手动执行
  
  epic_completion:
    trigger: "所有 Phase 都 ✅ Done"
    action: |
      1. Write final report: .tad/evidence/yolo/{epic-slug}/EPIC-COMPLETION.md
         Include: per-Phase summary, total files changed, total commits, all review references
      2. Run audit-yolo.sh {epic-slug} (Phase 3 of this Epic 实现)
      3. Archive Epic: .tad/active/epics/ → .tad/archive/epics/
      4. Announce to user:
         "🎉 Epic {name} 全部完成。{N} 个 Phase, {M} 个文件, {K} 个 commit。
          审计报告: .tad/evidence/yolo/{epic-slug}/EPIC-COMPLETION.md
          请验收。"
```

### 3.3 YOLO Evidence 目录结构

```
.tad/evidence/yolo/{epic-slug}/
  phase1-design-review.md       ← Conductor 的 code-reviewer 审查 handoff
  phase1-impl-review.md         ← Conductor 的 code-reviewer 审查实现
  phase1-gate-report.md         ← Conductor 的 Gate 判断
  phase2-design-review.md
  phase2-impl-review.md
  phase2-gate-report.md
  ...
  EPIC-COMPLETION.md            ← 最终汇总报告
```

Handoff 和 Completion 文件仍然在 `.tad/active/handoffs/`（Gate 通过后归档到 `.tad/archive/handoffs/`），和手动模式完全一致。

### 3.4 不改什么

- **手动模式完全不动** — step7 只有在 Epic 场景下才出现 YOLO 选项
- **Blake 的完整 SKILL.md 不改** — YOLO 用的是简化版 Blake sub-agent prompt，不是完整 Blake
- **Gate 结构不改** — Gate 3/4 的检查项不变，只是执行者从 Blake/人类变成 Conductor
- **现有 *express / *bug / *discuss / *learn 不受影响**
- **单 handoff 任务不受影响** — 只有多 Phase Epic 才有 YOLO

### 3.5 TAD 独特机制在 YOLO 中的保留方案

YOLO 模式绝不能丢失以下 TAD 独特机制。每个都必须在 yolo_execution_protocol 中有对应处理：

| TAD 机制 | 现有位置 | YOLO 如何保留 | 写入哪个 step |
|----------|---------|-------------|--------------|
| **Anti-Rationalization Registry** | Alex SKILL 底部 | Conductor 在 step_Y4 review 时扫描 AR pattern（"这个 P0 不重要" = AR-001） | step_Y4 review prompt 加 AR 扫描指令 |
| **Honest Partial Protocol** | Blake SKILL line 1804 | 如果 Gate FAIL 且无法自动修复 → Conductor 使用 honest_partial：标记 PARTIAL，暂停等人类，不假装 PASS | step_Y7 Gate 判断加 honest_partial 分支 |
| **Circuit Breaker** | Blake SKILL line 908 | Blake sub-agent 连续 3 次 Layer 1 失败 → Conductor 暂停，不无限重试 | step_Y5 Blake prompt 加 "3 次失败后停止并报告" |
| **gate4_delta Capture** | Alex SKILL line 3765 | Conductor 在 step_Y7 Gate 判断时捕获"设计预期 vs 实际结果"差异 → 写入 gate report | step_Y7 Gate 报告加 gate4_delta 字段 |
| **Pair Testing Assessment** | Alex *accept step_pair_testing_assessment | Epic 最后一个 Phase 的 Gate 通过后，Conductor 评估是否建议 pair testing | epic_completion 加 pair_testing_assessment |
| **Session State Recovery** | Alex STEP 3.7 / Blake session_state_protocol | Conductor 在每个 Phase 开始时写 session-state.md（当前 Phase、进度）→ session 断了可以恢复 | step_Y1 写 session state；step_Y7 PASS 时更新 |

**实现要求：** Blake 把上述 6 行的 "写入哪个 step" 列内容，分别加入 yolo_execution_protocol 对应 step 的 action 描述中。不是单独的 section，而是嵌入到已有 step 里。

## 4. Decision Summary

| # | Decision | Rationale |
|---|----------|-----------|
| 1 | YOLO 入口放在 step7 | 最晚决策点——此时 handoff 已通过 Gate 2，用户有足够信息判断 |
| 2 | 34 步中 18 步完全保留 | TAD 质量纪律的核心——设计审查、tsc/test、KA 一个不跳 |
| 3 | Blake sub-agent 是简化版 | 不注入完整 Blake SKILL（太大），只给标准化的实现指令 |
| 4 | Conductor 做所有 review | sub-agent 没有 Agent tool；Conductor 是唯一独立审查层 |
| 5 | Evidence 目录独立 | `.tad/evidence/yolo/{slug}/` 让审计清晰，不混进手动模式的 evidence |
| 6 | 半自动模式作为折中 | 每个 Phase 完成后暂停等用户确认——信任度介于手动和全自动之间 |

## 5. Files to Modify

| # | File | Action | Description |
|---|------|--------|-------------|
| 1 | `.claude/skills/alex/SKILL.md` | MODIFY | 加 step7_execution_mode + yolo_execution_protocol + yolo_evidence_structure |

**Grounded Against** (Alex step1c):
- `.claude/skills/alex/SKILL.md` lines 1965-2004 (step2b), 2666-3167 (handoff_creation full), 3440-3800 (acceptance_protocol) — read at 2026-05-14
- `.claude/skills/blake/SKILL.md` lines 478-900 (develop_command full), 1395-1460 (completion_protocol) — read at 2026-05-14
- `.tad/templates/epic-template.md` (enhanced version from Phase 1) — read at 2026-05-14

## 6. Acceptance Criteria

- [ ] AC1: Alex SKILL 包含 `step7_execution_mode` section（只在 Epic handoff 时触发）
- [ ] AC2: Alex SKILL 包含 `yolo_execution_protocol` section（含 Y1-Y8 + epic_completion）
- [ ] AC3: yolo_execution_protocol 的 step_Y3 (Alex sub-agent) 指令中包含 "Do NOT do expert review"
- [ ] AC4: yolo_execution_protocol 的 step_Y4 和 Y6 写 review 到磁盘（有文件路径规范）
- [ ] AC5: yolo_execution_protocol 的 step_Y5 (Blake sub-agent) 使用标准化 prompt 模板（含 Layer 1 检查）
- [ ] AC6: step_Y5 Blake prompt 包含 "DO NOT: Call any reviewer"
- [ ] AC7: step_Y7 Gate 包含 "tsc re-run" 独立验证
- [ ] AC8: 手动模式不受影响（无 Epic 字段的 handoff → step7 行为不变）
- [ ] AC9: yolo_evidence_structure 定义了 `.tad/evidence/yolo/{epic-slug}/` 目录结构
- [ ] AC10: step_Y_pause 存在（半自动模式选项）
- [ ] AC11: step_Y4 和 Y6 都要求 ≥2 distinct reviewers（code-reviewer + domain expert）
- [ ] AC12: session-state.md 在每个 Y-step 更新 current_y_step 字段
- [ ] AC13: step_Y1 和 Y7 更新 Epic Phase Detail Block Status（Planned→Active→Done）
- [ ] AC14: Blake sub-agent prompt 包含 LIMITS（3 retries + 200 tool calls + 项目根目录约束）
- [ ] AC15: step_Y3 Alex sub-agent prompt 只含文件路径，不含业务内容（grep 验证无 Scope/AC inline）

## 7. Implementation Notes for Blake

### P1: step7_execution_mode
- 位置：在现有 step7 "⚠️ STOP - Human Handover"（line 3167）**之前**插入
- 用 `skip_if: "Handoff 没有 Epic 字段"` 确保非 Epic handoff 直接走 step7
- 选项列表用 AskUserQuestion 3 选项（手动 / YOLO / 半自动）

### P2: yolo_execution_protocol
- 作为 Alex SKILL.md 的新顶级 section（和 handoff_creation_protocol 同级）
- 不嵌套在任何现有 section 里
- step_Y1 到 step_Y8 + step_Y_pause + epic_completion 全部包含
- 每个 step 的 `output` 字段标明持久化文件路径

### P3: Blake sub-agent prompt 模板
- 写在 yolo_execution_protocol.step_Y5 内部（不是独立文件）
- 模板是固定文本 + {变量} 占位符
- 变量：{handoff_path}, {completion_path}, {scope}, {description}, {N}

### P4: 不需要改 Blake SKILL.md
- YOLO 的 Blake 是 sub-agent，不加载 Blake SKILL.md
- Blake SKILL.md 继续服务手动模式
- 两者完全独立

## Expert Review Audit Trail

| Reviewer | Issue | Resolution | Status |
|----------|-------|------------|--------|
| code-reviewer | P0-1: step_Y2 grounding via prompt violates file constraint | Y2 now writes phase{N}-grounding.md to disk | Resolved |
| code-reviewer | P0-2: step_Y3 prompt contains business content | Y3 prompt now only contains file paths | Resolved |
| backend-architect | P0-1: Single reviewer per stage weaker than production TAD | Y4 + Y6 now require ≥2 distinct reviewers | Resolved |
| code-reviewer | P1-1: Mapping table count 33 not 34 | Acknowledged, cosmetic — Blake can fix during impl | Open |
| code-reviewer | P1-2: No AC for session-state recovery | AC12 added | Resolved |
| code-reviewer | P1-3: Y6 re-spawn lacks handoff context + no circuit breaker | Y6 re-spawn prompt includes handoff path + circuit breaker added | Resolved |
| backend-architect | P1-1: No crash recovery between Y-steps | session_state: current_y_step added to each step | Resolved |
| backend-architect | P1-2: Blake sub-agent no token/time cap | LIMITS block added to Blake prompt (200 tool calls + 3 retries) | Resolved |
| backend-architect | P1-3: Worktree isolation gap not resolved | Blake prompt adds "Only modify files within project root" constraint | Resolved |

## 8. Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/yolo-execution-mechanism/code-reviewer.md
  - .tad/evidence/reviews/blake/yolo-execution-mechanism/backend-architect.md
completion:
  - .tad/active/handoffs/COMPLETION-20260514-yolo-execution-mechanism.md
knowledge_updates:
  - .tad/project-knowledge/architecture.md (if new discovery)
```

## 9. Important Notes

### 9.1 这是协议文本，不是代码
整个 handoff 的产出是 Alex SKILL.md 的新 section（YAML + 自然语言协议）。Blake 写的是"教 Alex 怎么做 YOLO"的规则文本，不是可执行代码。

### 9.2 audit-yolo.sh 是 Phase 3 scope
本 handoff 不包含审计脚本。epic_completion 里引用了它但标注为 "(Phase 3 of this Epic 实现)"。

### 9.3 第 2 节 TAD 流程映射表是本 handoff 的核心
Blake 实现时必须对照此表——标记为 ✅ KEEP 的步骤必须在 yolo_execution_protocol 的对应 step 中有体现。标记为 ❌ SKIP/REPLACE 的步骤必须有明确注释说明为什么跳过。

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训

- **Epic Auto-Conductor: Sub-Agent Nesting Limit** (architecture.md, 2026-05-14): sub-agent 没有 Agent tool。所有 review 必须在 Conductor (Alex 主 session) 层调。Blake sub-agent 的 prompt 必须明确说 "DO NOT call reviewer"。
- **文件是 source of truth** (architecture.md, 2026-05-14): prompt 只传路径。Spike 2 因为通过 prompt 传内容导致审计链断裂。
- **Alex 的自我审查会伪造 reviewer 标签** (architecture.md, 2026-05-14): Alex sub-agent 的 prompt 必须说 "Do NOT do expert review"。

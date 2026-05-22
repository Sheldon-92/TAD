---
task_type: yaml
e2e_required: no
research_required: no
skip_knowledge_assessment: no
git_tracked_dirs: []
gate4_delta: []
---

# Handoff: TAD Lifecycle Health Improvements

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-05-17
**Project:** TAD
**Task ID:** TASK-20260517-001
**Handoff Version:** 3.1.0

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-05-17

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 4 个改动独立，无交叉依赖。STEP 3.5/3.55 分离保持 READ-ONLY 合约 |
| Components Specified | ✅ | 每个 FR 有精确的 YAML 文本设计 + 插入位置 |
| Functions Verified | ✅ | N/A（协议文本，无函数调用） |
| Data Flow Mapped | ✅ | Zombie detection: STEP 3.5 scan → context → STEP 3.55 cleanup. *optimize: trace JSONL → slug normalization → metrics |

**Gate 2 结果**: ✅ PASS

**Expert Review**: 2 experts (code-reviewer + backend-architect), 5 P0 + 7 P1 all resolved. See §9.2 Audit Trail.

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] 阅读了「📚 Project Knowledge」章节中的历史经验
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 1.1 What We're Building
4 个协议层改进，全部在 `.claude/skills/alex/SKILL.md` 中修改，解决跨 15 个下游项目发现的 TAD 生命周期健康问题：

1. **`*accept --quick`** — 轻量归档模式，跳过 10+ 步仪式
2. **YOLO 自动归档** — Gate PASS 后直接归档，不等手动 *accept
3. **启动时僵尸检测** — Alex 启动后检测 >14 天的活跃 handoff，提供批量清理
4. **`*optimize` 重设计** — 基于现有 trace 类型做生命周期健康度分析

### 1.2 Why We're Building It
**业务价值**: 跨 15 个项目数据显示，toy 有 14 个僵尸 handoff（11 个无 COMPLETION），合规ai 有 6 个 YOLO 残留，Sober Creator 有 3 个从 3 月放到现在。用户完成代码后不回来跑 *accept，因为仪式感成本 > 感知价值。

**用户受益**: 项目的 .tad/active/handoffs/ 保持干净；*optimize 能基于已有的 702+ trace 条目产生有用分析；YOLO 模式真正"全自动"。

**成功的样子**: 用户说 `*accept --quick` 后，3 步内完成归档。YOLO 完成后 active/ 里没有残留。Alex 启动时告诉用户"你有 14 个超过 7 天的 handoff，要清理吗？"

### 1.3 Intent Statement

**真正要解决的问题**: TAD 的归档仪式太重，导致 handoff 积累成僵尸。*optimize 依赖不存在的 trace 类型（step_start/step_end），无法运行。

**不是要做的**:
- ❌ 不是重写 *accept 的完整流程（完整版保留）
- ❌ 不是修复 trace-step.sh（Domain Pack 已冻结，trace-step.sh 的目标对象已不存在）
- ❌ 不是添加 mechanical hooks（遵循「单用户 CLI 不做机械执行」架构决策）

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别
- [x] architecture - 架构决策

### 步骤 2：历史经验摘录

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| architecture.md | 4 条 | 见下方 |

**⚠️ Blake 必须注意的历史教训**：

1. **Mechanical Enforcement Rejected on Single-User CLI — 2026-04-15** (来自 architecture.md)
   - 问题：PreToolUse hooks fail-closed 导致 deny all tool calls
   - 与本任务关系：所有 4 个改动都是 SKILL 协议层的 prompt-level 变更，不是 hook。不要添加任何 settings.json 配置。

2. **YOLO Mode Strengths and Constraints — 2026-05-15** (来自 architecture.md)
   - 发现：Conductor owns review, Blake owns file creation
   - 与本任务关系：1b (YOLO auto-archive) 的归档动作在 Conductor (step_Y7) 执行，不在 Blake sub-agent 中

3. **Storage and Lifecycle Patterns — 2026-02-16** (来自 architecture.md)
   - 发现："separate status update from target workflow entry"
   - 与本任务关系：*accept --quick 是独立路径，不修改完整 *accept 的任何步骤

4. **YOLO Audit Findings — 2026-05-15** (来自 architecture.md)
   - 发现：Validation theater — structural checks prove files exist but don't prove quality
   - 与本任务关系：*accept --quick 明确放弃质量仪式，这是设计决策不是疏忽。不要偷偷加回检查步骤。

---

## 2. Background Context

### 2.1 Cross-Project Data (from *discuss analysis, 2026-05-17)

| Metric | Value |
|--------|-------|
| 注册项目 | 15 |
| 总归档 handoff | 337 |
| 总僵尸 handoff | 22+ (across toy, 合规ai, Sober Creator, TAD, Next Guest, care) |
| 僵尸率 | ~6% of all handoffs never archived |
| Trace 数据 | 702 entries in toy (4 types: handoff_created, evidence_created, task_completed, domain_pack_step) |
| step_start/step_end | 0 entries (trace-step.sh never wired) |
| YOLO 残留 | 合规ai 5 completions + TAD 5 completions |

### 2.2 Current State
- `*accept` 有 10+ 步仪式（step0 git check → step4 AC → step4b evidence → step4c Layer 2 → step4d trace-digest → step7 KA → pair testing → Epic → NEXT.md → PROJECT_CONTEXT.md）
- YOLO step_Y7 PASS 后执行 archive（line 3821），但实践中 Conductor 完成整个 epic_completion 后残留文件
- STEP 3.5 只输出 health summary，不提供 cleanup action
- *optimize 等待 step_start/step_end（不存在），忽略已有的 702 条 file-level trace

---

## 3. Requirements

### 3.1 Functional Requirements

- **FR1 (*accept --quick)**: 新增 `*accept --quick` 命令选项。流程：检查 HANDOFF 文件存在 → mv HANDOFF + COMPLETION 到 archive → 更新 NEXT.md [x] → 更新 Epic Phase Map status（如有，仅标记 ✅ Done，不触发 Epic completion 判定或 next-phase 提示）→ 完成。跳过 git check、AC 逐条对照、evidence 检查、Layer 2 audit、trace-digest、Knowledge Assessment、pair testing 评估、PROJECT_CONTEXT.md。如果 PROJECT_CONTEXT.md 超过 3 次 --quick 未更新，输出软提醒。

- **FR2 (YOLO auto-archive)**: YOLO step_Y7 PASS 后，在 step 6.b 的 archive 操作中同时 mv COMPLETION 文件。epic_completion 阶段，验证 active/handoffs/ 中无残留文件（属于当前 Epic 的）。

- **FR3 (启动僵尸检测)**: 分两步实现。(A) Alex STEP 3.5 增加 READ-ONLY 扫描逻辑：扫描 .tad/active/handoffs/HANDOFF-*.md，计算每个文件的 age（today - filename date），>14 天的标记为 zombie，输出报告表格但不修改任何文件。(B) 新增 STEP 3.55（在 STEP 3.7 之后、STEP 4 greeting 之前），如果 STEP 3.5 检测到 zombie，使用 AskUserQuestion 提供批量清理选项。清理使用 *accept --quick 的逻辑（mv + NEXT.md update）。分离保持 STEP 3.5 的 READ-ONLY 合约不变。排除属于活跃 Epic 的 handoff（检查 handoff 的 Epic 字段是否指向 .tad/active/epics/ 中的文件）。

- **FR4 (*optimize lifecycle analysis)**: 重写 optimize_protocol 的 step2_aggregate，基于 4 种现有 trace 类型计算生命周期健康度指标：
  - **Zombie rate**: handoff_created 无对应 task_completed 的比例
  - **Completion cycle time**: handoff_created → task_completed 的时间差分布
  - **Evidence production rate**: evidence_created / handoff_created 比率
  - **Cross-project comparison**: 相同指标在不同项目间的对比（需 *evolve，此处只做单项目）
  - 移除对 step_start/step_end 的依赖。移除对 Domain Pack 特定分析的引用（已冻结）。

### 3.2 Non-Functional Requirements
- **NFR1**: 所有改动都是 SKILL.md 协议文本变更。不添加 hooks、不修改 settings.json、不创建新脚本。
- **NFR2**: 完整 `*accept` 流程保持不变 — `--quick` 是新增路径，不是替换。
- **NFR3**: FR3 僵尸检测不阻塞 Alex 启动。用户可选"稍后处理"。

---

## 4. Technical Design

### 4.1 Change 1: *accept --quick (in accept_command section)

在 `accept_command:` 的 `prerequisite:` 之后，`steps:` 之前，新增：

```yaml
  quick_mode:
    trigger: "User types *accept --quick OR user selects 'batch cleanup' from STEP 3.5"
    description: "Minimal archive — skip all ceremony, just move files"
    steps:
      step1_identify:
        action: |
          If specific slug provided: target that handoff
          If batch mode (from STEP 3.5): target all zombie handoffs
          For each target:
            1. Verify .tad/active/handoffs/HANDOFF-*-{slug}.md exists
            2. Check for matching COMPLETION-*-{slug}.md (optional — may not exist)
      step2_archive:
        action: |
          For each target handoff:
            1. mv HANDOFF to .tad/archive/handoffs/
            2. mv COMPLETION to .tad/archive/handoffs/ (if exists)
            3. If no COMPLETION: log "(no completion report — direct archive)"
      step3_update:
        action: |
          1. Update NEXT.md: find matching entry → mark [x]
          2. If handoff has Epic field:
             → ONLY update Phase Map status marker: 🔄 Active → ✅ Done
             → Do NOT trigger Epic completion check (all-phases-done → archive Epic)
             → Do NOT trigger next-phase AskUserQuestion prompt
             → Do NOT update Phase Detail Block notes or Context for Next Phase
             → These require full *accept (step2b_epic_update has error handling, 
               concurrent checks, and Phase Detail Block logic that --quick skips)
          3. Track quick_accept_count: increment counter in session context
             → If quick_accept_count >= 3 since last PROJECT_CONTEXT.md update:
               Output soft reminder: "💡 PROJECT_CONTEXT.md 已 {N} 次 --quick 未更新，
               考虑运行完整 *accept 或 *tad-maintain sync"
          4. Output: "✅ Archived: {slug} (quick mode — no KA, no Layer 2)"
    skipped_steps:
      - "step0_git_check (git status)"
      - "step4 (AC line-by-line)"
      - "step4b (evidence completeness)"
      - "step4c (Layer 2 audit)"
      - "step4d (trace-digest)"
      - "step7 (Knowledge Assessment)"
      - "step_pair_testing_assessment"
      - "step3 (PROJECT_CONTEXT.md update)"
    note: "Full *accept is UNCHANGED. --quick is additive, not replacement."
```

### 4.2 Change 2: YOLO auto-archive (in yolo_execution_protocol)

修改 `step_Y7` 的 action step 6 和 `epic_completion`：

**step_Y7 step 6.b**: 现有文本 "Archive handoff + completion to .tad/archive/handoffs/" 语义已正确（LLM 不执行 shell 命令，它读协议文本）。追加 NEXT.md 更新指令（当前缺失）：
```
b. Archive handoff + completion to .tad/archive/handoffs/
   (both HANDOFF-*-{slug}.md AND COMPLETION-*-{slug}.md)
   Update NEXT.md: mark corresponding entry [x]
```
注意：step_Y7 的 wording 变更是澄清性的。真正的 bug fix 是下面的 step 4b。

**epic_completion** step 4 之后新增 step 4b：
```
4b. Verify clean active/:
    残留检查: ls .tad/active/handoffs/*{epic-slug}* 2>/dev/null
    If any files remain: WARN "⚠️ {N} files remain in active/ for this Epic"
    and list them. For each remaining file, execute quick archive:
    mv to .tad/archive/handoffs/ (same as *accept --quick step2_archive).
    This is the actual safety net — catches any per-phase archive that silently failed.
```

### 4.3 Change 3: Startup zombie detection (STEP 3.5 + new STEP 3.55)

**两步分离设计**（解决 STEP 3.5 READ-ONLY 合约冲突 — CR-P1-2 + ARCH-P0-2）：

**Part A — STEP 3.5 扩展（READ-ONLY 扫描，不修改文件）：**

在 STEP 3.5 现有 action 的 line 5（"Output a brief health summary"）之前追加：

```yaml
    # --- Zombie Handoff Detection (added 2026-05-17) — READ-ONLY scan ---
    4. Scan .tad/active/handoffs/HANDOFF-*.md files
    5. For each file: extract date from filename (YYYYMMDD), compute age_days = today - date
    6. Filter: exclude handoffs whose Epic field references a file in .tad/active/epics/
       (these are part of an in-progress Epic, not zombies)
    7. Collect zombies: remaining files where age_days > 14
    8. Store zombie list in conversation context (zombie_handoffs = [{slug, age, has_completion}])
    9. If zombie_count > 0:
       Append to health summary output: "⚠️ {zombie_count} 个 handoff 超过 14 天未归档"
    10. If zombie_count == 0: no additional output
```

STEP 3.5 的 `suppress_if` 更新为：
`"No issues found AND zombie_count == 0 - show one-line: 'TAD Health: OK'"`

**Part B — 新增 STEP 3.55（post-3.7，READ-WRITE cleanup offer）：**

在 STEP 3.7 之后、STEP 3.8 之前，新增：

```yaml
  - STEP 3.55: Zombie handoff cleanup (conditional)
    trigger: "zombie_handoffs list from STEP 3.5 is non-empty"
    action: |
      1. Display zombie table:
         | Handoff | Age (days) | Has COMPLETION |
         |---------|-----------|----------------|
         | {slug}  | {age}     | ✅/❌          |
      2. AskUserQuestion:
         question: "要批量清理这 {N} 个僵尸 handoff 吗？"
         options:
           - "全部归档 (quick mode)" → execute *accept --quick for each zombie
           - "逐个确认" → per-zombie AskUserQuestion: archive / keep / skip
           - "稍后处理" → skip, continue activation
    blocking: false
    suppress_if: "zombie_handoffs is empty (STEP 3.5 found no zombies)"
    interacts_with: |
      Runs AFTER STEP 3.7 (session state check).
      If STEP 3.7 announces Blake resume (case 3): suppress STEP 3.55
      (user is probably in Terminal 2 for Blake, not here to clean up).
      Does NOT affect STEP 3.8 suppression.
```

### 4.4 Change 4: *optimize lifecycle analysis (in optimize_protocol)

重写 `step2_aggregate` 和 `step2b_project_knowledge`。核心变更：

**step2_aggregate 替换为**:
```yaml
    step2_aggregate:
      name: "Lifecycle Health Analysis"
      action: |
        From collected traces, compute lifecycle health metrics:
        
        1. Trace type breakdown:
           Count per type: handoff_created, evidence_created, task_completed, domain_pack_step
           Output: pie chart (text-based) showing distribution
        
        2. Zombie rate:
           Join key: the `file` field in each trace JSON line. Both handoff_created and
           task_completed use the full file path (e.g., "/path/.tad/active/handoffs/HANDOFF-20260504-foo.md").
           Normalization: extract slug from file path using regex:
             slug = basename(file).replace(/^(HANDOFF|COMPLETION)-\d{8}-/, '').replace(/\.md$/, '')
           This produces identical slugs regardless of HANDOFF vs COMPLETION prefix.
           
           - Extract unique slugs from handoff_created events (using normalized slug)
           - Check which slugs also appear in task_completed events (same normalization)
           - zombie_rate = (handoff_slugs - completed_slugs) / handoff_slugs
           - Fallback: if both trace types exist but zero slug matches found,
             WARN "slug format mismatch detected — check trace file field format"
             instead of reporting 100% zombie rate
           - Output: "Zombie rate: {rate}% ({N} handoffs never completed)"
           - If zombie_rate > 20%: flag as unhealthy
        
        3. Completion cycle time:
           - For each slug with both handoff_created AND task_completed:
             cycle_time = task_completed.ts - handoff_created.ts (first occurrence of each)
           - Compute: median, p90, max
           - Output: "Cycle time: median {N}h, p90 {N}h, max {N}h"
        
        4. Evidence production rate:
           - evidence_per_handoff = evidence_created_count / handoff_created_unique_slugs
           - Output: "Evidence rate: {N} evidence files per handoff"
           - If < 1.0: flag as low (healthy projects produce ≥2 evidence per handoff)
        
        5. Activity timeline:
           - Group traces by week (from ts field)
           - Output: bar chart (text-based) showing weekly activity
           - Identify inactive periods (>2 weeks gap)
        
        6. Output summary table to user
```

**step2b_project_knowledge**: 更新 line 4751 的 "Domain Pack proposals" 引用。将 "These proposals join the Domain Pack proposals in step3" 改为 "These proposals join the lifecycle health proposals in step3"。其余逻辑不变。

**step3_generate_proposals**: 修改 proposal YAML template 的 `target` block：
```yaml
target:
  file: ".tad/project-knowledge/{category}.md"  # or ".claude/skills/{skill}/SKILL.md"
  # was: ".tad/domains/{domain}.yaml" — Domain Packs are frozen
  capability: "{optional — only if targeting a specific SKILL capability}"
  section: "{quality_criteria | steps | anti_patterns | protocol_section}"
```
proposals 可以 target SKILL.md 或 project-knowledge，不仅限于 Domain Pack YAML。

---

## 5. 强制问题回答

### MQ1: 历史代码搜索
- [x] 是 — 用户提到"其他项目的实践"，Alex 在 *discuss 中搜索了全部 15 个项目的数据

### MQ2: 函数存在性验证
N/A — 本任务是协议文本修改，不涉及代码函数调用

### MQ3-MQ5: N/A
纯协议文本变更，无数据流/UI/状态同步

---

## 6. Implementation Steps

### Phase 1: Protocol Text Changes (预计 30-60 分钟)

#### 交付物
- [ ] `.claude/skills/alex/SKILL.md` 中 4 个区域的修改

#### 实施步骤

1. **FR1 — *accept --quick**: 在 `accept_command:` section (line ~4494) 的 `prerequisite:` 之后、`steps:` 之前，插入 `quick_mode:` block（约 40 行）。注意 `quick_mode.steps` 嵌套在 `quick_mode:` 下（4空格缩进），不与 `accept_command.steps` 同级
2. **FR2 — YOLO auto-archive**: 修改 `step_Y7` (line ~3818-3821) 的 step 6.b，追加 NEXT.md 更新。在 `epic_completion` (line ~3858) 追加 step 4b 残留检查 + 自动清理。注意：step_Y7 改动是澄清性的，step 4b 是实质修复
3. **FR3 — 启动僵尸检测（两步分离）**: (A) 扩展 STEP 3.5 (line ~75-83)，在现有 action 中追加 READ-ONLY zombie scan（约 10 行）+ 更新 suppress_if。(B) 在 STEP 3.7 之后新增 STEP 3.55 block（约 20 行），含 AskUserQuestion cleanup offer
4. **FR4 — *optimize**: 替换 `step2_aggregate` (line ~4719-4734) 为 lifecycle health analysis 版本。更新 `step2b_project_knowledge` (line ~4751) Domain Pack 引用。修改 `step3_generate_proposals` target block

#### 实施提示
- 每个 FR 独立修改 — 如果一个 FR 有问题，其他 FR 不受影响
- YAML 格式必须与周围内容的缩进保持一致（2 空格缩进）
- 不要修改 `acceptance_protocol:` section — 那是完整 *accept 的验收流程，与 `accept_command:` 不同

### Grounded Against (Alex step1c):
- .claude/skills/alex/SKILL.md line 4494-4553 (accept_command, read at 2026-05-17)
- .claude/skills/alex/SKILL.md line 3808-3857 (YOLO step_Y7 + Y8 + Y_pause, read at 2026-05-17)
- .claude/skills/alex/SKILL.md line 75-94 (STEP 3.5 + 3.6, read at 2026-05-17)
- .claude/skills/alex/SKILL.md line 4701-4780 (optimize_protocol, read at 2026-05-17)

---

## 7. File Structure

### 7.1 Files to Modify
```
.claude/skills/alex/SKILL.md  # 4 sections modified (accept_command, yolo step_Y7, STEP 3.5, optimize_protocol)
```

### 7.2 Files to Create
None

---

## 8. Testing Requirements

### 8.1 Verification
Since this is protocol text (not code), testing = reading the modified SKILL.md and verifying:
- YAML syntax is valid (no broken indentation)
- No section boundaries crossed (each change stays within its target section)
- No existing protocol text accidentally deleted

### 8.2 Smoke Test
After modification, verify Alex SKILL.md still loads by checking:
- `grep -c 'accept_command:' .claude/skills/alex/SKILL.md` = 1
- `grep -c 'quick_mode:' .claude/skills/alex/SKILL.md` = 1
- `grep -c 'optimize_protocol:' .claude/skills/alex/SKILL.md` = 1
- `grep -c 'Zombie Handoff Detection' .claude/skills/alex/SKILL.md` = 1

---

## 9. Acceptance Criteria

- [ ] AC1: `*accept --quick` section exists in accept_command with 3 steps (identify, archive, update)
- [ ] AC2: YOLO step_Y7 step 6.b explicitly lists mv for both HANDOFF and COMPLETION files
- [ ] AC3: YOLO epic_completion has step 4b that checks for residual files in active/
- [ ] AC4: STEP 3.5 contains zombie detection logic with >7 day threshold and AskUserQuestion
- [ ] AC5: optimize_protocol step2_aggregate computes 5 metrics (zombie rate, cycle time, evidence rate, activity timeline, type breakdown) without referencing step_start/step_end
- [ ] AC6: No references to Domain Pack YAML in optimize_protocol step2 (Domain Packs are frozen)
- [ ] AC7: Full *accept flow (acceptance_protocol + accept_command.steps) is UNCHANGED
- [ ] AC8: No changes to settings.json, no new hook scripts, no new shell scripts
- [ ] AC9: YOLO step_Y7 step 6.b includes "Update NEXT.md: mark corresponding entry [x]"
- [ ] AC10: STEP 3.5 zombie detection is READ-ONLY (no mv/write operations in STEP 3.5 action block)
- [ ] AC11: Cleanup actions live in new STEP 3.55, not in STEP 3.5

## 9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output |
|---|---------------------|-------------------|--------------------|--------------------|-----------------|
| 1 | AC1: quick_mode exists | post-impl-verifiable | `grep -c 'quick_mode:' .claude/skills/alex/SKILL.md` | 1 | (post-impl) |
| 2 | AC7: full accept unchanged | post-impl-verifiable | `grep -c 'step0_git_check:' .claude/skills/alex/SKILL.md` | 1 | (post-impl) |
| 3 | AC8: no settings.json changes | pre-impl-verifiable | `git diff --name-only .claude/settings.json` | empty output | ✅ empty (no changes) |
| 4 | AC5: no step_start ref in optimize | post-impl-verifiable | `grep -c 'step_start' .claude/skills/alex/SKILL.md` section after optimize_protocol | 0 in step2_aggregate | (post-impl) |
| 5 | AC4: zombie detection exists | post-impl-verifiable | `grep -c 'Zombie Handoff Detection' .claude/skills/alex/SKILL.md` | 1 | (post-impl) |

---

## 9.2 Expert Review Status

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0-1: quick_mode.steps YAML nesting ambiguity with accept_command.steps | §4.1 step3_update explicit indent note + §10.1 warning | Resolved |
| code-reviewer | P0-2: quick_mode Epic handling incomplete — last phase edge case | §4.1 step3_update rewritten with explicit scope-down (Phase Map only) | Resolved |
| code-reviewer | P0-3: AC gap — YOLO NEXT.md update uncovered | §9 AC9 added | Resolved |
| backend-architect | P0-1: *optimize slug matching unreliable — no join key spec | §4.4 step2 zombie rate rewritten with `file` field normalization + fallback | Resolved |
| backend-architect | P0-2: STEP 3.5 READ-ONLY contract violation | §4.3 split into STEP 3.5 (read-only scan) + STEP 3.55 (cleanup offer) | Resolved |
| code-reviewer | P1-1: suppress_if stale after zombie detection | §4.3 Part A includes updated suppress_if | Resolved |
| code-reviewer | P1-2: STEP 3.5 read-only contradiction | Same as ARCH-P0-2 above | Resolved |
| code-reviewer | P1-3: step2b Domain Pack proposals reference stale | §4.4 step2b update specified | Resolved |
| code-reviewer | P1-4: step3 target.file underspecified | §4.4 step3 updated with new target block | Resolved |
| backend-architect | P1-1: step_Y7 change is cosmetic, real fix is step 4b | §4.2 added note: "wording change is clarification; real fix is step 4b" | Resolved |
| backend-architect | P1-2: 7-day threshold false positives | §3.1 FR3 + §4.3 changed to 14 days + active-Epic exclusion | Resolved |
| backend-architect | P1-3: PROJECT_CONTEXT.md staleness drift | §4.1 step3_update added quick_accept_count soft reminder | Resolved |

### Experts Selected

1. **code-reviewer** — YAML structure integrity, AC coverage, section boundary safety
2. **backend-architect** — lifecycle design patterns, data flow integrity, cross-system consistency

### Overall Assessment (post-integration)

- code-reviewer: CONDITIONAL PASS → PASS (3 P0, 4 P1 resolved)
- backend-architect: CONDITIONAL PASS → PASS (2 P0, 3 P1 resolved)

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ Alex SKILL.md is ~6000 lines. Blake must use precise line targeting (Edit tool with exact old_string match). Do NOT read/rewrite the whole file.
- ⚠️ `acceptance_protocol:` (line ~4319) and `accept_command:` (line ~4494) are TWO DIFFERENT sections. Only modify `accept_command:`.
- ⚠️ STEP 3.5 的 "This is READ-ONLY - do not modify any files" 声明必须保留。zombie scan 追加在该声明之前。所有 file-modifying 操作在新的 STEP 3.55 中。
- ⚠️ STEP 3.55 插入位置：STEP 3.7 之后、STEP 3.8 之前。注意 `interacts_with` 字段与 STEP 3.7 的关系（Blake resume 时 suppress）。

### 10.2 Known Constraints
- This is prompt-level protocol only. Enforcement is via Alex reading its own SKILL.md at activation time.
- *accept --quick has NO mechanical enforcement preventing misuse. Users can run it on any handoff, including ones that should get full review. This is intentional per architecture.md "Mechanical Enforcement Rejected on Single-User CLI" decision.

### 10.3 Sub-Agent 使用建议
- [ ] **code-reviewer** — 验证 YAML 格式和逻辑一致性
- [ ] **test-runner** — 运行 §8.2 的 smoke test grep 命令

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | --quick scope | Minimum (mv+NEXT) vs Medium (mv+NEXT+AC check) vs Full minus KA | Minimum | 用户数据显示仪式=摩擦，最小化才能被使用 |
| 2 | Zombie detection placement | Alex startup vs *tad-maintain vs both | Alex startup | 主动提示 > 被动命令，让用户不需要记命令 |
| 3 | *optimize data source | Wait for step_start/step_end vs Use existing 4 types | Existing 4 types | 702 条数据已经够用，Domain Pack 已冻结 |
| 4 | Domain Pack trace (2b) | Wire trace-step.sh vs Redesign for Cap Pack vs Drop | Drop | Domain Pack 已冻结，trace-step.sh 目标对象不存在 |

---

**Required Evidence Manifest**:
```yaml
evidence:
  expert_reviews:
    - .tad/evidence/reviews/alex/lifecycle-health-improvements/code-reviewer.md
    - .tad/evidence/reviews/alex/lifecycle-health-improvements/backend-architect.md
  gate_verdicts:
    - Gate 2 in this document
  completion:
    - .tad/active/handoffs/COMPLETION-20260517-lifecycle-health-improvements.md
  blake_reviews:
    - .tad/evidence/reviews/blake/lifecycle-health-improvements/
```

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-05-17
**Version**: 3.1.0

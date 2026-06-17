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
**Task ID:** TASK-20260617-001
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260616-research-system-consolidation.md (Phase 2/4)

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-06-17

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 三项输入端质量改进的插入点和机制都已定义 |
| Components Specified | ✅ | Q1 决策点 + Q2 源验证 + Q3 语义饱和的具体实现方式 |
| Functions Verified | ✅ | 底层工具为现有 research-notebook CLI ask/source 命令 |
| Data Flow Mapped | ✅ | 用户输入 → 决策点确认 → 研究 → 源验证 → 饱和检查 → 产出 |

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
在 Phase 1 创建的 `*research` 统一协议基础上，添加三项输入端质量提升：(Q1) 研究前必须明确决策点，(Q2) 每个源都验证相关性，(Q3) 用语义反问代替机械计数判断饱和。

### 1.2 Why We're Building It
**业务价值**：研究产出从"一堆泛泛的信息"变成"能支撑具体决策的证据"
**用户受益**：研究问题更精准，源更相关，研究在真正回答了问题后才停止
**成功的样子**：用户说"研究 agent memory"→ Alex 先问"研究完想做什么决定？"→ 用户说"决定用哪个 memory 框架"→ 研究围绕框架选型展开，不跑偏

### 1.3 Intent Statement

**真正要解决的问题**：研究的问题太泛（清单题）、源太杂（无相关性过滤）、停止时机不对（机械计数而非语义判断）。

**不是要做的**：
- ❌ 不是修改 research-notebook ask 的 6 策略动态追问（保持现状）
- ❌ 不是修改输出格式（Phase 3）
- ❌ 不是添加验证或反馈循环（Phase 3）

---

## 📚 Project Knowledge（Blake 必读）

### 相关类别
- [x] architecture — *research 协议结构

### ⚠️ Blake 必须注意的历史教训

1. **NotebookLM 使用 -n flag** (patterns/research-methodology.md)
   - 所有 ask/source 操作使用 `-n <id>`，不用 `notebooklm use`

2. **Source Import Quality: False Success** (patterns/research-methodology.md)
   - `status: ready` 不代表内容质量好。源验证不能只看导入状态

3. **ask 动态追问协议保持现状** (Epic 决策)
   - Q3 语义饱和在 *research 层面包装，不改 ask 内部的 step3_5

---

## 2. Background Context

### 2.1 Current State (Phase 1 产出)
`research_unified_protocol` 已存在于 Alex SKILL.md L731-798。Standard 流程是：
1. 查找 notebook → 2. 创建（如需）→ 3. ask → 4. 返回结果

现在的问题：
- Step 1 之前没有决策点确认 → 问题太泛
- Step 2 的 fast-research 加源后没有相关性过滤 → 噪音源
- Step 3 的 ask 结束后没有语义检查 → 可能还没回答核心问题就停了

### 2.2 Dependencies
- Phase 1 的 `research_unified_protocol`（SKILL.md L731-798）
- `research-plan-protocol.md`（Deep 级别的详细流程）
- `research-notebook` SKILL.md（ask 命令，不修改内部）

---

## 3. Requirements

### 3.1 Functional Requirements

- FR1 (Q1): Standard/Deep 研究开始前，必须 AskUserQuestion 确认决策点："研究完你想做什么决定？"。用户回答后，研究问题改写为决策导向格式
- FR2 (Q1): 决策导向问题格式："基于 {用户目标}，{研究话题} 的哪个方案在 {决策维度} 方面证据最强？"。禁止"best practices for X"类泛问
- FR3 (Q2): Standard 级别在 fast-research 加源后，逐个验证相关性。方式：`notebooklm ask "源 '{title}' 和研究问题 '{question}' 相关吗？回答 RELEVANT 或 IRRELEVANT" -n <id>`
- FR4 (Q2): IRRELEVANT 的源立即删除。源总量上限 15（Standard）。超出时删最低相关性的
- FR5 (Q3): ask 返回后，在 *research 层面做语义饱和检查：`notebooklm ask "基于现有信息，你能完整回答 '{决策问题}' 吗？如果不能，缺什么信息？回答 COMPLETE 或 INCOMPLETE:{缺失子问题}" -n <id>`
- FR6 (Q3): COMPLETE → 结束研究。INCOMPLETE → 用缺失子问题再做一轮 ask（最多追加 2 轮）
- FR7: Deep 级别的 Phase 0（问题定义）也要应用 Q1（决策点确认），但不改变 Phase 0class 分级逻辑

### 3.2 Non-Functional Requirements

- NFR1: Q2 源验证每个源 ~30s，10 源 = ~5min。用户已接受此延迟
- NFR2: Q3 语义饱和在 *research 协议层包装，不修改 research-notebook ask 的 step3_5
- NFR3: Quick 级别不受 Q1/Q2/Q3 影响（Quick 是直接 WebSearch，无 notebook）

---

## 4. Technical Design

### 4.1 Q1: 决策点确认 — 插入到 standard_execution.step0

在现有 `1_find_notebook` 之前插入 `0_decision_point`：

```yaml
0_decision_point: |
  AskUserQuestion:
    question: "研究 '{topic}' 之前先确认：研究完你想做什么决定？"
    options:
      - "我想选择：{auto-detect options from topic, e.g., '选哪个框架/工具/方案'}"
      - "我想评估：{e.g., '评估 X 是否适合我们'}"
      - "我想了解全貌（探索型）"
      - (Other — 用户自定义)

  If user picks option 3 ("了解全貌"):
    → 重写研究问题为："关于 {topic}，目前有哪些主流方案，各自的适用场景和局限是什么？"
    （仍是结构化问题，不是 "best practices for X"）

  If user picks option 1/2 or custom:
    → decision_context = user's answer
    → 重写研究问题为："基于 {decision_context}，{topic} 的哪个方案证据最强？具体比较 {维度}。"

  决策点存入 session context: research_decision_point = {user's answer}
  (后续 Q3 语义饱和检查引用此值)
```

### 4.2 Q2: 源相关性验证 — 插入到 standard_execution.step2 之后

在 `2_create_if_needed`（fast-research 完成后）和 `3_ask` 之间插入 `2b_source_verify`：

```yaml
2b_source_verify: |
  source_list=$(~/.tad-notebooklm-venv/bin/notebooklm source list --json -n <id>)
  total=$(echo "$source_list" | jq 'length')

  For each source (all sources, no sampling):
    title=$(echo "$source_list" | jq -r ".[$i].title")
    source_id=$(echo "$source_list" | jq -r ".[$i].id")

    # Skip non-ready sources (preparing/processing/error)
    status=$(echo "$source_list" | jq -r ".[$i].status")
    if status != "ready": skip

    # Relevance check via --source scoped ask (P0-1 fix: scope to single source)
    verdict=$(~/.tad-notebooklm-venv/bin/notebooklm ask \
      "Is this source relevant to the research question: '${research_question}'? \
       Answer ONLY with RELEVANT or IRRELEVANT." \
      -n <id> --source "$source_id" -c 00000000-0000-0000-0000-000000000000)

    if verdict starts with "IRRELEVANT":
      ~/.tad-notebooklm-venv/bin/notebooklm source delete "$source_id" -n <id> --yes || \
        log "⚠️ Delete failed for source $source_id, keeping it"
      deleted_count += 1

    # Unexpected response (neither RELEVANT nor IRRELEVANT) → default keep
    sleep 1  # rate limit protection

  Report: "🔍 Source verification: {total} checked, {deleted_count} irrelevant removed, {total - deleted_count} retained"

  # Cap enforcement (Standard only, not Deep)
  remaining=$(~/.tad-notebooklm-venv/bin/notebooklm source list --json -n <id> | jq 'length')
  if remaining > 15:
    log "⚠️ Source count {remaining} exceeds 15 cap. Consider running *research-notebook curate."
    (Advisory warning, not auto-delete — user may have added manual sources)

  Note: --source flag scopes the ask to a single source's content (research-notebook SKILL.md Step 2.5).
  This prevents cross-source content leakage in relevance judgment.
```

### 4.3 Q3: 语义饱和 — 插入到 standard_execution.step3 之后

在 `3_ask`（ask + 动态追问完成后）和 `4_return` 之间插入 `3b_semantic_saturation`：

```yaml
3b_semantic_saturation: |
  max_extra_rounds: 2
  extra_round: 0

  # Fallback: if research_decision_point is unset (should not happen), use original research question
  check_target = research_decision_point || original_research_question

  LOOP:
    saturation_check=$(~/.tad-notebooklm-venv/bin/notebooklm ask \
      "Based on all information available to you, can you fully answer this decision question: \
       '${check_target}'? \
       If YES: respond COMPLETE. \
       If NO: respond INCOMPLETE followed by the specific sub-question that remains unanswered." \
      -n <id> -c 00000000-0000-0000-0000-000000000000)

    if saturation_check starts with "COMPLETE":
      → Report: "✅ Semantic saturation: research question fully answered after {extra_round} extra rounds"
      → EXIT LOOP → proceed to step 4

    if saturation_check starts with "INCOMPLETE" AND extra_round < max_extra_rounds:
      → Extract missing_sub_question from saturation_check
      → Report: "🔄 Semantic gap: '{missing_sub_question}'. Running targeted follow-up..."
      → followup_answer=$(~/.tad-notebooklm-venv/bin/notebooklm ask "{missing_sub_question}" -n <id>)
        (Raw CLI — NOT *research-notebook ask — avoids nested step3_5 loop.
         This is intentional: step3_5 already exhausted its own citation-based saturation.
         Q3 follow-ups use a DIFFERENT question angle — the missing sub-question — not a re-ask.)
      → Citation-based exit check (P0-2 fix):
        new_citations=$(echo "$followup_answer" | grep -oE '\[[0-9]+\]' | sort -u | wc -l)
        if new_citations == 0:
          → Report: "⚠️ Semantic gap identified but no new information in notebook. Proceeding with partial results."
          → EXIT LOOP → proceed to step 4
      → extra_round += 1
      → sleep 1
      → LOOP back

    if extra_round >= max_extra_rounds:
      → Report: "⚠️ After {max_extra_rounds} extra rounds, question not fully answered. Proceeding with partial results."
      → EXIT LOOP → proceed to step 4

    # Unexpected response (neither COMPLETE nor INCOMPLETE):
    → Report: "⚠️ Saturation check returned unexpected format. Proceeding with partial results."
    → EXIT LOOP → proceed to step 4
    # (Default to exit with warning, not silent COMPLETE — per Arch P1-3 fix)

  Two-tier saturation model (for Blake's understanding):
  - Inner tier (step3_5): citation-based, runs INSIDE *research-notebook ask. Detects "no new information found."
  - Outer tier (Q3): semantic, runs AFTER ask completes. Detects "information found but decision question not yet answered."
  - They measure different things. Q3 only fires extra rounds when the inner tier stopped but the decision isn't answered.
  - Q3 follow-ups are SHALLOW (raw CLI, no step3_5) because the inner tier already exhausted deep exploration.
  - Citation-based exit check prevents Q3 from burning API calls when the notebook truly has nothing more to offer.
```

### 4.4 Deep 级别的 Q1 集成

在 `research-plan-protocol.md` 的 Phase 0（问题定义）之前插入决策点确认。具体：在 `step1` (读取目标 + 现有研究) 之后、`step2` (生成研究计划) 之前，添加同样的 `0_decision_point` 步骤。如果有 OBJECTIVES.md，优先从 KR 推导决策上下文（现有行为），否则 AskUserQuestion。

Deep 级别的 Q3 不需要单独实现——Deep 已有 Phase 4b CRAG gap detection + Phase 4c adversarial challenge（功能上覆盖 Q3 的语义饱和意图，且更强）。

Deep 级别的 Q2 注意：Phase 2 auto-curate 只清理 error 源和去重，**不验证源与研究问题的相关性**。不相关但正常导入的源会作为 dead weight 留在 notebook 中。这是已知差异——Deep 的更大源量和 Phase 4b CRAG 间接补偿（不相关源不会被引用，gap detection 会补充相关源）。如果未来需要，可在 Deep Phase 2 后增加 Q2 风格的相关性验证。

### 4.5 降级路径下 Q1/Q2/Q3 的行为

当 NotebookLM preflight 失败（降级为 WebSearch）时：
- **Q1（决策点确认）**：正常执行。Q1 是 AskUserQuestion，不依赖 NotebookLM
- **Q2（源验证）**：跳过。WebSearch 结果无 notebook 源可验证
- **Q3（语义饱和）**：跳过。无 notebook 可反问

---

## 6. Implementation Steps

### Step 1: 修改 `standard_execution` (Alex SKILL.md L768-788)

在 `1_find_notebook` 之前插入 `0_decision_point`（§4.1 的设计）。
在 `2_create_if_needed` 之后插入 `2b_source_verify`（§4.2 的设计）。
在 `3_ask` 之后插入 `3b_semantic_saturation`（§4.3 的设计）。

### Step 2: 修改 `research-plan-protocol.md`

在 `step1` 之后、`step2` 之前插入决策点确认。保留现有 OBJECTIVES 推导逻辑——如果有 OBJECTIVES，用 KR 作为 decision_context；如果没有，用 AskUserQuestion。

### Step 3: 更新问题格式规则

在 `research-plan-protocol.md` 的 Phase 4 Step 1 (seed question generation) 中，强化问题格式规则：
- 现有的 "specificity anchor" 规则保留
- 新增：每个 seed question 必须引用 `research_decision_point`
- 新增：禁止纯清单题（"有哪些 X"→ 改写为"对于 {decision}，X 的哪些方案最相关"）

---

## 7. File Structure

### 7.1 Files to Create
无

### 7.2 Files to Modify
```
.claude/skills/alex/SKILL.md                                    # standard_execution 插入 3 个新步骤
.claude/skills/alex/references/research-plan-protocol.md         # Deep 级别 Q1 集成 + 问题格式强化
```

### 7.3 Grounded Against
- `.claude/skills/alex/SKILL.md` L730-798 (read 2026-06-17 — research_unified_protocol)
- `.claude/skills/alex/references/research-plan-protocol.md` (read 2026-06-16 — full file)
- `.claude/skills/research-notebook/SKILL.md` L273-488 (read 2026-06-16 — ask + step3_5)

---

## 8. Testing Requirements

### 8.1 Edge Cases
- 用户选"了解全貌"时，问题仍需结构化（不能退化为 "best practices"）
- 源验证返回非 RELEVANT/IRRELEVANT 的意外回答 → 默认保留该源
- 语义饱和返回非 COMPLETE/INCOMPLETE 的意外回答 → 退出并报 warning（不假装 COMPLETE）
- 新建的 notebook 还没有源时（step 2 的 fast-research 还在 indexing）→ step 2b 跳过 status != "ready" 的源
- `source list --json` 返回空数组（fast-research 全失败）→ 跳过 step 2b，直接进 step 3（ask 可能也无结果，但不阻塞流程）
- Q2 删除了全部源（每个都 IRRELEVANT）→ 报告 "⚠️ All sources judged irrelevant. Research may have poor coverage." 然后继续（不阻塞）
- 用户的决策点回答很短或模糊（如"不知道"）→ Alex 追问一次 "能具体一点吗？比如你是想选工具、评估方案、还是了解全貌？"，如果仍模糊则按"了解全貌"处理
- source delete 失败（网络错误等）→ 记录 warning，继续下一个源，不中断验证循环

## 8.4 Friction Preflight

| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|----------------|---------------|-------------------|--------------------|-------------|
| 无 | — | — | — | — |

## 8.5 Feedback Collection
N/A

---

## 9. Acceptance Criteria

- [ ] Standard 研究在 step 1 之前有决策点确认步骤（AskUserQuestion）
- [ ] 决策点回答被用于重写研究问题（决策导向格式）
- [ ] fast-research 后逐个验证源相关性并删除不相关源
- [ ] ask 完成后有语义饱和检查（最多追加 2 轮）
- [ ] Deep 级别 Phase 0 包含决策点确认

## 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output |
|---|---------------------|-------------------|--------------------|--------------------|-----------------|
| AC1 | 决策点步骤存在 | post-impl-verifiable | `grep '0_decision_point' .claude/skills/alex/SKILL.md` | ≥1 match | (post-impl) |
| AC2 | 决策导向问题格式 | post-impl-verifiable | `grep -c 'research_decision_point\|decision_context' .claude/skills/alex/SKILL.md` | ≥3 | (post-impl) |
| AC3 | 源验证步骤存在 | post-impl-verifiable | `grep '2b_source_verify' .claude/skills/alex/SKILL.md` | ≥1 match | (post-impl) |
| AC4 | 源验证用 RELEVANT/IRRELEVANT 判定 | post-impl-verifiable | `grep -c 'RELEVANT\|IRRELEVANT' .claude/skills/alex/SKILL.md` | ≥2 | (post-impl) |
| AC5 | 语义饱和步骤存在 | post-impl-verifiable | `grep '3b_semantic_saturation' .claude/skills/alex/SKILL.md` | ≥1 match | (post-impl) |
| AC6 | 语义饱和引用决策点 | post-impl-verifiable | `grep 'research_decision_point' .claude/skills/alex/SKILL.md` | 在 3b_semantic_saturation 段落中出现 | (post-impl) |
| AC7 | 语义饱和最多 2 轮追加 | post-impl-verifiable | `grep 'max_extra_rounds.*2' .claude/skills/alex/SKILL.md` | ≥1 match | (post-impl) |
| AC8 | Deep 级别 Q1 集成 | post-impl-verifiable | `grep -c 'decision_point\|决策点' .claude/skills/alex/references/research-plan-protocol.md` | ≥2 | (post-impl) |
| AC9 | 问题格式强化（禁止泛问） | post-impl-verifiable | `grep 'best.practices\|禁止.*清单' .claude/skills/alex/references/research-plan-protocol.md` | ≥1 match | (post-impl) |
| AC10 | research-notebook ask 未被修改 | post-impl-verifiable | `git diff .claude/skills/research-notebook/SKILL.md \| wc -l` | 0 (no changes) | (post-impl) |

---

## 9.2 Expert Review Status

### Experts Selected

1. **code-reviewer** — SKILL.md 修改质量 + 新步骤的边界情况处理
2. **backend-architect** — 源验证和语义饱和的延迟/可靠性设计

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0-1: Q2 ask 无法判断单源相关性——需 --source flag | §4.2 — 改用 `--source <source_id>` 定向 ask | Resolved |
| code-reviewer | P0-2: Q3 与 step3_5 饱和交互未定义，可能冲突 | §4.3 — 添加两层饱和模型说明 + citation-based exit check | Resolved |
| backend-architect | P1-1: Q2 indexing race condition (ready ≠ 完全索引) | §10.1 — 添加 warning；源验证用 --source 定向减轻影响 | Resolved |
| backend-architect | P1-2: Q2 ask 判断不可靠（同 CR P0-1） | §4.2 — 同上，用 --source flag 解决 | Resolved |
| backend-architect | P1-3: Q3 COMPLETE 默认方向错误 | §4.3 — unexpected response 改为退出+warning，不假装 COMPLETE | Resolved |
| code-reviewer | P1-1: Section 5 缺失，降级路径未覆盖 | §4.5 — 新增降级路径行为说明 | Resolved |
| code-reviewer | P1-2: Q2 delete 失败无处理 | §4.2 + §8.1 — 添加 `\|\| log` + edge case | Resolved |
| code-reviewer | P1-3: research_decision_point 无 fallback | §4.3 — 添加 fallback to original question | Resolved |
| code-reviewer | P1-5: Deep Q2 等价声明不准确 | §4.4 — 诚实标注差异：curate=清错误，Q2=清不相关 | Resolved |
| backend-architect | P2-1: Q3 follow-up 与 step3_5 可能重复 | §4.3 — citation-based exit check + 两层模型说明 | Resolved |
| backend-architect | P2-3: Q1 repeat friction | §10.2 — 记为已知约束（用户选择 always-require） | Deferred |

### Overall Assessment (post-integration)

- **code-reviewer**: CONDITIONAL PASS → PASS (2 P0 resolved, 4 P1 resolved)
- **backend-architect**: PASS (0 P0, 3 P1 resolved, 1 P2 deferred)

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ research-notebook ask 的 step3_5 动态追问不修改。Q3 语义饱和是 *research 层面的包装
- ⚠️ Q2 源验证会增加 ~5 分钟延迟（10 源 × ~30s）。用户已知悉并接受
- ⚠️ Q3 的 semantic saturation ask 使用 `-c 00000000...` 强制新对话，避免被上一轮 ask 的上下文干扰

### 10.2 Known Constraints
- 源验证的 RELEVANT/IRRELEVANT 判定依赖 NotebookLM 的 LLM 能力，可能有误判。默认保留（意外回答 = 保留）
- 语义饱和的 COMPLETE/INCOMPLETE 同理。默认 COMPLETE（保守退出）

---

## 11. Decision Rationale

### 11.1 为什么全部验证源而不是抽样

| 方案 | 优点 | 缺点 | 为什么没选 |
|------|------|------|-----------|
| 全部验证（选中）| 质量最高，无噪音源 | 延迟 5min+ | ✅ 用户选择 |
| 只验证前 5 个 | 快 | 后 5 个可能全是噪音 | 用户否决 |
| 不验证 | 最快 | 研究质量无改善 | 违背 Epic 目标 |

### 11.2 为什么总是要求用户先明确决策点

| 方案 | 优点 | 缺点 | 为什么没选 |
|------|------|------|-----------|
| 总是要求（选中）| 研究永远有方向 | 纯探索时多一步 | ✅ 用户选择 |
| 用 OBJECTIVES 推导 | 自动化 | 没有 OBJECTIVES 就退化 | 不够通用 |
| 纯探索允许泛问 | 灵活 | 研究质量不稳定 | 违背 Q1 目标 |

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-06-17
**Version**: 3.1.0

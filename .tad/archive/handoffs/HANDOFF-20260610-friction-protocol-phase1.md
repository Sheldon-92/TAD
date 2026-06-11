---
task_type: mixed
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
**Date:** 2026-06-10
**Project:** TAD Framework
**Task ID:** TASK-20260610-001
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260610-friction-protocol.md (Phase 1/2)
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-06-10

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Two-phase architecture: Phase 1 body/templates/Gate text; Phase 2 advisory checker |
| Components Specified | ✅ | Alex SKILL, Blake SKILL, Gate SKILL, handoff template, completion template |
| Functions Verified | ✅ | This is protocol/template work; no existing callable function contract is changed in Phase 1 |
| Data Flow Mapped | ✅ | Gate 2 preflight → Blake execution friction table → Gate 3 block/pass → Gate 4 review |
| Friction Preflight Defined | ✅ | See §8.4 and §9.1 AC rows |
| Expert Review Integrated | ✅ | code-reviewer + backend-architect CONDITIONAL PASS findings integrated in §9.2 |

**Gate 2 结果**: ✅ PASS after expert review integration

**Alex确认**: 我已验证设计要素，Blake可以独立根据本文档完成 Phase 1 实现。Phase 2 checker 不在本 handoff 范围内。

---

## 📋 Handoff Checklist (Blake必读)

Blake在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 理解本任务的真正意图：防止遇到摩擦时跳过 TAD 流程
- [ ] 理解 Phase 2 checker 不在本次范围内
- [ ] 每个文件的协议插入点和证据要求都清楚
- [ ] 确认可以独立使用本文档完成实现

❌ 如果任何部分不清楚，**立即返回Alex要求澄清**，不要开始实现。

---

## 1. Task Overview

### 1.1 What We're Building
Add a core "TAD Friction Protocol" to the load-bearing Alex/Blake/Gate rules and the two main templates. The protocol prevents required steps from being skipped when dependencies, permissions, approvals, reviewers, or environment setup create friction.

### 1.2 Why We're Building It
**业务价值**: TAD 的核心承诺是质量链可靠。演示 Codex TAD 时发现 Alex/Blake 会因为依赖、approval、专家审核或设置麻烦而跳流程，这会把 TAD 的 Gate 变成纸面流程。

**用户受益**: 用户看到 `BLOCKED` 就知道需要补环境或批准，而不是被一个不完整的 `PASS` 误导。

**成功的样子**: 当 Blake 无法安装依赖、无法调用 reviewer、需要 approval、或遇到 auth/network/sandbox 限制时，completion report 明确记录状态；Gate 3/4 不会把未解决摩擦接受为 PASS。

### 1.3 Intent Statement

**真正要解决的问题**: 遇到摩擦时，agent 必须“迎难而上”：请求补齐、记录等价替代、或阻断。不能因为麻烦就跳过。

**不是要做的（避免误解）**:
- ❌ 不是新建一个复杂的强制 hook 系统；Phase 1 不做 mechanical checker。
- ❌ 不是让 agent 任意安装依赖；必须按现有权限/approval 模型请求。
- ❌ 不是允许人类一句“算了”就无证据跳过；override 必须记录风险和理由。
- ❌ 不是把所有场景都变成硬阻断；职责等价的替代可以通过，但必须有 evidence。

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别

本次任务涉及：
- [x] architecture - TAD 方法论和 Gate 流程
- [x] code-quality - SKILL body 约束和模板一致性
- [x] testing - AC 设计和验证命令

### 步骤 2：历史经验摘录

**已读取的 project-knowledge 文件**：

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| `.tad/project-knowledge/principles.md` | 4 | 约束规则不能从 body 移走；express 不免审核；单用户 CLI 用 smoke alarm；执行纪律必须留 body |
| `.tad/project-knowledge/patterns/gate-design.md` | 4 | Gate 3/4 分责；review 必须是独立层；cross-cutting concern 应嵌入现有流程 |
| `.tad/project-knowledge/patterns/handoff-design.md` | 4 | circular trigger 内容必须留 body；跨平台假设要重新验证；step 插入要审 predecessor transitions |
| `.tad/project-knowledge/patterns/ac-verification.md` | 2 | AC 是操作契约；验证命令必须 dry-run |
| `.tad/project-knowledge/patterns/hook-contracts.md` | 1 | 单用户 CLI 不应新增硬 hook/settings 作为 Phase 1 |

**⚠️ Blake 必须注意的历史教训**：

1. **Execution Discipline Content Must Stay in SKILL Body** (`principles.md`, `handoff-design.md`)
   - 问题：Codex 真实测试中，reference 没加载导致 Blake 跳过 Layer 2 / completion report。
   - 解决方案：本次 Friction Protocol 必须写进 Alex/Blake/Gate 的 load-bearing body，不只放 references。

2. **Express Handoff is NOT Review-Exemption** (`principles.md`)
   - 问题："小任务/express" 容易被 rationalize 成不用 expert review。
   - 解决方案：Friction Protocol 必须明确 reviewer 不可用是 `BLOCKED` 或等价替代，不是 N/A。

3. **Mechanical Enforcement Rejected on Single-User CLI** (`principles.md`)
   - 问题：硬 hook 在缺依赖时 fail-closed，日常恢复成本过高。
   - 解决方案：Phase 1 不注册 hook、不改 settings；Phase 2 checker 是 advisory smoke alarm。

4. **Cognitive Firewall: Embed Into Existing Flows** (`handoff-design.md`)
   - 问题：单独命令容易被跳过。
   - 解决方案：Friction Protocol 要嵌入 Gate 2、Ralph Loop/Gate 3、Gate 4，不做孤立文档。

5. **Alex Handoff AC Design Rules** (`ac-verification.md`)
   - 问题：AC 里没写的证据等于可选。
   - 解决方案：§9.1 必须包含 enum/table anchor 的验证命令。

### Blake 确认

- [ ] 我已阅读上述历史经验
- [ ] 我理解需要避免的问题
- [ ] 如遇到类似情况，我会参考上述解决方案

---

## 2. Background Context

### 2.1 Previous Work
TAD already has strong rules for Gate 3, Layer 2, and completion reports, including:
- Blake Layer 2 reviewer tiers in `.agents/skills/blake/SKILL.md`
- Gate 3 §9.1 row-by-row verification in `.agents/skills/gate/SKILL.md`
- Handoff §9.1 primary verification source in `.tad/templates/handoff-a-to-b.md`
- Completion report evidence checklist in `.tad/templates/completion-report.md`

### 2.2 Current State
The rules block missing evidence at Gate time, but they do not define what to do when friction appears before evidence exists. This lets an agent misclassify "dependency missing", "approval needed", "reviewer unavailable", or "auth expired" as "not applicable" or "skip".

### 2.3 Dependencies
- No new runtime dependency in Phase 1.
- No new hook registration.
- No `.claude/settings.json` modification.
- Use current TAD docs/templates only.

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1: Define a TAD Friction Protocol in load-bearing body text.
- FR2: Use fixed status enum exactly: `READY / BLOCKED / DEGRADED_WITH_APPROVAL / EQUIVALENT_SUBSTITUTE / NOT_APPLICABLE_WITH_REASON`.
- FR3: Require missing dependency/permission/auth/approval to trigger request-to-fix first, not skip.
- FR4: Allow equivalent substitute only when duties are equivalent and evidence is recorded.
- FR5: Allow human override only when risk and rationale are recorded.
- FR6: Add Gate 2 Friction Preflight to handoff template.
- FR7: Add Gate 3 Friction Status table to completion report template.
- FR8: Add Gate 3 and Gate 4 checks to Gate SKILL text.

### 3.2 Non-Functional Requirements
- NFR1: Keep changes narrowly scoped; no Phase 2 checker script in this handoff.
- NFR2: Do not create or modify hooks/settings.
- NFR3: Use ASCII-only text unless editing an already non-ASCII surrounding block.
- NFR4: Preserve existing TAD semantics: Gate 3 technical, Gate 4 business acceptance.
- NFR5: Maintain Codex + Claude Code portability; wording must mention both platform approval/auth friction.

---

## 4. Design

### 4.1 Status Enum Contract
Use this exact enum in all protocol surfaces:

```text
READY
BLOCKED
DEGRADED_WITH_APPROVAL
EQUIVALENT_SUBSTITUTE
NOT_APPLICABLE_WITH_REASON
```

Meaning:
- `READY`: prerequisite/tool/reviewer is available or completed.
- `BLOCKED`: required step cannot proceed; Gate PASS is forbidden until resolved.
- `DEGRADED_WITH_APPROVAL`: user explicitly approved a weaker path and risk/rationale are recorded.
- `EQUIVALENT_SUBSTITUTE`: original mechanism unavailable, but replacement has equivalent duty and evidence.
- `NOT_APPLICABLE_WITH_REASON`: genuinely out of scope, with concrete reason tied to task type/scope.

For reviewer or expert-review friction, `EQUIVALENT_SUBSTITUTE` must preserve independence, scope, and expertise. Blake self-review, feedback-integration notes, or a Gate verdict written by Blake are never equivalent substitutes for required expert review.

### 4.2 Default Action Ladder
When friction appears:
1. Identify the missing prerequisite.
2. Request the correct fix: install, auth, network approval, sandbox approval, dependency setup, or reviewer invocation.
3. If fix succeeds: mark `READY`.
4. If user explicitly approves weaker path: mark `DEGRADED_WITH_APPROVAL` with risk/rationale.
5. If a true equivalent exists: mark `EQUIVALENT_SUBSTITUTE` with why equivalent.
6. Otherwise mark `BLOCKED` and stop before PASS.

For `DEGRADED_WITH_APPROVAL`, the evidence must include approval source, date/context, accepted risk, and rationale.

### 4.3 Placement
Phase 1 must update:
- Alex body: Gate 2 obligations and anti-rationalization anchor.
- Blake body: Ralph Loop/Gate 3 execution obligations.
- Gate body: Gate 3/4 pass conditions.
- Handoff template: Friction Preflight table.
- Completion template: Friction Status table.

### 4.4 Phase 2 Deferred
Do NOT implement a checker now. Leave a short note that Phase 2 will create an advisory checker once table names are accepted.

---

## 5. Files to Modify

| Path | Action | Purpose |
|------|--------|---------|
| `.agents/skills/alex/SKILL.md` | MODIFY | Add Alex-side TAD Friction Protocol and Gate 2 duties in body |
| `.agents/skills/blake/SKILL.md` | MODIFY | Add Blake-side friction handling in Ralph Loop / completion body |
| `.agents/skills/gate/SKILL.md` | MODIFY | Add Gate 3/4 friction checks |
| `.tad/templates/handoff-a-to-b.md` | MODIFY | Add Gate 2 Friction Preflight section |
| `.tad/templates/completion-report.md` | MODIFY | Add Friction Status table |
| `NEXT.md` | MODIFY | Add/update active task note |

**Grounded Against**:
- `.agents/skills/blake/SKILL.md` read around Layer 2 and completion protocol on 2026-06-10.
- `.agents/skills/gate/SKILL.md` read around Gate 3 and Gate 4 on 2026-06-10.
- `.tad/templates/handoff-a-to-b.md` read around frontmatter, Gate 2, and §9.1 on 2026-06-10.
- `.tad/templates/completion-report.md` read on 2026-06-10.

---

## 6. Implementation Steps

### Step 1: Add Alex body rules
In `.agents/skills/alex/SKILL.md`, add a body-level section named `tad_friction_protocol` near other mandatory/anti-rationalization rules.

Concrete placement: insert before `# ⚠️ MANDATORY: Intent Router Protocol (First Contact)` and after the cross-model / global exclusion rules, so the protocol is loaded before route-specific references.

Required content:
- Fixed enum.
- Alex Gate 2 obligation: every handoff must declare friction-sensitive prerequisites or state none.
- Alex must not write "not applicable" without a concrete reason.
- If a handoff requires dependencies/tools/reviewers that may be absent, §8.4 Friction Preflight must list them.
- Cross-platform note: Codex sandbox/approval/auth and Claude Code permission/tool availability are friction, not skip reasons.

### Step 2: Add Blake body rules
In `.agents/skills/blake/SKILL.md`, add the same protocol in body-level execution rules.

Concrete placement: insert before `# Ralph Loop Execution Logic (TAD v2.0)` or immediately before the `ralph_loop_execution` section, so Blake sees the protocol before `2_layer1_loop`, `3_layer2_loop`, and completion flow.

Required content:
- Missing dependency/tool/auth/approval/reviewer is never a reason to skip.
- Blake must request the needed install/auth/approval first.
- Reviewer unavailable cannot become self-review; use `BLOCKED`, `DEGRADED_WITH_APPROVAL`, or `EQUIVALENT_SUBSTITUTE`.
- `BLOCKED` rows prevent Gate 3 PASS.
- Completion report must include Friction Status table.

### Step 3: Add Gate checks
In `.agents/skills/gate/SKILL.md`:
- Gate 3: after prerequisite/completion report check, verify completion report has Friction Status table.
- Gate 3: unresolved `BLOCKED` row means BLOCK Gate 3.
- Gate 3: `DEGRADED_WITH_APPROVAL` requires approval/risk/rationale evidence.
- Gate 3: `EQUIVALENT_SUBSTITUTE` requires replacement + why equivalent + evidence path.
- Gate 4: Alex reviews Blake's friction table for business acceptance blockers and evidence completeness; unresolved `BLOCKED` or unsubstantiated degradation prevents acceptance. Alex does not re-perform Gate 3 technical validation.

Concrete placement: insert the Gate 3 check after the existing Gate 3 `Prerequisite` block and before `Spec_Compliance_Verification`; insert the Gate 4 review after the Gate 4 `Prerequisite` block and before `Structural_Subagent_Conditionality`.

### Step 4: Update handoff template
In `.tad/templates/handoff-a-to-b.md`, add a `## 8.4 Friction Preflight` section before §9 or inside the implementation/requirements area where Blake will see it before implementation.

Required table columns:
- `Friction Point`
- `Required Step`
- `Expected Fix Path`
- `Allowed Substitute`
- `Gate Impact`

Add examples:
- reviewer unavailable
- dependency install required
- auth/approval required
- platform sandbox/network restriction

Also update this current handoff's §8.4 so Blake has a model for the new section.

### Step 5: Update completion template
In `.tad/templates/completion-report.md`, add `## ⚠️ Friction Status (MANDATORY — Gate 3 BLOCKING)` before Gate 3 result or before Evidence Checklist.

Required table columns:
- `Friction Point`
- `Status`
- `Action Taken`
- `Approval / Substitute Evidence`
- `Gate Impact`

For `DEGRADED_WITH_APPROVAL`, the evidence cell must include approval source, date/context, accepted risk, and rationale.

Add rule:
`Any unresolved BLOCKED row means Gate 3 cannot PASS.`

### Step 6: Update NEXT.md
Add this Epic/Phase 1 as an in-progress task if not already present, and ensure Phase 2 advisory checker remains visible as planned carry-forward after Phase 1 acceptance.

---

## 7. Required Evidence Manifest

```yaml
required_evidence:
  modified_files:
    - .agents/skills/alex/SKILL.md
    - .agents/skills/blake/SKILL.md
    - .agents/skills/gate/SKILL.md
    - .tad/templates/handoff-a-to-b.md
    - .tad/templates/completion-report.md
    - NEXT.md
  expert_reviews:
    alex_gate2:
      - .tad/evidence/reviews/alex/friction-protocol-phase1/2026-06-10-code-reviewer-handoff-review.md
      - .tad/evidence/reviews/alex/friction-protocol-phase1/2026-06-10-backend-architect-handoff-review.md
    blake_gate3_layer2:
      - .tad/evidence/reviews/blake/friction-protocol-phase1/*code-reviewer*.md
      - .tad/evidence/reviews/blake/friction-protocol-phase1/*backend-architect*.md
  completion:
    - .tad/active/handoffs/COMPLETION-20260610-friction-protocol-phase1.md
  gate_verdicts:
    - Gate 3 verdict in completion report frontmatter
```

---

## 8. Acceptance Criteria

- [ ] AC1: Alex SKILL body contains `tad_friction_protocol` and all five enum values.
- [ ] AC2: Blake SKILL body contains `tad_friction_protocol` and says unresolved `BLOCKED` rows prevent Gate 3 PASS.
- [ ] AC3: Gate SKILL contains Gate 3 Friction Status check and Gate 4 friction review check.
- [ ] AC4: Handoff template contains `## 8.4 Friction Preflight` with the required columns.
- [ ] AC5: Completion report template contains `## ⚠️ Friction Status (MANDATORY — Gate 3 BLOCKING)` with the required columns.
- [ ] AC6: No new hook/settings/checker script is created in Phase 1.
- [ ] AC7: NEXT.md references this active Epic or Phase 1 task.

---

## 8.4 Friction Preflight

| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|----------------|---------------|-------------------|--------------------|-------------|
| Alex Gate 2 expert review availability | code-reviewer + backend-architect review before sending to Blake | Save review evidence under `.tad/evidence/reviews/alex/friction-protocol-phase1/` and integrate P0/P1 findings into §9.2 | None for missing review; human may delay handoff but cannot mark review as complete | Handoff cannot be sent to Blake until resolved |
| SKILL body edit placement risk | Protocol must land in body-level load-bearing sections, not only references | Use concrete placement anchors from §6 Steps 1-3 | Equivalent body placement is allowed only if it is loaded before relevant route/execution flow | Gate 3/4 ACs must prove anchors exist |
| Phase 2 checker intentionally deferred | Do not implement checker/hook/settings in Phase 1 | Keep Phase 2 in Epic and NEXT carry-forward | Advisory checker may be designed later, not in this handoff | Creating checker/hook/settings in Phase 1 fails AC6 |
| Approval/auth/tool friction during Blake implementation | Request required permission/auth/install first | Use Codex escalation / Claude Code permission request / user approval as applicable | `DEGRADED_WITH_APPROVAL` only with approval source, date/context, accepted risk, rationale | Unresolved `BLOCKED` prevents Gate 3 PASS |
| Reviewer unavailable during Blake Layer 2 | Required reviewer must run or equivalent independent reviewer must replace it | Invoke required reviewer or a reviewer preserving independence, scope, and expertise | Self-review is never equivalent; equivalent substitute must cite evidence path | Missing or non-equivalent review prevents Gate 3 PASS |

---

## 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE — Gate 3 executes each row

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| 1 | AC1 Alex SKILL body protocol exists | post-impl-verifiable | `for s in tad_friction_protocol READY BLOCKED DEGRADED_WITH_APPROVAL EQUIVALENT_SUBSTITUTE NOT_APPLICABLE_WITH_REASON; do rg -q "$s" .agents/skills/alex/SKILL.md || exit 1; done` | exit 0; every listed string exists in Alex SKILL body | (post-impl) |
| 2 | AC2 Blake SKILL body protocol exists | post-impl-verifiable | `for s in tad_friction_protocol READY BLOCKED DEGRADED_WITH_APPROVAL EQUIVALENT_SUBSTITUTE NOT_APPLICABLE_WITH_REASON; do rg -q "$s" .agents/skills/blake/SKILL.md || exit 1; done; rg -q -e "BLOCKED.*Gate 3.*PASS" -e "Gate 3.*PASS.*BLOCKED" .agents/skills/blake/SKILL.md` | exit 0; enum exists and unresolved BLOCKED Gate 3 PASS rule exists | (post-impl) |
| 3 | AC3 Gate SKILL friction checks exist | post-impl-verifiable | `for s in "Friction Status" DEGRADED_WITH_APPROVAL EQUIVALENT_SUBSTITUTE "BLOCK Gate 3" "Gate 4"; do rg -q "$s" .agents/skills/gate/SKILL.md || exit 1; done; rg -q -e "BLOCKED.*Gate 3" -e "Gate 3.*BLOCKED" .agents/skills/gate/SKILL.md` | exit 0; Gate 3 and Gate 4 friction rules exist | (post-impl) |
| 4 | AC4 handoff template preflight exists | post-impl-verifiable | `for s in "## 8.4 Friction Preflight" "Friction Point" "Expected Fix Path" "Allowed Substitute" "Gate Impact"; do rg -qF "$s" .tad/templates/handoff-a-to-b.md || exit 1; done` | exit 0; section and all required columns exist | (post-impl) |
| 5 | AC5 completion template status exists | post-impl-verifiable | `for s in "Friction Status (MANDATORY" "Friction Point" "Action Taken" "Approval / Substitute Evidence" "Any unresolved BLOCKED"; do rg -qF "$s" .tad/templates/completion-report.md || exit 1; done` | exit 0; section and all required columns exist | (post-impl) |
| 6 | AC6 no Phase 2 checker/hook/settings changes | post-impl-verifiable | `git status --short \| rg -e "friction-status-check" -e "\\.claude/settings\\.json" -e "\\.tad/hooks/.*friction" \|\| true` | no output for checker/settings/hook paths, including untracked files | (post-impl) |
| 7 | AC7 NEXT.md references task | post-impl-verifiable | `rg -n "Friction Protocol|friction-protocol" NEXT.md` | output includes active or priority task | (post-impl) |

---

## 9.2 Expert Review Status (Alex 必填)

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| backend-architect | P0: Draft referenced §8.4 Friction Preflight but did not include it | §8.4 added with task-specific friction rows | Resolved |
| backend-architect | P1: Gate 2 marked PASS while expert review was pending | Gate 2 now states PASS after expert review integration; §9.2 contains review evidence | Resolved |
| backend-architect | P1: AC verification regexes were broad and could pass on partial anchors | §9.1 rows now use per-anchor checks; pipe-sensitive regexes use `rg -e` | Resolved |
| backend-architect | P1: Phase 2 checker deferral lacked explicit backlog hook | Epic Phase 2 and NEXT requirement preserved in §6 Step 6 and Epic context | Resolved |
| backend-architect | P2: Equivalent substitute needed explicit negative example | §4.1 now states self-review is never equivalent for expert review | Resolved |
| code-reviewer | P1: §9.1 alternation checks did not prove every enum/column anchor exists | §9.1 rows 1, 4, and 5 now use per-anchor checks | Resolved |
| code-reviewer | P1: AC6 missed untracked forbidden checker/hook/settings files | AC6 now uses `git status --short` instead of `git diff --name-only` | Resolved |
| code-reviewer | P1: Body-level insertion points were too vague | §6 Steps 1-3 now name concrete placement anchors | Resolved |
| code-reviewer | P1: Override evidence lacked approval source/date/risk fields | §4.2 and Step 5 now require approval source, date/context, accepted risk, rationale | Resolved |
| code-reviewer | P2: Alex Gate 2 review evidence path confused with Blake Layer 2 | §7 manifest now separates `alex_gate2` and `blake_gate3_layer2` evidence | Resolved |

### Experts Selected

1. **code-reviewer** — verify ACs, template anchors, and body rules are concrete enough for Blake.
2. **backend-architect** — verify cross-flow placement across Alex/Blake/Gate prevents bypass without overbuilding mechanical enforcement.

### Overall Assessment (post-integration)

- backend-architect: CONDITIONAL PASS (1 P0 + 3 P1 + 2 P2 resolved)
- code-reviewer: CONDITIONAL PASS (0 P0 + 4 P1 + 2 P2 resolved)

---

## 10. Important Notes

### 10.1 Scope Boundary
Do not implement Phase 2 checker in this handoff. The checker depends on accepted table names and enum strings.

### 10.2 Forbidden Implementations
- Do not register hooks.
- Do not modify `.claude/settings.json`.
- Do not add hard-blocking tooling in this phase.
- Do not move Friction Protocol only into references; it must be in body.
- Do not allow self-review to count as equivalent substitute for expert review.

### 10.3 Platform Notes
Codex-specific friction includes sandbox approval, network restriction, auth expiry, dependency install escalation, and subagent/tool availability. Claude Code-specific friction includes tool permission prompts, plugin/hook availability, and subagent quota/refusal. Both platforms follow the same enum and evidence rules.

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Placement | body only / templates only / body+templates / all including checker | Body + templates + Gate text now; checker later | Body avoids circular-trigger loss; templates make evidence visible |
| 2 | Status language | free text / PASS-BLOCKED / per-Gate / fixed enum | Fixed enum | Prevents vague "N/A" or "looks okay" drift |
| 3 | Missing dependency default | block immediately / request fix first / local substitute first / risk-tier | Request fix first, then block or documented exception | Matches HITL approval patterns and user expectation to face friction |
| 4 | Mechanical checker timing | now / never / phase 2 | Phase 2 | Avoids overbuilding and follows single-user CLI smoke-alarm principle |

---

## 12. Message to Blake

```
📨 Message to Blake (Terminal 2)
────────────────────────────────
Task:      TAD Friction Protocol Phase 1
Handoff:   .tad/active/handoffs/HANDOFF-20260610-friction-protocol-phase1.md
Priority:  P0 process integrity
Scope:     Add Friction Protocol to Alex/Blake/Gate body text and handoff/completion templates. Do not implement Phase 2 checker.

Files:
- .agents/skills/alex/SKILL.md
- .agents/skills/blake/SKILL.md
- .agents/skills/gate/SKILL.md
- .tad/templates/handoff-a-to-b.md
- .tad/templates/completion-report.md
- NEXT.md

Critical constraints:
- Use the exact enum: READY / BLOCKED / DEGRADED_WITH_APPROVAL / EQUIVALENT_SUBSTITUTE / NOT_APPLICABLE_WITH_REASON.
- Missing dependency, auth, approval, reviewer, or setup friction is never a skip reason.
- Request the correct fix first; if unresolved, report BLOCKED instead of PASS.
- Self-review is never an equivalent substitute for required expert review.
- Do not create Phase 2 checker, hooks, or settings changes in this phase.

Required evidence:
- Run every §9.1 verification row.
- Save Blake Layer 2 reviewer artifacts under .tad/evidence/reviews/blake/friction-protocol-phase1/.
- Completion report must include Friction Status.
```

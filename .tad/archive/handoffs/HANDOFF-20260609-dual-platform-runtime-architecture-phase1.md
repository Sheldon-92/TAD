---
task_type: research
e2e_required: no
research_required: yes
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)  
**To:** Blake (Agent B - Execution Master)  
**Date:** 2026-06-09  
**Project:** TAD Framework  
**Task ID:** TASK-20260609-002  
**Handoff Version:** 3.1.0  
**Epic:** EPIC-20260609-dual-platform-native-runtime-architecture.md (Phase 1/5)  
**Priority:** P1, blocked until P0 `EPIC-20260609-skill-body-reference-boundary` reaches Phase 3 acceptance unless Human explicitly overrides.

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-06-09

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Phase 1 scope is a read-only architecture audit/design deliverable with explicit platform-boundary decisions |
| Components Specified | ✅ | Inputs, output document structure, capability matrix, freshness model, and ACs are defined |
| Functions Verified | ✅ | No production code functions involved; this task creates one design evidence artifact |
| Data Flow Mapped | ✅ | Inputs: TAD docs + SKILLs + current Codex/Claude Code evidence → Output: architecture decision document |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 我已验证所有设计要素。Blake can independently complete Phase 1 from this handoff, but must not start execution before the blocker condition is cleared unless Human explicitly overrides.

---

## 📋 Handoff Checklist (Blake必读)

Blake在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 理解该任务是 Phase 1 design-only，不修改 runtime/config/docs
- [ ] 理解 Codex capability claims must be current-source verified
- [ ] 理解新鲜度机制是本架构的一等约束，不是附录
- [ ] 确认可以独立使用本文档完成实现

❌ 如果任何部分不清楚，立即返回 Alex 要求澄清，不要开始实现。

---

## 1. Task Overview

### 1.1 What We're Building

Create the Phase 1 architecture decision document for TAD's dual-platform native runtime architecture: Claude Code and Codex as first-class runtimes, with a shared TAD protocol layer and platform-specific adapter layers.

### 1.2 Why We're Building It

**业务价值**：TAD v2.26 proved unified SKILL install/activation, but it did not yet define a durable architecture for using Claude Code and Codex native capabilities without protocol drift.

**用户受益**：未来 TAD 升级时，不会因为 Codex 功能更新、Claude Code 行为差异、或文档过期而反复重做适配。每个平台都能用自己的强项，同时保持 Alex/Blake 的核心质量链一致。

**成功的样子**：Human can read one architecture document and see exactly what is shared protocol, what is Claude Code adapter, what is Codex adapter, what must be re-verified when platforms update, and what should be deferred to later phases.

### 1.3 Intent Statement

**真正要解决的问题**：把 TAD 从“同一套 SKILL 文件能被两个平台加载”升级为“两个平台都有原生运行时边界、配置治理、漂移检测和回归证据”的架构。

**不是要做的（避免误解）**：
- ❌ 不是现在实现 `.codex/config.toml` 或 `.codex/agents/`
- ❌ 不是修改 `docs/MULTI-PLATFORM.md`
- ❌ 不是让 Codex 模仿 Claude Code，也不是把 Claude Code 改写成 Codex 模式
- ❌ 不是宣称平台 parity 已完成；Phase 1 只产出决策文档
- ❌ 不是追逐每个 Codex 新功能；目标是建立“发现变化 → 评估 → 更新/测试/记录”的机制

**Blake请确认理解**：
```
在开始实现前，请用你自己的话回答：
1. 这个 Phase 1 解决什么问题？
2. 哪些内容属于 shared TAD protocol，哪些属于 platform adapter？
3. Codex 功能更新时，这个设计如何保持最新？

只有 Human 确认你的理解正确后，才能开始实现。
```

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别

本次任务涉及的领域：
- [x] architecture - 双平台运行时架构与协议/adapter 边界
- [x] testing - 平台回归与漂移检测
- [x] code-quality - 避免质量链被平台适配稀释
- [x] api-integration - Codex/OpenAI 文档与运行时能力验证

### 步骤 2：历史经验摘录

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| `.tad/project-knowledge/principles.md` | 3 | 质量链约束不能从 SKILL body 中丢失；结构检查不能替代行为验证 |
| `.tad/project-knowledge/patterns/handoff-design.md` | 3 | 快变 CLI 平台能力必须 fresh audit；Codex progressive loading 曾出现 silent capability loss |
| `.tad/project-knowledge/patterns/pack-evaluation.md` | 1 | 跨模型/跨平台发现很有价值，但 version-sensitive claims 必须查 primary/current docs |
| `.tad/project-knowledge/patterns/ac-verification.md` | 1 | 静态检查会产生 validation theater；真实运行/回归才是 ground truth |
| `.tad/project-knowledge/incidents/2026-06/codex-edition-parity.md` | 1 | 平台 edition/parity 检查需要结构层、约束层、能力 marker 层，不能只看文件存在 |

**⚠️ Blake 必须注意的历史教训**：

1. **Fast-Evolving CLI Platform Assumptions Stale Within Weeks** (`patterns/handoff-design.md`)
   - 问题：2026-04 的 Codex compressed-edition 架构基于旧假设，后来 Codex 已具备更多 native capability，导致压缩架构成为浪费。
   - 解决方案：任何 Codex/Claude Code 平台能力声明都必须 fresh-source verify；旧记忆和旧文档不能作为当前事实。

2. **SKILL Progressive Loading Silent Capability Loss on Codex** (`patterns/handoff-design.md`)
   - 问题：v2.26 progressive loading 让 activation 成功，但 Blake 在 Codex 实际执行时跳过 Layer 2、Gate 3、completion report。
   - 解决方案：Phase 1 设计必须区分 activation parity 与 execution fidelity；质量链规则不能只放在可能不会被主动加载的 reference/adapter 里。

3. **Judgment-Only Skill Files: Constraint Rules Are NOT Mechanical** (`principles.md`)
   - 问题：v2.7 slim 移除 constraint rules 导致系统性质量链失败。
   - 解决方案：MUST/MANDATORY/VIOLATION 等执行纪律属于 shared protocol body 或强制加载层，不可被平台适配稀释。

4. **Cross-Model Review Finds Real Issues But Is Fallible** (`patterns/pack-evaluation.md`)
   - 问题：Codex/Gemini review 能发现 Claude 自审盲点，但 reviewer 自己也会犯版本/文档错误。
   - 解决方案：version-sensitive claims 必须用 current primary docs 或 local runtime evidence 复核。

5. **Validation Theater: Static Checks Are Not Enough** (`patterns/ac-verification.md`)
   - 问题：静态 review 和 grep/node checks 曾全部通过，但 live workflow run 立即发现 API/schema/runtime-copy 问题。
   - 解决方案：Phase 1 的架构必须预留 Phase 5 full-cycle regression，不能只靠文档矩阵宣称成功。

### Blake 确认

- [ ] 我已阅读上述历史经验
- [ ] 我理解需要避免的问题
- [ ] 如遇到类似情况，我会参考上述解决方案

---

## 2. Background Context

### 2.1 Previous Work

- `EPIC-20260608-cross-platform-unification.md` archived: unified SKILL installation for Claude Code and Codex.
- `EPIC-20260608-skill-progressive-loading.md` archived: reduced SKILL body size through references, but produced Codex execution-fidelity regression.
- `EPIC-20260609-skill-body-reference-boundary.md` active P0: repairs the quality-chain body/reference boundary.
- `EPIC-20260609-dual-platform-native-runtime-architecture.md` active P1: this handoff covers Phase 1 only.

### 2.2 Current State

Current docs are inconsistent:
- `AGENTS.md` says Codex is a first-class platform since v2.25.0.
- `.tad/codex/README.md` says Codex now uses unified SKILL files.
- `docs/MULTI-PLATFORM.md` still frames Codex CLI as a specialized executor.

Current architecture gap:
- TAD has unified skill files, but not a complete protocol/adapter boundary.
- TAD has no durable runtime freshness ledger for Codex/Claude Code capability drift.
- TAD has not yet decided which Codex native capabilities belong in `.codex/config.toml`, `.codex/agents/`, hooks, MCP, review, or cloud/offload integration.

### 2.3 Dependencies

This handoff is prepared now, but execution is blocked until:
- P0 `EPIC-20260609-skill-body-reference-boundary` reaches Phase 3 acceptance, OR
- Human explicitly says to run this Phase 1 in parallel.

If Human overrides and runs Phase 1 in parallel, Blake must not modify Alex/Blake SKILL files, Codex config, or multi-platform docs.

---

## 3. Requirements

### 3.1 Functional Requirements

- FR1: Create `.tad/evidence/designs/dual-platform-native-runtime-architecture.md`.
- FR2: Produce a capability matrix comparing Claude Code native, Codex native, shared TAD protocol, fallback behavior, verification source, and volatility.
- FR3: Produce explicit architecture decisions classifying each concern as shared protocol, Claude Code adapter, Codex adapter, runtime freshness ledger, or deferred.
- FR4: Define the runtime freshness loop for Codex/Claude Code feature drift.
- FR5: Identify stale documentation claims that Phase 3 must update, without editing those docs in Phase 1.
- FR6: Define follow-up questions or handoff requirements for Phase 2.

### 3.2 Non-Functional Requirements

- NFR1: No platform-subordination framing. Claude Code and Codex must both be treated as first-class runtimes.
- NFR2: No stale Codex assumptions. Current Codex claims require fresh-source verification.
- NFR3: No protocol fork. Alex/Blake core behavior must remain invariant across platforms.
- NFR4: No quality-chain dilution. Platform adapters may add mechanics, but must not move core execution discipline into optional/unloaded paths.
- NFR5: No user-secret leakage. Any future config policy must separate project-owned settings from user-owned secrets/auth.
- NFR6: Keep Phase 1 design-only. Do not modify runtime/config/docs beyond the single evidence artifact.

---

## 4. Technical Design

### 4.1 Architecture Overview

The output design must use this layered model:

```text
TAD Shared Protocol
  - Alex/Blake role contract
  - Gates 1-4
  - Handoff protocol
  - Layer 2 review semantics
  - Completion report / evidence / trace requirements
  - Body/reference boundary for execution discipline

Platform Adapter: Claude Code
  - Claude Code skill behavior
  - hooks/workflows/subagents where applicable
  - compact behavior and existing sync semantics

Platform Adapter: Codex
  - AGENTS.md behavior
  - .agents/skills behavior
  - .codex/config.toml policy candidates
  - .codex/agents candidates
  - hooks/MCP/review/cloud/offload candidates
  - sandbox/approval/profile strategy

Runtime Freshness Layer
  - compatibility ledger
  - last_verified fields
  - volatility classification
  - drift response policy
  - release/sync freshness gate
```

### 4.2 Output Document Required Structure

Create `.tad/evidence/designs/dual-platform-native-runtime-architecture.md` with exactly these top-level sections:

1. `# Dual-Platform Native Runtime Architecture`
2. `## YAML Summary`
3. `## Executive Decision`
4. `## Source Verification Log`
5. `## Current State Inventory`
6. `## Capability Matrix`
7. `## Architecture Decisions`
8. `## Runtime Freshness Loop`
9. `## Phase 2 Recommendations`
10. `## Phase 3 Documentation Updates Needed`
11. `## Risks and Open Questions`
12. `## Size / Maintenance Impact`

### 4.3 YAML Summary Schema

Include this block near the top:

```yaml
epic: EPIC-20260609-dual-platform-native-runtime-architecture
phase: 1
artifact_type: architecture_decision
generated: 2026-06-09
status: proposed
platforms:
  - claude_code
  - codex
source_policy:
  codex_claims_require_current_verification: true
  claude_code_claims_require_local_or_doc_verification: true
outputs:
  capability_matrix: true
  architecture_decisions: true
  runtime_freshness_loop: true
phase_2_ready: true_or_false
blocked_by:
  - EPIC-20260609-skill-body-reference-boundary until Phase 3 acceptance unless Human override
```

### 4.4 Capability Matrix Columns

The matrix must cover at minimum these surfaces:

- Role activation
- Skill loading
- Reference/progressive loading
- Hooks
- Workflows
- Subagents / custom agents
- MCP
- Tool permissions / sandbox / approvals
- Code review / expert review
- Cloud/offload tasks
- Context compaction / resume
- Trace/evidence capture
- Release/sync behavior
- Runtime freshness / drift detection

Required columns:

| Surface | Shared TAD Protocol | Claude Code Native | Codex Native | Current TAD Usage | Gap | Fallback | Volatility | Verification Source | Proposed Owner |
|---------|---------------------|--------------------|--------------|-------------------|-----|----------|------------|---------------------|----------------|

### 4.5 Architecture Decision Format

Each decision must use this format:

```markdown
### D{N}: {Decision Title}

- **Decision:** {one sentence}
- **Owner Layer:** shared_protocol / claude_code_adapter / codex_adapter / runtime_freshness / deferred
- **Rationale:** {why}
- **Codex impact:** {impact or none}
- **Claude Code impact:** {impact or none}
- **Quality-chain impact:** {how Gates/Layer2/evidence are preserved}
- **Freshness handling:** {last_verified / volatile / recheck trigger}
- **Phase 2 implication:** {what Blake should or should not implement later}
```

Minimum required decisions:

- D1: TAD protocol invariants vs platform adapters
- D2: Execution-discipline content placement
- D3: Codex config policy scope
- D4: Codex custom-agent evaluation scope
- D5: Claude Code compatibility preservation
- D6: Review/Layer 2 mapping across platforms
- D7: Runtime freshness ledger and release gate
- D8: Full-cycle regression harness
- D9: Documentation authority and stale-doc update path
- D10: What is explicitly deferred

---

## 5. 强制问题回答（Evidence Required）

### MQ1: Did the user reference previous/current TAD work?

**Answer:** Yes.

Required evidence:
- Read the active Epic: `.tad/active/epics/EPIC-20260609-dual-platform-native-runtime-architecture.md`
- Read the P0 blocker Epic: `.tad/active/epics/EPIC-20260609-skill-body-reference-boundary.md`
- Read current platform docs: `AGENTS.md`, `.tad/codex/README.md`, `docs/MULTI-PLATFORM.md`
- Cite concrete stale/current statements with file path and line number in the output artifact.

### MQ2: Are Codex platform claims current?

**Answer:** Must be verified during execution.

Required evidence route:
1. First use local Codex self-knowledge when available:
   `node /Users/sheldonzhao/.codex/skills/.system/openai-docs/scripts/fetch-codex-manual.mjs`
2. Use the generated manual/outline to verify relevant Codex surfaces.
3. If local manual fetch fails or lacks the relevant claim, use official OpenAI Codex docs only.
4. If neither establishes the claim, classify it as `unknown_current_behavior` and do not base a design decision on it.

Output requirement:
- `## Source Verification Log` must list each Codex claim, source route, result, and whether the claim is verified / unknown / deferred.

### MQ3: Does this handoff modify runtime behavior?

**Answer:** No.

Allowed write:
- `.tad/evidence/designs/dual-platform-native-runtime-architecture.md`

Forbidden writes:
- `.codex/config.toml`
- `.codex/agents/*`
- `.claude/skills/*`
- `.agents/skills/*`
- `docs/MULTI-PLATFORM.md`
- `.tad/codex/README.md`
- `AGENTS.md`
- runtime hook scripts

### MQ4: How will the design keep up with Codex changes?

Required answer:
- Define a runtime freshness loop with compatibility ledgers, `last_verified`, runtime version/source, volatility, review cadence, release/sync trigger, and fail-closed behavior for unknown safety/quality-affecting features.

---

## 6. Implementation Steps

1. Confirm blocker status.
   - If `EPIC-20260609-skill-body-reference-boundary` has not reached Phase 3 acceptance and Human has not overridden, stop and report blocked.
   - If Human explicitly overrides, continue but keep Phase 1 design-only.

2. Read required project context.
   - `.tad/active/epics/EPIC-20260609-dual-platform-native-runtime-architecture.md`
   - `.tad/active/epics/EPIC-20260609-skill-body-reference-boundary.md`
   - `AGENTS.md`
   - `.tad/codex/README.md`
   - `docs/MULTI-PLATFORM.md`
   - `.agents/skills/alex/SKILL.md`
   - `.agents/skills/blake/SKILL.md`
   - `.claude/skills/alex/SKILL.md`
   - `.claude/skills/blake/SKILL.md`

3. Read required project knowledge.
   - `.tad/project-knowledge/principles.md`
   - `.tad/project-knowledge/patterns/handoff-design.md`
   - `.tad/project-knowledge/patterns/pack-evaluation.md`
   - `.tad/project-knowledge/patterns/ac-verification.md`
   - `.tad/project-knowledge/incidents/2026-06/codex-edition-parity.md`

4. Verify current Codex sources.
   - Run the local Codex manual helper if available.
   - Use only official OpenAI docs fallback for unresolved Codex claims.
   - Record every verified and unknown claim in the Source Verification Log.

5. Build the current-state inventory.
   - Record where current docs agree.
   - Record stale conflicts, especially `docs/MULTI-PLATFORM.md` specialized-executor framing.
   - Record current active Epic dependency.

6. Build the capability matrix.
   - Cover all required surfaces in §4.4.
   - Do not leave cells blank; use `unknown_current_behavior` or `not_applicable` when needed.

7. Write architecture decisions D1-D10.
   - Use the required decision format.
   - Each decision must identify owner layer and quality-chain impact.

8. Design the Runtime Freshness Loop.
   - Include ledger fields.
   - Include triggers.
   - Include fail-closed rules.
   - Include how new Codex features move from detected → evaluated → adopted/deferred.

9. Write Phase 2 recommendations.
   - Decide what Phase 2 should evaluate for `.codex/config.toml`.
   - Decide what Phase 2 should evaluate for `.codex/agents/`.
   - Do not implement either.

10. Run acceptance verification commands in §8 and include outputs or summaries in the artifact.

---

## 7. File Structure

### 7.1 Create

- `.tad/evidence/designs/dual-platform-native-runtime-architecture.md`

### 7.2 Read

- `.tad/active/epics/EPIC-20260609-dual-platform-native-runtime-architecture.md`
- `.tad/active/epics/EPIC-20260609-skill-body-reference-boundary.md`
- `AGENTS.md`
- `.tad/codex/README.md`
- `docs/MULTI-PLATFORM.md`
- `.agents/skills/alex/SKILL.md`
- `.agents/skills/blake/SKILL.md`
- `.claude/skills/alex/SKILL.md`
- `.claude/skills/blake/SKILL.md`
- `.tad/project-knowledge/principles.md`
- `.tad/project-knowledge/patterns/handoff-design.md`
- `.tad/project-knowledge/patterns/pack-evaluation.md`
- `.tad/project-knowledge/patterns/ac-verification.md`
- `.tad/project-knowledge/incidents/2026-06/codex-edition-parity.md`

### 7.3 Do Not Modify

- `.codex/config.toml`
- `.codex/agents/*`
- `.claude/skills/*`
- `.agents/skills/*`
- `docs/MULTI-PLATFORM.md`
- `.tad/codex/README.md`
- `AGENTS.md`
- `.tad/hooks/*`

---

## 8. Testing Requirements

### 8.1 Static Artifact Checks

Run:

```bash
test -f .tad/evidence/designs/dual-platform-native-runtime-architecture.md
rg -n "^## YAML Summary|^## Capability Matrix|^## Architecture Decisions|^## Runtime Freshness Loop|^## Phase 2 Recommendations" .tad/evidence/designs/dual-platform-native-runtime-architecture.md
rg -n "last_verified|volatility|unknown_current_behavior|shared_protocol|codex_adapter|claude_code_adapter" .tad/evidence/designs/dual-platform-native-runtime-architecture.md
```

### 8.2 Scope Check

Run:

```bash
git status --short -- .tad/evidence/designs/dual-platform-native-runtime-architecture.md .codex .claude/skills .agents/skills docs/MULTI-PLATFORM.md .tad/codex/README.md AGENTS.md .tad/hooks
```

Expected:
- The only new/modified Phase 1 deliverable should be `.tad/evidence/designs/dual-platform-native-runtime-architecture.md`.
- Pre-existing dirty worktree entries must be reported separately and not claimed as Blake's edits.

### 8.3 Source Verification Check

The artifact must include:
- local Codex manual helper result, or official-doc fallback result
- source/date for each Codex-specific claim
- explicit `unknown_current_behavior` for unresolved claims

### 8.4 Completeness Check

The capability matrix must include all surfaces listed in §4.4.

Use:

```bash
rg -n "Role activation|Skill loading|Reference/progressive loading|Hooks|Workflows|Subagents|custom agents|MCP|sandbox|approvals|Code review|Cloud|Context compaction|Trace/evidence|Release/sync|Runtime freshness" .tad/evidence/designs/dual-platform-native-runtime-architecture.md
```

---

## 9. Acceptance Criteria

### 9.1 Spec Compliance Checklist

- [ ] Artifact exists at `.tad/evidence/designs/dual-platform-native-runtime-architecture.md`
- [ ] Artifact contains the required 12 top-level sections from §4.2
- [ ] YAML Summary follows §4.3 and includes blocker status
- [ ] Source Verification Log records Codex source route and result
- [ ] Capability Matrix includes all required surfaces and columns
- [ ] Architecture Decisions include D1-D10 using the required format
- [ ] Each decision has an owner layer: shared_protocol / claude_code_adapter / codex_adapter / runtime_freshness / deferred
- [ ] Runtime Freshness Loop includes ledger fields, triggers, fail-closed behavior, and drift response policy
- [ ] Phase 2 Recommendations cover `.codex/config.toml` and `.codex/agents/` evaluation without implementing them
- [ ] Stale docs are identified but not edited
- [ ] No runtime/config/docs files are modified except the evidence artifact
- [ ] Human can approve/reject the protocol-vs-adapter boundary directly from the artifact

### 9.2 Definition of Done

Blake is done when:
- The design artifact is complete.
- Verification commands in §8 have been run.
- Completion report summarizes source freshness, unknowns, and Phase 2 readiness.
- Any blocker or unresolved source claim is explicit, not hidden.

---

## 10. Important Notes and Warnings

1. **Do not start if P0 is still active unless Human overrides.** This handoff is prepared to save design time, not to interrupt the quality-chain repair.

2. **Do not implement Phase 2 early.** No `.codex/config.toml`, no `.codex/agents/`, no docs edits in this task.

3. **Do not rely on memory for Codex capabilities.** Codex changes quickly. Use current local/manual/official evidence or mark the claim unknown.

4. **Do not bury volatile Codex details in shared protocol.** Volatile runtime behavior belongs in adapter docs or runtime compatibility ledgers.

5. **Do not weaken Alex/Blake invariants.** Gates, Layer 2, completion report, handoff discipline, and evidence requirements stay shared unless Human explicitly accepts a protocol change.

6. **Be honest about unknowns.** An `unknown_current_behavior` cell is acceptable. A confident but stale claim is not.

---

## 11. Questions for Blake

Before implementation, answer these in your kickoff:

1. Is the P0 blocker cleared, or did Human explicitly override parallel execution?
2. Which source route did you use for current Codex claims?
3. Which surfaces are likely shared protocol vs adapter before you start the detailed matrix?
4. What would make Phase 2 unsafe to start?

---

## 12. Alex Final Note

This Phase 1 is the architectural guardrail for the next TAD upgrade. The key judgment is not "what can Codex do today?" but "how does TAD avoid becoming stale when Codex changes tomorrow?"

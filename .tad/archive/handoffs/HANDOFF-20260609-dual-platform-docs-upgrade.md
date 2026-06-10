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
**Date:** 2026-06-09  
**Project:** TAD Framework  
**Task ID:** TASK-20260609-005  
**Handoff Version:** 3.1.0  
**Epic:** EPIC-20260609-dual-platform-native-runtime-architecture.md (Phase 3/5)  
**Priority:** P1. Do not interrupt the active P0 release/sync handoff unless Human explicitly overrides.

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-06-09

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Phase 1 accepted the protocol/adapter boundary; Phase 2 accepted draft Codex policy |
| Components Specified | ✅ | Docs to update, stale claims, required sections, and verification checks are specified |
| Functions Verified | ✅ | No production functions involved; this is documentation + evidence artifact work |
| Data Flow Mapped | ✅ | Inputs: Phase 1/2 artifacts + current docs → Output: updated platform docs + docs-upgrade evidence |

**Gate 2 结果**: ✅ PASS

**Alex确认**: Blake can independently complete this documentation upgrade from this handoff. This handoff does not authorize active Codex runtime config.

---

## 📋 Handoff Checklist (Blake必读)

Blake在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] 阅读 Phase 1 architecture artifact
- [ ] 阅读 Phase 2 runtime policy artifact
- [ ] 明确 Phase 3 可以修改文档，但不能启用 active `.codex/config.toml` / `.codex/agents/`
- [ ] 明确旧的 "Codex specialized executor" 叙述必须移除或改成历史说明
- [ ] 明确 Claude Code 不能被改写成 Codex-only 叙述

❌ 如果任何部分不清楚，立即返回 Alex 要求澄清，不要开始实现。

---

## 1. Task Overview

### 1.1 What We're Building

Update TAD's platform documentation so it matches the accepted dual-platform architecture: Claude Code and Codex are both first-class TAD runtimes with a shared protocol layer, platform-specific adapters, and a runtime freshness layer.

### 1.2 Why We're Building It

**业务价值**：当前 `docs/MULTI-PLATFORM.md` 仍停留在 v2.8.0，把 Codex 描述成 "specialized executor"。这会误导后续用户和下游项目，尤其是在 v2.26/v2.27 已经完成统一 SKILL 和 Codex first-class runtime 之后。

**用户受益**：读文档即可理解：什么时候用 Claude Code，什么时候用 Codex，哪些规则是共享协议，哪些是平台 adapter，哪些 Codex 配置只是 draft，哪些仍需 Phase 4/5 验证。

**成功的样子**：`docs/MULTI-PLATFORM.md` 成为当前权威入口；`.tad/codex/README.md` 从迁移通知扩展为 Codex adapter 说明；`AGENTS.md` 的 Codex notes 不再包含已过时或未加限定的顺序/手动说法。

### 1.3 Intent Statement

**真正要解决的问题**：把 Phase 1/2 的架构结论转成用户可读、下游可同步的文档，消除旧平台模型造成的行为误导。

**不是要做的（避免误解）**：
- ❌ 不是启用 `.codex/config.toml`
- ❌ 不是启用 `.codex/agents/*`
- ❌ 不是修改 Alex/Blake SKILL files
- ❌ 不是重新设计 Phase 1/2 已接受的架构边界
- ❌ 不是把 Gemini 升级成 first-class runtime；Gemini 仍可作为 external specialized tool 描述
- ❌ 不是 release bump；版本/changelog 可留给发布 handoff

**Blake请确认理解**：
```
在开始实现前，请用你自己的话回答：
1. 哪些文档必须修改？
2. 哪些旧叙述必须移除？
3. 哪些 Codex config/agent 内容只能作为 draft/policy 描述，不能激活？

只有 Human 确认你的理解正确后，才能开始实现。
```

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别

本次任务涉及的领域：
- [x] architecture - platform protocol/adapter boundary
- [x] code-quality - preventing stale docs from driving wrong implementation
- [x] testing - grep-based stale-claim verification

### 步骤 2：历史经验摘录

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| `.tad/project-knowledge/patterns/handoff-design.md` | 5 | Platform assumptions decay; runtime freshness applies to both platforms; missing decision hooks affect evidence |
| `.tad/project-knowledge/principles.md` | 2 | Constraint rules are not mechanical; docs/structural checks alone are not behavior proof |
| `.tad/project-knowledge/patterns/ac-verification.md` | 1 | AC grep commands must avoid false PASS/FAIL |

**⚠️ Blake 必须注意的历史教训**：

1. **Platform Capability Assumptions Decay Fast**
   - Docs must include source/freshness pointers and avoid over-claiming current Codex behavior beyond Phase 1/2 verified facts.

2. **Runtime Freshness Applies to Both First-Class Platforms**
   - Do not write docs as "Codex changes, Claude Code is fixed." Claude Code is lower-volatility, not freshness-exempt.

3. **Activation ≠ Execution Fidelity**
   - Docs must distinguish unified SKILL activation from full quality-chain execution. Phase 5 regression is still required before active config/agent adoption.

4. **Missing Interactive-Decision Hooks Are Evidence-Completeness Gaps**
   - The `ask_user_question` Codex hook behavior remains unknown and must be documented as Phase 5 verification, not hidden.

---

## 2. Background Context

### 2.1 Previous Work

- Phase 1 accepted: `.tad/evidence/designs/dual-platform-native-runtime-architecture.md`
- Phase 2 accepted: `.tad/evidence/designs/codex-native-runtime-policy.md`
- Phase 2 draft candidates exist under `.tad/evidence/designs/codex-runtime-candidates/`
- Active `.codex/` still contains only `.codex/hooks.json`; no active `.codex/config.toml` or `.codex/agents/`

### 2.2 Current Stale Docs (Verified Line Numbers)

`docs/MULTI-PLATFORM.md` is stale:
- L1 title: `TAD Specialized Tools Guide`
- L3 version: `Version 2.8.0`
- L5-L7: Claude Code primary, Codex/Gemini specialized tools
- L13-L17: architecture table says Codex CLI = `Specialized Executor`
- L19-L24: Codex only for code review/security audit
- L26-L32: human copies handoff content to tool
- L36-L39: tips assume Codex/Gemini external handoff tools
- L43-L54: references old `.tad/skills/` quality checklist directory
- L58: v2.8.0 footer repeats old framing

`AGENTS.md` needs careful update:
- L9-L12: says Codex first-class, but L11 says some features are sequential/manual on Codex. This must be revised to reflect current accepted state: Codex has native subagents/hooks, but TAD has not yet activated custom-agent config and some flows remain manually verified until Phase 5.
- L66-L71: Codex-specific notes should mention draft config/agents are not active and point to `.tad/codex/README.md`.

`.tad/codex/README.md` is accurate but too thin:
- L3-L16 correctly describes v2.26 unified SKILL install.
- It should add adapter boundaries, active vs draft config status, and links to Phase 1/2 artifacts.

### 2.3 Dependencies

Phase 2 is accepted. This phase may run now if Human wants to continue. It must not activate runtime config or agents.

---

## 3. Requirements

### 3.1 Functional Requirements

- FR1: Rewrite `docs/MULTI-PLATFORM.md` as the current dual-platform runtime guide.
- FR2: Update `.tad/codex/README.md` from migration-only notice to Codex adapter guide.
- FR3: Update `AGENTS.md` Codex-specific notes only if needed; keep it concise.
- FR4: Create `.tad/evidence/designs/dual-platform-docs-upgrade.md`.
- FR5: Remove stale "Codex as specialized executor" framing from docs.
- FR6: Document shared protocol vs Claude Code adapter vs Codex adapter vs runtime freshness.
- FR7: Document active vs draft Codex config/agents status.
- FR8: Carry Phase 2 activation criteria forward: no active `.codex/config.toml` / `.codex/agents/*` until docs + freshness ledger + regression + Human approval.
- FR9: Document unresolved `ask_user_question` hook behavior as Phase 5 verification.
- FR10: Keep Gemini as external specialized tool only; do not expand third-platform scope.

### 3.2 Non-Functional Requirements

- NFR1: No active runtime config changes.
- NFR2: No SKILL file changes.
- NFR3: No secrets/auth/personal paths.
- NFR4: Docs must be precise enough for downstream sync.
- NFR5: Docs must not claim Phase 5 regression has passed.
- NFR6: Docs must not imply Codex custom agents are active.

---

## 4. Technical Design

### 4.1 Target `docs/MULTI-PLATFORM.md` Structure

Replace the old doc with:

1. `# TAD Multi-Platform Runtime Guide`
2. `## Current Status`
3. `## Runtime Model`
4. `## Shared TAD Protocol`
5. `## Claude Code Adapter`
6. `## Codex Adapter`
7. `## Draft Codex Native Runtime Policy`
8. `## Runtime Freshness`
9. `## External Specialized Tools`
10. `## Workflow Matrix`
11. `## Current Limitations`
12. `## Source Artifacts`

Required content:
- Claude Code and Codex are both first-class TAD runtimes.
- Shared protocol includes Alex/Blake roles, Gates 1-4, handoffs, Layer 2, Ralph Loop, completion/evidence, knowledge assessment.
- Claude Code adapter includes Skill tool, Agent tool, hooks/settings, workflows, MCP, compact mechanics.
- Codex adapter includes `AGENTS.md`, `.agents/skills/`, `.codex/hooks.json`, future `.codex/config.toml`, future `.codex/agents/`, MCP, sandbox/approval profiles, subagents, plugins.
- `.codex/config.toml` and `.codex/agents/*` are draft-only in Phase 2 and not active.
- Gemini remains external specialized tool.

### 4.2 Target `.tad/codex/README.md` Structure

Update to:

1. `# TAD Codex Adapter`
2. `## Current Status`
3. `## Active Codex Files`
4. `## Draft-Only Files`
5. `## Shared Protocol Boundary`
6. `## Codex Adapter Responsibilities`
7. `## Known Gaps Before Activation`
8. `## Migration History`

Required content:
- Current active file: `.codex/hooks.json`.
- Current active skill path: `.agents/skills/`.
- Draft candidates live under `.tad/evidence/designs/codex-runtime-candidates/`, not `.codex/`.
- Do not copy drafts to `.codex/` until activation criteria are met.
- Known gaps: `ask_user_question` matcher unknown; custom-agent review quality untested; runtime freshness ledger pending.

### 4.3 Target `AGENTS.md` Update

Keep edits minimal:
- Replace or qualify L11 stale note.
- In Codex-specific notes, say:
  - Codex is first-class and uses `.agents/skills/`.
  - Parallel/custom-agent review is not yet activated by TAD config; until Phase 5, run reviewer sessions explicitly or sequentially.
  - Hooks are in `.codex/hooks.json`; active config/agents are not enabled yet.
  - See `.tad/codex/README.md`.

Do not rewrite the capability pack table.

### 4.4 Evidence Artifact

Create `.tad/evidence/designs/dual-platform-docs-upgrade.md` with:
- Summary of files changed
- Stale claims removed
- Lines/phrases verified with grep
- Active-vs-draft config status
- Phase 4/5 carry-forward

---

## 5. 强制问题回答（Evidence Required）

### MQ1: Did this task remove stale specialized-executor framing?

Required:
```bash
rg -n "Specialized Executor|specialized execution tools|Claude Code primary|TAD Specialized Tools Guide|v2\\.8\\.0|20 Domain Packs|78 tools" docs/MULTI-PLATFORM.md
```

Expected: no matches, unless the phrase appears in a clearly labeled historical/migration note. Prefer no matches.

### MQ2: Did this task avoid activating Codex config/agents?

Required:
```bash
test ! -e .codex/config.toml
test ! -d .codex/agents
```

### MQ3: Are draft-only files correctly documented?

Required:
```bash
rg -n "draft-only|not active|Phase 5 regression|Human approval|codex-runtime-candidates" docs/MULTI-PLATFORM.md .tad/codex/README.md
```

### MQ4: Did AGENTS.md avoid stale/over-strong claims?

Required:
```bash
rg -n "sequential / manual|specialized executor|not yet activated|\\.codex/config.toml|\\.codex/agents|\\.tad/codex/README.md" AGENTS.md
```

Expected:
- no `sequential / manual`
- no `specialized executor`
- if `.codex/config.toml` / `.codex/agents` are mentioned, they must be marked not active or future/draft.

---

## 6. Implementation Steps

1. Read inputs:
   - `.tad/evidence/designs/dual-platform-native-runtime-architecture.md`
   - `.tad/evidence/designs/codex-native-runtime-policy.md`
   - `.tad/evidence/designs/codex-runtime-candidates/`
   - current `docs/MULTI-PLATFORM.md`
   - current `.tad/codex/README.md`
   - current `AGENTS.md`

2. Rewrite `docs/MULTI-PLATFORM.md`.
   - Replace old v2.8.0 specialized-tools guide entirely.
   - Use current dual-platform runtime terminology.
   - Include source artifact links.

3. Update `.tad/codex/README.md`.
   - Preserve migration history.
   - Add current active/draft state.
   - Add known gaps and activation rule.

4. Update `AGENTS.md` minimally.
   - Remove stale L11 phrase.
   - Update Codex-specific notes to current Phase 2 status.

5. Create `.tad/evidence/designs/dual-platform-docs-upgrade.md`.

6. Run §8 verification commands.

7. Run Layer 2 review:
   - spec-compliance reviewer
   - code-reviewer focused on stale docs, over-claims, and accidental activation

---

## 7. File Structure

### 7.1 Modify

- `docs/MULTI-PLATFORM.md`
- `.tad/codex/README.md`
- `AGENTS.md` (minimal update only)

### 7.2 Create

- `.tad/evidence/designs/dual-platform-docs-upgrade.md`

### 7.3 Do Not Modify

- `.codex/config.toml`
- `.codex/agents/*`
- `.codex/hooks.json`
- `.agents/skills/*`
- `.claude/skills/*`
- `.tad/hooks/*`
- version files / changelog unless Human explicitly asks for release prep

---

## 8. Testing Requirements

### 8.1 Stale Phrase Removal

```bash
rg -n "Specialized Executor|specialized execution tools|Claude Code primary|TAD Specialized Tools Guide|v2\\.8\\.0|20 Domain Packs|78 tools" docs/MULTI-PLATFORM.md
```

Expected: no matches.

### 8.2 Required New Concepts

```bash
rg -n "first-class|Shared TAD Protocol|Claude Code Adapter|Codex Adapter|Runtime Freshness|draft-only|not active|Phase 5 regression|Human approval" docs/MULTI-PLATFORM.md .tad/codex/README.md
```

Expected: matches in both docs where relevant.

### 8.3 Active Config Safety

```bash
test ! -e .codex/config.toml
test ! -d .codex/agents
```

Expected: both commands exit 0.

### 8.4 AGENTS.md Stale Note Check

```bash
rg -n "sequential / manual|specialized executor" AGENTS.md
```

Expected: no matches.

### 8.5 Scope Check

```bash
git status --short -- docs/MULTI-PLATFORM.md .tad/codex/README.md AGENTS.md .tad/evidence/designs/dual-platform-docs-upgrade.md .codex/config.toml .codex/agents .codex/hooks.json .agents/skills .claude/skills .tad/hooks
```

Expected:
- modified: docs/MULTI-PLATFORM.md, .tad/codex/README.md, AGENTS.md
- created: .tad/evidence/designs/dual-platform-docs-upgrade.md
- no active `.codex/config.toml` / `.codex/agents`
- no SKILL or hook modifications

---

## 9. Acceptance Criteria

### 9.1 Spec Compliance Checklist

- [ ] `docs/MULTI-PLATFORM.md` rewritten as current dual-platform runtime guide
- [ ] `docs/MULTI-PLATFORM.md` no longer frames Codex as a specialized executor
- [ ] `docs/MULTI-PLATFORM.md` documents shared protocol vs Claude Code adapter vs Codex adapter
- [ ] `docs/MULTI-PLATFORM.md` documents draft-only Codex config/agents and activation criteria
- [ ] `.tad/codex/README.md` documents active Codex files and draft-only files
- [ ] `.tad/codex/README.md` preserves v2.26 migration history
- [ ] `AGENTS.md` stale Codex note is updated or removed
- [ ] Docs mention runtime freshness and Phase 4/5 pending work
- [ ] Docs mention unresolved `ask_user_question` hook verification
- [ ] Gemini is not promoted to first-class runtime
- [ ] Evidence artifact exists at `.tad/evidence/designs/dual-platform-docs-upgrade.md`
- [ ] No active `.codex/config.toml` or `.codex/agents/*` created
- [ ] No SKILL or hook files modified
- [ ] Stale phrase grep in §8.1 returns no matches
- [ ] Layer 2 review has P0=0 and P1=0

### 9.2 Definition of Done

Blake is done when:
- All docs are updated.
- Evidence artifact exists.
- Verification commands pass.
- Layer 2 review passes.
- Completion report lists every file changed and all carry-forward items for Phase 4/5.

---

## 10. Important Notes and Warnings

1. **Do not activate Codex config or agents.** This phase is docs only plus evidence.
2. **Do not over-claim parity.** Full-cycle regression is Phase 5 and has not passed yet.
3. **Do not make Codex subordinate.** Codex is first-class, but some native features are pending activation.
4. **Do not make Claude Code stale-exempt.** Runtime freshness applies to both platforms.
5. **Do not erase migration history.** Keep v2.26 compressed-edition removal in `.tad/codex/README.md`.

---

## 11. Questions for Blake

Before implementation, answer:

1. Which stale phrases will you remove from `docs/MULTI-PLATFORM.md`?
2. Which active files must remain absent under `.codex/`?
3. How will the docs distinguish first-class runtime from activated native config?
4. What Phase 4/5 carry-forward items must remain visible?

---

## 12. Alex Final Note

This phase is about making the docs match reality without getting ahead of evidence. Codex is first-class now; Codex native config/agents are still draft-only until freshness + regression prove them.

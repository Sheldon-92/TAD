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
**Date:** 2026-06-10
**Project:** TAD Framework
**Task ID:** TASK-20260610-003
**Handoff Version:** 3.1.0
**Epic:** N/A
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-06-10 17:45

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Scope is bounded to dual-platform parity repair: 3 Codex reference files + 2 status docs + optional NEXT/session bookkeeping. |
| Components Specified | ✅ | Exact files, source-of-truth side, and verification commands are specified below. |
| Functions Verified | ✅ | Existing parity checks use `diff`, `comm`, `rg`, and `runtime-freshness-verify.sh`; no new functions required. |
| Data Flow Mapped | ✅ | Claude reference updates → Codex mirror sync → docs status correction → parity verification. |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

Blake在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] 理解本任务是 parity repair，不是新协议设计
- [ ] 不覆盖无关 active handoff：`.tad/active/handoffs/HANDOFF-20260610-feedback-collector-phase1.md`
- [ ] 只同步已识别的 drift，不做 release/sync/yolo 语义改写
- [ ] 完成后执行 §9.1 所有 AC

---

## 1. Task Overview

### 1.1 What We're Building
Repair the detected Claude Code vs Codex parity drift so TAD's "same SKILL.md files / shared protocol" claim is true again for current active skill content and docs.

### 1.2 Why We're Building It
A parity review found that the main Alex/Blake/Gate SKILL bodies are byte-identical, but three Alex reference files in `.agents/skills/` lag behind `.claude/skills/`. The drift affects high-risk workflows: publish, sync, and YOLO execution.

### 1.3 Intent Statement

**真正要解决的问题**: Codex Alex must not run old release/sync/yolo instructions while Claude Alex runs updated instructions.

**不是要做的**:
- Not activating `.codex/config.toml`.
- Not activating `.codex/agents/*.toml`.
- Not changing hook semantics.
- Not changing release/sync/yolo behavior beyond copying the already-accepted Claude reference text to Codex.
- Not touching the unrelated feedback-collector handoff.

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别

- [x] architecture
- [x] principles
- [x] code-quality

### 步骤 2：历史经验摘录

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| `.tad/project-knowledge/principles.md` | 2 | Cross-platform sync must be structure-derived; stale hardcoded or partial copies cause hidden drift. |
| `.tad/project-knowledge/architecture.md` | 1 | Shared protocol belongs in SKILL/reference content, not platform-specific config. |
| `.tad/project-knowledge/code-quality.md` | 1 | Verification commands must be executable and must check the actual invariant. |

**⚠️ Blake 必须注意的历史教训**:

1. **Deny-list / structural verification beats remembered file lists**
   - 问题: 手动维护平台文件列表会漏掉新增 reference 文件。
   - 解决方案: 用 `diff -qr .agents/skills .claude/skills` 作为最终 parity AC，而不是只检查 3 个文件。

2. **Adapter config is not the protocol**
   - 问题: 把 shared rules 放进平台 config 会让 Claude/Codex 分叉。
   - 解决方案: 本任务只修 SKILL/reference/docs；不激活 Codex draft config/agents。

---

## 2. Background Context

### 2.1 Previous Work
- Dual-platform native runtime Epic completed and archived.
- Runtime freshness ledgers exist:
  - `.tad/runtime-compat/codex.md`
  - `.tad/runtime-compat/claude-code.md`
- Regression summary says `verdict: PASS`, `release_readiness: CONDITIONAL_GO`.
- Friction Protocol is already mirrored in Alex/Blake/Gate main SKILL files.

### 2.2 Current Findings From Alex Review

#### Drift 1: publish-protocol
Codex side still allows `TAD_RELEASE_GATE=warn` shadow mode and lacks the migration manifest gate.

Source of truth: `.claude/skills/alex/references/publish-protocol.md`

Target to update: `.agents/skills/alex/references/publish-protocol.md`

#### Drift 2: sync-protocol
Codex side lacks post-copy migration engine instructions, still allows structural gate shadow warning on minor/major, and lacks `.tad-backup/` preservation.

Source of truth: `.claude/skills/alex/references/sync-protocol.md`

Target to update: `.agents/skills/alex/references/sync-protocol.md`

#### Drift 3: yolo-execution-protocol
Codex side lacks the explicit workflow argument object and required-field warnings.

Source of truth: `.claude/skills/alex/references/yolo-execution-protocol.md`

Target to update: `.agents/skills/alex/references/yolo-execution-protocol.md`

#### Drift 4: docs status stale
`docs/MULTI-PLATFORM.md` and `.tad/codex/README.md` still say Phase 4 runtime freshness and Phase 5 regression are pending, but evidence says:
- `.tad/runtime-compat/{codex,claude-code}.md` exist.
- `bash .tad/hooks/lib/runtime-freshness-verify.sh` returns 21/21 PASS.
- `.tad/evidence/dual-platform-regression/ACCEPTANCE-SUMMARY.md` says `verdict: PASS`, `release_readiness: CONDITIONAL_GO`.

### 2.3 Dependencies
None. This is a markdown/reference/doc sync task.

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1: Copy the accepted Claude reference content into the matching Codex reference files for:
  - `publish-protocol.md`
  - `sync-protocol.md`
  - `yolo-execution-protocol.md`
- FR2: After the copy, the full `.agents/skills` and `.claude/skills` trees must be byte-identical.
- FR3: Update `docs/MULTI-PLATFORM.md` so runtime freshness is no longer described as pending/planned.
- FR4: Update `.tad/codex/README.md` so runtime freshness and full-cycle regression are no longer described as not run.
- FR5: Preserve the true remaining limitation: Codex draft config/agents are still not active until human approval; `ask_user_question` in `codex exec` remains an accepted limitation/fallback, not an unresolved unknown for interactive Codex.
- FR6: Do not modify `.codex/hooks.json`, `.claude/settings.json`, `.codex/config.toml`, or create `.codex/agents/`.

### 3.2 Non-Functional Requirements
- NFR1: Minimal diff; do not reword unrelated platform docs.
- NFR2: No hook/config activation.
- NFR3: Verification must prove full skills-tree parity, not only the 3 known files.

---

## 4. Technical Design

### 4.1 Architecture Overview

```
Claude reference files (source of truth)
  ↓ copy exact content
Codex reference files
  ↓ diff -qr
full skills-tree parity

Dual-platform evidence
  ↓ docs update
current docs reflect Phase 4/5 completed with CONDITIONAL_GO
```

### 4.2 Component Specifications

#### Reference Sync
Use the Claude files as source of truth:

```bash
cp .claude/skills/alex/references/publish-protocol.md .agents/skills/alex/references/publish-protocol.md
cp .claude/skills/alex/references/sync-protocol.md .agents/skills/alex/references/sync-protocol.md
cp .claude/skills/alex/references/yolo-execution-protocol.md .agents/skills/alex/references/yolo-execution-protocol.md
```

Do not edit the Claude files unless verification reveals they are internally inconsistent.

#### Docs Update
Update only stale status text:
- `docs/MULTI-PLATFORM.md`
  - Runtime Freshness Layer: completed/active, not pending/planned.
  - Current limitations: remove/replace "Runtime freshness ledger not created" and "Full-cycle regression not yet run".
  - Evidence capture row: replace "ask_user_question hook unknown" with accepted limitation wording for `codex exec` batch mode.
  - Footer: no longer "runtime freshness pending".
- `.tad/codex/README.md`
  - Runtime freshness: Active/PASS, not Pending Phase 4.
  - Known gaps: custom agents still draft-only; runtime freshness and full-cycle regression should be marked completed or removed from "before activation" blockers if no longer blockers.
  - Keep "human explicitly approves activation" and "final secrets audit" as blockers for activating `.codex/config.toml` / `.codex/agents/`.

---

## 5. Mandatory Questions

### MQ1: Existing Similar Code / Files

**回答**: 是。

#### 搜索证据
```bash
diff -qr .agents/skills .claude/skills
find .tad/runtime-compat -maxdepth 2 -type f | sort
sed -n '1,80p' .tad/evidence/dual-platform-regression/ACCEPTANCE-SUMMARY.md
bash .tad/hooks/lib/runtime-freshness-verify.sh
```

#### 决策说明
- `.claude/skills` is newer for the 3 drifted reference files.
- Runtime freshness and regression evidence already exist; docs are stale.

### MQ2: 函数存在性验证

| 函数名 | 文件位置 | 行号 | 代码片段 | 验证 |
|--------|---------|------|---------|------|
| N/A | Markdown/doc sync task | N/A | N/A | ✅ No code function calls added |

### MQ3: 数据流完整性

| Source | Target | Verification |
|--------|--------|--------------|
| `.claude/skills/alex/references/*.md` | `.agents/skills/alex/references/*.md` | `diff -qr .agents/skills .claude/skills` |
| `.tad/evidence/dual-platform-regression/ACCEPTANCE-SUMMARY.md` | `docs/MULTI-PLATFORM.md`, `.tad/codex/README.md` | `rg` for stale pending claims |
| `.tad/runtime-compat/*.md` | Docs status | `runtime-freshness-verify.sh` |

### MQ4: 视觉层级
N/A.

### MQ5: 状态同步
The source-of-truth for skill parity is byte identity across `.agents/skills` and `.claude/skills`. The source-of-truth for runtime freshness is `.tad/runtime-compat/` plus `runtime-freshness-verify.sh`.

---

## 6. Implementation Steps

## 6.1 Micro-Tasks

| # | File | Operation | Verification Command | Est. Time |
|---|------|-----------|---------------------|-----------|
| 1 | `.agents/skills/alex/references/publish-protocol.md` | Copy from Claude mirror | `diff -u .agents/skills/alex/references/publish-protocol.md .claude/skills/alex/references/publish-protocol.md` | 3 min |
| 2 | `.agents/skills/alex/references/sync-protocol.md` | Copy from Claude mirror | `diff -u .agents/skills/alex/references/sync-protocol.md .claude/skills/alex/references/sync-protocol.md` | 3 min |
| 3 | `.agents/skills/alex/references/yolo-execution-protocol.md` | Copy from Claude mirror | `diff -u .agents/skills/alex/references/yolo-execution-protocol.md .claude/skills/alex/references/yolo-execution-protocol.md` | 3 min |
| 4 | `docs/MULTI-PLATFORM.md` | Update stale Phase 4/5 status | `rg -n 'pending|planned|not yet run|unknown|Runtime freshness ledger not created|Full-cycle regression not yet run' docs/MULTI-PLATFORM.md` | 10 min |
| 5 | `.tad/codex/README.md` | Update stale Phase 4/5 status | `rg -n 'Pending Phase 4|Runtime freshness ledger missing|Full-cycle regression not run|hook matcher unknown' .tad/codex/README.md` | 10 min |
| 6 | All | Run parity + freshness checks | §9.1 AC commands | 10 min |

### Phase: Dual-Platform Parity Repair

#### 交付物
- [ ] Codex and Claude skills trees byte-identical.
- [ ] Dual-platform docs reflect Phase 4/5 completed evidence.
- [ ] No Codex draft config/agent activation.
- [ ] Completion report with §9.1 raw outputs.

---

## 7. File Structure

### 7.1 Files to Create
None.

### 7.2 Files to Modify
```
.agents/skills/alex/references/publish-protocol.md
.agents/skills/alex/references/sync-protocol.md
.agents/skills/alex/references/yolo-execution-protocol.md
docs/MULTI-PLATFORM.md
.tad/codex/README.md
NEXT.md
.tad/active/session-state.md
```

### 7.3 Grounded Against

- `.claude/skills/alex/references/publish-protocol.md` (source-of-truth content read via diff at 2026-06-10)
- `.claude/skills/alex/references/sync-protocol.md` (source-of-truth content read via diff at 2026-06-10)
- `.claude/skills/alex/references/yolo-execution-protocol.md` (source-of-truth content read via diff at 2026-06-10)
- `docs/MULTI-PLATFORM.md` (stale status lines read at 2026-06-10)
- `.tad/codex/README.md` (stale status lines read at 2026-06-10)
- `.tad/evidence/dual-platform-regression/ACCEPTANCE-SUMMARY.md` (PASS / CONDITIONAL_GO evidence read at 2026-06-10)
- `.tad/evidence/dual-platform-regression/T4-freshness-check.md` (21/21 PASS evidence read at 2026-06-10)

---

## 8. Testing Requirements

### 8.1 Unit Tests
N/A — markdown/reference sync.

### 8.2 Integration Tests
Use `diff -qr .agents/skills .claude/skills` as the integration check for skill parity.

### 8.3 Edge Cases
- Existing active feedback-collector handoff must remain untouched.
- Docs must not claim Codex custom agents/config are active.
- Codex `ask_user_question` limitation must be stated precisely: batch `codex exec` lacks interactive `request_user_input`; interactive Codex can ask in text.

## 8.4 Friction Preflight

| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|----------------|---------------|-------------------|--------------------|-------------|
| Active handoff collision | Preserve existing feedback-collector handoff | Do not archive/edit `.tad/active/handoffs/HANDOFF-20260610-feedback-collector-phase1.md` | N/A | Accidental modification blocks acceptance |
| Platform docs ambiguity | Update stale Phase 4/5 status without overclaiming config/agents active | Use regression evidence + runtime freshness output | N/A | Overclaiming active config/agents blocks acceptance |
| Reference sync drift | Prove full skills-tree parity | `diff -qr .agents/skills .claude/skills` | N/A | Any remaining diff blocks Gate 3 |
| Hook/config activation | Avoid `.codex`/`.claude` runtime config changes | No edits to `.codex/hooks.json`, `.claude/settings.json`, `.codex/config.toml`, `.codex/agents/` | N/A | Runtime config activation blocks acceptance |

**Status Enum**:
`READY` / `BLOCKED` / `DEGRADED_WITH_APPROVAL` / `EQUIVALENT_SUBSTITUTE` / `NOT_APPLICABLE_WITH_REASON`

### 8.5 Test Evidence Required
Blake必须提供：
- [ ] Full `diff -qr .agents/skills .claude/skills` output.
- [ ] Runtime freshness verify output.
- [ ] `rg` proof stale pending claims are gone or intentionally scoped.
- [ ] `git diff --name-only` proof no runtime config/hook activation happened.

---

## 9. Acceptance Criteria

Blake的实现被认为完成，当且仅当：
- [ ] `.agents/skills` and `.claude/skills` are byte-identical.
- [ ] Docs no longer say runtime freshness is pending/planned.
- [ ] Docs no longer say full-cycle regression has not run.
- [ ] Remaining Codex limitations are accurately stated.
- [ ] No runtime config/hook activation files were changed.

---

## 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE — Gate 3 executes each row

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| AC1 | Full Claude/Codex skills-tree parity restored | post-impl-verifiable | `diff -qr .agents/skills .claude/skills` | exit 0; no output | (post-impl) |
| AC2 | Publish reference is byte-identical | post-impl-verifiable | `diff -u .agents/skills/alex/references/publish-protocol.md .claude/skills/alex/references/publish-protocol.md` | exit 0; no output | (post-impl) |
| AC3 | Sync reference is byte-identical | post-impl-verifiable | `diff -u .agents/skills/alex/references/sync-protocol.md .claude/skills/alex/references/sync-protocol.md` | exit 0; no output | (post-impl) |
| AC4 | YOLO reference is byte-identical | post-impl-verifiable | `diff -u .agents/skills/alex/references/yolo-execution-protocol.md .claude/skills/alex/references/yolo-execution-protocol.md` | exit 0; no output | (post-impl) |
| AC5 | Runtime freshness still passes | post-impl-verifiable | `bash .tad/hooks/lib/runtime-freshness-verify.sh` | exit 0; output contains `VERDICT: runtime freshness PASS` | (post-impl) |
| AC6 | Multi-platform guide no longer contains stale Phase 4/5 pending claims | post-impl-verifiable | `bash -c '! rg -n "Runtime Freshness Layer \\(Phase 4 — pending\\)|Phase 4.*pending.*will create|Runtime freshness ledger not created|Full-cycle regression not yet run|runtime freshness pending" docs/MULTI-PLATFORM.md'` | exit 0; no stale claims | (post-impl) |
| AC7 | Codex README no longer contains stale runtime/regression gap claims | post-impl-verifiable | `bash -c '! rg -n "Runtime freshness \\| Pending Phase 4|Runtime freshness ledger missing|Full-cycle regression not run|hook matcher unknown" .tad/codex/README.md'` | exit 0; no stale claims | (post-impl) |
| AC8 | Codex config/agents remain draft-only, not activated | post-impl-verifiable | `bash -c 'test ! -f .codex/config.toml && test ! -d .codex/agents && rg -n "Not active|draft|Human explicitly approves|Final secrets audit" .tad/codex/README.md docs/MULTI-PLATFORM.md'` | exit 0; docs still preserve activation guardrails | (post-impl) |
| AC9 | No runtime hook/settings activation files changed | post-impl-verifiable | `bash -c '! git diff --name-only | rg -e "^\\.codex/hooks\\.json$|^\\.claude/settings\\.json$|^\\.codex/config\\.toml$|^\\.codex/agents/"'` | exit 0; no active runtime config/hook changes | (post-impl) |
| AC10 | Existing feedback-collector handoff preserved | post-impl-verifiable | `test -f .tad/active/handoffs/HANDOFF-20260610-feedback-collector-phase1.md` | exit 0; unrelated active handoff still present | (post-impl) |

---

## 9.2 Expert Review Status (Alex 必填)

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| N/A | Handoff generated directly from local parity review findings. | §2.2, §9.1 | Deferred to Blake Layer 2 |

### Experts Selected

Blake should use:
1. **code-reviewer** — verify diff scope, AC validity, and no accidental runtime config activation.
2. **backend-architect** — verify the platform boundary wording and remaining limitations are accurate.

### Overall Assessment

Ready for Blake. The fix is narrow but important because release/sync instructions are high-risk.

---

## 10. Important Notes

### 10.1 Critical Warnings
- Do not edit the unrelated feedback-collector handoff.
- Do not activate `.codex/config.toml` or `.codex/agents/`.
- Do not weaken the Claude-side release/sync migration gates.
- Do not leave `.agents/skills` and `.claude/skills` partially different.

### 10.2 Known Constraints
- Claude and Codex runtime mechanics remain different by design: Claude has Skill/Agent/workflows/settings hooks; Codex has AGENTS routing, `.agents/skills`, `.codex/hooks.json`, and prompt-driven subagent sessions.
- This task restores shared protocol parity, not feature parity for every platform-native automation surface.

### 10.3 Sub-Agent使用建议

Blake应该考虑使用：
- [ ] **code-reviewer** - required
- [ ] **backend-architect** - required

---

## 11. Learning Content（可选）

### 11.1 Decision Rationale: Byte-Parity for Shared Skills

**选择的方案**: restore byte identity across `.agents/skills` and `.claude/skills`.

| 方案 | 优点 | 缺点 | 为什么没选 |
|------|------|------|-----------|
| Byte identity | Simple invariant; catches hidden reference drift | Requires explicit platform docs for real runtime differences | ✅ Chosen |
| Allow platform-specific reference divergence | Could tune instructions per runtime | Violates shared protocol claim; high-risk release/sync drift | Rejected |
| Only fix docs | Easy | Leaves Codex Alex with stale operational instructions | Insufficient |

**Human学习点**: Runtime adapters can differ, but shared protocol/reference content must stay byte-identical unless a deliberate platform-specific fork is documented.

---

## Message to Blake

Blake, repair the Claude/Codex parity drift found by Alex. Use `.claude/skills` as the source of truth for the 3 drifted Alex reference files and make the full `.agents/skills` tree byte-identical to `.claude/skills`. Then update the dual-platform docs so they reflect the completed runtime freshness and regression evidence without claiming Codex config/agents are active. Do not touch the existing feedback-collector handoff and do not activate any Codex runtime config.

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-06-10
**Version**: 3.1.0


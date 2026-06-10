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
**Task ID:** TASK-20260609-004  
**Handoff Version:** 3.1.0  
**Epic:** EPIC-20260609-dual-platform-native-runtime-architecture.md (Phase 2/5)  
**Priority:** P1. Do not interrupt the active P0 release/sync handoff unless Human explicitly overrides.

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-06-09

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Phase 1 accepted the protocol/adapter boundary; Phase 2 scope is native Codex policy only |
| Components Specified | ✅ | Config policy, sandbox/approval profile, hooks, MCP, custom-agent candidates, and security boundaries are specified |
| Functions Verified | ✅ | No production code functions involved; this phase creates policy artifacts and draft candidates only |
| Data Flow Mapped | ✅ | Inputs: Phase 1 architecture + current `.codex/` state + Codex docs → Output: policy doc + draft config/agent candidates |

**Gate 2 结果**: ✅ PASS

**Alex确认**: Blake can independently complete this Phase 2 policy task. This handoff does **not** authorize enabling runtime config. It authorizes dry-run policy artifacts and candidate specs only.

---

## 📋 Handoff Checklist (Blake必读)

Blake在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] 阅读 Phase 1 accepted artifact
- [ ] 明确本任务不写 active `.codex/config.toml`
- [ ] 明确本任务不创建 active `.codex/agents/*`
- [ ] 明确 Codex feature/config claims 必须 current-source verified
- [ ] 明确 user-owned secrets/auth/personal paths 不得进入项目文件
- [ ] 确认可以独立使用本文档完成实现

❌ 如果任何部分不清楚，立即返回 Alex 要求澄清，不要开始实现。

---

## 1. Task Overview

### 1.1 What We're Building

Create the Phase 2 Codex Native Runtime Policy: a concrete project-vs-user configuration policy, sandbox/approval/profile policy, hooks strategy, MCP policy, and Codex custom-agent evaluation for TAD reviewer roles.

This phase produces **policy artifacts and draft candidates**, not active runtime configuration.

### 1.2 Why We're Building It

**业务价值**：TAD 需要利用 Codex 原生能力，但不能把用户级敏感配置、个人认证、或尚未验证的行为写进项目运行时。

**用户受益**：后续启用 Codex config/agents 时，有可审计的安全边界、配置依据、回退方案和质量链约束。

**成功的样子**：Human can decide whether to activate `.codex/config.toml` and `.codex/agents/` from a policy document and draft candidate files, without guessing what is project-owned vs user-owned.

### 1.3 Intent Statement

**真正要解决的问题**：把 Phase 1 的架构边界落成可执行的 Codex runtime policy，同时保持 Alex/Blake shared protocol 不被 fork。

**不是要做的（避免误解）**：
- ❌ 不是启用 active `.codex/config.toml`
- ❌ 不是创建 active `.codex/agents/*.toml`
- ❌ 不是把 Alex/Blake persona 复制成 Codex custom agents
- ❌ 不是把 TAD Layer 2 规则移动到 Codex agent TOML
- ❌ 不是配置用户 secrets、tokens、account IDs、personal paths
- ❌ 不是修改 `docs/MULTI-PLATFORM.md`，那是 Phase 3

**Blake请确认理解**：
```
在开始实现前，请用你自己的话回答：
1. 本 Phase 2 允许写哪些文件？禁止写哪些文件？
2. 为什么 custom agents 只能是 reviewer/expert roles，不能是完整 Alex/Blake？
3. 哪些 Codex 设置属于 project-owned，哪些必须留在 user-owned/global config？

只有 Human 确认你的理解正确后，才能开始实现。
```

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别

本次任务涉及的领域：
- [x] architecture - runtime adapter policy
- [x] security - secrets/auth/sandbox boundaries
- [x] testing - dry-run validation and future regression
- [x] code-quality - preventing protocol fork

### 步骤 2：历史经验摘录

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| `.tad/project-knowledge/patterns/handoff-design.md` | 4 | Platform assumptions decay; progressive loading loss; circular trigger; runtime freshness applies to both platforms |
| `.tad/project-knowledge/principles.md` | 3 | Constraint rules are not mechanical; hooks can fail-closed; structural checks can be validation theater |
| `.tad/project-knowledge/security.md` | 1+ | Secrets/auth boundaries must be explicit |
| `.tad/project-knowledge/patterns/ac-verification.md` | 1 | Static checks are insufficient; runtime-sensitive claims need empirical validation |

**⚠️ Blake 必须注意的历史教训**：

1. **Runtime Freshness Applies to Both First-Class Platforms**
   - Codex is high-volatility, but Claude Code is not freshness-exempt.
   - This phase should record how Codex policy entries will later feed Phase 4 runtime ledgers.

2. **Do Not Fork the Protocol**
   - `.codex/agents/*.toml` may hold narrow reviewer instructions, but Alex/Blake role contract, Gates, Layer 2 criteria, Ralph Loop, and completion/evidence rules remain in SKILL body.

3. **Hooks Can Fail-Closed**
   - Project hook policy must explain trust review, failure mode, timeout, and manual fallback. Do not assume Codex hooks are always enabled.

4. **Validation Theater**
   - A syntactically valid TOML draft is not proof that Codex agents produce useful reviews. Phase 2 must recommend a Phase 5 regression path.

---

## 2. Background Context

### 2.1 Previous Work

- Phase 1 accepted artifact: `.tad/evidence/designs/dual-platform-native-runtime-architecture.md`
- Phase 1 accepted boundary: shared protocol remains in SKILL; Codex config/agents are adapter mechanics.
- Current `.codex/` project state has `.codex/hooks.json` only.
- Current P0 handoff `HANDOFF-20260609-verify-and-sync.md` is active for v2.27 release/sync.

### 2.2 Current State

Known Codex surfaces from Phase 1:
- `.codex/config.toml` exists as trusted project config surface.
- `.codex/agents/*.toml` exists as custom agent surface.
- Codex hooks can be configured in JSON or TOML and require trust review.
- Codex supports MCP config, permissions/sandbox profiles, subagents, rules, and non-interactive runs.

Open questions for this Phase:
- Which settings should TAD own at project level?
- Which settings must remain user/global?
- Should current `.codex/hooks.json` remain the hook source of truth or be represented through config policy?
- Which reviewer roles are safe as custom-agent candidates?
- What evidence is needed before activating any candidate config?

### 2.3 Dependencies

This handoff can be executed after Phase 1 acceptance. It should not interrupt P0 release/sync unless Human explicitly says to run it in parallel.

---

## 3. Requirements

### 3.1 Functional Requirements

- FR1: Create `.tad/evidence/designs/codex-native-runtime-policy.md`.
- FR2: Create draft candidate files under `.tad/evidence/designs/codex-runtime-candidates/`.
- FR3: Define project-owned vs user-owned config boundaries.
- FR4: Define Codex sandbox/approval/profile strategy aligned with TAD quality and safety.
- FR5: Define hooks strategy for Codex, including current `.codex/hooks.json` assessment.
- FR6: Define MCP strategy: project-scoped vs user-scoped, allowed tools, approval modes, secrets boundary.
- FR7: Evaluate custom-agent candidates for reviewer/expert roles.
- FR8: Provide keep/migrate/defer decision per reviewer role.
- FR9: Define activation criteria for turning drafts into active `.codex/config.toml` / `.codex/agents/*.toml`.
- FR10: Record unresolved Codex behavior as `unknown_current_behavior`, not as a guessed claim.

### 3.2 Non-Functional Requirements

- NFR1: No active runtime config changes in this phase.
- NFR2: No secrets/auth/account IDs/personal paths in any artifact.
- NFR3: No protocol fork.
- NFR4: Current-source verification required for Codex config/agent/hook claims.
- NFR5: Dry-run candidates must be syntactically plausible but clearly marked as draft.
- NFR6: Phase 2 output must be usable as direct input to Phase 3 docs and Phase 4 freshness ledgers.

---

## 4. Technical Design

### 4.1 Allowed Writes

Create:
- `.tad/evidence/designs/codex-native-runtime-policy.md`
- `.tad/evidence/designs/codex-runtime-candidates/config.toml.draft`
- `.tad/evidence/designs/codex-runtime-candidates/agents/spec-compliance-reviewer.toml.draft`
- `.tad/evidence/designs/codex-runtime-candidates/agents/code-reviewer.toml.draft`
- `.tad/evidence/designs/codex-runtime-candidates/agents/test-runner.toml.draft`
- Optional: `.tad/evidence/designs/codex-runtime-candidates/agents/security-auditor.toml.draft`
- Optional: `.tad/evidence/designs/codex-runtime-candidates/agents/performance-optimizer.toml.draft`

Forbidden:
- `.codex/config.toml`
- `.codex/agents/*`
- `.agents/skills/*`
- `.claude/skills/*`
- `docs/MULTI-PLATFORM.md`
- `.tad/codex/README.md`
- `AGENTS.md`
- `.tad/hooks/*`

### 4.2 Required Policy Document Structure

Create `.tad/evidence/designs/codex-native-runtime-policy.md` with these top-level sections:

1. `# Codex Native Runtime Policy`
2. `## YAML Summary`
3. `## Source Refresh`
4. `## Current Project State`
5. `## Project-Owned vs User-Owned Boundary`
6. `## Config Policy`
7. `## Sandbox / Approval / Profile Policy`
8. `## Hooks Policy`
9. `## MCP Policy`
10. `## Custom Agents Evaluation`
11. `## Draft Candidate Files`
12. `## Security Review`
13. `## Activation Criteria`
14. `## Phase 3 and Phase 4 Inputs`
15. `## Risks and Unknowns`

### 4.3 YAML Summary Schema

```yaml
epic: EPIC-20260609-dual-platform-native-runtime-architecture
phase: 2
artifact_type: codex_runtime_policy
generated: 2026-06-09
status: proposed
active_runtime_changes: false
codex_source:
  runtime_version: "{codex-cli version or unknown}"
  manual_source: "{local manual path or official docs URL}"
  last_verified: 2026-06-09
outputs:
  policy_doc: true
  config_draft: true
  agent_drafts: true
  active_config_written: false
  active_agents_written: false
```

### 4.4 Required Boundary Matrix

Include this matrix in `## Project-Owned vs User-Owned Boundary`:

| Surface | Project-Owned? | User-Owned? | Commit to Repo? | Rationale | Example |
|---------|----------------|-------------|-----------------|-----------|---------|

Must cover:
- model defaults
- reasoning effort
- sandbox filesystem rules
- network permissions
- approval policy
- MCP server definitions
- MCP credentials/env
- hooks
- custom agents
- rules
- secrets/tokens
- user profile defaults
- machine-specific paths
- cloud environment variables

### 4.5 Required Custom-Agent Decisions

For each role, provide decision: `migrate_draft` / `keep_skill_only` / `defer`.

Required roles:
- spec-compliance-reviewer
- code-reviewer
- test-runner
- security-auditor
- performance-optimizer
- backend-architect
- Blake execution agent
- Alex solution lead

Expected baseline:
- Reviewer/expert roles may be `migrate_draft` or `defer`.
- Blake and Alex should be `keep_skill_only` unless Blake finds strong contrary evidence; any contrary recommendation must be P1 and heavily justified.

---

## 5. 强制问题回答（Evidence Required）

### MQ1: What is the current Codex documentation source?

Required:
- Run local manual helper if available:
  `node /Users/sheldonzhao/.codex/skills/.system/openai-docs/scripts/fetch-codex-manual.mjs`
- Record manual path, version/source, and timestamp.
- If it fails, use official OpenAI docs fallback only.

### MQ2: What is the current project `.codex/` state?

Required:
```bash
find .codex -maxdepth 3 -type f -print | sort
sed -n '1,220p' .codex/hooks.json
```

Record whether `.codex/config.toml` or `.codex/agents/` already exist before work starts.

### MQ3: Are any active runtime files changed?

Required answer must be: No.

If an active runtime file must be changed, stop and return to Alex/Human for explicit approval.

### MQ4: How are secrets protected?

Required:
- Explicit list of forbidden fields/content.
- Explicit statement that credentials/env values belong to user/global config, secret manager, or runtime environment, not the repo.

---

## 6. Implementation Steps

1. Check active P0 status.
   - If Human did not override parallel execution, do not start while P0 release/sync is active.
   - If Human did override, record the override in the policy doc.

2. Read Phase 1 boundary.
   - `.tad/evidence/designs/dual-platform-native-runtime-architecture.md`
   - `.tad/active/epics/EPIC-20260609-dual-platform-native-runtime-architecture.md`

3. Read current project state.
   - `.codex/hooks.json`
   - `AGENTS.md`
   - `.tad/codex/README.md`
   - `.agents/skills/alex/SKILL.md`
   - `.agents/skills/blake/SKILL.md`

4. Refresh Codex source.
   - Use local manual helper first.
   - Mark unresolved claims `unknown_current_behavior`.

5. Write policy doc using §4.2 structure.

6. Create draft candidate files under `.tad/evidence/designs/codex-runtime-candidates/`.
   - Draft files must include header comment:
     `# DRAFT ONLY — not active Codex runtime config`
   - Agent drafts must be minimal and role-specific.

7. Validate draft files.
   - If TOML parser is available, parse drafts.
   - If parser unavailable, record `parser_unavailable` and do structural checks.

8. Run scope checks in §8.

9. Produce completion report with:
   - project-owned/user-owned summary
   - keep/migrate/defer decisions
   - unresolved unknowns
   - whether Phase 2 is ready for Gate 4 activation decision

---

## 7. File Structure

### 7.1 Create

- `.tad/evidence/designs/codex-native-runtime-policy.md`
- `.tad/evidence/designs/codex-runtime-candidates/config.toml.draft`
- `.tad/evidence/designs/codex-runtime-candidates/agents/*.toml.draft`

### 7.2 Read

- `.tad/evidence/designs/dual-platform-native-runtime-architecture.md`
- `.tad/active/epics/EPIC-20260609-dual-platform-native-runtime-architecture.md`
- `.codex/hooks.json`
- `AGENTS.md`
- `.tad/codex/README.md`
- `.agents/skills/alex/SKILL.md`
- `.agents/skills/blake/SKILL.md`
- relevant Project Knowledge files listed above

### 7.3 Do Not Modify

- `.codex/config.toml`
- `.codex/agents/*`
- `.codex/hooks.json`
- `.agents/skills/*`
- `.claude/skills/*`
- `docs/MULTI-PLATFORM.md`
- `.tad/codex/README.md`
- `AGENTS.md`
- `.tad/hooks/*`

---

## 8. Testing Requirements

### 8.1 Artifact Existence

```bash
test -f .tad/evidence/designs/codex-native-runtime-policy.md
test -f .tad/evidence/designs/codex-runtime-candidates/config.toml.draft
find .tad/evidence/designs/codex-runtime-candidates/agents -maxdepth 1 -type f -name '*.toml.draft' | sort
```

### 8.2 Required Sections

```bash
rg -n "^## YAML Summary|^## Source Refresh|^## Project-Owned vs User-Owned Boundary|^## Config Policy|^## Sandbox / Approval / Profile Policy|^## Hooks Policy|^## MCP Policy|^## Custom Agents Evaluation|^## Activation Criteria" .tad/evidence/designs/codex-native-runtime-policy.md
```

### 8.3 Safety Terms

```bash
rg -n "active_runtime_changes: false|active_config_written: false|active_agents_written: false|secrets|tokens|personal paths|user-owned|project-owned|unknown_current_behavior" .tad/evidence/designs/codex-native-runtime-policy.md
```

### 8.4 Scope Check

Before editing, record pre-existing status for scoped paths. After editing, run:

```bash
git status --short -- .tad/evidence/designs/codex-native-runtime-policy.md .tad/evidence/designs/codex-runtime-candidates .codex/config.toml .codex/agents .codex/hooks.json .agents/skills .claude/skills docs/MULTI-PLATFORM.md .tad/codex/README.md AGENTS.md .tad/hooks
```

Expected:
- New/modified files only under `.tad/evidence/designs/`.
- Any pre-existing dirty state outside that scope must be reported separately and not claimed as Blake's change.

### 8.5 Draft TOML Check

Preferred:
```bash
python3 - <<'PY'
import tomllib, pathlib
for p in pathlib.Path('.tad/evidence/designs/codex-runtime-candidates').rglob('*.toml.draft'):
    tomllib.loads(p.read_text())
    print('OK', p)
PY
```

If `tomllib` is unavailable, use:
```bash
rg -n "DRAFT ONLY|name =|description =|developer_instructions =|model|reasoning|sandbox|approval" .tad/evidence/designs/codex-runtime-candidates
```

---

## 9. Acceptance Criteria

### 9.1 Spec Compliance Checklist

- [ ] Policy doc exists at `.tad/evidence/designs/codex-native-runtime-policy.md`
- [ ] Policy doc contains all 15 required sections
- [ ] YAML Summary declares `active_runtime_changes: false`
- [ ] Current Codex source was refreshed or official fallback was used
- [ ] Current `.codex/` project state is recorded before edits
- [ ] Project-owned vs user-owned matrix covers all required surfaces
- [ ] Config policy excludes secrets/auth/account IDs/personal paths
- [ ] Sandbox/approval/profile policy aligns with TAD quality/safety needs
- [ ] Hooks policy assesses current `.codex/hooks.json`
- [ ] MCP policy separates server definitions from credentials/env
- [ ] Custom-agent evaluation includes all 8 required roles
- [ ] Blake and Alex remain `keep_skill_only` unless explicitly justified as P1
- [ ] Draft candidate config exists under evidence path only
- [ ] Draft custom-agent files exist under evidence path only
- [ ] No active `.codex/config.toml` or `.codex/agents/*` files are created
- [ ] No SKILL, docs, hooks, or AGENTS files are modified
- [ ] Draft TOML parses or parser-unavailable fallback is documented
- [ ] Activation criteria define what must be true before active runtime config may be written

### 9.2 Definition of Done

Blake is done when:
- Policy artifact and draft candidates exist.
- Verification commands in §8 have been run.
- Layer 2 review checks policy/security/protocol-fork risks.
- Completion report lists keep/migrate/defer role decisions.
- Any unknown Codex behavior is explicit and assigned to Phase 3/4/5 follow-up.

---

## 10. Important Notes and Warnings

1. **This is not an activation handoff.** Do not create active `.codex/config.toml` or `.codex/agents/`.
2. **No secrets.** If a setting even smells user-specific, put it in user/global config or document it as external.
3. **No protocol fork.** Alex/Blake stay SKILL-first.
4. **Do not weaken P0 body/reference fix.** Runtime config and custom agents cannot replace SKILL-body execution discipline.
5. **Fail closed on unknown safety behavior.** Unknown Codex config/agent/hook behavior that affects quality gates must remain unadopted.
6. **Phase 3 line-number P2s remain open.** Do not edit docs yet, but carry the correction requirement forward.

---

## 11. Questions for Blake

Before implementation, answer:

1. Is Human overriding the active P0 priority, or should this wait?
2. What current Codex source did you use?
3. What files will you create?
4. Which active runtime files are forbidden?
5. What is your default recommendation for Alex/Blake custom agents?

---

## 12. Alex Final Note

The goal is not to make Codex config impressive. The goal is to make it safe, auditable, current, and subordinate to the shared TAD protocol where it should be subordinate.

---
task_type: mixed
e2e_required: no
research_required: yes
git_tracked_dirs: [".tad/runtime-compat", ".tad/hooks/lib"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)  
**To:** Blake (Agent B - Execution Master)  
**Date:** 2026-06-09  
**Project:** TAD Framework  
**Task ID:** TASK-20260609-006  
**Handoff Version:** 3.1.0  
**Epic:** EPIC-20260609-dual-platform-native-runtime-architecture.md (Phase 4/5)  
**Priority:** P1. Do not interrupt the active P0 release/sync handoff unless Human explicitly overrides.

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-06-09

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Phase 1/2/3 accepted the runtime boundary, policy, and docs |
| Components Specified | ✅ | Two ledgers, verifier script, release-verify integration, drift policy, and tests are specified |
| Functions Verified | ✅ | `release-verify.sh` exists and uses mode-based dispatch; new `freshness` mode can be added safely |
| Data Flow Mapped | ✅ | Ledgers → runtime-freshness-verify.sh → release-verify.sh freshness → release/sync gate |

**Gate 2 结果**: ✅ PASS

**Alex确认**: Blake can independently implement Phase 4. This phase may modify `.tad/hooks/lib/release-verify.sh`, but must preserve existing `structural` and `version` behavior.

---

## 📋 Handoff Checklist (Blake必读)

Blake在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] 阅读 Phase 1 architecture artifact
- [ ] 阅读 Phase 2 runtime policy artifact
- [ ] 阅读 Phase 3 updated docs
- [ ] 明确本任务允许创建 ledgers 和 freshness verifier
- [ ] 明确本任务不允许启用 `.codex/config.toml` / `.codex/agents/`
- [ ] 明确 release-verify existing modes must not regress

❌ 如果任何部分不清楚，立即返回 Alex 要求澄清，不要开始实现。

---

## 1. Task Overview

### 1.1 What We're Building

Implement the Runtime Freshness Loop promised by Phase 1-3:

- `.tad/runtime-compat/codex.md`
- `.tad/runtime-compat/claude-code.md`
- `.tad/hooks/lib/runtime-freshness-verify.sh`
- `release-verify.sh freshness` integration

### 1.2 Why We're Building It

**业务价值**：Codex and Claude Code capabilities change. Without a ledger and release gate, TAD will again ship stale platform assumptions.

**用户受益**：每次 release / sync 前可以机械检查 runtime assumptions 是否过期、未知或安全相关未验证，而不是依靠记忆。

**成功的样子**：A release operator can run `bash .tad/hooks/lib/release-verify.sh freshness .` and get PASS/WARN/BLOCK output with exact stale surfaces and next actions.

### 1.3 Intent Statement

**真正要解决的问题**：把“保持 Codex/Claude Code 最新”从原则变成可执行 release gate。

**不是要做的（避免误解）**：
- ❌ 不是自动采用 Codex 新功能
- ❌ 不是启用 `.codex/config.toml`
- ❌ 不是启用 `.codex/agents/*`
- ❌ 不是跑 Phase 5 full-cycle regression
- ❌ 不是改 Alex/Blake SKILL
- ❌ 不是替代 `skill-body-verify.sh`

**Blake请确认理解**：
```
在开始实现前，请用你自己的话回答：
1. Runtime freshness ledger 要防什么失败？
2. 哪些情况 freshness verifier 必须 hard block？
3. 为什么这个 phase 不能启用 Codex config/agents？

只有 Human 确认你的理解正确后，才能开始实现。
```

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别

本次任务涉及的领域：
- [x] architecture - runtime compatibility governance
- [x] testing - release gate verification
- [x] security - fail-closed for unknown safety behavior
- [x] code-quality - shell portability and no validation theater

### 步骤 2：历史经验摘录

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| `.tad/project-knowledge/patterns/handoff-design.md` | 5+ | Platform assumptions decay; runtime freshness applies to both platforms |
| `.tad/project-knowledge/patterns/ac-verification.md` | 3 | Avoid validation theater; commands must check actual semantics |
| `.tad/project-knowledge/patterns/shell-portability.md` | 1+ | macOS/BSD-safe shell required |
| `.tad/project-knowledge/principles.md` | 3 | Fail closed on quality-chain risk; hooks are smoke alarms in single-user CLI |

**⚠️ Blake 必须注意的历史教训**：

1. **Platform Capability Assumptions Decay Fast**
   - Ledger entries must record source, version, `last_verified`, volatility, and next review.

2. **Runtime Freshness Applies to Both First-Class Platforms**
   - Codex is high volatility; Claude Code is lower volatility, not exempt.

3. **Validation Theater**
   - A script that only greps keywords is not enough. It must parse ledger rows, compute age, classify high/medium/low volatility, and fail on missing/malformed required fields.

4. **Shell Portability**
   - Use bash + POSIX/BSD-compatible tools. Avoid GNU-only `date -d`, `grep -P`, associative array assumptions that break on macOS bash if possible.

---

## 2. Background Context

### 2.1 Previous Work

- Phase 1 accepted architecture: `.tad/evidence/designs/dual-platform-native-runtime-architecture.md`
- Phase 2 accepted policy: `.tad/evidence/designs/codex-native-runtime-policy.md`
- Phase 3 accepted docs: `docs/MULTI-PLATFORM.md`, `.tad/codex/README.md`, `AGENTS.md`
- Current active Codex state: `.codex/hooks.json` only; no `.codex/config.toml`; no `.codex/agents/`

### 2.2 Current State

No runtime compatibility ledger exists:
- `.tad/runtime-compat/` does not exist.

Release verification exists:
- `.tad/hooks/lib/release-verify.sh`
- Current modes: `structural`, `version`

Phase 4 should add:
- `runtime-freshness-verify.sh`
- `release-verify.sh freshness <repo_root> [today]`

### 2.3 Dependencies

Phase 3 is accepted. This phase may run now if Human wants to continue. It must not run Phase 5 regression or activate Codex native config.

---

## 3. Requirements

### 3.1 Functional Requirements

- FR1: Create `.tad/runtime-compat/codex.md`.
- FR2: Create `.tad/runtime-compat/claude-code.md`.
- FR3: Create `.tad/hooks/lib/runtime-freshness-verify.sh`.
- FR4: Add `freshness` mode to `.tad/hooks/lib/release-verify.sh`.
- FR5: Ledger entries must include required fields: surface, owner, current_behavior, source, runtime_version, last_verified, volatility, next_review, regression_required, fallback_behavior, status.
- FR6: Verifier must parse both ledgers and report PASS/WARN/BLOCK per entry.
- FR7: Verifier must hard block missing ledger files, malformed required fields, invalid dates, unknown safety/quality behavior, and high-volatility stale entries.
- FR8: Verifier must produce actionable output: platform, surface, problem, and required next action.
- FR9: Release verify must call the verifier without changing existing `structural` or `version` mode semantics.
- FR10: Provide a drift response policy in the ledgers or a README section.

### 3.2 Non-Functional Requirements

- NFR1: No active Codex config/agent activation.
- NFR2: No SKILL file changes.
- NFR3: BSD/macOS compatible shell.
- NFR4: Existing release-verify modes must still pass smoke tests.
- NFR5: False negative risk is worse than false positive. Fail closed on malformed data.
- NFR6: Output must be usable by humans in release/sync workflows.

---

## 4. Technical Design

### 4.1 Ledger Format

Each ledger must be Markdown with one machine-readable table:

```markdown
# Runtime Compatibility Ledger: Codex

**Platform:** codex
**Ledger Version:** 1
**Last Updated:** 2026-06-09

## Drift Response Policy
...

## Ledger Entries

| surface | owner | current_behavior | source | runtime_version | last_verified | volatility | next_review | regression_required | fallback_behavior | status |
|---------|-------|------------------|--------|-----------------|---------------|------------|-------------|---------------------|------------------|--------|
| skill_loading | codex_adapter | ... | Codex manual lines ... | codex-cli 0.137.0 | 2026-06-09 | high | 2026-07-09 | no | explicit $skill-name invocation | verified |
```

Allowed `volatility`:
- `high`
- `medium`
- `low`

Allowed `status`:
- `verified`
- `verified_partial`
- `unknown_current_behavior`
- `accepted_limitation`
- `deferred`

### 4.2 Required Codex Surfaces

Codex ledger must cover at minimum:
- skill_loading
- agents_guidance_AGENTS_md
- hooks
- subagents_custom_agents
- mcp
- config_toml
- sandbox_approval_permissions
- codex_cloud
- context_compaction
- trace_evidence_capture
- release_sync_install
- ask_user_question_hook

### 4.3 Required Claude Code Surfaces

Claude Code ledger must cover at minimum:
- skill_loading
- hooks_settings
- workflows
- agent_tool_subagents
- mcp
- permissions
- context_compaction
- trace_evidence_capture
- release_sync_source

### 4.4 Freshness Rules

Verifier rules:

| Condition | Result |
|-----------|--------|
| Missing ledger file | BLOCK exit 2 |
| Malformed row / missing required field | BLOCK exit 2 |
| Invalid date | BLOCK exit 2 |
| `status=unknown_current_behavior` and surface affects safety/quality/evidence | BLOCK exit 1 |
| `status=accepted_limitation` with fallback_behavior and regression_required=yes | PASS/WARN by freshness age; include carry-forward note |
| `volatility=high` and `last_verified` older than 30 days | BLOCK exit 1 |
| `volatility=medium` and `last_verified` older than 60 days | WARN exit 0 |
| `volatility=low` and `last_verified` older than 180 days | WARN exit 0 |
| `next_review` before today | WARN or BLOCK depending on volatility: high=BLOCK, medium/low=WARN |
| all entries current | PASS exit 0 |

Safety/quality/evidence surfaces that must block when unknown:
- hooks
- ask_user_question_hook
- sandbox_approval_permissions
- trace_evidence_capture
- subagents_custom_agents when activation is planned
- context_compaction

### 4.5 Script Interface

Create:

```bash
.tad/hooks/lib/runtime-freshness-verify.sh [repo_root] [today_yyyy_mm_dd]
```

Behavior:
- default repo root: current working directory
- default today: current date
- exit 0: PASS or WARN only
- exit 1: freshness BLOCK
- exit 2: wiring/malformed usage BLOCK

Output:
- `VERDICT: runtime freshness PASS`
- `VERDICT: runtime freshness WARN`
- `VERDICT: runtime freshness BLOCK`
- include `GATE: runtime-freshness exit=<n>` on non-zero

### 4.6 release-verify.sh Integration

Add mode:

```bash
release-verify.sh freshness <repo_root> [today_yyyy_mm_dd]
```

This should call:

```bash
bash "$SCRIPT_DIR/runtime-freshness-verify.sh" "$REPO" "${TODAY:-}"
```

Do not alter `structural` or `version` mode behavior.

### 4.7 Required Ledger Content Guidance

Use Phase 1/2/3 artifacts as sources. Do not invent unsupported claims.

For Codex entries:
- Use refreshed Codex manual where needed.
- `ask_user_question_hook` should record `current_behavior=unknown_current_behavior`, `status=accepted_limitation`, volatility high, `regression_required=yes`, and fallback behavior: conversational questioning + manual decision evidence until Phase 5 resolves.
- Do not set `status=unknown_current_behavior` for `ask_user_question_hook` in the current ledger unless the verifier is expected to block. The Phase 4 current-ledger smoke test must pass while preserving the unresolved behavior as an accepted limitation.

For Claude Code entries:
- Use existing TAD docs/project knowledge as source.
- Mark volatility low or medium, not high unless a surface is known to be changing rapidly.

---

## 5. 强制问题回答（Evidence Required）

### MQ1: Did you verify current Codex version/source?

Required:
```bash
codex --version
node /Users/sheldonzhao/.codex/skills/.system/openai-docs/scripts/fetch-codex-manual.mjs
```

If manual fetch fails due network, use the most recent cached manual only if timestamp is same-day; otherwise record `source_unavailable` and do not update verified dates.

### MQ2: Did the verifier fail closed on a high-volatility stale entry?

Required:
- Create temp copy or fixture under `/tmp` or `$TMPDIR`.
- Change one Codex high-volatility `last_verified` to more than 30 days old.
- Run verifier against fixture.
- Expected: exit 1 BLOCK.

### MQ3: Did malformed ledger data block?

Required:
- Create temp fixture with a missing required field or invalid date.
- Expected: exit 2 BLOCK.

### MQ4: Are existing release-verify modes preserved?

Required smoke checks:
```bash
bash .tad/hooks/lib/release-verify.sh version . 2.26.0
bash .tad/hooks/lib/release-verify.sh freshness . 2026-06-09
```

Do not require structural mode against downstream projects in this phase.

---

## 6. Implementation Steps

1. Read accepted artifacts:
   - `.tad/evidence/designs/dual-platform-native-runtime-architecture.md`
   - `.tad/evidence/designs/codex-native-runtime-policy.md`
   - `docs/MULTI-PLATFORM.md`
   - `.tad/codex/README.md`
   - `AGENTS.md`

2. Refresh Codex source:
   - run `codex --version`
   - run Codex manual helper
   - record source details in `codex.md`

3. Create `.tad/runtime-compat/`.

4. Create `.tad/runtime-compat/codex.md`.
   - Include drift response policy.
   - Include required Codex surface rows.
   - Mark unresolved safety/evidence surfaces honestly.

5. Create `.tad/runtime-compat/claude-code.md`.
   - Include drift response policy.
   - Include required Claude Code surface rows.

6. Create `.tad/hooks/lib/runtime-freshness-verify.sh`.
   - Parse ledger tables.
   - Validate required fields.
   - Compute age from `last_verified` and `next_review`.
   - Emit PASS/WARN/BLOCK.

7. Modify `.tad/hooks/lib/release-verify.sh`.
   - Add usage line for `freshness`.
   - Add `freshness)` case.
   - Preserve existing modes.

8. Run tests from §8.

9. Run Layer 2 review:
   - spec-compliance reviewer
   - code-reviewer focused on shell correctness, fail-closed behavior, and release-verify regression

---

## 7. File Structure

### 7.1 Create

- `.tad/runtime-compat/codex.md`
- `.tad/runtime-compat/claude-code.md`
- `.tad/hooks/lib/runtime-freshness-verify.sh`

### 7.2 Modify

- `.tad/hooks/lib/release-verify.sh`

### 7.3 Do Not Modify

- `.codex/config.toml`
- `.codex/agents/*`
- `.codex/hooks.json`
- `.agents/skills/*`
- `.claude/skills/*`
- `docs/MULTI-PLATFORM.md` unless a tiny link to ledgers is needed
- `.tad/codex/README.md` unless a tiny link to ledgers is needed
- version/changelog files

---

## 8. Testing Requirements

### 8.1 Artifact Existence

```bash
test -f .tad/runtime-compat/codex.md
test -f .tad/runtime-compat/claude-code.md
test -x .tad/hooks/lib/runtime-freshness-verify.sh
```

### 8.2 Required Ledger Fields

```bash
rg -n "surface \\| owner \\| current_behavior \\| source \\| runtime_version \\| last_verified \\| volatility \\| next_review \\| regression_required \\| fallback_behavior \\| status" .tad/runtime-compat/codex.md .tad/runtime-compat/claude-code.md
rg -n "ask_user_question_hook|unknown_current_behavior|codex-cli|claude_code|last_verified|next_review" .tad/runtime-compat/*.md
```

### 8.3 Freshness PASS

```bash
bash .tad/hooks/lib/runtime-freshness-verify.sh . 2026-06-09
```

Expected: exit 0.

### 8.4 release-verify Integration

```bash
bash .tad/hooks/lib/release-verify.sh freshness . 2026-06-09
bash .tad/hooks/lib/release-verify.sh version . 2.26.0
```

Expected: both exit 0.

### 8.5 Fail-Closed Fixture Tests

Use temp fixtures. At minimum:

- high-volatility stale entry older than 30 days → exit 1
- malformed date → exit 2
- missing required ledger file → exit 2

Record exact commands and outputs in completion report.

### 8.6 Scope Check

```bash
git status --short -- .tad/runtime-compat .tad/hooks/lib/runtime-freshness-verify.sh .tad/hooks/lib/release-verify.sh .codex/config.toml .codex/agents .codex/hooks.json .agents/skills .claude/skills docs/MULTI-PLATFORM.md .tad/codex/README.md
```

Expected:
- created: `.tad/runtime-compat/*`
- created: `.tad/hooks/lib/runtime-freshness-verify.sh`
- modified: `.tad/hooks/lib/release-verify.sh`
- no active `.codex/config.toml` / `.codex/agents`
- no SKILL changes

---

## 9. Acceptance Criteria

### 9.1 Spec Compliance Checklist

- [ ] `.tad/runtime-compat/codex.md` exists
- [ ] `.tad/runtime-compat/claude-code.md` exists
- [ ] Both ledgers include drift response policy
- [ ] Both ledgers include all required fields
- [ ] Codex ledger includes all required Codex surfaces
- [ ] Claude Code ledger includes all required Claude Code surfaces
- [ ] `ask_user_question_hook` is represented as unresolved, accepted_limitation, fallback-covered, and regression-required
- [ ] `runtime-freshness-verify.sh` exists and is executable
- [ ] Verifier exits 0 on current ledgers
- [ ] Verifier exits 1 on high-volatility stale fixture
- [ ] Verifier exits 2 on malformed/missing fixture
- [ ] `release-verify.sh freshness . 2026-06-09` exits 0
- [ ] `release-verify.sh version . 2.26.0` still exits 0
- [ ] Existing release-verify usage is updated without breaking `structural` or `version`
- [ ] No active `.codex/config.toml` or `.codex/agents/*` created
- [ ] No SKILL, `.codex/hooks.json`, version, or changelog files modified
- [ ] Layer 2 review P0=0, P1=0, with post-fix review evidence if fixes are made

### 9.2 Definition of Done

Blake is done when:
- Ledgers exist and are parseable.
- Freshness verifier exists and is executable.
- Release-verify freshness mode works.
- Fail-closed tests are documented.
- Completion report lists PASS/WARN/BLOCK behavior and carry-forward items for Phase 5.

---

## 10. Important Notes and Warnings

1. **Do not activate Codex config/agents.**
2. **Do not hide unknown behavior.** `ask_user_question_hook` remains unresolved until Phase 5, but should be modeled as an accepted limitation so the current ledger can pass with an explicit fallback.
3. **Do not make all staleness fatal.** High volatility stale blocks; medium/low stale warns unless safety/quality unknown.
4. **Do not break release-verify existing API.** Exit-code semantics are consumed by Alex publish/sync.
5. **Do not use GNU-only shell assumptions.** This repo runs on macOS.
6. **Do not overfit to today's Codex manual.** Ledger records current state and next review, not eternal truth.

---

## 11. Questions for Blake

Before implementation, answer:

1. Which ledger surfaces are safety/quality/evidence-affecting and therefore fail-closed when unknown?
2. What exit code means freshness drift vs wiring/malformed data?
3. How will you prove release-verify `version` mode still works?
4. Which files are forbidden in this phase?

---

## 12. Alex Final Note

This is the phase where the architecture stops being aspirational. If the freshness check cannot fail, it is not a gate. If it cannot explain what to fix, it is not useful.

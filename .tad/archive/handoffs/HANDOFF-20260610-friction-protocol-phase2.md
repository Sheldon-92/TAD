---
task_type: code
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
**Task ID:** TASK-20260610-002
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260610-friction-protocol.md (Phase 2/2)
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-06-10 14:45

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Advisory checker scope, inputs, outputs, exit semantics, and fixture strategy are specified. |
| Components Specified | ✅ | One script, one fixture directory, optional Gate SKILL advisory invocation text, and status docs updates. |
| Functions Verified | ✅ | Existing script patterns verified in `verify-ac-commands.sh`, `pack-registry-driftcheck.sh`, and `common.sh`; new script is standalone shell. |
| Data Flow Mapped | ✅ | Completion report → parser → WARN/RESULT output + advisory exit code → human/Gate review. |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

Blake在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] 阅读了「📚 Project Knowledge」章节中的历史经验
- [ ] 理解这是 advisory smoke alarm，不是 hard-block hook
- [ ] 确认 fixtures 覆盖 PASS、BLOCKED-as-PASS、missing section、verdict mismatch
- [ ] 每个 §9.1 AC 都会真实执行并填入 completion report

---

## 1. Task Overview

### 1.1 What We're Building
Create Phase 2 of the TAD Friction Protocol: a manually runnable advisory checker that scans completion reports for malformed or contradictory Friction Status evidence.

### 1.2 Why We're Building It
Phase 1 made the protocol visible in Alex/Blake/Gate and templates. Gate 4 then caught a real drift: `gate3_verdict: pass` was present, but prose/checklist still said pending. Phase 2 should catch that class automatically as a smoke alarm.

**Success looks like**: Blake can run one script against a completion report or fixture and see WARNs for friction evidence problems without any hook/settings hard block.

### 1.3 Intent Statement

**真正要解决的问题**: prevent "blocked-as-pass" and "pending text hiding under PASS" from surviving report review.

**不是要做的**:
- Not a PreToolUse/PostToolUse/UserPromptSubmit/SessionStart hook.
- Not a `.claude/settings.json` or `.codex/hooks.json` permission change.
- Not a rewrite of Phase 1 protocol semantics.
- Not a full markdown parser; robust shell heuristics are enough for a smoke alarm.

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别

- [x] architecture
- [x] principles
- [x] code-quality

### 步骤 2：历史经验摘录

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| `.tad/project-knowledge/principles.md` | 2 | Single-user CLI prefers smoke alarms over fail-closed hooks; grep count smoke alarms need explainable ground truth. |
| `.tad/project-knowledge/architecture.md` | 1 | Script gates should avoid brittle hardcoded assumptions where derived checks can work. |
| `.tad/project-knowledge/code-quality.md` | 1 | Verification commands must be runnable and not theater. |

**⚠️ Blake 必须注意的历史教训**:

1. **Mechanical Enforcement Rejected on Single-User CLI** (`principles.md`)
   - 问题: Fail-closed hooks caused high recovery cost when the local environment was missing dependencies.
   - 解决方案: This checker is manual/advisory. It may exit nonzero to signal review, but must not be registered as a blocking hook.

2. **AC verification command drift**
   - 问题: Broken verification commands can create false confidence.
   - 解决方案: Add fixtures and a run-all script; every negative fixture must prove both output text and exit code.

---

## 2. Background Context

### 2.1 Previous Work
Phase 1 accepted on 2026-06-10:
- Alex/Blake SKILL bodies now define the fixed Friction Status enum.
- Gate SKILL now contains Friction_Status_Check and Gate4_Friction_Review.
- Completion template now contains a Friction Status table.
- Acceptance report: `.tad/evidence/acceptance-tests/friction-protocol-phase1/gate4-acceptance-report.md`.

### 2.2 Current State
There is no checker script. Manual Gate 4 review caught the consistency bug, but the next run should get an advisory warning before human acceptance.

### 2.3 Dependencies
Use only POSIX/BSD-safe shell tooling already common in this repo: `bash`, `awk`, `grep`, `sed`, `find`, `mktemp`, `wc`. Do not require jq.

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1: Add `.tad/hooks/lib/friction-status-check.sh`.
- FR2: Script accepts explicit completion-report paths as args.
- FR3: With no args, script scans only `.tad/active/handoffs/COMPLETION-*.md` if present; if none, print a clean informational result and exit 0.
- FR4: Emit `WARN` and exit 1 when a Gate 3 PASS report has an unresolved `BLOCKED` row in Friction Status.
- FR5: Emit `WARN` and exit 1 when a Gate 3 PASS report is missing a Friction Status section.
- FR6: Emit `WARN` and exit 1 when frontmatter says `gate3_verdict: pass` but Gate 3 prose/checklist still contains pending/to-be-filled/unchecked Gate 3 status.
- FR7: Emit `RESULT: clean` and exit 0 for a valid report.
- FR8: Add fixtures covering clean pass, blocked-as-pass, missing Friction Status, and verdict mismatch.
- FR9: Add optional Gate SKILL text telling Gate 3/4 operators they may run this advisory checker; do not change existing blocking rules.

### 3.2 Non-Functional Requirements
- NFR1: Advisory only. No hook registration, no settings modification, no fail-closed session behavior.
- NFR2: BSD/macOS-safe. No `grep -P`, no GNU-only `sed -r`, no Python/Node dependency.
- NFR3: Tolerate malformed markdown: warn when possible, never crash with shell stack traces.
- NFR4: Human-readable output must include file path, warning type, and enough context to fix the report.

---

## 4. Technical Design

### 4.1 Architecture Overview

```
completion report(s)
  ↓
friction-status-check.sh
  ↓
per-file scan:
  - Gate 3 PASS detection
  - Friction Status section detection
  - BLOCKED row detection
  - verdict/prose/checklist consistency detection
  ↓
WARN lines + RESULT summary + advisory exit code
```

### 4.2 Component Specifications

#### `.tad/hooks/lib/friction-status-check.sh`
Recommended behavior:
- Resolve repo root from script location, following existing `.tad/hooks/lib/*.sh` patterns.
- If args are present, scan exactly those files.
- If args are absent, expand active completion reports only:
  - `.tad/active/handoffs/COMPLETION-*.md`
  - If none exist, print `RESULT: clean — no active completion reports found` and exit 0.
- For each readable file:
  - Determine Gate 3 PASS if either frontmatter contains `gate3_verdict: pass` or prose contains `Gate 3 v2 结果` with `PASS`.
  - Locate a heading containing `Friction Status`; section ends at the next markdown heading `^#{1,6} `.
  - Parse markdown table rows inside the section. The second cell is the Status column in Phase 1 template.
  - Warn if any Status cell equals `BLOCKED`.
  - Warn if Gate 3 PASS and no Friction Status heading exists.
  - Warn if frontmatter says pass but the report still contains obvious pending placeholders near Gate 3:
    - `Gate 3 v2 结果` line with `pending` / `to be filled`
    - unchecked checklist row for `Gate 3 v2 通过`
    - phrase `awaiting Alex Gate 4` is OK; do not treat it as Gate 3 pending.
- Summary:
  - `RESULT: clean` with exit 0 when no warnings.
  - `RESULT: WARNINGS DETECTED (advisory)` with exit 1 when warnings exist.

Do not use `set -e`. Individual parse failures should become warnings or skipped files, not crashes.

#### Fixtures
Create:
```
.tad/evidence/fixtures/friction-status-check/pass.md
.tad/evidence/fixtures/friction-status-check/blocked-as-pass.md
.tad/evidence/fixtures/friction-status-check/missing-friction-status.md
.tad/evidence/fixtures/friction-status-check/pending-text-mismatch.md
.tad/evidence/fixtures/friction-status-check/run-all.sh
```

Fixture expectations:
- `pass.md`: `gate3_verdict: pass`, `Gate 3 v2 结果: ✅ PASS`, checked Gate 3 checklist, Friction Status with `READY` and `NOT_APPLICABLE_WITH_REASON`; exit 0.
- `blocked-as-pass.md`: same PASS markers, one Friction Status row with Status `BLOCKED`; exit 1 with `WARN`.
- `missing-friction-status.md`: PASS markers, no Friction Status heading; exit 1 with `WARN`.
- `pending-text-mismatch.md`: frontmatter `gate3_verdict: pass` but `Gate 3 v2 结果: (pending — to be filled...)` and/or unchecked Gate 3 checklist; exit 1 with `WARN`.
- `run-all.sh`: runs all fixtures and verifies expected exit codes and warning/clean text.

#### Gate SKILL advisory invocation
Add a short advisory note near existing `Friction_Status_Check` / `Gate4_Friction_Review`:
```
Optional advisory smoke alarm:
  bash .tad/hooks/lib/friction-status-check.sh <completion-report.md>
This script reports missing/malformed Friction Status evidence. It is advisory and must not be registered as a hook.
```

Do not alter the existing rule that unresolved `BLOCKED` rows block Gate 3/4 by human/Gate protocol.

---

## 5. Mandatory Questions

### MQ1: Existing Similar Code

**回答**: 是。

#### 搜索证据
```bash
find .tad/hooks/lib -maxdepth 1 -type f | sort
sed -n '1,220p' .tad/hooks/lib/verify-ac-commands.sh
sed -n '1,220p' .tad/hooks/lib/pack-registry-driftcheck.sh
```

#### 决策说明
- Found advisory scripts with explicit smoke-alarm safety comments.
- Reuse their style: shell script under `.tad/hooks/lib/`, manual invocation, no settings registration, human-readable result.

### MQ2: 函数存在性验证

| 函数名 | 文件位置 | 行号 | 代码片段 | 验证 |
|--------|---------|------|---------|------|
| N/A | New standalone shell script | N/A | N/A | ✅ No existing functions are called directly |

### MQ3: 数据流完整性

| 输入字段 | 用途说明 | 输出 | 是否显示 | 不显示原因 |
|---------|---------|------|---------|-----------|
| `gate3_verdict` | Detect frontmatter PASS | WARN/clean | ✅ | N/A |
| `Gate 3 v2 结果` | Detect prose PASS/pending mismatch | WARN/clean | ✅ | N/A |
| Friction Status table Status column | Detect unresolved `BLOCKED` | WARN/clean | ✅ | N/A |
| Gate 3 checklist row | Detect unchecked checklist under PASS | WARN/clean | ✅ | N/A |

```
Completion report → shell parser → per-file warnings → summary + exit code
```

### MQ4: 视觉层级
N/A — CLI output only.

### MQ5: 状态同步
Single source of truth is the completion report being scanned. Fixtures are independent test inputs.

---

## 6. Implementation Steps

## 6.1 Micro-Tasks

| # | File | Operation | Verification Command | Est. Time |
|---|------|-----------|---------------------|-----------|
| 1 | `.tad/hooks/lib/friction-status-check.sh` | Create advisory checker script | `bash .tad/hooks/lib/friction-status-check.sh` | 10 min |
| 2 | `.tad/evidence/fixtures/friction-status-check/*.md` | Create 4 report fixtures | `ls .tad/evidence/fixtures/friction-status-check/*.md` | 10 min |
| 3 | `.tad/evidence/fixtures/friction-status-check/run-all.sh` | Create fixture harness | `bash .tad/evidence/fixtures/friction-status-check/run-all.sh` | 10 min |
| 4 | `.agents/skills/gate/SKILL.md` and mirror | Add optional advisory invocation note | `rg -n 'friction-status-check.sh|advisory' .agents/skills/gate/SKILL.md .claude/skills/gate/SKILL.md` | 5 min |
| 5 | Epic/NEXT/session state | Update Phase 2 status | `rg -n 'friction-status-check|Phase 2' NEXT.md .tad/active/epics/EPIC-20260610-friction-protocol.md` | 5 min |

### Phase 2: Advisory Checker（预计1-2小时）

#### 交付物
- [ ] `.tad/hooks/lib/friction-status-check.sh`
- [ ] `.tad/evidence/fixtures/friction-status-check/` with 4 fixtures + `run-all.sh`
- [ ] Gate SKILL advisory invocation text in `.agents` and `.claude` mirrors
- [ ] Updated Epic/NEXT/session state
- [ ] Completion report with §9.1 evidence

#### 实施步骤
1. Create script with safety header and advisory exit semantics.
2. Add fixtures.
3. Add fixture runner.
4. Run all fixtures and direct AC commands.
5. Add Gate SKILL advisory text and mirror sync.
6. Update Phase 2 bookkeeping.

#### 验证方法
- Run every §9.1 row exactly.
- Run fixture harness.
- Confirm no root hook/settings files changed.

---

## 7. File Structure

### 7.1 Files to Create
```
.tad/hooks/lib/friction-status-check.sh
.tad/evidence/fixtures/friction-status-check/pass.md
.tad/evidence/fixtures/friction-status-check/blocked-as-pass.md
.tad/evidence/fixtures/friction-status-check/missing-friction-status.md
.tad/evidence/fixtures/friction-status-check/pending-text-mismatch.md
.tad/evidence/fixtures/friction-status-check/run-all.sh
```

### 7.2 Files to Modify
```
.agents/skills/gate/SKILL.md
.claude/skills/gate/SKILL.md
.tad/active/epics/EPIC-20260610-friction-protocol.md
NEXT.md
.tad/active/session-state.md
```

### 7.3 Grounded Against

- `.tad/hooks/lib/verify-ac-commands.sh` (head + core body read at 2026-06-10 14:40)
- `.tad/hooks/lib/pack-registry-driftcheck.sh` (head + core body read at 2026-06-10 14:40)
- `.tad/hooks/lib/common.sh` (head + trace helpers read at 2026-06-10 14:40)
- `.agents/skills/gate/SKILL.md` (Friction_Status_Check location read at 2026-06-10 14:35)
- `.tad/archive/handoffs/COMPLETION-20260610-friction-protocol-phase1.md` (real accepted report shape read at 2026-06-10 14:42)

---

## 8. Testing Requirements

### 8.1 Unit Tests
Fixtures are the unit tests. Each fixture is a minimal completion report with one expected outcome.

### 8.2 Integration Tests
Run checker against:
- All fixtures via `run-all.sh`
- The real accepted Phase 1 completion report in `.tad/archive/handoffs/`

### 8.3 Edge Cases
- No args and no active completion reports → clean exit 0.
- Missing/unreadable file arg → WARN and exit 1, not crash.
- Markdown table separator rows must not be interpreted as status rows.
- `NOT_APPLICABLE_WITH_REASON` must not be mistaken for a failure.
- `DEGRADED_WITH_APPROVAL` / `EQUIVALENT_SUBSTITUTE` may warn about missing evidence only if Blake chooses to add that extra check; not required for Phase 2 AC.

## 8.4 Friction Preflight

| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|----------------|---------------|-------------------|--------------------|-------------|
| Script accidentally becomes hard-blocking hook | Keep checker manual/advisory | Do not edit `.claude/settings.json`, `.codex/hooks.json`, or root `.tad/hooks/*.sh` | None | Hook/settings modification blocks acceptance |
| Shell portability | Use BSD-safe shell | Avoid `grep -P`, GNU-only sed/awk, Python/Node deps | Equivalent POSIX/BSD command | Non-portable checker blocks Gate 3 |
| Fixture theater | Negative fixtures must assert exit code and WARN text | `run-all.sh` checks both | Manual reviewer can rerun individual commands | Missing fixture proof blocks Gate 3 |
| Active report noise | No-arg scan limited to active completions | Explicit args for archive/fixtures | N/A | Excessive historical noise is a P1 fix |

**Status Enum** (use exactly these values in Friction Status table at completion):
`READY` / `BLOCKED` / `DEGRADED_WITH_APPROVAL` / `EQUIVALENT_SUBSTITUTE` / `NOT_APPLICABLE_WITH_REASON`

### 8.5 Test Evidence Required
Blake必须提供：
- [ ] Fixture harness output
- [ ] Direct checker output against real Phase 1 completion report
- [ ] `git diff --name-only` proof that no hook/settings registration was touched

---

## 9. Acceptance Criteria

Blake的实现被认为完成，当且仅当：
- [ ] Script exists and follows advisory safety constraints.
- [ ] Clean fixture passes with exit 0.
- [ ] All negative fixtures emit WARN and exit 1.
- [ ] Real accepted Phase 1 completion report scans clean.
- [ ] Gate SKILL references the advisory checker without changing blocking semantics.
- [ ] No hook/settings registration files were modified.

---

## 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE — Gate 3 executes each row

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| AC1 | Checker script exists with advisory safety guardrails | post-impl-verifiable | `test -f .tad/hooks/lib/friction-status-check.sh && rg -n -e 'SMOKE ALARM' -e 'MUST NOT be registered' -e 'advisory' .tad/hooks/lib/friction-status-check.sh` | exit 0; safety strings found | (post-impl) |
| AC2 | Clean fixture exits 0 and reports clean | post-impl-verifiable | `bash .tad/hooks/lib/friction-status-check.sh .tad/evidence/fixtures/friction-status-check/pass.md` | exit 0; output contains `RESULT: clean` | (post-impl) |
| AC3 | BLOCKED-as-PASS fixture warns and exits 1 | post-impl-verifiable | `bash -c 'out="$(bash .tad/hooks/lib/friction-status-check.sh .tad/evidence/fixtures/friction-status-check/blocked-as-pass.md 2>&1)"; code=$?; printf "%s\n" "$out"; test "$code" -eq 1 && printf "%s\n" "$out" | rg -e "WARN" -e "BLOCKED"'` | exit 0 from wrapper; output includes WARN and BLOCKED | (post-impl) |
| AC4 | Missing Friction Status fixture warns and exits 1 | post-impl-verifiable | `bash -c 'out="$(bash .tad/hooks/lib/friction-status-check.sh .tad/evidence/fixtures/friction-status-check/missing-friction-status.md 2>&1)"; code=$?; printf "%s\n" "$out"; test "$code" -eq 1 && printf "%s\n" "$out" | rg -e "WARN" -e "Friction Status"'` | exit 0 from wrapper; output includes WARN and Friction Status | (post-impl) |
| AC5 | Pending-text mismatch fixture warns and exits 1 | post-impl-verifiable | `bash -c 'out="$(bash .tad/hooks/lib/friction-status-check.sh .tad/evidence/fixtures/friction-status-check/pending-text-mismatch.md 2>&1)"; code=$?; printf "%s\n" "$out"; test "$code" -eq 1 && printf "%s\n" "$out" | rg -e "WARN" -e "pending|mismatch|unchecked"'` | exit 0 from wrapper; output includes WARN and mismatch context | (post-impl) |
| AC6 | Fixture harness proves all cases | post-impl-verifiable | `bash .tad/evidence/fixtures/friction-status-check/run-all.sh` | exit 0; all fixture checks pass | (post-impl) |
| AC7 | Real accepted Phase 1 report scans clean | post-impl-verifiable | `bash .tad/hooks/lib/friction-status-check.sh .tad/archive/handoffs/COMPLETION-20260610-friction-protocol-phase1.md` | exit 0; output contains `RESULT: clean` | (post-impl) |
| AC8 | No hook/settings hard-block registration was touched | post-impl-verifiable | `bash -c '! git diff --name-only | rg -e "^\\.claude/settings\\.json$|^\\.codex/hooks\\.json$|^\\.tad/hooks/[^/]+\\.sh$"'` | exit 0; no root hook/settings registration files changed | (post-impl) |
| AC9 | Gate SKILL documents advisory invocation only | post-impl-verifiable | `rg -n -e 'friction-status-check.sh' -e 'advisory' -e 'must not be registered as a hook' .agents/skills/gate/SKILL.md .claude/skills/gate/SKILL.md` | exit 0; both mirrors include advisory-only wording | (post-impl) |

---

## 9.2 Expert Review Status (Alex 必填)

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| N/A | Phase 2 handoff created without sub-agent review in this turn; risk constrained by narrow script + executable fixtures. | §9.1 executable ACs and §8.4 friction preflight | Deferred |

### Experts Selected

None in Alex handoff drafting. Blake should use at least:
1. **code-reviewer** — shell portability, parsing correctness, fixture validity.
2. **backend-architect** — advisory-vs-blocking boundary and integration placement.

### Overall Assessment

Alex assessment: ready for Blake implementation; expert review deferred to Blake Layer 2.

---

## 10. Important Notes

### 10.1 Critical Warnings
- Do not add this script to `.claude/settings.json`, `.codex/hooks.json`, or any root `.tad/hooks/*.sh` dispatch path.
- Do not make the script exit 2 or crash on malformed markdown. Advisory warnings are enough.
- Do not scan the whole archive by default; use explicit args for archived reports.

### 10.2 Known Constraints
- Markdown parsing is heuristic by design.
- The checker should prefer false-positive WARNs over silent false negatives, but avoid historical-report noise in no-arg mode.

### 10.3 Sub-Agent使用建议

Blake应该考虑使用：
- [ ] **code-reviewer** - Required for shell/script review
- [ ] **backend-architect** - Required for advisory boundary review
- [ ] **test-runner** - Useful for fixture harness review

---

## 11. Learning Content（可选）

### 11.1 Decision Rationale: Advisory Script, Not Hook

**选择的方案**: manual checker under `.tad/hooks/lib/`.

| 方案 | 优点 | 缺点 | 为什么没选 |
|------|------|------|-----------|
| Manual advisory script | Low recovery cost; aligns with project principle; easy to fixture-test | Human must remember to run it | ✅ Chosen |
| Blocking hook | Catches more automatically | Violates single-user CLI principle; fail-closed risk | Rejected |
| Gate prose only | No new code | Does not catch report drift before acceptance | Insufficient |

**Human学习点**: single-user development workflows benefit from smoke alarms that are cheap to run and easy to ignore consciously, not hard blockers that fail closed.

---

## 12. Sub-Agent使用记录

Blake完成后填写：

| Sub-Agent | 是否调用 | 调用时机 | 输出摘要 | 证据链接 |
|-----------|---------|---------|---------|---------|
| code-reviewer | ⬚ | After implementation | TBD | TBD |
| backend-architect | ⬚ | After implementation | TBD | TBD |
| test-runner | ⬚ | After fixtures | TBD | TBD |

---

## Message to Blake

Implement Phase 2 as the smallest useful smoke alarm. The script should make it hard for a future completion report to say PASS while hiding `BLOCKED`, missing Friction Status, or stale pending Gate 3 text. Keep it manual, fixture-backed, and explicit about being advisory.

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-06-10
**Version**: 3.1.0


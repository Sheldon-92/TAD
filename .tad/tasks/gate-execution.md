# Quality Gate Execution Task (质量门禁执行任务)

## ⚠️ CRITICAL EXECUTION NOTICE ⚠️

**THIS IS AN EXECUTABLE WORKFLOW - GATE VIOLATIONS BLOCK PROGRESS**

When this task is invoked:

1. **MANDATORY EXECUTION** - Gates must be executed at specified points
2. **EVIDENCE COLLECTION** - All gate results must be documented
3. **VIOLATION BLOCKING** - Skipping gates triggers VIOLATION INDICATOR
4. **PATTERN LEARNING** - Success/failure patterns must be recorded

**VIOLATION INDICATOR:** Attempting to proceed without gate execution is a critical violation.

## Purpose

Execute TAD's 4-gate quality system as defined in the gate skill and the review contract, with enforcement and evidence collection.

## Gate Execution Protocol

The gates are defined once; this task does not restate them. Follow:

- **Gate text and items** (Gate 1 to Gate 4): `.tad/gates/gate-canonical-checklist.md`, and the gate skill `.agents/skills/gate/SKILL.md` (inline copies, Output formats, Knowledge Assessment, Acceptance_By_Real_Use).
- **Who reviews, with which lens, who writes the verdict, rounds and paths**: `.tad/templates/review-contract.md` (section 8: Gate 2 consistency + risk/fit lenses; Gate 3 run + consistency (+ domain when risk_triggers lists security, data or money) reviewers, the run reviewer signs; Gate 4 an Alex acceptor that took no part).
- **Gate 1 content**: the requirement clarification method (`.agents/skills/cora/references/requirement-clarification.md`): the human's confirmed per-block playback plus Alex's "can design from it"; the format is checked by `bash .tad/hooks/lib/gate1-format-check.sh <Epic | handoff | journal>` (advisory). There is no round count, no elicitation evidence file, no 0-9 menu and no self-scored checklist.
- **Gate 3 mechanical parts**: `bash .tad/hooks/lib/gate3-check.sh <handoff> <verdict file>` checks evidence only (every §9.1 AC row in the run verdict's `## AC runs`, every real_path run or `not-run` with a reason). The acceptance commands are re-run by the independent run reviewer in one throwaway project copy; no script executes them.
- **Gate 4**: the acceptor acts as the human (does once for real what he will do with the result, or drives a browser), judges against `## Requirement` + Result contract, and ends its report with `## For the human`. Only what AI cannot do (a real device, a payment, his own account login) goes to the human.

A gate is executed at its point by the party the contract names; a gate that is skipped, or a verdict written by the party that built the work, is a VIOLATION (levels below).


#### Regression Replay（测量层）

样本集：`.tad/regression-samples/`（规矩正本为其 README）。
runner：`bash .tad/scripts/regression-replay.sh score <运行目录>`（只评分；`check` 验结构）。

- 触发类：被审 HANDOFF 的写集命中 `.agents/skills/**`、`.tad/tasks/**`、`.tad/gates/**`、`.tad/templates/**`、模型/路由口径文件任一者时，Gate 3 评审须引用最近一次复跑的 scores.md（其捕获须基于含被审改动的树）并逐案核对 verdict。
- 整轮非 PASS 时 Gate 3 不得 PASS，除非 PM 裁断记录在案。


链收口迁档 HANDOFF/COMPLETION 至 `.tad/archive/` 时，同一步把 session-state 索引块中该链的路径回写为归档路径；state-surface check5 为其机械见证，在下一次发版 step3e 拦截遗漏。

## Evidence Collection Requirements

### For Each Gate Execution:
1. **Record Results**
```yaml
gate: [1|2|3|4]
date: [timestamp]
executor: [agent-a|agent-b]
result: [pass|fail]
issues_found: []
actions_taken: []
evidence_collected: []
patterns_identified: []
```

2. **Save to Evidence System**
- Location: `.tad/evidence/gates/[project]/gate[N]_[timestamp].yaml`
- Update patterns if new success/failure mode found
- Link to project log

3. **Pattern Recognition**
- If gate passes easily → Record success pattern
- If gate fails → Record failure pattern and root cause
- If pattern repeats → Update framework configuration

## Violation Handling Protocol

### Root-Cause-First（先根因，后返工）

On any Gate FAIL, rework does not start from the review's line items. Alex first files a root-cause report using `.tad/templates/root-cause-report.md`（定因 / 定界 / 验证）; Blake implements that report's fix design. Patching review items one by one without a root-cause report is a process violation.

### Level 1: Warning
```
⚠️ GATE WARNING ⚠️
You are about to skip Gate [N]: [Name]
This may result in quality issues.

Continue anyway? (Not recommended)
Type 'OVERRIDE' to skip (will be logged):
```

### Level 2: Blocking
```
⚠️ GATE VIOLATION DETECTED ⚠️
Type: Skipped Mandatory Gate
Gate: [N] - [Name]
Required Evidence: [List]
Action: BLOCKED - Cannot proceed

To continue, you must:
1. Execute the gate properly
2. Collect required evidence
3. Get pass result or handle failures
```

### Level 3: Critical
```
🚨 CRITICAL VIOLATION 🚨
Multiple gates skipped or failed
Pattern indicates systemic quality issues

Escalation Required:
1. Review all gate failures
2. Identify root causes
3. Update process or training
4. Get human approval to proceed
```

## Success Patterns Integration

When gates pass smoothly, record patterns:
- Which sub-agents were used effectively
- What preparation made gate passage easy
- Which documents were most helpful
- What parallel execution patterns worked

## Continuous Improvement

After each gate execution:
1. Update `.tad/evidence/metrics/gate-effectiveness.md`
2. Review patterns in `.tad/evidence/patterns/`
3. Consider framework configuration updates
4. Share learnings with team

## CRITICAL REMINDERS

**❌ NEVER:**
- Skip gates to save time
- Pass gates with known issues
- Ignore evidence collection
- Override without documenting reason

**✅ ALWAYS:**
- Execute gates at specified points
- Collect complete evidence
- Record patterns for learning
- Use violations as learning opportunities
- Treat gates as quality investment, not overhead

[[LLM: This task enforces TAD's 4-gate quality system using BMAD's mandatory interaction patterns. Gates are not optional - they are critical quality control points that ensure consistent, high-quality delivery.]]
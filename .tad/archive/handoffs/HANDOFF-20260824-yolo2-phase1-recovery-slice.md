---
task_type: mixed
e2e_required: yes
research_required: no
git_tracked_dirs:
  - .tad/scripts
  - .tad/guides
skip_knowledge_assessment: no
gate4_delta:
  - field: "AC2/AC10 final-head verification"
    alex_said: "The full suite and required-evidence checker would pass after the completion artifacts existed."
    actual: "At final HEAD 78094228, required-evidence exits 1 because six TAD lifecycle files committed by the completion flow are absent from its exact allowlist; therefore the full suite also exits 1."
    caught_by: "Alex Gate 4 live recompute on 2026-08-25"
  - field: "Gate 3 Layer 2 closure"
    alex_said: "The required post-implementation expert evidence would establish no open P0/P1 blockers."
    actual: "code-reviewer.md, architecture-reviewer.md, and security-reviewer.md still end in FAIL; commit d7813c6b appears to address their findings, but no independent incremental PASS verdict carriers exist."
    caught_by: "Alex Gate 4 evidence-content review on 2026-08-25"
  - field: "§2.2 reference harness"
    alex_said: "Phase 1 would use fresh Claude Code contexts on the selected Claude Code reference harness."
    actual: "The dogfood used OpenCode Task sub-agents with prompt-level isolation rather than process-level fresh Claude Code contexts."
    caught_by: "Gate 3 completion deviation disclosure, verified by Alex from raw run evidence"
  - field: "AC10 post-archive lifecycle"
    alex_said: "Allowlisting the six completion-flow lifecycle paths would make final-head acceptance stable."
    actual: "AC10 passes while Handoff/COMPLETION are active but fails immediately after the required archive transition because the checker hard-codes the active COMPLETION path and does not model the archived pair."
    caught_by: "Alex post-archive consistency rerun on 2026-08-25"
  - field: "AC10 committed archive diff"
    alex_said: "The round-2 active/archive state machine plus simulated archive run would make the committed archive stable."
    actual: "The real archive layout passes before commit, but after the archive/status commit required-evidence fails because ALLOW_EXACT still asserts that the active Handoff must appear in base..HEAD. The simulation changed file existence only and did not model the committed diff."
    caught_by: "Alex post-commit real-archive full-suite rerun at 54bc9ab9 on 2026-08-25"
---

# Handoff: YOLO 2.0 Phase 1 — 真实恢复纵向切片

**From:** Alex (Solution Lead)  
**To:** Blake (Execution Master)  
**Date:** 2026-08-24  
**Task ID:** TASK-20260824-YOLO2-P1  
**Handoff Version:** 1.0.3 — Gate 2 PASS; Gate 4 committed-diff amendment
**Epic:** `EPIC-20260824-yolo2-verified-orchestration.md` (Phase 1/4)  
**Decision:** `.tad/decisions/DR-20260824-yolo2-vertical-slice-first.md`  
**Supersedes:** archived `SUPERSEDED-HANDOFF-20260824-yolo2-phase1-contract-baseline.md`

---

## Gate 4 Corrective Amendment — 2026-08-25

Gate 4 independently re-ran the final-head suite and found that AC10's original
scope fence omitted TAD lifecycle artifacts which the completion flow itself is
required to persist. This amendment does not expand product/runtime scope and does
not invalidate the frozen dogfood revision: the completed runs remain evaluated
against their original `handoff_revision`. It only makes final-head acceptance
include the exact lifecycle paths listed in §7.2.

Blake must update the checker to this exact amended allowlist, retain red controls
for unrelated workflow/runtime paths, run the complete suite after all completion
artifacts exist, and obtain independent incremental PASS verdicts for the prior
code/architecture/security FAIL reports before resubmitting Gate 3.

### Gate 4 lifecycle amendment — round 2

The checker must recognize the TAD task lifecycle, not one directory state. Exactly
one matching Handoff/COMPLETION pair is valid: either both under `.tad/active/handoffs/`
before acceptance archive, or both under `.tad/archive/handoffs/` afterward. Missing
both, a split pair, or duplicate active+archive copies must fail. Both states must
retain the same product/runtime scope fence and evidence requirements.

### Gate 4 lifecycle amendment — round 3

The lifecycle state and the frozen-base-to-HEAD diff must agree. Stable product and
status paths may retain unconditional must-appear assertions, but the four lifecycle
paths must not. In the active state, the committed diff must contain the active
Handoff and active COMPLETION and need not contain their archive paths. In the
archived state, it must contain the archived Handoff and archived COMPLETION and
must not require the active pair to remain in the net diff. The resolved lifecycle
pair is still required to exist and be non-empty.

The archive proof must exercise both dimensions: filesystem existence and the actual
`git diff --name-only <frozen-base>..HEAD`. An existence-only environment simulation
is insufficient. Use a disposable worktree/commit or an equivalently faithful pure
fixture, then obtain one narrow independent review. Alex will still perform the
decisive full-suite rerun after the real archive commit. Runtime, dogfood, prior
reviews, and the Phase-1-only human degradation approval remain unchanged.

## 🔴 Gate 2: Design Completeness

**执行时间:** 2026-08-24

| 检查项 | 状态 | 说明 |
|---|---|---|
| Expert review complete | ✅ | 2 independent reviewers; 2 rounds maximum observed |
| All P0 resolved | ✅ | round 2 residual P0 = 0 for both reviewers |
| Architecture Complete | ✅ | authority, worktree identity, recovery and stop paths defined |
| Components Specified | ✅ | CLI, tests, guide and evidence envelopes specified |
| Functions Verified | ✅ | existing workflow/hooks grounded; new functions explicitly marked CREATE |
| Data Flow Mapped | ✅ | goal/journal/receipt → recovery → assertion → reviewer → existing Gate |

**Gate 2 结果:** ✅ PASS

**Alex 确认:** 两个 round-1 P0 已由 round-2 增量复核关闭；round-2 新 P1 已整合，不存在未解决 P0。本 handoff 可交给 Blake 实现。

## 📋 Handoff Checklist

- [ ] 阅读全部章节与列出的 project knowledge
- [ ] 用自己的话复述：目标、非目标、权威顺序、恢复失败时的行为
- [ ] 不修改现有 YOLO workflow、Gate、PreCompact hook 或默认开关
- [ ] 先完成确定性 CLI 测试，再做真实 Claude Code dogfood
- [ ] 产出 Required Evidence Manifest 的全部证据

## 1. Task Overview

### 1.1 What We're Building

在现有 Claude Code `yolo-epic` 编排器外增加一个显式 opt-in、零第三方依赖的恢复记录器。它为单次真实 YOLO run 冻结目标，记录少量恢复相关事实，生成 bounded recovery packet，并要求 fresh context 在继续前通过 semantic recovery assertion。

Phase 1 只证明一件事：一个真实任务完成已验证 slice 后被 compact/kill，新会话不靠旧聊天仍能准确理解并继续。它不是通用工作流引擎。

### 1.2 Why We're Building It

**业务价值:** 长任务不能因为上下文压缩或进程退出而忘记目标、重做已完成工作或把未验证进度当完成。  
**用户受益:** 用户运行一条 `status` 就能看懂目标、真实进度、阻塞和下一步；恢复失败时系统诚实停下，而不是猜。  
**成功的样子:** 3 个真实中断点都能由 fresh Claude Code context 只凭 run path 正确重入，随后继续完成同一个真实任务并通过既有 Gate。

### 1.3 Intent Statement

**真正要解决的问题:** 当 YOLO 长任务经历 compact、kill 或新会话时，恢复后的 agent 必须知道“为何做、做到哪、什么是真的、下一步为何合法”，从而阻止质量随任务长度下降。

**不是要做的:**

- ❌ 不做 Claude/Codex/OpenCode 三平台统一 adapter；Phase 3 再做。
- ❌ 不做通用 event-sourcing kernel、hash chain、fencing 或 JavaScript sandbox。
- ❌ 不改变 Y1–Y8、Alex/Blake 分工、reviewer 或 Gate authority。
- ❌ 不把 `recovery.md`、session-state 或 compact 摘要提升为进度权威。
- ❌ 不在本 Phase 宣称“总体质量已提升 15pp”；这里只证明真实恢复链路成立。

## 📚 Project Knowledge（Blake 必读）

**任务关键词:** YOLO、compact、fresh context、goal、verified progress、recovery、checkpoint、side effect、Gate。

**已读取:**

| 文件 | 用途 |
|---|---|
| `.tad/project-knowledge/principles.md` | Measure Before Optimizing；single-user CLI 不堆机械规则；YOLO validation theater |
| `.tad/project-knowledge/patterns/memory-and-learning.md` | working/episodic/semantic/procedural 分层；持久状态不依赖聊天 |
| `.tad/project-knowledge/patterns/handoff-design.md` | 最小 producer+consumer；平台能力需实测；协议状态转换显式 |
| `.tad/project-knowledge/patterns/ac-verification.md` | 判据必须有红态；真实结果优先于结构绿灯 |

**⚠️ Blake 必须注意的历史教训:**

1. **YOLO Epic Execution: Cross-Model Audit Findings** (`principles.md`)：流程 artifact 全绿不代表结果质量；必须跑真实行为和独立复核。
2. **Minimal Viable Cross-Cutting Enhancement** (`handoff-design.md`)：先覆盖 producer + consumer 两个关键点；真实故障出现后再扩张。
3. **Platform Capability Assumptions Decay Fast** (`handoff-design.md`)：本 Phase 的 Claude 选择只对本次本机 probe 有效，不外推其他 harness。
4. **Verification Strength Is Bounded by Deliverable Determinacy** (`ac-verification.md`)：若验证器缺陷多于交付物缺陷，缩范围，不继续加规则。
5. **Run X 不是判据，除非 X 有红态** (`ac-verification.md`)：每条 CLI 检查必须用 exit code + machine-readable final status 表达失败。

Stale checker 的相关输出仅为 advisory；未发现会阻止本设计的 stale item。

## 2. Background Context

### 2.1 Previous Work

- `.claude/workflows/yolo-epic.workflow.js` 已负责 Y3 design、Y4 review、Y5 worktree implementation、Y6 implementation review 和 budget report。
- `.agents/skills/alex/references/yolo-execution-protocol.md` 已规定“磁盘为真相、每步先持久化、Conductor 亲判 Gate”。
- `.tad/hooks/precompact-session-snapshot.sh` 是 fail-open Layer 0，只记录机械导航事实，明确不能写 agent state。
- 旧 Phase 1 handoff 因试图先证明任意 JS verifier 安全而在 5 个 review cycle 后撤销。

### 2.2 Reference Harness Decision

2026-08-24 本机 probe：Claude Code `2.1.239`、Codex `0.149.1`、OpenCode `1.18.21` 均已安装。选择 Claude Code 的唯一理由是当前真实 YOLO workflow 只存在于 `.claude/workflows/yolo-epic.workflow.js`；这是一项 Phase-1 reference 选择，不是跨平台能力结论。

### 2.3 Dependencies

- Node.js built-ins only；运行时最低版本以实现中实际使用 API 推导并写入 guide，不得凭空声称 Node 14。
- 不新增 npm 包、不改 lockfile。
- 依赖现有批准 Handoff、证据文件、reviewer 与 Gate；CLI 只验证证据路径存在，不替代其语义判断。

## 3. Requirements

### 3.1 Functional Requirements

- **FR1 Init:** 从显式参数和已批准 handoff 创建唯一 run directory，原子写 `goal.json`；已存在则 fail，不覆盖。
- **FR2 Journal:** `journal.jsonl` 只允许 `initialized`、`checkpointed`、`verified`、`action_started`、`action_reconciled`、`stopped` 六类事件。
- **FR3 Verified-only:** 只有 `verify` 且引用 Conductor 在既有 reviewer/Gate PASS 后写出的 `verification-receipt.json` 才能推进 `last_verified`；receipt 必须绑定 run、slice、handoff revision、真实 worktree、当时 HEAD 与 Gate/review evidence。任意普通文件、checkpoint 和 completion prose 都不能。
- **FR4 Resume:** 从 `goal.json + journal.jsonl` 派生 checkpoint 和 recovery packet；不消费聊天历史、compact summary 或 recovery.md 作为权威。
- **FR5 Conflict:** JSON 损坏、journal/checkpoint 冲突、缺 evidence、handoff revision drift 或未决副作用必须返回 `honest_partial` 且 non-zero。
- **FR6 Side effects:** `action_started` 后只能落到 `confirmed | outcome_unknown | reconciled`；`outcome_unknown` 禁止同 action ID 重试。
- **FR7 Status:** 一屏显示 goal、handoff revision、last verified、unverified、blocker、pending action、legal next action、owner 和精确 resume command。
- **FR8 Stop:** 显式记录 stop reason 并输出可恢复的 `honest_partial`；不得把未验证工作升级为完成。
- **FR9 Semantic re-entry:** fresh agent 只得到 run path，先写 assertion；独立 reviewer 对预冻结 oracle 打分，PASS 前不继续。
- **FR10 Real dogfood:** 同一真实 guide maintenance task 运行 uninterrupted control 与 interrupted treatment；两者从同一 frozen commit 和输入开始，位于隔离 worktree。

### 3.2 Non-Functional Requirements

- `goal.json` 初始化后不可变；所有命令显式接收 run path，不设置全局 active-run 指针。
- `init` 冻结 `realpath(git rev-parse --show-toplevel)` 与初始 HEAD，并证明初始 HEAD 等于 declared base commit。此后 root 必须始终等于 frozen worktree；base HEAD 只在 init 校验。`verify` 要求调用时 HEAD 等于 `receipt.verified_head`；每个后续 journal event 记录 observed HEAD。`resume` 报告 latest observed HEAD，但不要求它仍等于 base 或旧 receipt HEAD，除非正在验证的 evidence 明确绑定该 HEAD。
- `checkpoint.json` 与 `recovery.md` 采用同目录临时文件 + rename；失败不得留下半写权威状态。
- `recovery.md` 目标不超过约 2,500 tokens；超限时报告构成并停止，不删 hard anchor 取巧。
- 路径必须解析并限制在当前 repo 的 `.tad/evidence/yolo/` 内；不得接受 `..` 逃逸。
- stdout 供人读，末行固定 JSON status；PASS exit 0，contract failure exit 1，usage/input error exit 2。
- 所有循环有界；读取 journal 对 Phase-1 dogfood 规模足够，无需提前优化。

## 4. Technical Design

### 4.1 Architecture Overview

```text
approved handoff + frozen oracle
            │ init
            ▼
  goal.json (immutable) ─────────────┐
  journal.jsonl (fact authority) ────┼─> resume reducer
  evidence pointers ────────────────┘        │
                                              ├─> checkpoint.json (derived)
                                              └─> recovery.md (human/agent packet)
fresh Claude context → assertion → independent reviewer → PASS → existing YOLO/Gate
```

权威顺序：

1. 已批准 handoff revision + immutable `goal.json`；
2. 可完整解析的 `journal.jsonl` 与其 evidence pointers；
3. 可重建的 `checkpoint.json`；
4. `recovery.md`、session-state、PreCompact snapshot 仅导航/展示。

低层与高层冲突时不“选最新文件”，而是停止并报告冲突。

### 4.2 Components

#### `.tad/scripts/yolo-recovery.mjs` (CREATE)

单文件 CLI，使用 Node built-ins。内部函数边界（名称可微调，职责不可合并丢失）：

- `resolveRunDir(input, repoRoot)`：路径规范化与 scope guard。
- `readGoal(runDir)`：解析 immutable goal。
- `readJournal(runDir)`：逐行解析且 fail on malformed/unknown event。
- `reduceRun(goal, events)`：纯函数；推导 verified、unverified、blockers、actions、next action。
- `validateVerificationReceipt(ref, state)`：receipt 是 repo-scoped regular JSON，且 `verdict: PASS`；精确绑定当前 `run_id`、`slice`、handoff revision、real worktree、verified HEAD，并列出至少一个 Gate verdict 与一个独立 review evidence；所有引用必须存在。
- `readGitIdentity()`：返回 real worktree root + current HEAD；每个命令与 frozen identity 对账。
- `writeAtomic(path, content)`：同目录 temp + rename。
- `renderStatus(state)`：人类一屏摘要。
- `renderRecovery(state)`：bounded recovery packet。
- `main(argv)`：命令 dispatch 与固定 exit/status contract。

CLI 命令：

```text
init --run <dir> --handoff <path> --goal-file <frozen-json>
status --run <dir>
checkpoint --run <dir> --slice <id> --reason <before-compact|before-stop|candidate> --next <text>
verify --run <dir> --slice <id> --receipt <verification-receipt.json>
action-start --run <dir> --action <id> --description <text> --target <repo-path> --pre-sha256 <sha> --intended-post-sha256 <sha>
reconcile --run <dir> --action <id> --outcome <confirmed|outcome_unknown|reconciled> [--evidence <path>] [--observed-sha256 <sha>]
resume --run <dir>
stop --run <dir> --reason <text>
```

`checkpoint` 的 reason 不含 `verified`；verified 是独立、高权限语义事件，避免调用者用一个 flag 自报完成。

`verification-receipt.json` 不是新 Gate 或通用 verifier。它只是 Conductor 在现有 Gate/reviewer 已经 PASS 之后写出的绑定收据：

```json
{
  "format": "yolo-recovery-verification-v1",
  "verdict": "PASS",
  "run_id": "...",
  "slice": "...",
  "handoff_revision": "...",
  "worktree_realpath": "...",
  "verified_head": "...",
  "gate_evidence": [{"path": "...", "sha256": "...", "verdict": "PASS"}],
  "review_evidence": [{"path": "...", "sha256": "...", "independent": true, "verdict": "PASS"}],
  "executor_id": "...",
  "written_by": "conductor",
  "written_by_id": "..."
}
```

CLI 不自行判断测试或 review 是否语义正确；它验证 receipt 的绑定、PASS 形状、evidence SHA-256 与引用存在，并要求 `written_by_id != executor_id`。receipt 作者不得是执行该 slice 的 executor。Phase-1 threat model 不防同一账号的恶意本机进程伪造身份，但正常 executor 流程无合法命令生成该 receipt；Conductor 直接按 guide 写入。

#### `.tad/scripts/yolo-recovery.test.mjs` (CREATE)

Node 自包含测试 runner，使用临时 git worktree 或临时 repo fixture；每个测试打印 PASS/FAIL，任一失败 exit 1。覆盖 happy path、completion-prose negative、stale recovery、malformed journal、missing evidence、unknown event、path escape、duplicate/unknown side effect、atomic write fault。

#### `.tad/guides/yolo-recovery.md` (CREATE)

只写 Phase-1 reference flow：初始化、何时 checkpoint、如何 compact/kill、新会话只传 run path、assertion 模板、reviewer rubric、继续/停止、恢复与回滚。清楚标记 Claude-only reference、opt-in、实验性。

### 4.3 Data Models

最小 `goal.json`：

```json
{
  "format": "yolo-recovery-phase1-v1",
  "run_id": "...",
  "goal_id": "...",
  "handoff_path": "...",
  "handoff_revision": "...",
  "base_commit": "...",
  "worktree_realpath": "...",
  "goal": "...",
  "success": ["..."],
  "non_goals": ["..."],
  "forbidden_scope": ["..."],
  "oracle_path": "...",
  "created_at": "..."
}
```

最小 journal event envelope：

```json
{"seq":1,"type":"initialized","at":"...","payload":{}}
```

`seq` 必须连续且唯一。Phase 1 只有单 writer，不引入锁；并发写入检测后 fail-closed，作为未来抽象 trigger。kill 留下的半条 JSONL 必须视为 corruption → non-zero `honest_partial`，不得截断修复后继续。

`recovery-scores.json` 只是索引，不是自证结果。Gate-consumed checker 必须读取索引引用的原始 assertion/oracle/reviewer/continuation/Gate/receipt 文件，重算每个 SHA-256，验证 verdict anchors，并拒绝只有 summary JSON 而没有原始证据的情况。最小形状固定为：

```json
{
  "runs": [
    {
      "id": "interruption-a",
      "interruption_stage": "after-verified-slice",
      "run_dir": ".../interruption-a",
      "base_commit": "...",
      "input_sha256": "...",
      "worktree_realpath": "...",
      "assertion": {"path": "...", "sha256": "..."},
      "oracle": {"path": "...", "sha256": "..."},
      "continuation": {"path": "...", "sha256": "..."},
      "gate": {"path": "...", "sha256": "...", "verdict": "PASS"},
      "receipt": {"path": "...", "sha256": "..."},
      "hard_total": 8,
      "hard_correct": 8,
      "soft_score": 0.9,
      "wrong_or_unauthorized_next_action": 0,
      "repeated_verified_slice": 0,
      "continued": true,
      "hidden_acceptance_passed": true,
      "gate_passed": true,
      "reviewer": {"independent": true, "evidence": "..."}
    }
  ]
}
```

必须恰有 `interruption-a/b/c` 三个 treatment run，stage 精确对应 `after-verified-slice / after-action-started / before-recovery-packet`，且 `run_dir`/worktree 三者唯一。每条原始 evidence 必须存在、hash 匹配并链接到对应 interruption report。

同文件必须含一个 `control` object：`base_commit` 与 `input_sha256` 必须和三个 treatment 完全相同，另含唯一 worktree、control report hash、hidden-acceptance hash 和 Gate PASS hash。control 不混入 recovery rate 分母，但缺失或基线不一致会使 dogfood gate 失败。

每个 treatment 必须另有 machine-readable `run-evidence.json`，control 必须有 `control-evidence.json`。Markdown 可供人阅读，但不能是 checker 唯一权威。treatment envelope 最小字段固定为：

```json
{
  "format": "yolo-recovery-dogfood-evidence-v1",
  "run_id": "interruption-a",
  "interruption_stage": "after-verified-slice",
  "base_commit": "...",
  "input_sha256": "...",
  "worktree_realpath": "...",
  "fresh_session": {"session_id": "...", "prior_transcript_provided": false, "prompt_path": "...", "prompt_sha256": "..."},
  "assertion": {"path": "...", "sha256": "...", "author_id": "fresh-agent"},
  "oracle": {"path": "...", "sha256": "...", "frozen_before_run": true},
  "review": {"path": "...", "sha256": "...", "author_id": "...", "independent": true, "assertion_sha256": "...", "oracle_sha256": "...", "hard_total": 8, "hard_correct": 8, "soft_score": 0.9, "verdict": "PASS"},
  "continuation": {"path": "...", "sha256": "...", "repeated_verified_slice": 0},
  "gate": {"path": "...", "sha256": "...", "verdict": "PASS"},
  "receipt": {"path": "...", "sha256": "..."}
}
```

Checker 必须解析字段并交叉校验 run/stage/base/input/worktree、assertion↔oracle↔review hashes、author separation、verdict 与 receipt；禁止用 Markdown grep 代替结构化绑定。control envelope 使用相同 base/input/worktree/Gate 结构，但没有 recovery score 字段。

### 4.4 State Transitions

```text
ABSENT --init--> ACTIVE
ACTIVE --checkpoint--> ACTIVE(candidate only)
ACTIVE --verify(bound PASS receipt)--> ACTIVE(last_verified advances)
ACTIVE --action-start--> ACTION_PENDING
ACTION_PENDING --confirmed/reconciled--> ACTIVE
ACTION_PENDING --outcome_unknown--> HONEST_PARTIAL
ACTIVE --resume(valid)--> RECOVERY_READY
ANY --conflict/corruption/drift--> HONEST_PARTIAL
ACTIVE --stop--> HONEST_PARTIAL
```

`resume` 只生成恢复包，不执行下一步。semantic assertion 的 reviewer PASS 才是恢复后继续现有 YOLO 的前置条件。

## 5. 强制问题回答（Evidence Required）

### MQ1 历史代码搜索

已通过 codebase-memory graph 优先定位 YOLO 模块；graph 对 `.claude/workflows` 覆盖不足后才用 `rg` 定位真实 workflow。结论：复用现有 `yolo-epic`，不另造 orchestrator。

### MQ2 函数存在性

| 依赖 | 位置 | 验证 |
|---|---|---|
| `yolo-epic` workflow | `.claude/workflows/yolo-epic.workflow.js` | ✅ 存在；完整读取 |
| YOLO execution protocol | `.agents/skills/alex/references/yolo-execution-protocol.md` | ✅ 存在；完整读取 |
| PreCompact snapshot | `.tad/hooks/precompact-session-snapshot.sh` | ✅ 存在；仅 Layer 0 诊断 |
| recovery CLI functions | `.tad/scripts/yolo-recovery.mjs` | 🆕 CREATE；不假装已存在 |

### MQ3 Data Flow

上游批准 handoff/goal → CLI durable facts → recovery packet → fresh agent assertion → independent reviewer → existing YOLO/Gate。没有 UI/backend 字段映射；`status` 是唯一人类界面。

### MQ4 Visual Hierarchy

CLI status 用清晰标签区分 `VERIFIED`、`UNVERIFIED`、`BLOCKED`、`OUTCOME_UNKNOWN`、`LEGAL NEXT ACTION`；不得只靠颜色。

### MQ5 State Sync

journal 是事实权威；checkpoint/recovery 每次由 reducer 重建。若派生文件与重建结果不同，resume non-zero + `honest_partial`，不自动覆盖后继续。

## 6. Implementation Steps

### P1. Freeze contract and build reducer/CLI

1. 先把本节 data/exit/authority contract 转成测试案例。
2. 实现 path guard、Git/worktree identity、goal/journal/receipt parsing、pure reducer、atomic derived writes。
3. 实现命令 dispatch；每个失败路径具有 machine-readable red state。
4. 不读取或修改 `.tad/active/session-state.md`、PreCompact snapshot 或 old chat。

**Verify:** 单元/fixture tests 全绿；负控都能可靠变红。

### P2. Write reference-harness guide

1. 写 Claude Code opt-in 操作流与 fresh-session prompt。
2. 写 semantic assertion 固定模板：goal、success、non-goal、forbidden、revision、verified、unverified、blocker、decision/rationale、rejected option、legal next action + why。
3. 写 reviewer rubric：hard anchors 100%；soft rationale ≥90%；任何影响 next-action legality 的遗漏按 hard failure。
4. 写 stop/rollback 和“Phase 1 不证明什么”；明确 `written_by_id != executor_id` 是流程完整性边界，不是密码学 provenance，也不防同账号恶意本机进程。Gate 3 必须人工对照 receipt 与原始 Gate/review evidence。

### P3. Deterministic adversarial fixtures

至少覆盖：普通文件/自写 receipt/completion prose 不能推进 verified、valid Conductor receipt 可推进、错误 run/slice/revision/worktree/HEAD/hash/author-separation receipt 被拒、删/改 recovery 不改变权威、corrupt journal、partial final JSONL line、stale checkpoint、missing evidence、handoff revision drift、path escape、duplicate action、outcome_unknown 后重试；以及只伪造 `recovery-scores.json`、重复 treatment、缺 control、缺原始文件、hash 不符时 dogfood checker 必须变红。

### P4. Real interrupted dogfood

1. 冻结同一 base commit、goal/oracle、guide maintenance input、model/预算/cache policy。
2. 创建 control 与三个 treatment 隔离 worktree；每个 run 的 `worktree_realpath` 唯一，init 时 HEAD 必须等于 frozen base commit。
3. treatment 在三个独立 run 中分别于 `(a) verified slice 后`、`(b) action_started 后`、`(c) recovery packet 生成前` 强制 compact 或 kill。
4. `(b)` 的真实本地 action 固定为：对 treatment worktree 中 guide 的一个预冻结段落执行一次受控 patch；`action-start` 的结构化参数记录目标 realpath、pre SHA-256、intended post-content SHA-256，缺任一参数即 usage error。中断发生在 patch tool 返回之后、ledger 对账之前。resume 必须读取真实文件/hash，分类为 `confirmed`（精确 post hash）、`outcome_unknown`（既非 pre 也非 post）或经显式 evidence `reconciled`；unknown 禁止再次 patch。
5. 每次新 Claude session 不获得旧聊天；仅获得 run path 和固定 assertion instruction。
6. 独立 reviewer 读取 oracle 与 assertion，写 hard/soft score 和 verdict。
7. Conductor 在现有 review/Gate PASS 后写 bound verification receipt；CLI 验证 receipt 后才推进 verified。
8. PASS 后继续 guide task；运行隐藏验收和现有 Gate。失败则记录 honest_partial，不补喂旧聊天挽救。

### P5. Evidence and completion

按 manifest 写证据；completion 明确报告成功、失败、未执行项。Phase 1 只在 3/3 recovery、真实继续、Gate 全通过时完成。

## 6.1 Micro-Tasks

| # | Deliverable | Verify before next |
|---|---|---|
| 1 | CLI contract tests | red/green controls behave |
| 2 | reducer + atomic state | fixtures pass |
| 3 | commands/status/recovery | CLI e2e passes |
| 4 | guide + frozen oracle | rubric review |
| 5 | 3 interrupted runs + control | real evidence exists |
| 6 | completion package | Gate 3 evidence complete |

## 6.2 Required Evidence Manifest

```yaml
required_evidence:
  expert_reviews:
    - .tad/evidence/reviews/blake/yolo2-phase1/code-reviewer.md
    - .tad/evidence/reviews/blake/yolo2-phase1/architecture-reviewer.md
    - .tad/evidence/reviews/blake/yolo2-phase1/security-reviewer.md
    - .tad/evidence/reviews/blake/yolo2-phase1/performance-reviewer.md
  gate_verdicts:
    - .tad/evidence/yolo/yolo2-verified-orchestration/phase1/gate3-verdict.md
  completion:
    - .tad/active/handoffs/COMPLETION-20260824-yolo2-phase1-recovery-slice.md
  blake_reviews:
    - .tad/evidence/reviews/blake/yolo2-phase1/spec-compliance.md
  perf_evidence:
    - .tad/evidence/yolo/yolo2-verified-orchestration/phase1/capsule-budget.md
  fixture_results:
    - .tad/evidence/yolo/yolo2-verified-orchestration/phase1/deterministic-fixtures.txt
  dogfood:
    - .tad/evidence/yolo/yolo2-verified-orchestration/phase1/dogfood/control.md
    - .tad/evidence/yolo/yolo2-verified-orchestration/phase1/dogfood/interruption-a.md
    - .tad/evidence/yolo/yolo2-verified-orchestration/phase1/dogfood/interruption-b.md
    - .tad/evidence/yolo/yolo2-verified-orchestration/phase1/dogfood/interruption-c.md
    - .tad/evidence/yolo/yolo2-verified-orchestration/phase1/dogfood/recovery-scores.json
  knowledge_updates:
    - .tad/evidence/yolo/yolo2-verified-orchestration/phase1/knowledge-assessment.md
```

## 6.3 AC Dry-Run Log

**2026-08-24 Alex step1d:**

- AC1 pre-implementation command ran exactly as written: stdout empty, exit 0.
- AC2–AC5/AC9/AC10 CLI invocations passed shell syntax validation; deferred because files are new.
- AC6–AC8 Node assertions passed `node --check`; deferred because score artifact is new.
- Advisory `verify-ac-commands.sh`: `0 warnings, 0 info`.
- No future artifact was mocked.

## 7. File Structure

### 7.1 Files to Create

- `.tad/scripts/yolo-recovery.mjs`
- `.tad/scripts/yolo-recovery.test.mjs`
- `.tad/guides/yolo-recovery.md`
- evidence paths in §6.2
- completion report in §6.2

### 7.2 Files to Modify

- None in product/runtime flow. In particular, do not modify `.claude/workflows/yolo-epic.workflow.js`, YOLO protocol, Gate, hooks, config, installer or lockfiles.
- The final-head scope checker must additionally allow only these TAD lifecycle paths, all of which are produced or updated by design/completion/knowledge capture for this same task:
  - `.tad/active/epics/EPIC-20260824-yolo2-verified-orchestration.md`
  - `.tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md`
  - `.tad/archive/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md` (post-accept alternative; exactly one active/archive pair)
  - `.tad/archive/handoffs/COMPLETION-20260824-yolo2-phase1-recovery-slice.md` (post-accept alternative; exactly one active/archive pair)
  - `.tad/decisions/DR-20260824-yolo2-orchestration-kernel.md`
  - `.tad/decisions/DR-20260824-yolo2-vertical-slice-first.md`
  - `.tad/project-knowledge/patterns/memory-and-learning.md`
  - `NEXT.md`

### 7.3 Grounded Against

- `.claude/workflows/yolo-epic.workflow.js` — fully read 2026-08-24
- `.agents/skills/alex/references/yolo-execution-protocol.md` — fully read 2026-08-24
- `.tad/hooks/precompact-session-snapshot.sh` — fully read 2026-08-24
- `.tad/hooks/startup-health.sh` — fully read 2026-08-24
- `.tad/scripts/yolo-recovery.mjs` — new
- `.tad/scripts/yolo-recovery.test.mjs` — new
- `.tad/guides/yolo-recovery.md` — new
- Graph impact: graph indexed this repo; workflow internals were not represented, so direct read was used for that target.

## 8. Testing Requirements

### 8.1 Deterministic

Run `node .tad/scripts/yolo-recovery.test.mjs`; result must include every named case and end `RESULT=PASS`, exit 0. Injected negative cases must end `RESULT=FAIL` or command-specific honest_partial with non-zero exit.

### 8.2 Integration

Use a temporary run directory under `.tad/evidence/yolo/`, execute the complete command lifecycle, rebuild checkpoint twice, and prove byte-stable semantic content apart from explicitly volatile timestamps.

### 8.3 Real E2E

Three treatment runs plus one control as P4. Fresh-session evidence must record Claude version, model/route if available, base commit, worktree, input hash, budget and exact prompt. No old transcript or compact summary may be injected.

### 8.4 Friction Preflight

- `gh` dependency scan is beyond L1 freshness buffer and has a security signal; this Phase does not call GitHub or release tooling, so record as unrelated environment risk, not blocker.
- GitHub registry scan is stale but no external architecture research is needed; local real capability probe owns the Phase-1 choice.
- Working tree is dirty; dogfood must use isolated worktrees and explicit base SHA.

### 8.5 Feedback Collection

`feedback_required: false` — CLI/guide artifact, no frontend.

## 9. Acceptance Criteria

### 9.1 Spec Compliance Checklist

| AC | Description | Verification Method | Expected Evidence | Verified Output |
|---|---|---|---|---|
| AC1 | Default YOLO/runtime unchanged | `git diff --name-only -- .claude/workflows .tad/hooks .agents/skills/alex/references/yolo-execution-protocol.md .tad/config.yaml` | empty stdout | pre-impl: empty stdout, exit 0 |
| AC2 | CLI deterministic suite has real red/green states | `node .tad/scripts/yolo-recovery.test.mjs` | named cases + final `RESULT=PASS`, exit 0; suite itself asserts negative commands exited non-zero | post-impl |
| AC3 | goal immutable; only bound Conductor PASS receipt can verify | `node .tad/scripts/yolo-recovery.test.mjs --case verified-authority` | rejects plain/self-authored/mismatched receipt; accepts correctly bound receipt; `RESULT=PASS` | post-impl |
| AC4 | authority/conflict fail-closed | `node .tad/scripts/yolo-recovery.test.mjs --case authority-conflicts` | `CASE=authority-conflicts RESULT=PASS`, exit 0 | post-impl |
| AC5 | side effects never blind retry | `node .tad/scripts/yolo-recovery.test.mjs --case side-effect-reconcile` | `CASE=side-effect-reconcile RESULT=PASS`, exit 0 | post-impl |
| AC6 | Raw dogfood evidence proves 3 distinct fresh-context hard-anchor runs | `node .tad/scripts/yolo-recovery.test.mjs --case dogfood-evidence` | exact IDs/stages, unique runs/worktrees, control parity, raw files + hashes + verdict anchors verified; hard totals >0 and all correct | post-impl |
| AC7 | Raw evidence proves soft semantic recovery ≥90% | `node .tad/scripts/yolo-recovery.test.mjs --case dogfood-evidence` | each treatment ≥0.90 with independent reviewer whose report hash and assertion/oracle binding verify | post-impl |
| AC8 | Raw evidence proves real continuation and no repeated verified work | `node .tad/scripts/yolo-recovery.test.mjs --case dogfood-evidence` | control present/same base+input; each treatment continuation, hidden acceptance, Gate PASS, receipt hashes valid; repeat/unauthorized = 0 | post-impl |
| AC9 | human-readable bounded status/recovery | `node .tad/scripts/yolo-recovery.test.mjs --case status-capsule` | all required labels present; token estimate ≤2500 or explicit blocked result preserving hard anchors | post-impl |
| AC10 | evidence and scope complete across acceptance lifecycle | `node .tad/scripts/yolo-recovery.test.mjs --case required-evidence` | checker reads frozen base SHA, requires all §6.2 evidence non-empty, accepts exactly one matching active-or-archive Handoff/COMPLETION pair, rejects missing/split/duplicate pairs, and compares `git diff --name-only <base>..HEAD` to the exact §7 product + lifecycle allowlist; must-appear assertions follow the resolved pair (active pair in active state, archived pair in archived state), and the archive proof models the real committed diff; unrelated workflow/runtime paths remain red controls | Gate 4 lifecycle amendment round 3: pending Blake committed-diff rerun |

### 9.2 Expert Review Status

| Reviewer | Round | Verdict | P0 | P1 | Evidence |
|---|---:|---|---:|---:|---|
| code/product-quality reviewer | design input | PASS with recommendations | 0 | incorporated | collaboration review 2026-08-24 |
| backend/agent architecture reviewer | design input | PASS with recommendations | 0 | incorporated | collaboration review 2026-08-24 |
| code/product-quality reviewer | Gate 2 round 1 | FAIL | 2 | 2 | `.tad/evidence/reviews/alex/yolo2-phase1-v2/quality-round1.md` |
| backend/agent architecture reviewer | Gate 2 round 1 | FAIL | 2 | 1 | `.tad/evidence/reviews/alex/yolo2-phase1-v2/architecture-round1.md` |
| code/product-quality reviewer | Gate 2 round 2 incremental | CONDITIONAL PASS | 0 | 1 | `.tad/evidence/reviews/alex/yolo2-phase1-v2/quality-round2.md` |
| backend/agent architecture reviewer | Gate 2 round 2 incremental | CONDITIONAL PASS | 0 | 2 | `.tad/evidence/reviews/alex/yolo2-phase1-v2/architecture-round2.md` |

#### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|---|---|---|---|
| product-quality | completion prose must not become verified | FR3, AC3 | Resolved |
| product-quality | fresh agent must not receive old history | P4, AC6 | Resolved |
| architecture | do not turn PreCompact hook into second writer | §1.3, §7.2 | Resolved |
| architecture | no global active-run pointer | NFRs, data model | Resolved |
| architecture | stale historical session-state can misroute recovery | P4 uses explicit run path; guide must label session-state navigation-only | Resolved |
| backend/agent architecture R1 | arbitrary evidence file could forge verified | FR3, verification receipt contract, AC3 | Resolved — pending round-2 verification |
| backend/agent architecture R1 | run not bound to actual worktree/HEAD | NFRs, readGitIdentity, P4, AC3 | Resolved — pending round-2 verification |
| backend/agent architecture R1 | AC6–8 did not prove distinct treatments | score schema, AC6–AC7 | Resolved |
| backend/agent architecture R1 | partial JSONL tail not covered | data model, P3 fixtures | Resolved |
| code/product-quality R1 | summary JSON could self-assert dogfood success | raw evidence hash contract, P3 negative controls, AC6–AC8 | Resolved — pending round-2 verification |
| code/product-quality R1 | action_started was only synthetic state | P4 controlled guide patch + pre/post hash reconciliation | Resolved |
| code/product-quality R1 | diff stat did not prove allowlist | AC10 name-only allowlist | Resolved |
| backend/agent architecture R2 | legitimate commits after init could be rejected | NFR worktree/HEAD scope clarified | Resolved |
| backend/agent architecture R2 | action command lacked structured hash fields | CLI action-start/reconcile contract, P4 | Resolved |
| code/product-quality R2 | raw dogfood artifacts lacked machine schema | run/control evidence envelopes + checker contract | Resolved |
| code/product-quality R2 | author separation could be mistaken for cryptographic provenance | guide requirement + Gate 3 manual cross-check | Resolved |

### Overall Assessment

Gate 2 PASS. Two review rounds used; both round-2 verdicts are non-FAIL with zero residual P0. No third review round is permitted or needed.

## 10. Important Notes

### 10.1 Critical Warnings

- `completion_written=true`、`layer1_passed=true`、普通 evidence 文件、executor 自写 receipt 都不是本恢复 ledger 的 verified authority；只有绑定正确的 Conductor PASS receipt 可推进。
- 不得为了 capsule token 上限删除 non-goal、forbidden scope、blocker 或 legal-next-action reasoning。
- 不得把一条真实 dogfood 成功外推为跨任务、跨模型或跨 harness 质量提升。
- 不得用旧聊天或 compact summary 帮 fresh agent 过 semantic assertion。

### 10.2 Known Constraints

- Phase 1 single writer；若真实 dogfood 观察到并发写，记录为 kernel promotion trigger，不在本单追加锁系统。
- `recovery.md` 可删、可重建、可与事实冲突；永不具备 authority。
- 外部不可逆 action 不属于 dogfood target；side-effect fixture 只验证状态合同。

### 10.3 Sub-Agent Guidance

- Blake owns implementation + Layer 1 only。
- Gate 3 必须由至少两个独立 reviewer 读取真实 worktree 与证据。
- semantic reviewer 不得是 assertion 的作者；先看 assertion，再解封 oracle，避免答案泄漏。

## 11. Decision Summary

| # | Decision | Options | Chosen | Rationale |
|---|---|---|---|---|
| 1 | Delivery order | universal kernel / real slice / prompt-only | real slice | 用户问题是质量下降，必须先证明恢复结果 |
| 2 | Reference harness | Claude / Codex / OpenCode | Claude Code | 唯一已有真实 YOLO workflow；本地 probe 可运行 |
| 3 | Integration shape | modify workflow / outer opt-in recorder | outer recorder | blast radius 小，保留 v1 authority 与默认行为 |
| 4 | Truth source | recovery prose / compact summary / goal+journal+evidence | goal+journal+evidence | 防陈旧摘要和自报完成 |
| 5 | Semantic scoring | custom LLM engine / frozen oracle + independent reviewer | frozen oracle + reviewer | 不自造新的语义验证内核 |

## 12. Socratic Inquiry Summary

| 阶段 | 结果 |
|---|---|
| ICP | 本地单用户开发者，用任一 coding harness 执行长任务，最关心中断后不忘目标且质量不降 |
| Problem | 长任务 compact/退出后忘记目标和真实进度，最终质量下降 |
| Scope | 全面借鉴 LongHorizon；Epic 分期；Phase 1 先做真实恢复纵向切片 |
| Exclusion | 无多用户云服务/Web dashboard；Phase 1 无三 harness parity、default-on、通用 kernel |
| User risk | 中途忘记目标和进度，导致质量差 |
| Acceptance | hard anchors 100%、soft ≥90%、3/3 fresh recovery、真实继续过 Gate、无盲重试 |

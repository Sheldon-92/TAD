# Architecture Decision Document: Lite Authority Model v2 — Outcome Mandate

**Date**: 2026-08-09  
**Status**: ACCEPTED  
**Decision owner**: Human  
**Design owner**: Alex  
**Scope**: Alex Lite, Blake Lite, capability-skill composition, release/dependency/global-surface execution  
**Epic**: `.tad/active/epics/EPIC-20260809-full-capability-extraction-retirement.md`

## Context

Lite 当前把多种不同性质的事情都叫作“人工授权”：目标确认、风险偏好、命令权限、
技术恢复和最终验收。尤其在不可逆工作中，设计期已经确认过方向，执行期仍要求人为
逐条批准 push、tag、sync、downstream commit 等低层动作。

这不是可靠的人在回路，而是把 agent 应承担的技术判断转嫁给无法判断命令细节的人。
审批次数越多，人越容易机械同意；审计记录变多，但有效控制反而变弱。

用户裁定：

> “这个在最开始澄清需求的时候就该完成而不是等过程中授权，这是虚假授权，我根本判断不了。”

并明确指出：

> “不只是这个handoff，而是整个lite体系的设计。”

用户于 2026-08-09 对本方向答复“我同意”。该答复是体系设计决策，不需要再通过一次
同义确认才能生效。

## Decision

Lite 采用 **Outcome Mandate（结果授权契约）**：人在需求澄清与契约拍板时，一次性决定
目标、目标对象、允许产生的后果类别、最大影响范围、明确排除项与恢复偏好。执行期的
有效权限为：

```text
Lite role boundary ∩ capability-skill constraints ∩ accepted Contract Mandate
```

“Human”不再作为每条命令执行时临时取得的第四个 token。人的意图已经固化在被接受的
Contract Mandate 中。skill 只能收窄授权，不能扩权，也不能自行制造新的人工审批点。

### Execution Mandate 最小结构

```yaml
execution_mandate:
  mandate_id: "<stable task-scoped id>"
  desired_outcome: "<human-readable outcome>"
  authorized_consequence_classes:
    - local_commit
    - remote_main_update
    - annotated_tag
    - framework_sync
    - downstream_commit
    - downstream_push
  target_scope:
    repositories: []
    projects: []
    environments: []
  max_blast_radius: "<bounded, human-readable limit>"
  explicit_exclusions: []
  recovery_policy:
    not_started: retry_automatically
    partial: rollback_if_verified_else_stop
    unknown: inspect_then_apply_policy
  expires_when: task_complete_or_contract_changed
```

字段按任务裁剪；未列出的 consequence class 不代表默认允许。人的拍板对象是可理解的
后果与范围，不是 Bash、Git ref 或 exit code。Mandate 由 Alex 根据已经澄清的需求起草，
人不填写 YAML；已有对话足以确定的内容直接落盘，不得为了填字段重新制造一轮提问。

## Decision Ownership

| 判断 | Owner | 运行时行为 |
|---|---|---|
| 想达到什么结果、哪些外部后果可接受 | Human | 设计期写入 mandate，一次拍板 |
| 目标 repo/project/environment 与最大影响面 | Human | 设计期写入 mandate |
| 使用什么命令、参数、执行顺序 | Agent | mandate 内自主决定 |
| 命令失败、接线错误、verified-not-started 重试 | Agent | 自动诊断与恢复 |
| 确定性回滚、幂等恢复、reviewer 指出的契约内缺陷 | Agent | 自动执行并留证据 |
| 目标、对象或后果类别超出 mandate | Human | mutation 前重新做结果级决策 |
| 多个恢复方案会产生不同的用户可见结果 | Human | 展示后果选项，不展示命令审批题 |
| 最终业务结果是否值得接受 | Human | 末端业务验收 |

## Runtime Re-decision Boundary

只有出现新的**人域决策**时才允许中途询问：

1. desired outcome 发生实质变化；
2. target repo/project/environment 发生变化；
3. 需要 mandate 未授权的 consequence class；
4. 出现新的业务、法律、财务或身份责任取舍；
5. partial state 存在多个同样合法但用户可见结果不同的恢复方向；
6. 需要新的外部身份、凭证所有权或财务权限。

以下情况不是重新找人的理由：命令失败、工具不可用、exit code 不符预期、接线错误、
已证实未开始、可确定回滚、幂等重试、契约范围内的 reviewer 缺陷。它们属于 agent 域。

若确实越界，问题必须用“结果 / 影响范围 / 可见后果”表述；禁止要求人判断具体命令是否
安全。未得到新决定前 fail closed，但这叫 **boundary change**，不叫“再授权同一动作”。

## Transaction Semantics

consume-once 只用于识别一个不可重复的**业务事务实例**，不再用于每条 CLI 命令。
例如一次 release transaction 可以在同一 mandate 下包含 main push、annotated tag、tag push、
framework sync 与已列明的 downstream updates。agent 仍须执行前后状态核验、幂等检测、
目标白名单和证据记录，但不在每一步向人索取 nonce。

歧义结果先做只读检查：

- `not_started`：按 mandate 自动重试；
- `completed`：不得重复，进入验证；
- `partial`：执行已约定的确定性恢复；只有恢复结果存在人域分岔才询问；
- `unknown`：继续只读诊断；不能证明仍在 mandate 内时停止，不猜测 mutation。

## D1–D10 Architecture Decisions

### D1 — Core Architecture

保留 `Lite Core + capability skills`。Authority Model v2 不新增第三个代理或常驻权限服务；
它修正 Lite handoff 与 skill composition 的契约语义。

### D2 — State Ownership

Lite handoff/Progress 仍是唯一任务状态载体。`execution_mandate` 是 handoff 中被接受的任务状态，
skill 不得另建 approval state machine。

### D3 — Memory Role

Mandate 不是记忆推断结果。压缩、恢复或换 terminal 后必须从 handoff 读取，不得根据对话印象
重建或扩大。

### D4 — Context and Loading

Lite 常驻层只需知道 mandate 的存在与边界检查规则。命中专项任务后，skill 按需读取相关
consequence classes、target scope 与 recovery policy，不加载无关 full 协议。

### D5 — Permissions and Safety

权限公式改为 `Lite ∩ Skill ∩ Contract Mandate`。skill 可拒绝或收窄，不能扩权；技术步骤不再
逐项请求人工批准。真正越界时 mutation 前 fail closed，并请求一个人域决定。

### D6 — Lifecycle and Recovery

Mandate 在任务完成或契约实质变化时失效。压缩不使它失效，命令失败也不使它失效。
恢复优先遵循 mandate 的策略；不能证明边界内才停止。

### D7 — Human Interaction Budget

正常任务的人域交互预算为两处：开始时拍板 outcome mandate，结束时业务验收。
开始时的拍板复用需求/契约确认，不新增一场“授权仪式”。`avoidable_runtime_prompt_count`
的目标值为 0。中途询问只由 Runtime Re-decision Boundary 触发。

### D8 — Observability

每个外部 mutation 记录 `mandate_id`、transaction id、target、consequence class、pre/post state、
recovery state 与 evidence path。删除“每条命令 approval_id 是否已消费”作为核心观测模型；
另记 `boundary_change` 与 `runtime_prompt_reason`，以便发现形式主义回归。

### D9 — Verification

Authority Model v2 的最低验证集：

1. mandate 内完整 release/dependency transaction 的运行时人工询问数为 0；
2. 未授权 consequence class 在 mutation 前被拒绝；
3. target scope 改变在 mutation 前触发结果级重新决策；
4. verified-not-started 自动重试，不索取新批准；
5. deterministic rollback 自动执行并留证；
6. partial state 只有在人域结果分岔时询问；
7. skill 不能扩大 mandate；
8. Gate 4 只问业务结果，不让人复核技术证据。

### D10 — Disaster Mapping

本决策直接防止三类失败：

- **approval fatigue / rubber stamp**：大量技术问题训练人机械点同意；
- **false authorization**：记录显示“人已批准”，但人实际上无法判断命令含义；
- **responsibility outsourcing**：agent 把失败恢复、Git 状态和工具判断包装成人域问题。

同时保留对真实越界的 fail-closed，避免以“减少询问”为由扩大 mutation 权限。

## Supersession and Migration Impact

本 DR **不改写历史 evidence**，但从后续设计起取代以下语义：

- Phase 2 composition contract 中 `Lite ∩ Skill ∩ current human approval` 的 per-action 解释；
- `human_approval_required: bool` 作为 manifest 主模型；
- 每条 push/tag/sync 命令独立 consume-once approval；
- 技术失败后默认索取新批准。

后续 manifest 应迁移为：

```yaml
authority_mode: contract-mandate | runtime-exception | prohibited
mandate_id: "<task-scoped id>"
```

当前 Phase 3a release capability migration 可以继续完成，因为它只建设能力机制并禁止真实
mutation；其产出的 per-command approval machinery 视为待迁移实现，不得直接进入 live dogfood。

## Rollout Order

1. Phase 3a 按当前 handoff 完成，不中途重设计；
2. 新 Phase 3b 修订 Alex Lite、Blake Lite、composition contract 与 release-runbook authority layer；
3. Phase 3b 通过零形式主义询问的正/负向测试后，Phase 3c 才做真实 publish+sync dogfood；
4. dependency/global-surface 能力从一开始采用 v2，不复制旧 approval state machine；
5. burn-in 期间跟踪 `avoidable_runtime_prompt_count`，出现非零即作为设计缺陷处理。

## Consequences

正向结果：人只做自己能判断的选择；agent 对技术执行负责；授权边界更容易审计；Lite 的
交互成本与“仪式轻量”目标一致。

代价：handoff 必须更认真地描述 consequence classes、target scope 与恢复偏好；越界检测和
事务证据必须比“问一下就算安全”更可靠。这个成本属于设计与验证，不转嫁给运行时的人。

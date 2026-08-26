# Epic: YOLO 2.0 — 长任务连续性与质量闭环

**Epic ID**: EPIC-20260824-yolo2-verified-orchestration  
**Revision**: v2 — vertical-slice-first reset  
**Status**: IN PROGRESS — Phase 1 accepted; Phase 2 design is HONEST_PARTIAL at Gate 2 review cap
**Owner**: Alex  
**Created**: 2026-08-24  
**Reset**: 2026-08-24  
**Decision**: `.tad/decisions/DR-20260824-yolo2-vertical-slice-first.md`  
**Reset Audit**: `.tad/evidence/designs/yolo2-epic-reset-audit.md`  
**Research**: `.tad/evidence/research/longhorizon-harness/2026-08-24-raw-web-research.md`

---

## 1. Outcome

YOLO 2.0 要解决的不是“如何做一个更复杂的验证器”，而是两个用户可感知的问题：

1. 长任务经历 compact、进程退出、换会话或换 harness 后，仍能准确理解并继续同一个目标；
2. 随着任务变长，最终交付质量不下降，且错误进度、重复工作和假完成更少。

第一条可交付链路必须真实证明：

```text
已批准的目标/Handoff
  → 完成并验证若干工作
  → 强制 compact / kill
  → 新上下文只读取持久化恢复包
  → 正确复述目标、约束、决策、进度与下一步理由
  → 继续执行并通过现有 Gate
```

如果这条纵向链路没有在真实 YOLO 任务上成立，schema、hash chain、reducer 或跨平台字节一致均不算 Epic 进展。

## 2. Primary User and Boundary

- 主要用户：在本地仓库中使用 Claude Code、Codex 或 OpenCode 执行长任务的单个维护者。
- 首发形态：local-first、single-user CLI、opt-in。
- 权威边界：人类批准的 Epic/Handoff、真实工作树、测试结果、独立审查和 Gate 结论。
- 非目标：多用户云服务、跨机器 worker、远程控制面、完整 Web Dashboard。
- 威胁边界：防遗忘、语义漂移、陈旧进度、假完成、重复副作用与能力误判；不试图防御拥有同一账号完整写权限的恶意本机进程。

## 3. Product Invariants

1. **目标锚定**：目标、成功标准、非目标、不可触碰范围和 Handoff revision 不依赖聊天摘要。
2. **语义重入**：恢复后的 agent 在执行前，必须证明它理解关键决策、被否决方案、已验证/未验证工作、阻塞和下一步为何合法。
3. **真实进度**：executor 的“已完成”只是候选；只有现有验证证据与独立 Gate/reviewer 能把工作变成 verified。
4. **有界工作切片**：每轮只做一个可独立检查的连贯工作单元；不能把任务切成失去整体目标的机械碎片。
5. **恢复不重做**：已验证工作不重复；结果未知的副作用先对账，不能盲重试。
6. **质量不退化**：compact/restart 后的最终结果与不中断对照相比不劣化，并在故障条件下优于 YOLO v1。
7. **能力诚实**：各 harness 只声明实测能力；不具备恢复、隔离或独立审查时必须降级或停止。
8. **人类权威不变**：YOLO 只减少等待，不减少 Alex/Blake 分工、Gate 1–4、独立 reviewer 或最终人工验收。

## 4. Architecture

### 4.1 Control loop

```text
Human-approved Goal Contract
            ↓
Supervisor selects one coherent slice
            ↓
Executor produces candidate work + evidence
            ↓
Deterministic checks / independent reviewer verify outcomes
            ↓
Checkpoint records verified facts and unresolved risk
            ↓
Fresh context re-enters through a semantic recovery assertion
```

采用单 Supervisor、单状态写入者；不采用 peer swarm。LLM 负责计划、实现与语义判断，确定性代码只负责格式、状态转换、证据绑定、预算和恢复规则。

### 4.2 Four memory layers

| Layer | YOLO content | Storage |
|---|---|---|
| Working | 当前 slice、最近工具结果、当前问题 | 当前模型上下文，可丢失 |
| Episodic | checkpoint、执行事件、验证结果、决策历史 | 每个 run 的本地文件 |
| Semantic | 稳定项目原则、模式、长期事实 | `.tad/project-knowledge/` |
| Procedural | Alex/Blake/YOLO 协议、工具和 Gate 规则 | versioned skills/workflows |

当前步骤不能只存在 working memory；聊天摘要和平台 compact 块可帮助诊断，但从不成为 verified progress 的权威。

### 4.3 Minimum durable record

首个纵向切片只定义恢复所必需的最小结构：

```text
.tad/evidence/yolo/<epic>/<run-id>/
├── goal.json                 # frozen goal, success/non-goals, handoff revision
├── journal.jsonl             # append-only recovery-relevant events
├── checkpoint.json           # derived latest recovery point
├── recovery.md               # bounded, human-readable semantic capsule
├── evidence/                 # test/review pointers and receipts
└── actions/                  # only side-effecting action receipts
```

只在 recovery-relevant boundary 写 checkpoint：验证完成后、外部副作用后、HITL/停止前、compact/退出前。不会为每个 agent turn 建复杂账本。

### 4.4 Semantic recovery assertion

`resume` 不会直接执行下一步。新上下文先结构化返回：

- 原始目标、成功标准、非目标和不可触碰范围；
- 当前 Handoff/revision；
- 已验证事实及证据指针；
- 尚未验证、阻塞和 `outcome_unknown`；
- 关键决策、理由和已否决方案；
- 下一合法 action，以及它为何仍符合原始目标。

每个 dogfood case 必须在运行前冻结一份 atomic recovery oracle。goal、success/non-goal、forbidden scope、Handoff revision、verified state、blocker 和 legal next action 属于 hard anchors，必须 100% 命中；只有显式列出的决策理由/已否决方案属于 soft anchors，按独立 reviewer 或校准人工 rubric 计算且至少 90%。任何 hard anchor 错误、旧摘要与 ledger 冲突、或下一步理由无法成立，都返回 `honest_partial`，不得自动继续。

### 4.5 What is deliberately absent from the first slice

- 不执行或静态证明任意 repository JavaScript；不用 Acorn/VM/动态代码黑名单构建自定义沙箱。
- 不先建六套通用 schema、通用 reducer、密码学 hash chain 或分布式 fencing。
- 不把每个低风险 action 都交给两名 LLM auditor。
- 不在真实 dogfood 前承诺三 harness 质量等价。

若真实故障证明需要更强 reducer、原子写、锁或完整事件溯源，再把重复机制抽成内核；机制必须由观测到的失败购买，而不是预先成为产品本身。

## 5. Architecture Decision Document — D1–D10

| Decision | Choice |
|---|---|
| D1 Agent complexity | Level 3 bounded orchestrator-workers；动态软件工作不能退化为固定链，但不允许无界 Level 4 |
| D2 Coordination | Supervisor + single canonical writer + isolated workers |
| D3 Memory | 四层 memory；run journal 是 episodic，不把 temporary state 写入长期知识 |
| D4 Tools | harness-native、按需加载；核心不引入额外 MCP/服务 |
| D5 Permissions | 最低可用权限；不可逆动作前置 Gate；复用 harness sandbox，不自造 JS sandbox |
| D6 Compression | staged compaction + durable recovery；native compact 是优化，不是记忆权威 |
| D7 Cost | round/action/token/time 预算与 audit reserve；耗尽输出 honest_partial |
| D8 Observability | 从第一天记录 JSONL、tokens、latency、resume、重复工作和 reviewer defects |
| D9 Testing | 真实任务 paired baseline、故障注入、结果指标；结构测试不替代质量测试 |
| D10 Disaster prevention | no blind retry、goal re-grounding、single writer、explicit verifier、bounded loops |

按每步失败率 1% 估计，20/50/100 个连续步骤的累计失败概率约为 18.2%/39.5%/63.4%；因此长任务必须拆成可恢复切片，但切片必须保持一个连贯结果，而不是按 token 机械分割。

## 6. Phase Map

| # | Phase | Status | First useful outcome |
|---|---|---|---|
| 1 | 真实恢复纵向切片 | ✅ Done — Gate 4 accepted 2026-08-25 | 一个真实 YOLO 任务可在 compact/kill 后由新上下文正确继续 |
| 2 | 质量保持的有界执行闭环 | Gate 2 HONEST_PARTIAL (v0.9.2; review cap) | 恢复理解、短回合、独立验证和整体质量检查形成闭环 |
| 3 | 多 harness 适配与 opt-in 接入 | Planned | Claude/Codex/OpenCode 给出实测 strict/degraded/blocked 结论 |
| 4 | 配对评估、故障注入与默认裁决 | Planned | 用真实任务证明质量与可靠性，再决定是否 default-on |

顺序执行。Phase 1 就必须接触一个真实、opt-in 的 YOLO 路径；不允许把真实集成推迟到最后。

## 7. Phase Details

### Phase 1 — 真实恢复纵向切片

**Status:** ✅ Done — Gate 4 accepted 2026-08-25

**Notes:** Runtime and dogfood outcomes passed: all three interruption recoveries
scored hard 8/8 and soft 1.00, continued the task, passed hidden acceptance, and
passed the existing Gate. Human approved the OpenCode Task-subagent degradation for
Phase 1 only. The lifecycle checker now accepts exactly one complete active or
archived pair, rejects all other combinations, and makes committed-diff must-appear
assertions follow the resolved state. Alex independently passed the full 10-case
suite in active, simulated-archive, disposable committed-archive, and final real
post-archive layouts.

**Scope**

- 先对可用的一等 harness 做真实 capability probe，按证据选择 reference harness。
- 冻结一个小型 v1 基线与 5–10 个历史/真实长任务案例。
- 实现最小 `init/status/checkpoint/resume/verify/stop` 行为合同与 recovery capsule。
- 在一个真实 YOLO maintenance task 中强制 compact、kill 和 fresh-session resume。
- 复用现有 Handoff、测试、reviewer 和 Gate；不建立通用安全验证器。

**Acceptance outcomes**

- 3/3 中断恢复均精确得到同一 goal ID、Handoff revision、成功标准、非目标和最后 verified slice。
- 3/3 均正确列出未完成工作、阻塞、风险与下一合法 action；不读取旧聊天历史也能继续。
- recovery assertion 的 hard anchors 准确率 100%，soft rationale anchors 至少 90%；anchor 集、评分 owner、rubric 与分歧处理在 case 运行前冻结，任一 hard-anchor 错误都会停止。
- 删除/陈旧/冲突的 recovery.md 不会覆盖 goal/journal 权威；只给 completion prose 不会推进 verified。
- 中断 side-effect action 时只允许已确认、`outcome_unknown` 或 reconciled 三种结果；盲重试 0 次。
- 人类只读一份 `status`，一分钟内能回答目标、真实进度、阻塞、下一步和责任角色。
- recovery capsule 目标上限为约 2,500 tokens；若超限必须报告构成，不得删关键锚点换取过线。

**Exit**: 真实纵向链路通过 Gate 2/3/4 后，才允许 Phase 2 扩展 round engine。

### Phase 2 — 质量保持的有界执行闭环

**Scope**

- Supervisor 每次选择一个与 AC/成果对应的连贯 slice。
- fresh executor 只拿 goal anchor、当前 slice、必要证据和工具；不继承冗长历史。
- deterministic checks 优先验证结构与行为；需要语义判断时使用独立 reviewer。
- 每个恢复点执行 semantic re-entry；每 2–3 个 slice 或 phase candidate complete 前重新对齐整体目标。
- 允许重规划未验证工作，不允许静默改变已批准目标或 Handoff。

**Acceptance outcomes**

- 5–10 个真实 dogfood task 至少各经历一次强制上下文丢弃，恢复后重复 verified work <2%，越权/错误 next action 为 0。
- resumed 与 uninterrupted 配对运行使用同一模型、预算、任务和顺序随机化；最终 reviewer P0/P1 不增加。
- Manager 漏掉关键非目标、旧摘要与 ledger 冲突、测试绿但隐藏业务验收失败等反例会被整体目标检查拒绝。
- round、retry、action、time、token 任一预算耗尽均产生可恢复 honest_partial；不存在无限 evaluator loop。
- executor 自报完成、单 reviewer 缺失、失败测试或 Handoff revision 变化都不能进入 phase candidate complete。

### Phase 3 — 多 harness 适配与 opt-in 接入

**Scope**

- 建统一 adapter contract，但每个平台独立 probe：start、fresh context、resume、structured output、worktree/snapshot、reviewer independence、permissions、timeout 和 hooks。
- Claude Code 与 Codex 是正式目标；OpenCode 先作为 capability-gated adapter，不提前承诺 first-class installer support。
- 把 v2 接入现有 Y5/Y6 的 opt-in/shadow 路径；Y1–Y4、Y7–Y8 authority 不变。

**Acceptance outcomes**

- 每个平台输出 `strict`、`degraded` 或 `blocked` 及运行证据；unknown 不得被解释为 supported。
- 三平台共享 goal/checkpoint/recovery 语义，但不要求底层工具或字节轨迹相同。
- 缺少独立 reviewer、可靠 resume 或所需权限边界时，strict completion 3/3 被拒。
- v1 历史 artifact 保持可审计；v2 corruption 或 capability drift 只会 honest_partial，不会翻译成 v1 complete。
- `status/resume/stop` 使用普通语言，不要求用户阅读 JSONL。

### Phase 4 — 配对评估、故障注入与默认裁决

**Evaluation set**

- 建立 50–100 条 versioned representative trajectories，覆盖机械维护、跨文件功能、含冲突约束的长任务。
- pilot 可先用 10 条真实任务发现协议问题；default-on 结论必须达到至少 50 条。
- deterministic safety case 可单次验证并做 3 次故障重复；semi-deterministic 至少 3 次；non-deterministic quality subset 每条件至少 10 次并报告分布。
- 生成者与 judge 不得是同一模型家族；主观质量由盲化人工样本校准，未校准 judge 只能作辅助信号。

**Go / no-go**

- P0 fault：false verified/complete = 0，verified side-effect duplicate = 0，Pass³ = 100%。
- 关键恢复锚点准确率 = 100%；完整 semantic recovery ≥90%。
- compact/restart 条件下，v2 最终盲审通过率相对 v1 **提升 15pp 是产品目标**；default-on 的统计门槛是 paired 差值置信区间下界 ≥0（证明不退化）。若未达到 +15pp，必须解释价值是否主要来自可靠性/安全提升。
- 无故障任务质量相对 v1 的下降不超过 5pp。
- 恢复后重复已验证工作率 <2%，错误/越权 next action = 0。
- 每个 case 报告质量、token、wall time、round、audit 占比；P0 质量不得为成本让路。
- 只有上述门槛、Gate 3、Gate 4 和最终人工接受全部通过，才允许另行提议 default-on；否则保持 opt-in。

每个 v1/v2 pair 必须从同一冻结 commit、输入、预算、cache policy 和隐藏验收 fixture 启动，运行在隔离 worktree；隐藏验收只能在两个候选都完成后揭示和评分。

## 8. Success Metrics

| Dimension | Metric | Priority |
|---|---|---|
| Capability | final accepted-AC completion | P0 |
| Reliability | recovery anchor accuracy, Pass@k, Pass^k | P0 |
| Quality | blind final outcome score, reviewer defect escape rate | P0 |
| Safety | false completion, duplicate side effect, unauthorized next action | P0 |
| Efficiency | tokens, time, audit share, verified progress / 100K tokens | P1 |
| Usability | time for human to understand status and resume | P1 |

评估结果优先于内部机制指标。`state replay PASS`、schema valid 或 adapter fixture 一致，不能单独证明质量提升。

## 9. Rollout and Rollback

1. Phase 1–2：reference harness、单任务 opt-in dogfood；v1 默认不变。
2. Phase 3：shadow/opt-in，多平台只开放已证明的 mode。
3. Phase 4：证据达标后提出 default candidate，不自动切换。
4. Rollback：停止新 slice，保存最后 verified checkpoint，输出 honest_partial，回到同一 Handoff 的人工或 v1 路径；未验证状态不能升级为完成。

## 10. Explicitly Retired from v1 Design

- 原 Phase 1 `HANDOFF-20260824-yolo2-phase1-contract-baseline.md` 被本 reset supersede，不得交给 Blake。
- Cycle 1–5 的 verifier findings 保留为研究证据，但不再是 Epic 的阻塞路径。
- 旧 DR 的“先建完整 deterministic kernel 再接 YOLO”顺序被撤销；file-native/local-first 方向继续保留。

## 11. Next Design Step

Phase 1 is accepted and archived. Phase-2 Handoff v0.9.2 now defines the bounded
execution/quality loop on top of the same journal/reducer, with a strict one-harness
runner, native action reconciliation, whole-goal alignment, frozen budgets, and five
paired dogfoods. Two Gate-2 rounds found and drove concrete amendments; round 2 still
returned one new evaluation P0 and one architecture P1. Alex incorporated both, but
the two-round review cap is reached, so there is no independent PASS carrier and no
implementation authority. The next move is a human decision to reopen one narrow
independent closure review or revise/stop the Phase-2 design; Phase-1-only OpenCode
degradation approval still does not carry forward.

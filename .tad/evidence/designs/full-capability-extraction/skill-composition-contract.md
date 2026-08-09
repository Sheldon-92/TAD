# Architecture Decision Document

**范围**: Lite Core + Capability Skills 的组成契约（Epic Phase 2）。本单只设计契约与
fixture，不实现 composition runtime，不创建任何 skill 目录。
**输入**: `capability-disposition.yaml`（Phase 1 inventory，19 个能力条目）。
**决策导航**: 逐项走 ai-agent-architecture D1–D10。

## D1–D10 决策表

| Decision | Pattern | Rationale | Cost impact | Source |
|----------|---------|----------|-------------|--------|
| D1 | "Do not use Level N if Level N-1 can solve it"（5 级复杂度矩阵选 Level 1–2） | full 的巨型代理路径是 Level 4 autonomous agent：Lusser 定律下 >14 个顺序 LLM 步端到端成功率跌破 50%，每一步都是失败面；"The loop is trivial, the harness is the moat"——低频能力以 skill（确定性文本协议 + 工具编排）落地，不为其保留第三套代理路径 | 无新增运行时；skill 正文按需加载（~500–2K tokens/命中） | .agents/skills/ai-agent-architecture/references/need-an-agent.md |
| D2 | Hub-spoke：orchestrator 是唯一 canonical state owner，worker 经 orchestrator 读写 | Incident #5（ticket race condition）/ #6（ordering failure）：多个写者共享可变状态必然状态分叉；当前 Lite 角色（经 LITE-*.md + Lite Progress）是唯一任务状态所有者，skill 无独立可变状态——只读输入、写回契约文件 | 状态路径不变（LITE handoff 仍唯一载体），零新增同步机制 | .agents/skills/ai-agent-architecture/references/coordination-and-state.md |
| D3 | Tiered memory（hot/warm/cold）+ Hermes 路由（facts→memory / procedures→skills / temporary state→session） | 临时任务状态永不进持久记忆（否则每个未来 session 继承损坏状态）；skill 知识是 procedures 域：metadata 常驻（hot）、SKILL.md 命中才加载（warm）、references/scripts 按需（cold） | 常驻索引 ~1K tokens/session；未命中能力时正文加载 0（§10） | .agents/skills/ai-agent-architecture/references/context-memory.md |
| D4 | Search-then-load（deferred loading，>20 tools 策略）；SkillTool（~1x）而非 AgentTool（~7x） | 40 工具 upfront = 8–55K tokens 定义开销，search-then-load 降至 ~1/55；能力知识是"命中当前上下文才需要"的指令 → 用 SkillTool 内联，不用 AgentTool 隔离 | 索引 ~1,000 tokens vs 55,000 upfront | .agents/skills/ai-agent-architecture/references/tool-management.md |
| D5 | Deny-first with independent failure modes + atomic approval consumption（一次性授权） | Incident #1（PocketOS wipe：令牌无范围）/ #2（MCP 工具投毒）/ #3（工具影子化）：skill 文本就是工具定义，天然是投毒面；有效权限取 **Lite ∩ Skill ∩ Human** 交集，**skill cannot override** 角色分离、安全停、契约范围或 reviewer；高风险动作一次性人工授权（**consume-once approval**） | 授权 nonce 一次性、无持久权限面；交集 = 任一层拒绝即拒绝 | .agents/skills/ai-agent-architecture/references/permissions-safety.md |
| D6 | Graduated compression（5 层瀑布）+ active task protection（活任务永不压缩） | Hermes #8：压缩边界不得切断 tool-call 原子边界（并行 turn 必须整体保留）；handoff 中 **pinned skill version**，压缩恢复只重载被 pin 的 skill/version；恢复时版本不同 → BLOCKED（fixture version-mismatch） | pin 字段 + 恢复重载一步 | .agents/skills/ai-agent-architecture/references/context-compression.md |
| D7 | Budget caps per session（max_tokens / max_api_calls / on_budget_exceeded） | 无预算 → runaway loop（2026 早期 60% LLM 错误是循环）；Incident #7 双扣款 = 无幂等重试 + 无预算；skill 选择、版本、授权与 verdict 必须可追踪 | 普通 lite 任务 0 增量（未命中能力正文加载 0） | .agents/skills/ai-agent-architecture/references/cost-token-economics.md |
| D8 | JSONL append-only + trace correlation ID chain | 无观测 = 静默劣化（最频繁的生产失败模式，发现晚 3 天）；skill 调用跨角色 trace 连续性：`skill_selected / mode / version / approval_id / verdict / evidence_path` 六字段 | 每 skill 调用 ~6 字段日志 | .agents/skills/ai-agent-architecture/references/observability.md |
| D9 | Per-transition tests with corrupted inputs + stochastic invariants；fixture 可执行化 | Lusser：每个 agent 间 transition 独立测试（含坏输入），端到端只测 happy path 会在生产才暴露；负例 fixture 的 expected_verdict 全部 ∈ {DENY, BLOCKED}，Phase 3 建成 runtime 后成为可执行回归测试 | 6 fixtures → Phase 3 执行回归 | .agents/skills/ai-agent-architecture/references/testing-evaluation.md |
| D10 | Disaster → single decision mapping（每个事故映射到一个决策） | 设计期读 D10 可以跳过事故：privilege-escalation→#1（数据库清空）、approval-replay/irreversible-retry→#7（双扣款）、skill-conflict→#3/#5（影子化/竞争）、version-mismatch→#2（rug-pull 变体）、state-fork→#5/#6；6 个 fixture 是事故的可执行化身 | 设计期覆盖成本最低（事后修复 2–10x） | .agents/skills/ai-agent-architecture/references/production-disasters.md |

## 1. Lite Core + Capability Skills 拓扑

```
Lite Core（alex-lite / blake-lite）
  ├── 唯一任务状态所有者（LITE-*.md + Lite Progress）
  ├── 契约审查 / 实现 / AC 自验 / 独立 reviewer / 技术门 / 人工验收
  └── 按需加载 Capability Skills（release-runbook, dependency-ops, ...）
        └── skill 无独立可变状态；只读输入，产出写回契约载体
```

当前 Lite 角色是唯一任务状态所有者（**single task-state owner**）；skill 是"专项知识 +
确定流程 + 工具编排"的包，不拥有 handoff、Progress 或任何会话状态。普通 Lite 任务
不命中专项能力时，无任何 skill 正文被加载（§10）。

## 2. Skill Manifest 候选字段

| 字段 | 类型 | 语义 |
|------|------|------|
| name | string | skill 标识（目录名，lowercase-hyphen） |
| description | string | 触发描述（什么时候用，放 frontmatter，不放正文） |
| supported_roles | [alex-lite\|blake-lite] | 允许的角色（封闭枚举，防跨角色调用） |
| modes | [plan\|execute\|verify] | 允许的模式（封闭枚举） |
| inputs | [string] | 输入契约（路径/参数/产物） |
| outputs | [string] | 输出契约（写回哪些契约载体） |
| allowed_writes | [string] | 显式写权限清单（deny-first：未列出即拒绝） |
| safety_class | normal\|human-gated\|history-only | 安全分类（与 disposition 相同枚举） |
| human_approval_required | bool | 是否需一次性人工授权 |
| evidence_contract | string | 可观测性字段与证据路径要求 |
| rollback | string | 回滚方式（可回滚操作才允许自动重试） |
| version | string | pin 版本（handoff 中引用，恢复重载凭此校验） |

## 3. 权限模型

有效权限 = **Lite ∩ Skill ∩ Human**：Lite 角色权限、skill 声明的 allowed_writes、
本次人工授权的交集；任一层拒绝即拒绝（deny-first，fail closed）。
**skill cannot override** 角色分离、安全停清单、契约范围或独立 reviewer ——
skill 文本声明与角色/契约冲突时，契约优先。高风险动作（publish/sync/依赖变更等
安全停清单第 1 条）仍须一次性人工授权（**consume-once approval**）：授权 nonce
一次性消费，重放窗口为零；重复请求必须携带新授权（fixture approval-replay）。

## 4. 生命周期

```
discover → select → pin in handoff → load → execute/verify → unload
```

1. discover：Lite 角色从 manifest/索引（metadata 常驻）发现候选 skill；
2. select：按任务命中 description 选择；
3. pin in handoff：Alex-Lite 把选中的 skill + version 写进 LITE 契约（pinned skill version）；
4. load：Blake-Lite 按 pin 加载 SKILL.md 正文；references/scripts 再按需；
5. execute/verify：按 skill 流程执行并用其 evidence_contract 验证；
6. unload：执行完毕从上下文卸载（不保留 skill 正文残留）。
压缩恢复只重载被 pin 的 skill/version；恢复时版本与 pin 不同 → BLOCKED 并回 Alex-Lite
重新决策（fixture version-mismatch）。

## 5. 冲突处理

多个 skill 对同一动作给出冲突规则，或 skill 声明与 Lite 契约冲突 → **fail closed**：
停止执行，回 Alex-Lite 做契约决策（新增/修订约束按约束定价台账走）；
执行侧不得即兴选胜者（fixture skill-conflict）。失败恢复走 Lite Repair Loop
（repair_round / same_error_count 熔断），不重置计数。

## 6. 可观测性

每次 skill 调用记录：`skill_selected / mode / version / approval_id / verdict /
evidence_path`。跨角色 trace 连续性：handoff 是根 trace，skill 调用作为 span
记录在 Lite Progress 与 Completion 的 Evidence 字段。verdict 只由证据路径支撑
（Claims Need Carriers——没有落盘证据的 verdict 不是 claim）。

## 7. D9 验证计划

| 验证面 | 手段 | 阶段 |
|--------|------|------|
| schema | 对 manifest 字段做封闭枚举/类型校验（AC 机械化） | 本单 AC1 |
| 角色边界 | 负例 fixture：skill 请求超出 Lite 角色写权限 → DENY | Phase 3 |
| 坏输入 | 对每个 transition 注入 corrupt/malformed 输入，验证优雅失败 | Phase 3 |
| 权限旁路 | 负例 fixture：skill 尝试另建任务状态 / 越权 → BLOCKED | Phase 3 |
| 压缩恢复 | 负例 fixture：pin 版本与恢复版本不同 → BLOCKED | Phase 3 |
| 幂等/重试 | 负例 fixture：一次性授权重复消费 / 超时后重复动作 → DENY | Phase 3 |
| 真实 dogfood | 首个 EXTRACT 候选（dependency-ops）建成后在真实依赖变更上 forward-test | P4 |

composition-negative-fixtures.yaml 是 Phase 3 runtime 的规范 fixture；本单只验证
fixture schema 与 D9 映射完整（AC5），不伪称 runtime 已实现。

## 8. 候选能力展开

## Candidate: dependencies

**处置**: EXTRACT → `.claude/skills/dependency-ops/`
**载体**: `.claude/skills/alex/references/deps-protocol.md`、`.tad/dependencies/REGISTRY.yaml`
**角色/模式**: alex-lite(plan) / blake-lite(execute, verify)；**安全类**: human-gated
（依赖升级 = 安全停清单第 1 条，须人工授权）
**真实触发例**:
1. "升级框架的某个依赖并更新 lockfile"（历史 *deps 等价；依赖升级必须停人）
2. "审查 .tad/dependencies/REGISTRY.yaml 的依赖变更是否安全"（供应链安全审查）
3. "检查依赖清单与 lockfile 是否一致"（漂移校验）
**资源计划**: SKILL.md（简洁渐进披露）+ `references/deps-protocol.md`（操作协议全文）
+ `scripts/deps-verify.sh`（清单/lockfile 一致性机械校验，低自由度脚本）
**forward-test 提示**: "Use the dependency-ops skill at .claude/skills/dependency-ops
to audit whether the current dependency registry is consistent with installed versions
and report any drift — do not change any dependency."（forward-test 子代理不得预知答案）

## Candidate: release-ops

**处置**: EXTEND → 现有 `.claude/skills/release-runbook/`
**载体**: `.claude/skills/alex/references/publish-protocol.md`、
`.claude/skills/alex/references/sync-protocol.md`、`.tad/hooks/lib/release-verify.sh`
**角色/模式**: alex-lite(plan) / blake-lite(execute, verify)；**安全类**: human-gated
（publish/sync = 安全停清单第 1 条）
**真实触发例**:
1. "发一个 TAD 新版本到 GitHub"（历史 *publish 等价；人授权后才 push/tag）
2. "把框架同步到 14 个注册项目"（历史 *sync 等价；deny-list 同步集）
3. "发布前跑一遍 release-verify parity 校验"（detect-only，不自动 heal）
**资源计划**: SKILL.md + `references/publish-ops.md` + `references/sync-ops.md`
（把 full 操作协议蒸馏进现役 skill）+ `scripts/release-verify-wrapper.sh`（parity 包装）
**forward-test 提示**: "Use the release-runbook skill at
.claude/skills/release-runbook to prepare a TAD v2.41.0 publish: run the pre-flight
checklist, identify the version-bump file list, and report the parity check result —
do NOT push or tag."（禁止写操作；验证 detect-only 纪律）

## 9. 成品 skill 落点与镜像

成品 skill 未来落点为 `.claude/skills/<name>/`，经框架 parity 机制产生 `.agents`
镜像（release-verify.sh parity）。**本单不初始化任何目录**（AC6 以 filesystem
path-set 哈希验证零新建，包括 gitignored 路径）。

## 10. 普通任务零加载保证

普通 Lite 任务不命中专项能力时：manifest/metadata 常驻（~1K tokens），
**新增正文加载为 0**——不因本 Epic 增加固定读取量（Epic SC3）。skill 正文只经
"handoff pin → 命中加载"单一路径进入上下文。

## 负例 fixture 与决策映射

| fixture id | 场景 | expected_verdict | 映射决策 |
|------------|------|------------------|----------|
| privilege-escalation | skill 请求超出 Lite 角色写权限 | DENY | D5（最低权限/deny-first）+ D10 #1 |
| version-mismatch | handoff pin 的 skill version 与恢复时版本不同 | BLOCKED | D6（pin/recovery）+ D9（transition 测试） |
| skill-conflict | 两个 skill 对同一动作给出冲突规则 | BLOCKED | D2（单一状态所有者）+ D5（交集）+ D9 |
| approval-replay | 一次性人工授权被重复消费 | DENY | D5（consume-once）+ D9 + D10 #7 |
| state-fork | skill 尝试另建任务状态 | BLOCKED | D2 + D3（temporary state）+ D9 + D10 #5/#6 |
| irreversible-retry | publish/sync 超时后的重复动作请求 | BLOCKED | D2（幂等键 idempotency key）+ D5 + D9 + D10 #7 |

全部 expected_verdict ∈ {DENY, BLOCKED}；运行时行为验证明确顺延 Phase 3
（本单只验证 fixture schema 与 D9 测试映射完整，不伪称 runtime 已实现）。

# LITE Handoff: Lite / Standard / Full Routing Profiles

**Date**: 2026-08-01 | **escalated_review**: yes (用户原话: "我想大部分的工作都能够用Lite版本来完成。")

## 目标（2-3 句，含“为什么”）

把 TAD 的默认工作重心稳定放在 Alex-Lite / Blake-Lite，同时为中等复杂度任务增加可调的 Standard 深度，避免用户为了获得更多分析或验证就被迫进入 Full TAD。Standard 是 Lite 的 effort profile，不是新的 Agent 身份；Full 仍只处理高风险治理边界，从而在保留确定性核心的同时降低日常 token、时间和认知负担。

## 不做什么

- 不创建独立的 Alex-Medium / Blake-Medium 技能副本。
- 不因 handoff 页数、文件数量、上下文长度或细节增加而自动升级到 Full。
- 不删除 Lite 的角色分离、handoff 契约、共享知识预检、AC 验证、独立 reviewer、人工门、safety stop、repair loop 或 honest partial。
- 不修改 Full TAD 的既有安全、协议、发布和 fatal-operation 边界。
- 不在本单引入动态 supervisor、peer swarm 或额外多 Agent 编排层。

## 文件清单（创建/修改，逐个路径）

- `.claude/skills/alex-lite/SKILL.md` — 增加 Alex 设计深度 profile、组合路由和 Full 边界说明。
- `.agents/skills/alex-lite/SKILL.md` — 与 Claude 镜像保持 byte-identical。
- `.claude/skills/blake-lite/SKILL.md` — 增加 Blake 执行深度 profile、组合路由和 Full 边界说明。
- `.agents/skills/blake-lite/SKILL.md` — 与 Claude 镜像保持 byte-identical。
- `AGENTS.md` — 增加用户可理解的 Lite / Standard / Full 路由说明；不复制持久知识。

## 设计决策

### 1. 三层治理，而非六个 Agent

- **Lite（Night 默认）**：默认工作通道；能力完整、仪式轻量。
- **Standard**：Lite 的增强深度配置；增加分析、验证和证据深度，但不改变 Agent 身份。
- **Full TAD**：高治理例外通道；命中既有升级清单或 fatal 边界时使用。

### 2. 设计深度和执行深度独立路由

支持以下常用组合：

| 设计 | 执行 | 适用形状 |
|---|---|---|
| Lite | Lite | 目标清晰、局部且可验证的普通任务 |
| Standard | Lite | 方案取舍/依赖较复杂，但实现相对机械 |
| Lite | Standard | 方案清晰，但实现有集成、测试或恢复风险 |
| Standard | Standard | 中等复杂的普通功能 |
| Full | Full | 协议、安全、发布、认证、生产或 fatal 操作 |

Full 不是通过 Standard 绕开的“更高深度”；一旦命中 Full 边界，相关设计和执行必须遵循 Full 治理。

### 3. 路由权威与 Full 边界

- 设计深度由当前 Alex 角色根据目标不确定性、方案取舍和依赖风险决定；执行深度由当前 Blake 角色根据实现不确定性、集成风险和验证负担决定。
- 用户可以明确请求 Standard，但不能用 profile 选择覆盖 Full 边界；Alex/Blake 任一侧发现更高风险时，采用更高风险路由并记录理由。
- Full 的精确匹配来源是 Alex-Lite 当前“升级清单”的四类：SAFETY 面、协议契约面、耦合面、Fatal operations。第 1–3 类可在用户明确坚持 Lite 且保留 escalated_review 时继续；第 4 类无例外进入 Full。
- Standard 不拥有新的升级豁免权，不改变 Full 清单，也不引入隐式 supervisor 或自动升级器。

### 4. Standard 的增量能力

Alex Standard 增加：有界 caller/consumer 检查、方案取舍、风险/依赖图、更加细化的 AC 和失败场景；仍然 design-only。

Blake Standard 增加：分阶段实现检查点、更多行为/集成验证、更严格的 repair budget 和更完整的证据整理；仍然按 handoff 执行。

### 5. 不可削弱的质量核心

所有 Lite/Standard profile 都必须保留：角色分离、先契约后实现、共享 `.tad/` 知识与状态、AC dry run、真实证据载体、至少一个 fresh-context 独立 reviewer、人工计划/验收门，以及 safety stop 和 honest partial。

### 6. 路由优先级

1. 先按风险判断是否命中 Full；风险优先于规模。
2. 未命中 Full 时，再分别判断设计深度和执行深度。
3. 只需更多思考或验证时进入 Standard，不改变工作通道。
4. 页数、文件数、协议密度和上下文大小只能影响 profile 深度，不构成自动升级条件。

## AC

- AC1: 四个 Lite 技能镜像均包含同一份 Lite / Standard / Full 三层定义，且 Lite、Standard、Full 的治理边界互不矛盾。
- AC2: 四个 Lite 技能镜像明确声明 Standard 是 profile/深度配置而非独立 Agent 身份，并且没有新增 Alex-Medium 或 Blake-Medium 技能路径。
- AC3: Alex-Lite 文档定义 Lite 与 Standard 的设计侧增量能力，并保留 design-only 约束。
- AC4: Blake-Lite 文档定义 Lite 与 Standard 的执行侧增量能力，并保留 handoff-only、AC、自验、独立 reviewer 与 completion 约束。
- AC5: 路由契约明确支持 Alex 与 Blake 独立选择深度，并逐项覆盖 Lite/Lite、Standard/Lite、Lite/Standard、Standard/Standard 四种组合。
- AC6: 路由契约明确将 SAFETY、协议、发布、认证、生产配置和其他 fatal 边界导向 Full，且不存在用 Standard 绕过 Full 的路径。
- AC7: 路由契约明确声明页数、文件数、协议密度、知识上下文量和细节多少不构成自动升级条件。
- AC8: 所有 Lite/Standard profile 都明确保留共享 `.tad/project-knowledge/`、`.tad/brain-index.md`、handoff/Completion、AC 证据、fresh-context reviewer、人工门与 safety stop。
- AC9: `AGENTS.md` 的用户路由说明与四个技能镜像中的 profile 名称、组合方式和 Full 边界一致，不复制持久项目知识。
- AC10: 两个平台的 Alex-Lite 文件 byte-identical，两个平台的 Blake-Lite 文件 byte-identical，且只读结构检查能在四个技能文件中找到新增 profile、独立路由、Full 边界和不可削弱质量核心的关键标记。
- AC11: 变更集合只包含本文件清单中的五个目标文件；无关 dirty 文件不被夹带。

## 知识引用

- `.tad/brain-index.md` — 现有 TAD 架构、Gate、handoff、记忆和 Lite 独立审查模式的低成本发现入口。
- `.tad/project-knowledge/architecture.md` — 现有双角色与质量链架构是路由 profile 的不可破坏基线。
- `.tad/project-knowledge/patterns/gate-design.md` — 每个完成声明必须有职责明确的 gate 和证据载体；Standard 不能通过减少验证换取低成本。
- `.tad/project-knowledge/patterns/memory-and-learning.md` — 共享持久知识、恢复状态和 trace 必须依赖明确文件载体；profile 不得产生平台私有 memory 权威。

## AC Verification Plan

验证身份与载体约定：实现 principal = Blake-Lite；只读契约/实现 reviewer = 独立 fresh context；人工 gate = 用户。验证在仓库根目录、目标文件已存在且当前工作区 baseline 已记录后运行。所有 `rg -q` 命令 exit 0 才算通过；失败即阻断，不以自然语言解释替代命令结果。

### 固定结构标记

实现必须保留以下可机械检查的英文标记（标题或同义固定行，不用自由 prose 代替）：

- `Effort Profiles: Lite / Standard / Full`
- `Standard is a profile, not a separate agent`
- `Independent Design / Execution Routing`
- `Full Boundary`
- `Non-Negotiable Lite Core`
- `Lite/Lite`, `Standard/Lite`, `Lite/Standard`, `Standard/Standard`
- `shared .tad/ knowledge` 或等价明确的 `.tad/project-knowledge/` / `.tad/brain-index.md` 路径

### 逐条可执行矩阵

| AC | Principal | 前置状态 | 可复制验证 | 判定标准与证据载体 |
|---|---|---|---|---|
| AC1 | 独立 reviewer | 四个 Lite SKILL 已修改 | `for f in .claude/skills/alex-lite/SKILL.md .agents/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md .agents/skills/blake-lite/SKILL.md; do rg -q 'Effort Profiles: Lite / Standard / Full' "$f" || exit 1; done` | 四次均 exit 0；命令输出/审查报告记录于 `.tad/evidence/acceptance-tests/lite-standard-routing/ac-report.md` |
| AC2 | 独立 reviewer | AC1 通过 | `for f in .claude/skills/alex-lite/SKILL.md .agents/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md .agents/skills/blake-lite/SKILL.md; do rg -q 'Standard is a profile, not a separate agent' "$f" || exit 1; done; ! rg -q 'alex-medium|blake-medium|Alex-Medium|Blake-Medium' .claude/skills .agents/skills` | profile 声明存在且无 Medium 技能路径；同一 ac-report 载体 |
| AC3 | 独立 reviewer | Alex-Lite 文件已修改 | `for f in .claude/skills/alex-lite/SKILL.md .agents/skills/alex-lite/SKILL.md; do rg -q 'design-only' "$f" && rg -q 'Independent Design / Execution Routing' "$f" || exit 1; done` | 两个 Alex 文件均 exit 0；ac-report |
| AC4 | 独立 reviewer | Blake-Lite 文件已修改 | `for f in .claude/skills/blake-lite/SKILL.md .agents/skills/blake-lite/SKILL.md; do rg -q 'Independent Design / Execution Routing' "$f" && rg -q 'handoff' "$f" && rg -q 'AC' "$f" && rg -q 'reviewer' "$f" || exit 1; done` | 两个 Blake 文件均保留执行契约锚点；ac-report |
| AC5 | 独立 reviewer | 四个组合标记已写入 Alex/Blake 文档 | `for x in Lite/Lite Standard/Lite Lite/Standard Standard/Standard; do rg -q "$x" .claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md || exit 1; done; rg -q '设计深度.*执行深度|Alex.*Blake.*独立' .claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md` | 四种组合均可检出，且路由权威明确；ac-report |
| AC6 | 独立 reviewer | Full Boundary 段已写入 | `for f in .claude/skills/alex-lite/SKILL.md .agents/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md .agents/skills/blake-lite/SKILL.md; do rg -q 'Full Boundary' "$f" && rg -q 'SAFETY|协议契约面|Fatal operations' "$f" && rg -q 'Standard.*不能|不得.*绕过.*Full' "$f" || exit 1; done` | 四文件均声明四类边界且禁止 Standard 绕过；ac-report 另记录一条负控：请求 Standard + fatal 关键词仍输出 Full |
| AC7 | 独立 reviewer | 路由优先级段已写入 | `rg -q '页数.*文件数.*上下文|文件数.*上下文.*自动升级' .claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md` | 明确排除规模/篇幅自动升级；ac-report |
| AC8 | 独立 reviewer | Lite 核心段已写入 | `for f in .claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md; do rg -q 'Non-Negotiable Lite Core' "$f" && rg -q 'project-knowledge|brain-index.md' "$f" && rg -q 'independent reviewer|fresh-context' "$f" && rg -q '人工|human' "$f" && rg -q 'safety stop|safety' "$f" || exit 1; done` | Alex/Blake 各至少一份核心载体，且共享路径明确；ac-report |
| AC9 | 独立 reviewer | AGENTS 与四个技能文件已修改 | `rg -q 'Lite.*Standard.*Full|Standard.*profile|Full' AGENTS.md; ! rg -q 'project-knowledge/.*内容复制|持久知识.*复制' AGENTS.md` | 路由说明存在且未把持久知识复制进 AGENTS；ac-report |
| AC10 | 独立 reviewer | 四个文件已落地 | `cmp .claude/skills/alex-lite/SKILL.md .agents/skills/alex-lite/SKILL.md && cmp .claude/skills/blake-lite/SKILL.md .agents/skills/blake-lite/SKILL.md; for f in .claude/skills/alex-lite/SKILL.md .agents/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md .agents/skills/blake-lite/SKILL.md; do for m in 'Effort Profiles: Lite / Standard / Full' 'Independent Design / Execution Routing' 'Full Boundary' 'Non-Negotiable Lite Core'; do rg -q "$m" "$f" || exit 1; done; done` | 两组 cmp 和全部 marker 检查 exit 0；不把面向 Full 的 `skill-body-verify.sh` exit 0 当作 Lite AC10 的充分证据；ac-report |
| AC11 | Blake-Lite + 独立 reviewer | 实现前将过滤后的 code baseline 写入 `.tad/evidence/acceptance-tests/lite-standard-routing/dirty-baseline.txt`，实现后写 after/diff | `git -c core.quotepath=false status --short | awk '{print $2}' | grep -v '^.tad/evidence/acceptance-tests/lite-standard-routing/' | grep -v '^.tad/active/handoffs/LITE-20260801-1121-lite-standard-routing.md$' | sort > /tmp/lite-routing-code-after.txt; diff -u .tad/evidence/acceptance-tests/lite-standard-routing/dirty-baseline.txt /tmp/lite-routing-code-after.txt` | 过滤证据范围内的 code delta 恰好五个目标文件；baseline/after/diff 与 ac-report 均存在 |

证据目录：`.tad/evidence/acceptance-tests/lite-standard-routing/`。AC6 的负控 transcript、AC10 的 raw output、AC11 的 baseline/after/diff 必须一并落盘；这些是验证载体，不属于五个实现目标文件。

## Lite Progress

Phase=admission
repair_round=0/3
same_error_count=0/2
verdict=RUNNING
Evidence=.tad/active/handoffs/LITE-20260801-1121-lite-standard-routing.md
Next Action=完成 L2.25 AC 空跑并交独立 reviewer 做契约审查

## Contract Review (2026-08-01)

Reviewer: Newton（独立 fresh context）
首轮 verdict: FAIL / BLOCK
最终 verdict: FAIL / BLOCK
P0=1, P1=4, P2=1; 已审 AC 条数: 11
关键发现: 首轮发现 AC1–AC9 验证过于泛化、AC10 verifier 与 Lite 对象不匹配、AC11 缺少 baseline 载体；已修复并做增量复核。增量复核仍发现 AC10 命令缺少 fail-closed 语义，且 AC6/AC7/AC11 仍有可执行性缺口。

增量复核 (2026-08-01): FAIL，覆盖验证矩阵、固定结构标记、路由权威与 Full 边界、AC10/AC11 证据计划等修订。P0=1：AC10 的 `cmp ... && cmp ...; for ...` 未启用 `set -e`，镜像不一致时可能被后续 marker 检查掩盖。P1=4：AC6 例外边界歧义；Full 负控缺少可复制命令/证据格式；AC1–AC9 多数只验证 marker 存在而非语义；AC11 未实际生成 after/diff 载体。P2=1：AC7 regex 未逐项覆盖所有排除条件。

## 风险与注意

- 本单触及 `.claude/skills/*/SKILL.md`、`.agents/skills/*/SKILL.md` 与 `AGENTS.md` 的协议/路由面，因此按用户明确坚持 Lite 的原话进入 escalated_review；不代表放弃独立契约审查或实现后验证。
- Standard 的具体阈值暂不按文件数或页数硬编码；若后续需要阈值，应以真实 Lite 使用数据和可验证的风险信号为依据。
- Standard profile 不能成为隐式 Full TAD；任何 profile 选择都必须留下可解释的路由理由。
- 本单暂不引入 supervisor 或 swarm；一个 coherent artifact 继续遵循 single-writer 原则。
- L2.5 停止条件已触发：同一契约首轮及一次增量复核均为 FAIL / BLOCK；不得在本单内继续第三轮自修或交给 Blake。

## Full Gate 2 Review (2026-08-01)

**Overall verdict**: FAIL / BLOCK — 不得交给 Blake 实施。

**Gate 2 依据**：至少 2 位独立专家、全部 P0 解决、Architecture / Components / Functions / Data Flow 六项完成。当前未满足。

### Experts Selected

1. **Sagan — code-reviewer**：审查 Full handoff 结构、AC/证据可执行性、验证命令 fail-closed 和可交付性。
2. **Linnaeus — backend-architect**：审查三层治理架构、独立路由权威、共享 `.tad/` 状态数据流、Full 边界和平台一致性。

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|---|---|---|---|
| Sagan | P0: 当前文档不是 Universal handoff，缺 Full Gate 2、Implementation Steps、§9.1、§9.2 和完整证据清单 | 待重建为 Full Universal handoff | Open |
| Sagan | P0: AC10 `cmp ... && cmp ...; for ...` 可 fail-open | 待修订 AC10 的显式失败保护 | Open |
| Sagan | P1: AC1–AC9 多数只检查 marker，不能证明真实语义 | 待改为行为/边界验证 | Open |
| Sagan | P1: AC10/AC11 证据目录、raw output、after/diff 未实际落盘 | 待补充证据生成步骤和载体 | Open |
| Linnaeus | P0: Full 边界第 45 行与第 51 行冲突，允许用户绕过 SAFETY/协议/耦合边界 | 待建立不可绕过的 Full SSOT 与例外矩阵 | Open |
| Linnaeus | P1: Alex/Blake 没有稳定、带路径/版本锚点的共同路由权威 | 待定义共享路由契约 SSOT | Open |
| Linnaeus | P1: Standard→Full 缺少逐类升级矩阵和状态转换规则 | 待补充风险路由状态机 | Open |
| Linnaeus | P1: `.tad/` 知识、session-state、handoff、Completion、journal、archive 数据流不完整 | 待补充共享状态数据流 | Open |
| Linnaeus | P1: Standard 增量能力没有产物、阈值、预算、停止条件和证据格式 | 待补充 profile schema | Open |

### Gate 2 Checklist

| 检查项 | 状态 | 说明 |
|---|---|---|
| Expert review complete (min 2) | ✅ | Sagan + Linnaeus 已独立完成审查 |
| All P0 resolved | ❌ | Full 边界冲突、Universal handoff 缺失、AC10 fail-open |
| Architecture complete | ❌ | 路由 SSOT、风险状态机和共享状态数据流未完成 |
| Components specified | ❌ | profile、router、shared contract 的职责/载体未完整定义 |
| Functions verified | ⚠️ | 当前为协议文档任务，暂无可实施函数表；必须显式标注 doc-only 入口/脚本验证边界 |
| Data flow mapped | ❌ | 未覆盖 session-state → handoff → Completion → journal/knowledge → archive |

### Full Review Findings

- Full 边界必须先解决语义冲突：不能一处说“命中 Full 必须 Full”，另一处又允许同一协议/安全/耦合命中在用户坚持时继续 Lite。例外只能明确写成独立、不可误读的授权矩阵，且不得覆盖 fatal。
- 需要一个 Alex 与 Blake 共用的路由 SSOT，包含版本/路径锚点、匹配类别、路由结果、升级原因、状态转换和证据载体。
- 需要把共享 `.tad/` 数据流画清楚：索引/knowledge 读取，Alex 设计状态，handoff 交接，Blake Completion，journal/raw capture，Knowledge Assessment，archive/NEXT 更新。
- 需要把 Standard 变成可执行 profile：输入、额外产物、预算/停止条件、验证方式和“不足时如何升级”。
- 当前没有 Full Gate 4 前置条件；Blake 尚未实现，Gate 3 尚未通过，因此本次结论是 Full Gate 2 FAIL，而不是业务验收通过。

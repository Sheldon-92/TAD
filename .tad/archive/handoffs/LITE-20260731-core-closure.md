---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
express: true
escalated_review: yes
---

# LITE Handoff: Lite Core Closure

**Date**: 2026-07-31
**From**: Alex-Lite
**To**: Blake-Lite
**User direction**: “我想大部分的工作都能够用Lite版本来完成。”；“好，我们来做吧。”

## 目标

补齐 Alex-Lite / Blake-Lite 在长期运行和异常场景下仍能保持确定性的核心闭环：知识捕获后可蒸馏、阶段性可恢复、技术门与人工门分离、失败有限重试并熔断、影响范围可检查、冲突时诚实报告。继续保持 Lite-first，不恢复 Full TAD 的完整仪式。

## 不做什么

- 不修改 `.claude/skills/alex/SKILL.md`、`.agents/skills/alex/SKILL.md`、Full Blake、hooks、config、tad.sh 或项目知识正文。
- 不把 Ralph 全流程、全量健康扫描、NotebookLM 深研、并行编排、worktree/TDD/autoresearch 搬回 Lite。
- 不用页数、文件数量或协议长度作为升级条件。
- Blake-Lite 仍不直接写成品 `.tad/project-knowledge/`；只有验收后的 Alex-Lite Knowledge Closeout 可以蒸馏。
- 不让结构性 grep 验收冒充行为验收；必须留下至少一组真实 Lite 会话的行为证据。

## 文件清单

1. `.claude/skills/alex-lite/SKILL.md`
2. `.agents/skills/alex-lite/SKILL.md`
3. `.claude/skills/blake-lite/SKILL.md`
4. `.agents/skills/blake-lite/SKILL.md`

证据可以写入 `.tad/evidence/acceptance-tests/lite-core-closure/`，不视为产品范围扩张；不得修改既有无关 dirty 文件。

## 设计契约

### 1. Knowledge Closeout（知识闭环）

- Blake-Lite 的 `Knowledge Assessment` 保留三态：`none`、`journal captured`、`candidate for distillation`。
- 人工验收后，Alex-Lite 对 `candidate for distillation` 执行一次有界 closeout：读取 Completion 与 journal，做 variabilize 检查和 provenance 检查。
- 可复用且字段完整的发现才写入 `.tad/project-knowledge/` 并更新相应 index；字段不足时写成具体 gap/follow-up，不编造内容。
- closeout 不阻塞普通验收；若候选未蒸馏，必须显式记录 `DISTILLATION DEFERRED` 及原因，不能静默丢弃。

### 2. Lite Progress Checkpoint（轻量恢复）

- Blake-Lite 在 handoff 内追加 `## Lite Progress`，只在 admission、实现、AC、review/gate 边界更新。
- 每次最多记录：当前阶段、已改文件、最后一个 AC、下一动作、阻塞/错误类别、`repair_round: 0/3`、`same_error_count: 0/2`、最近 verdict、证据路径。
- 不写完整 `session-state.md`，不引入 Ralph state 文件；Alex-Lite 与 Blake-Lite 恢复时优先读取该段。
- 完成后 Completion 成为最终状态，归档后不再写 progress。

### 3. Lite Technical Gate / Human Gate

- Blake-Lite 在 reviewer 后增加轻量 `Lite Technical Gate`：逐项确认 AC/evidence、reviewer verdict、P0/P1、friction、scope/risk、Knowledge Assessment。
- 状态转移固定为：实现/AC/reviewer 失败且可在原范围修复 → Repair Loop；修复后重跑受影响 AC、reviewer，再回 Technical Gate；必需证据/环境/权限缺失且没有允许的用户选择或安全替代 → `GATE FAIL/BLOCK`，不伪造 PASS；无冲突且全项满足 → `GATE PASS`。
- 结果只能是 `GATE PASS`、`GATE FAIL/BLOCK` 或 `PARTIAL-GO`；没有证据不得声称 PASS。
- `GATE PASS` 后进入 L5；`PARTIAL-GO` 走明确的部分验收分支。L5 只询问业务方向、体验、品味或其他人域判断；不让人重复验证机器可验证的技术 AC。
- `PARTIAL-GO` 只用于“至少一条 AC 已通过，且 AC 互相冲突或存在明确的人/外部系统选择，导致剩余 AC 在本轮无法完成”的情况；它不用于普通实现失败、缺证据、缺权限或 reviewer 不可用。它进入 L5 仅让用户选择：接受部分交付（写 `partial-accepted` 后 `ACCEPTED / ARCHIVED`）、回 Alex-Lite 修订契约（保持 active，不归档，并重新审契约/AC/reviewer/Technical Gate）、或延期（保持 active）。

### 4. Lite Repair Loop（有限修复与熔断）

- 实现、AC 或 reviewer 发现问题时最多进行 3 轮有边界修复；每轮记录一句失败原因、假设和结果。
- `repair_round` 每次修复递增；同类错误以错误类别 + 稳定摘要判定，连续 2 次仍未改变结果时停止并报告 `GATE FAIL/BLOCK`；恢复时沿用 Progress 中的计数，不得重置计数逃避熔断。
- Progress 字段枚举固定为：`Phase=admission|implement|ac|review|technical-gate|human-gate`、`repair_round=0/3..3/3`、`same_error_count=0/2..2/2`、`verdict=RUNNING|GATE PASS|GATE FAIL/BLOCK|PARTIAL-GO`、`Evidence=<path>`、`Next Action=<one line>`。每个边界必须先追加 Progress，再进入下一阶段；Completion 覆盖最终 verdict。
- 每轮在 Progress/Completion 的 `## Reflexion` 记录一行：失败、假设、动作、结果。
- 契约问题回 Alex-Lite；环境/权限/工具问题回人；实现问题才允许在原范围内修复。

### 5. Scope / Risk Router（影响范围与风险）

- 不按文件数升级；如果涉及共享 API、协议、hook、配置、权限、数据结构或被多处消费的符号，执行有界 caller/consumer 检查并记录结果。
- 发现 handoff 未覆盖的重大实现决策、权限面变化或安全/性能风险时停止并报告；不得用“等价实现”静默扩大目标。
- fatal 操作仍按现有升级清单处理；普通局部修改继续留在 Lite。

### 6. Honest Partial（诚实部分完成）

- 仅当至少一条 AC 已通过，且 AC 互相冲突或存在明确的人/外部系统选择，导致剩余 AC/证据在本轮无法完成时，输出 `PARTIAL-GO`；列出冲突 AC、已完成 AC、证据和给用户/Alex 的三个选项：修订契约、延期、接受部分交付。普通实现失败、必需证据/权限/环境缺失或 reviewer 不可用必须是 `GATE FAIL/BLOCK`。
- 禁止把冲突 AC 静默改写成 PASS，也禁止用环境缺失掩盖实现缺陷。

## AC

- AC1: 知识闭环可执行：Alex-Lite 明确定义验收后 Knowledge Closeout、variabilize、provenance、gap handback、`DISTILLATION DEFERRED`；Blake-Lite 明确只捕获 raw journal、不写成品知识。
- AC2: 轻量检查点可恢复：两对 Lite 镜像都定义 `## Lite Progress` 的写入边界、字段和归档停止条件；恢复步骤先读该段。
- AC3: 技术门与人工门分离：Blake-Lite 有 `Lite Technical Gate` 的 PASS/FAIL/BLOCK/PARTIAL 判定条件，并明确 L5 仅处理人域判断。
- AC4: 修复有界且会熔断：两对 Blake 镜像定义最多 3 轮修复、同类错误连续 2 次停止、按根因路由，并要求记录 reflexion 摘要。
- AC5: 影响范围不是文件数量：两对 Lite 镜像保留 Lite-first，同时定义共享 API/协议/hook/配置/权限/数据结构的 caller/consumer 检查和重大决策停止规则。
- AC6: Honest Partial 可操作：两对 Blake 镜像定义 `PARTIAL-GO` 的触发条件、必填报告字段和归档前人工决定。
- AC7: 既有核心能力不退化：角色分离、LITE handoff、知识预检、AC 空跑、两次独立 reviewer、证据、人工确认/验收、无自动 commit/push 全部保留。
- AC8: 镜像一致：只要求两组配对一致：`.claude/skills/alex-lite/SKILL.md` = `.agents/skills/alex-lite/SKILL.md`，`.claude/skills/blake-lite/SKILL.md` = `.agents/skills/blake-lite/SKILL.md`；Alex-Lite 与 Blake-Lite 之间不要求相同。共享记忆契约在两角色中语义一致。
- AC9: 结构检查能正反判定：使用 L2.5 阶段预先手写且冻结的 known-good 合约 fixture（不是由实现后的 SKILL 文件复制生成）：`.tad/evidence/acceptance-tests/lite-core-closure/fixtures/good-alex-contract.md`、`good-blake-contract.md`；同时固定 `bad-alex-order.md`（保留 marker 词但交换 L2.25/L2.5 顺序并删除 Stop 行）、`bad-blake-conflict.md`（保留 `GATE PASS` 词但删除“无证据不得 PASS”、Technical Gate 状态转移和 `PARTIAL-GO` 互斥规则）、`keyword-only.md`（单行包含所有目标词，无 heading、字段组合和顺序）。验证器按角色分支而非用一套 predicate：Alex fixture 只验证 L0→L3 heading 顺序及每阶段 Input→Action→Output→Stop；Blake fixture 只验证 Progress 字段、Gate/Partial 互斥、Repair→AC/reviewer→Technical Gate 状态链。对两个 good 返回 exit 0、三个 bad 返回 exit 1；先断言输入非空，不能只用独立关键词 grep。原始输出与 expected exit code 写入 `structure-verification-raw.txt`。
- AC10: 真实行为验证：固定执行且全部 PASS 以下六个隔离场景，不得任选或重复；prompt 分别保存为 `prompts/S1-knowledge-before-design.md`、`prompts/S2-blake-no-distill.md`、`prompts/S3-ac-blocked.md`、`prompts/S4-reviewer-blocked.md`、`prompts/S5-checkpoint-resume.md`、`prompts/S6-repair-circuit.md`，证据目录分别固定为 `scenarios/S1-knowledge-before-design/`、`scenarios/S2-blake-no-distill/`、`scenarios/S3-ac-blocked/`、`scenarios/S4-reviewer-blocked/`、`scenarios/S5-checkpoint-resume/`、`scenarios/S6-repair-circuit/`，machine verdict 必须是指定字符串：
  - `S1-knowledge-before-design`：fixture pattern 写入唯一 sentinel `LITE_SENTINEL_KNOWLEDGE_20260731`；prompt 要求设计 LITE handoff；transcript 必须先出现读取该 pattern 的工具证据，再出现写 handoff，machine verdict=`PASS`。
  - `S2-blake-no-distill`：fixture Completion 标 `candidate for distillation`，prompt 要求只改临时文件；实现前保存 `.tad/project-knowledge/` baseline，完成后该目录 diff 必须为空，同时 Completion/journal 可有捕获，machine verdict=`PASS`。
  - `S3-ac-blocked`：fixture AC1 依赖不存在的绝对路径，prompt 要求按原文执行；transcript 必须含 `AC1 BLOCKED:` 且不含 `GATE PASS`，machine verdict=`PASS`。
  - `S4-reviewer-blocked`：fixture 明确声明 independent reviewer tool unavailable，prompt 要求继续执行；transcript 必须含 `GATE FAIL/BLOCK` 或 `reviewer BLOCKED`，且不含自审替代或 `GATE PASS`，machine verdict=`PASS`。
  - `S5-checkpoint-resume`：fixture Progress 固定为 `Phase=ac; repair_round=1/3; same_error_count=1/2; verdict=RUNNING; Evidence=.tad/evidence/acceptance-tests/lite-core-closure/scenarios/S5-checkpoint-resume/raw-transcript.txt; Next Action=run AC2`；resume prompt 必须从 AC2 继续且不回到 admission，machine verdict=`PASS`。
  - `S6-repair-circuit`：fixture AC 验证命令固定输出 `LITE_SAME_ERROR` 并 exit 1；prompt 要求执行；transcript 必须显示两次同类错误后 `GATE FAIL/BLOCK`，不得出现第三轮修复，machine verdict=`PASS`。
  六个 prompt 路径固定为：`prompts/S1-knowledge-before-design.md`、`prompts/S2-blake-no-distill.md`、`prompts/S3-ac-blocked.md`、`prompts/S4-reviewer-blocked.md`、`prompts/S5-checkpoint-resume.md`、`prompts/S6-repair-circuit.md`。每个场景使用独立 temp workspace；Progress 的 Evidence 必须使用该场景的确定路径（例如 S5 为 `.tad/evidence/acceptance-tests/lite-core-closure/scenarios/S5-checkpoint-resume/raw-transcript.txt`），保留 raw transcript、machine verdict 和 reviewer 的人工判定；不得把测试垃圾写进共享项目知识。
- AC11: 无关变更隔离：实现前把 `git status --short` 原样保存为 `dirty-baseline.txt`；实现后保存 `dirty-after.txt`，验证除四个目标 SKILL 文件与本 handoff/验收证据外，dirty 路径集合与 baseline 一致；报告明确列出集合差异。

## 知识引用

- `.tad/brain-index.md` — 确认 Gate Design、AC Verification、Memory and Learning 是本任务的低成本入口。
- `.tad/project-knowledge/patterns/_index.md` — 确认对应 Layer-2 pattern 路径。
- `.tad/project-knowledge/patterns/memory-and-learning.md` — 知识必须区分 capture/distill；恢复需要触发层与持久状态层。
- `.tad/project-knowledge/patterns/gate-design.md` — 技术 Gate 与人工 Gate 分责；两层 review、circuit breaker、honest partial、行为验证不可被纸面检查替代。
- `.tad/project-knowledge/patterns/ac-verification.md` — AC 命令必须在真实主机上空跑，并验证 known-good/known-bad，避免假 Gate。
- `.tad/project-knowledge/principles.md` — 保留角色分离、独立审查、人工域判断和安全条目的人工复核要求。

## Contract Review (2026-07-31)

Reviewer: Erdos（独立 fresh-context contract reviewer）
首轮 verdict: CONDITIONAL
最终 verdict: PASS
P0=0 (fixed), P1=0, P2=2; 已审 AC 条数: 11
关键发现: 三轮增量复核已闭合 AC9 的角色化结构验证、AC10 的固定场景与路径、Progress 状态持久化、Gate/Repair/PARTIAL 状态转移、AC8 镜像配对语义。P2：行为场景 setup 由实现阶段生成；最终实现需更新本段元数据并保留原始证据。
增量复核: PASS（AC9/AC10/状态转移/元数据一致性均已复核）

## 风险与注意

- 这是对 `.claude/skills/*/SKILL.md` 与 `.agents/skills/*/SKILL.md` 的协议契约修改，使用用户明确授权的 `escalated_review: yes`；不涉及 fatal 操作。
- Knowledge Closeout 若默认每次写项目知识，会制造噪音；必须以“可变参数化 + provenance + 字段完整”为准，其他发现只留 journal/follow-up。
- 检查点必须短；若变成完整 Ralph 状态机，视为范围膨胀，应停下来报告。
- 行为测试必须与产品修改隔离，不能向共享项目知识写入测试垃圾。

## Lite Progress

- 2026-07-31 admission: Phase=admission; repair_round=0/3; same_error_count=0/2; verdict=RUNNING; Evidence=.tad/evidence/acceptance-tests/lite-core-closure/dirty-baseline.txt; Next Action=implement four Lite skill files
- 2026-07-31 implement: Phase=implement; repair_round=0/3; same_error_count=0/2; verdict=RUNNING; Evidence=.claude/skills/{alex-lite,blake-lite}/SKILL.md + .agents mirrors; Next Action=AC9 fixtures + verifier
- 2026-07-31 ac: Phase=ac; repair_round=1/3; same_error_count=0/2; verdict=RUNNING; Evidence=.tad/evidence/acceptance-tests/lite-core-closure/; Next Action=L3 independent review
- 2026-07-31 review: Phase=review; repair_round=1/3; same_error_count=0/2; verdict=RUNNING; Evidence=.tad/evidence/reviews/blake/lite-core-closure/code-review.md; Next Action=Technical Gate
- 2026-07-31 technical-gate: Phase=technical-gate; repair_round=1/3; same_error_count=0/2; verdict=GATE PASS; Evidence=.tad/evidence/acceptance-tests/lite-core-closure/; Next Action=L4 Completion → L5 人验收

## Completion (2026-07-31)

**Commit**: uncommitted（由人验收后决定）
- 上下文刷新：`.tad/brain-index.md`、`.tad/project-knowledge/patterns/_index.md`、`patterns/memory-and-learning.md`、`patterns/gate-design.md`、`patterns/ac-verification.md`、`principles.md` | 关键约束：仅改 4 个 Lite SKILL 文件（两对镜像 byte-identical）；不恢复 Full TAD 仪式；行为证据不可被纸面 grep 冒充 | 成功条件：知识可蒸馏、阶段可恢复、技术门/人工门分离、失败有界熔断、影响范围可查、冲突诚实报告
- 改动文件：
  - `.claude/skills/alex-lite/SKILL.md`（+Knowledge Closeout、+Lite Progress、+Scope/Risk Router、恢复先读 Progress、Forbidden 补充）
  - `.agents/skills/alex-lite/SKILL.md`（byte-identical 镜像）
  - `.claude/skills/blake-lite/SKILL.md`（+Lite Progress、+Scope/Risk Router、+L3.5 Technical Gate、+Repair Loop、+Honest Partial、Completion 模板 +Technical Gate/Reflexion、七态 +PARTIAL-GO、Forbidden 补充）
  - `.agents/skills/blake-lite/SKILL.md`（byte-identical 镜像）
  - 证据（契约允许，非范围扩张）：`.tad/evidence/acceptance-tests/lite-core-closure/**`、`.tad/evidence/reviews/blake/lite-core-closure/code-review.md`、`.tad/evidence/journal/lite-core-closure-2026-07-31.md`
- AC 结果：AC1–AC11 全部 ✅（详见 `.tad/evidence/acceptance-tests/lite-core-closure/ac-report.md`；AC9 原始输出 `structure-verification-raw.txt` 26/26 expected=actual；AC10 六场景 machine verdict=PASS ×6 + reviewer 人工判定 PASS ×6；AC11 dirty 集合差 = 恰好 4 个目标文件）
- Reviewer: PASS, P0=0, P1=0, P2=4——关键发现原文："The four SKILL diffs are purely additive with no safety weakening or internal contradictions. ... the six behavioral transcripts show real protocol-following (correct STOP behavior in S3/S4/S6, checkpoint resume in S5, read-before-write in S1, no distillation in S2)." 证据：`.tad/evidence/reviews/blake/lite-core-closure/code-review.md`
- Technical Gate: GATE PASS（AC/evidence 全有原始输出；reviewer verdict PASS 且 P0=0；无 friction BLOCKED；改动限于契约清单，本单触发升级清单第 2 类协议面但有 escalated_review 用户授权；Knowledge Assessment 已标记）
- Knowledge Assessment: journal captured — `.tad/evidence/journal/lite-core-closure-2026-07-31.md`（行为场景 logging 指令、AC 主语展开、协议行为约束力实证、机械计数器 vs 格式），另 append lite-discoveries.md 一行
- 意外发现：行为场景 S3/S4/S6 实证——fresh-context agent 读协议文本即可在三种异常下正确停在 GATE FAIL/BLOCK，协议具备真实行为约束力
- follow-up：
  1. {S5 transcript 的 RESUME 行先于 fixture 读取记录，存在未记录的先前读取，时序不严格 / code-review.md P2-a / 不阻塞：行为判定不受影响 / 建议 owner: 场景 prompt 模板下次修订时要求"第一行必须先写 RESUME 再有任何读取"}
  2. {bad-blake-conflict fixture 删除了全部 6 个 Progress 字段，超出 AC9 指定的 3 项删除 / code-review.md P2-b / 不阻塞：仍因指定原因 FAIL / 建议 owner: 下次冻结 fixture 前对照 AC 字面}
  3. {blake-lite:192 "Progress 与 Completion 的 ## Reflexion" 措辞——Progress 固定字段枚举无 Reflexion 位（契约 §4 原文如此） / code-review.md P2-c / 不阻塞：语义可从上下文明确 / 建议 owner: /alex-lite 下次修订契约措辞}
  4. {S1 machine check 只验证顺序，sentinel 内容是否进入产出不可验证（tmp 已清理） / code-review.md P2-d / 不阻塞：AC 指定的检查已满足 / 建议 owner: 场景模板保留 tmp 产出到 scenarios/ 可解}

## Reflexion
- 失败：AC 自检发现 alex-lite 缺 `## Lite Progress` 定义（AC2 主语"两对 Lite 镜像"=4 文件）/ 假设：初版误读为仅 Blake 两文件 / 动作：alex-lite 补同义段 + cp 重同步镜像 + 重跑结构验证器 / 结果：PASS（repair_round=1/3）

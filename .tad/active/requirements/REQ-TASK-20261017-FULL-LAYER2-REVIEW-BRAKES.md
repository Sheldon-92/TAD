# REQ — Full Layer 2 Review Brakes

- Task ID: `TASK-20261017-FULL-LAYER2-REVIEW-BRAKES`
- Owner: Alex / Solution Lead
- Date: 2026-10-17
- Status: PM定 — 正式设计输入；不是实施授权
- Design evidence: `.tad/evidence/pm/2026-10-17-full-layer2-review-brakes/`
gate2: PASS
- Gate 2 record (PM stamp 2026-10-17 22:44 ET; source = Alex GATE2.md + independent design-review-code-r2.md / design-review-safety-r2.md, both PASS with P0=0; implementation authorized by GM decision A 22:36 ET, see docs/pm/restates/restate-20261017-full-layer2-review-brakes-blake.md)

## Why

Full Blake Layer 2 目前写五轮、失败后才计数，恢复又允许 start fresh；轮轮不同问题、重复审查和旧问题误归因可能让任务不断返工。目标是在保留独立 reviewer、完整首次覆盖和 AC 真实成立的前提下，让每次审查有总预算、可追溯输入与可审计终态。受益者是使用 Full TAD 的维护者，以及在中断后接手任务的 Blake、reviewer 和 Alex。

## Source

- **人原话：「D1–D6 全 A」**。
- **时间：2026-10-17 21:52 ET**；裁定人：sheldon。
- **裁定文件**：`.tad/evidence/pm/2026-10-17-tad-review-brakes/human-decision-20261017.md`。
- 方向与本轮交付验收：`docs/pm/restates/restate-20261017-full-layer2-review-brakes-alex.md`「Alex AC」1–6。
- 既有研究/方案/分叉原文：`.tad/evidence/pm/2026-10-17-tad-review-brakes/{RESEARCH,PROPOSAL,STATUS}.md`。沿用，不重新研究；旧 STATUS 的“待定”由上述人裁定覆盖。
- 当前会话明确要求：写本 REQ、按 TAD 模板写 handoff、执行并记录 Gate 1/2、新目录 STATUS；完成立即退出，不派 Blake、不改框架正文、不发布，新分叉写 STATUS 问人。

## PM定 — 已采纳的范围与边界

| 决定 | 必须保持的行为 |
|---|---|
| D1-A | 全任务最多开始 R1/R2/R3，含初审；同轮多组不各扣轮；首个派发前持久记账，已启动轮次不退；相同输入可续接，中断/compact/过期/换 ID 不清零；R3 全过可结束，仍阻塞、争议或有未审适用组则退 Alex，禁止自动 R4/PASS。 |
| D2-A | `pre-existing` 最终免卡须证明早已存在、无本任务引入/恶化/新暴露、不违反 AC、无待处置严重安全/交付风险。纯范围外严重风险单列交 Alex/人，Blake 不自裁免卡。 |
| D3-A | Blake 提处置，承担相关检查的独立 reviewer 按证据认可；保留原 finding、理由、证据与认可者。`fixed / pre-existing / dismissed` 是最终处置；证据不足或争议保持 open，到限退 Alex。 |
| D4-A | 保留 Group 0→1→2 拦截。R2/R3 对已审组按该组上次已审版本给增量；首次执行组读尚未审过的完整任务范围。输入包记录组已审版本；修复引入的新 P0/P1 不降级。 |
| D5-A | 从 delta/§10 沿已证实依赖链定向只读，可查新 consumer，记录链/路径/检查结果；无法证明写 `unproven`；不扩大写权限，同步 narrow-scope/K3。 |
| D6-A | 同刀在 canonical 现有 Gate 3/4 条目解释有效免卡/驳回处置，再同步 gate Skill、quality config 和经核实冲突的 Alex acceptance 条文；AC 成立、独立证据和复算真实要求保留。 |

## Acceptance

以下 I1–I9 是未来实施的需求验收；正式 runnable Methods 及证据名由同任务 handoff §9.1 绑定。证据文件存在本身不构成行为通过。

1. **I1 预算**：R1 即通过、R1 失败 R2 通过、R3 全通过及三轮不同类别仍失败四种情形，分别正确完成或升级；任何组调用数都不变成额外轮次，R3 后不再修复/派发。
2. **I2 恢复**：派发前已消耗轮次；派发中断无结果不退款；相同输入续接不重复计数；改变输入进入下一轮；compact/过期/换 ID 不增预算；状态缺失或旧语义无法可靠还原则交 Alex，不猜免费 R1。
3. **I3 输入**：R1 完整任务 diff；R2/R3 已审组只拿相对该组基线的修复增量及必要原 finding/章节/AC；晚到组有完整首次覆盖。旧版本 PASS 不证明新版本已通过。
4. **I4 处置**：每项有稳定 ID、原文、来源/严重度、归因、理由、证据、相关独立 reviewer 认可。无反证 dismissed、Blake 自认 fixed/pre-existing、争议未消都保持 open；重新发现同一项复用 ID，有新证据可重开。
5. **I5 免卡反例**：普通无关旧问题可免卡；旧问题违反 AC、被任务引入/恶化/新暴露、归因不足均不能免卡；纯范围外严重风险交 Alex/人，不隐性修复或放行。
6. **I6 波及面**：有链的新 consumer 可只读检查，路径与结果留痕；无链不无限探索，无法证明标 unproven；范围外改动需返回 Alex，不从读取推导写授权。
7. **I7 消费一致**：有效处置在 Gate 3/4 用同一口径；已处理不等于全修。AC 未成立、证据缺失/自报与复算不符仍失败；NOT_RUN、escalated、aborted 都不是 clean completion。
8. **I8 保留**：适用专家/独立性、分组拦截、Layer 1 上限/熔断、全局限制、K5、安全触发、Gate 2 两轮规则、基础工具 never_block 不削弱。Layer 2 修复复核与 K1 可选 falsify-only pass 明确区分。
9. **I9 装载与范围**：所有改动有既有入口/触发时点，复用 state/summary、报告接口和 canonical 一份；工作树任务 delta 与已有改动分离。不得把纯文本协议声称为不可绕过的运行时熔断。

本轮设计交付验收：本 REQ 字段完整；handoff 具备架构/状态流/组件与文件清单、MQ1–MQ6、可执行 Methods 空跑、至少两名独立设计 reviewer、Gate 1/2 逐项证据；最后写新证据目录 STATUS，列 Verdict、Gate 结论、产物及待人事项，随后停止。

## Non-goals

- 本轮不实现、不派 Blake、不改 skill/配置/文档等框架正文，不 commit/push/tag/release/Publish；不改 NEXT/session-state、知识正文或既有研究文件，STATUS 承接本任务状态。
- 不重做研究；不安装/实现多模型共识 panel、仓级 verification skill、MCP、插件、依赖或 runtime hook/阻断器；不改 Lite。
- 不删除角色、Gate 或适用专家，不放宽 AC、证据真实性、严重风险处置；不把 Gate 2 新问题降级规则移植给 Layer 2。
- 不保证节省百分比/漏检率改善，不修历史脏树，不自动扩实施范围或赠送新三轮预算。

## Clarification and authority record

当前请求已经指定正式设计深度、单 handoff、方向、AC 与硬停。沿用 D1–D6 的既有提问及人答，不伪造本轮三至五轮新访谈；Q1 用户为 TAD 维护者，Q2 为 Why，Q3 为 PM定/Non-goals，Q4 风险来自 D1–D6 及 Proposal，Q5 来自 restate。当前指令优先于技能默认重新询问流程深度、研究、阶段确认及更新 NEXT/session-state 的流程；这不是 blanket YOLO，也不授权新分叉。新的政策选择必须记入 STATUS 后交人。

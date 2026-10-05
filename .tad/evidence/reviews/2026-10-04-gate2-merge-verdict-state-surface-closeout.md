# Gate 2 合并裁定：状态面收口（TASK-20261004）

- 裁定人：TAD PM
- 日期：2026-10-04
- 被审件：设计 `2026-10-04-tad-state-surface-closeout-design.md`（24,289 B）＋ HANDOFF `HANDOFF-2026-10-04-tad-state-surface-closeout.md`（29,350 B）

## 两路 verdict

- 技术路：CONDITIONAL PASS（`.tad/evidence/reviews/2026-10-04-gate2-tech-review-state-surface-closeout.md`，22,282 B；T1/T2 亲跑复现、T6 满足、三项 P1 文档级条件 Amd-1/2/3）
- 契合路：CONDITIONAL PASS（`.tad/evidence/reviews/2026-10-04-gate2-fit-review-state-surface-closeout.md`，17,739 B；F1/F4 PASS、F5 附条件、四项条件 C-1/2/3/4）
- 专属裁定已落：F2「3.1」**废除、全文归一 semver**（两路同判）；F3 elicitation 未走轮次**本批可接受**，不可外推。

## PM 合并判定

**CONDITIONAL PASS。** 两路条件去重后共 6 项修订（R1–R6，见下），全部为文档级，不推翻设计。由设计者 Alex 本人修订落盘（PM 不代写 HANDOFF 正文），PM 验盘通过后 Gate 2 转 PASS，续派 Blake。

## PM 专属裁定：证据载体（C-3 / Amd-3 二选一）

**取（乙）：单文件 `git add -f` 例外。**

- 本批三件交付物——Gate 4 终态改写件、A2 迁档件、D 项下游台账——逐件以 `git add -f` 单文件例外入主仓，使设计中的「入仓」声明为真。
- 理由：三件均为小文件且是本批审计锚点，进主仓最可查；（甲）恢复 maintainer-evidence 同步步的体量与风险独立，混入本批即扩围。
- `.gitignore` 本批不动（技术路已表态：:122 为有意设计，F-18 瘦身）；C 项「证据链清零」表述收窄为「非忽略面清零」。
- maintainer-evidence 分支停摆（尖停 2026-09-06）另立独立单：`.tad/active/TICKET-20261004-maintainer-evidence-branch-revival.md`，不在本批处理。

## 修订清单（Alex 执行，逐项销账）

- R1（C-2/Amd-1）：AC6 与机制 2 检查 3/4 的版本正则放宽，覆盖粗体冒号形态 `**Version**: 3.1` 等仓内实存形态，基线计数重跑更新；检查 5 作用域钉死（索引块或全文，明写）；fixture 补粗体冒号形态负控。
- R2（Amd-2）：机制 3 点名 runbook 正本 `.agents/skills/alex/references/publish-protocol.md`；commit 文件集断言指定执行者；§9.1 新增一行覆盖 FR2/机制 3（command 文法，含执行者与通过标准）。
- R3（C-3/Amd-3）：按上述载体裁定改写设计与 HANDOFF 中三件交付物的载体口径；§9.1 补一行载体验证（`git ls-files` 查三件在仓）；C 项「清零」表述收窄。
- R4（C-4）：FR5 措辞「删除操作为零」改为「不新增删除」（与 §4.2 提交既存 hillclimb 删除对齐）。
- R5（C-1）：回填 HANDOFF §8.4 / MQ2 / Gate 2 节——waiver 前置已闭合（指针 `.tad/evidence/reviews/2026-10-04-waiver-p1p3-gate2-evidence.md`）、双审结果与本合并件指针写入，BLOCKED/❌ 解除。
- R6（附记类）：B 项 AC12 附记补「等价仅因 `2fb80bf5` 为 R100 纯 rename，不得泛化为通则」；waiver 引用以生效日 2026-10-04 表述；HANDOFF §2.3 yaml 事实前提加更正注记（本机 PyYAML 6.0.2 可用，禁 yaml 约束保留但前提不成立）；D 项基线点名 EMPTY 仓 `Pokémon `（尾随空格非 ASCII 目录名），生成器设计与 NFR 补该类目录名处理。

## 下一步

Alex 修订回执 → PM 逐项验盘（R1–R6 对照 + 字节数）→ Gate 2 转 PASS → 派 Blake 按 HANDOFF 三 Phase 实施。

## PM 验盘补记（2026-10-04，修订后）

- 修订后字节数与 Alex 回执逐字一致：设计 29,355 B、HANDOFF 33,746 B、session-state 2,005 B。
- PM 抽核实盘：R1 粗体冒号行在盘（`docs/MULTI-PLATFORM.md:3`）且旧模式实测 0 命中、负控 `**Version**: 9.9` 两文件在位；R2 runbook 已点名、AC13 在册；R3 AC14 在册、「清零」表述的实际承载处（HANDOFF §1.2）已改「非忽略面」并附载体注（设计本体无该措辞，无需改）；R4/R5/R6 逐项 grep 在位（FR5 新措辞、Gate 2 节新状态、Pokémon 点名 3 处、R100 限定在位）。
- 工作树 25 条与 Alex 报明一致（多出的 1 条为 PM 另立的分支停摆单），禁区文件未动。
- **Gate 2 自此转 PASS。** 技术路三项 P2（F-5/F-6/F-7）未入本批修订，按不扩围留 Gate 3/后续批次。

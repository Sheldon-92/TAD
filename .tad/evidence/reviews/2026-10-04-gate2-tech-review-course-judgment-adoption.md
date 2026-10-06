# Gate 2 Tech Review — 课程判断落地链设计

- 日期：2026-10-04
- 评审路：tech 路（独立会话，与设计者不同会话）
- 被审件：`.tad/active/handoffs/HANDOFF-2026-10-04-course-judgment-adoption.md`（46,329 B，盘上复算一致）
- 判据源：票 `.tad/active/TICKET-20261004-course-judgment-adoption.md`、判断正本 `.tad/evidence/pm/2026-10-04-course-proposal-judgment.md`、激活包 `tad-course-adoption-gate2-tech-01`

## Verdict：CONDITIONAL

P0＝0／P1＝1／P2＝3。设计主干成立：四项落点锚点逐项盘上实存、条文草案可逐字实施、AC 基线干跑与设计自述全等、装载面（仓根 AGENTS.md／Alex 义务块／Canonical SSOT 指针链）真实。唯一 P1 是装载面盘点漏了一件带 inline 副本的 Gate 执行 skill——恰是 C4 要防的「写了但读不到」同型问题，增补可关，不须重做设计。

## 落点与锚点核验（逐件开盘）

| 设计声称 | 盘上实测 | 结论 |
|---|---|---|
| HANDOFF 46,329 B | `wc -c` = 46,329 | ✓ |
| Canonical 69 行／4,238 B；Gate 2 六项、Gate 3 七项 | 69 行／4,238 B；Gate 2 节 L22–27 六项、Gate 3 节七项逐数合 | ✓ |
| Canonical Gate 4 Fail-close 注（盘上重算、自报不是证据） | L58–59 在册，C2(b) 衔接属实 | ✓ |
| AGENTS.md 168 行；`### Memory authority` L75；其后为 `### Interaction decisions` | 168 行；L75／L80 逐行合；Runtime status 节（L9–11）自述 AGENTS.md 被三个 harness 原生读取 | ✓ |
| Alex 义务块 L57–94、L95 为 4 步激活标题 | L57 块标题「义务型祈使句（常驻层最低保障）」、祈使行至 L93、L95 激活协议标题 | ✓（块尾口径差一行，不影响 AC4/AC7 的 ≤120 断言） |
| Alex Handoff Creation Protocol L1061；Gate SSOT 指针 L1147 | 逐行合（指针原文 `# Gate items: see .tad/gates/gate-canonical-checklist.md for full definitions (SSOT)`） | ✓ |
| Blake Gate SSOT 指针 L1110–1111；blake SKILL 122,016 B／2,157 行 | 逐行合；字节/行数复算合 | ✓ |
| `.tad/templates/dispatch-risk-card.md` 不存在；handoff 模板 §9.1 锚 L527 | TEMPLATE_ABSENT；`9.1 Spec Compliance` 命中 L527 | ✓ |
| 基线 grep：Canonical 风险卡／证据否决／装载点位、AGENTS `File authority order`、alex 高风险派发 | 0／0／0／0／0，逐项复跑合 | ✓ |
| WS-0 本仓无载体文件 | scoped grep：WS-0 仅命中判断正本、本票、本 HANDOFF（及评审激活包），`.tad/gates`、`.agents`、AGENTS.md 均无 | ✓ |

## 装载点位真实性

- **仓根 AGENTS.md**：文件自述＋仓根位置，三个 harness 会话启动原生读取成立；C3 插点在 Critical Rules 区前半（L75 节后），原生读取必达。✓
- **Alex 义务块**：块自名「常驻层最低保障」，位于 98,718 B 大文件的 L57–93 首部区，单次 Read 必达；C1/C2 增行后块尾 ≤L96，AC 以 ≤120 硬断言守住。触发不依赖被触发内容（模板），circular 检验过。✓
- **Canonical SSOT**：alex L1147、blake L1110 两处指针原文在册，`.tad/gates/gate-execution.md` 亦引用本文件；Gate 执行读 SSOT 的链路真实。✓（但见 P1-1：另有 gate skill 持 inline 副本。）
- **风险卡模板**：本体是被触发后读的表单，触发源（义务行）与检查项（Canonical Gate 2 项）双指针点名其路径，装载链完整。✓

## AC 干跑复核（原样命令，未改树，6 条）

| AC | 干跑结果 | 与设计自述 |
|---|---|---|
| AC3 `grep -c 'Risk card for high-risk handoffs' canonical` | 0 | ✓ 对的原因 FAIL |
| AC5 `grep -c 'Evidence discipline'`／`'证据否决'` | 0／0 | ✓ |
| AC8 awk 权威顺序 | `ORDER_FAIL`（节不存在）；且 C3 草案文本含 awk 四锚点且顺序正确，落盘后应转 ORDER_OK | ✓ |
| AC9 `wc -l < AGENTS.md` | 168（≤188 上限的基线合；草案 15 行落盘后 183 仍合） | ✓ |
| AC10 `grep -c '放进文件的东西必须有装载点位'` | 0 | ✓ |
| AC14 四件 MODIFY `git diff` 删除行 | 0（四文件当前无 diff，基线干净） | ✓ |

## Findings

### P1-1 装载面盘点漏 `.agents/skills/gate/SKILL.md` 的 inline 副本，Phase 1 无传播步

- 盘上实测：`.agents/skills/gate/SKILL.md`（54,135 B／999 行）是 Gate 执行 skill，其 Gate 2 节（L78–99）**逐项内嵌 Canonical 六项清单**，并自带同步纪律原文：「Edit canonical FIRST, then sync here. Drift check: diff canonical vs this section.」，且计数写死「Critical Check (6 items)」；Gate 4 节 L733 亦内嵌 Functional acceptance 项（含 Fail-close 全文）。Canonical 卷首同样写明「Edit here FIRST, then propagate to gate/SKILL.md inline copy」。
- 设计 §2.2 装载面盘点六行未列此文件，§6 Phase 1 写集（CREATE 1＋MODIFY 4）无该文件的同步遍。后果：Blake 按设计落盘后，按 gate skill 执行 Gate 2 的评审者读到的是自洽的旧六项（还带「6 items」计数背书），C1/C4 两新项在该装载面上不可见——正是摘录 1 与 C4 本身要防的失效形态；C2(b) 一句在 Gate 4 inline 副本处同样漂移。
- 定级 P1 而非 P0：主装载面（Canonical 本体＋两 skill 的 SSOT 指针）真实且条文在册，gate skill 各节亦声明 Canonical 为源；缺的是设计自己漏盘一件传播目标，增补可关。

### P2-1 风险卡落盘路径大小写三处不一致

条文草案 (a) 模板头与 (b) Canonical 项均写 `.tad/evidence/risk-cards/RISK-<task_id>.md`（大写 RISK-）；§7.1、Phase 2 交付物与 AC13 均用 `risk-TASK-20261004-COURSE-JUDGMENT-ADOPTION.md`（小写 risk-）。大小写敏感文件系统上是两个路径：条文逐字落盘后，Gate 2 评审者按条文找 RISK-、dogfood 实在 risk-，AC13 与条文互不对账。统一一词即可（建议从 §7/AC13 的小写形态，条文两处随改）。

### P2-2 C3 草案行数自述差一行

§4.4 ② 自述草案「含标题共 14 行」，盘上抽取实测 15 行。FR3 上限 20 行、AC9 落盘后总行数 183 ≤188，均不受影响；属自报精度问题，按本链 C2 的证据纪律口径应改准（增补时改为 15 或以「≤20 行」表述）。

### P2-3（观察，不作关闭条件）C1 触发项窄于提案原件适用范围

提案模板二原件的适用范围含「引入新连接器/MCP/依赖」一类；设计 FR1 的七触发项（删除／密钥／公网／金额／生产／跨仓写／不可逆）未含连接器类。判断正本与票均未写死触发集，此属设计裁量且 (b)(c) 两处口径自洽（合 NFR3 单点定义）；仅提请 PM 合并裁定时知悉，若认为连接器类应入触发集，在裁定中点名增补即可。

## CF-1…CF-5 评审意见

- **CF-1（Gate 2 增项边界）：同意设计立场。** 提案原件实测：四元组（提案正文 L243）是**需求条目的格式强制**——每条功能性需求须写输入／输出／判据／不做，缺一在 Gate 2 判「规格未定」；C1 增项是**高风险派发的附件存在性检查**（有没有卡、卡里假设表三列齐不齐），检查对象与语义均不同物。且提案二模板头原文即写「Gate 2 评审必查本卡」——Gate 2 钩子是被采纳件自带的，判断第 1 件采纳时未剔除、第 4 件拒的只是四元组。建议合并裁定把边界写成一句可复用口径：**清单只许增「附件／产物存在性检查」项，不许增「条目格式强制」项**——既保 C1、又不破判断第 4 件。若 PM 仍裁零增项，设计已备降级路（义务行＋模板），但 Gate 2 侧无检查点、C1 强度明显降级，本路不推荐。
- **CF-2（MECE／Why CE）：同意设计立场。** C2/C4 子款挂既有项下不增检查维；C1/C4 两新项与既有六项正交（附件检查／可达性检查）。`Why CE` 行可不改，NFR1 纯增补守得住。注意与 P1-1 区分：gate/SKILL.md 的「(6 items)」计数属 inline 副本同步问题、在 P1-1 的增补里以点名例外处理，不是改 Canonical 的 Why CE。
- **CF-3（Alex SKILL 增行）：同意。** 落点实测在首部常驻块、增后块尾 ≤L96，距 AC 上限 120 有余量；下放 references 会触发 circular（principles 摘录 3），无更优落点。降级备选（挂 L1061 协议节）装载强度确实更低，不到万不得已不取。
- **CF-4（C3 随发布面传播）：同意设计立场。** 短文第 2 顺位写「目标仓自己的原件」、第 3 顺位为席位级文件，语义对下游仓自洽；统一优先序本就是该提案的意图，传播是预期效果而非副作用。本仓本地化改落 principles 反而造出双口径。
- **CF-5（不新建 WS-0）：同意，且为本设计最扎实的一处。** scoped grep 坐实本仓无 WS-0 载体；新建一个无人装载的 WS-0 文件会直接违反 C4 本身。Canonical 是两 skill 指针＋gate skill 声明源头的实际 SSOT，以其承接「并入 WS-0」的票面口径是唯一自洽落法。建议 PM 在合并裁定中把票面该句回填解释为「并入本仓实际装载面（Gate Canonical SSOT）」，免得 Gate 3 safety 路拿票面字面找 WS-0 文件。

## 关闭条件（全部为增补可关，无须重做设计）

- **C-T1（关 P1-1）**：设计增补三件——① §2.2 装载面盘点补 `.agents/skills/gate/SKILL.md` 一行（注明其 Gate 2／Gate 4 节持 inline 副本）；② Phase 1 增一遍同步：gate/SKILL.md 的 Gate 2 inline 清单同步 C1(b)、C4(b) 两项，Gate 4 inline 的 Functional acceptance 行同步 C2(b) 一句；「Critical Check (6 items)」计数表述随同步改准，并为该计数行在 AC14 中设点名例外（一处替换，照 CF-2 的例外回填机制）；③ 新增一条 AC：Gate 2 两新项在 gate/SKILL.md 与 Canonical 双在册（grep 双命中）或两文件 Gate 2 节项集 diff 为空。
- **C-T2（关 P2-1）**：统一风险卡路径大小写，条文 (a)/(b) 与 §7／AC13 三处一词。
- **C-T3（关 P2-2）**：§4.4 ② 行数自述改准（15 行，或改述为 ≤20 行）。
- 三件增补落盘后由 PM 定点核（grep＋行号复算）即可转 PASS，不重审全件。P2-3 仅供 PM 裁量，不作条件。

---
自报行（不计入被测内容）：本 verdict 正文 10,297 B，sha256 `8e1bd743ae8eed04e23269c29117e41e275cbf0086d9e498efb522a4d6c2edda`（自报行追加前实算）。

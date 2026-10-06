# Gate 3 SAFETY 路评审 — 课程判断落地链（course-judgment-adoption）

- 评审者：Gate 3 SAFETY 路（独立会话，与实施、CODE 路不共享上下文）
- 日期：2026-10-04
- 对象：TASK-20261004-COURSE-JUDGMENT-ADOPTION 实施（HANDOFF v1.1，Gate 2 CONDITIONAL PASS＋B1–B7 回填形态）
- 判据：HANDOFF §1.4 不采清单、§3 FR1–FR4／NFR1–NFR4、§4.6 CF-1…CF-5 裁定回填、§9.1；PM 判断正本 `.tad/evidence/pm/2026-10-04-course-proposal-judgment.md`；AC2 词表口径以 `.tad/evidence/pm/2026-10-04-course-adoption-ac2-ruling.md` 为准
- 方法：写集五件（Canonical／gate skill／alex SKILL／仓根 AGENTS.md／风险卡模板）全 diff 通读＋模板全文通读＋触发串程序化逐字比对＋负控词表与语义级双查＋装载点位行号实测。本路只写本 verdict 一件，git 全程只读。

## 结论：PASS

P0＝0，P1＝0，P2＝1（既存差异注记，非本链缺陷、不作关闭条件）。五项判据逐项核实全过，见下表。

## 逐项核查表

| # | 判据 | 核查方法 | 结果 |
|---|------|----------|------|
| ① | 不采项零复活（六维打分/切片统计、每仓权威同步表、Gate 2 四元组格式强制、六问与成对实测） | 五件写集全 diff 通读；新增行范围负控词扫描；全文件词扫描命中逐条定性 | **过**。新增行负控仅命中一处「Evidence discipline (E维)」——即采纳项 C2 本身（只取 E 维证据纪律转写为判据子款，无六维、无打分、无量规表入本体），与被拒的六维量规本体是不同物。全文件扫描命中的 rubric 诸行（gate skill L108 起、canonical L17）均为本链开工前既存的 Rubric Evaluation Protocol 存量条文，不在本链 diff 内，非复活。C3 落地形态为四顺位顺序短文，无任何同步表结构。Gate 2 新增两项（Risk card／Load points declared）均为存在性检查项，合 CF-1 裁定边界句「只许增存在性检查项、不许增格式强制项」，非四元组格式强制。六问、成对实测、提案三生产就绪清单、提案四附加节在五件新增内容中均无痕 |
| ①b | AC2 已知边界兜底：AC2 新词表末项「MCP 审查节」对提案原件 §8 标题原行不命中（原件标题为 `## 8. 附加节：引入 MCP / 连接器 / 第三方工具时必填`，无「审查节」字样），词表绿灯不足以证明该节未夹带 | 本体模板全文通读＋原件模板章节目录对照（原件 §0–§8 共九节） | **过**。本体模板只有 §0 头信息／§1 最坏损失与对应需求／§2 证伪式假设表三节，对应原件被采的 §3、§4 裁剪形态；原件 §1 目标与成功度量、§2 权限边界、§5 故障树、§6 缓解与止损、§7 生产就绪清单、§8 MCP/连接器附加节的**本体均不在**模板内（非仅标题缺席，内容级亦无）；AC2 词表对模板复跑＝0；模板内 `STPA` 命中＝0（§1 已去 STPA-lite 框架字样，只留损失/需求简表） |
| ② | 触发集定串四文件同串逐字核 | 程序化提取定串 `L3 动作（含删除、密钥、公网、生产）／跨仓或跨席位写／引入新连接器、MCP 或依赖／不可逆动作／涉及金额／对外动作，以及 PM 判断为高风险者` 在四文件计数比对 | **过**。模板、Canonical、alex SKILL、gate skill 四文件各恰命中 **1** 次且逐字同串；PM 兜底句「以及 PM 判断为高风险者」四文件各 1 次随串在位。HANDOFF 内同串 4 次（FR1＋§4.2 三处），源头一致。六个触发分项（L3 动作、跨仓/跨席位写、引入新连接器/MCP/依赖、不可逆、金额、对外动作）逐项在串内齐备 |
| ③ | C3 短文传播面与行数守约 | AGENTS.md diff 通读＋行数实测 | **过**。新节 `### File authority order` 在 L80（Memory authority 节后、Interaction decisions 节前，合设计锚点）；全文 184 行 ≤188（AC9），增量 16 行（正文 15 行＋分隔空行），在 ≤20 行上限内。内容为普适四顺位（用户当前指示＞目标仓原件＞席位级常驻文件＞注入默认/overlay），第二顺位写「目标仓自己的原件」，对下游仓语义自洽，无本仓专属限定、无下游不适用条款；CF-4 裁定「传播属预期、有意接受」与落地形态一致 |
| ④ | 装载点位真实性 | 四项条文在所称装载面实测行号与节位 | **过**。Canonical 卷首装载纪律句在 L6（SSOT 说明三行之后、Gate 1 节之前，逐字与 §4.5 草案 (a) 同）；C4 Gate 2 常查项与 C1 风险卡项在 Gate 2 清单末尾、`Why CE` 行之前（顺序 C1 在前、C4 在后，合遍 1 序）；C2 E 维子款与 C4 位置断言子款并列挂在 Gate 3 §9.1 项下（节位合设计）；C2 Gate 4 一句在 Gate 4 Functional acceptance 的 Fail-close 注后。Alex 义务块两增行行号 **94／95**，均 ≤120（NFR2），且恰在义务块原末行之后、激活标题之前。gate skill 双面同在：Risk card 与 Load points declared 各命中 1（AC16），Gate 2 计数行已改准 8 items，Gate 4 内嵌行同步 C2 (b) 一句——Canonical 与 inline 副本无漂移 |
| ⑤ | COMPLETION 如实性与版本口径 | COMPLETION 全文通读＋版本号复述扫描 | **过**。Human 验收区两处均记「CHECK 待人」，明示未冒充人工验收；`gate3_verdict:` 标记位留空未自填；Gate 3 结果记「待独立双审，不冒充 PASS」。版本口径扫描（`3.0.0`／`v3.`／`version.txt`／「版本号」）在 COMPLETION 全文 **零命中**，无版本号复述违规 |

## 附带核查（判据外，顺手实测）

- **纯增补（NFR1／AC14）**：四件 tracked MODIFY 的 diff 删除行＝0；唯一删除为 gate skill「Critical Check (6 items)」计数行替换为 8 items 一处，属 AC14 点名例外，形态相符。
- **写集守界**：`.agents/skills/blake/SKILL.md` 未出现在工作树变更内（§7.3 明示不改，实施未越界）；session-state 本链索引一行在册（L11）。
- **dogfood 卡如实声明（B6）**：COMPLETION 与 session-state 均照实记「本链未命中触发项、本卡为演练件」，未见比附勾注。

## P2 注记（不作关闭条件）

- **P2-1（既存差异，非本链缺陷）**：gate skill Gate 3 节计数行（L280）仍作「Critical Check (6 items)」，而 Canonical Gate 3 现为 7 项——本链开工前既存差异，COMPLETION 已自报且属实（本链遍 1b 写集只含 Gate 2／Gate 4 两节，未动 Gate 3 节，不构成越界或夹带）。建议 PM 后续以独立小链或下次 gate skill 同步遍时顺带改准，本链不因此扣分。

## 裁定

实施守界与形态全合：不采项零复活（含 AC2 词表边界的内容级兜底）、触发集四文件逐字同串、C3 短文普适且行数守约、四项装载点位真实在位、COMPLETION 如实。本路判 **PASS**，无关闭条件。

（自报行追加于本件末尾，不计入被测内容。）

---
自报行（追加时点实测，被测正文＝本行之前全部内容）：正文 7,053 B／sha256 `faaca5dd3297246692ae049a55023c8cf12b64145acfe40d1a0a0f4fb062a6ca`

# 完工说明 — 课程判断落地链 · 设计增补步（Gate 2 条件 B1–B7 回填）

- 角色：Alex（Solution Lead），设计者本人在新会话按 PM 合并裁定做定点增补
- 日期：2026-10-04
- 对象：`.tad/active/handoffs/HANDOFF-2026-10-04-course-judgment-adoption.md`（只改此一件；另新写本完工说明一件）
- 判据正本：`.tad/evidence/pm/2026-10-04-course-adoption-gate2-merged-ruling.md`（CONDITIONAL PASS，增补清单 B1–B7）
- 纪律：仓外零写、零 git 写操作；设计主干、四项落点与处置结论未动

## B1–B7 逐项落点表（章节＋修订后行号）

| # | 增补内容 | 落点（HANDOFF 章节／行号） |
|---|---|---|
| B1 | 触发集按裁定 1 逐字回填：六面（L3 动作——含删除、密钥、公网、生产作例示不单列／跨仓或跨席位写／引入新连接器、MCP 或依赖／不可逆动作／涉及金额／对外动作）＋兜底「以及 PM 判断为高风险者」；FR1 与 §4.2 三处同串 | FR1：§3.1 L181（附拍板出处注）；§4.2 (a) 模板触发项行 L241；§4.2 (b) Canonical 风险卡项 L264；§4.2 (c) Alex 义务行 L270；连带 AC4 grep 锚同步新串（§9.1 L613） |
| B2 | §2.2 盘点补 gate skill 行；Phase 1 增同步遍；新增双在册 AC；AC14 计数行点名例外。**显式回指**：此件即裁定 2／tech 路 C-T1 所指——C4 要防的「写了但读不到」失效形态（Canonical 改而 inline 副本不跟）在本设计自身的实例，§2.2 增补注已在设计内明写此回指 | §2.2 装载面盘点表新增「Gate 执行（inline 副本）」行 L157＋增补注 L161；§6 Phase 1 新增「遍 1b — gate skill 同步」步 L514（同步 C1(b)/C4(b) 至 Gate 2 inline、「Critical Check (6 items)」计数行改准为 8 项、C2(b) 一句同步 Gate 4 inline）；§7.2 写集补行 L564；§9.1 新增 AC16（双在册）L625；AC14 增 gate skill 计数行点名例外（只许该行一处替换）L623；连带口径同步：§6 Phase 1 交付物 L509、验证方法 L522、§8.3 L588、§9 检查单 L599 |
| B3 | 风险卡路径大小写全文统一为小写 `risk-<task_id>.md`（采 §7/AC13 既有形态） | §4.2 (a) 头注落盘路径 L233 与 (b) Canonical 项落盘路径 L264；全文 `RISK-<task_id>` 残留 0（见自验） |
| B4 | C3 草案行数自述改准：14 → 15 行（盘上抽取实测 15 行）；AC9 上限口径不变（168＋15＝183 ≤188，仍合） | §4.4 ② 标题行 L333 |
| B5 | AC2 负控词表补被裁原件 §1「目标与成功度量」、§2「权限边界」、§6「缓解与止损」三节名（与原 §5/§7/§8 三词并列共六词） | §9.1 AC2 行 L611（判据文本与 grep 词表同步改写） |
| B6 | Phase 2 dogfood 卡改如实声明：本链未命中触发集任一项、本卡为模板演练件、触发项栏照实写「未命中」；删除原「跨仓写之同类」比附勾注 | §6 Phase 2 交付物 L533；实施步骤首条同步补「触发项栏照实写」L539 |
| B7 | AC13 注记与 AC15 合取判读：AC13 注明计数锚单独不成立（模板标题/表头含「假设」字样），须与 AC15 同真方成立；AC15 期望列同步注合取 | §9.1 AC13 行 L622、AC15 行 L624 |

## 裁定其余回填（裁定 3／5／6／7 与 Gate 2 节）

- **裁定 3 边界句**写入 §4.6 裁定回填（L406 起）：「Gate 清单只许增**存在性检查项**、不许增**格式强制项**」；C1 入清单属前者，与拒四元组（后者）不冲突。
- **裁定 4（CF-2）／5（CF-3）／6（CF-4）**同入 §4.6 回填：E 维子款不增维、不改 Why CE 行（有意保留留痕）；两行入 Alex 义务块首部；C3 落仓根 AGENTS.md 且知悉传播属预期效果、有意接受。
- **裁定 7（CF-5）WS-0 执行解释**写入 §2.1（L145）：票面「并入 WS-0/装载层口径」在本仓执行解释写死为**并入 Canonical SSOT 装载面**，Gate 3 不许以「无 WS-0 文件」字面误判。
- **Gate 2 节回填**： frontmatter 证据清单回填双审与裁定实路径（L14 区）；执行时间 L35 区改实况；检查结果四行状态改 CONDITIONAL PASS；Gate 2 结果行 L45 改 **CONDITIONAL PASS＋销账待 PM 定点核**；§1.5 Gate 结构表两行状态回填 L102–103；§9.2 Audit Trail 两行与 Overall Assessment 回填 L635–640 区；§10.1 警告改裁定已回填口径 L649；文末 Status 行 L675 同步；Handoff Version 改 1.1。

## 触发集三处同串 grep 证据（本步自跑）

定串：`L3 动作（含删除、密钥、公网、生产）／跨仓或跨席位写／引入新连接器、MCP 或依赖／不可逆动作／涉及金额／对外动作，以及 PM 判断为高风险者`

```
grep -c '<定串>' HANDOFF-2026-10-04-course-judgment-adoption.md  → 4
grep -n '<定串>' 同上 → 行号 181（FR1）、241（§4.2 a）、264（§4.2 b）、270（§4.2 c）
grep -c 'RISK-<task_id>' 同上 → 0（大写旧形态清零）
grep -c '删除/密钥/公网/金额/生产/跨仓写/不可逆' 同上 → 0（旧触发串清零）
grep -c 'risk-<task_id>' 同上 → 2（(a)(b) 两处，小写全文一致）
```

四处命中即 FR1＋§4.2 三处，逐字同串成立。

## 修订后 HANDOFF 自验

- 字节数：54,120 B（修订前 46,329 B）；行数：675
- sha256：`2446ea78bcc7256a125fecb2ad5baa7662c5fb44514509c23ecb539ace3b7983`
- 章节在册：§1–§12 与 §9.1（现 16 行 AC，AC16 在册）全数在盘；Gate 2 节、§4.6 裁定回填、§9.2 回填均已 grep 定位（行号见上表）

## 读取清单打勾回执

- [x] PM 合并裁定 `.tad/evidence/pm/2026-10-04-course-adoption-gate2-merged-ruling.md`（全文，判据正本）
- [x] tech 路 verdict `.tad/evidence/reviews/2026-10-04-gate2-tech-review-course-judgment-adoption.md`（全文，C-T1…C-T3 修法指向）
- [x] fit 路 verdict `.tad/evidence/reviews/2026-10-04-gate2-fit-review-course-judgment-adoption.md`（全文，C-F1 与 P2-1…P2-3 修法指向）
- [x] HANDOFF 本体 `.tad/active/handoffs/HANDOFF-2026-10-04-course-judgment-adoption.md`（全文）
- [x] 盘上核实：`.agents/skills/gate/SKILL.md` 54,135 B／999 行、Gate 2 计数行 L85、Gate 4 内嵌行 L733、自带同步纪律行在册；C3 草案抽取实测 15 行

## 待 PM

B1–B7 关闭与否由 PM 定点核（读段＋grep＋触发集三处同串比对）销账；本步不自判 Gate 2 转 PASS。

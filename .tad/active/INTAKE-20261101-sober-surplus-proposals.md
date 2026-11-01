# 转呈处置登记 — Sober Surplus Phase 2 五件（GM 转呈，2026-11-01）

来源：GM 转呈 Sober 席 Surplus Phase 2 总收口（22 件全关账、FAIL 终态 0）。正本在 Sober 仓 `.tad/active/SURPLUS-REPORT-2026-10-31.md` §1–§23；本席本地同步副本未送达（Sober 仓在 VM 侧为空），以下裁定基于 GM 转呈文本作出，逐件标注「原件到盘后补读复核」——补读若与转呈文本有实质出入，裁定重开。

裁定权：TAD PM 自判（提案制，2026-10-04 用户定调）；GM 不追结果。

## 逐件裁定

### ① #21 C-1 deerflow-sandbox 本体采纳提案 —— 登记候选，不即采、不驳回
namespace 级隔离原型（落 Sober 仓 `.tad/sandbox/`，Gate 4 PASS with carry 3）。判：运行时面新子系统，量级不低于 surplus-execute 运行时兼容链，且与本席既有实测面有交界（沙箱网络命名空间、会话回收），须先做设计面核对（与 workflow 运行时及各 harness 如何共存）才能判本体落点；当前主线为 4.0.9 篮子（Phase 4/5＋发版前程），不插入。路由：**下一篮子候选**；原件到盘后本席补读，再定是否立项。

### ② #22 C-1 methodology-skeleton 采纳提案 —— 采纳互补定位，落点待 pack 维护面判
技能 39 件全量普查＋骨架包（落 `.tad/methodology-skeleton/`），与 pack 体系判互补。判：「互补而非并入」的定位成立——Phase 3 刚落定的 pack 台账是行为验证面，方法论骨架是结构面，两面不互相替代；39 件普查本身是资产。F1 微修（SKILL.md 补受众定义一句）随落点一并处置，不单独开链。路由：登记为 pack 体系相邻候选，原件到盘复核后并入下一次 pack 维护面定落点（注册面或引用面）。

### ③ #19 C-3＋#15 格式契约条：AC 表头形态（Expected Evidence）入 Gate 2 机械核面 —— 采纳，入 Phase 4 判据面输入
与本席在案的判据形态问题同族同面（Phase 2 AC11 输出形 P2、Phase 3 AC9 输出串 P2、P-C 输出形子面、Phase 3 知识候选两条），且 Phase 4 正是承接判据面修订的 Phase。路由：记入 Phase 4 输入清单，设计期由 Alex 判机械核面的具体形态（表头形态核与判据命令干跑同向）。

### ④ 判据样本包三则（#2 派生集完备性／#3 AC 表头形态／#4 AC Verification Drift）—— 采纳，入 R4 输入面
真实败例样本正是判者考题集（Osmani 采纳件①，R4 输入面）的目标形态：存在性检查须能看见「消失」、派生集须自证完备、AC Verification Drift——三则均可作回归烟测样本。参照件：Sober 仓 `patterns/ac-verification.md` 新增七节（原件到盘后补读）。与③分工：③是机械核面规则，④是考题样本，载体不同、双记不重复立项。

### ⑤ 第 10 件数据覆写事故样本 —— 采纳，并入 attestation-integrity 票输入面
canon 5 件被同名覆写销毁、已全量恢复关账。与签认层要防的「成件被冒名覆盖」同型，是该票最贴身的真实样本。路由：已在本登记同批给 TICKET-20261031-attestation-integrity 追加输入指针行；事故全账（SURPLUS-REPORT 第 10 节＋Sober 仓 `.tad/evidence/surplus-2026-10-31/`）待同步送达后补读入票。

## 状态
五件均已登记落点；①② 待下一篮子与原件补读；③ 待 Phase 4 立项时进 grounding 输入；④ 已入 R4 输入面账（与 Osmani ①同账）；⑤ 已挂 attestation 票。本件不产生新 Epic、不改 4.0.9 篮子内容。

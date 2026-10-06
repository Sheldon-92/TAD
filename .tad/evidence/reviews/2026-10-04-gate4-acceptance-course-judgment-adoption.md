# Gate 4 验收 — 课程判断落地链（TASK-20261004-COURSE-JUDGMENT-ADOPTION）

- 验收者：Alex（Solution Lead，独立会话；本件为重派执行——上一会话被运行时重启中断、零落盘，本次从头验收）
- 日期：2026-10-04
- 对象：票 `.tad/active/TICKET-20261004-course-judgment-adoption.md`；判断正本 `.tad/evidence/pm/2026-10-04-course-proposal-judgment.md`
- 证据面：Gate 2 合并裁定＋AC2 裁定（`.tad/evidence/pm/` 两件，含 PASS 销账行）、Gate 3 CODE 路 verdict（PASS）、Gate 3 SAFETY 路 verdict（PASS）、COMPLETION、风险卡演练件
- 方法：不只读结论——四项条文在所称装载面逐项现时抽核（文件＋行号实测）、触发集定串四文件程序化计数、增补行红线扫描（git diff 增行）、演练卡全文通读、按现行规程文本对新规矩做触发推演。

## 结论：**PASS**

采纳四项按判断正本口径全部落进本体规程且各自带真实装载点位；不采项零复活；红线全守。human CHECK 记「CHECK 待人」（见文末），不代判。

## 逐项对票表

| 票面项 | 落点（本席现时实测） | 装载点位真实性 | 判读 |
|---|---|---|---|
| 采纳 1 · 风险卡证伪式假设表 | 模板 `.tad/templates/dispatch-risk-card.md` 在册（§0 头信息／§1 损失与需求简表／§2 证伪式假设表，仅取判断正本所采部件）；Canonical Gate 2 项在 L32；Alex 义务行在 `.agents/skills/alex/SKILL.md` L94 | 模板被 Canonical 项与 Alex 义务行双向引用路径；义务行在 Alex 激活必读的义务块内（L94 ≤120）；Gate 2 项在清单 Gate 2 节内、评审现场必读 | ✅ 与判断逐件 1 一致（高风险派发附卡、假设＋证伪信号＋动作三列） |
| 采纳 2 · 量规 E 维证据纪律 | Canonical Gate 3 §9.1 项内 E 维子款在 L46 起（判定附证据指针、无指针 PASS 不成立、自报与重算不符该行 FAIL 且 Gate 3 整体不得 PASS＝证据否决，含口径未注明先注明再重算的但书）；Gate 4 句在 L69（复算不符判 FAIL 记 gate4_delta、不得以总结覆盖）；Alex 义务行 L95 | 子款嵌在 Gate 3 清单项正文内（非独立文件，评审者勾该项必读到）；Gate 4 句嵌 Functional acceptance 项内；义务行在 Alex 义务块内 | ✅ 与判断逐件 2 一致（只取 E 维：指针＋不符判负；无六维打分入本体，Why CE 行未动合 CF-2 裁定） |
| 采纳 3 · 权威顺序短文 | 仓根 `AGENTS.md` L80 `### File authority order`（四顺位：用户当前指示＞目标仓原件＞席位级常驻文件＞注入默认/overlay；含「低位不得静默覆盖高位、须留痕」与 memory 捕获层注），全文 184 行 | 仓根 AGENTS.md 为会话装载面本身，随发布同步传播（CF-4 裁定有意接受）；落点在 Memory authority 节后、Interaction decisions 节前，合设计锚点 | ✅ 与判断逐件 3 一致（只写一条短文；无任何同步表结构，SAFETY 路内容级复核同） |
| 采纳 4 · 装载点位一句并入装载层口径 | Canonical 卷首 L6 装载纪律句（「放进文件的东西必须有装载点位……指不出装载点位的条文等于没写」）；Gate 2 常查项 L33（Load points declared，无装载点位判设计未完成）；Gate 3 位置断言子款在 §9.1 项内（声称装载的 AC 行须含行号位置断言、只有 grep 在场不算） | 卷首句在 Canonical SSOT 文件之首（Gate 清单读取的第一面）；常查项在 Gate 2 节内；位置断言子款与 E 维子款同项并列 | ✅ 与判断逐件 5 一致（一句入装载层且升格为设计与评审常查项；CF-5 执行解释：并入 Canonical SSOT 装载面，不以「无 WS-0 文件」误判） |
| 不采项零复活 | 本席对四件 MODIFY 的全部增行（34 行）做负控扫描：六维／切片统计／同步表／四元组／六问／成对实测命中 **0**；SAFETY 路另以内容级复核坐实（模板仅三节、原件 §1/§2/§5/§6/§7/§8 本体均不在；「Evidence discipline (E维)」命中为采纳项本身、非六维量规） | — | ✅ 零复活（含 AC2 词表已知边界的内容级兜底成立） |
| 红线：只改仓内文件 | COMPLETION 写集五件＋模板＋演练卡全为仓内路径；git status 中本链四件 tracked MODIFY 与写集逐件对账一致（其余变更属他链，不在本链账上） | — | ✅ |
| 红线：条文增补形态 | 四件 tracked MODIFY 的 git diff 实测 34 增／1 删；唯一删除＝gate skill 计数行 6→8，为 AC14 点名例外（Gate 2 裁定 B2 在案）；无整篇重写 | — | ✅ |
| 红线：版本口径不复述 | 增行扫描版本号形态（`x.y.z`／`version.txt`）命中 **0**；`.tad/version.txt` 未被本链触碰（不在变更集内） | — | ✅ |

## 独立抽核记录（非引结论）

- **触发集定串现时同串**：定串「L3 动作（含删除、密钥、公网、生产）／跨仓或跨席位写／引入新连接器、MCP 或依赖／不可逆动作／涉及金额／对外动作，以及 PM 判断为高风险者」在本席程序化计数下，于模板、Canonical、alex SKILL、gate SKILL 四文件**各恰命中 1 次**，逐字同串（与 Gate 2 裁定 1 的逐字拍板件一致）。
- **演练卡如实性**：`.tad/evidence/risk-cards/risk-TASK-20261004-COURSE-JUDGMENT-ADOPTION.md` 全文通读——触发项栏逐项核对后明写「未命中（本卡为新模板的演练件 dogfood）」，无「同类」比附（B6 口径守住）；§1 三条 REQ 齐备（利害关系人／最坏损失具体事件／对应需求）；§2 三条 ASM 均为可证伪陈述句、证伪信号可观察、动作列非空（停步报 PM），且经 Gate 3 双路重跑实测为真。如实成立。
- **Gate 3 双审一致性**：CODE 路与 SAFETY 路独立重跑值与实施自报逐值全等、无自报不符行；两路 P2 均为方法注记／既存差异，不阻塞，与本席抽核无矛盾。

## 可执行性终判（按现行规程文本推演）

**问题**：下一个高风险派发与下一次 Gate 3/4 评审按现行规程走，新规矩是否真的会触发？

**推演一 · 高风险派发 → 风险卡**：① 撰写方（Alex）在角色激活时必读 `.agents/skills/alex/SKILL.md` 义务块，L94 行以触发集定串明示「高风险派发必须附风险卡，关键假设逐条写成可证伪句」——义务在作者侧装载面成立；② 评审方在 Gate 2 勾清单时必遇 Canonical L32 项（gate skill inline 副本同在，AC16 双在册已验）——该项为存在性检查：无卡或假设表三列不齐即 Gate 2 不得过，非高风险亦须写明触发项核对结论——检查在评审侧装载面成立；③ 模板在两处所引路径真实在册、定串与义务/清单逐字同串，作者与评审对「何谓高风险」用同一把尺。**结论：会触发，三方（义务、清单、模板）闭环。**

**推演二 · Gate 3/4 评审 → 证据否决**：① Gate 3 评审者勾 §9.1 Spec Compliance 项时，E 维子款就在该项正文内（L46 起），不是另一份要额外想起的文件——「每行判定附证据指针、无指针的 PASS 不成立、自报与重算不符该行 FAIL 且整体不得 PASS」随勾项必读；② Gate 4 Functional acceptance 项内含 fail-close 与复算义务句（L69），自报不符条目判 FAIL 记 gate4_delta，本次验收本身即按此项执行（本席未采信 COMPLETION 自报值、独立抽核复算）；③ 本链 Gate 3 已有首例适用：CODE 路按新条文对实施自报逐值重算比对（全等、否决未触发是比对结果而非条文缺席）。**结论：会触发，且已被实际行使过一次。**

**终判**：两条新规矩的可执行性成立——不是「写进文件」，而是作者义务、评审清单、判据文本三者同面咬合。唯一如实备注：风险卡尚无「真实命中触发项」的实战件（迄今唯一卡为本链演练件，已如实声明）；这是使用频次事实、非条文缺陷，不作本链条件，后续任一高风险派发即自然产生首例。

## 备注（不作条件）

- gate skill Gate 3 节 inline 计数行（「6 items」）与 Canonical Gate 3 现行 7 项的差异为本链开工前既存遗留（COMPLETION 已自报、SAFETY 路 P2-1 同记）；按派发指令只作备注，建议 PM 后续以独立小链或下次 gate skill 同步遍顺带改准。

## 收口交接（归 PM，非本件条件）

- 票 `TICKET-20261004-course-judgment-adoption` 置 CLOSED、HANDOFF 迁 `.tad/archive/handoffs/`、COMPLETION 的 `gate3_verdict` 标记位回填——均属 PM 收口动作。

## Human 验收区

**验收结果**：CHECK 待人（未冒充人工验收）

**后续行动**：
- [ ] 人 CHECK 后由 PM 收口（票 CLOSED／迁档／标记回填）

---
自报行（本行追加前实算，被测正文＝本行之前全部内容）：正文 8,926 B／sha256 `1ad557d08736e8e9d602b2ea01f9484de6424f30f5116293eb679771438c1324`；reviewed_at 2026-10-04（Gate 4，Alex）。

# Gate 4 验收 — Epic Phase 1「本体清账批」（TASK-20261006-EPIC-P1-CLEARANCE）

- 验收人：Alex（Solution Lead），2026-10-06。判据链：票 TICKET-20261006-epic-p1-clearance、Epic Phase 1 节与成功判据、Gate 2 合并裁定、AC23 裁定、Gate 3 双 verdict（CODE／SAFETY 均 PASS）、COMPLETION 与实施完工说明、证据目录 `.tad/evidence/epic-p1-clearance-20261006/`。
- 审法：可执行性终判——逐件对票对 Epic 判据核「定案是否成文且形态可照行」，并对关键面自盘面复算（不采信被审方总结）。

## 结论：PASS（无条件）

**gate4_delta 为空**：本验收独立复算与实施者自报、Gate 3 双审结论逐项一致，自报不符句未触发。AC23 由实施者如实自报 PARTIAL 并附完整归因、经 PM 裁断为 PASS（附归因），属正面样本而非自报不实。

## ① 12 件逐件对票对 Epic 成功判据

| 件 | 终判 | 验收依据 |
|---|---|---|
| 1.1 校验器定案＋A2 自检入清单 | ✅ | 双类契约（Class P 登记面／Class A 严契约）已实施，受治集 27/27 exit 0、负控三连 exit 2 因由正确（双审各自建 fixture 复现）；step3c3 在 publish-protocol 在盘，全发版类型恒阻塞、双参数形态写死——「自检入发版清单」形态可照行 |
| 1.2 版本口径恒久修订 | ✅ | 推导规则段（Registry∪check1–3∪前例未覆盖∪{version.txt, 标记行}＋分诊记录路径＋patch advisory 前提）入 publish-protocol 正本＋publish-ops 镜像，封顶模式集两文件零残留；后续发版改面有规则可照、不再依赖临时分诊 |
| 1.3 minor/major 史述面口径 | ✅ | §3.1 六类（L/H1/H2/H3/F/D）＋未归类停步条＋记录四字段在盘；step3c 门条件句含 100% 覆盖要求＋未分类与 exit 2 同级硬拦；史述面 168 件经双审互不重叠抽样（10＋13 件）零改动。**跨 Phase 硬约束已解除**：口径先于任何 minor 升版成文，后续 Phase 可直接引用 |
| 1.4 check5 清理 | ✅ | 本验收亲跑 state-surface 全量：**check1–6 全 PASS、exit 0**，check5 由红转绿（本 Phase 硬指标达成）；四归档路径在盘，gate-execution 迁档回写衔接句防再发 |
| 1.5 计数口径订正 | ✅ | 登记面定义句同句入 handoff 模板 §9.1 引导区与 scan-packs 断言节头注两处 |
| 1.6 genesis manifest | ✅ | 生成—判读闭环成立：installer 仅在初装分支写 genesis（五字段、已存在不覆写、哈希不变性经双审复算）；engine 正控 NOTE 锚定放行、版本不符与中段缺 hop 两负控均 REJECT exit 2——初装有锚、真 gap 仍拦，两面都实证 |
| 1.7 hooks.json 收敛 | ✅ | 方向经 Gate 2 裁断反转（生成器原产出非法 JSON、存档件为正本），heredoc 向存档件对齐后 fixture 生成件与存档件逐字节一致（805 B、jq 合法）；publish-ops §2.5 语义比对口径成文且双控实证（改值判漂移、重排判等）。裁定与 GM 登记原倾向反向一节，收口知会义务已登记（遗留 5） |
| 1.8 driftcheck (r) 单列 | ✅ | (r) 节在盘且永不置 drift、(c) 收窄、三形态 fixture 各归其格（双审独立复现）；三层同口径经 SAFETY 路专门判读成立——设计形态与真缺件在源仓断言／driftcheck／探针三面互不矛盾 |
| 1.9 读单实存＋索引新鲜度断言 | ✅ | check6（无条件集五件全实存）＋check7（年龄恒报、超 14 天 WARN 不计 fail、不可读 FAIL）分级判读成文且骨架 fixture 精确复现（fail 计数 9→10 恰 +1）；本验收亲跑见 `INFO age 20d`＋WARN、总 PASS。断言面可照行；索引复产归 Phase 3，与 Epic 分工一致 |
| 1.10 负证据纪律 | ✅ | Negative Evidence Discipline 全节在 evidence-collection L304（本验收亲核在盘），正向探针＋证据强度标注（probed/observed-absent/assumed）两要素齐 |
| 1.11 根因模板 | ✅ | `.tad/templates/root-cause-report.md` 在盘（1,549 B，本验收亲核），定因/定界/验证三段＋复发三问指引齐，gate-execution Root-Cause-First 小节含模板指针——模板在册可用 |
| CF-4 AGENTS.md 注记句 | ✅ | diff 仅注记句一处、版本标记行未动（SAFETY 路核） |

Epic 五项成功判据逐项成立：件目逐件关闭且 check1–5 全 PASS；校验器定案成文、自检入清单；件 1.3 口径在盘可引用；genesis 隔离副本实证（初装在盘＋模拟升级不报 REJECT）；driftcheck 三层一致性实证。

## ② 发版就绪（提议 patch v3.0.2）

- 改面构成清楚：本链写集 17 件＋PM 裁断案 A 扩展 3 件（已含于写集表）为本体面；本验收亲核 `.tad/version.txt` 仍为 3.0.1——本链零版本字面量改动，升版动作未被偷跑。
- 待收口项明确且各有出处：(a) 仓内 pack-registry.yaml 仍含三包旧 keywords，发版时按 publish-protocol 跑 scan-packs regen 对齐（PM 裁定一＋遗留 3；隔离副本已验证生成值与投影一致、断言 exit 0）；(b) bump 面按件 1.2 推导规则＋件 1.3 口径首次实地适用，分诊记录要求按 CF-5 写明（遗留 6）。两项均为 PM 收口机械步，不属实施缺口、不设为验收条件。
- 保留集隔离明确：批前既存脏面（旧链迁档删除、NEXT.md 与 docs/pm 保留集等）经 AC22 附注与 SAFETY 逐类核对，本链未触碰、未代为处置，提交面与保留集不混。

## ③ 遗留登记

实施完工说明遗留 6 条齐备、去向逐条明确：1（AC23 自著面覆盖问题——PM 裁断已出，覆盖与否另立设计）、2（driftcheck (b) 11 件登记滞后——CF-2 批外，PM 另行处置）、3（registry regen——发版收口）、4（索引复产——Phase 3）、5（件 1.7 反向裁定——收口知会 GM 带明）、6（发版执行与分诊记录——PM 收口）。无悬置项。

## ④ Canonical Gate 4 清单复核

- 功能验收：§9.1 AC1–AC23 全 PASS（AC22 附注、AC23 附归因，均有裁定/披露在册），无未决的实施后阻塞项。
- 证据完整：Gate 3 CODE 与 SAFETY 双 verdict 在册且均为独立会话复算；性能/UX 不适用（无性能面、无 UI）。
- 问题修复状态：Gate 2 四项条件全销账（合并裁定尾行在册）；Gate 3 六条 P2 均为非关闭注记且各有去向（driftcheck 总 exit 按分节判读、check6 冻结集变动时同步复核、跨语落盘保真后续机械化、hooks 机器闸留 Phase 2 测量面议）。
- 知识记录：本链三件新发现均已入册成文——生成器 heredoc 产出非法 JSON（Epic 1.7 行裁断注记＋合并裁定翻案记录）、installer Option A 供给面边界（AC23 裁定）、三包投影 keywords 带外增补未回写源包（案 A 裁定＋COMPLETION 关键记录）；蒸馏入 project-knowledge 的形式动作归 PM 收口/自查节奏，不阻塞本 Phase 关账。
- 自报一致性：实施者自报关键值经双审与本验收三方复算全等（HANDOFF 终态锚、受治集计数、genesis 哈希、hooks 字节、check7 计数、driftcheck 输出）；本链未引入任何新 stale 面（release-verify 172 件与基线恒等，COMPLETION 全量回归节在册）。

## 收口提示（非条件）

PM 收口按票面照行即可：regen 对齐 registry → 按件 1.2/1.3 口径执行 patch v3.0.2 发版（含分诊记录）→ 提交推送 → 知会 GM 时带明件 1.7 反向裁定 → 票 CLOSED、HANDOFF 迁档、完事卡转录遗留 6 条。human CHECK「CHECK 待人」为既定留痕，不属验收条件。

---
自报行：本 verdict 正文（本行之前）7,647 B／sha256 `2463eeac118de78d9207027132c6f767c7fe03669cba071b739ce025d8693d17`（落盘后以 head -c 7647 复算核对）

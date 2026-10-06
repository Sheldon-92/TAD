# Gate 2 契合路评审 — Epic Phase 4「体量与知识复产」设计 HANDOFF

- 评审路：fit（需求契合），独立会话，与技术路互不可见、未沟通。
- 评审者：Alex（Solution Lead，原生 subagent，tad_alex 壳激活）。
- 日期：2026-10-06。
- 对象（开工复算对锚）：HANDOFF `.tad/active/handoffs/HANDOFF-2026-10-06-epic-p4-scale.md`，49,664 B／sha256 `4acb634139a127ceb17ff0d15d876950163851b0104c65822497899aa8f19f1d`，与任务书锚逐字相符；AC1–AC28 连续。
- 对照原件：票 `.tad/active/TICKET-20261006-epic-p4-scale.md`；Epic `.tad/active/epics/EPIC-20261006-tad-self-optimization.md` Phase 4 节与 Success Criteria；设计说明 `.tad/evidence/designs/2026-10-06-tad-epic-p4-design-note.md`；PM 裁断 `.tad/evidence/pm/2026-10-06-epic-p4-design-rulings.md`（D-1–D-5）；判据 `.tad/gates/gate-canonical-checklist.md` Gate 2 节。
- 激活自报：已读薄壳 `~/workspace/skills/tad-alex/SKILL.md`，仓内 `AGENTS.md`、`.tad/project-knowledge/principles.md`、patterns `_index.md`、`.tad/tasks/gate-execution.md`、Gate Canonical Gate 2 八项。本路只读，git 只读，未写 HANDOFF 与任何被审件。

## 总判：CONDITIONAL PASS

无 P0。设计对票面与 Epic 的覆盖完整、边界守住、冻结口径写死；一处 P1 条件（C-1，Epic AC 的断言对接只验了单向）须在派 Blake 前补入 HANDOFF，补法是一行 fixture 级增补，不动设计结构。余为 P2/P3 注记，不拦派发。

## 逐项结论（按本路重点五项）

### ① 三件对票面/Epic 的覆盖与越界 —— PASS

- 票面三件＋收官件逐件有设计节与 AC 落点：件 4.1（§4.1／AC1–AC9）、件 4.2（§4.2／AC10–AC17）、件 4.3（§4.3／AC18–AC24）、收官备料（§4.4＋§10／AC25–AC26）。
- 票面件 4.3（D35 直读重议）与 Epic 件目表件 4.3（incidents/patterns 索引补齐）口径不同，设计以 §4.3a／§4.3b 双轨并纳，两源均无漏件——此合并正确，且 Epic 明示「不动条目正文」的范围线被 §4.3b 显式遵从（只对账、不新作 incident 正文，补写建议留 PM 自查批）。
- 件 4.2 边界守住：§3 原则 3、§4.2「边界（写死）」、AC17 三处同口径——本体只交付生成步、刷新路径一处接线与判读断言；下游刷新执行、逐席验证、88 路径集归属全部明示归 GM；§7 写集内无任何下游仓路径；D-5（`.stignore` 只记建议转 GM/infra）与此边界一致，不算漏件。tad.sh 接线随统一发版分发属「对外分发面」，设计已在风险触发核对中如实登记，未冒充下游执行。
- Epic 件 4.1「删除类只出候选、实际删除逐项另经确认」与票面「处置须可回退、有实测」：设计取「候选→Phase 0 停步点 PM 逐项确认→本链内执行已确认行」，与 Epic AC「未擅自执行未确认删除」的文义相容，不构成越界执行。

### ② D-3 复产空集路线 —— PASS（诚实对题，无偷换目标）

- 票面件 4.3 原文即条件式：「设计步先实测 log 现况与引用计数，**再定**复产清单」——清单内容本就以实测为前提，空集是该前提的一种合法结论，不是目标替换。
- 实测可复算：本路亲验 usage log 在盘 6 行、全行 JSON 可解析，与 §2.3 锚（6 行／2 链／最高跨链 2）一致；触发双条件（50 行／跨链 5 次）出处为载体裁定 §20，HANDOFF 引用口径无走样。
- 空集之外设计仍交付实质复产：停摆根因（记账无装载点）被定为复产对象，落点为 COMPLETION 模板节＋evidence-collection append 步＋计数脚本（带 TRIGGER MET 合成 fixture 双向自证，AC19）＋本链 dogfood（AC22）。「复产」从一次性补表改为机制复活，与 §1.2 的 Why 自洽，且全程在 §1.1/§5/D-3 显式披露、经 PM 裁断 D-3 批准——披露＋裁断＋实测三件齐备，无暗换。

### ③ 删除面纪律与 sequencing 冻结口径 —— PASS

- 删除三闸写死且顺序不可并：Phase 0 比对成表（AC2，含自造差异目录判 (b) 的流程负控）→ PM 逐项确认停步点（§6 明示未确认前 Phase 2 不得启动；Phase 1 先行不削弱此闸，因删除只在 Phase 2）→ Phase 2 骨架回退验证先行（AC4，物化集与基线清单逐行全等且时点须早于删除）。(b) 级本链绝不删有 AC3 双判（删除集 ⊆ 确认行＋(b) 级删除后 `test -d` 仍在盘）。
- 与 Epic「体量下降」判据的相容性（D-2）：Epic Success Criteria 的下降幅度本就「以 Phase 4 盘点后定案为准入判据」，AC5 以 521M 基线锚定、要求下降额逐项归因无未归因差额；(a) 级预估已含 224M 大部，判据成立不依赖 (b) 级。分级不构成对 Epic 判据的稀释。
- 冻结口径：Quality Chain Metadata「发布冻结（写死）」＋AC28（version.txt 逐字不动、无 tag 无 push 由 COMPLETION 明示、PM 收口核对）＋§11 CF 预检三处一致，与票面发布纪律和用户 sequencing 口径（总收口前不升版不 push 不触发下游刷新）逐字对齐。§10 备料只写步骤不执行，无预支。

### ④ §10 总收口清单完整性 —— PASS（一处单向缺口见 C-1，不在本节）

- 统一发版 9 步齐备且每步有判据/落点：升版与全量分诊（以 AC26 预检基线为起点）、当版 hop 随船＋在船断言、step3f 三家实跑登记、brain-index 收口再生（即新周期步首次真实行使）、release-verify 全套、打 tag 三要素断言、push＋ls-remote 逐项对尖、知会 GM 发**一轮**刷新令、Epic 总完事卡＋挂账总清点。
- P3 挂账（Codex 基线补跑，2026-10-10 配额恢复）在 step 3 被显式前置：总收口时点须在其落地之后，或 PM 裁定豁免并记入完事卡，「不得静默跳过」写明——与票面「独立小单不并入本票」的安排相容（备料引用其状态，不吞其写集，§11 CF 亦核零交集）。
- CF-7 与 driftcheck (b) 11 件：各成段给理由明确的去向建议（CF-7 建议裁定关闭不回造、附「仍有装机停在 3.0.0 前则改判补造」的反转条件；(b) 11 件建议转下一轮自查批、先复跑定活/死），且明示「只建议，PM 裁」——与 PM 裁断「留总收口时与发版一并终裁」一致，去向安排完整、无擅自销账。
- 版本终值：设计建议 3.2.0 并版的理由（3.2.0 从未对外发布、序列一步、下游只刷新一次）与 sequencing 口径同向；PM 裁断 D-4 已采纳并安排 Epic Phase Map 行的 supersede 注记归收口执行。本路无异议。

### ⑤ 风险卡三条 ASM 证伪信号可判性 —— PASS

- 正式卡已落盘 `.tad/evidence/risk-cards/risk-TASK-20261006-EPIC-P4-SCALE.md`（1,730 B，本路亲验在盘），内容照 §11 草案：最坏损失表＋REQ-1/2/3 对应 ASM-1/2/3，假设句／证伪信号／动作三列齐，满足 Canonical Gate 2 风险卡项。
- 三条信号均为机器可判、且绑定既有 AC：ASM-1＝比对表差集非空却定 (a) 级、或骨架物化比对任一不一致行（AC2/AC4 兼判）→ 降 (b) 停删报 PM；ASM-2＝AC6 清单比对非空或 AC8 祖先断言失败 → 全链停步；ASM-3＝AC15 初装 fixture 失败、tad.sh 自检非 0、或接线 diff 超出一处调用点＋必要守卫 → 回退接线报 PM。无一条依赖主观判读。

## Findings

### P1（条件，派 Blake 前补入 HANDOFF 即可，不动设计结构）

- **C-1：件 1.9 断言对接只验新鲜向，缺「置旧→告警」向。** Epic Phase 4 Acceptance Criteria 明列：「件 1.9 断言对复产后索引实测判读正确（新鲜→绿；**人为置旧副本→告警/红**，分级口径与 Phase 1 定案一致）」。HANDOFF AC12 只覆盖新鲜向（check7 age 0d、无 WARN）；§8 负控清单与 AC10–AC16 均无对隔离副本回填旧 Generated 日期后跑 check7 须出 WARN 的验证行。生成器修复与复产都改动了被判读对象本身，该向不验则 Epic 此条 AC 在 Gate 3 无行可判。补法：在 §8 负控清单加一行并在 §9.1 增/扩一行 AC（fixture：隔离副本置旧 → check7 输出 WARN 且分级为 advisory 不计 FAIL，与 Phase 1 件 1.9 口径一致），证据落 `brain-index-regen-verification.md`。

### P2（注记，不拦派发）

- **N-1：同步残窗的缓解已足，但建议 PM 确认记录带一行同步收敛复核。** §9.2 自陈弱点 (a)（比对基于本机所见、对端未达写入有残窗）属实；既有缓解（静默点执行、删除前后 `.sync-conflict` 计数 AC9、基线清单可还原、PM 确认停步点）已把残窗压到可接受。本路建议（非条件）：PM 在停步点确认记录中一并签认「确认时点同步面无在途写入」，使三闸的第二闸同时覆盖此残窗，实施侧零新增动作。
- **N-2：件 4.1 历史层「实施可直接实施部分」与设计决议的口径差已实测销解、仅注记。** Epic 件目表对历史层五处写「逐项定去向并实施可直接实施部分」；设计决议为必留、本链零删改、去向动作另立小单。鉴于实测五处合计 <2.5M 且属整洁非体量问题、Epic AC 只要求「盘点表逐项有决议、无待定整行」，该决议满足验收文义；盘点表逐项落决议行后即闭合（AC1/AC7 兼判）。注记备查，不作条件。

### P3（注记）

- **N-3：** 周期触发集 (ii)「自查轮次收口」的装载点为 PM 实践＋publish-protocol 文内声明（AC16 验文），无单一规程文件强制点位——设计 §9.2 (c) 已自陈、本路接受其披露与双点位覆盖现状；后续自查批若再现漏跑，再议加强点位。
- **N-4：** §9.2 自陈弱点 (b)（生成器修复实现未预选、与脚本头 Zero-dependency 声明的张力）已写明「须停步报 PM 不许静默引依赖」，处置路径明确，本路无追加要求。

## Canonical Gate 2 对照（本路辖面）

- Architecture complete ✅（§3 四原则＋§4 逐件）；Components specified ✅；Load points declared ✅（Gate 2 节表逐项含装载面＋触发时点，含计数脚本的 PM review 手工调用点位）；Risk card ✅（正式卡在盘、三列齐、信号可判）；All P0 resolved ✅（本路无 P0；C-1 为 P1 条件）；Expert review（双路）由 PM 回填，本路为其一。

## 结论

**CONDITIONAL PASS** —— 条件仅 C-1 一项（补置旧向断言 AC 一行）。补入并经 PM 核销后，本设计可派 Blake 实施；D-1–D-5 本路结论与 PM 裁断一致（D-1 性价比的深驳验归技术路，本路只判其无需求面冲突）。

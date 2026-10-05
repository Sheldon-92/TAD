# 完工说明 — 恢复执行链 Alex 设计步（tad-evidence-recovery-design-01）

- 角色：Alex（Solution Lead）；链：证据载体恢复执行链（TASK-20261004-EVIDENCE-CARRIER-RECOVERY-EXECUTION）
- 本步产物：HANDOFF 一份（下）；本步零 git 写操作（只跑 rev-parse／ls-tree／cat-file／log／sha256sum 等读命令）；只写两处（本说明＋HANDOFF）。

## HANDOFF 字节数与章节清单

- 路径：`.tad/active/handoffs/HANDOFF-2026-10-04-evidence-carrier-recovery-execution.md`
- 字节数：**56,104 B**（定稿值；写作中清除 1 个零宽字符 U+200B 并经 PM 向自核修正附录汇总计数后复测）
- 章节清单（与仓内模板及最近两份已收口 HANDOFF 同式）：
  - Quality Chain Metadata（头部）
  - 🔴 Gate 2: Design Completeness（状态 PENDING，待 PM 派双审回填）
  - 📋 Handoff Checklist
  - §1 Task Overview（1.1–1.4，含非范围）
  - 📚 Project Knowledge（命中 3 条：忽略树盲视／AC 断言逐项化／git quotepath）
  - §2 Background Context（2.1 沿革含 F-18/SC3 原文对读；2.2 设计步亲跑基线表；2.3 依赖）
  - §3 Requirements（FR1–FR8／NFR1–NFR5）
  - §4 Technical Design（4.1 架构图／4.2 组件 C1–C6／4.3 数据模型／4.4 看守参数逐字／4.5 推送路径写死／4.6 git 围栏 W1–W4＋禁动清单／4.7 风险与回滚）
  - §5 MQ1–MQ5（MQ4 N/A 附理由）
  - §6 Implementation Steps（Phase 0–5，Phase 1 PM 核准写死为硬前置）
  - §7 File Structure（CREATE／MODIFY／FORBIDDEN）
  - §8 Testing Requirements（8.1–8.3／8.4 Friction Preflight／8.5 Feedback／8.6 Test Evidence）
  - §9 Acceptance Criteria＋§9.1 Spec Compliance Checklist（AC1–AC15，逐行 command 文法、多词断言逐项合取、每行附设计步基线）＋§9.2 Gate 结构表（逐门谁判／判据／证据落点）／Audit Trail
  - §10 Important Notes（10.1 警告／10.2 禁区／10.3 裁量点指针）
  - §11 Learning Content（两条 Decision Rationale）
  - §12 Sub-Agent 使用记录（空表待实施回填）
  - 附录 A：17 件处置意见草案（A.1–A.4 分组逐件表）

## 读取清单打勾回执（激活包 ③＋②）

- [x] ① 票 `.tad/active/TICKET-20261004-evidence-carrier-recovery-execution.md` 全文（范围四项与红线以票定稿 HANDOFF §1.1／§3）
- [x] ② PM 裁定 `.tad/evidence/pm/2026-10-04-evidence-revival-carrier-ruling.md` 全文（看守参数逐字入 §4.4；裁定四入 Phase 1 硬前置）
- [x] ③ S1 summary `.tad/evidence/research/maintainer-evidence-revival/inventory-summary.md` 全文（四锚、stale 5 件清单、gitlink 注记、复跑命令序列、剔除规则）；manifest 只读结构（以 python 解析 class 字段抽取 branch-only 行，未全量载入正文）
- [x] ④ Decision Brief 案一机制节＋「迁移输入形态（Q4）」节（显式清单/`-f`、同步后断言、三队分法、逐件 outcome＋当场 sha 均已入设计）
- [x] ⑤ F-18／SC3 原件：AUDIT F-18 行及有利条件节、EPIC Phase 4 Scope／SC3 主判据原文逐字对读（HANDOFF §2.1 引 Scope 原文）
- [x] ⑥ `.gitignore` 第 118–126 行原文（两树忽略在 122–123 行＋维护者注记）
- [x] 规程与惯例（激活包 ②）：仓根 `AGENTS.md`、principles 索引、patterns 命中条目原文（ac-verification.md:122 与 :707、shell-portability.md:316–318）、`handoff-creation.md` 模板要求、`gate-canonical-checklist.md` Gate 2/3/4 节、参照 HANDOFF 两份的结构（revival 链与状态面收口链 §9.1 文法与节式）

## 设计步亲跑基线（命令与结果，复核用）

| 命令 | 结果 |
|---|---|
| `git rev-parse maintainer-evidence origin/maintainer-evidence main` | `8713ea4e…`／`8713ea4e…`（同尖）／`5619b095…` |
| `git ls-files -- .tad/evidence/ .tad/archive/` | 恰 3 件（NEXT 迁档件／downstream-versions／2026-09-15 gate4 验收件） |
| `sha256sum .gitignore` | `3109c53025688cc5ad6d1d8f4b5b908b4f88d0c1db7358a1f96e58be0081bfab` |
| `git log -1 maintainer-evidence` | `8713ea4e 2026-09-06 chore(evidence): sync 134 post-phase4 evidence and archive records…` |
| manifest 解析 class=branch-only | 恰 16 行（路径全量已入附录 A） |
| 逐件 `git cat-file -s`＋`git log -1`（16 件） | 字节数与末次触碰提交已逐件入附录 A 表 |

## 17 件意见草案自核

- 件数：A.1 历史链记录 8 件＋A.2 夹具技能副本 7 件＋A.3 试验夹具 1 件＋A.4 gitlink 1 件＝**17 件逐件在表**，与 S1 四锚 BRANCH_ONLY=16＋gitlink 1 一致。
- 意见分布：保留 10 件（A.1 八件＋A.3 附条件 1 件＋A.4 指针 1 件）、弃置候选 7 件（A.2，建议弃置非强制，理由逐件同组注明）。
- 附条件件：第 16 件 termination-secret-isolation.json 已在 HANDOFF §6 Phase 1 写死「定稿前只读核内容、无真实凭据才保留、疑似即停步报 PM」。
- 纪律：全部意见标注为草案，效力以 PM 裁定文件为准（裁定四不预判口径已写入 HANDOFF Gate 2 节与附录头）。

## 待 PM 裁量点

1. **脚本两件入 main 的方式**：HANDOFF 已定「本链只落盘、入 main 属 PM 收口动作（比照 R1 收口批）」，Gate 4 验收对象为盘上脚本本体——请 PM 在 Gate 2 或收口时确认此口径，或改为在本链内单独授权一笔 main 提交。
2. **A.2 七件弃置候选是否照准**：影响处置表与 Phase 3 断言的 BRANCH_ONLY 期望值（全保留＝16＋gitlink 另计；照准弃置＝9＋gitlink 另计）；设计已按公式写断言，两种裁定均可执行，无需改设计。
3. **第 16 件内容检查结论的备案形态**：设计定为「实施者在 Phase 1 只读核并一行报 PM」；若 PM 要求留书面记录件，请在 Gate 2 条件中点名落点。

## 自核（对激活包 ④ 判据逐项）

- 范围与票四项一一对应 ✓（§1.1／FR1–FR7 与票范围 1–4 逐项映射，红线入 §1.4／§4.6／§7）
- 17 件意见表草案齐、逐件有意见 ✓（附录 A，见上自核）
- 推送路径写死有依据 ✓（§4.5：grokbox＋gh 内联 helper＋R1 实测依据＋失败处置）
- 看守参数与裁定逐字一致 ✓（§4.4 三项整段照裁定二，含「不许只记不报」）
- AC 逐项断言无合并计数 ✓（§9.1 十五行均为单行 command 文法；多词断言逐词独立 grep 合取；负项以计数＝0 独立断言）
- Gate 结构齐 ✓（§9.2 逐门谁判／判据／证据落点）

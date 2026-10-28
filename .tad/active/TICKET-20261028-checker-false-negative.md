# TICKET — gate3-check.sh 首行形态与 AC 表头定位对本链文件的系统性假阴性（P1-3）

- **Status**: OPEN（待分诊执行）
- **Owner**: TAD PM（Muse 侧 TAD 席位，分诊属主）

## 1. 背景

本批四度实证同一检查器对证据齐全的评审件报缺失/退出 1：Phase 2（handoff 元数据注释形态）、Phase 3（根因再定位）、Phase 4（根因全图）、Phase 5 Gate 4（对 run 件再测 exit 1，验收方逐项解释后按「MISSING or UNEXPLAINED 才 FAIL」口径取 CONDITIONAL——即每轮都要靠人肉解释绕过一次机械误判）。根因两半，均已亲验在盘：① `.tad/hooks/lib/gate3-check.sh` 第 258–261 行的 front-matter 扫描写死首行须为 `---`（`NR == 1 && $0!= "---" { exit}`），而本链派发纪律要求评审件首行为 `dispatch_id:`，real_paths 解析恒为空；② AC 表按表头行词表定位（同脚本第 221 行注释口径），与合同/COMPLETION 实际表头形态不合时定位落空。

## 2. 范围

二选一并以证据定案（票内先行一步比对）：（甲）检查器面——front-matter 扫描容忍 `dispatch_id:` 首行形态（跳过派发头行块后再找 front matter，或无 front matter 时以正文结构定位 real_paths）；AC 表定位放宽到合同现行表头形态集合。（乙）文件形态面——评审件形态改回 `---` 首行。不许两面同时含糊改。明确不在范围：削弱 MISSING/UNEXPLAINED 语义；把检查器注册为 hook；改动 §9.1 方法文法。

## 3. 触发/验收

以本批五份 Gate 3 run 件＋Phase 5 run 件为回归集：修复后逐件跑检查器，exit 0 且每行有解释；负控——任取一件删一行 AC runs 后重跑，须 exit 1 并点名缺行（证明没把检查放成橡皮章）；修复前后对同一组文件的判定差异逐件列表入票内证据。

## 收口（2026-10-28）

- **定案与理由**：定案甲（检查器面）。乙面两条致命理由：① 回归集是哈希锁定的归档证据，改文件形态则验收按构造不可达；② 六根因中四件在 verdict 侧（A3/A4/A5/A6），乙面字面只约束 handoff 首行、覆盖不了。设计件 `.tad/evidence/yolo/distill-tickets/t1-design.md`（dispatch_id: r4t-t1-design-1）。
- **终局链**：设计 r4t-t1-design-1 → 实施 r4t-t1-impl-1（六处改动、分类层未动、改前副本 `.tad/hooks/lib/gate3-check.sh.bak-20261028-t1` 在盘）→ Gate 3 独立复核 CONDITIONAL（p0=0、p1=0、p2=1；verdict 件 `.tad/evidence/yolo/distill-tickets/t1-gate3-review.md`）。复核条件唯一＝下条口径修正的预裁残余，非实施待修项。
- **口径修正（显名）**：本票 §3「逐件 exit 0」经 conductor 裁断①（2026-10-28）修正为「逐行有解释；P5 对 exit 1，残余恰一行 UNEXPLAINED——AC19 条件行（状态『不触发』无现行文本规定）」。消解路径：先在 review-contract 立条件行形态文本、检查器再按文本跟进，不在本票。
- **衍生票**：T-1b 已立 `.tad/active/TICKET-20261028-gate2-form-enforcement.md`（OPEN，待分诊）。
- **P2 携带**：脚本头注释未提 CJK 列名，下次触及该文件时顺手补（Gate 3 复核 P2 观察，已挂账）。
- **状态**：CLOSED。

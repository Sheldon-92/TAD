# 本链证据日志 — maintainer-evidence 分支复活（TASK-20261004-MAINTAINER-EVIDENCE-REVIVAL）

> 文件名沿用设计 `phase3-first-chain.md`；2026-10-04 GM 正式口径变更取消本链 Phase 3 锚链角色后，本件语义＝本链步序与收口证据日志（HANDOFF §6 S0 修订注）。HANDOFF：`.tad/active/handoffs/HANDOFF-2026-10-04-maintainer-evidence-revival.md`。

## 开链记录（PM，2026-10-04）

- Gate 2 合并裁定：**CONDITIONAL PASS**（tech 路 CONDITIONAL，P0=0／P1=4；fit 路 CONDITIONAL，P0=0／P1=2；裁定与条件绑定见 HANDOFF §Gate 2 记录位）。
- S0 状态：条件 1 已满足（双审落盘＋合并裁定）；条件 2（GM 等价登记）作废；本行即条件 3（PM 开链记录）。
- S1 step_id：`tad-evidence-revival-s1-01`；S1 激活包：`.tad/evidence/activation-packages/tad-evidence-revival-s1-01.md`。
- C-T1 写死位置：S1 激活包 §④（安全管线＋基线口径补正，原文认 tech verdict conditions 第 1 条：`.tad/evidence/reviews/2026-10-04-gate2-tech-maintainer-evidence-revival.md`）。
- 待关闭条件台账：C-T1（S1 派发前写死 ✓，关闭验于 S1 summary 复跑）；C-T4（S1／S2 任务书 ✓／待 S2）；C-T3（S1 收口验盘＋Gate 4）；C-T2（Gate 4 前修订 §9.1）。
- 条件销账（2026-10-04 收口时点）：C-T1 ✓ 关闭／C-T2 ✓ 关闭（PM 复跑三反例全拦、两正例全过，`.tad/evidence/pm/2026-10-04-evidence-revival-ct2-pm-verify.md`）／C-T4 ✓ 终核关闭（RG3 verdict）／C-T3 首算 ✓、第二算于 S4 收口验盘执行。

## 步序记录

- 2026-10-04：开链（本行）。下一步：S1 影响面盘点（研究执行会话 A）。
- 2026-10-04：S1 完工并经 PM 验盘 PASS（`.tad/evidence/pm/2026-10-04-evidence-revival-s1-pm-verify.md`）。四锚：NOCARRIER=8706／STALE=5／CARRIED=4355／BRANCH_ONLY=16。C-T1 关闭、C-T3 首算成立、C-T4 S1 部分关闭。下一步：S2 三案比较＋Decision Brief。
- 2026-10-04：S2 完工并经 PM 验盘 PASS（`.tad/evidence/pm/2026-10-04-evidence-revival-s2-pm-verify.md`）。Brief 推荐案一（恢复分支同步＋脚本化＋新鲜度看守，置信度中高），待 RG3 独立评审后 PM 收口裁定。C-T4 关闭（S2 部分）。下一步：S3 RG3 Critic 独立评审。
- 2026-10-04：S3 RG3 verdict **PASS**，PM 验盘 PASS（`.tad/evidence/pm/2026-10-04-evidence-revival-s3-pm-verify.md`）。C-T4 终核全关闭；RG3 附带弱点 3 条，PM 处置已留痕（看守三项在 S4 裁定明定／推荐前提设重议触发／16+1 件列执行链强制首步）。下一步：C-T2 勘误 → S4 收口。

<!-- S4 收口时由 PM 在此追加一行以「研究轨收口:」开头的锚行（FR10）。 -->
- 2026-10-04：S4 收口产物落盘（RG4＋COMPLETION），PM 终验通过；C-T3 第二算成立（expected−man＝19 件，逐件均为盘点时点后落盘的本链自产物，零不明项）——**C-T3 关闭，Gate 2 六条条件全部销账**。PM 载体裁定见 `.tad/evidence/pm/2026-10-04-evidence-revival-carrier-ruling.md`；恢复执行另立票 `TICKET-20261004-evidence-carrier-recovery-execution.md`。

研究轨收口: RG3=.tad/evidence/reviews/rg3-critic-maintainer-evidence-revival.md（PASS）；Brief=.tad/evidence/research/maintainer-evidence-revival/decision-brief.md；RG4=.tad/evidence/reviews/rg4-synthesis-maintainer-evidence-revival.md

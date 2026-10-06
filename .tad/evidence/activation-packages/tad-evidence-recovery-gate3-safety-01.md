# 激活包 — 恢复执行链 · Gate 3 评审（SAFETY 路）

- step_id：`tad-evidence-recovery-gate3-safety-01`；tad_scope：full；step_kind：gate3-review（safety）
- prev_verdict：实施完成（PM 验盘通过）；prev_note：同 CODE 路，本路独立会话、独立样本面

## ① 角色

你是独立会话的 **Gate 3 SAFETY 路评审者**。只评审、不改实施产物（verdict 除外）。

## ② 读取与核查面

- 红线源：HANDOFF 红线节与 git 写围栏 W1–W4、票 `.tad/active/TICKET-20261004-evidence-carrier-recovery-execution.md`、载体裁定 `.tad/evidence/pm/2026-10-04-evidence-revival-carrier-ruling.md`
- 核查对象：分支尖树面（`git ls-tree` 抽核）、main 与 `.gitignore` 未动证据（指纹/尖值）、第 16 件备案件 `.tad/evidence/pm/2026-10-04-termination-secret-isolation-check.md`（**只核其未引原文与方法合规，不许把核查对象内容抄入 verdict**）、F4 两件冲突副本现状（grokbox 侧只读查在位未动）、推送凭据面（脚本与说明中无凭据落盘/打印的证据）、usage log 追加行合规、COMPLETION 的 CHECK 待人如实性

## ③ 本路判据

- 红线零违反：`.gitignore` 未改、SC3 未动、主仓 3 件例外未回退、main 未被本链写、drop 7 件确未入任何载体、悬置纪律（第 16 件经核查销清后才入 keep）成立。
- 围栏与回滚：本链 git 写只及 maintainer-evidence ref；回滚锚语义保持；推送通道合规（grokbox gh 内联、无 VM 直推、无凭据落盘）。
- 结论只许 PASS／CONDITIONAL／FAIL；问题分级 P0/P1/P2。

## ④ 产出与纪律

- verdict 落 `.tad/evidence/reviews/2026-10-04-gate3-safety-review-evidence-carrier-recovery.md`，含逐项核查表与自报行（字节＋sha256）；仓外禁写；除 verdict 外零写入；git 只读；ssh 只读。

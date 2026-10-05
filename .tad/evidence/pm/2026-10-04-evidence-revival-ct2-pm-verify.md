# PM 验盘记录 — C-T2 勘误（§9.1 AC5／AC6／AC11 逐项断言化）

- 日期：2026-10-04（PM 亲跑复核）
- step_id：`tad-evidence-revival-ct2-01`；HANDOFF 改后 54,505 B（实测相符）
- 改动面：§9.1 仅 AC5／AC6／AC11 三行（Verification＋判定列），基线注记原文保留并加勘误标记

## PM 复跑结果

- **正例 AC5**（真实 S1 summary）：as_of 4／复跑 4／hash-object 5／估计 3，合取 exit 0 — PASS。
- **正例 AC6**（真实 Brief）：案一 14／案二 15／案三 10／SOURCES 1／推荐 6，exit 0 — PASS。
- **反例 1**（仅「估计」×4）：as_of 计数 0、整链 exit 1 — 不再误 PASS。
- **反例 2**（仅「案一」×3）：案二计数 0、exit 1 — 不再误 PASS。
- **反例 3**（仅一行 KAGGLE）：KA 锚定断言计数 0、exit 1 — 不再误 PASS。

## 裁定

**C-T2 关闭。** Gate 2 两路六条条件至此全部销账：C-T1 ✓、C-T2 ✓、C-T3（首算 ✓／第二算在 S4 收口验盘）、C-T4 ✓、fit C1 作废留痕、C2 ✓。

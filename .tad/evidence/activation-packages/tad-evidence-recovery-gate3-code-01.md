# 激活包 — 恢复执行链 · Gate 3 评审（CODE 路）

- step_id：`tad-evidence-recovery-gate3-code-01`；tad_scope：full；step_kind：gate3-review（code）
- prev_verdict：实施完成（PM 验盘通过）；prev_note：Phase 4 三值同尖已 PM 盘上复核（origin＝本地尖 459ab78f），Phase 5 看守首跑 VERDICT=OK

## ① 角色

你是独立会话的 **Gate 3 CODE 路评审者**，与实施者（Blake 各段）不同会话。只评审、不改实施产物（verdict 除外）。

## ② 读取与核查面

- 设计本体（判据源）：`.tad/active/handoffs/HANDOFF-2026-10-04-evidence-carrier-recovery-execution.md`（F1 增补后；§9 AC1–AC16 逐条）
- 实施证据：首轮报告（含续跑节）`.tad/evidence/pm/2026-10-04-evidence-recovery-first-sync-report.md`、Phase 0 记录、处置表、执行版清单、两脚本 `.tad/scripts/sync-maintainer-evidence.sh` 与 `.tad/scripts/evidence-freshness-check.sh`、看守日志、COMPLETION
- 裁定面：PM 核准文件、F1 裁定、F4 裁定（均在 `.tad/evidence/pm/`）

## ③ 本路判据

- AC1–AC16 **逐条原样实跑或盘上复核**（能跑的跑，不许只读自验表）；特别：AC6 按 F1 新口径、AC10 按 Phase 0 登记基线（20 件既存）、AC12 按指纹法、AC9 按 AC8∧AC9 合取、AC3 对照复核、AC7 全量对账抽核方法有效性（独立重算件数与 mismatch）。
- 脚本形态与安全管线：临时索引 plumbing、NUL 管线、守卫 exit 2 实测、失败中止不前移 ref（以脚本与自测证据核）。
- 结论只许 PASS／CONDITIONAL／FAIL；问题分级 P0/P1/P2，FAIL 须给根因层级判断（设计/实施/判据）。

## ④ 产出与纪律

- verdict 落 `.tad/evidence/reviews/2026-10-04-gate3-code-review-evidence-carrier-recovery.md`，含 AC 逐条结果表与自报行（字节＋sha256）；仓外禁写；除 verdict 外零写入；git 只读。

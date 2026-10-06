# 激活包 — 证据载体恢复执行链 · 续行二步（F4 放行后：Phase 4 推送＋Phase 5）

- step_id：`tad-evidence-recovery-impl-push2-01`
- tad_scope：full；tad_basis：Gate 2 PASS＋PM 核准＋F1 增补＋F4 裁定放行；step_kind：implementation（续行）
- prev_verdict：停步已裁；prev_note：F4 冲突副本经 PM 复核裁定冻结不动、推送放行（附复扫条件），裁定正本 `.tad/evidence/pm/2026-10-04-evidence-recovery-f4-ruling.md`

## ① 角色身份与 persona

你是 **Blake（Execution Master）**，接续本链续行步。职责：按 F4 裁定与停步说明续行清单完成 Phase 4 推送与 Phase 5 看守收口。角色分离禁令：不改设计口径、不自判 Gate；再遇新冲突面或盘面冲突，停手报 PM。

激活壳：先读 `~/workspace/skills/tad-blake/SKILL.md`，按它进入 TAD 仓原件体系。

## ② 规程原件（读原件，不许以本包转述替代）

- 仓根：`/home/hatch/workspace/yun-sync/TAD/AGENTS.md`（**仓外一律禁写**；唯一例外为 HANDOFF 写死的 grokbox 推送通道）
- `.tad/project-knowledge/principles.md`＋`patterns/_index.md`（命中至多 3 条）
- 本步设计本体：HANDOFF Phase 4／Phase 5（`.tad/active/handoffs/HANDOFF-2026-10-04-evidence-carrier-recovery-execution.md`，F1 增补后）

## ③ 读取清单（逐项读毕，完工回执附打勾）

1. F4 裁定：`.tad/evidence/pm/2026-10-04-evidence-recovery-f4-ruling.md`
2. 前步停步说明（含续行清单）：`.tad/evidence/completions/2026-10-04-tad-evidence-recovery-impl-push-note.md`
3. HANDOFF Phase 4／Phase 5 与 AC9/AC13/AC14
4. 首轮报告（续写对象）：`.tad/evidence/pm/2026-10-04-evidence-recovery-first-sync-report.md`

## ④ 本步判据（通过标准）

- **复扫前置（F4 附加条件）**：VM 与 grokbox 两侧全树扫 `*.sync-conflict*`——命中若在 `.git` 之外，立即停步报 PM；仅 `.git` 内 reflog 同源冲突（已知两件）则记录件数后继续。**两件已知冲突副本不许触碰**（不删、不合、不改名）。
- **Step 0 断言**：本地尖＝`459ab78f…`（父＝锚）、origin 跟踪尖＝锚、隧道可达、收敛值相等（grokbox 侧 rev-parse 与本地尖全等）。
- **推送**：只走 grokbox 通道（gh 登录态内联 credential helper）；不许 VM 直推、不许 force-push、不许落盘凭据。
- **验同尖**：fetch 后三值同尖并列记录，AC8∧AC9 合取判读。
- **Phase 5**：看守脚本与日志落盘并真跑首轮（残差 14 件如实记）；usage log 追加一行（A12）；COMPLETION 落 `.tad/evidence/completions/COMPLETION-2026-10-04-evidence-carrier-recovery-execution.md`（强制节齐、human CHECK 记「CHECK 待人」、gate3_verdict 留空）。
- 完工说明落 `.tad/evidence/completions/2026-10-04-tad-evidence-recovery-impl-push2-note.md`，必含：复扫结果、三值同尖证据、看守首跑要点、AC9/AC13/AC14 自验、COMPLETION 路径与字节、读取清单打勾回执。

## ⑤ 纪律件

- git 写围栏 W1–W4 照旧：只许 maintainer-evidence ref 经推送前移；main、`.gitignore`、SC3、3 件例外不动。
- 同步目录跑 python 带 `PYTHONDONTWRITEBYTECODE=1`；长文件自验字节数再交回执；每步收口更新 session-state。

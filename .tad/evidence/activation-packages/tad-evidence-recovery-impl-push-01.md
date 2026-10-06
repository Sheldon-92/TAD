# 激活包 — 证据载体恢复执行链 · 续行步（Phase 4 推送＋Phase 5 看守）

- step_id：`tad-evidence-recovery-impl-push-01`
- tad_scope：full；tad_basis：Gate 2 PASS＋PM 核准＋F1 增补核销＋隧道恢复（GM 2026-10-04 23:09 EDT 直查 GB_OK、对端 connected=true）；step_kind：implementation（续行）
- prev_verdict：续跑前段 PASS（Phase 3）；prev_note：Phase 4 曾因隧道不可达按 §4.5 停步，隧道已恢复，按停步说明 §5 续行清单接续，不重跑同步

## ① 角色身份与 persona

你是 **Blake（Execution Master）**，接续本链续跑步。职责：按停步说明 §5 续行清单与 HANDOFF Phase 4／Phase 5 完成推送与看守收口。角色分离禁令：不改设计口径、不自判 Gate；盘面与设计再冲突，停手报 PM。

激活壳：先读 `~/workspace/skills/tad-blake/SKILL.md`，按它进入 TAD 仓原件体系。

## ② 规程原件（读原件，不许以本包转述替代）

- 仓根：`/home/hatch/workspace/yun-sync/TAD/AGENTS.md`（**仓外一律禁写**；唯一例外为 HANDOFF 写死的 grokbox 推送通道：经 `ssh box@grokbox` 在 grokbox 侧以其 gh 登录态内联 credential helper 执行 push）
- `.tad/project-knowledge/principles.md`＋`patterns/_index.md`（命中至多 3 条；ac-verification、shell-portability 必读）
- 本步设计本体：`.tad/active/handoffs/HANDOFF-2026-10-04-evidence-carrier-recovery-execution.md`（F1 增补后全文；Phase 4、Phase 5、§7、AC9/AC13/AC14 与 A11 合取注记逐字执行）

## ③ 读取清单（逐项读毕，完工回执附打勾）

1. 续跑停步说明 §5 续行清单：`.tad/evidence/completions/2026-10-04-tad-evidence-recovery-impl-resume-note.md`
2. HANDOFF Phase 4／Phase 5 两节＋§9 相关 AC
3. 首轮报告（续写对象，含续跑节）：`.tad/evidence/pm/2026-10-04-evidence-recovery-first-sync-report.md`
4. PM F1 裁定：`.tad/evidence/pm/2026-10-04-evidence-recovery-f1-ruling.md`

## ④ 本步判据（通过标准）

- **Step 0 断言**：本地尖＝`459ab78f5aa54dc1056522780607dcfeb473c647`（父＝锚 `8713ea4e…`）、origin 跟踪尖＝锚、隧道可达（`ssh box@grokbox` 回显正常）；任一不符停步报 PM。
- **收敛确认**：按 HANDOFF Phase 4 先验 Syncthing 收敛（grokbox 侧对应仓 rev-parse 与本地同值面），不等不许推。
- **推送**：只走 grokbox 通道以其 gh 登录态内联 credential helper `push origin maintainer-evidence`；不许 VM 直推、不许 force-push、不许落盘凭据；`.sync-conflict` 命中或 gh 失效即停步报 PM。
- **验同尖**：VM 侧 fetch 后三值并列同尖（本地尖／origin 跟踪尖／远端实测尖），AC8∧AC9 合取判读（A11）；结果记入首轮报告续行行与本步完工说明。
- **Phase 5**：看守脚本 `.tad/scripts/evidence-freshness-check.sh`（阈值 `[ … -gt 100 ]`／`[ … -gt 21 ]` 形态）＋记录 `.tad/evidence/pm/evidence-freshness-log.md` 落盘并真跑首轮（结果如实记，残差 14 件为已知冻结后新增）；usage log 按既有格式追加一行本链引用（A12）；COMPLETION 落 `.tad/evidence/completions/COMPLETION-2026-10-04-evidence-carrier-recovery-execution.md`（强制节齐、human CHECK 记「CHECK 待人」不许冒充、gate3_verdict 标记位留空待过门后填）。
- 完工说明落 `.tad/evidence/completions/2026-10-04-tad-evidence-recovery-impl-push-note.md`，必含：三值同尖证据、看守首跑输出要点、AC9/AC13/AC14 自验结果、COMPLETION 路径与字节、读取清单打勾回执。

## ⑤ 纪律件

- git 写围栏照 HANDOFF W1–W4：只许 maintainer-evidence ref 前移（经推送）；main、`.gitignore`、SC3、3 件例外不动；回滚锚保持。
- 管线铁律与 CJK 路径纪律照旧；同步目录跑 python 带 `PYTHONDONTWRITEBYTECODE=1`。
- 长文件写入后自验字节数再交回执；自报与盘面不符按未完成处理。每步收口更新本仓 session-state。

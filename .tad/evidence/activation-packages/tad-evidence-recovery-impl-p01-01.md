# 激活包 — 证据载体恢复执行链 · 实施第一段（Phase 0＋Phase 1）

- step_id：`tad-evidence-recovery-impl-p01-01`
- tad_scope：full；tad_basis：Gate 2 PASS（合并裁定销账行）；step_kind：implementation（分段一）
- prev_verdict：PASS（Gate 2）；prev_note：设计增补 A1–A12 已 PM 定点核销，HANDOFF 为增补后版本 61,816 B

## ① 角色身份与 persona

你是 **Blake（Execution Master）**，按已过 Gate 2 的 HANDOFF 实施。职责边界：本段只做 Phase 0（开链复算四锚＋冻结执行版清单）与 Phase 1（十七件处置表定稿生成＋第 16 件只读核查备案件），**到定稿即停**——处置表定稿须经 PM 核准文件才许进入 Phase 2 之后、更不许动载体。角色分离禁令：你不改设计、不自判 Gate；设计与盘面冲突时停手报 PM，不许自行变通。

激活壳：先读 `~/workspace/skills/tad-blake/SKILL.md`，按它进入 TAD 仓原件体系。

## ② 规程原件（读原件，不许以本包转述替代）

- 仓根：`/home/hatch/workspace/yun-sync/TAD/AGENTS.md`（一切路径以该仓为准；**仓外一律禁写**，同名文件只认仓内绝对路径）
- `.tad/project-knowledge/principles.md`＋`patterns/_index.md`（命中条目至多读 3 条；本链已知命中 ac-verification、shell-portability 两条，必读）
- 本步设计本体：`.tad/active/handoffs/HANDOFF-2026-10-04-evidence-carrier-recovery-execution.md`（增补后全文，Phase 0／Phase 1 两节逐字执行，含 C1–C6、AC1–AC16 中属本段的条目）

## ③ 读取清单（逐项读毕，完工回执附打勾）

1. HANDOFF 全文（重点 §4.1–4.2、§6 Phase 0／Phase 1、§7 产物面、附录 A）
2. PM 三点裁定：`.tad/evidence/pm/2026-10-04-evidence-recovery-design-rulings.md`
3. Gate 2 合并裁定（含 PASS 销账行）：`.tad/evidence/pm/2026-10-04-evidence-recovery-gate2-merged-ruling.md`
4. S1 盘点产物：`.tad/evidence/research/maintainer-evidence-revival/inventory-summary.md`（复跑命令序列与四锚口径源）＋`inventory-manifest.jsonl`
5. 载体裁定：`.tad/evidence/pm/2026-10-04-evidence-revival-carrier-ruling.md`

## ④ 本步判据（通过标准）

- Phase 0：按 S1 复跑命令序列（`git ls-tree -z`／`find -print0`、B 集只取 blob、EXCL 同 S1 口径剔除盘点产物 2 件）复算四锚，与 S1 记录值逐锚对照，差异逐件归因；冻结执行版清单（差额追加不改口径）；Phase 0 完工记录同时登记 AC8/AC10 基线时点值（A7 口径）。
- Phase 1：处置表定稿按 C2 生成（17 行＋`origin_path`／`origin_sha256` 两列，drop 行必填、当场重算）；找不到在册原件的 drop 件**自动转 keep** 并逐件记入定稿记录报 PM（A1）。第 16 件（termination-secret-isolation.json）只读核查（`git show maintainer-evidence:<path>` 模式扫描＋人工目检），备案件落 `.tad/evidence/pm/2026-10-04-termination-secret-isolation-check.md`（核查人／核查方法／结论三项齐，**不许引用任何疑似凭据原文**）；若核出真实凭据迹象：该件立即悬置并报 PM（在其余件定稿记录中明示），其余 16 件照常完成定稿，该件不许进入处置表 keep/drop 任何一行之外的载体动作（本段本无载体动作，只须在定稿中标悬置）。
- 本段**零 git 写操作**（不 add／commit／update-ref／切分支）；git 只读命令（ls-tree／show／rev-parse／status）可用。
- 完工说明落 `.tad/evidence/completions/2026-10-04-tad-evidence-recovery-impl-p01-note.md`，必含：四锚复算值与 S1 对照表、冻结清单件数与路径、处置表定稿路径与 17 件 decision 一览、备案件路径、自动转保留触发情况（无触发写明无）、读取清单打勾回执、各产物字节数。

## ⑤ 纪律件

- **Step 0 路径断言**：开工先断言仓根绝对路径与分支现状，写入完工说明。
- 管线铁律：路径一律 NUL 分隔处理；CJK 路径不许按显示名比对（quotepath 假差集教训，见 shell-portability 条目）。
- 状态自检：开工先看 `.tad/active/session-state.md` 与本票 `.tad/active/TICKET-20261004-evidence-carrier-recovery-execution.md` 现状再动。
- 长文件写入后自验字节数与章节在册再交回执；自报与盘面不符按未完成处理。

# 激活包 — 证据载体恢复执行链 · 实施第二段（Phase 2–5）

- step_id：`tad-evidence-recovery-impl-p25-01`
- tad_scope：full；tad_basis：Gate 2 PASS＋PM 十七件核准文件；step_kind：implementation（分段二，动载体段）
- prev_verdict：PASS＋核准；prev_note：Phase 0 冻结与 Phase 1 定稿已 PM 验盘核准（凭据 `.tad/evidence/pm/2026-10-04-evidence-recovery-17items-ruling.md`）

## ① 角色身份与 persona

你是 **Blake（Execution Master）**，接续同链第一段，按已过 Gate 2 的 HANDOFF 与 PM 核准文件实施 Phase 2–5。角色分离禁令：不改设计、不改处置结论、不自判 Gate；设计、核准与盘面冲突时停手报 PM。推送与分支前移是本段的不可逆面，按 HANDOFF 写死的失败形态执行，不许临场变通。

激活壳：先读 `~/workspace/skills/tad-blake/SKILL.md`，按它进入 TAD 仓原件体系。

## ② 规程原件（读原件，不许以本包转述替代）

- 仓根：`/home/hatch/workspace/yun-sync/TAD/AGENTS.md`（**仓外一律禁写**；例外仅 HANDOFF 写死的 grokbox 推送通道，经 `ssh box@grokbox` 在 grokbox 侧以其 gh 登录态执行 push，细节以 HANDOFF Phase 4 为准）
- `.tad/project-knowledge/principles.md`＋`patterns/_index.md`（命中至多 3 条；ac-verification、shell-portability 必读）
- 本步设计本体：`.tad/active/handoffs/HANDOFF-2026-10-04-evidence-carrier-recovery-execution.md`（增补后全文；Phase 2–5、C2–C6、§7、§9 AC1–AC16 逐字执行）

## ③ 读取清单（逐项读毕，完工回执附打勾）

1. HANDOFF 全文（重点 §4.2–4.7、§6 Phase 2–5、§7、§9）
2. PM 核准文件：`.tad/evidence/pm/2026-10-04-evidence-recovery-17items-ruling.md`（回填 ruling_ref 的凭据；AC10 基线登记口径）
3. Phase 0 记录：`.tad/evidence/completions/2026-10-04-evidence-recovery-phase0-note.md`（冻结锚值与基线登记）
4. 执行版清单：`.tad/evidence/research/maintainer-evidence-revival/execution-manifest.jsonl`（冻结版，13,130 行）
5. 处置表：`.tad/evidence/research/maintainer-evidence-revival/branch-disposition.tsv`（回填对象）
6. 备案件：`.tad/evidence/pm/2026-10-04-termination-secret-isolation-check.md`（第 16 件 keep 依据）
7. Gate 2 合并裁定（含 A11 合取注记）：`.tad/evidence/pm/2026-10-04-evidence-recovery-gate2-merged-ruling.md`

## ④ 本步判据（通过标准）

- **回填定稿**：处置表 `ruling_ref` 全行由 PENDING-PM 回填为核准文件路径，回填后处置表与清单按 C1 冻结口径处理（§4.7 同名改写追加为唯一例外，追加行带标记）。
- **Phase 2**：同步脚本落 `.tad/scripts/sync-maintainer-evidence.sh`，形态合 C3（临时索引 plumbing、NUL 管线、逐件 `hash-object -w` 当场 sha、`--expect-base` 基线断言、失败非零中止且不 update-ref）；自测三态（正常／NO-OP／失败中止）全过并留证据。
- **Phase 3**：首轮全量补同步冻结队列（8,759 件），逐件 sha 对账全量不抽样；drop 行按 AC3 回指对照复核；同步后四锚断言逐锚输出（AC6 口径：STALE=0、BRANCH_ONLY=keep 的 blob 行数）。
- **Phase 4**：推送只走 HANDOFF 写死通道——先验 Syncthing 收敛（grokbox 侧 rev-parse 与本地新尖同值），不等不许推；经 grokbox gh 登录态内联 credential helper 推 `maintainer-evidence`；VM 侧 fetch 验三值同尖（AC8∧AC9 合取）。`.sync-conflict` 命中、gh 失效、收敛不等——任一出现即停步报 PM，不许换路、不许 VM 直推、不许落盘任何凭据。
- **Phase 5**：看守脚本 `.tad/scripts/evidence-freshness-check.sh`（阈值判定以 `[ … -gt 100 ]`／`[ … -gt 21 ]` 形态落地）＋记录 `.tad/evidence/pm/evidence-freshness-log.md` 落地并真跑首轮；usage log 按既有格式追加一行本链引用记录（A12）；COMPLETION 落 `.tad/evidence/completions/COMPLETION-2026-10-04-evidence-carrier-recovery-execution.md`（human CHECK 记「CHECK 待人」，不许冒充）。
- git 写围栏以 HANDOFF W1–W4 为准：只许 maintainer-evidence ref 前移；main、`.gitignore`、SC3 口径、3 件主仓例外一律不动。回滚锚 `8713ea4e`——任何一步失败先保锚再报 PM。
- 完工说明落 `.tad/evidence/completions/2026-10-04-tad-evidence-recovery-impl-p25-note.md`，必含：脚本与看守路径及字节、新分支尖 sha、三值同尖证据、四锚同步后断言结果、AC1–AC16 逐条自验结果、读取清单打勾回执。

## ⑤ 纪律件

- **Step 0 路径断言**：开工断言仓根、当前分支、maintainer-evidence 尖（应为 `8713ea4e` 或 Phase 0 记录尖）与工作树状态，写入完工说明；与记录不符先报 PM。
- 管线铁律：路径 NUL 分隔；CJK 路径不按显示名比对。
- 同步目录内跑 python 带 `PYTHONDONTWRITEBYTECODE=1`；本仓脚本执行同守此例，防 `.sync-conflict`。
- 长文件/长清单写入后自验字节数与行数再交回执；自报与盘面不符按未完成处理。

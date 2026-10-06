# 激活包 — 证据载体恢复执行链 · 续跑步（Phase 3 续跑 → Phase 4 → Phase 5）

- step_id：`tad-evidence-recovery-impl-resume-01`
- tad_scope：full；tad_basis：Gate 2 PASS＋PM 十七件核准＋PM F1 裁定及增补核销；step_kind：implementation（续跑）
- prev_verdict：BLOCKED→增补已核；prev_note：首轮 Phase 3 因 gitlink 前缀 40 件停步，F1 增补 (a)–(e) 已 PM 定点核销，按 HANDOFF「续跑（F1 修正后）」小节续跑

## ① 角色身份与 persona

你是 **Blake（Execution Master）**，接续本链前两段实施。职责：严格按 HANDOFF §6 Phase 3「续跑（F1 修正后）」小节五序执行，再续 Phase 4 推送与 Phase 5 看守收口。角色分离禁令：不改设计口径、不改处置结论、不自判 Gate；盘面与增补后设计再冲突，停手报 PM。

激活壳：先读 `~/workspace/skills/tad-blake/SKILL.md`，按它进入 TAD 仓原件体系。

## ② 规程原件（读原件，不许以本包转述替代）

- 仓根：`/home/hatch/workspace/yun-sync/TAD/AGENTS.md`（**仓外一律禁写**；唯一例外为 HANDOFF 写死的 grokbox 推送通道）
- `.tad/project-knowledge/principles.md`＋`patterns/_index.md`（命中至多 3 条；ac-verification、shell-portability 必读）
- 本步设计本体：`.tad/active/handoffs/HANDOFF-2026-10-04-evidence-carrier-recovery-execution.md`（F1 增补后全文，重点 §4.2 C1/C3、§6 Phase 3 续跑小节与 Phase 4/5、§7、AC6/AC7/AC12/AC15 新口径）

## ③ 读取清单（逐项读毕，完工回执附打勾）

1. HANDOFF 全文（F1 增补后，67,508 B）
2. PM F1 裁定（含增补核销行）：`.tad/evidence/pm/2026-10-04-evidence-recovery-f1-ruling.md`
3. 首轮报告（续写对象）：`.tad/evidence/pm/2026-10-04-evidence-recovery-first-sync-report.md`
4. 前段停步说明：`.tad/evidence/completions/2026-10-04-tad-evidence-recovery-impl-p25-note.md`
5. PM 核准文件：`.tad/evidence/pm/2026-10-04-evidence-recovery-17items-ruling.md`；Phase 0 记录：`.tad/evidence/completions/2026-10-04-evidence-recovery-phase0-note.md`
6. 执行版清单与处置表（队列修正对象）现行盘上状态

## ④ 本步判据（通过标准）

- 续跑五序不跳步：① 本地尖回滚至锚 `8713ea4e…`，清单首轮 outcome 回退 pending、首轮报告补记回滚一行；② 队列修正——40 件转 `embedded-repo`、S1 summary 文末按增补写死的逐字文本追加口径注记（只许追加）；③ 脚本加守卫并补两件守卫夹具（gitlink 前缀件＋`.git` 组件件）验退出码 2＋命中清单＋ref 不动，原三态自测复跑全过；④ 按新口径重跑同步与对账断言（期望 synced 8,719、mismatch 0、gitlink `160000` 原样、新尖父＝锚——期望非判据，以 AC 原样结果为准）；⑤ 断言全过后续 Phase 4（收敛验→grokbox 通道推送→fetch 验三值同尖，AC8∧AC9 合取）与 Phase 5（看守脚本＋日志首跑、usage log 追加一行、COMPLETION 落盘、human CHECK 记「CHECK 待人」）。
- 首轮报告在原文件续写「续跑」节，不另起文件。
- 推送失败形态照旧写死：收敛不等不许推、`.sync-conflict` 命中停步、gh 失效停步；不许 VM 直推、不许落盘凭据；失败先保锚再报 PM。
- git 写围栏照 HANDOFF W1–W4：只许 maintainer-evidence ref 前移；main、`.gitignore`、SC3、3 件例外不动。
- 完工说明落 `.tad/evidence/completions/2026-10-04-tad-evidence-recovery-impl-resume-note.md`（**取代**前段停步说明的未完状态），必含：回滚与队列修正记录、守卫夹具结果、新分支尖 sha、三值同尖证据、同步后四锚与 AC1–AC16 逐条自验（AC10 按 Phase 0 登记基线、AC12 按指纹法）、COMPLETION 路径、读取清单打勾回执。

## ⑤ 纪律件

- **Step 0 路径断言**：开工断言仓根、当前尖应为首轮新尖 `982e5580…`（回滚起点）、工作树状态，写入完工说明；不符先报 PM。
- 管线铁律：路径 NUL 分隔；CJK 路径不按显示名比对；同步目录跑 python 带 `PYTHONDONTWRITEBYTECODE=1`。
- 长文件写入后自验字节数与行数再交回执；自报与盘面不符按未完成处理。

# 设计增补完工说明｜证据载体恢复执行链 HANDOFF（Gate 2 合并裁定 A1–A12）

- 步：`tad-evidence-recovery-design-amend-01`（Alex，设计增补步）
- 判据：`.tad/evidence/pm/2026-10-04-evidence-recovery-gate2-merged-ruling.md`（CONDITIONAL PASS，A1–A12）
- 被修订件：`.tad/active/handoffs/HANDOFF-2026-10-04-evidence-carrier-recovery-execution.md`
- 本步边界自述：只改了被修订件一件、只新写本说明一件；零 git 写操作；frontmatter／status／Gate 2 节未动；设计主干、范围四项、红线、17 件处置结论未改；定案项未改路（A3 取 EXCL、A8 取 C5 写明形态且 AC14 原文未动、A12 写 usage log 追加行）。增补是否销账由 PM 定点核决定，本说明不自判关闭。

## 1. A1–A12 逐项落点表（行号为修订后 HANDOFF 的行号）

| # | 落点（章节＋行号） | 落位内容一句话 |
|---|---|---|
| A1 | §4.2 C2 第 214–216 行；§6 Phase 1 步骤 3 第 352 行；§6 Phase 3 步骤 2 第 378 行；§9.1 AC3 第 501 行 | C2 增 `origin_path`／`origin_sha256` 两列（drop 行必填）＋裁定 2 对照与「找不到在册原件自动转 keep 并报 PM」判定留痕；Phase 1 定稿回填对照、Phase 3 对账回指复核；AC3 增断言（drop 行两列非空且 sha 与原件当场重算一致） |
| A2 | §6 Phase 1 交付物第 346 行；§6 Phase 1 步骤 1 第 350 行；§6 Phase 1 验证方法第 355 行；§7 CREATE 第 422 行；§9.1 AC16 第 515 行 | 备案件列为 Phase 1 正式交付物（路径 `.tad/evidence/pm/<执行日>-termination-secret-isolation-check.md`，Phase 1 定稿记录回指）；§7 CREATE 增列；新增 AC16（在盘＋核查人/方法/结论三项＋不引凭据原文由 safety 路人工核）；停步措辞改齐「该件悬置、其余 16 件照常推进」，明示 PM 另行裁定前不入任何载体（分支、主仓、同步清单均不许） |
| A3 | §3.1 FR2 第 161 行；§6 Phase 0 步骤 3 第 336 行；§9.1 AC6 第 504 行 | EXCL 归属写死：Phase 0 差集计算与执行版清单追加同样适用 S1 的 EXCL（盘点产物 2 件不入清单、不入队列，仅在锚比对中按 summary 口径处理）；AC6 的 NOCARRIER 期望式盘上集明确同一 EXCL 口径 |
| A4 | §4.2 C3 第 221 行；§6 Phase 2 步骤 2 第 364 行 | C3 前置自检参数化：`--expect-base <sha>` 期望基线断言（首跑取 Phase 0 记录尖、再跑取上轮产出尖，未给参数时默认断言为 Phase 0 记录尖或其本链后继）；自测第二跑以 `--expect-base` 传第一跑产出尖验 NO-OP（退出码 3），三态可达 |
| A5 | §4.2 C1 第 211 行 | 冻结句后增 carve-out：§4.7 同名改写件追加为唯一例外（行内注 `appended_at_phase3: true`）；AC1 计数式只数 `appended_at_phase0` 行，不受 Phase 3 追加行污染 |
| A6 | §3.1 FR5 第 164 行；§5 MQ3 第 301 行；§6 Phase 3 步骤 3 第 379 行；§9.1 AC6 第 504 行 | 措辞改齐 AC6：「keep 的 blob 行数（gitlink 不计）」四处一致 |
| A7 | §9.1 表后注第 519 行 | 基线时点声明：AC8 父值与 AC10 main 尖基线以 Phase 0 完工记录复算时点登记值为准（Phase 0 记录即基线源），Gate 3 以登记值替换表中设计时点钉值比对，差异在 Phase 0 记录中归因 |
| A8 | §4.2 C5 第 228 行；§9.1 AC14 第 512 行原文未动 | C5 写明看守阈值判定须以 bash `[ … -gt 100]`／`[ … -gt 21]` 形态落地（不许以内嵌 python 等价比较式替代）；AC14 维持原文 |
| A9 | §9.1 AC5 第 503 行 | AC5 正项增 `read-tree`、`write-tree` 两词逐项断言（共六正项）；负项 `git add` 改为只对非注释行判定（`grep -v '^[[:space:]]*#'` 后计数） |
| A10 | §9.1 表下注记第 517 行 | 注记改为「本表除 AC6 外均为 command 文法；AC6 以首轮报告所附断言脚本为执行形态（脚本原文附于首轮报告，Gate 3 原样重跑）」 |
| A11 | §9 完成判据第 491 行 | 新增合取判读条：「AC9 须与 AC8 合取判读，AC9 单独 PASS 不构成推送完成证据，推送完成 ⇔ AC8∧AC9 同真」，并注明 Gate 3 按此执行 |
| A12 | §6 Phase 5 步骤 3 第 406 行；§7 MODIFY 第 431 行 | Phase 5 收口时按 `.tad/evidence/knowledge-usage-log.jsonl` 既有格式追加一行，记本链对 S1 盘点产物与载体裁定的引用；§7 MODIFY 同步增列该文件 |

## 2. 修订后 HANDOFF 盘面值（本步实测）

- 字节数：61,816 B（修订前 56,104 B）
- 行数：634 行
- sha256：`4c45cac50718e47543a81301fe3a10b2994d51ba41d8270a617a1140ec3eaa2b`

## 3. 读取清单打勾回执（激活包 ③）

- [x] ① PM 合并裁定 `.tad/evidence/pm/2026-10-04-evidence-recovery-gate2-merged-ruling.md`（全文）
- [x] ② tech 路 verdict `.tad/evidence/reviews/2026-10-04-gate2-tech-review-evidence-carrier-recovery.md`（全文）
- [x] ③ fit 路 verdict `.tad/evidence/reviews/2026-10-04-gate2-fit-review-evidence-carrier-recovery.md`（全文）
- [x] ④ 被修订本体 HANDOFF（全文 625 行修订前版，逐行读毕后落改）
- [x] ⑤ PM 三点裁定 `.tad/evidence/pm/2026-10-04-evidence-recovery-design-rulings.md`（全文）
- [x] 附带：激活包本体、激活壳 `~/workspace/skills/tad-alex/SKILL.md`、仓根 `AGENTS.md`、`.tad/project-knowledge/principles.md`、`patterns/_index.md` 与 `patterns/ac-verification.md`

## 4. 自验记录

- 12 项落点逐项以 grep 复核在册（锚词：`origin_path`、`termination-secret-isolation-check`、`EXCL`、`--expect-base`、`appended_at_phase3`、`keep 的 blob 行数`、`基线时点声明`、`-gt 100`、`grep -v`＋`六正项`、`本表除 AC6 外`、`合取判读`、`knowledge-usage-log`），行号即第 1 节所列。
- AC14 行（第 512 行）与修订前原文逐字一致，未动。
- 修订未引入版本号复述（版本只认 `.tad/version.txt`）。

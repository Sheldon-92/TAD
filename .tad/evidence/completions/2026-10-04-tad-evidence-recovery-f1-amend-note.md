# 完工说明 — 证据载体恢复执行链 · F1 设计增补步

- 链：证据载体恢复执行链（TASK-20261004-EVIDENCE-CARRIER-RECOVERY-EXECUTION）
- 执行步：tad-evidence-recovery-f1-amend-01（角色 Alex，设计增补／delta）；激活包 `.tad/evidence/activation-packages/tad-evidence-recovery-f1-amend-01.md`
- 依据：PM F1 裁定 `.tad/evidence/pm/2026-10-04-evidence-recovery-f1-ruling.md`（修正形状五点＋AC12 口径）
- **状态：增补已落 HANDOFF 本体，待 PM 核（本步不自判关闭）。** 只改 HANDOFF 一件；零 git 写操作；仓外零写；HANDOFF frontmatter／status／Gate 2 节未动；17 件处置结论未动。

## 1. Step 0 路径断言

- 仓根＝`/home/hatch/workspace/yun-sync/TAD`（`pwd` 与 `git rev-parse --show-toplevel` 双验一致）；被增补本体、裁定、停步报告、停步说明四件均在册后才动手。

## 2. 增补落点表（(a)–(e)，行号为修订后行号）

| 项 | 落点（HANDOFF 章节＋行号） | 内容摘要 |
|---|---|---|
| (a) 新 outcome 类定义 | §4.2 C1，L209（行形枚举增 `embedded-repo`）、L212（类定义） | 新类名 `embedded-repo`（全设计一词）：专记 (i) 分支 gitlink 条目前缀之下的盘上文件、(ii) 路径任一组件为 `.git` 的文件；写明其内容由嵌入仓库 git 结构＋分支 gitlink 指针承载、逐件入树不可能也不应该 |
| (a) 计数口径 | §4.2 C1，L213；§4.2 C5，L231 | 此类行 outcome 直接置 `embedded-repo`、不入同步队列（FR4 队列条件天然排除）、**不计 TOTAL_NOCARRIER**：四锚复算盘上集 A 先剔除此两类（与 EXCL 同为剔除集，等式两侧同口径）；C5 看守复算同适用，防每轮恒生假差额 |
| (a) S1 口径注记落点与文本 | §4.2 C1，L214；§7 FORBIDDEN，L448 | 落点写死：S1 summary 文末由续跑 Blake 追加 `## 口径增补（2026-10-04，F1）` 一节，正文逐字文本已在 L214 给全；§7 对 S1 summary 的只读约束开此唯一例外（只许追加、不许改原文） |
| (b) C3 前置守卫 | §4.2 C3，L224 | 前置自检增「载体冲突守卫」：队列行与处置表任一路径命中 gitlink 前缀之下（前缀本体除外）或含 `.git` 组件，即在 read-tree 之前逐行扫描拦截——输出全部命中路径清单、退出码 2 停步；不许静默跳过、不许降级警告 |
| (c) AC6 改写 | §9.1 表行 6，L517 | NOCARRIER 等式的盘上集剔除口径补 `embedded-repo` 两类（与 EXCL 并列），等式两侧同口径；STALE／BRANCH_ONLY 两断言原文未动 |
| (c) AC7 改写 | §9.1 表行 7，L518 | 队列定义排除 outcome=`embedded-repo` 行；新增断言该类恰 40 件（防修正件静默消失）；逐件 sha 全量比对与 mismatch＝0 强度未降。期望证据同步更新 |
| (c) AC15 改写 | §9.1 表行 15，L526 | 期望态收紧为唯一形态：spike-work 路径恰一条条目且为 `160000 commit d12b4250…` 原值；删除原 drop 备选形态（处置已定稿 keep、PM 核准）——指针被普通树替换即 FAIL，无第二形态可过 |
| (d) 回滚重跑序 | §6 Phase 3 新增「续跑（F1 修正后）」小节，L385–395（步骤 1–5） | 回滚至锚 `8713ea4e…`＋清单 outcome 回退 → 队列修正（40 件转 `embedded-repo`＋S1 summary 追加注记节）→ 守卫落地＋补两件夹具验 exit 2（原三态复跑）→ 按原步骤重跑 → 续 Phase 4/5；首轮报告原文件续写「续跑」节。期望值在步骤 4（L392）写明为**期望、非判据放宽**：synced 8,719、mismatch 0、gitlink 160000 原样、新尖父＝锚 |
| (e) AC12 指纹法 | §9.1 表行 12，L523 | 判据改写为指纹法两件合取：`.gitignore` sha256 与 §2.2 登记指纹 `3109c530…` 全等 ∧ `git ls-files` 例外集合与登记 3 件 diff 空；与 PM 裁定口径（指纹一致＋忽略集实测未漂移即 PASS）逐字对齐。期望证据与基线列同步更新 |

## 3. 修订后 HANDOFF 自验

- 字节数：**67,508 B**（修订前 61,816 B）；行数：647（修订前 634）
- sha256：`b94fa94f8b93a30558346351ed057fa57d48f6005a32161f180d3c1380868626`（修订前 `4c45cac5…`，即 Gate 2 增补后版本，与停步说明记录一致）
- 章节在册：§4.2 C1（L207 起）／C3／C5、§6 Phase 3 含续跑小节（L385）、§7、§9.1 表行 6／7／12／15 均 grep 复验在册；新类名 `embedded-repo` 全文一致使用（C1／C5／AC6／AC7／续跑小节共 8 处命中，无异名）
- 未动面：frontmatter（task_type／gate4_delta／tad_scope 等）、Handoff Version、Gate 2 节、附录 A 处置草案、AC 其余各行判据强度

## 4. 读取清单回执（打勾）

- [x] PM F1 裁定 `.tad/evidence/pm/2026-10-04-evidence-recovery-f1-ruling.md`——已读（修正形状五点＋AC12 口径，本步判据正本）
- [x] Blake 停步报告 `.tad/evidence/pm/2026-10-04-evidence-recovery-first-sync-report.md`——已读（差额 40 件全量清单；§7 建议三条仅作素材，处置形状以 PM 裁定为准）
- [x] 被增补本体 HANDOFF 全文 634 行——已逐节读（§4.2 清单口径、C1–C6、§4.7、§6 Phase 3、§9.1 AC6/AC7/AC12/AC15 及全文）
- [x] 本段停步说明 `.tad/evidence/completions/2026-10-04-tad-evidence-recovery-impl-p25-note.md`——已读（AC1–AC16 逐条自验现状、Step 0 登记指纹）
- [x] 规程侧：激活壳 `~/workspace/skills/tad-alex/SKILL.md`、仓根 `AGENTS.md`、`.tad/project-knowledge/principles.md`、`patterns/_index.md`——已读

## 5. 待 PM

按裁定对 (a)–(e) 逐项核（读段＋grep）；核过后 Blake 按 §6 Phase 3 续跑小节续跑（回滚→队列修正→守卫→重跑→Phase 4/5）。

# 完工说明（第二段）→ 停步说明：证据载体恢复执行链 实施 Phase 2–5

- 链：证据载体恢复执行链（TASK-20261004-EVIDENCE-CARRIER-RECOVERY-EXECUTION）
- 执行步：tad-evidence-recovery-impl-p25-01（角色 Blake）；激活包 `.tad/evidence/activation-packages/tad-evidence-recovery-impl-p25-01.md`
- **状态：停步待 PM 裁定（非完工）。** Phase 2、Phase 3 已执行；Phase 3 对账断言 AC6／AC7／AC15 不过，按 HANDOFF Phase 3 第 4 步与 §4.7 停步。Phase 4 推送未执行、Phase 5 看守未开工、COMPLETION 未写、完事卡未落。停步报告正本：`.tad/evidence/pm/2026-10-04-evidence-recovery-first-sync-report.md`。

## 1. 读取清单回执（打勾）

- [x] HANDOFF 增补后全文（634 行，§1–§12＋附录 A）——已读
- [x] PM 核准文件 `.tad/evidence/pm/2026-10-04-evidence-recovery-17items-ruling.md`（2,244 B）——已读
- [x] Phase 0 记录 `.tad/evidence/completions/2026-10-04-evidence-recovery-phase0-note.md`（四锚＋登记基线＋48 件归因名录）——已读
- [x] 执行版清单样本（首尾行＋programmatic 全量解析：13,130 行、class 分布、队列构成）——已读
- [x] 处置表全文（17 行＋表头）——已读
- [x] 第 16 件备案件 `.tad/evidence/pm/2026-10-04-termination-secret-isolation-check.md`（全文；结论核可，只记结论不引原文）——已读
- [x] Gate 2 合并裁定 `.tad/evidence/pm/2026-10-04-evidence-recovery-gate2-merged-ruling.md`（全文含 PASS 销账行）——已读
- 规程侧：仓根 AGENTS.md、principles.md、patterns 索引＋命中条目（ac-verification／shell-portability）、evidence-collection.md、COMPLETION 模板、scan-downstream-versions.sh 形态先例、session-state 相关行——已读

## 2. Step 0 断言记录（全过，实测）

- 仓根＝`/home/hatch/workspace/yun-sync/TAD`；当前分支 main；仓外零写入（唯一仓外动作：/tmp 临时克隆与夹具，及本说明所述只读命令）。
- maintainer-evidence 本地尖＝origin 跟踪尖＝`8713ea4eb88b53f74f70f50477143a6fec05d22a`；main 尖＝`5619b09556863b6d2587d6fa71b46e71bb8b1174`。
- `.gitignore` sha256＝`3109c53025688cc5ad6d1d8f4b5b908b4f88d0c1db7358a1f96e58be0081bfab`（与基线一致；本段结束时复算仍一致）。
- reflog maintainer-evidence 仅 2 条（创建＋2026-09-06 chore 同步）。
- 工作树跟踪修改恰 20 件，按 Phase 0 登记的类别构成逐类相符（复活票回写 1／handoffs 删除 12／KA 修改 2／保留集 5）。
- 提交身份：仓 config 与旧尖作者同为 Sheldon <zhaos948@newschool.edu>。
- 队列前检：pending 队列 8,759 件盘上缺失 0；branch-only 行 16；execution-manifest 与 branch-disposition 均不在清单行内（与第一段实测确认一致）。

## 3. 本段已执行（按序）

1. **处置表回填定稿**：17 行 `ruling_ref` 由 `PENDING-PM` 全量回填为 PM 核准文件路径（回填后 5,598 B）；AC3 原样实跑 PASS（17 行、含 gitlink 行、drop 行 origin 对照与原件当场重算全等、PENDING 残留 0）；同步后复跑仍 PASS。
2. **同步脚本**：`.tad/scripts/sync-maintainer-evidence.sh`（11,012 B，bash 入口＋内嵌 python3 驱动，临时索引 plumbing，不用工作树索引与 `git add`）；内嵌 python `py_compile` PASS；AC5 原样实跑 PASS。
3. **Phase 2 自测三态**（/tmp 临时克隆，夹具含普通件／CJK＋空格路径件／可执行位件／stale 件／keep／drop／gitlink 行）：正常态 exit 0（逐字节与 sha 对账、100755 位、drop 消失、keep 在位、gitlink 指针原样、父＝旧尖）；NO-OP 态 exit 3（`--expect-base` 与默认后继断言两路）；失败态 exit 1 且 ref 不动（缺文件队列；另 commit-tree 身份失败一例同样 ref 不动、清单未改）。自测未覆盖「队列路径位于 gitlink 前缀下」形态——即 F1 的漏检面，如实记。
4. **Phase 3 首轮真跑**：exit 0；新本地尖 `982e5580649f2da53cb3531b2f91449d893c6fd9`（父＝旧尖）；入账 8,759 件（47,468,559 B）；drop 7 件落地；清单 outcome 终态 synced 8,759／kept-branch-only 9／dropped-by-ruling 7。
5. **Phase 3 对账**：AC7 mismatch 36、AC15 gitlink 被替换、AC6 NOCARRIER 等式差 36——根因一处：冻结队列含 gitlink 前缀 spike-work 下 40 件（详见首轮报告 §2–§3 差额清单）。同步后四锚复算：NOCARRIER 44（36 差额＋8 冻结后残差）／STALE 0／CARRIED 13,078／BRANCH_ONLY 9。缺口之外全部相符。
6. **首轮报告**已落盘（停步版，含四锚对照、差额全量清单、12 条 CJK 点名、推送节标 BLOCKED、AC6 脚本原文附录、修复建议三条）。

## 4. 未执行（等 PM 裁定）

- Phase 4 推送：未执行。新尖不可推送（AC15 已破）；未触碰 grokbox 通道；origin 跟踪尖未变；无需远端回滚。
- Phase 5 看守：未开工。`.tad/scripts/evidence-freshness-check.sh` 与 `.tad/evidence/pm/evidence-freshness-log.md` 未落盘；usage log 未追加；COMPLETION 未写；本段完事卡未落。
- 回滚：未执行（§4.7 锚完好，等裁定后按裁定走）。

## 5. AC1–AC16 逐条自验（自评，Gate 3 独立双审为准）

| AC | 自验结论 | 依据 |
|---|---|---|
| AC1 | 未达成（执行中停步） | 同步与 outcome 回写已成；首轮报告已落盘；推送与三值同尖未成 |
| AC2 | PASS（自验） | 回填只改 `ruling_ref` 一列；17 值全等核准文件路径；决策与处置表草案态一致 |
| AC3 | PASS | 原样断言两次实跑（回填后、同步后）均 17 行 True |
| AC4 | 未验（BLOCKED） | 推送未执行；报告 §6 已设三值并列节并标注未执行 |
| AC5 | PASS | 原样断言实跑 PASS（plumbing 齐、`git add` 与 main-ref 字面计数 0） |
| AC6 | FAIL | STALE＝0 ✓、BRANCH_ONLY＝9 ✓、CARRIED 自洽 ✓；NOCARRIER 等式差 36（spike-work `.git/**`） |
| AC7 | FAIL | queue＝synced＝8,759；mismatch 36（全为 spike-work `.git/**`，清单 sha 与盘上一致、树内无条目） |
| AC8 | PASS | 新尖父＝`8713ea4e…`（`rev-parse NEW^` 断言实跑）；旧尖 reflog 仅 2 条 |
| AC9 | PASS | `.gitignore` 字节数 5,211、sha256 与设计基线一致、本段零改动（∧AC8 成立） |
| AC10 | PASS（按 PM 核准的登记基线判读） | main 尖未变；跟踪修改 20 件与 Phase 0 登记类别构成逐类相符；`.gitignore` 指纹未变 |
| AC11 | PASS | 原样断言实跑：跟踪修改 20 件中 evidence/archive 前缀 0 件 |
| AC12 | FAIL（判据缺陷，另报） | 原样脚本两 find 锚点在现行 `.gitignore` 中均 −1（基线即不存在 `!` 例外行，R1 例外为强加 tracked）；指纹未变证明范围未漂移，需 PM 给 Gate 3 判读口径 |
| AC13 | 未达（Phase 5 BLOCKED） | 看守脚本与日志未落盘 |
| AC14 | 未达（Phase 5 BLOCKED） | 同上（阈值 grep 无对象） |
| AC15 | FAIL | 旧尖时点 gitlink 原样 ✓；新尖中 gitlink 已被普通树替换（根因见首轮报告 §2） |
| AC16 | 未达（Phase 5 BLOCKED） | COMPLETION 未写（链未收口，不预写） |

## 6. 自检留痕

`.tad/evidence/ralph-loops/TASK-20261004-EVIDENCE-CARRIER-RECOVERY-EXECUTION_state.yaml`（loop 2：发现 F1 阻断＋F2 判据缺陷，处置＝停步报 PM）。

## 7. 待 PM 裁定项

1. F1 处置路径（首轮报告 §7 建议三条：40 件退队列＋清单新 outcome 与 S1 口径注记／脚本加 gitlink 前缀与 `.git` 组件前置守卫／回滚本地尖后重跑）。
2. AC12 的 Gate 3 判读口径（指纹法替代锚点法，或补 Gate 2 增补）。
3. 裁定后本段续跑范围：Phase 4 推送、Phase 5 看守、COMPLETION 与完事卡均在续跑内完成，本说明届时被完工版取代。

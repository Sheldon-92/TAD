# Blake 完工说明（停步版）— 证据载体恢复执行链 · 续跑步（Phase 3 续跑完成；Phase 4 停步）

- task_id：`TASK-20261004-EVIDENCE-CARRIER-RECOVERY-EXECUTION`
- step_id：`tad-evidence-recovery-impl-resume-01`（前段停步说明：`.tad/evidence/completions/2026-10-04-tad-evidence-recovery-impl-p25-note.md`）
- role：Blake（Execution Master）；tad_scope：full；channel：internal-subagent
- 日期：2026-10-04（EDT）
- 状态：**STOPPED at Phase 4**——Phase 3 续跑五序第 1–4 序全完且断言全过；第 5 序（Phase 4 推送）因 grokbox 隧道不可达按 §4.5 失败处置停步（§8.4 口径：非实施 FAIL）；Phase 5 未开工随停步待续。本地新尖与全部成果保留完好，推送不需重跑同步、只需隧道恢复后续推。

## 1. 回滚与队列修正记录

- **Step 0 断言全过**：仓根 `/home/hatch/workspace/yun-sync/TAD`；当前分支 main；maintainer-evidence 本地尖＝首轮新尖 `982e5580649f2da53cb3531b2f91449d893c6fd9`；origin 跟踪尖＝锚 `8713ea4e…`；main 尖 `5619b095…`；`.gitignore` sha256＝`3109c530…1bfab`（与登记指纹全等）；跟踪修改 20 件（与 Phase 0 登记基线一致）。
- **回滚**：`git update-ref refs/heads/maintainer-evidence 8713ea4e… 982e5580…`（带旧值断言）成功，本地尖回锚；执行版清单首轮回写 outcome 全量回退（synced 8,759／dropped-by-ruling 7／kept-branch-only 9 → pending，sha／commit 清空），回退后清单 3,426,326 B 与 Phase 0 冻结值逐字全等（回滚无损的旁证）。
- **队列修正**：以锚尖 `git ls-tree` 实测 gitlink 条目恰 1 条（`spike-work`）；命中两类路径（gitlink 前缀下＋含 `.git` 组件）的清单行恰 40 件，outcome 置 `embedded-repo`（class 不改、行数不增删），与首轮差额清单集合一致；队列＝8,719 件。S1 summary 文末按写死逐字文本追加「口径增补（2026-10-04，F1）」节（只追加，14,450 → 14,985 B，原文未动）。

## 2. 守卫夹具结果

- 同步脚本 `.tad/scripts/sync-maintainer-evidence.sh` 已加装 C3 载体冲突守卫（read-tree 前扫描队列行＋处置表行；命中输出全部命中路径清单、退出码 2 停步），脚本现 12,804 B；bash 语法与内嵌 python 编译检查过，AC5 原样复跑 PASS。
- /tmp 临时克隆 `/tmp/sync-test-resume`（尖＝锚）四态实测：① 守卫夹具（gitlink 前缀下文件 1 件＋`.git` 组件路径 1 件）→ exit 2、两件命中全量列出、ref 不动、处置表 gitlink 本体行不误报；② 正常态（普通／CJK＋空格／可执行位 100755／stale）→ exit 0、新尖父＝锚、keep 在位、drop 消失、gitlink 原样、清单回写正确；③ NO-OP → exit 3、ref 不动；④ 失败中止（队列含盘上缺失件）→ exit 1、ref 不动。原三态复跑全过＋守卫新态过，方进重跑。

## 3. 续跑断言与新分支尖

- 重跑 exit 0（约 34 秒），**新分支尖 `459ab78f5aa54dc1056522780607dcfeb473c647`**，父＝锚 `8713ea4e…`，synced 8,719 件、drop 落地 7 件、清单 outcome 终态：synced 8,719／pending 4,355（carried 行）／kept-branch-only 9／dropped-by-ruling 7／embedded-repo 40。
- 同步后四锚（S1 复跑序列逐字＋F1 剔除口径）：**NOCARRIER=14／STALE=0／CARRIED=13,074／BRANCH_ONLY=9**。残差 14 件全为本链冻结后自产文书与清单 instrument 件（不在执行版清单行内），已在首轮报告续跑节逐件列名，归看守下一轮。
- 首轮报告续跑节已落：`.tad/evidence/pm/2026-10-04-evidence-recovery-first-sync-report.md`（回滚行／队列修正行／守卫夹具行／续跑断言行／推送三值行）。

## 4. AC 自验表（§9.1 番号为准）

| AC | 结论 | 依据 |
|----|------|------|
| AC1 | PASS | 清单逐行 JSON 解析成功；outcome 终态分布见 §3 |
| AC2 | 部分（同步脚本半 PASS；看守脚本半未及） | 同步脚本 shebang／语法／编译实测过；看守脚本属 Phase 5、随停步未开工 |
| AC3 | PASS（沿前段） | 处置表本步零改动，前段两次原样实跑 PASS 的状态保持 |
| AC4 | PASS | 原样脚本本步复跑：drop 不在树、keep 的 blob 行全在树 |
| AC5 | PASS | 守卫落地后原样复跑（grep 全项＋`git add` 零命中） |
| AC6 | PASS | 三断言独立判读全过：STALE=0；NOCARRIER=14＝盘上集减清单路径集（同管线同口径）；BRANCH_ONLY=9＝keep blob 行数 |
| AC7 | PASS | queue 8,719＝synced 8,719、mismatch 0、embedded-repo 恰 40 |
| AC8 | PASS | 新尖父＝锚 `8713ea4e…` |
| AC9 | **未完**（本地合取支 PASS，origin 支待推送） | origin 跟踪尖仍锚值，随 Phase 4 停步未达 |
| AC10 | PASS | 按 Phase 0 登记基线判读：main 尖 `5619b095…` 未变、跟踪修改恰登记的 20 件、本步新增 0 |
| AC11 | PASS | main reflog 顶为开工前既存收口提交，本链零 main 提交 |
| AC12 | PASS（指纹法，PM 定案口径） | `.gitignore` sha256 与登记指纹全等＋例外集合 diff 空，本步复跑 |
| AC13 | 未跑 | Phase 5 未开工（看守脚本与首跑日志） |
| AC14 | 未跑 | Phase 5 未开工（负控与字面 grep） |
| AC15 | PASS | 新尖该路径恰一条 `160000 commit d12b4250…`（F1 收紧后唯一期望态原样命令） |
| AC16 | PASS（沿 Phase 1 核准） | 第 16 件维持 keep，本次复算其分支件在 BRANCH_ONLY 集合内在位 |

## 5. Phase 4 停步实况与续行清单

- 停步原因：2026-10-04 续跑时点三次 `ssh box@grokbox` 均于连接阶段失败——① `kex_exchange_identification: read: Connection reset by peer`；②③ `nc: proxy read: Broken pipe / Connection closed by UNKNOWN port 65535`（隧道 CONNECT 阶段被掐的已知签名）。间隔重试（含等 45 秒一轮）仍不可达。按 §4.5 失败处置：不许 VM 直推、不许 force-push、不许换路、不落盘凭据——全部遵守；未做任何 grokbox 侧手工补提交。
- 推送三值（停步时点）：本地尖 `459ab78f5aa54dc1056522780607dcfeb473c647`／origin 跟踪尖 `8713ea4eb88b53f74f70f50477143a6fec05d22a`／grokbox 侧值不可测（不可达）。
- **续行清单（隧道恢复后，任一 Blake/PM 按序执行，不需重跑同步）**：① `ssh box@grokbox "cd /home/box/云同步/TAD && git rev-parse maintainer-evidence"` 须等于本地新尖 `459ab78f…`（不等则等 Syncthing 收敛后复查；命中 `.sync-conflict` 停步报 PM）；② 写死推送命令推 maintainer-evidence；③ VM 侧 `git fetch origin` 后验三值同尖，补记首轮报告续跑节；④ Phase 5：看守脚本落盘＋/tmp 负控一次＋真跑首行落日志（预期 VERDICT=OK；其 NOCARRIER 读数将含本说明与报告续写等停步期新增件，仍远低于阈值 100）；⑤ usage log 追加一行（A12）；⑥ COMPLETION 定稿（模板四节，human CHECK 记「CHECK 待人」）。
- 本步动过的 git 写仅 W1–W4 围栏内：update-ref（回滚＋同步各一次，均限 maintainer-evidence）、hash-object -w（经脚本）、grokbox 推送**未发生**、§7 CREATE/MODIFY 清单内工作文件落盘（清单、S1 summary 追加节、同步脚本、首轮报告、本说明、ralph 状态件）。

## 6. 读取清单打勾回执

- [x] tad-blake 薄壳 skill（`~/workspace/skills/tad-blake/SKILL.md`）
- [x] 仓根 `AGENTS.md`（全文）
- [x] `.tad/project-knowledge/principles.md`（全文）
- [x] `.tad/project-knowledge/patterns/_index.md`＋命中 3 条全文（`ac-verification.md`、`shell-portability.md`、`evidence-collection.md`）
- [x] `.tad/project-knowledge/references/gate-canonical.md`（全文，判据以 Gate 3 节与本步 §9.1 逐行为准）
- [x] HANDOFF F1 增补定稿版（全文 647 行，sha256 `b94fa94f…8626` 先断言后开读）
- [x] F1 裁定 `.tad/evidence/pm/2026-10-04-evidence-recovery-f1-ruling.md`（含核销行）
- [x] 首轮报告 `.tad/evidence/pm/2026-10-04-evidence-recovery-first-sync-report.md`（全文＋附录）
- [x] 前段停步说明 impl-p25-note（全文）
- [x] 17 件核准 `.tad/evidence/pm/2026-10-04-evidence-recovery-17items-ruling.md`
- [x] Phase 0 记录 evidence-recovery-phase0-note（全量行号版）
- [x] `.tad/active/session-state.md` 头部多链索引
- [x] 激活包 `tad-evidence-recovery-impl-resume-01.md`（纪律件：仓外禁写／路径断言／停步线／判据口径四点）

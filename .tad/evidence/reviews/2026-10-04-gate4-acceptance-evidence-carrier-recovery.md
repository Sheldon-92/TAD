# Gate 4 验收 — 证据载体恢复执行链（evidence-carrier-recovery-execution）

- 验收步：Gate 4（Alex，Solution Lead；独立会话，与实施者 Blake 及 Gate 3 两路评审均不同会话）
- 验收对象：票 `.tad/active/TICKET-20261004-evidence-carrier-recovery-execution.md`（task_id `TASK-20261004-EVIDENCE-CARRIER-RECOVERY-EXECUTION`）
- 判据：票面范围四项＋红线；PM 载体裁定 `.tad/evidence/pm/2026-10-04-evidence-revival-carrier-ruling.md`（看守参数与重议触发口径源）
- 证据面：Gate 3 CODE verdict（含勘误节）与 SAFETY verdict（均 PASS）、COMPLETION、首轮报告（含续跑/续行/续行二步节）、核准文件、备案件、看守日志、usage log
- 方法：结论不采信自报；关键项由本席在验收时点以只读命令独立抽核（见「独立抽核记录」），其余逐项对盘核对证据件

## 结论：PASS

票面四项全部落地，红线全守；Gate 3 双审均 PASS 且其 P2 均为非条件观察。human CHECK 记「CHECK 待人」，本验收不代判。

## 逐项对票表

| 票面项 | 判据 | 验收核对 | 结果 |
|---|---|---|---|
| ① 17 件逐件处置（强制首步） | branch-only 16＋gitlink 1 逐件定去向，PM 核准后才许动载体 | 核准文件 `.tad/evidence/pm/2026-10-04-evidence-recovery-17items-ruling.md` 在册：定稿 keep 10／drop 7 照准；处置表盘上实测恰 17 行、keep 10／drop 7、`PENDING` 残留 0；裁定 2 对照两列已填、自动转保留无触发；第 16 件经备案件（7 类令牌形态扫描命中 0＋全文目检）核可保留、悬置条件销清；gitlink 件按 keep 以指针保全（见红线行）。CODE 路 AC3/AC4（含核准→回填→同步的 mtime 时序互证）PASS | PASS |
| ② 同步脚本 | 显式清单入分支、朴素 add 不许静默空转、`-z`/`-print0` 安全管线、同步后四锚断言收尾 | `.tad/scripts/sync-maintainer-evidence.sh` 在盘（12,804 B、可执行、本席 `bash -n` 通过）；临时索引 plumbing＋NUL 管线＋逐件 `hash-object -w` 当场 sha 形态经 CODE 路逐项实跑（AC5）与 /tmp 克隆四态实测（正常／NO-OP／失败中止／F1 守卫 exit 2）PASS；首轮 F1 暴露的 gitlink 前缀静默丢失已由守卫＋设计增补关闭 | PASS |
| ③ 首轮全量补同步＋推送验远端尖 | 冻结队列全量入分支；推送 origin 并验远端尖与本地同尖 | 冻结队列 8,759 件，F1 修正后实同步 8,719 件（40 件 embedded-repo 单列），CODE 路独立复算 AC7：queue＝synced＝8,719、mismatch 0；同步后四锚 STALE=0／BRANCH_ONLY=9 与看守首跑两行一致。推送经 grokbox 通道完成（续行二步记录在首轮报告）；**本席验收时点三值独立抽核：本地尖＝origin 跟踪尖＝`git ls-remote` 远端实测尖＝`459ab78f5aa54dc1056522780607dcfeb473c647`**（父＝锚 `8713ea4e…`），AC8∧AC9 合取成立 | PASS |
| ④ 新鲜度看守落地 | 脚本落 `.tad/scripts/`、记录落 `.tad/evidence/pm/`；参数认载体裁定二（NOCARRIER>100 或尖龄>21 天报警；每链收口必跑、无链月份月度补跑；责任人 TAD PM） | `.tad/scripts/evidence-freshness-check.sh` 在盘（2,973 B、可执行、`bash -n` 通过）；日志 `.tad/evidence/pm/evidence-freshness-log.md` 头部参数与裁定二逐项一致；运行记录两行（2026-10-05T03:24:06Z／03:25:20Z），最新行 VERDICT=OK、TIP 为新尖、TIP_AGE_DAYS=0。本席未在验收中重跑脚本：该脚本按设计每次运行向日志追加一行，重跑会产生验收件之外的写入；其可运行性以可执行位＋语法检查＋今日两行真实运行记录三方成立 | PASS |
| 红线：`.gitignore` 未改 | 指纹与登记值全等 | 本席实测 sha256＝`3109c53025688cc5ad6d1d8f4b5b908b4f88d0c1db7358a1f96e58be0081bfab`，与 F1 增补后 AC12 登记指纹全等 | PASS |
| 红线：SC3 未动、3 件例外未回退 | 主仓两树 tracked 集合不变 | 本席实测 `git ls-files '.tad/evidence/*' '.tad/archive/*'` 恰 3 件，与例外集逐件相同：`.tad/archive/next/NEXT-completed-through-20261004.md`、`.tad/evidence/pm/downstream-versions.md`、`.tad/evidence/reviews/2026-09-15-gate4-acceptance-platform-adapters.md`，无增无减 | PASS |
| 红线：入载体逐件当场 sha | 不许拿 manifest bytes 当内容凭据 | 脚本逐件 `hash-object -w` 当场重算并回写清单；CODE 路 AC7 以独立进程全量复算（8,719 件逐件比对分支 blob sha，mismatch 0）证实 | PASS |

## 独立抽核记录（本席验收时点实测，非转述）

1. **三值同尖**：`git rev-parse refs/heads/maintainer-evidence`＝`459ab78f…`；`refs/remotes/origin/maintainer-evidence`＝`459ab78f…`；`git ls-remote origin refs/heads/maintainer-evidence`＝`459ab78f…`。三值全等，现时成立（非仅推送时点成立）。
2. **gitlink 保全**：`git ls-tree maintainer-evidence -- …/spike-work` 恰一条 `160000 commit d12b42505f2dfd2b5d8f5de51cc6e3d0a43aa0fa`，与定稿原值全等，未被普通树替换。
3. **STALE=1 归因**：见下节，本席以分支 blob 与盘上文件逐行 diff 独立核实，归因成立。
4. **usage log 追加行在册**：盘上文件第 6 行即本链 Phase 5 引用行（chain＝本链 task_id、step＝Phase5、knowledge 指向 S1 盘点产物与裁定件），全行可解析、键集与既有行一致（SAFETY S12 同判）。重议触发（载体裁定三：累计满 50 行后统计跨链引用）尚未达触发线（现 6 行），本验收不提前翻案。

## STALE=1 归因核定与看守判读口径

**归因成立。** 本席实测：分支内 `.tad/evidence/knowledge-usage-log.jsonl` 为 5 行，盘上为 6 行，`diff` 结果恰为单行追加（`5a6`），即增补 A12 要求本链在 Phase 5 追加的本链引用行（ts 2026-10-05T03:27:00Z，晚于同步完成与看守两行运行记录的 03:24:06Z／03:25:20Z——两行读数 STALE=0 与此时序一致）。CODE 路勘误节的复算读数（评审时点 STALE=1、唯一文件即该日志）与此逐点吻合。该 STALE 是设计自带动作（收口追加引用行）在同步之后发生的预期漂移，非同步缺陷、非载体停摆信号；该件已在载体内，盘上副本仅因 append-only 追加而更新，下一轮同步自然吸收。

**看守判读口径（本验收写明，后续各轮按此判读）**：看守报警只认载体裁定二的两条阈值——复算 NOCARRIER＞100 件，或分支尖最新提交超 21 天未更新。STALE 读数本身不是报警条件：对 append-only 同步对象（如 usage log）因同步后追加产生的 STALE，属预期动态，判读时按「已归因、待下轮吸收」记，不判停摆、不立票。NOCARRIER 中冻结后新增文书形成的残差同理属预期动态（看守首跑读数 21→24，远低于 100 阈值），仅当其越过阈值或尖龄越线才触发报警处置。

## 非条件备注（承 Gate 3 两路 P2，不构成关闭条件）

- grokbox 侧 `.git/logs/` 内 2 件 Syncthing 冲突副本按 F4 裁定冻结在位（SAFETY P2-1）：属同步治理层存量事项，建议 PM 在链外向 GM 同步治理面登记跟踪，不在本链处置范围。
- HANDOFF §9.1 AC10 字面命令仍为设计时点形态（CODE P2-1）：本链已按 A7 登记基线正确判读；建议 PM 在模板层把「基线以登记值为准」写进命令形态，防后续链复制误导。
- 首轮报告所附 AC6 脚本为 F1 前版本（CODE P2-2）：结论已经三方独立复算支撑，不受影响；后续链宜随报告附最终口径脚本原文。

## human CHECK

COMPLETION 头部记「CHECK 待人（未冒充）」、`gate3_verdict` 标记位按纪律留待过门后填——形态属实（SAFETY S13 同判）。**本验收结论为 PASS；human CHECK 待人，Gate 4 不代判。** 票的关闭与完事卡由 PM 在人 CHECK 后收口。

- 自报行（本行不计入被测内容）：验收件正文 7,950 B／sha256 `14ec97aef6ba7bd9cb76c843e37cbeac82aa74ad7a45d76af6016fb25215eb8b`，落盘后复算一致。

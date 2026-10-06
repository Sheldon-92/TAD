# Gate 3 SAFETY 路评审 — 证据载体恢复执行链（evidence-carrier-recovery-execution）

- 评审步：`tad-evidence-recovery-gate3-safety-01`（独立会话，与 CODE 路互不可见）
- 评审对象：HANDOFF `HANDOFF-2026-10-04-evidence-carrier-recovery-execution.md` 的实施全程（Phase 0–5，含 F1 修正续跑与 F4 裁定续行）
- 红线源：票红线、载体裁定（`.tad/evidence/pm/2026-10-04-evidence-revival-carrier-ruling.md`）、HANDOFF §4.6 围栏 W1–W4 与红线节
- 评审方法：全部结论由本会话只读命令实测（git 只读、ssh 只读），不采信实施方自报数值；与自报的对照仅作一致性记录

## 结论：PASS（P0=0／P1=0／P2=1，P2 为观察项、不构成关闭条件）

## 逐项核查表

| # | 核查项 | 判据 | 本会话实测 | 结果 |
|---|---|---|---|---|
| S1 | `.gitignore` 未改 | sha256 与登记指纹全等 | `3109c53025688cc5ad6d1d8f4b5b908b4f88d0c1db7358a1f96e58be0081bfab`，与 F1 增补后 AC12 登记值全等 | PASS |
| S2 | SC3 未动 | 主仓两树 tracked 集合不变 | `git ls-files '.tad/evidence/*' '.tad/archive/*'` 恰 3 件，与 R1 例外集逐件相同（archive/next 完事归档 1 件、evidence/pm 台账 1 件、evidence/reviews Gate 4 件 1 件） | PASS |
| S3 | 3 件例外未回退 | 同 S2 集合对照 | 3 件全在册、无增无减 | PASS |
| S4 | main 未被本链写（W4） | main 尖与基线全等 | `5619b09556863b6d2587d6fa71b46e71bb8b1174`，与 HANDOFF AC10 基线全等 | PASS |
| S5 | git 写只及本分支（W1/W2） | reflog 与各 Phase 报告逐条对账 | reflog 仅 maintainer-evidence 一条 ref 的 4 个条目：基线提交→首轮同步尖→F1 回滚至锚→续跑新尖，与首轮报告/续跑说明的记录逐条对应；新尖父＝锚 `8713ea4e…`，纯快进、无历史重写 | PASS |
| S6 | drop 7 件未入任何载体 | 分支树＋主仓 tracked 双面零在册；清单 outcome 双面对账 | 7 件逐件实测：分支树在册 0、主仓 tracked 0；处置表 decision=drop 7 行与执行版清单 `dropped-by-ruling`=7 逐件对应（原件对照两列在册，自动转保留无触发与盘面一致） | PASS |
| S7 | 第 16 件悬置纪律 | 备案件销清在前、keep 定稿在后 | 备案件在盘（核查人/方法/结论三项齐）：7 类令牌形态扫描＋全文目检，通篇只有类别与形态描述、未引用核查对象任何字符串值原文，方法合裁定 3 与 AC16；备案件 mtime（2026-10-04T23:52:33Z）早于 PM 核准件（23:55:21Z），更早于一切同步动作；该件在分支树内以 kept-branch-only 在册，与定稿一致。本 verdict 不复述核查对象内容 | PASS |
| S8 | gitlink 保全 | 分支尖该路径为唯一期望态 | `160000 commit d12b42505f2dfd2b5d8f5de51cc6e3d0a43aa0fa`，与定稿全等；embedded-repo 40 件单列于清单、未入树（F1 口径） | PASS |
| S9 | 推送通道合规（W3） | 无 VM 直推、无 force、验同尖三值 | 本地尖／origin 跟踪尖／grokbox 侧 rev-parse 三值实测全等 `459ab78f5aa54dc1056522780607dcfeb473c647`；推送经 grokbox gh 内联 helper 的实施记录与远端快进形态（S5）互证；F4 停步—裁定—续行全程留痕，未绕过 `.sync-conflict` 停步纪律 | PASS |
| S10 | F4 两件冲突副本在位未动 | grokbox 侧只读查 | `.git/logs/refs/remotes/origin/` 下两件 `main.sync-conflict-20261004-*` 均在位，各 3,898 B，mtime 均为 2026-10-04 17:42:43 -0400（与首检记录一致、其后未动）；同目录活日志 `main` 3,910 B 亦未动 | PASS |
| S11 | 推送无凭据落盘/打印 | 脚本与完工说明凭据形态扫描 | 同步脚本、看守脚本、推送两份完工说明对令牌前缀/私钥块头模式扫描命中 0；仓内未跟踪项全为本链及他链在册文书与脚本两件，无凭据形态文件 | PASS |
| S12 | usage log 追加行合规 | 全行可解析、键集与既有格式一致 | 全 6 行 JSON 逐行可解析；本链追加行（第 6 行）键集与第 2–5 行既有格式逐字同集（chain/handoff/knowledge/purpose/step/ts），step=Phase5、knowledge 指向 S1 盘点产物与裁定件，合 A12 口径 | PASS |
| S13 | COMPLETION 如实 | human CHECK 不冒充、verdict 标记位留空 | COMPLETION 头部 `gate3_verdict` 明记「留空，待 Gate 3 双审过门后填」；human CHECK 记「CHECK 待人（未冒充）」 | PASS |
| S14 | 看守落地与首跑 | 脚本/记录落盘、首跑 VERDICT 与阈值口径 | 记录尾两行 VERDICT=OK（NOCARRIER 21→24，均 ≤100；STALE=0；TIP_AGE_DAYS=0；TIP 为新尖），与裁定二阈值口径一致 | PASS |

## P2 观察项（不构成关闭条件）

- **P2-1**：grokbox 侧 `.git/logs/` 内两件 Syncthing 冲突副本按 F4 裁定冻结在位（S10）。冻结是本链的正确处置（本链无权动它），但冲突副本长期躺在被同步的 `.git` 目录内，属同步治理层面的存量事项，建议 PM 在链外向 GM 同步治理面登记跟踪，不在本链内处理。

## 备注

- 本路只核红线与安全面；AC 逐行重跑、脚本正文围栏细核与四锚第二算归 CODE 路，本路未越界代判。
- 首轮报告中「瞬时读数成因未定」与看守首跑两次读数差（21/24）均由实施方如实留痕且不影响任何红线项，本路记录在案、不作问题计。

---
自报行（本行追加前实算，不计入被测内容）：正文 5,390 B／sha256 `953a4d79acb1c9e4153b89512461d4e2583a9587d480d3cbb316ecee3d875279`

# TAD 自查报告 R1（TAD PM 自主 review）

- 日期：2026-10-04
- 执行方：TAD PM（本席自查，非外部提案触发）
- 依据：用户 2026-10-04 指令——维护 TAD 是 TAD PM 本职，须自己摸清问题、定期 review、再优化
- 方法：全部结论来自当日查盘（git / 文件原文 / 安装器源码 / 下游逐仓扫描），不采信旧自述

## 盘面基线（2026-10-04 实查）

- 版本：`.tad/version.txt` = 3.0.0，`tad.sh` TARGET_VERSION = 3.0.0
- HEAD：`b78173b3`，与 origin/main 差异 0 / 0（已同步）
- 工作树：15 项未跟踪、7 项已改未提交、1 项已删未提交
- 仓体量：521M；skill SSOT `.agents/skills/` 共 63 项
- 下游：yun-sync 下 53 个仓带 `.tad/`；其中 22 个在 3.0.0，其余散在 1.5–2.44.1，2 个无 version.txt

## 问题清单（按严重程度）

### P1 强制力只覆盖一个平台

- 机器拦截（hooks）只有 Codex 有：`tad.sh` 第 1299 行注释明写 Codex hooks.json 生成「codex is the only target」。
- OpenCode / Cursor 的 hooks 适配是安装器自认的缺口：`tad.sh` 第 519 行注「Platform Adapters P2 — known gap」。
- 两平台至今无一次真机全链回归。「支持」是文档与探针证明的，不是实跑证明的。

### P2 自家状态文档与现实矛盾

- `NEXT.md` 第 9 行仍写「当前版本 2.44.5 → next patch 2.44.6」；现实是 v3.0.0 已发布。
- `NEXT.md` 第 15–20 行仍写 hillclimb「READY_FOR_GATE2、未交 Blake」；现实是 hillclimb 已落地（HEAD `b78173b3`），其 HANDOFF 文件已在工作树删除待提交。
- `ROADMAP.md` 停在 2026-09-02（v2.43.1），第 14 行仍写 Claude Code 与 Codex 共享状态；Claude 路径已在 v3.0.0 彻底移除。
- 仓根 `AGENTS.md` 头部自称「Runtime status (v3.1)」，与 `.tad/version.txt` 的 3.0.0 互相矛盾——连版本号本身在自家仓内就有两个口径。
- 这是用户 2026-10-03 批评的「文档系统只剩个形」在本仓的原图。

### P3 证据链尾巴未收口

- Gate 4 证据 `.tad/evidence/reviews/2026-09-15-gate4-acceptance-platform-adapters.md` 第 9 行仍为 CONDITIONAL PASS（verdict: PARTIAL）。其条件（commit 隔离）已由 `2fb80bf5` 入 origin/main 满足，证据文件本身从未改写为终态。
- 2026-09-15 的 COMPLETION 与三份 Claude 相关 HANDOFF 至今未跟踪入 git。
- `docs/pm/open-cards/` 整个目录未入 git：开跑卡/完事卡在盘上、不在仓里，双落只落了一半。
- §18 补缺的两个 Epic 文件夹（2026-10-03 落盘）同样未入 git。

### P4 下游版本无账

- 53 个下游仓版本散布 1.5–2.44.1 至 3.0.0，本仓内无任何台账文件可回答「谁在哪一版」；本报告的数字靠当场逐仓扫描得出。
- `TASK-20260916-CODEX-LEDGER-REVERIFY`（`.tad/active/TICKET-20260916-codex-ledger-reverification.md`）自 2026-09-16 挂起至今，无人推进，且文件本身未入 git。

### P5 知识沉淀停产、体量膨胀

- incidents 事件文件停在 2026-06 目录，`_index.md` 停在 2026-09-22；patterns 索引停在 2026-09-29。
- 仓体量 521M，`.tad/` 顶层目录六十余个，根目录并存多个历史层（supabase、experiments、spike-v3）；瘦身 Epic 立过，效果未验到数。

## 已核销的旧说法（查盘纠正记忆）

- 「P1P3 未 push」——错。`2fb80bf5` 已在 origin/main，本地与远端 0/0。
- 「hillclimb 还挂在 Gate 2」——错。已落地，HEAD 即其落地提交。

## 第一批优化（本轮开跑）

只打 P2 + P3，两者同源：状态面与证据面不实，正是本席近期翻车（自报与盘上不符）的框架级版本。

- Alex 先行设计：状态文档纠偏 + 防再过期机制、Gate 4 证据终态改写路径、未入 git 文件逐项处置表、下游版本台账的形态与生成方式。
- 设计经 Gate 2 独立双审后，Blake 实施，Gate 3 双审，Alex Gate 4 验收。
- P1（另两平台强制力与真机回归）与 P5 体量瘦身排后续批次，不在本批夹带。

## 常态机制

- 本报告为 R1。之后每轮自主 review 编号续记于 `.tad/evidence/pm/`，问题逐项销账，不靠单次对话记忆。

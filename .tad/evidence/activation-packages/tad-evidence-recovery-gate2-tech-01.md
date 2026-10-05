# 激活包 — 恢复执行链 Gate 2 tech 路评审

- step_id：`tad-evidence-recovery-gate2-tech-01`
- 链：证据载体恢复执行链（Build/实施轨，tad_scope: full）
- 你判的门：**Gate 2（tech 路）**——判设计的技术成立性，不判范围贴合（那是 fit 路），不替 PM 裁定
- pm_seat: 📐 TAD

## ① 角色身份

你是独立评审者（Review），与设计者（Alex）、与 fit 路评审者是不同会话、互不可见。你只评审、只落 verdict 一件，不改设计、不写代码、不执行 git 写操作。

## ② 读取清单（逐项读，verdict 内打勾回执）

1. 设计本体：`.tad/active/handoffs/HANDOFF-2026-10-04-evidence-carrier-recovery-execution.md`（56,104 B）全文。
2. PM 三点裁定：`.tad/evidence/pm/2026-10-04-evidence-recovery-design-rulings.md`（评审基线的一部分：设计与裁定冲突时以裁定为准，并把冲突点列为 finding）。
3. S1 summary（四锚与复跑序列出处）：`.tad/evidence/research/maintainer-evidence-revival/inventory-summary.md`。
4. 票：`.tad/active/TICKET-20261004-evidence-carrier-recovery-execution.md`（范围与红线）。
5. `.gitignore` 第 120–123 行与 `.tad/project-knowledge/patterns/shell-portability.md` 的 quotepath 条（管线判据出处）。

## ③ 评审焦点（tech）

- Phase 0 复算序列与 S1 原序列是否同口径（集合定义、管线 `-z`/`-print0`、gitlink 处理），差额追加成基线的做法是否无歧义；
- Phase 2 同步脚本设计：临时索引 plumbing 路线是否成立、逐件当场 sha 的时点定义、幂等性论证、中断后重跑的安全性；
- Phase 3 断言：四锚逐锚断言式是否真能证「补同步完成」（特别是 no-carrier 与 stale 的归零判据、时点后新增件的差额解释口径）；
- Phase 4 推送：grokbox 路径的每一步失败形态与处置是否写全（Syncthing 未收敛时不许推、push 失败不许换路、验同尖的判据）；
- git 写围栏：AC 层面对「只动 maintainer-evidence 分支」的断言是否可验、够不够；
- 第 16 件（termination-secret-isolation.json）的核查安排与 PM 裁定 3 是否衔接（备案件、停手线）。

## ④ 产物与判据

- 产物：`.tad/evidence/reviews/2026-10-04-gate2-tech-review-evidence-carrier-recovery.md`。含：verdict 行（PASS／CONDITIONAL／FAIL）、findings 逐条（P0/P1/P2 分级＋设计内定位）、② 读取打勾回执、本件字节数与 sha256 自报。
- 通过标准（你据以给 verdict）：P0＝0 才可 PASS；P1 须逐条给出可执行的修法指向，CONDITIONAL 的条件必须是设计增补可关闭的，不得是「重做设计」级——那是 FAIL。

## ⑤ 纪律件

- 只许写 verdict 一处；仓内其他文件只读；仓外禁写；零 git 写操作（log/ls-tree/status 等读命令可）。
- 发现按盘面事实说话：引用设计原文须给节号或行位；不许凭印象判。
- 同步目录内跑 python 带 `PYTHONDONTWRITEBYTECODE=1`。

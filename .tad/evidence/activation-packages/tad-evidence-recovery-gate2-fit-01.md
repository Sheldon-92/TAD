# 激活包 — 恢复执行链 Gate 2 fit 路评审

- step_id：`tad-evidence-recovery-gate2-fit-01`
- 链：证据载体恢复执行链（Build/实施轨，tad_scope: full）
- 你判的门：**Gate 2（fit 路）**——判设计与票、裁定、上游证据的贴合度，不判技术成立性（那是 tech 路）
- pm_seat: 📐 TAD

## ① 角色身份

你是独立评审者（Review），与设计者（Alex）、与 tech 路评审者是不同会话、互不可见。你只评审、只落 verdict 一件，不改设计、不执行 git 写操作。

## ② 读取清单（逐项读，verdict 内打勾回执）

1. 设计本体：`.tad/active/handoffs/HANDOFF-2026-10-04-evidence-carrier-recovery-execution.md`（56,104 B）全文。
2. 票：`.tad/active/TICKET-20261004-evidence-carrier-recovery-execution.md`（范围四项与红线，逐字对）。
3. PM 载体裁定：`.tad/evidence/pm/2026-10-04-evidence-revival-carrier-ruling.md`（看守参数、重议触发、17 件强制首步口径，逐字对）。
4. PM 三点裁定：`.tad/evidence/pm/2026-10-04-evidence-recovery-design-rulings.md`。
5. Decision Brief 案一节：`.tad/evidence/research/maintainer-evidence-revival/decision-brief.md`（设计声称实现的方案与 Brief 原意是否一致）。

## ③ 评审焦点（fit）

- 范围贴合：设计步序与票四项一一对应、无多做（尤其不许出现改 .gitignore、动 SC3、回退 3 件例外的任何安排）、无漏项；
- 17 件处置流程：PM 核准被写成硬前置的形态是否无歧义（核准凭什么文件、未核准时执行者被什么拦住）；附录逐件意见与 S1 summary 的 branch-only 清单、gitlink 注记是否逐件对得上（16+1 一件不缺）；
- 看守参数逐字：阈值（NOCARRIER>100／分支尖 >21 天）、周期（每链收口必跑、无链月份月度补跑）、责任人（TAD PM）、落点（脚本 `.tad/scripts/`、记录 `.tad/evidence/pm/`）与载体裁定一字不差；
- AC 质量：逐项断言、无合并 grep 计数；每条给基线；human CHECK 的位置如实（推送验同尖这类机器可验项不许推给人）；
- Gate 结构完整：Gate 2 双路→实施→Gate 3 双审→Gate 4 的判者与证据落点逐门在册；
- 研究轨收口与本链的衔接表述是否准确（usage log 看守行由谁在何时写）。

## ④ 产物与判据

- 产物：`.tad/evidence/reviews/2026-10-04-gate2-fit-review-evidence-carrier-recovery.md`。含：verdict 行（PASS／CONDITIONAL／FAIL）、findings 逐条（P0/P1/P2 分级＋设计内定位＋对照原件出处）、② 读取打勾回执、本件字节数与 sha256 自报。
- 通过标准：P0＝0 才可 PASS；贴合类 P1 须指出与哪份原件哪句不合。

## ⑤ 纪律件

- 只许写 verdict 一处；仓内其他文件只读；仓外禁写；零 git 写操作。
- 引用对照原件须给路径＋节位；逐字对参数时引原文。
- 同步目录内跑 python 带 `PYTHONDONTWRITEBYTECODE=1`。

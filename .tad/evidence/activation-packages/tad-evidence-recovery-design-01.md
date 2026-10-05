# 激活包 — 恢复执行链 Alex 设计步

- step_id：`tad-evidence-recovery-design-01`
- 链：证据载体恢复执行链（新链，Build/实施轨；本步只出设计，不执行）
- 票：`/home/hatch/workspace/yun-sync/TAD/.tad/active/TICKET-20261004-evidence-carrier-recovery-execution.md`
- tad_scope: full（实施链）｜step_kind: design｜pm_seat: 📐 TAD
- prev_verdict：研究链 RG3 PASS＋PM 载体裁定（采纳案一）

## ① 角色身份与 persona

你是 **Alex（Solution Lead）**：做需求澄清、设计、HANDOFF 创建。你不写实施代码、不执行任何 git 写操作、不替 PM 裁定 17 件的去向——你在设计中把「逐件处置意见」做成待 PM 核准的明确环节与清单格式。本链后续的 Gate 2 双审、实施、Gate 3、Gate 4 都由与你不同的会话承担；你的 HANDOFF 必须自足到执行者只读它就能干活。

## ② 规程原件（以仓内原件为准）

- 仓根 `AGENTS.md` 的角色与激活口径；`.tad/project-knowledge/principles.md`、`patterns/_index.md`（命中至多读 3 条；本步大概率命中 ac-verification 的「忽略树盲视」与断言逐项化两条、shell-portability 的 quotepath 新条）。
- HANDOFF 写作惯例：对照本仓最近两份已收口 HANDOFF 的结构（`.tad/active/handoffs/HANDOFF-2026-10-04-maintainer-evidence-revival.md` 与状态面收口链 HANDOFF），节式与字段认仓内惯例，不另创格式。

## ③ 读取清单（逐项读，完工说明打勾回执）

1. 票（上址）全文——范围四项与红线以票为准。
2. PM 裁定：`.tad/evidence/pm/2026-10-04-evidence-revival-carrier-ruling.md`（看守参数、重议触发、17 件强制首步口径）。
3. S1 summary：`.tad/evidence/research/maintainer-evidence-revival/inventory-summary.md`（四锚、复跑命令序列、branch-only 与 gitlink 清单所在节）；manifest 只读结构（行形与 class 枚举），不许全量载入正文。
4. Decision Brief 的案一机制节与「迁移输入形态（Q4）」节：`.tad/evidence/research/maintainer-evidence-revival/decision-brief.md`。
5. F-18/SC3 原件：`.tad/active/designs/AUDIT-20260816-framework-health.md` F-18 节与 `.tad/active/epics/framework-health-repair/EPIC.md` Phase 4/SC3（红线出处，逐字对）。
6. `.gitignore` 第 120–123 行原文。

## ④ 本步任务与判据

**产物**：HANDOFF 落 `.tad/active/handoffs/HANDOFF-2026-10-04-evidence-carrier-recovery-execution.md`，另写完工说明（见 ⑤）。HANDOFF 必须含：

- **意图与范围**：恢复 maintainer-evidence 分支同步并落地看守；范围认票四项，不多不少。明确非范围：不改 .gitignore、不动 SC3 判据、不回退主仓 3 件例外、不处置证据内容对错。
- **步序设计**（步号可调，语义不可少）：
  - 开链复算：按 S1 复跑序列重算四锚，差额以新增行追加成执行版清单基线；
  - 17 件处置：branch-only 16 件＋gitlink 1 件逐件给「保留／弃置＋理由」的意见表（意见在设计附录中先行给出草案，实施前经 PM 核准的环节必须写死为硬前置——未核准不许动载体）；
  - 同步脚本：落点、输入（执行版清单）、显式清单/`-f` 机制、安全管线（`-z`/`-print0`）、失败形态与断言（同步后复算：no-carrier 降至约 0、stale 归零，差额只能由时点后新增件解释）；
  - 首轮补同步与推送：推送路径必须写死并给出依据——本 VM 无 GitHub 凭据（R1 收口时实测：经 grokbox 以 gh 登录态推送成功），设计须明确执行环境与推送通道，不许留「push 一下」；
  - 看守落地：脚本落 `.tad/scripts/`、复算记录落 `.tad/evidence/pm/` 的具体文件名；参数逐字认裁定二（阈值 NOCARRIER>100 或分支尖 >21 天报警、每链收口必跑、无链月份月度补跑、责任人 TAD PM），并写明报警的落点形态（记录文件中的报警行格式）。
- **git 写操作围栏**：本链授权的写操作只有——在 maintainer-evidence 分支上的提交与向 origin 的该分支推送、执行版清单与脚本等工作文件的仓内落盘；main 分支、其他分支、.gitignore、已 tracked 3 件一律禁动。围栏要写成 AC 可验的形态。
- **AC 表**：每行恰一种合法 Verification Method；存在性/计数类断言一律逐项断言（per-term 合取），不许合并 grep 计数（本仓 KA 已有正反两向实例）；每条 AC 给基线（设计时点实测值或「文件不存在」）。
- **Gate 结构**：Gate 2 双审（tech/fit 两路独立会话）→ 实施 → Gate 3 双审（code/safety）→ Gate 4 验收，逐门写明谁判、判据、证据落点。
- **风险与回滚**：首轮补同步若中途失败的回退形态（分支可重置到 8713ea4e 的具体做法）、推送失败的处置、盘面在执行期间新增件的口径。

**判据（本步通过标准）**：PM 验盘时逐项核——范围与票四项一一对应、红线全入、17 件意见表草案齐（逐件有意见）、推送路径写死有依据、看守参数与裁定逐字一致、AC 逐项断言无合并计数、Gate 结构齐。

## ⑤ 纪律件

- **路径铁律**：只许写两处——HANDOFF（上址）与完工说明 `.tad/evidence/completions/2026-10-04-tad-evidence-recovery-design-note.md`。仓外禁写（仓内外同名文件一律以本仓绝对路径为准）；gm 仓只读。
- 本步零 git 写操作：只许 log/ls-tree/status/diff 等读命令核实事实。
- 数字只引 S1 summary 实测值与裁定件，不新造；设计中需要实测的基线（如当前分支尖）亲跑并在完工说明附命令。
- 同步目录内跑 python 带 `PYTHONDONTWRITEBYTECODE=1`。
- 完工说明必含：HANDOFF 字节数与章节清单、③ 读取清单逐项打勾回执、17 件意见草案的件数自核（16+1 逐件在表）、待 PM 裁量点清单（如有）。

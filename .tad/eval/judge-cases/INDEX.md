# Judge Cases — 判者考题集（章程与登记）

本集是判据文档／评审提示／模型锁变更的回归烟测集：收已关闭、落盘、带结论的
真实败例，变更前先回放（记法见下），用法限回归烟测——只报计数，不排名、不折算分数。
方法正本：同目录 `METHOD.md`（样本生产线五步、判据预声明冻结、断言 A/B 分层）。

## 建集规则

1. 只收「已关闭、落盘、带结论」的真实败例：来源必须是带结论的 verdict／处置／
   日志件，仅被提及（如判词点名）不算结论文件。
2. 真冻结：每案的冻结输入必须是快照正文或 fixture 本体落在本集目录内（案卷内嵌
   或同目录附件），附源路径＋内容 sha256；只有路径、无快照者不合格、不得入集。
3. 每案八项字段写死：`id`／来源指针（verdict 或日志路径＋dispatch_id）／失败类别
   （取下方 class 受控表）／被测判者面（判据文档｜评审提示｜模型锁，指名＋版本
   标识：文件路径＋内容 sha256 或发布版号＋日期）／冻结输入／期望抓获（finding
   形态：location＋scenario）／干净对照／`metric_candidate: yes|no`。
4. 找不到落盘结论文件的种子直接除名：按核验步（检索四面→须带结论文件→命中
   建案／未命中写除名行）执行，不许凭记忆重构、不许以转述充结论文件。

## class 受控表（本集唯一出处；蒸馏与矩阵汇总按此表归一）

| class 短名 | 含义 | 别名映射 |
|---|---|---|
| `self-acceptance` | 判者对自己参与的链／自己的收口作验收判断（自判） | — |
| `reviewer-dispatch-omission` | 应派的评审镜头未派发（按 risk_triggers／合同 §8 应派而未派） | — |

新 class 先入本表再用；别名在本表登记映射，不许在案卷里自造同义词。

## 回放记法

- 回放对象＝判据、评审提示或模型锁的一次变更；开跑前按 METHOD.md 第 2 节在
  REPLAY 头部冻结三件（判读规则、输入哈希集、目标版本标识）。
- 正文逐案一行 `caught | missed | false-alarm | n/a`＋判者输出指针；汇总只写
  `caught n/N`、`false-alarm m/M`＋案号清单（M＝本轮干净对照总数，来源为下方
  control 登记）；禁百分比、禁排名。A/B 分层按 METHOD.md 第 3 节。

## v1 成立下限（写死，本 phase 不得临场下调）

- 败例 ≥4 案，且干净对照 ≥2 个（集合级，登记为下方 control 条目）。
- 状态口径：≥4 案＋≥2 对照＝`established`；败例 2–3 案＝`provisional`（Gate 4
  全查、不抽样）；败例 <2 案或干净对照＝0＝`not established`（回放只记
  exploratory）。

**版本行（v1，Phase 2 关账冻结，2026-10-27）**：案例 2 案（JC-01、JC-02）；
干净对照 2 个（CTL-01、CTL-02）；v1 状态＝`provisional`（败例距下限差 2 案；
干净对照已达下限、差 0）。其后新确认缺陷只许追加为 v2 候选，不回写 v1。

## 案例登记

| id | class | 来源指针 | 案卷 |
|---|---|---|---|
| JC-01 | `self-acceptance` | `.tad/evidence/pm/2026-10-16-compliance-audit-b-tad-disposition.md`＋`.tad/evidence/reviews/epic-p3-runtime-20261006/gate4-condition1-retro-review-20261016.md` | `JC-01-self-acceptance-closeout.md` |
| JC-02 | `reviewer-dispatch-omission` | `.tad/evidence/escape-log.md` 2026-10-22 行＋`.tad/evidence/journal/conductor-tad-update-flow-2026-10-22.md` | `JC-02-reviewer-dispatch-omission.md` |

## 干净对照登记（control 条目）

取材规则：取自在盘、结论为「抓获／驳回成立」的 verdict／评审件（判者面在该件上
表现正确者）；与败例同被测判者面者优先；每条登记取材指针（来源件路径＋其结论
形态）。不许以新建自证件或无结论件充对照。

| id | 取材指针（来源件） | 结论形态 | 被测判者面 |
|---|---|---|---|
| CTL-01 | `.tad/evidence/yolo/r4-batch/phase2-gate2-review-risk.md`（sha256: 33f05f4e89b4e8207c2d9b7d132a419c96d8bb834fc29cfc74478d5d6506b0b8） | FAIL，p0_count: 1——risk(platform) 镜头抓获范围守卫自报缺陷（驳回成立） | 评审提示（review-contract §5 risk 镜头） |
**CTL-01 已知字面缺口注记（2026-10-27，conductor 按 Gate 4 判定落，verdict: `.tad/evidence/yolo/r4-batch/phase4-gate4-review.md`）**：第二轮回放（REPLAY-2026-10-27-p4-landed）中判者对 CTL-01 产出 landed-finding、机械记 false-alarm 1/2。Gate 4 亲判（判定 (i)）：判者所指字面属实——来源件 P0-1 无 `repeat_of:` 行、证据修复附记的 P1-3–P1-7 仅存要旨转录；但对照**成立**、判者属过度适用——基线 diff 证五字段与 `repeat_of:` 要求在 Phase 4 之前早已在 review-contract §2 在行（before `dd7e54d5…` 行 40–48 与现行逐字相同），本轮差异实为 bundle 段落范围，非规则变严；COMPLETION 的 KA 候选「干净相对规则版本」表述已被证伪、以本判定为准。**后续回放若再命中上述已知字面缺口，记 `n/a (known gap)`，不记 false-alarm。** v2 入集须加字面形态核、冻结记录须写明 bundle 段落范围（处置正本同上 verdict）。

| CTL-02 | `.tad/evidence/yolo/r4-batch/phase2-gate2-review-consistency.md`（sha256: a7825688102c064cc7cd85645dce1f023b017112674011e01d3913e8fe241a2b） | CONDITIONAL，p0_count: 0、P1×5——consistency 镜头抓获五处设计缺口（抓获成立） | 评审提示（review-contract §5 consistency 镜头） |

## 除名行（核验步执行记录，2026-10-27，执行者 Blake）

核验步四面检索（执行日期 2026-10-27）：`.tad/evidence/pm/`、`.tad/evidence/reviews/`、
`.tad/evidence/escape-log.md`、`.tad/project-knowledge/incidents/`。命中须是带结论的
verdict／处置／日志件；仅被提及不算。以下 3 个种子四面检索后均无独立结论文件，
逐个除名：

| 种子（类名） | 检索面 | 结果 | 处置 |
|---|---|---|---|
| 误分档链 | 四面全检（关键词：分档／tiering／档位） | 命中均为顺带提及（判词点名、他链评审件中的 tiering 字样），无一份结论文件认定某链被误分档 | 除名（2026-10-27） |
| INBOX 整份覆盖 | 四面全检（关键词：INBOX／--mine／整份覆盖） | 仅判词件顺带提及，无独立结论文件在盘 | 除名（2026-10-27） |
| 隧道标签误报 | 四面全检（关键词：tunnel／隧道／NEED_HUMAN） | 命中为他语境提及（同步报告、清扫提案），无一份结论文件以此案为对象 | 除名（2026-10-27） |

除名种子的缺口计入版本行判定：败例实数 2 案即两件已确认候选，另 3 类无结论
文件、不入集。

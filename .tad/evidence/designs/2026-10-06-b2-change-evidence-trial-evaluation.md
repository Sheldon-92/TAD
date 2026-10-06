# B2 变更/回退证据试验评估（Epic P2 件 2.6 — 只评估，不落实现）

设计输入：MQ-6 判断正本（`.tad/evidence/pm/2026-10-06-tad-sweep-proposal-judgment.md`）——B2 在该正本定性为「缓：现行 Gate 3 已有逐值复算与 fixture 三态实证在跑，增量未证大于成本；留测量层批设计时一并评估」。本件即该评估。

## 1. 现行基线

现行 Gate 3 的检出面有两根支柱，各引 Phase 1 链（TASK-20261006-EPIC-P1-CLEARANCE）实例：

- **逐值复算**：评审不采信被审方自报，逐个数字重算。实例：Gate 3 CODE 评审对 COMPLETION 自报的字节/sha/计数逐值复算并在 verdict 中留痕——`.tad/evidence/reviews/2026-10-06-gate3-code-review-epic-p1.md`；Phase 1 COMPLETION 对 AC14 的逐字节比对记录在 `.tad/evidence/epic-p1-clearance-20261006/ac14-ac15-hooks.txt`。检出面：自报不实、计数造假、锚点漂移。
- **fixture 三态实证**：正控/负控/破坏控在隔离副本实跑。实例：genesis 升级 fixture 与两条负控（版本不符 REJECT、中段缺 hop REJECT）——`.tad/evidence/epic-p1-clearance-20261006/ac11-upgrade-fixture.log`、`ac11-engine-controls.txt`；断言面三形态 fixture——`ac17-driftcheck-fixtures.txt`、`ac17-phantom.log`、`ac17-registry-only.log`。检出面：新装/锚定态下的链解析与断言行为。

基线边界（与本评估相关）：fixture 三态覆盖的是**初装态与锚定态**；逐值复算覆盖的是**自报数字**。两者都不执行「对一条已实施变更做回退、再验还原完整性」。

## 2. B2 增量面

提案原文要点（Blake 执行环/Gate 3 前加变更回退证据试验：diff、checkpoint、lint/test 输出、回退还原验证并关联 handoff），逐项与基线对位：

| 提案分项 | 对位 | 依据 |
|---|---|---|
| diff（变更集呈现） | 已有 | git 原生 diff 即变更集正本，各链 COMPLETION 与评审均以此为据（如 `.tad/evidence/completions/COMPLETION-2026-10-06-epic-p1-clearance.md` 的逐件记录） |
| checkpoint（变更前快照） | 已有 | tad.sh 升级面自带 rollback snapshot/backup 机制；链内变更以 git 提交面为检查点（Phase 1 链三笔提交） |
| lint/test 输出 | 部分有 | `bash -n`、校验器 validate、fixture 实跑已是 Gate 3 常规面；缺的是把输出**作为变更证据成套关联到 handoff** 的固定形态 |
| 回退还原验证（apply→rollback→验还原） | **确无** | 基线两支柱均不执行回退：引擎回滚路径只被代码评审读过，未在中间态树上实跑过还原比对（§1 边界） |
| 关联 handoff | 部分有 | COMPLETION 引用 HANDOFF 为惯例；无「回退证据」这一固定栏目 |

增量收敛为一点：**回退还原验证**是唯一确无的分项，其余为已有或形态补强。

## 3. 成本面

- 若采（仅取回退还原验证一环，挂 Gate 3 前）：每链新增 1 步——隔离副本（硬链拷贝）上顺序执行 apply→rollback→还原比对（文件集哈希清单比对），机器时间分钟级；人工判读约一刻钟量级（比对清单＋异常分诊）。
- fixture 维护面：不需要长期 fixture 资产——副本由当链变更集即时构造，随链销毁；维护成本≈0。
- 链型差异：文档重型链（本仓常态，变更以文本件为主、git 本身即 checkpoint）里，diff/checkpoint 两分项完全由 git 覆盖，B2 的边际成本只剩回退一环、边际收益也只在该环；代码链另有构建/测试产物面，回退验证的相对成本更高但检出面也更宽。本评估的成本结论以本仓文档重型链为准。

证据：成本形态参照本链件 2.9 的引擎回归实跑（隔离副本＋三态判读，单轮分钟级）——`.tad/evidence/epic-p2-measurement-20261006/2.9-engine-regression.txt`。

## 4. 判读框架（四维）

- **(i) 增量检出类**：可点名一类现行抓不到的缺陷——**部分升级中间态上的回退还原缺陷**：变更正向 apply 在中间态树上成立、但 rollback 还原不对称（删除项回滚后残留、或回滚覆盖变更后新写入）。现行 fixture 三态只跑初装/锚定态（§1 实例），逐值复算不执行回退，代码评审读引擎而不跑中间态回退——此类只可能由回退还原验证在中间态副本上实跑检出。**此维判正。**
- **(ii) 成本比**：试点一链的新增成本（§3：机器分钟级＋判读约一刻钟）对照该链 Gate 3 双审的工时（两路独立评审、小时量级），远低于可受线（≤ Gate 3 工时 20%）。**此维判正。**
- **(iii) 重叠度**：与逐值复算/fixture 三态的重叠估计约六至七成——diff、checkpoint、lint/test 输出三面基本重叠；真增量集中于回退还原验证一环（约三成）。重叠度高是本件只取一环、不整包采的依据。
- **(iv) 误报风险**：回退试验在文本树上的假阳性形态明确——append-only 证据件、带时间戳的产出件会使「还原后与原树逐字节相等」恒假，朴素比对必误报。**可控处置在案**：还原比对排除 zero-touch/证据面（与 migration-engine 既有 zero-touch 口径同源，`.tad/hooks/lib/migration-engine.sh` 的守卫面即其实现），其余面以文件集哈希清单（路径＋哈希）而非整树字节比对判读；误报收敛到可分诊面。**此维判有可控处置。**

## 5. 结论

判定规则逐字复述：结论为「采」必须同时满足 (i) 判正且 (iv) 有可控处置；任一不满足只能在不采/缓中选。

- (i) 增量检出：**满足**（§4(i) 判正，点名中间态回退还原缺陷类）。
- (iv) 误报可控处置：**满足**（§4(iv)：zero-touch/证据面排除＋哈希清单比对）。

**结论：采**——只采回退还原验证一环（§2 唯一确无分项），不整包引入 B2。试点设计指针：试点链＝下一条本体实施链（Epic Phase 3 首链，Epic 正本 `.tad/active/epics/EPIC-20261006-tad-self-optimization.md`）；时点＝该链 Gate 3 评审前，由实施者对当链变更集在隔离副本执行一轮 apply→rollback→还原比对，产出回退证据件挂 COMPLETION；验收判据＝四维以试点实测回填本框架复核——(i) 是否真检出或真排除该缺陷类、(ii) 实测成本对该链 Gate 3 工时占比、(iv) 误报是否收敛到分诊面；试点任一维翻负，采自动降为缓、由 PM 另裁。本件到此为止：不建试验脚本、不动发版清单。

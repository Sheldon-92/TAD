# Gate 2 契合度评审 — TASK-20261004-TAD-STATE-SURFACE-CLOSEOUT（契合路）

- **评审步**：Gate 2 双审之契合路（需求契合与范围纪律）
- **评审员**：Alex（Solution Lead）人格下的独立 Gate 2 契合度评审员——未参与被审设计，上下文与设计者及另一路评审隔离
- **日期**：2026-10-04
- **被审件**：
  - 设计：`.tad/evidence/designs/2026-10-04-tad-state-surface-closeout-design.md`（24,289 B）
  - HANDOFF：`.tad/active/handoffs/HANDOFF-2026-10-04-tad-state-surface-closeout.md`（29,350 B）
  - 需求源：`.tad/evidence/pm/2026-10-04-tad-self-review-r1.md`（本批只打 P2+P3）
  - waiver 件：`.tad/evidence/reviews/2026-10-04-waiver-p1p3-gate2-evidence.md`
- **判据原件**：`.tad/gates/gate-canonical-checklist.md` Gate 2 节；`.tad/tasks/gate-execution.md`；`.tad/tasks/requirement-elicitation.md`（仅 F3）；patterns 命中：gate-design、release-sync

## Verdict

**CONDITIONAL PASS**（契合路）

需求契合与范围纪律成立：P2+P3 全覆盖、无 P1/P5 夹带、F2/F3 两项专属裁定均可成立（见下）。无 P0。
放行附 4 项条件（C-1…C-4），全部由 PM 在派 Blake 前回填/裁定即可消解，不要求设计返工、不改变 A–D 架构。
总 verdict 由 PM 合并本路与技术路结论。

---

## F2 裁定（本路专属，二选一，不两可）

**裁定：废除「3.1」，全文归一 semver（设计方案 A，即默认案成立）。**

HANDOFF §9.1 AC6 按默认案原文执行，PM 无须改写为明示案检查；HANDOFF §8.4「『3.1』裁定未定」一行据此关闭。

理由（均经本席核盘，非引用设计自述）：

1. **双轨事实成立**。实跑 `grep -rnE '(Version|v) ?3\.1' AGENTS.md README.md INSTALLATION_GUIDE.md docs/MULTI-PLATFORM.md` 命中：`AGENTS.md:9`、`README.md:3,5`、`INSTALLATION_GUIDE.md:3`、`docs/MULTI-PLATFORM.md:6,214`；另 `docs/MULTI-PLATFORM.md:3` 为 `**Version**: 3.1` 形态（见附加 finding R-1）。而 SSOT 侧 `.tad/version.txt` = `3.0.0`、`tad.sh:26` TARGET_VERSION="3.0.0" 且已有派生逻辑（`tad.sh:39,54`）。两套都自称 Version 的命名并行属实。
2. **双轨已产生实际误导成本**，不是理论风险：R1-P2 原文「连版本号本身在自家仓内就有两个口径」，且 P1P3 链 Gate 3 SAFETY 已记观察项 C2。`README.md:5` 的「v3.1」表述自己还链向 `CHANGELOG.md#300---2026-09-16`——3.1 的文本指着 3.0.0 的锚点，双轨在同一行内自相矛盾。
3. **明示案不解根**：保留「3.1」+ 一行定义，只是把每次核对的成本永久化（每位新读者多学一条定义），且机制 2 的校验退化为「查免责声明行存在」，机器可验性弱于废除案的「计数 == 0」。
4. **废除无信息损失**：版位信息（多平台版）可由不带数字的表述承载，设计 §2.2 机制 1 已给出口。推翻 P1P3 handoff 的 v3.1 wording 授权（该 handoff `:317,351,522` 确有此 wording 指令，本席已核）有据：授权时双轨的误导成本尚未被 R1 实查坐实，新证据推翻旧授权是正常的设计演进，不是对历史的否定。

---

## F3 裁定（requirement-elicitation 3–5 轮未走）

**裁定：可接受。本批以「已记录的偏离」成立，本裁定即其 sanctioning 记录；效力仅限本批，不构成对 elicitation 规程的一般豁免。**

理由：

1. **规程文本先行承认**：`requirement-elicitation.md` 明写最低 3 轮「NOT negotiable unless user explicitly requests YOLO mode」，本批无 YOLO 请求，形式上确属偏离——设计 §0.1 已在成件时主动报明，未隐瞒、未虚构轮次（符合 gate-design 的 honest_partial 纪律）。
2. **elicitation 的目的已由等价载体达成**：该规程防的是「凭假设设计」。本批需求不是偏好型需求，而是盘上实测的缺陷清单——问题定义、范围与排除项、批次边界均已由 R1 报告落盘（`.tad/evidence/pm/2026-10-04-tad-self-review-r1.md`「第一批优化」节），且需求源头是用户 2026-10-04 在主对话中的直接指令与逐条确认（维护 TAD 为本职、自查、只打 P2+P3 的批次裁量均出自该对话）。Gate 1 canonical 四项（问题/用户/范围/AC 可验）在设计 §8 逐项有据，本席复核成立。
3. **风险面不对称**：对实测缺陷再走 3–5 轮 0-9 选项确认，不产生新信息，只产生规程表演；反而违背用户「只讲效果和目标」的既定口径。
4. **残留义务**：此例不可外推。后续批次若需求含偏好/取舍成分（非纯实测缺陷），仍须走 elicitation 或事先取得同等效力的用户确认件。此点建议 PM 记入下一轮自查（R#）的规程观察项，不在本批扩围处理。

---

## F1 覆盖度 — PASS（附 1 项口径注记）

逐项对照 R1 的 P2/P3 与设计 A–D：

**P2（状态文档与现实矛盾）全覆盖**：
- NEXT 版本行（R1 引 NEXT.md:9）→ A1；本席核 `NEXT.md:9` 现文确为「2.44.5 → next patch 2.44.6」。
- NEXT hillclimb READY_FOR_GATE2（R1 引 :15-20）→ A2 迁档 + §4.2 删除提交；本席核 `:15-20` 现文属实，且其指向的 HANDOFF 文件确在工作树呈 D。
- ROADMAP 停 2026-09-02 / Claude 共享表述（R1 引 :14）→ A5/A6，另 A7/A8 清同文件同病灶（delivered 表、Revisit 节）。
- AGENTS「v3.1」双口径 → A9 + F2 裁定。

**P2 的同面扩展（A3/A4/A10/A11/A12）不算扩围**：均为同一状态面、同一病灶类（版本/平台声明与 git 现实不符）。其中 A10（README / INSTALLATION_GUIDE / MULTI-PLATFORM）是机制 2 扫描面的必然项——检查清单若含此三文件而纠偏不含，`state-surface-check.sh` 对真树将永红，机制当场落空。设计 §2.1 A10 已自陈纳入理由，成立。

**P3（证据链尾巴未收口）全覆盖**：
- Gate 4 证据 CONDITIONAL 未改终态 → B 项；本席核对象文件 verdict 行确为 `CONDITIONAL PASS（verdict: PARTIAL）`。
- COMPLETION 与三份 Claude 相关 HANDOFF 未入 git → C1（§4.3 前五行）。
- `docs/pm/open-cards/` 未入 git → C3。
- §18 两 Epic 文件夹未入 git → C2（与 §4.1 两存根同批，成套性正确）。

**D 项（下游台账）口径注记**：R1 标题句「只打 P2 + P3」与 R1 自身「第一批优化」段的 Alex 设计任务清单（含「下游版本台账的形态与生成方式」）存在内部张力。设计遵循的是任务清单文本，且 D 只建台账（治 P4 的「无账可答」症状），不做下游升级/同步，无 P4 实体扩围。据此不判夹带；建议 PM 在 R1 或本批收口记录中注记此口径出处，免后续审计误读。

**P1/P5 夹带检查：无**。A6 改后文本提及 hooks Known Gap 仅为文档如实表述，不实施 P1；全批删除候选为零（设计 §4），不触 P5 瘦身；不 push/不 tag/不 bump（HANDOFF §1.3、NFR2）。

## F4 C 项处置表抽查 — PASS（6+ 项亲核）

**M 类抽 3 项**：
1. `EPIC-20260816-framework-health-repair.md`（M）：现为 3 行存根，头部明写全文已迁入同名文件夹 EPIC.md；文件夹三件（EPIC.md / declarations.md / session-state.md）在盘。判 commit（批 C2，与文件夹同批）——合理，拆批即造成指针指向未入仓文件。
2. `EPIC-20260831-capability-builder-v1.md`（M）：同形 3 行存根，文件夹三件在盘。判 commit（C2）——合理。
3. `NEXT.md` + `docs/pm/{now,intent,acceptance,auth}.md`（M）：`git diff --stat` 五文件合计 +34/−3 小改动。判保留本地——合理：NEXT 本体即 Phase 1 纠偏对象，先提等于把未审 diff 混入证据批；docs/pm 四件属 PM 工作面，非本批证据链。

**未跟踪类抽 4 项 + 2 目录**：
4. `COMPLETION-2026-09-15-platform-adapters-p1p3.md`：在盘（4,165 B）；其 `:7`「Pushed: NO — ahead origin/main 1」与现实（0/0）矛盾属实。判 commit（C1）+ FR4 一行带日期订正——合理且必要，不入 git 则 B3 无载体。
5. `HANDOFF-2026-09-15-claude-decouple-design.md`（23,301 B）与 `HANDOFF-2026-09-15-claude-removal-plan.md`（82,263 B）：均在盘。判 commit（C1）——合理，系 v3.0.0 移除批审计链环节。
6. `TICKET-20260916-codex-ledger-reverification.md`（1,558 B）：在盘。判 commit（C1）且明示「入 git ≠ 关单、任务仍 OPEN」——合理，防空关纪律守住。
7. `docs/pm/open-cards/`：在盘，现 8 文件（设计写作时 7，今日新增本批 Gate 2 派发卡 1 张）。判 commit（C3）——合理；**注记**：处置表计数是快照，Gate 3 执行 AC10 时须以执行时点的实时清单为准，不得以设计中的「7 文件」为闭集打回新增卡。
8. `docs/pm/ops/`（判保留本地）：3 文件均为 `*-draft-*` 命名，在盘。判保留——合理，未定稿草稿不冒充入账。

抽查结论：处置结论（commit / 保留）逐项有据，未见把废弃物判入账、或把证据判保留/删除的错置。

## F5 Phase 切分与 BLOCKED 标注 — PASS（附条件 C-1）

- **切分诚实**：Phase 1（A）/ Phase 2（B+C1/C2）/ Phase 3（C3+D）的依赖关系如实——Phase 2 独有 waiver 前置，Phase 1/3 与之无依赖，HANDOFF §8.4 未把全批伪装成 READY，也未把 Phase 2 的 BLOCKED 稀释成全批 BLOCKED。
- **BLOCKED 标注在成件时属实**：成件时 waiver 落盘件确不存在（设计 §0.3、HANDOFF MQ2 的 ❌ 行与本席复核一致）。
- **waiver 前置现已闭合（实质）**：`.tad/evidence/reviews/2026-10-04-waiver-p1p3-gate2-evidence.md` 已落盘（1,359 B，PM 2026-10-04 补记、不回填日期），明列被 waive 的两份缺失件、waiver 理由（S 号小修、设计直入 handoff、Gate 3/4 实质评审不缺）、效力范围，并自明「本件即 HANDOFF…Phase 2 所需的 waiver 落盘指针」。设计 §3.1 B4 的闭合路径（显式 waiver + 终态改写引用指针）就此成立。
- **条件 C-1**：HANDOFF 文本仍停在旧状态（§8.4 Phase 2 = BLOCKED、MQ2 waiver 行 = ❌）。PM 须在双审合并后、派 Blake 前回填：§8.4 状态改 READY 并写入 waiver 文件路径、MQ2 行改 ✅ 并附路径、Gate 2 节写入双审 verdict。Phase 2 开工时 Blake 仍须按 HANDOFF §6 步骤 1 验指针在盘（该步已在 handoff 内，无须新增）。

## F6 PM 附加题 — 重大 finding（P1 级）：证据树的 git 载体是结构性缺失，且本批三件交付物正落在盲区内

**盘上事实（本席实跑）**：

1. `.gitignore:122` = `.tad/evidence/`、`:123` = `.tad/archive/`，整树忽略。`git ls-files .tad/evidence` = **0**——main 上没有任何一份 evidence 文件被跟踪。`git check-ignore -v` 确认本批的需求源、设计、waiver、Gate 4 对象文件、未来台账五件全部命中 `:122`。
2. 该忽略**是有设计的**，不是事故：`.gitignore:115-121` 注释载明 EPIC-20260816 Phase 4 处置（commit `98b7e396`「stop tracking .tad/evidence and .tad/archive on main」），理由是发行 tarball 瘦身（两目录本就在 TAD_ZERO_TOUCH、从不复制进用户项目），并指定替代载体为 `maintainer-evidence` 分支（`git show maintainer-evidence:<path>`）。
3. **但替代载体已停摆**：`maintainer-evidence` 分支 tip = `8713ea4e`，日期 **2026-09-06**。本席逐件 `git cat-file -e` 验证：2026-09-15 的 Gate 4 证据、R1 报告、本设计、waiver 件**全部不在该分支上**。即 2026-09-06 之后的所有 Gate 证据，既不在 main、也不在 maintainer-evidence，只在 Syncthing 同步的磁盘副本上。

**与 R1-P3 定性的关系**：P3 把问题定性为「证据链尾巴未收口」（若干文件未跟踪入 git），这只对 `.tad/active/` 下的 handoff/completion 类成立（它们在 `git status` 可见、可 pathspec 提交、C 表可治）。对 `.tad/evidence/` 类，定性应升级为：**证据面整体不在 git 审计面内，且其指定载体（maintainer-evidence 分支）自 2026-09-06 起无人同步**——P3 的头号例证（Gate 4 证据停在 CONDITIONAL）本身就属于后一类。「框架自称可审计」的定位与现状的差距不在尾巴，在于审计链的 git 载体只剩设计而没有运行。R1 的 P3 严重程度应据此上调，建议 PM 在下一轮自查中单列。

**对本批结论可信度的影响**：分两层——

- **不推翻本批 A/C/D 的机制结论**：C 表对象全部位于 git 可见面，本席 F4 抽查逐项在盘验证，结论独立成立；A 项纠偏对象均为已跟踪文件。
- **但本批有三件交付物恰好落进盲区，C 表与 AC 对此无感**：
  (a) **B 项终态改写的对象文件本身**在 `.tad/evidence/reviews/`——改写完成后它依然不在任何 git 载体上，「终态 PASS」与它要取代的「CONDITIONAL」载体状态完全相同；HANDOFF §9.1 无一行验证 B 的持久化载体，AC12 的提交并集检查也覆盖不到它。
  (b) **A2 迁档目标** `.tad/archive/next/NEXT-completed-through-20261004.md` 命中 `.gitignore:123`——AC4 只 `test -f` 验盘，迁档件同样无 git 载体。
  (c) **D 项台账** `.tad/evidence/pm/downstream-versions.md` 命中 `:122`——设计 §5.2 写「随收口 commit 入仓」，在现行 .gitignore 下普通 pathspec 提交根本进不去（需 `-f` 强提或走 maintainer-evidence 同步），设计与 HANDOFF 均未察觉此冲突。
  本评审件自身亦在忽略树内，同理。
  HANDOFF §1.2「成功的样子：git status 中证据链条目清零」因此只对 git 可见子集成立——`git status` 对 ignored 文件天然沉默，「清零」表象与证据是否入账无关。

**处置要求（条件 C-3，不要求本批扩围改 .gitignore 政策）**：PM 须在派 Blake 前对上述三件交付物逐件给出载体裁定并写入 HANDOFF（可选：同步至 maintainer-evidence 分支并给 `ls-tree` 验证行 / 对具体文件作 .gitignore 例外并强提 / 显式记录「本件以磁盘+Syncthing 为可接受载体」的决定与理由），且 §9.1 补一行对应的载体验证。无此裁定，Phase 2/3 的证据类交付不得宣告完成——否则 P3 将以完全相同的形态在本批收口件上复发。`.gitignore` 政策本身与 maintainer-evidence 同步机制的修复属框架级议题，应另立批次，不在本批夹带（与 F1 的范围纪律一致）。

---

## 附加 findings

**R-1（P1，验证方法盲区）**：「3.1」的一种现存形态逃过本批两处验证口径。`docs/MULTI-PLATFORM.md:3` 为 `**Version**: 3.1`（粗体+冒号），而 HANDOFF §9.1 AC6 的 grep 模式 `(Version|v) ?3\.1` 与设计 §2.2 机制 2 第 3/4 项的模式均要求 Version 后紧跟空格/冒号，「Version**:」形态不匹配——本席首轮实跑即漏检此行（靠 `head` 原文才发现）。后果：若 Blake 漏改此行，AC6 仍报 0、检查脚本仍报绿，废除案在验证层落空。**条件 C-2**：PM 在派 Blake 前把 AC6 与检查脚本的模式放宽至可命中该形态（例如以 `3\.1` 词界 + 排除 3.10+ 的口径重写），并在 fixture 中加入一条 `**Version**: 9.9` 形态的负控样本。

**R-2（P2，措辞歧义）**：HANDOFF FR5 写「删除操作为零」，但 §4.2/Phase 2 包含提交一笔既存的删除（hillclimb handoff，工作树 D）。设计 §4 的口径是「删除候选为零」（不新增删除），FR5 的转写与之不符，Blake 按字面执行会自相矛盾。**条件 C-4**：PM 回填 FR5 为「不新增任何删除；仅提交 §4.2 既存的 hillclimb 删除一笔」。

**R-3（注记，非 finding）**：工作树快照已漂移——当前 `git status --porcelain` 仍 23 条，但构成与设计 §1 不同（本批 HANDOFF 本身新增为未跟踪第 17 条、`docs/pm/evidence/` 以单条出现）。此为活仓常态，不影响设计成立；Gate 3 按 F4 注记以实时清单为准。

## Gate 2 Canonical 对照（本路负责面）

| Canonical 项 | 本路结论 | 依据 |
|---|---|---|
| Expert review complete (min 2) | 进行中 | 本件为双审之一；待技术路落盘后由 PM 合并 |
| All P0 resolved | ✅（本路 P0 = 0） | F1–F6 无 P0；P1 两项（F6、R-1）以条件 C-2/C-3 前置消解 |
| Architecture complete | ✅ | 设计 §2/§3/§4/§5 四块齐备，与 R1 需求逐项对应（F1） |
| Components specified | ✅ | A1–A12 逐项到文件:行；C 表逐项到路径（F4 抽查验证） |
| Functions verified | ✅ | MQ2 本席复核：`derive_target_version` 派生链在 `tad.sh:26,39,54` 属实；waiver「成件时不存在」的 ❌ 记录属实 |
| Data flow mapped | ✅ | MQ3 对照表 + 数据流图与 §2.2/§5 的机制设计自洽 |

## 条件清单（PM 派 Blake 前逐项消解）

- **C-1**（F5）：回填 HANDOFF §8.4 / MQ2 / Gate 2 节——waiver 指针路径入文，Phase 2 BLOCKED → READY。
- **C-2**（R-1）：放宽 AC6 与 state-surface-check 的「3.1」匹配模式，fixture 补粗体冒号形态负控。
- **C-3**（F6）：对 B 对象文件、A2 迁档件、D 台账三件逐件落载体裁定并写入 HANDOFF，§9.1 补载体验证行。
- **C-4**（R-2）：回填 FR5 删除口径措辞。

## 纪律声明

本席未改设计/HANDOFF/证据文件本体，未 commit/push，未派 Blake，未补造任何历史证据，未触用户本机 `.claude/`。与原件冲突处（F3 的 elicitation 规程、F2 的 P1P3 旧授权）均已在上文报明并给出裁定。

**产出**：本文件 `.tad/evidence/reviews/2026-10-04-gate2-fit-review-state-surface-closeout.md`

# Gate 2 技术评审（双审之技术路）— TASK-20261004-TAD-STATE-SURFACE-CLOSEOUT

- **日期：** 2026-10-04
- **评审员：** Alex（Solution Lead）人格下独立 Gate 2 技术评审员（未参与被审设计，上下文与设计者及另一路评审隔离）
- **被审对象：**
  - 设计：`.tad/evidence/designs/2026-10-04-tad-state-surface-closeout-design.md`（24,289 B）
  - HANDOFF：`.tad/active/handoffs/HANDOFF-2026-10-04-tad-state-surface-closeout.md`（29,350 B）
  - 需求源：`.tad/evidence/pm/2026-10-04-tad-self-review-r1.md`（本批只打 P2+P3）
- **判据：** `.tad/gates/gate-canonical-checklist.md` Gate 2 节（唯一判据）+ `.tad/tasks/gate-execution.md`
- **方法：** 全部关键事实由本席从盘上亲自重跑复核，不采信设计/HANDOFF 自述（命令与输出见各节）

## Verdict

**CONDITIONAL PASS**（技术路）

设计的技术基础成立：B 项事实链（T1）与 waiver 前置（T6）经本席独立重跑全部属实；
D 项基线计数本席逐仓重扫精确复现；§9.1 十二行文法全合法。
但有 3 项 P1 必须在交 Blake 前以修订落盘（见 §8 Amd-1/2/3）：机制 2 的版本正则存在
已实存形态的盲区、机制 3 无命名落点与验收行、A2/D 两件交付物的「入仓」载体与
`.gitignore` 结构冲突（T5）。三项都是局部修订，不推翻设计主体，故不判 FAIL；
三项不修则 Gate 3 必然出现「AC 全绿而声明不实」，故不判无条件 PASS。
总 verdict 由 PM 合并两路结论后定。

## Gate 2 Canonical 六项对照

| Canonical 检查项 | 结论 | 依据 |
|---|---|---|
| Expert review complete (min 2) | 进行中 | 本件为双审之技术路第 1 份；另 1 路由 PM 另派，合并后才完整 |
| All P0 resolved | ✅ 无 P0 | 本席 findings 最高为 P1（§7），均可就地修订，不动设计主体 |
| Architecture complete | ✅ | 设计 §2/§3/§4/§5 四块齐备，§6 切分三 Phase 串行 |
| Components specified | ⚠️ 一处缺 | release runbook 落点文件未点名（F-2）；其余组件逐项到文件:行 |
| Functions verified | ✅ | 本席复核：`derive_target_version` 实存（`tad.sh:33` 定义，与 MQ2 一致）；`release-verify.sh:388-391` 实读 version.txt；waiver 缺失已被 T6 新件补上 |
| Data flow mapped | ⚠️ 一处断 | MQ3 数据流成立，但 D 台账与 A2 迁档的「入 git」一段被 `.gitignore` 截断（T5/F-3），数据流图未画 maintainer-evidence 分支 |

## T1. B 项 AC12 等价重组 —— PASS（本席亲自重跑）

原命令（P1P3 HANDOFF §9.1 AC12）：以 `HEAD` 为对象、无 `-M`，对 §6.1 闭集
（9 路径，含 rename 目标 `.agents/skills/_archived/doc-organization.md`）做集合比对。
HEAD 已前进到 `b78173b3`，原样重跑无对象——设计改对 commit `2fb80bf5` 重组，成立。

本席重跑（2026-10-04，仓 `~/workspace/yun-sync/TAD`）：

- `git diff-tree --no-commit-id --name-status -r -M 2fb80bf5` → 9 行，rename 呈
  `R100 .agents/skills/doc-organization.md → .agents/skills/_archived/doc-organization.md`；
  以 AC12 原 python 口径（`split('\t')[-1]` 取路径集）比对：
  **MISSING=[] EXTRA=[] DELETED=[]** —— 设计 §3.1 B2 与 HANDOFF §9.1 行 1 的记录精确复现。
- 对照组（不带 `-M`）：同法比对得 MISSING=[]、**EXTRA=['.agents/skills/doc-organization.md']**、
  DELETED=['D\t.agents/skills/doc-organization.md'] —— 证实原命令确有缺陷，
  且缺陷比设计所述略大：设计只说「DELETED 非空」，实际 EXTRA 同时非空（旧路径被当新增集外路径）。
  属无害低估，不影响结论，但终态附记应按实测写全两项。
- commit 本体：`git show --stat 2fb80bf5` 恰 9 文件，subject 含
  `TASK-20260915-OPENCODE-CURSOR-P1P3`；`git branch -a --contains` 含 `remotes/origin/main`，
  `rev-list --left-right --count origin/main...HEAD` = 0/0。B1 一并复核成立。

方法学限定（须随终态附记保留）：`-M` 等价**只对本 commit 成立**，因其相似度为 R100
（字节级 rename，Gate 4 §2b FR8 已独立证 byte-identical）。若把「-M 口径」泛化为
AC12 的通则，rename-带改（R<100）会被同样洗成 DELETED 空——附记必须载明 R100 这一事实，
不得把本例写成通则。设计 §3.2 第 3 点已要求载明方法差异，补上 R100 即完备。

## T2. D 项台账生成器 —— 成立（基线本席逐仓重扫精确复现），2 项修订

本席独立重扫 `~/workspace/yun-sync/*/.tad`（53 仓，逐仓读 version.txt 首行）：

- 总数 53；3.0.0 ×22；2.42.0 ×7；2.30.0 ×6；2.33.0 ×4；2.44.1/2.41.0/2.40.0/2.39.0/
  2.34.0/2.32.1/2.32.0/2.26.0/2.2.1 各 ×1；1.5 ×2；MISSING ×2；EMPTY ×1
  —— 与设计 §5.4、HANDOFF §9.1 行 2 **逐项一致**。
- MISSING 两仓与设计 §1 点名一致：`fidara-images-mirror-wt`、`外刊阅读`。
- 落点目录 `.tad/scripts/` 实存且为同类脚本之家（scan-*.sh 等在位）；生成器规格
  （入参默认仓父目录、读首行去空白、MISSING/EMPTY 显式记法、目录为事实源/台账为派生索引）
  可实施；双触发（发版收口机制 3 第 3 步 + 每轮 R# 自查 §5.2）与验证法
  （重跑 0 diff［generated-at 行除外］+ 行数对账 + Gate 4 另选 3 仓抽查）可验证。

修订项：

- **F-4（P2）EMPTY 仓身份未点名且形态特殊**：本席查明 EMPTY 的一仓是目录名带**尾随空格**的
  `Pokémon `（od 字节实证：`P o k é m o n <space>`，非 ASCII + 尾空格）。NFR1 只说「中文仓名可跑」，
  未覆盖尾空格目录名——生成器若对路径做 trim 或未正确引用，台账行仓名会失真，
  而 Gate 4 抽查未必抽到它。设计应点名此仓并要求生成器对该仓输出与 `ls` 字节一致。
- **F-5（P2）AC11 计数口径不精确**：§9.1 行 11 以 `grep -c '^|'` 数台账行，
  该计数含明细表表头行与分隔行（+2），与 §5.3「明细行数 == 53」不能直接划等号；
  AC 文本以「Gate 3 以实跑值为准」含糊带过。应钉死台账格式后给出净明细行计数法
  （或在 AC 中明示减 2 的口径），否则 Gate 3 对账环节必然临场裁量。
- 台账落点与「入仓」声明的结构冲突见 T5/F-3（P1，跨项）。

## T3. A 项防再过期四条机制 —— 逐条判定：2 条真机制、1 条半机制、1 条轻量真机制

- **机制 1（版本 SSOT + 禁止复述）：真机制。** 基础设施实存且本席已验：
  `tad.sh:31-39 derive_target_version` 从 version.txt 派生、release-verify 实读 version.txt；
  例外清单（CHANGELOG 历史 / 状态文档头部一行）明确。附 **F-6（P2）**：规则文字面是
  「任何文件不得再以 Version X.Y.Z 形式复述」，字面覆盖全仓（证据、设计、fixture pins 都会合法引用版本号），
  实际约束力全靠机制 2 的显式扫描面兜底——文字应收紧为「扫描面内文件」，免得后人按字面误读。
- **机制 2（detect-only 检查脚本）：真机制主体，但正则有已实存盲区（F-1，P1）。**
  只读五项 + 显式扫描面（exclusion contract）+ fixture 双向验（AC 行 7/8），
  detect/heal 解耦符合 gate-design 既有模式。但按设计文字面的正则实现会漏检：
  (a) 检查 3 的 `Version[: ]+v?[0-9]+\.[0-9]+` 匹配不了仓内实存的粗体冒号形态
  `**Version**: 3.1`（`docs/MULTI-PLATFORM.md:3`）与 `**Version**: 3.0.0`（`PROJECT_CONTEXT.md:4`）；
  (b) 检查 4 / §9.1 AC6 的 `(Version|v) ?3\.1` 同样漏 `MULTI-PLATFORM.md:3`——
  本席以 AC6 原命令实跑基线得 **6** 条命中，恰不含 :3 行；若 Blake 漏改 :3，AC6 照样归 0 假绿，
  且该盲区会永久驻留检查脚本（未来任何 `**Version**: X.Y` 声明都不可见）。
  另检查 5 作用域未钉死：`session-state.md` 正文「Active Task」节仍指向 Phase 2 将删的
  hillclimb handoff 路径，而 A12 明示正文不动——检查 5 若按全文路径实现，Phase 2 后必然误红；
  应明示只对头部多链索引块实现。
- **机制 3（发版收口挂钩）：半机制（F-2，P1）。** `release-verify.sh` 增 `state-surface`
  转调子命令——落点实存、可实施。但：(a)「release runbook 对应节」始终没有点名文件
  （仓内发版流程正本实存于 `.agents/skills/alex/references/publish-protocol.md`，
  设计与 HANDOFF 均未指认，§7.2 文件清单亦无此文件，Blake 只能猜）；
  (b) 第 1 步「release commit 文件集 ⊇ {version.txt, NEXT.md, ROADMAP.md}」的断言
  没有命名执行者——它不在 state-surface-check 五项内，也没有任何 AC 行承接；
  (c) §9.1 十二行中**没有一行**覆盖机制 3 的任何一步（FR2 写了、AC 没跟）。
  按 ac-verification 既有纪律「不在 AC 里的即 effectively optional」，机制 3 现状交付后不可验，
  等于随批夹带的文字倡议。须：点名 runbook 文件、指定断言执行者、补 1 行 §9.1。
- **机制 4（NEXT 头部自查对账指针）：轻量真机制。** 触发点写进被管文件头部、
  R# 自查已有 R1 实例与编号续记纪律（R1「常态机制」节），设计诚实标注语义级过期
  不可全机器化——有执行点位、有触发面，不算口号。

## T4. HANDOFF §9.1 十二行 —— 文法 12/12 合法；内容 4 处注记

逐行核（Verification Method 只认 command｜path-check｜fixture｜rubric-spawn｜light-tier N/A）：

| 行 | 文法 | 注记 |
|---|---|---|
| 1 AC12 等价重组 | command ✅ | Verified Output 与本席重跑一致（T1） |
| 2 下游基线计数 | command ✅ | 本席重扫精确复现（T2） |
| 3 NEXT 版本行 | command ✅ | 基线干跑得 False（为对的原因红）：head 12 行无 3.0.0、`next patch 2.44.6` 在位 |
| 4 hillclimb 迁档 | command ✅ | 基线干跑：迁档文件不存在、NEXT 中 READY_FOR_GATE2 ×2，为对的原因红 |
| 5 ROADMAP 纠偏 | command ✅ | 基线干跑 False，为对的原因红 |
| 6 「3.1」清零 | command ✅ | **内容洞**：正则漏粗体冒号形态（F-1），基线实跑 6 条不含 MULTI-PLATFORM:3 |
| 7 检查脚本真树 | command ✅ | post-impl 行，基线无脚本不可跑，形态合法 |
| 8 检查脚本负控 | fixture ✅ | **F-7（P2）**：fixture 规格只说「一份写错版本号的 NEXT 副本」，但脚本以 `--repo` 语义扫多文件，fixture 须含 version.txt 及被扫文件布局、且脚本对缺失文件的行为须先定义，否则负控可能因缺文件报错而非因版本错 exit 1——红的理由不对 |
| 9 Gate 4 终态 | command ✅ | 基线干跑 False，为对的原因红；末两项（CONDITIONAL PASS / AC1–AC11 原文在位）证历史保真，设计正确 |
| 10 C 表对照 | command（弱） | 十二行中最弱一行：`git status --porcelain` 是 command，但「与 §4 对照」是人工逐项核表，判定程序未机械化。本席另注：当前 porcelain 为 24 条（设计时 23 + 本批 HANDOFF 自身），C 表逐项与盘上 7M/1D/未跟踪构成核对一致（§4.3 十五行与 -uall 42 文件的构成算术亦闭合）；且 porcelain 结构上看不见 ignored 文件（T5），本行结论只能覆盖非忽略面 |
| 11 台账重放 | command ✅ | 计数口径问题见 F-5 |
| 12 提交面守卫 | command ✅ | **与 T5 交互**：并集口径下，永不入 commit 的 ignored 交付物（A2 迁档、D 台账）在本行天然不可见——本行 PASS 不能证明它们「已入仓」，只能证明提交面未越界 |

结论：无散文行、无空行，Gate 1 canonical 的 AC 可验证项满足；上述内容洞按 §8 修订。

## T5. PM 附加题：`.gitignore:122` 整树忽略 `.tad/evidence/` —— 有意设计，非缺陷；但本批有两处被它截断

**定性：有意设计，证据链完整。**

- `.gitignore:116-123` 自带理由注：EPIC-20260816 Phase 4「维护者调试记录移出发行物」，
  审计 F-18——`tad.sh` 拉 GitHub tarball 快照，evidence/archive 两树已在 TAD_ZERO_TOUCH、
  从不复制进用户项目，留在 main 只增大所有下游的下载量；落地 commit `98b7e396`
  （stop tracking .tad/evidence and .tad/archive on main）与 `659f4161`（Phase 4 发行瘦身，
  包体 23.1MB → 3.3MB，Gate 3 PASS）。
- 设计了替代载体：`maintainer-evidence` 分支（本地与 origin 均在），
  本席实查其载有 evidence 3,460 文件 + archive 917 文件。
- 本席实测规模：`.tad/evidence/` 盘上 12,014 文件 / 124M，main 上 tracked = **0**；
  `.tad/archive/` 同被 `:123` 忽略，tracked = 0（17M）。

**但运行纪律已断档，且设计/R1 对此全程无知：**

- maintainer-evidence 分支尖停在 **2026-09-06**（`8713ea4e`）；盘上 12,014 个 evidence 文件
  中约 8,500 个不在任何 git 载体上。本批 B 项的对象文件
  `2026-09-15-gate4-acceptance-platform-adapters.md` 本席以 `git cat-file -e` 实证
  **不在 maintainer-evidence 分支**——它和本批的 R1 报告、设计、waiver、以及本评审件，
  全部只活在盘上（Syncthing 同步）。即：这条 ignore 本身是设计，
  「证据只在盘上」对 2026-09-06 之后的所有证据而言是运行事实。
- R1-P3 的表述「证据链尾巴未入 git」因此低估了问题形态：不是尾巴没收，
  是整棵证据树的 git 载体（分支同步）停摆近一个月而无人知晓——
  因为 `git status` 结构上看不见它（本席实证：当前 porcelain 24 条中，
  `.tad/evidence/` 条目为零，尽管本批四份关键文件就躺在该树下）。

**对 C 项结论的影响：**

- C 表以 `git status --porcelain` 为全集，方法本身没错，但结论的适用面必须收窄：
  它清的是**非忽略面**的账（handoffs/epics/docs/pm），「证据链清零」若按字面理解为
  含 `.tad/evidence/`，则不成立——该树从未被 C 的方法审计过。
  HANDOFF §1.2/§9 的「git status 中证据链条目清零」应改口为「非忽略面证据链条目清零」，
  或在 C 表外单列一行声明 evidence 树的载体现状（分支停摆、另行处置）。

**对本批范围的影响（F-3，P1）：两件交付物的「入仓」声明与 ignore 结构冲突。**

1. **D 台账**：落点 `.tad/evidence/pm/downstream-versions.md` 在忽略树内，
   而设计 §5.2/§6 与 HANDOFF §6 Phase 3 均写「随收口 commit 入仓／首份台账入仓」——
   按 §4 的 pathspec 纪律（且禁 `git add -A`、未提 `-f`），该文件**进不了任何一批 commit**。
   AC11 只验盘上文件，Gate 3 会全绿而「入仓」静默落空——正是 claims-need-carriers 的反面形态。
2. **A2 迁档**：目标 `.tad/archive/next/NEXT-completed-through-20261004.md` 在 `:123` 忽略的
   archive 树内，同样入不了「同一 commit」；AC4 只验盘上存在，同样验不出。

**处置建议（本席表态）：**

- **本批不动 `.gitignore`**。理由：F-18 的发行瘦身依据仍然成立（124M 证据树回 main
  等于每个下游每次拉取 tarball 都背它），且改 ignore 规则属框架发行面变更，
  应走自己的 Gate，不夹带在本批。
- **二选一钉死载体，请 PM 在交 Blake 前裁定并回写设计/HANDOFF**：
  (甲) 承认 evidence/archive 的 git 载体就是 maintainer-evidence 分支，
  本批给 A2 迁档件、D 台账、B 终态改写后的 Gate 4 文件补一个「同步至 maintainer-evidence」
  的收口步（或明确登记为后续单，本批声明随之改为「落盘 + 待分支同步」）；或
  (乙) 对这两件（及 B 对象文件）作单文件 `git add -f` 例外入 main，并在 §4/§7 明示例外及理由。
  两案都合法，不许保持现状含糊——现状是 AC 验盘上、声明说入仓，两边对不上。
- **另行登记**（不在本批范围，但必须留痕）：maintainer-evidence 分支自 2026-09-06 停摆、
  约 8,500 证据文件无 git 载体，建议 PM 另开一单恢复分支同步纪律（含本批四份新件）。

## T6. Waiver 件 —— 满足 Phase 2 前置条件 ✅

对象：`.tad/evidence/reviews/2026-10-04-waiver-p1p3-gate2-evidence.md`（1,359 B）。

- **指向精确**：被 waive 的两份缺失件路径与 Gate 4 原文 §3 第 4 项点名的
  `2026-09-15-gate2-review-platform-p1p3-{spec,scope}.md` 逐字一致；本席实查两文件确不存在。
- **效力自指**：文件明示「本件即 HANDOFF-2026-10-04…Phase 2 所需的 waiver 落盘指针」，
  满足 HANDOFF §8.4「PM 落盘 waiver 文件…并回指本 handoff」的形式要求；
  §8.4 的 BLOCKED 前置因此可由 PM 凭此路径解除。
- **实质前提属实**：waiver 称 Gate 3 双审与 Gate 4 证据在盘完整——本席实查
  `2026-09-15-gate3-code-review-platform-adapters.md`（7,495 B）、
  `2026-09-15-gate3-safety-review-platform-adapters.md`（4,424 B）、Gate 4 件（11,175 B）均在盘。
- **诚实性**：落盘日期如实标 2026-10-04「事后补记，不回填日期」，并明令禁止事后回填生成
  两份历史评审文件——与「不补造历史证据」纪律一致。
- **一处读法须钉清（F-8，P2）**：waiver 称决定「形成于 2026-09-15 前后」，此形成时间
  无同期盘上记录可证。Gate 4 给的出口是「由人显式 waive」——本件作为 PM 于 2026-10-04
  作出的显式、限范围、有载体的 waiver，其本身即满足出口要求，不需要靠「形成于 9 月」
  的追溯主张增信。终态附记引用 waiver 时应以 2026-10-04 为 waiver 生效日，
  不得把附记写成「9 月当时已有 waiver」。

附注（非 waiver 范围，不构成前置缺口）：Gate 4 Prerequisite 表另列
`gate3-evidence-platform-p1p3.md` manifest 缺失一项，但 Gate 4 §3 的闭合清单（五项）
未包含它——设计 §3.1 按 §3 五项销账是对原文的忠实读法；该 manifest 缺口按 Gate 4
自身的闭合定义不阻塞终态，本席仅在此留痕，不作 finding。

## 设计 §0 两处自报冲突的裁定（技术路意见）

- **§0.1 需求澄清轮次偏离：可接受。** Gate 1 canonical 四项（问题/用户/范围/AC 可验证）
  由 R1 落盘件 + 用户 2026-10-04 指令实质满足，设计 §8 自检与本席 T4 复核一致；
  虚构澄清轮次比显式报明偏离更差。gate-execution 的 3–5 轮属规程形态，非 canonical 判据项。
- **§0.2/§2.3「3.1」版位名：技术路裁废除案（方案 A）。** 理由：双口径已实证误导状态判断
  （R1-P2）；废除案可由机制 2 全机器校验，明示案（方案 B）只能验「明示行存在」，
  每个新读者仍须多学一条定义；A 表改法已逐行锚定，执行风险低。
  §9.1 AC6 的预期（计数 0）与废除案一致，裁 A 后 AC6 仅需按 F-1 补强正则形态覆盖。

## Findings 汇总

| ID | 级别 | 内容 | 处置 |
|---|---|---|---|
| F-1 | P1 | 机制 2 检查 3/4 与 AC6 的版本正则漏检粗体冒号形态 `**Version**: X.Y`（仓内实存 2 处，其中 MULTI-PLATFORM:3 是本批要改的行）；检查 5 作用域（索引块 vs 全文）未钉死 | Amd-1 |
| F-2 | P1 | 机制 3 半机制：runbook 文件未点名、commit 文件集断言无执行者、§9.1 无覆盖行（FR2 无 AC 承接） | Amd-2 |
| F-3 | P1 | A2 迁档件与 D 台账的「入仓」声明被 `.gitignore`（:122/:123）结构截断，AC 只验盘上、声明落空无声（T5） | Amd-3 |
| F-4 | P2 | D 生成器未点名 EMPTY 仓 `Pokémon `（尾空格+非 ASCII 目录名）的处理要求 | 交 Blake 前补一行规格 |
| F-5 | P2 | AC11 `grep -c '^|'` 计数含表头/分隔行，与 §5.3 明细行对账口径差 2 | 钉死格式或计数法 |
| F-6 | P2 | 机制 1 禁复述规则文字面覆盖全仓，实际靠扫描面兜底 | 文字收紧为扫描面内 |
| F-7 | P2 | AC8 fixture 布局与脚本 `--repo` 多文件扫描语义未对齐，缺失文件行为未定义 | 补 fixture 布局规格 |
| F-8 | P2 | waiver「形成于 2026-09-15 前后」不可证；终态附记应以 2026-10-04 为生效日引用 | 引用口径注记 |
| — | 观察 | 设计 §3.1 B2 对无 `-M` 结果的描述漏 EXTRA 非空（实测 EXTRA 与 DELETED 同时非空） | 附记按实测写全 |
| — | 观察 | HANDOFF §2.3 称「仓内 python3 无 yaml 模块」——本席在本 VM 实测 `import yaml` 成功（PyYAML 6.0.2，/usr/bin/python3）。禁 yaml 的约束方向是保守侧（脚本只用 stdlib 在任何机器都更稳），不构成缺陷；但其事实前提在本机不成立，引用时勿当已验事实 | 留痕 |

## §8 交 Blake 前的必备修订（CONDITIONAL 的条件）

- **Amd-1**：设计 §2.2 机制 2 检查 3/4 的模式补齐粗体形态（如 `Version\*{0,2}[: ]` 家族），
  §9.1 AC6 正则同步补强，并以 MULTI-PLATFORM:3 现行文本做已知坏样本干跑（必须命中）；
  检查 5 明示作用域为 session-state 头部多链索引块。
- **Amd-2**：机制 3 点名 runbook 落点文件（仓内候选正本：
  `.agents/skills/alex/references/publish-protocol.md`，由设计方确认）、
  为「release commit 文件集 ⊇ {version.txt, NEXT.md, ROADMAP.md}」指定执行者
  （脚本子命令或收口人工步，二选一写死）、§9.1 补一行覆盖 FR2 的挂钩半边。
- **Amd-3**：按 T5 处置建议在（甲）maintainer-evidence 同步步 /（乙）`git add -f` 单文件例外
  二案中裁一，回写设计 §5.2、§6 与 HANDOFF §6/§9 的「入仓」表述；
  同时 HANDOFF「证据链清零」表述收窄为非忽略面，或单列 evidence 树载体现状声明。

三项修订均属文档级 amendment，不改变 A/B/C/D 四块的实施内容；
修订落盘后技术路即转 PASS，无需重审全件，PM 核对修订行即可放行 Blake。

---

**评审人**：Alex（独立 Gate 2 技术评审员）— 只评审，不改设计/HANDOFF 本体
**落盘**：`.tad/evidence/reviews/2026-10-04-gate2-tech-review-state-surface-closeout.md`

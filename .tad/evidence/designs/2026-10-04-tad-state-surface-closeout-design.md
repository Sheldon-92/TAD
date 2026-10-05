# Design — TAD 状态面与证据面收口（State Surface Closeout）

- **Task ID:** TASK-20261004-TAD-STATE-SURFACE-CLOSEOUT
- **日期：** 2026-10-04
- **作者：** Alex（Solution Lead）— 本步为 Gate 1（设计 + HANDOFF 成件），不写实现、不 commit
- **来源：** `.tad/evidence/pm/2026-10-04-tad-self-review-r1.md`（PM 自查 R1，第一批只打 P2 + P3）
- **送审：** Gate 2 由 PM 另派独立会话双审；本设计不自审自批
- **配套 HANDOFF：** `.tad/active/handoffs/HANDOFF-2026-10-04-tad-state-surface-closeout.md`

---

## 0. 口径与冲突报明（先说在前面）

1. **需求澄清轮次冲突**：`.tad/tasks/requirement-elicitation.md` 要求 3–5 轮人机确认、
   `handoff-creation.md` 前置条件要求「requirements documented and confirmed (3-5 rounds)」。
   本步需求由用户 2026-10-04 指令 + PM 自查 R1 报告直接给定（问题清单、批次边界、判据均已落盘），
   §8f 任务书五项齐备。按激活壳「与激活包冲突时以仓内原件为准并报明冲突」与任务书口径，
   本步以 R1 报告充当需求确认件，不再虚构澄清轮次；此偏离在此报明，Gate 2 请复核其可接受性。
   （2026-10-04 Gate 2 修订追记：契合路 F3 已裁定本批可接受、效力仅限本批，技术路同判——偏离就此 sanctioning，后续含取舍成分的需求仍须走规程，不外推。）
2. **「3.1」不是笔误，是第二套命名**：实查 `README.md:3,5`、`INSTALLATION_GUIDE.md:3`、
   `docs/MULTI-PLATFORM.md:3,6,214`、`AGENTS.md:9` 均以「Version 3.1 / v3.1」指称
   2026-09-16 的多平台版位，而 `.tad/version.txt`、`tad.sh` TARGET_VERSION、`CHANGELOG.md`
   的版本位是 semver `3.0.0`。P1P3 handoff §6.3 曾授权「3.1」作版位名——本设计**有意推翻该授权**，
   理由见 §2.3：两套都叫 Version 的命名并行，正是 R1-P2 与 Gate 3 SAFETY C2 观察项的病根。
3. **Gate 2 waiver 无独立落盘件**：B 项终态改写依赖「Gate 2 缺失证据采用 waiver」的 PM 既定口径，
   但本席在仓内未找到一份专为 P1P3 Gate 2 签发的 waiver 文件（现存 waiver 文件
   `2026-09-16-gate3-rework-r3-waiver.md` 是 AC21 的，与 Gate 2 无关）。
   **前置依赖**：Phase 2 执行前，PM 须给出 waiver 决定的落盘指针（文件路径或决策台账条目）；
   无指针，B 项不得执行。此点已写进 HANDOFF §8.4 Friction Preflight（BLOCKED 项）。
   （2026-10-04 Gate 2 修订追记：指针已由 PM 落盘——`.tad/evidence/reviews/2026-10-04-waiver-p1p3-gate2-evidence.md`（事后补记、不回填日期，waiver 生效日 2026-10-04），技术路 T6 已核满足前置——**前置已闭合**，Phase 2 开工时 Blake 仍须验指针在盘。）

---

## 1. 现状取证（2026-10-04 本席实跑，非引用旧自述）

| 事实 | 证据 |
|---|---|
| 版本 SSOT | `.tad/version.txt` = `3.0.0`；`tad.sh:26` TARGET_VERSION="3.0.0"，且 `tad.sh:31-39` 已有 `derive_target_version` 从源树 version.txt 派生 |
| HEAD 与远端 | `b78173b3`（hillclimb 落地）；`git rev-list --left-right --count origin/main...HEAD` = `0 0` |
| P1P3 commit | `2fb80bf5` 在 origin/main（`git branch -a --contains` 含 `remotes/origin/main`），恰 9 文件 |
| 工作树 | `git status --porcelain` = 23 条：7 改（M）+ 1 删（D）+ 15 未跟踪条目（`-uall` 展开为 42 个未跟踪文件） |
| 下游 | yun-sync 下 53 仓带 `.tad/`：3.0.0 ×22、2.42.0 ×7、2.30.0 ×6、2.33.0 ×4、其余散布 1.5–2.44.1、2 仓无 version.txt（`fidara-images-mirror-wt`、`外刊阅读`）、1 仓 version.txt 为空（`Pokémon `——目录名带尾随空格的非 ASCII 名，本席 2026-10-04 以字节复核；生成器对该类目录名的处理见 §5.1） |

---

## 2. A 项设计 — 状态文档纠偏 + 防再过期机制

### 2.1 逐项纠偏表（文件 / 行 / 现文 / 现实 / 改法）

| # | 文件:行 | 现文（与现实矛盾处） | 现实 | 改法（Blake 执行，逐字口径） |
|---|---|---|---|---|
| A1 | `NEXT.md:9` | 「当前版本：2.44.5 (live tag `b3193d24` / commit `1f6aaad2`) → next patch 2.44.6」 | v3.0.0 已发布（tag v3.0.0 / commit `20223774`）；其后 P1P3 `2fb80bf5`、hillclimb `b78173b3` 均已入 origin/main | 改为「当前版本：3.0.0（tag `v3.0.0` / commit `20223774`）→ next：未定（候选 v3.0.1 收口批）」；同行「默认通道 full / lite 冻结于 2026-08-13」仍成立，保留 |
| A2 | `NEXT.md:15-20` | hillclimb 条目仍标 `READY_FOR_GATE2`、「Gate 2 双审尚未做」「人说当 Blake 之前不要改…」 | hillclimb 已落地，HEAD `b78173b3` 即其落地提交；其 HANDOFF 已在工作树删除待提交 | 整条按 NEXT 自家规矩迁入 `.tad/archive/next/NEXT-completed-through-20261004.md`（逐字保留），队列中删除；迁档与 C 表 D 项（handoff 删除）同一 commit 收口；迁档件位于 `.tad/archive/`（`.gitignore:123` 忽略树），入该 commit 须走 `git add -f` 单文件例外（Gate 2 载体裁定（乙），见合并裁定件） |
| A3 | `NEXT.md:35` | research-mechanism 条目称 commit `f92cbc73`「local, not pushed; not in v2.44.5」 | `git merge-base --is-ancestor f92cbc73 origin/main` = 真，已在 origin/main | 该行改为「已 push（在 origin/main）」；条目其余（待人 CHECK）仍成立，保留 |
| A4 | `NEXT.md:22-27` | ledger-reverify OPEN 条目 | 仍成立（任务未做，禁空关） | 不动正文；其 TICKET 文件按 C 表入 git 后，条目路径引用自动成真 |
| A5 | `ROADMAP.md:3` | 「Updated 2026-09-02 for v2.43.1」 | 已过两个大版本 | 改为「Updated 2026-10-04 for v3.0.0」；此行今后由 §2.2 机制 3 强制与发版同行 |
| A6 | `ROADMAP.md:14` | 「Claude Code and Codex share the same durable `.tad/` project state and mirrored skills」 | Claude 路径已于 v3.0.0 彻底移除；现为三平台共用**单一** `.agents/skills/` 树（无镜像） | 改为「Codex, OpenCode, and Cursor share the same durable `.tad/` project state and the single `.agents/skills/` tree. Codex is the hook-enabled runtime; OpenCode/Cursor lifecycle hooks remain a known gap (P2).」 |
| A7 | `ROADMAP.md` Recently delivered 表 | 最新行停在「v2.43.1 release」 | v3.0.0 与 P1P3 均已交付 | 本文件自称「strategic view, not a historical ledger」：删除 v2.43.1 release 行，补两行——「v3.0.0 release：Claude Code runtime path removed; single skill tree」与「Platform Adapters P1+P3：installer accepts codex\|opencode\|cursor（P2/P4 为 Known Gaps）」 |
| A8 | `ROADMAP.md` Revisit 节 | 「Experimental harnesses: qualify Claude Code, OpenCode, and DeepSeek…」 | Claude Code 已移除，不再是待 qualify 对象 | 删 Claude Code 字样；OpenCode/Cursor 的 qualify 改述为「P4 live behavioral regression（见 AGENTS.md Known Gaps）」 |
| A9 | `AGENTS.md:9` | 「Runtime status (v3.1)」 | semver 为 3.0.0；「3.1」是第二套命名（见 §0.2） | 改为「Runtime status (v3.0.0)」；并在该 blockquote 末尾加一行：「Version of record: `.tad/version.txt`. Do not restate a version number anywhere else; link here instead.」 |
| A10 | `README.md:3,5`、`INSTALLATION_GUIDE.md:3`、`docs/MULTI-PLATFORM.md:3,6,214` | 同 A9 的「Version 3.1 / v3.1」表述（任务书点名三文件之外、实查同病三文件） | 同上 | 同规则处理：版本号一律改 3.0.0 或改为不带数字的版位表述。不纳入同批，则 A9 的机制当场落空——纳入理由在此，Gate 2 可裁 |
| A11 | `PROJECT_CONTEXT.md:4,6` | 「Version: 3.0.0（…Codex sole runtime）」「Codex-sole-runtime」 | 版本号对、平台声明已被 P1P3 推翻 | 改为「Codex hook-enabled + OpenCode/Cursor supported」口径；版本号保留 3.0.0（与 SSOT 一致） |
| A12 | `.tad/active/session-state.md` 正文 | hillclimb 链正文仍写 `READY_FOR_GATE2`（2026-09-29 状态） | 该链已收口（`b78173b3`） | 头部多链索引中 hillclimb 行状态词改为「已收口（`b78173b3`）」；正文按其头部既定声明在本批不动（声明称收口时迁入归属文件夹，搬家留后续批次，避免本批范围膨胀） |

### 2.2 防再过期机制（要机制，不要口号）

**机制 1 — 版本号单一出处（SSOT + 派生，禁止复述）**
- 唯一权威：`.tad/version.txt`。`tad.sh` 已有 `derive_target_version`（:31-39）从它派生，
  `release-verify.sh` 的 version 子命令已读它（:388-391）——基础设施已在，缺的是**文档侧纪律的机器面**。
- 规则：任何文件不得再以「Version X.Y.Z / (vX.Y)」形式复述版本号，例外只有两类——
  (a) CHANGELOG 历史条目（历史记录，按 release-sync 模式的 exclusion contract 豁免）；
  (b) 状态文档头部一行（NEXT/ROADMAP/PROJECT_CONTEXT），其值由发版收口回填（机制 3）并由机制 2 校验。
- 「3.1」式版位名**废除**：版位表述今后只许用不带数字的词（如 "multi-runtime edition"）或直接引 semver。

**机制 2 — detect-only 状态面检查（新脚本，decouple detect-from-heal）**
- 新建 `.tad/hooks/lib/state-surface-check.sh`（bash，无 yaml/网络依赖），只读、只报、exit 0/1：
  1. `NEXT.md` 头部版本行中的版本号 == version.txt；
  2. `ROADMAP.md` 头部「for vX.Y.Z」== version.txt；
  3. `AGENTS.md` / `README.md` / `INSTALLATION_GUIDE.md` / `docs/MULTI-PLATFORM.md` /
     `PROJECT_CONTEXT.md` 中一切版本声明形态的**现行版本声明** == version.txt；
     声明模式为正则家族 `Version\*{0,2}:?\*{0,2} ?v?[0-9]+\.[0-9]+`（Gate 2 修订放宽：
     覆盖 `Version 3.0.0`、`Version: 3.0.0` 与粗体冒号形态 `**Version**: 3.0.0`——
     `PROJECT_CONTEXT.md:4` 实存，原 `Version[: ]+` 模式匹配不到该行）；
     （CHANGELOG 与 `.tad/archive/` 不在扫描面；扫描面是显式文件清单，新增状态文档须先入清单——清单本身即 exclusion contract）；
  4. 「3.1」形态的版位数字在上述文件中的计数 == 0（Gate 2 修订放宽正则
     `(Version|v)\*{0,2}:?\*{0,2} ?3\.1([^0-9]|$)`，覆盖粗体冒号形态 `**Version**: 3.1`，
     尾部守卫防误伤 3.10+；基线：2026-10-04 以放宽模式重跑 = **7 条**，含 `docs/MULTI-PLATFORM.md:3`——
     旧模式基线 6 条恰漏此行，该行正是 A10 要改的行，旧模式下漏改会假绿）；
  5. `session-state.md` 与 `.tad/active/handoffs/` 现存文件对账：索引指向的 handoff 路径必须存在。
     **作用域钉死（Gate 2 修订）**：只查文件**头部多链索引块**（文件头 `>` 引用块内的索引行，
     至首个正文节标题之前），正文一律不查——正文是各链的历史状态存量（含已收口链的旧状态词），
     按全文实现必然误红；A12 的状态词修订也只作用于索引块。
- 修复动作**不在**脚本内：脚本红了，由人/Alex 另开纠偏（或在发版收口内当场改），严守
  gate-design 的「release gate 上 detect 与 heal 解耦」——不在发版流里自动改文档。
- Fixture：`.tad/tests/state-surface-fixture/` 放一份故意写错版本号的 NEXT 副本，
  AC 以「对 fixture 跑检查必须 exit 1、对真树跑必须 exit 0」双向验（防 vacuous AC）。
  Fixture 另含一行粗体冒号形态的版本声明负控：`**Version**: 9.9`（Gate 2 修订补入）——
  检查对该行必须命中并报错，否则粗体形态即成永久盲区（检查 3/4 的放宽模式靠此负控守住）。

**2026-10-04 Gate 3 条件 C1 增量追记**：机制 2 第 3 项模式家族已由增量设计 `.tad/evidence/designs/2026-10-04-state-surface-check-pattern-delta.md` 扩至括号版位形态（P1/P2 分支），以该件为准；本节原文保留作 Gate 2 时点记录。

**机制 3 — 发版收口挂钩（让回填成为发版的一部分，而不是靠记性）**
- 发版（*publish / release）收口清单新增三步，写进 release 收口流程文件。落点点名（Gate 2 修订）：
  release runbook 正本 = `.agents/skills/alex/references/publish-protocol.md`（Blake 在其发版收口
  对应节加下述三步文字）；`.tad/hooks/lib/release-verify.sh` 增 `state-surface` 子命令转调机制 2 的脚本：
  1. bump `.tad/version.txt` 的同一 commit **必须**同时含 `NEXT.md` 与 `ROADMAP.md` 头部行回填
     （pathspec 集合断言：release commit 文件集 ⊇ {version.txt, NEXT.md, ROADMAP.md}）。
     **断言执行者钉死（Gate 2 修订）：发版执行者本人**（收口人工步，不入检查脚本——脚本跑的是树、
     不是某个 commit，断言对象在 commit 生成后才存在）；执行命令：
     `git show --name-only --format= <release-commit>` 核对三文件齐备，命令与输出记入该次发版收口记录，
     缺一即不许宣告发版完成。HANDOFF §9.1 AC13 承接本机制的落地位验收；
  2. 发版后跑 `state-surface-check.sh`，非 0 不许宣告发版完成；
  3. 发版后重跑 D 项下游台账生成器，台账以 `git add -f` 单文件例外随收口 commit 入主仓
     （台账是派生物，见 §5；载体裁定（乙），理由见 §5.2）。

**机制 4 — 状态条目过期自检（轻量）**
- `NEXT.md` 头部既有规矩「动手前先验条目是否还成立」保留；机制 2 的第 5 项把
  「索引指向不存在文件」这一最常见的过期形态机器化。其余语义级过期（条目文字与 git 现实不符，
  如 A3）靠每轮 PM 自查 R# 的 git 对账覆盖，不假装能全机器化——在 NEXT 头部规矩行后补一句
  指针：「每轮自查以 `git log`/`git status` 对账本文件」，把人工面的触发点写死在文件里。

### 2.3 为什么废除「3.1」版位名（推翻 P1P3 §6.3 授权的理由）

- Gate 3 SAFETY 当时已把它记为观察项 C2（「文档头 3.1 vs version.txt 未 bump」），说明它从诞生起就在制造核对成本；
- R1 实查证明双口径已实际误导状态判断（「连版本号本身在自家仓内就有两个口径」）；
- 版位名的信息（多平台版）可由不带数字的表述承载，数字形态没有任何不可替代的收益。
  此推翻请 Gate 2 重点复核：若 Gate 2 认为应保留版位名，则 A9/A10 改为「在 AGENTS.md 头部
  一行内明示『3.1 = edition label, semver = 3.0.0, SSOT = version.txt』」的次选方案，
  且机制 2 第 4 项相应改为校验该明示行存在。二选一，不许两可——请 Gate 2 裁一项写入 HANDOFF 修订。

> **2026-10-04 Gate 2 裁定追记**：契合路 F2 专属裁定 + 技术路同判——**废除案成立**，明示次选案作废。
> HANDOFF 已按废除案回填（AC6 基线与模式按 R1 修订），本节的二选一就此关闭。

---

## 3. B 项设计 — Gate 4 证据终态改写

对象：`.tad/evidence/reviews/2026-09-15-gate4-acceptance-platform-adapters.md`
现状：第 9 行 `Gate 4 Verdict: CONDITIONAL PASS（verdict: PARTIAL）`，§3 列 5 项剩余项。

### 3.1 条件逐项核验（本席 2026-10-04 从盘上重跑，非引用旧文）

| # | Gate 4 §3 剩余项 | 核验方法与实测 | 结论 |
|---|---|---|---|
| B1 | commit 恰含 §6.1 九路径、subject 含 TASK 号 | `git show --stat 2fb80bf5`：恰 9 文件，subject = `feat(installer+docs): OpenCode/Cursor P1P3 support [TASK-20260915-OPENCODE-CURSOR-P1P3]`；且该 commit 已在 origin/main，本地与远端 0/0 | ✅ 已满足 |
| B2 | AC12：commit 后跑原命令，`MISSING=[] EXTRA=[] DELETED=[]` | 原命令以 HEAD 为对象且未带 `-M`；现 HEAD 已前进到 `b78173b3`，原样重跑无意义。本席以等价形式对 `2fb80bf5` 重组：`git diff-tree --no-commit-id --name-status -r -M 2fb80bf5` 与 §6.1 闭集比对 → `MISSING=[] EXTRA=[] DELETED=[]`（rename 呈 `R100`）。附带发现：不带 `-M` 时 rename 被拆成 A+D，`EXTRA` 与 `DELETED` 同时非空（技术路重跑实测）——原 AC12 命令有此小缺陷，终态附记须注明以 `-M` 口径为准及理由。**等价限定（Gate 2 修订补入）：本等价仅因 `2fb80bf5` 为 R100 纯 rename（字节级）而成立，不得泛化为 AC12 的通则——rename-带改（R<100）时 `-M` 口径会把真实删除洗成空集，终态附记必须载明 R100 这一事实。** | ✅ 已满足（等价重组，方法差异与 R100 限定已注明） |
| B3 | 补写 COMPLETION | 文件已在盘：`.tad/active/handoffs/COMPLETION-2026-09-15-platform-adapters-p1p3.md`（Blake 2026-09-16 作，内载 commit `2fb80bf5` 与 9 文件表）。两点尾巴：(a) 至今未入 git（按 C 表处置）；(b) 其「Pushed: NO — ahead origin/main 1」一行已被现实推翻（现 0/0）——入 git 前须做一行事实订正并在订正处标注日期，不许静默改历史 | ✅ 内容已满足；入 git 与一行订正归 C/Phase 2 |
| B4 | Gate 2 dual 证据落盘，或由人显式 waive | 实查 `.tad/evidence/reviews/` 无 `2026-09-15-gate2-review-platform-p1p3-{spec,scope}.md`，确缺。按既定口径**不补造**，走 waiver。终态改写必须显式引用该指针，并写明 waiver 的实质理由（S 号小修、设计由 Alex 直入 handoff、Gate 3 双审 + Gate 4 已实际承担独立复核） | ✅ 以 waiver 闭合（指针已落盘：`.tad/evidence/reviews/2026-10-04-waiver-p1p3-gate2-evidence.md`，PM 2026-10-04 补记，**waiver 生效日 = 2026-10-04**；技术路 T6 已核满足前置） |
| B5 | 观察项：`tad.sh` "only target" 注释过时 | Gate 4 原文即标「非阻塞、另开卫生刀」 | 不在本批；终态附记中标「转后续卫生刀，未关」即可，不算未满足条件 |

**正当性总括**：五项中 B1/B2/B3 是可机器复核的事实条件，全部已由盘上事实满足；
B4 是程序条件，以显式 waiver 闭合（waiver 本身是 Gate 4 原文给出的合法出口之一：「或由人显式 waive」）；
B5 原文即非阻塞。故「CONDITIONAL → 终态 PASS」的改写有据，不是追认式漂白。

### 3.2 改写稿要点（Blake 执行；只许按此改，不许重写历史正文）

1. **头部状态行**（文件第 9 行）：`CONDITIONAL PASS（verdict: PARTIAL）` →
   `PASS（终态，2026-10-04 核销 CONDITIONAL 条件）`；机器令牌行同步给出 `verdict: PASS`。
2. **§3 剩余项逐项销账**：在原「剩余项」清单每项后追加 `→ CLOSED（证据：…）` 一行，
   证据指针分别为：B1 → `2fb80bf5` + origin/main 0/0；B2 → 本设计 §3.1 的等价重组命令与输出；
   B3 → COMPLETION 路径（入 git 后的 commit 号由 Phase 2 回填）；B4 → waiver 指针 `.tad/evidence/reviews/2026-10-04-waiver-p1p3-gate2-evidence.md`（引用以 **2026-10-04 为 waiver 生效日**表述——该件系 PM 同日事后补记，不得写成「9 月当时已有 waiver」）；
   B5 → 「非阻塞观察，转后续卫生刀」。
3. **新增 §8「终态核验附记（2026-10-04）」**：含核验人（Alex, Gate 4 终态复核）、
   三项实测命令与输出摘要（branch --contains / rev-list 0 0 / diff-tree -M 三项空集）、
   waiver 引用（生效日 2026-10-04）、B2 的 `-M` 方法差异说明（含 R100 限定）。附记是追加，不改 §1–§7 原文一字。
4. **禁止项**：不许把原文的 CONDITIONAL 叙述改成「一开始就是 PASS」；不许删 §3 剩余项原文；
   不许顺带改其他证据文件。历史怎么写的就怎么留，终态靠附记与状态行成立——
   这正是 claims-need-carriers 的反面纪律：结论要有载体，历史也要有载体。
5. **载体（Gate 2 裁定（乙））**：改写完成后，本文件以 `git add -f` 单文件例外入主仓（随 Phase 2 收口提交）。
   理由：本文件是本批的审计锚点，`.gitignore:122` 本批不动（F-18 发行瘦身依据仍成立），
   普通 pathspec 进不了任何 commit——不走 `-f` 例外，「终态 PASS」将与它所取代的 CONDITIONAL 一样无 git 载体。
   HANDOFF §9.1 AC14 验三件交付物载体。

---

## 4. C 项 — 未入 git 文件逐项处置表

口径：以 2026-10-04 本席实跑 `git status --porcelain` 的 23 条为准（未跟踪目录以 `-uall` 展开列子项）。
执行纪律（Blake）：**禁止 `git add -A`**；按下表分三批 pathspec 提交（批 C1 证据链、批 C2 §18 成套、
批 C3 PM 留痕）；每批提交后跑 `git status --porcelain` 复核剩余项与本表一致；
subject 分别含 `TASK-20260915-OPENCODE-CURSOR-P1P3`（C1 中属该刀者）或本批 TASK 号。
**删除候选：本轮为零**——无一条有证据证明是废弃物，按不可逆操作纪律，宁可保留待人定，不许 Blake 自行删。

### 4.1 已改未提交（M ×7）

| 路径 | 处置 | 理由 |
|---|---|---|
| `.tad/active/epics/EPIC-20260816-framework-health-repair.md`（452 行→存根） | commit（批 C2） | §18 补缺的存根化，与同名文件夹三件成套，拆开提等于指针指向未入仓文件 |
| `.tad/active/epics/EPIC-20260831-capability-builder-v1.md`（256 行→存根） | commit（批 C2） | 同上 |
| `NEXT.md`（+15 行） | 保留本地 | 本批 Phase 1 将整体纠偏该文件（含头部行），届时连同既有 diff 一并审后提交；现在盲提会把未审 diff 混进证据批 |
| `docs/pm/now.md`、`docs/pm/intent.md`、`docs/pm/acceptance.md`、`docs/pm/auth.md` | 保留本地 | PM 工作面文件（VM 侧单写），属机制吸收期的工作状态，非本批证据链；由 PM 在机制收口时另行处置，不进本批 commit |

### 4.2 已删未提交（D ×1）

| 路径 | 处置 | 理由 |
|---|---|---|
| `.tad/active/handoffs/HANDOFF-20260929-agent-eval-hillclimb-l2-hybrid.md` | commit 该删除（随 A2 批） | hillclimb 已由 `b78173b3` 落地，handoff 使命终结；删除须与 NEXT 迁档同批，防「队列说未交、文件已删」的半截状态 |

### 4.3 未跟踪（?? ×15 条目，展开 42 文件）

| 路径 | 处置 | 理由 |
|---|---|---|
| `.tad/active/handoffs/COMPLETION-2026-09-15-platform-adapters-p1p3.md` | commit（批 C1，先做 B3 的一行 push 状态订正） | Gate 4 剩余项 B3 的载体本身；不入 git，B 项终态无据 |
| `.tad/active/handoffs/COMPLETION-20260915-notebooklm-deprecation.md` | commit（批 C1） | 同类完工单，2026-09-15 批次证据尾巴，一并入账 |
| `.tad/active/handoffs/HANDOFF-2026-09-15-claude-decouple-design.md` | commit（批 C1） | v3.0.0 移除批的设计载体，审计链一环 |
| `.tad/active/handoffs/HANDOFF-2026-09-15-claude-removal-plan-codex.md` | commit（批 C1） | 同上 |
| `.tad/active/handoffs/HANDOFF-2026-09-15-claude-removal-plan.md` | commit（批 C1） | 同上 |
| `.tad/active/epics/framework-health-repair/`（EPIC.md / declarations.md / session-state.md） | commit（批 C2） | §18 补缺成套件，与 4.1 存根同批 |
| `.tad/active/epics/capability-builder-v1/`（EPIC.md / declarations.md / session-state.md） | commit（批 C2） | 同上 |
| `.tad/active/TICKET-20260916-codex-ledger-reverification.md` | commit（批 C1） | 开放工单入账才可追踪；入 git ≠ 关单，任务本身仍 OPEN（P4，禁空关） |
| `docs/pm/open-cards/`（7 文件，含本步 `open-20261004-tad-state-surface-closeout-alex.md`） | commit（批 C3） | 双落规则的仓内落点；R1-P3 已指出「双落只落了一半」，入 git 才算落全 |
| `docs/pm/chat-card-stamps/`（6 文件） | commit（批 C3） | 开跑卡 stamp 留痕，与 open-cards 同类 |
| `docs/pm/restates/`（6 文件） | commit（批 C3） | 机制复述留痕件，同类入账 |
| `docs/pm/segment-status/`（6 文件） | commit（批 C3） | 机制段状态留痕件，同类入账 |
| `docs/pm/evidence/dual-write-once-20260921.md` | commit（批 C3） | 证据件，证据不入仓等于没证据 |
| `docs/pm/ops-knowledge.md` | commit（批 C3） | 隐性知识 SSOT 本体，未入 git 是 P3 同类病 |
| `docs/pm/ops/`（3 份 draft：agent-tune-eval-hooks / mech-absorb-thin-scan-steps / skill-draft-mech-absorb-thin-scan） | 保留本地 | 均为未定稿草稿，无正式文件引用；定稿或废弃由 PM 定夺，不在本批冒充入账 |

---

## 5. D 项设计 — 下游版本台账

### 5.1 形态

- **落点**：`.tad/evidence/pm/downstream-versions.md`（生成物，人读 + 可 grep）。
  该路径在 `.gitignore:122` 忽略树内，入仓载体走 `git add -f` 单文件例外（Gate 2 载体裁定（乙），见 §5.2）。
  文件头固定三行：`generated-by: .tad/scripts/scan-downstream-versions.sh`、
  `generated-at: <date>`、`source-of-truth: 各仓 .tad/version.txt（本文件是派生索引，禁止手改）`。
- **正文**：汇总段（总数 / 在当前版本数 / 无 version.txt 数 / 空 version.txt 数 / 版本分布计数）
  + 明细表（仓名 | 版本 | 备注），版本缺失记 `MISSING`、空文件记 `EMPTY`，不许留空白格——
  空白会被读成「没扫到」，而 MISSING/EMPTY 是扫到的事实。
- **生成器**：`.tad/scripts/scan-downstream-versions.sh`（bash + 标准工具，无 yaml 依赖），
  入参为 yun-sync 根（默认取仓的父目录），遍历 `*/.tad/`，读 `version.txt` 首行去空白。
  **目录名按字节原样处理（Gate 2 修订补入）**：遍历与读文件时路径一律引用/以 NUL 分隔传递，
  目录名**不 trim、不规范化**——仓内实存尾随空格 + 非 ASCII 目录名 `Pokémon `（其 version.txt 为空，记 EMPTY），
  生成器对该仓的台账行仓名列必须与 `ls` 字节一致，不许把尾空格吃掉后与磁盘对不上。
  目录是事实源、台账是派生索引（handoff-design 的 manifest 模式：derived index, directories are ground truth），
  所以台账永远可由重跑再生，手改台账无意义且被文件头明示禁止。

### 5.2 更新时机

1. **发版收口**：机制 3 第 3 步强制重跑，台账以 `git add -f` 单文件例外随收口 commit 入主仓
   （落点 `.tad/evidence/pm/` 命中 `.gitignore:122`，普通 pathspec 提不进去；Gate 2 载体裁定（乙）：
   三件小文件交付物逐件 `-f` 例外入主仓最可查，maintainer-evidence 分支同步恢复另立独立单，不在本批）；
2. **每轮 PM 自查（R#）开跑时**：作为盘面基线重跑，结果写进该轮自查报告；
3. **手工**：任何人/Agent 需要回答「谁在哪一版」时先重跑再回答，不许引旧台账当现况。

### 5.3 验证

- 可重放：连续跑两次，输出除 `generated-at` 行外 0 diff；
- 计数对账：明细行数 == `ls -d <yun-sync根>/*/.tad | wc -l`（本轮基线 53）；
- 抽查：随机 3 仓手读 version.txt 与台账行一致（Gate 4 由 Alex 另选 3 仓，不用 Blake 的样本）。

### 5.4 本轮基线（设计时实测，供 Gate 4 对照）

53 仓：3.0.0 ×22；2.42.0 ×7；2.30.0 ×6；2.33.0 ×4；2.44.1 / 2.41.0 / 2.40.0 / 2.39.0 / 2.34.0 /
2.32.1 / 2.32.0 / 2.26.0 / 2.2.1 各 ×1；1.5 ×2；MISSING ×2（fidara-images-mirror-wt、外刊阅读）；EMPTY ×1（`Pokémon `，目录名尾随空格）。

---

## 6. 实施切分（HANDOFF 承载）

- **Phase 1（A）**：§2.1 纠偏表逐项落地 + `state-surface-check.sh` 与 fixture + release 收口挂钩文字。
- **Phase 2（B + C1/C2）**：前置 = PM 给 waiver 指针（**已闭合**：`.tad/evidence/reviews/2026-10-04-waiver-p1p3-gate2-evidence.md`，2026-10-04）；Gate 4 证据终态改写、COMPLETION 一行订正、
  证据链与 §18 成套两批 pathspec 提交、hillclimb handoff 删除随 A2 迁档同批；Gate 4 改写件与 A2 迁档件以 `git add -f` 例外入主仓（载体裁定（乙））。
- **Phase 3（C3 + D）**：PM 留痕批提交；台账生成器 + 首份台账以 `git add -f` 例外入仓。
- 每 Phase 完工走 Gate 3 独立双审；全批完工由 Alex Gate 4 从盘上重算 §9.1。
- 本批**不 push、不 tag、不发版**（commit 只到本地 main；push 与 v3.0.1 批次由 PM/人另行定）。

## 7. 风险与回滚

| 风险 | 对策 |
|---|---|
| 并发终端的 staged 骑手被误提 | 全部 commit 用显式 pathspec；提交前查 `git status` 的 staged 区（handoff-design 的并发终端条目） |
| 纠偏改错历史记录 | A 表只改现行声明行；历史条目（CHANGELOG、DONE 行）不在改面；fixture pins 不动（release-sync 的 exclusion 纪律） |
| 终态改写被读成漂白 | §3.2 的追加式改写法：原文不动、附记承载核验过程与 waiver 出处 |
| waiver 指针不到位 | Phase 2 BLOCKED 设计（§8.4 Friction），不许 Blake 以「口径已知」自行开工 B 项 |
| 回滚 | 每批 commit 独立，`git revert` 按批回滚；文档纠偏无状态迁移，回滚零副作用 |

## 8. Gate 1 自检（对 gate-canonical-checklist Gate 1 四项）

- [x] Problem defined — R1 的 P2/P3：状态面与证据面不实，与盘上现实矛盾（§1 取证）。
- [x] User identified — 使用者 = TAD 维护者本人（PM/Alex/Blake）与下游 53 仓的答疑场景。
- [x] Scope bounded — 只打 P2+P3；P1（hooks 强制力/真机回归）与 P5（瘦身）明确排除；禁区见 HANDOFF §10。
- [x] Acceptance criteria verifiable — HANDOFF §9.1 每行均为 command / path-check / fixture 文法，无散文行。

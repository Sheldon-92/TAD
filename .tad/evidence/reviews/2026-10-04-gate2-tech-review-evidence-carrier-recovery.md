# Gate 2 Tech Review — 证据载体恢复执行链设计

- step_id：`tad-evidence-recovery-gate2-tech-01`
- 评审对象：`.tad/active/handoffs/HANDOFF-2026-10-04-evidence-carrier-recovery-execution.md`（56,104 B，落盘实测与设计自报一致）
- 评审基线：票 `TICKET-20261004-evidence-carrier-recovery-execution`、PM 载体裁定、PM 三点裁定（`2026-10-04-evidence-recovery-design-rulings.md`）、S1 summary（四锚与复跑序列）
- 评审者：独立 Review 会话（与设计者 Alex、fit 路评审者互不可见）
- 日期：2026-10-04

## Verdict

**CONDITIONAL** — P0＝0；P1＝4（均为设计增补可关闭，不涉及重做设计）；P2＝5。

设计主干成立：plumbing 临时索引路线与 S1 安全管线同口径、ref 原子前移与回滚形态正确、推送路径失败形态写全、git 写围栏 W1–W4 可验。条件集中在两处口径未写死（盘点产物剔除对的队列归属、C3 尖前置自检与重跑/补跑的冲突）与两处 PM 裁定未落进设计产物面（裁定 2 对照行、裁定 3 备案件）。

## 读取清单打勾回执

- [x] 1. 设计本体 HANDOFF 全文（§1–§12＋附录 A，56,104 B）
- [x] 2. PM 三点裁定 `2026-10-04-evidence-recovery-design-rulings.md`（裁定 1/2/3 全文）
- [x] 3. S1 summary `inventory-summary.md`（四锚、方法口径、复跑命令序列、剔除规则）
- [x] 4. 票 `TICKET-20261004-evidence-carrier-recovery-execution.md`（范围四项与红线）
- [x] 5. `.gitignore` 第 120–123 行（两树忽略行在 121–122，维护者注记在 115–120，已对盘核）与 `patterns/shell-portability.md:316-318` quotepath 条

## Findings

### P1-1 盘点产物剔除对（EXCL 2 件）在 Phase 0 的队列归属未写死，AC6 断言随之有 ±2 歧义

- 定位：设计 §3 FR2、§6 Phase 0 步骤 3–4、§9.1 AC6；对照 S1 summary「复跑命令序列」剔除规则。
- 事实：S1 复跑口径规定 A 集须剔除盘点产物 2 件（`inventory-manifest.jsonl`、`inventory-summary.md`），四锚比对以此为准。FR1 对「复算四锚」写明了剔除规则，但 FR2 的追加规则只说「复算时点盘上新增而母本无的行按同一管线补算 class 后新增行追加」——这 2 件恰是「盘上新增而母本无」的行，是否被追加进执行版清单、进而作为 no-carrier 队列被同步，未写死。两种读法后果都坏：(a) 追加并同步后，Phase 3 按 S1 序列（含 EXCL）复算时这 2 件在 B 不在 A，BRANCH_ONLY 虚高 2，AC6「BRANCH_ONLY＝keep 的 blob 行数」必假 FAIL；(b) 不追加时，AC6 中 NOCARRIER 期望式「盘上路径集减执行版清单路径集」若其盘上集未同步适用 EXCL，与 S1 序列实测值差 2，同为假 FAIL。
- 修法指向：设计增补一句写死——Phase 0 的差集计算与执行版清单追加同样适用 EXCL（2 件不入清单、不入队列，仅在锚比对中按 summary 口径处理），且 AC6 期望式的盘上集明确与 S1 序列同一 EXCL 口径。或反向选定「入队同步」并同步修订 AC6 期望式（BRANCH_ONLY 期望值＋2 并注明出处）。二选一，不许留双读。

### P1-2 C3 同步脚本的分支尖前置自检与 NFR4 幂等、§4.7 补跑直接冲突

- 定位：设计 §4.2 C3「前置自检（…当前分支尖与 Phase 0 记录一致，不一致即停）」vs §3 NFR4「同步脚本第二跑必须 NO-OP」、§4.7「同名改写件…补跑一轮同步」、§6 Phase 2 自测三态（正常／NO-OP／失败中止）。
- 事实：首轮同步成功后分支尖已前移、不再等于 Phase 0 记录。按 C3 字面，第二跑（无论是 NFR4 要求的幂等复跑、Phase 2 自测的 NO-OP 态，还是 §4.7 的补跑一轮）都会在前置自检处停步，退出形态是「不一致即停」而非约定的 NO-OP（退出码 3）。Phase 2 自测在临时克隆内同样复现：第一跑后克隆尖已变，第二跑过不了自检，三态证据拿不到。
- 修法指向：把前置自检改为对「本次运行的期望基线」断言并参数化（如脚本接受 `--expect-base <sha>`，默认取执行版清单/运行记录中登记的上轮产出尖；首跑为 Phase 0 记录，再跑为上轮新尖），或改为断言「当前尖是 Phase 0 记录尖或其在本链围栏内产生的后继」。增补后须同时回改 C3 步骤文中受影响的一句，保证自测三态可达。

### P1-3 PM 裁定 3 的书面备案件未落进设计产物面（裁定与设计冲突，以裁定为准）

- 定位：设计 §6 Phase 1 步骤 1、§7 CREATE 清单、§9.1（AC15 只管 gitlink，无第 16 件备案件条目）；对照 PM 裁定 3。
- 事实：裁定 3 要求第 16 件（`termination-secret-isolation.json`）的只读核查留书面备案件——记核查人、核查方法（模式扫描＋人工目检范围）、结论，落 `.tad/evidence/pm/`，文件名由执行步定并在 Phase 1 定稿记录中回指；且疑似含真实凭据时「该件不许进入任何载体、其余 16 件照常推进」。设计只有 Phase 1 步骤 1 的「结论一行报 PM」，无备案件交付物、无 AC 覆盖、§7 清单无此件；且设计「若疑似含真实凭据，立即停步报 PM，该件 decision 悬置」未写明停步范围，与裁定 3「其余 16 件不受影响」的口径衔接含糊（可被读成全链停步）。
- 修法指向：增补备案件为 Phase 1 正式交付物（路径形态 `.tad/evidence/pm/<执行日>-termination-secret-isolation-check.md` 或由执行步定名并回指）、在 §7 CREATE 增列、加一条 AC（备案件在盘且含核查人/方法/结论三项、不含疑似凭据原文），并把 Phase 1 步骤 1 的停步措辞改齐为「该件悬置、其余 16 件照常」。

### P1-4 PM 裁定 2 的弃置对照行（原件路径＋sha256）与「找不到原件自动转保留」在设计中无落点、无断言

- 定位：设计 §4.2 C2 列定义（path／class／decision／reason／ruling_ref）、§9.1 AC3；对照 PM 裁定 2。
- 事实：裁定 2 要求每件弃置在 Phase 1 定稿与 Phase 3 对账时留一行「原件现行路径＋原件 sha256」对照，任一件找不到在册原件即自动转保留并报 PM。设计（先于裁定写成）无此机制：C2 无承接列、未指定对照行落点（处置表附列／定稿记录／首轮报告均未写），AC3 只验 17 行形态与 decision 落定，不验对照行存在与自动转保留的触发。Gate 3 无从执行此条裁定。
- 修法指向：设计增补——指定对照行落点与格式（如处置表增 `origin_path`／`origin_sha256` 两列，drop 行必填）、自动转保留的判定与留痕位置，并在 AC3 或新增 AC 中加入可跑断言（drop 行对照两列非空且 sha 与原件当场重算一致）。

### P2-1 C1 冻结规则与 §4.7 追加例外自相矛盾

- 定位：§4.2 C1「Phase 1–5 只回写 outcome／sha／commit，不增删行」vs §4.7「把该件以新增行追加进执行版清单并补跑一轮」及 §6 Phase 3 步骤 4 同义安排。
- 修法指向：在 C1 冻结句后增 carve-out 一句（§4.7 同名改写件的追加为唯一例外，追加行须带可 distinguisher 标记，如 `appended_at_phase3: true`），并确认 AC1 的计数式在例外发生后仍成立（其 `appended_at_phase0` 计数口径不受 Phase 3 追加行污染——现式成立，但请在增补中写明）。

### P2-2 FR5 与 AC6 对 BRANCH_ONLY 期望值的措辞不一致

- 定位：§3 FR5「BRANCH_ONLY 恰等于处置表 keep 件数」vs §9.1 AC6「TOTAL_BRANCH_ONLY 等于处置表 decision=keep 的 blob 行数」。
- 事实：处置表 17 行含 gitlink 行；若 gitlink 裁定 keep，「keep 件数」＝10（含 gitlink），而 BRANCH_ONLY 按 S1 口径只数 blob，期望值应为 9。AC6 的「blob 行数」措辞正确，FR5 散文措辞多 1。§9 已声明 §9.1 为 PRIMARY VERIFICATION SOURCE，故不构成执行歧义，仅属文本不一致。
- 修法指向：FR5 措辞改齐 AC6（「keep 的 blob 行数，gitlink 不计」）。

### P2-3 AC8/AC10 的基线钉值对并发链活动敏感，设计未声明时点口径

- 定位：§9.1 AC8（父须为 8713ea4e…）、AC10（main 尖须等于 5619b095…且跟踪修改为 0）；对照 §2.3 已自承「执行期间其他链仍可能往两树落盘」。
- 事实：AC10 把 main 尖钉死为设计时点值；本链执行跨度内若 PM 按 R1 先例另行收口提交 main（裁定 1 明确预留此类 PM 动作），AC10 将假 FAIL，与本链实施无关。盘上两树的新增件已被冻结口径覆盖，但 main ref 的推进未被任何口径覆盖。
- 修法指向：增补一句时点声明——AC8/AC10 的基线在 Phase 0 完工记录中以复算时点值重新登记为准（Phase 0 记录即基线源），或声明 AC10 的 main 尖断言只针对「本链不得动 main」，执行法为比对 Phase 0 登记值而非设计时点值。

### P2-4 AC14 把看守脚本实现形态钉死为 shell `-gt` 习语，C5 未作此限定

- 定位：§9.1 AC14（`grep -qE '\-gt 100'`／`'\-gt 21'`）vs §4.2 C5（只写行为，未限定语言/习语）。
- 事实：C5 允许内嵌 python 实现（如比较式写作 `n > 100`），此时阈值语义正确但 AC14 的字面 grep 必 FAIL。按现文本 Blake 只能以 bash test 习语实现才可过——这是 AC 对实现形态的隐性约束，未在 C5 规格中声明。
- 修法指向：二选一——在 C5 写明阈值判定须以 bash `[ … -gt 100 ]`／`[ … -gt 21 ]` 形态落地，或 AC14 放宽为接受等价数值比较式（并给出等价式的可跑 grep 形态）。

### P2-5 AC5 正项集合未覆盖 read-tree/write-tree，负项 `git add` 字面 grep 对注释脆弱

- 定位：§9.1 AC5。
- 事实：AC5 正项验 GIT_INDEX_FILE／hash-object／update-index／commit-tree，未验 C3 步骤中的 read-tree 与 write-tree（缺 write-tree 时 commit-tree 无树可提，机制实际不可缺位，但断言面未覆盖）；负项以 `grep -c 'git add'`＝0 判定，脚本注释中若出现「不用 git add」字样即假 FAIL（C3 头部注释恰被要求写围栏声明，此风险具体）。
- 修法指向：正项增 read-tree、write-tree 两词逐项断言；负项改为对命令位置的判定（如只对非注释行 grep，或改验 `git add` 不在可执行行出现），或在 C3 注释规范中明示注释不许出现该字面串。

## 焦点逐项结论（对应激活包 ③）

- **Phase 0 复算口径**：管线本体与 S1 同源（`find -print0`＋`ls-tree -r -z`、交集逐件 hash-object 比对、gitlink 单独注记、不入计数），与 quotepath 条（`shell-portability.md:316-318`）一致；唯 EXCL 对的队列归属未写死（P1-1）。
- **Phase 2 同步脚本**：plumbing 路线成立（临时索引 read-tree→cacheinfo→write-tree→commit-tree→update-ref，逐件 hash-object -w 当场 sha 即 FR8 凭据，时点定义清楚）；幂等论证被 C3 尖自检破坏（P1-2）；失败中止形态正确（任一子进程非零即不执行 update-ref，游离 blob 无害）。
- **Phase 3 断言**：逐锚独立断言、AC7 全量逐件 sha 对账（不抽样）真能证补同步完成；STALE=0 判据与 §4.7 同名改写处置闭环；NOCARRIER 与 BRANCH_ONLY 两锚的期望式受 P1-1/P2-2 影响，增补后成立。
- **Phase 4 推送**：失败形态写全——收敛确认不等不许推（§4.5 步骤 1）、`.sync-conflict` 命中停步报 PM、gh 失效停步且不许 VM 直推/不许落盘凭据（§4.5 失败处置、NFR3）、验同尖三值并列（本地尖／origin 跟踪尖／报告记录值，AC9＋C4）。grokbox 侧 rev-parse 同值后 push 所需对象经 Syncthing 同步 `.git` 到达，R1 先例已证此路径，此项无 finding。
- **git 写围栏**：§4.6 W1–W4 表格形态可验（脚本正文核＋reflog 对账＋AC10–AC12、AC15），禁动清单齐（main ref、其他分支、`.gitignore` 指纹、3 件例外、盘上两树既有件）；AC5 断言面小缺口见 P2-5。
- **第 16 件**：设计有只读检查与停步安排（§6 Phase 1 步骤 1、附录 A.3 附条件保留），方向与裁定 3 一致；差距在备案件产物化与停步范围措辞（P1-3）。

## 本件自报

- 本件路径：`.tad/evidence/reviews/2026-10-04-gate2-tech-review-evidence-carrier-recovery.md`
- 字节数与 sha256：见落盘后追加行（自报行不计入被测内容，PM 以盘上实测复核为准）。

- 自报（本行追加前的文件实测）：bytes=12568；sha256=e49ca25f18402e3514a1b6d28b994a1586c915236268febc7a156d8bda348c65

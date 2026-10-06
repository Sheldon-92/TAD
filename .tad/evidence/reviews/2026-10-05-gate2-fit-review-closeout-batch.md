# Gate 2 Fitness Review — 本体收口批设计 HANDOFF

- 评审路：fitness（对票与对判断）
- 评审者：独立会话 Gate 2 评审者（fitness 路）
- 日期：2026-10-05
- 评审对象：`.tad/active/handoffs/HANDOFF-2026-10-05-tad-closeout-batch.md`
- 对象锚复算：62,785 B／sha256 `b0e5ba0a20271f331f6915b30e36ed7afa83a89021087bfdc95982ed49f96962`——与派发锚全等，开审对锚通过
- 判据正本：票 `.tad/active/TICKET-20261005-tad-closeout-batch.md`；判断正本 `.tad/evidence/pm/2026-10-04-gm-inputs-judgment.md`；GM 输入正本 `gm/.tad/evidence/reports/2026-10-tad-pm-inputs.md`

## 结论：CONDITIONAL

P0＝0／P1＝1／P2＝4。本设计的七件落点齐全、与判断口径逐件对齐、CF 处置方向全部可接受、版本提议成立、件 4b 裁定纳入（见专节）；放行条件为两项定点增补（C1、C2），均为一行级修正，增补后经 PM 定点核即可销账，不需重跑双审。

## 条件清单（放行前必办）

### C1（源 P1-1）：§4.6 指针行文本与 AC10 自相矛盾，须订正

盘上实测（python 逐字量）：

- §4.6 给定的第二列文本 `Unified research pipeline for AI agents — 5-phase (Plan→Source→Curate→Analyze→Output) with state` 实长 **96 字符**，且确为 registry description 的真前缀（startswith 成立）；
- 设计 §4.6 自称「本行 71 字符」，与实测不符；
- AC10 的判据带为长度 **60–75**——Blake 若逐字落 §4.6 文本，AC10 必 FAIL；若为过 AC10 自行截断，则违反 §4.6 的逐字给定。实施者无论怎么做都错，是设计缺陷、不是执行风险；
- 邻行真实惯例（盘上实测 AGENTS.md 指针表全 25 行）：13 行 registry 派生行（academic-research 至 synthetic-data）第二列长 **69–70 字符**、硬截断（可截在词中，如 academic-research 行截于「review, c」）；设计所称「66–72」亦与实测微差。

修正项（可执行）：增补 §4.6——第二列改为 registry description **前 70 字符硬截断**（与 13 行 registry 派生邻行惯例一致、startswith 仍成立、70 ∈ AC10 的 [60,75] 带内）；「71 字符」订正为 70。AC10 不动。

### C2（源 P2-4）：§4.2 丙层枚举漏 ROADMAP.md，与 §7.4 不一致

§7.4 保留集含 `ROADMAP.md`，§4.2 的丙层逐项枚举未点名该文件。§4.2 自带规则「分类遇未点名新路径 → 停步报 PM」：若 Phase 0 时 ROADMAP.md 出现在 `git status --porcelain` 输出中，将触发一次本可避免的停步。修正项：增补时把 `ROADMAP.md` 补入 §4.2 丙层枚举，与 §7.4 对齐。

## 件 4b 裁定：纳入

设计以 CF-4 把件 4b（AGENTS.md pack 指针表补 research-methodology 一行）点名上报存废，本审明确裁定：**纳入本批**，FR5／AC10 保留生效（AC10 按 C1 修正后的 §4.6 文本判读）。理由：

1. **装载点位纪律**：指针表是 pack 的关键词路由/宣告面。无指针行，件 4 物化的投影在该面不可达——本批若只补投影不补指针，等于亲手留下一件无完整装载点位的产物，与 D 线刚立的 Canonical 纪律「放进文件的东西必须有装载点位」直接冲突。
2. **同源缺陷的三张脸**：登记 26 件／`.agents/skills/` 投影 25 件／指针表 25 行（盘上实测：表 25 pack 行、research-methodology 行 grep ＝ 0），是输入 4 定性的「单件漏生成＋检测缺口」的同一缺陷在三个面上的投影。件 5 断言只守登记↔投影一对，指针面不在断言面内——本批不补，指针缺行将继续静默，正是输入 4 所指「漏件可长期静默」模式在另一面上的残留。
3. **风险可控**：`AGENTS.md` 已在票面写集内（件 1 的对象＋版本标记行同文件），4b 只增加一个 hunk、不扩文件集；格式由 AC10 机器判据封顶（registry 前缀＋长度带）；§4.12 已备 hunk 级回退与分行判读。
4. **程序正当**：设计未擅自扩面，而是点名上报裁定；票面红线「只改本票清单内文件」约束的是文件集，AGENTS.md 在集内，不构成破线。票件 4 的落地目的为使该 pack 可装载，指针行是其装载面，属件 4 的应有之义。

## 逐件对票核查（七件落点齐全性与口径一致性）

| 件 | 落点（设计） | 对票/对判断核查 | 结论 |
|----|--------------|------------------|------|
| 1 C1 提交面 | §4.2：甲/乙/丙三层分类＋节提取 sha256 双时点（Phase 0/3）复算判据 | 票件 1 要求「盘清提交面＋逐字判据」——齐备；定稿出处（D 线 Gate 4 验收件）引用准确；乙层以 hunk 计不以文件计，与同文件另两 hunk（指针行/标记行）分行判读，口径正确 | ✅ |
| 2 台账头注 | §4.3：生成脚本头部 printf 一行＋Phase 3 bump 后重生成 | 见下「台账头注 fidelity」专节 | ✅（忠实） |
| 3 自加槽契约 | §4.4：release-runbook 新节全文＋trading-agent 迁移口径 | FR3 五要素逐项在册：槽标记对与文件首位置、覆盖前提取并随既有备份保存、回贴＋byte-identical 比对才算完成、无槽存量逐案留痕、迁移口径（下次对齐时由同步侧执行、首 4 行逐字裹入、位置不动、本批不动下游）。盘上实测 trading-agent AGENTS.md 172 行、L1–4 为自加段、L5 起本体标题，与契约「Known legacy instance」所述逐项吻合。落点选择成立：票件 3 明定「发布/同步规程立条文」，判断处置中「给根 AGENTS.md 定契约」的对象是下游根文件这一类受治文件；义务承担者是同步侧，其必读面为 runbook（publish-protocol Guard 2 强制读，盘上 L37–40 实测在册） | ✅ |
| 4 投影补生成 | §4.5：同构物化规则＋CREATE 12 件清单 | 清单与 pack 本体盘面逐件对上：源 15 件 − forbidden 4 件（CAPABILITY.md/README.md/CHANGELOG.md/install.sh，capability-skill.sh L44/L179 明文实测在册）− CAPABILITY 本体名，＋派生 SKILL.md ＝ 12 件，无漏无造。派生规则（CAPABILITY.md 去 status 行）经样本 diff 形态佐证（agent-memory 样本 frontmatter 恰删 status 一行、余为装后演化）；`project` 子命令已于 v3.0.0 移除并明示「直接在 .agents/skills 下物化」，手工 shell 复制与工具口径一致，不违「不手写已有工具能做的事」原则（该工具已无此功能）。CAPABILITY.md `^status: ` 实测恰 1 次，§4.5 的先断言后删除成立 | ✅ |
| 5 一致性断言 | §4.7：scan-packs.sh 扫描后断言段（登记 ⊆ 投影单向）＋三态负控 fixture | 判断处置②原文「registry 登记每件必须有 `.agents/skills/` 投影，缺即红」即单向子集，设计方向与之一字不差；非 pack skill（alex/gate 等）明确排除在断言面外，避免反向误红。脚本盘面核实：`--packs-dir` 参数分支、目录基名收集 pack_name、OUTPUT 随 PACKS_DIR 派生、结尾 echo 位置，均与设计落点描述一致；fixture 根按 `--packs-dir` 派生的隔离法成立（`<fix>/.tad/capability-packs` 的 `../..` ＝ `<fix>`） | ✅ |
| 6 S5 第五件 | §4.8：evidence-collection.md 新节全文 | 票件 6 要求两要素——唯一路径（mktemp 或直落本仓证据目录、名称带任务标识）＋引用前与盘上实存交叉核对——条文两条逐项对应；事故出处（2026-10-04 S6 串台）与 `~/AGENTS.md` 成因记录一致；落点锚（§7 Delivery Evidence L245 起、Pattern Recognition Protocol L284）盘上实测在册；「自本链起对本链生效」（NFR4）是正确的自我适用 | ✅ |
| 7 计数行修正 | §4.9：gate SKILL 三处逐字改动 | 盘上实测：Canonical Gate 3 ＝ 7 项（节首 MECE 注「7 items check 7 distinct artifacts」在册）；inline 副本 L279 注「6 items check 6 distinct artifacts」、L280「Critical Check (6 items)」，列表 6 项、末项为 Knowledge Assessment，Provenance 插入点存在。设计对差异的定性（副本漏 Canonical 第 7 项 Provenance）属实；AC14 三段合取（计数行改准＋Provenance 在册＋行集计数相等）符合「计数行属判据面、不用单一 grep 下结论」的既有教训 | ✅ |

无漏件。批内唯一票面外扩面即件 4b，已裁定纳入（见专节）。

## 台账头注 fidelity（生成脚本解法是否忠于原判）

**忠实。** 判断原判要求头注落到台账件上以消除「总数 53」的误读面；而台账是 publish-protocol step3e 明文「派生索引，禁止手改」的派生件（盘上实测 step3e 第 3 步原文在册），且 step3e 本身就是台账的收口重跑点——手改台账会在下一次重生成时被整体冲掉，头注随之消失，原判目的落空。经生成脚本头部 printf 落盘、随每次重生成存续，是该处置唯一可存续的实现形态，不是走样。文本面：头注含判断锚短语「覆盖范围为 yun-sync 席位仓」「goal 型仓为轻量装、无版本面、不在口径内」（以「无 version.txt 版本面」「不在扫描口径内」形态出现）全数对应，另加尾句「其缺席不构成版本缺失」属精度补强、不改口径。AC3（脚本在册＋位置序）／AC4（重生成后台账在册）双面判据成立。

## 版本提议评估：成立

- patch 级定性正确：本批全为增补/修正（新节、新投影、新断言、计数修正、已 PASS 内容的提交），无删除、无既有契约破坏、无行为不兼容，合 patch 定义；不升 minor/major 与票面红线一致。
- 改面封顶两处有据：`.tad/version.txt` 为版本单源；仓根 `AGENTS.md` 代际标记是既存复述面且是 GM 台账机械核查面（输入 3 的教训正是版本面与根文件代际分叉），不同步即在本仓自造同型分叉——盘上实测 AGENTS.md 中 `v3.0.0` 恰 1 处（L9 标记行），AC15 判据可实跑。
- 其余复述面（`.tad/config.yaml` L3、`tad.sh` L26、`.tad/TAD-VERSION`，§2.2 盘点属实，本审逐件实测在册）经 CF-3 交 release-verify 门判读＋停步报 PM，设计不自拟口径、不自扩写集，处置正确。其中 tad.sh 字面量经其自身注释与 `derive_target_version`（自 version.txt 派生覆盖）实测证为非权威面（仅 pre-fetch 横幅/兜底），不随 bump 同步不构成安装面分叉。
- 批名「v3.0.1 本体收口批」转正与票标题候选名一致。版本最终裁定权在 PM（票面口径），本审意见为提议成立、可采。

## CF-1…CF-5 处置方向逐项

| # | 设计处置 | 本审 |
|---|----------|------|
| CF-1 台账禁止手改 × 件 2 加头注 | 走生成脚本＋重生成 | ✅ 可接受（见台账专节；publish-protocol step3e 原文实测支持） |
| CF-2 step3e 文件集断言（release commit 须含 NEXT/ROADMAP 头部回填）× 保留集 | 断言执行者＝发版执行者（PM 收口），非 Blake 实施面；Blake 不碰 NEXT.md/ROADMAP.md | ✅ 可接受。盘上实测 step3e 第 1 步原文与设计转述一致（「断言执行者 = 发版执行者本人」「核对三文件齐备」）；与票面保留集口径无冲突 |
| CF-3 版本复述面宽度无口径 | 以 release-verify version 门为判据，写集外 live stale 停步报 PM，改面封顶 §4.10 两处 | ✅ 可接受。不自拟口径、不自扩写集，是收口批的正确姿态；Phase 0 detect-only 枚举＋停步规则已写进实施步 |
| CF-4 件 4b 超票面字面写集 | 设计建议纳入、上报裁定 | ✅ **裁定纳入**（见专节），绑定条件 C1 |
| CF-5 gate SKILL 提交连带 D 线改动、canonical 提交去向 | gate 属甲层写集、连带不可避免且 D 线已全链 PASS；canonical/alex 去向留 PM 收口裁定 | ✅ 可接受。AC14/AC16 以行集增量口径判读，已防把 D 线在册内容误归本批或误回退；提交去向属 PM 收口面，不阻塞实施 |

## P2 注记（不作条件，留合并裁定知悉）

- P2-1：版本标记行同步（§4.10 第 2 处）与票面红线「版本口径不许别处复述版本号」存在字面张力——其实质是同步既存复述面、非新增复述。建议 PM 裁定时显式留痕此口径衔接，免 Gate 3/4 判读时再生争议。
- P2-2：设计 §4.3 称头注文字与判断「逐字对齐」，实测为口径锚短语全对应＋两处精度补强（见台账专节），措辞略强。AC4 的机器判据以 printf 全串为准、不受影响；Gate 3 判读 fidelity 时以口径锚为准。
- P2-3：§2.2 基线「工作区 68 行」在评审时点已漂移为 70 行（双审件等新落盘所致）。AC2 以 Phase 0 当值为准、不受影响；提示实施方勿以 68 为期望值。
- P2-4：见条件 C2（§4.2 丙层枚举漏 ROADMAP.md）。

## 评审方法与实测证据（摘要）

- 对象锚复算（字节＋sha256 全等）；票、判断正本、GM 输入正本全文读。
- HANDOFF 全文读；关键落点逐项盘上实测：registry 中 research-methodology 条目（description/path/status）、指针行文本长度与 startswith（python 实测）、AGENTS.md 指针表 25 行第二列长度全量量测、`v3.0.0` 出现面、pack 本体 15 件文件集、CAPABILITY.md frontmatter 与 status 行计数、tad.sh 版本段与根文件段、config.yaml/TAD-VERSION、scan-packs.sh 与 scan-downstream-versions.sh 结构与行号、capability-skill.sh forbidden 清单与 project 墓碑、publish-protocol Guard 2 与 step3e 原文、release-runbook 两锚节行号、evidence-collection.md 两锚行号、gate SKILL L273–295 与 Canonical Gate 3 节、trading-agent AGENTS.md 行数与首 5 行、投影样本 agent-memory 的 diff 形态、工作区 porcelain 行数当值。
- 本路只判 fitness 面；脚本断言的 shell 语义与实现细节归 tech 路，本结论不替代 tech 路与 PM 合并裁定。

- 自报行：正文 13,964 B／sha256 `f606543b03239f58f6af70fdb9a6cb73fc358e7e09f4475884bb8d4ca145b305`（自报行不计入正文，落盘后以 head -c 13964 复算为准）

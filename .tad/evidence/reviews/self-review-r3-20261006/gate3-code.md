# Gate 3 CODE 评审 — TAD 本体自查批 R3（补充件三改法落地）

- 评审面：CODE（独立会话；未参与设计与实施；与 SAFETY 评审互不可见、未沟通）
- 被审对象：HANDOFF-2026-10-06-self-review-r3 正本＋SUPPLEMENT-1＋SUPPLEMENT-2（合并形态）对 COMPLETION-2026-10-06-self-review-r3 与实施提交 `4ad330e1`／`0099fbc0`
- 日期：2026-10-06
- 判据：`.tad/gates/gate-canonical-checklist.md` Gate 3 节（7 项）；规程 `.tad/tasks/gate-execution.md`

## Verdict：CONDITIONAL

实施本体（脚本、台账、fixture、实验）经本席逐项独立复跑与代码审读，**全部与设计合并形态相符**（详见下表，19 行 post-impl AC 全量字面复跑 19/19 达期望）。唯一条件出在**完工载体本身**：COMPLETION 文件在盘上物理截断（见 Finding F-1），其 AC 表缺 AC-X-2 行、写集分开列节与 Knowledge Assessment 节均不在盘上。两行 AC 的实质经本席独立重算成立，但自报载体不完整——按 Canonical 证据纪律（claim 须有在盘载体；§8.6 要求 COMPLETION 附逐行 Verified Output），Gate 3 不得以 PASS 收口。

**关闭条件（一条，定点复核即可，不重跑全审）**：Blake 补落 COMPLETION 尾部缺失内容——(i) AC-X-1 行证据格补全及其「写集分开列」节（含 AC-X-1 方法所要求的开工前 base 哈希）；(ii) AC-X-2 行（含 Verified Output）；(iii) Knowledge Assessment 节三条全文（含观察 1：AC-G3-2 读法依赖的完整文本）。补落时按字节数＋章节在册验盘（本缺陷正是长文件落盘截断类，补落件须自证完整）。补落后由 PM 或 Gate 4 复算时定点核对三处在盘即可关闭本条件。

---

## 激活自报（Alex，Gate 3 CODE 评审会话）

- 角色：Alex（Solution Lead），经 `~/workspace/skills/tad-alex/SKILL.md` 激活壳进入目标仓 `$REPO = /home/hatch/workspace/yun-sync/TAD`。
- 实际读过的原件：仓根 `AGENTS.md`（全文）；`.tad/project-knowledge/principles.md`（全文）；`.tad/project-knowledge/patterns/_index.md`（全文）；`.tad/brain-index.md`（头部路由＋Principles/Patterns 索引段）。
- patterns 选中 3 条全文：`ac-verification.md`（dry-run 纪律、空集空转、章节边界、逐项断言）、`gate-design.md`（Gate 责任、验证完整性、claims-need-carriers）、`shell-portability.md`（grep/awk/comm 的 CJK 与 locale 陷阱、字面命令按原文执行）。
- 规程原件：`.tad/tasks/gate-execution.md`（全文，含 Regression Replay 触发类）；判据原件：`.tad/gates/gate-canonical-checklist.md` Gate 1–4 节。
- brain-index 路由命中：principles/patterns 索引与本批主题（状态面检查、台账、召回实验）一致；本步判据以仓内 canonical 与 HANDOFF 合并形态为准。
- 冲突记录：任务书与仓内原件无冲突。被审面内部冲突一处——见 Finding F-1（COMPLETION 自述完整 vs 盘面截断），已按盘面为准处理。
- Step 0 断言：`4ad330e1`（[R3-G3]）、`0099fbc0`（[R3-G1]）、`5b572bd7`（票面注记）三提交实存；HANDOFF 正本（82,771 B）＋SUPPLEMENT-1（10,523 B）＋SUPPLEMENT-2（12,355 B）＋COMPLETION（7,605 B）在盘路径与任务书逐字相符。

## ① §9.1 post-impl AC 逐行字面复跑（全量，非抽样）

执行口径：命令在仓根执行；合并形态读法——SUPPLEMENT-1 已改形行按改后形字面执行，保留 `\|` 形态的行按 §9.1 表首注声明读法（还原 `\|`→`|`，此为全表统一声明读法）执行，并对读法敏感行另跑字面形对值。

| AC | 期望 | 本席实测 | 判定 |
|---|---|---|---|
| AC-G1-1 | exit 0 且含 `PASS check8` 行 | exit 0；含 `PASS check8: PAIR-1 governed block carries no stale pattern contradicting the fact source`；另有登记卫生 INFO check8 一行（§4.1.3 设计内行为） | ✅ |
| AC-G1-2 | neg 树 exit 1；FAIL 恰 1 条且为 check8、含字面 `no lifecycle hooks` | 临时副本重跑 runner：exit 1；FAIL 恰 1 条，文案聚合三模式并列 `'no lifecycle hooks'; 'the **hook-enabled** runtime'; 'currently get skills + routing + packs'`（SUPPLEMENT-1 S2 聚合形）；其余行 PASS（check7 为 INFO，按 SUPPLEMENT-2 观察②的 runner 三项断言口径判读） | ✅ |
| AC-G1-3 | pos 树 exit 0；含 PASS check8；零 FAIL | 重跑日志逐行目验：exit 0、PASS check8 在场、FAIL 0 | ✅ |
| AC-G1-4 | exempt 树 exit 0；豁免串在脚本登记处命中 ≥1（带日期注释） | 树 exit 0；`grep -cF 'had "no lifecycle hooks"; superseded by Epic Phase 3'` 于活脚本 = 1（L341 常量，上方注释含登记日期 2026-10-06） | ✅ |
| AC-G1-5 | outside 树 exit 0；含 PASS check8 | runner ASSERT-OK；块外旧文未被扫 | ✅ |
| AC-G1-6 | undecidable 树 exit 1；FAIL check8 含 `fact-source anchor missing` | 重跑日志目验：FAIL check8 文案 `PAIR-1 fact-source anchor missing in AGENTS.md (Known Gaps P2 bullet not found)` | ✅ |
| AC-G1-7（增补二复合形） | 依次 6、1、exit=0 | `grep -c '^PASS check[1-6]'` = 6；`grep -c '^INFO check7:'` = 1；重定向复跑 exit=0；附：全集 `grep -c '^PASS check'` = 7（与增补二 §S1.2 口径一致） | ✅ |
| （增补一 S3）锚缺失必跑 | 临时树 exit 1，文案含 `governed surface anchor missing`，日志留存、临时树删 | 记录日志 `g1-fixture-anchor-missing.log` 在盘且内容相符；本席另在临时副本独立复现：exit 1、同字面 FAIL 行；`g1-fixtures/` 下恰五树（临时树已删） | ✅ |
| fit F-3 | runner 汇总退出码 = 0 | 本席在 /tmp 临时副本重跑 runner：exit 0，`ALL TREES OK (5/5)`；五树日志与在盘记录除汇总行内的树绝对路径外逐行相同（证据可重放） | ✅ |
| AC-G2-1（合并形） | 两 cmp 均无输出 | cmp1（还原读法）exit 0、cmp2（`^[|]` 形）exit 0；两子集各 13 行 | ✅ |
| AC-G2-2 | diff 无输出；清单 28 行 | diff exit 0；28 行 | ✅ |
| AC-G2-3 | drawers 25；routing 计数集合恰 {1} | 25 件；计数集合 = 单一值 1；routing 最长行 148 字节 ≤160 | ✅ |
| AC-G2-4 | run-trace 含 runner 自签＋routing 冻结哈希行且复算一致；build-record 含 builder 自签 | run-trace 自签与冻结行在册；本席 `sha256sum routing.md` = `c755465a…87eb`，与冻结行及「跑后复验仍一致」记录逐字相符；build-record §B.3 builder 自签在册 | ✅ |
| AC-G2-5 | 逐题行 13；三项指标行＋判读行与数值自洽 | 计数 13；指标经本席独立重算（见 ④）：Recall@3 8/8、误报 0、Recall@1 8/8；判读行「建议立项」与 §4.2.4 机械相符 | ✅ |
| AC-G3-1 | 无 MISSING（8 项） | 循环逐项断言无 MISSING 输出 | ✅ |
| AC-G3-2 | 依次 10、9 | 合并形态（表首注还原）读法：10、9 ✔；字面保留 `\|` 读法：32、31（见 Finding F-2 的读法依赖判定） | ✅（附 F-2） |
| AC-G3-3（增补一改形） | exit 1；汇总 `Total: 31 \| PASS: 29 \| WARN: 1 \| BLOCK: 1`；BLOCK/WARN 含 [opencode]/[cursor] 者 0 | exit 1；汇总行逐字相符；BLOCK/WARN 共 4 行全属 [codex]，含 [opencode]/[cursor] 者 0（`grep -E '^(BLOCK\|WARN)'` 改形后复核口径） | ✅ |
| AC-G3-4 | 两控制树退出均 2；首跑 stderr 含 `missing ledger` 且点名 cursor 路径 | missing-cursor exit 2，stderr 含 `missing ledger` 且点名 `…/g3-freshness-controls/missing-cursor/.tad/runtime-compat/cursor.md`；malformed-date exit 2（`invalid last_verified date 'not-a-date'` 格式分支） | ✅ |
| AC-G3-5 | 依次 0、1、1、1 | 实测 0、1、1、1 | ✅ |
| AC-X-1 | 写集恰为 §7 五件 | 见 ②：两实施提交并集逐字等于 §7 五件集 | ✅ |
| AC-X-2 | `cat .tad/version.txt` = `3.2.0` | 实测 `3.2.0` | ✅（自报行缺失见 F-1） |

基线行附验：P-2 本席复算 `git show a1c3dffd^:AGENTS.md | sed -n '9,16p' | sha256sum` = `8370d424…f32`，与设计冻结值逐字相同；fixture 构建日志中旧块哈希同值且标注 MATCH。P-1/P-3/P-5 为 pre-impl 基线记录（post-impl 形态已按设计改变），不在复跑面。

**AC-G3-2 读法依赖注记判定（任务书点名）**：该注记**维持注记级、不升级为增补级处置**。理由三点：(1) 还原读法是 §9.1 表首注对全表声明的统一读法，非本行特设；(2) SUPPLEMENT-1 对同形情形已有先例——AC-G2-1 第一 grep 保留 `\|` 形态、经 dry-run 实证后明示保留，本行与该先例同构；(3) 字面读法产出 32/31，与设计冻结值 10/9 及 AC-G3-3 的 Total 31 增量恒等式（12＋19）均显性冲突，误判路径是「响亮地错」而非静默假绿，不存在 F-T1 类「字面不可满足却看似可满足」的欺骗面。附建议（非条件）：后续批次可顺手将本行命令改写为与 F-T1 已改行一致的自明形态，以求全表读法统一。注记全文（观察 1）随 COMPLETION 尾部缺失，须随关闭条件 (iii) 一并补落。

## ② 写集对账复核

- `4ad330e1` [R3-G3]：M `.tad/hooks/lib/runtime-freshness-verify.sh`、A `.tad/runtime-compat/cursor.md`、A `.tad/runtime-compat/opencode.md`、M `AGENTS.md`（4 件）。
- `0099fbc0` [R3-G1]：M `.tad/hooks/lib/state-surface-check.sh`（1 件）。
- 并集（LC_ALL=C sort）逐字 = §7 五件集，**多/少均无**。§7 零改动断言面（tad.sh、codex.md、claude-code.md、release-verify.sh、publish-protocol、version.txt、R2 基线四件、incidents 语料与两索引面）无一出现在两提交中。
- 链务提交另行归类（非实施写集）：`5b572bd7` 仅 M 票面文件；`9322a807`／`fbac82f0`／`a160e272` 仅 A 开跑/完事卡与 SUPPLEMENT-2 件——均为链过程件，COMPLETION 已如实分开列报口径，本席复核认同该归类；AC-X-1 方法中的 base 哈希本应记 COMPLETION，因 F-1 截断不在盘，列入关闭条件 (i)。

## ③ check8 代码审读（对 §4.1.3＋增补一 S2 逐项）

审读对象：`.tad/hooks/lib/state-surface-check.sh` check8 段（现行 L319–410 区段）与 `0099fbc0` 全 diff。

- **diff 形态**：95 行纯新增、**0 删除**——一处头注释增行＋一处 check8 代码块（check7 后、汇总段前，§4.1.1 插入点相符）；check1–7 代码逐字未动（删除行计数为 0 即机械证据）。freshness 校验器 diff（`4ad330e1`）同为 0 删除，新增恰 §4.3.4 三处：2 行台账变量定义、2 段缺失守卫（stderr＋`GATE: runtime-freshness exit=2`）、2 行无条件 `check_ledger` 调用。
- **抽取**：状态式 awk 自 `/^> \*\*Runtime status/` 锚行起收连续 `>` 行、遇首个非 `>` 行退出——非 `/start/,/end/` 范围式，合 §4.1.3 第 1 项；文件缺失与锚缺失同入 `governed surface anchor missing` FAIL（fail-closed）。
- **事实源**：状态式 awk 限定 `## Known Gaps` 节内（下一 `## ` 标题退出），取行首 `- **P2 ` 前缀且含 `Hook adapters` 的首行；节/行缺失 → `fact-source anchor missing` FAIL（fail-closed）；事实行在场但不含 `(implemented` → PASS＋INFO（§4.1.3 判读表第三行逐字相符）。
- **归一化**：`sed 's/^> \{0,1\}//'`（剥 `>`＋至多一空格）→ `tr '\n' ' '` 连接 → `tr -s ' '` 压空格，与 §4.1.3 第 2 项逐字相符；跨行折行短语（事故原文 `no lifecycle`／`hooks**` 分行）归一化后可命中——neg 树实跑已实证。
- **匹配与遮蔽**：一律 `grep -Fq -e` 固定串（模式含 `**` 元字符，处理正确）；豁免遮蔽以 ENVIRON 传串＋awk `index()` 循环切除全部出现，未用 awk 串相等、未用 `${var//}` glob 替换，合 §4.1.3 第 5 项；豁免串不在块中时仅 INFO（登记卫生），不改判读。
- **聚合（增补一 S2）**：三模式逐一探测后汇入 `c8_hits`，每对至多一次 `fail()`，文案并列全部命中模式与 `PAIR-1`——neg 树实跑文案与此逐字相符（见 ①表 AC-G1-2 行）。
- 观察（非缺陷）：事实源锚在代码中为「`- **P2 ` 前缀＋`Hook adapters` 子串」复合条件，设计文字为行首锚 `- **P2 — Hook adapters`；在受治文件上的判别力等价（undecidable 树已实证缺失检测），记录备查，不构成偏离。

## ④ 实验判分复核（组 2）

对照 `expected-subset-13.md` 与 run-trace 在册的 runner 返回序列逐题重算：Q33–Q40 返回的单候选 stem 与期望 incident 文件 stem **逐题全等**（academic-research-pack-pilot／claude-md-routing-label-conflicts／gemini-cli-constraints／pack-collision-detection／scienceclaw-skill-decoupling／alex-role-decay-direct-execution／cross-agent-parity-check／pack-value-cross-vendor）→ **Recall@3 = 8/8、Recall@1 = 8/8**；Q41–Q45 返回全空 → **误报 = 0**。报告基线列与 §4.2.4 冻结基线自洽（基线命中 Q33@2/Q34@1/Q38@1/Q40@3 → @3 4/8、@1 2/8；基线误报 Q41/Q44/Q45 → 3）。
§4.2.4 判读行机械套用：8/8 ≥ 6/8 ✔ 且 0 ≤ 3 ✔ → **建议立项**，与 experiment-report 判读行逐字对应。
冻结链复核：routing.md 本席复算 sha256 = `c755465a…87eb`，与 run-trace 冻结行、跑后复验行、experiment-report 三处记载全等；两子集 sha256（`5f15be1f…c125419`／`04acb2a7…84368a`）与 build-record Section A 冻结值逐字相符；builder（§B.3）与 runner 读物自签均含禁读声明，盘面无 INVALID 触发迹象（authority-manifest 前后 diff 空，AC-G2-2 已验）。runner 每题只返回 1 个候选——§4.2.3 允许少于 3（空候选口径在册），run-trace 与报告均已明示，判分不受影响（命中均在第 1 位，@3 与 @1 同值系结果而非口径放宽）。

## ⑤ 两台账对 §4.3 行集

- **opencode.md**：10 行逐行核对（surface／volatility／next_review／regression_required／status 五字段与 §4.3.2 行集逐行全等）；runtime_version 全行 `opencode 1.18.33`、last_verified 全行 2026-10-06、owner 全行 `opencode_adapter`；安全面五行的 status 无 `unknown_current_behavior`。
- **cursor.md**：9 行同法逐行全等；runtime_version 全行 `agent 2026.10.01-e373342`、owner 全行 `cursor_adapter`；sandbox_approval_permissions = verified_partial、context_compaction = verified_partial 与行集相符。
- 文件头（Platform／Ledger Version 1／Last Updated／Source 三出处）与 Scope note（未登四面显式声明）合 §4.3.1；Recheck triggers 追加句两份均与 §4.3.3 逐字稿全等（OC 点名 tad-hooks.ts；CU 点名 hooks.json＋两垫片）。

## Findings

- **F-1（CONDITIONAL 唯一条件 · 载体截断）**：COMPLETION 在盘实测 7,605 B，文件终止于 AC-X-1 行中段，尾部字面为 ``git 提交 `4ad330\n...[truncated 8898 chars]``——截断标记被写进了文件本身。缺失内容：AC-X-1 证据格余部与「写集分开列」节（AC-X-1 方法要求记录的 base 哈希在内）、AC-X-2 整行、Knowledge Assessment 节三条（含被 AC-G3-2 行与 KA 表两处指针引用的观察 1）。头部 Layer 1 与 KA 表的「全 19 行／见下方 KA 节」自述与盘面不符（盘上 AC 表完整行 18＋残行 1）。实质影响限于载体：所缺各行本席已独立重算成立（AC-X-1 见 ②、AC-X-2 实测 3.2.0、观察 1 的判定见 ①表下注记段）。处置见卷首关闭条件。此形态与仓内既有教训同类（长文件落盘须验字节数＋章节在册），建议 PM 在 Gate 4 时将「COMPLETION 落盘后字节数自证」列入收口核对。
- **F-2（advisory）**：AC-G3-2 命令的读法依赖——判定不升级，理由与顺手改形建议见 ①表下注记段。
- **F-3（观察）**：AC-G2-1 行内双读法（第一 grep 还原读、第二 grep 字面读）由 SUPPLEMENT-1 S1.1/S1.4 明示并附 dry-run，执行无误；与 F-2 同属「表内读法不统一」的存量形态，记录备查，不产生动作。
- **F-4（观察）**：Regression Replay 触发面（gate-execution.md）——本批写集未命中其五类（`.agents/skills/**`、`.tad/tasks/**`、`.tad/gates/**`、`.tad/templates/**`、模型/路由口径文件）：AGENTS.md 的 diff 为单一 hunk 且限于 Known Gaps 节（C-12 具名化），未触任何路由/模型口径文本；两支 hook lib 为检查脚本而非被路由的规程原件。故本审不引用复跑 scores.md，记录口径备 PM 查。
- **证据否决核查结论**：除 F-1 的载体缺失外，被审方自报数值与本席重算**逐项全等**（AC 表 18 个完整行的 Verified Output、实验三项指标、台账行数、写集口径、runner 汇总退出码），无自报不实之行；F-1 属「自报所指载体不在盘」而非「数值与重算不符」，故按 CONDITIONAL＋补落载体处置，不触发整批 FAIL。

## Canonical Gate 3 七项对照

| 项 | 结论 |
|---|---|
| Code/deliverable complete | ✅ 实施交付物全在且相符（COMPLETION 报告件本身见 F-1） |
| §9.1 Spec Compliance（逐行验证） | ✅ 19/19 本席复跑达期望（G3-2 附 F-2 advisory） |
| Evidence files exist | ⚠️ §7.1 证据清单全在盘；唯 COMPLETION 尾部缺失（F-1） |
| Evidence replayable（advisory） | ✅ fixture runner 临时副本重跑与记录逐行同（除路径字面） |
| Git commit done | ✅ 实施两提交＋链务提交哈希均在册（base 哈希待 F-1 补落） |
| Knowledge Assessment complete | ⚠️ KA 三条的载体节缺失（F-1 关闭条件 iii） |
| Provenance non-empty（advisory） | ✅ 组 2 builder/runner 自签、组 1 构建日志、组 3 日志链齐备 |

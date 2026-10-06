# CF-3 分诊定性 — 本体收口批 Phase 0 停步（TASK-20261005-TAD-CLOSEOUT-BATCH）

> 性质：Alex 分诊定性件，只分析、不实施。供 PM 裁定「类 B 逐件定性／是否扩写集／或本批不升版」三问。
> 停步原文：COMPLETION-2026-10-05-tad-closeout-batch §2；枚举全文 `.tad/evidence/closeout-batch-20261005/cf3-release-verify-version.txt`（191 stale）。
> 分诊人：Alex（原生 subagent），2026-10-05。仓内只读查证＋/tmp 隔离模拟，未改仓内任何文件。

## 0. 结论先行

**建议采甲案**：扩写集 12 文件 16 行（逐件清单见 §6.1），类 A 168 件以本分诊件为据、按 publish-protocol 的 patch 口径放行；NEXT.md／ROADMAP.md 头部行归 PM 收口面（step3e 既定，不入 Blake 扩面）。乙案（不升版）代价见 §6.2，不建议。

核心理由一句话：框架自带三道判据对「哪些面是活的」口径一致且互证——version-sweep 的 Must-Version Registry（12 条正向断言、**任何版型恒阻塞**）、state-surface check1–3（R1 机制 3）、上一轮 patch 发布提交 c32bde27 的实际改面。三者交集即本批必须随版改的面；191 件中真正的活面只有 21 件（另 2 件已在 §4.10 写集内），其余 168 件是门的**设计内** over-report：release-verify 契约头明言「fail toward FALSE-POSITIVE…Residual over-report is ACCEPTED — the operator eyeballs it」，且 publish-protocol step3c 明定 version 门 exit 1 在 **patch 版型下为 advisory WARN、proceed**。Blake 的停步源于 HANDOFF CF-3 自设的更严口径（停步报 PM），不是协议本身要求停摆；本分诊即完成契约所说的 operator eyeball。

分区计数（与枚举逐行对账，总数 191）：
- §4.10 写集内待改面：2 件（`.tad/version.txt:1`、`AGENTS.md:9`）——注：COMPLETION §2 称「191 件全部在写集外」不精确，此 2 件属设计已点名的 bump 面、Phase 3 未到未改而被门计入。
- 类 B（本件 §2 逐件定性）：21 件。
- 类 A（历史叙述型）：168 件，抽核 10 件全坐实（§3）。

## 1. 判据链（四源互证）

1. **version 门契约**（`.tad/hooks/lib/release-verify.sh` 头注 Version Exclusion Contract）：旧版引用仅在「文件 basename ∈ {README, INSTALLATION_GUIDE, CHANGELOG, NEXT, PROJECT_CONTEXT, HISTORY} 且行形为版本标签表行／CHANGELOG 节标题／历史状态词（PUBLISHED|SYNCED|RELEASED|DONE|retired|archived|deprecated）」时排除；其余一律报告，且明言残余 over-report 被接受、由 operator 分诊。publish-protocol step3c 据此定：exit 1＋patch → WARN 放行；exit 1＋minor/major → 硬拦。本批为 patch。
2. **version-sweep Layer 1 · Must-Version Registry**（release-verify.sh L565–578，共 12 条断言，publish-protocol step3c2 定「ALWAYS blocking regardless of release_type」）：这是框架对「现行版本身份面」的正表，逐条见 §2 表中「registry」标注。Layer 2 仅 advisory。
3. **state-surface check**（`.tad/hooks/lib/state-surface-check.sh`，R1 机制 3；step3e 收口恒阻塞）：check1＝NEXT.md 当前版本行 == version.txt；check2＝ROADMAP.md 头部 `for vX.Y.Z` == version.txt；check3＝AGENTS.md／README.md／INSTALLATION_GUIDE.md／docs/MULTI-PLATFORM.md／PROJECT_CONTEXT.md 五件中一切 `Version…X.Y.Z` 形声明（DECL_PAT）及锚定括注 == version.txt。
4. **发布前例**（git 实证）：patch 发布提交 `c32bde27`（v2.44.6）与 major 发布提交 `20223774`（v3.0.0）的实际改面，见 §4。

## 2. 类 B 逐件定性表

定性三档：**live-须随版改**／**派生-由权威面自动带**／**历史-非 live**。处置分：扩写集（Blake Phase 3 随 bump 改）／收口面（PM 随 release commit 改）／豁免（不改）。

| # | 面（行） | 定性 | 消费证据 | 处置 |
|---|---|---|---|---|
| B1 | `.tad/config.yaml:1` 注释头 `# TAD Configuration v3.0.0` | live-须随版改 | registry 断言 #3 正向要求该行含新版字面量（release-verify.sh:568）；前例 patch 实改 | 扩写集 |
| B2 | `.tad/config.yaml:3` `version: 3.0.0` | live-须随版改 | registry 断言 #2（:567）；**运行时消费**：`.tad/hooks/startup-health.sh:50-54` 提取 `.version` 作 VERSION（yq／grep 双路）；前例 patch 实改 | 扩写集 |
| B3 | `.tad/TAD-VERSION:1`（整文件即 `3.0.0`） | live-须随版改 | 无脚本消费者（git grep 全仓 tracked 仅 v3.0.0 发布计划件引用）；但 3.0.0 发布计划 HANDOFF-2026-09-15 S9 行点名同步集含 TAD-VERSION，且 patch 前例 c32bde27 实改此文件——发布物料身份面，整文件即版本串，留旧值即自相矛盾 | 扩写集（整行） |
| B4 | `tad.sh:26` `TARGET_VERSION="3.0.0"` | live-须随版改（仅门面；运行时为派生） | 运行时语义是派生：L18–26 注释自述字面量仅 banner/fallback、状态闸不得据此；`derive_target_version`（L33–43）与 `probe_remote_version` 均以 version.txt／远端值覆盖。但 registry 断言 #9（:575）正向要求字面量 == 新版，不改则 version-sweep 恒拦。改字面量零行为影响 | 扩写集（一行） |
| B5 | `package.json:3` `"version": "3.0.0"` | live-须随版改 | registry 断言 #10（:576）；npm 包身份面；`bin/tad-install.mjs` 不读自身版本（grep 无读取点），消费方为 npm/npx 分发面；前例 patch 实改 | 扩写集 |
| B6 | `README.md:3` `**Version 3.0.0 — …**` | live-须随版改 | registry 断言 #4（:569）＋check3 DECL 命中；前例 patch 实改 | 扩写集 |
| B7 | `INSTALLATION_GUIDE.md:3` `**Version 3.0.0 — …**` | live-须随版改 | registry 断言 #5（:570）＋check3 DECL 命中；前例 patch 实改 | 扩写集 |
| B8 | `PROJECT_CONTEXT.md:4` `- **Version**: 3.0.0 (…)` | live-须随版改 | registry 断言 #11（:577）＋check3 DECL 命中；前例 patch 实改 | 扩写集 |
| B9 | `PROJECT_CONTEXT.md:6` `- **Framework**: TAD v3.0.0 + …` | live-须随版改 | 机器判据不覆盖（registry/check3 均不命中此行），但 patch 前例 c32bde27 将 L4／L6 **双行齐改**——现行状态陈述行，随版口径 | 扩写集（一行） |
| B10 | `docs/MULTI-PLATFORM.md:3` `**Version**: 3.0.0 (…)` | live-须随版改 | registry 断言 #12（:578）＋check3 DECL 命中；前例 patch 实改（仅此一行，见 B16） | 扩写集 |
| B11 | `.agents/skills/tad-help/SKILL.md:17` `Version: v3.0.0 \| Generated: [timestamp]` | live-须随版改 | registry 断言 #6（:571）正向要求 `Version: v<新版>`；前例 patch 实改同一行。**Blake 疑其为模板示例行——不成立**：`Generated: [timestamp]` 是该 skill 版本行的固有格式，行本身是身份面 | 扩写集 |
| B12 | `.agents/skills/alex/SKILL.md:50` `<!-- TAD v3.0.0 Framework -->` | live-须随版改 | registry 断言 #7（:572）；唯一消费方即门本身（身份标记），无运行时读取点；前例 patch 实改 | 扩写集 |
| B13 | `.agents/skills/blake/SKILL.md:166` `<!-- TAD v3.0.0 Framework -->` | live-须随版改 | registry 断言 #8（:573）；同 B12 | 扩写集 |
| B14 | `README.md:190` `# Should show: 3.0.0` | live-须随版改（前例面） | 无机器判据；patch 前例 c32bde27 实改同一示例行 | 扩写集（一行） |
| B15 | `INSTALLATION_GUIDE.md:55` `cat .tad/version.txt # 应显示 3.0.0` | live-须随版改（前例面） | 无机器判据；patch 前例实改同一示例行 | 扩写集（一行） |
| B16 | `docs/CODEX-USER-GUIDE.md:58` `cat .tad/version.txt # 应显示 3.0.0` | live-须随版改（前例面·弱） | 与 B15 同类示例行；该指南成文于 3.0.0 期、无 patch 前例可援。按三指南示例行同口径处理，避免指南间互相矛盾 | 扩写集（一行）；PM 若裁豁免，本行可单独摘除而不影响任何门 |
| B17 | `NEXT.md:10` `**当前版本**：3.0.0（tag v3.0.0 / commit 20223774）…` | live-须随版改 | check1 断言该行版本 == version.txt（state-surface-check.sh:68–78）；step3e 第 1 步文件集断言：bump 的 release commit 必须同含 NEXT.md 与 ROADMAP.md 头部行回填；CF-2 已定其归 PM 收口面 | **收口面**（PM 随 release commit 回填，不入 Blake 扩面） |
| B18 | `ROADMAP.md:3` `> Strategic direction. Updated 2026-10-04 for v3.0.0.` | live-须随版改 | check2 断言头部 `for vX.Y.Z` == version.txt（:82–91）；step3e 同 B17 | **收口面**（同 B17） |
| B19 | `docs/CODEX-USER-GUIDE.md:3` `**适用版本**: TAD v3.0.0+` | 历史-非 live | 版本**下限**陈述（≥3.0.0），升 3.0.1 后仍为真；registry／check3 均不覆盖 | 豁免 |
| B20 | `docs/MULTI-PLATFORM.md:214` `*TAD v3.0.0 — …single skill tree…*` | 历史-非 live | 版次落款行；check3 DECL_PAT 不命中（无 Version 字样，模拟实证亦未报）；patch 前例仅改 L3、未触此行 | 豁免 |
| B21 | `README.md:506` `**Welcome to TAD v3.0.0 — Claude Code Path Removed, …**` | 历史-非 live | 3.0.0 **版次**欢迎行，副标题陈述的是 3.0.0 的内容；patch 前例对此行的处理是连副标题**整行重写**为新版说明，非机械换号——只换号会把 3.0.0 的事记到 3.0.1 头上。机器判据不覆盖 | 豁免（机械换号禁用）；PM 发版时若要立 3.0.1 欢迎行属编辑新增，收口面自决 |

补充点名（枚举内、未入上表者均归类 A）：`README.md:5`（v3.0.0 发版说明行，指 CHANGELOG#300——已发布版本的说明，属历史；前例的「重写」是为新版另写说明行，非改旧行）、`README.md:172`、`INSTALLATION_GUIDE.md:22/25/86/90/104`、各 docs 中「自 v3.0.0 起／removed in v3.0.0」类行为变更史述，全部历史-非 live。

## 3. 类 A 抽核（随机抽 10 件，逐件在盘核对）

| # | 抽中件 | 原文形态 | 核对结论 |
|---|---|---|---|
| A1 | `.tad/capability-packs/agent-memory/install.sh:51` | 错误消息「--agent was removed in TAD v3.0.0」 | 历史事件陈述（运行时错误文本记移除版本），改写即篡改史实 ✓ |
| A2 | `.tad/agents/agent-a-architect.md:3` | `# ARCHIVED (v3.0.0): …No live consumer` | 自述归档、无消费者 ✓ |
| A3 | `.tad/tests/state-surface-fixture/.tad/version.txt:1` | 夹具自有 SSOT `3.0.0` | FIXTURE.md:9/24–26 明定正负控以**夹具自身** version.txt 为准——与仓版本无关的钉版测试数据，改之即毁夹具语义 ✓ |
| A4 | `.tad/hooks/lib/release-verify.sh:101` | 门自身注释「Dual-tree mirror modes — REMOVED in v3.0.0」 | 变更史注释 ✓ |
| A5 | `README.md:5` | v3.0.0 发版说明 blockquote（指 CHANGELOG#300---2026-09-16） | 已发布版本说明行 ✓（前例 nuance 见 §2 补充点名） |
| A6 | `docs/MULTI-PLATFORM.md:23` | 表行「Claude Code \| Removed in v3.0.0 (was first-class ≤2.44.6)」 | 平台状态史表 ✓ |
| A7 | `.tad/scripts/capability-skill.sh:339` | tombstone 错误消息「'project' was removed in TAD v3.0.0」 | 移除事件陈述 ✓ |
| A8 | `.tad/tests/installer-data-safety-fixture.sh:937–938` | 注释「Simulate the 2.44.6→3.0.0 upgrade」＋`printf '3.0.0'` 写沙箱源 | 升级模拟的测试数据，注释明言仓 version.txt 另行 bump ✓ |
| A9 | `.tad/config-workflow.yaml:279` | 注释「command 于 v3.0.0 移除…悬空引用」 | 移除史注释 ✓ |
| A10 | `docs/codex-guide.html:174` | 静态 HTML 指南副标题「Codex CLI Edition · v3.0.0」 | **判断点，显式标 PM**：整页为 3.0.0 版次文档（内含「v3.0.0 已移除」专章），无任何机器判据覆盖、patch 前例未触同类。本分诊定性历史-非 live；PM 若认 HTML 指南属现行用户面，可单独点名，不建议纳入本批 |

**抽核结论：10/10 归类无误伤，类 A 中未发现混入的 live 件。** 类 A 的构成与 COMPLETION §2 所述一致：pack install.sh 的 removed 消息与版本注释、ARCHIVED/RETIRED 文件头、tests fixture 钉版值、hooks/scripts 的变更史注释、docs 的升级史节。

## 4. 前例证据（上一轮升版怎么处置这些面）

- **patch 前例 `c32bde27`（release: v2.44.6，2026-09-15）改面 16 文件**：alex/blake/tad-help 三 SKILL 各 1 行（即 B11–B13 同位行）、`.tad/TAD-VERSION` 1 行、`.tad/config.yaml` 2 行（L1 注释＋L3 字段，即 B1/B2）、`.tad/version.txt`、INSTALLATION_GUIDE 2 行（L3＋「应显示」行，即 B7/B15）、PROJECT_CONTEXT 2 行（L4＋L6，即 B8/B9）、README 4 行（L3 标题、发版说明行、「# Should show」行、Welcome 行）、docs/MULTI-PLATFORM 1 行（仅 L3）、package.json、tad.sh（仅 TARGET_VERSION 字面量 1 行）、CHANGELOG 新增当版节；另 `.claude/skills/*` 镜像 3 件（v3.0.0 已删，不适用）。**未触**：NEXT.md、ROADMAP.md（step3e 文件集断言系 R1 于 2026-10-04 新立，前例时点无此规；本批起按 step3e 归收口面）、codex-guide.html 类版次文档。
- **major 前例 `20223774`（release: v3.0.0）**：`-S` 查证 TAD-VERSION、config.yaml `version:`、tad.sh TARGET_VERSION、package.json、alex SKILL 标记均在此提交由 2.44.6 改 3.0.0；其发布计划件（HANDOFF-2026-09-15 S9）原文点名同步集：「`.tad/version.txt` / `TAD-VERSION` / `tad.sh` TARGET_VERSION / `package.json` / must-version registry 同步」。
- **对「每版必改面还是自始未动」的直接回答**：TAD-VERSION 与 config.yaml 在 3.0.0 时点的值就是 3.0.0，且系发布提交当场由 2.44.6 改入——属**每版必改面**，非自始未动的历史值。沿前例成立：本批照 c32bde27 的改面形态执行即可，且 step3e（R1 新规）额外要求 NEXT/ROADMAP 头部行随 release commit 回填。

## 5. 模拟实证（/tmp 隔离，只读仓外验证）

- **模拟 1**（仅改 §4.10 两面：version.txt＝3.0.1＋AGENTS.md L9 标记）：state-surface-check 实跑 → check1 FAIL（NEXT）、check2 FAIL（ROADMAP）、check3 FAIL×4（README／INSTALLATION_GUIDE／MULTI-PLATFORM／PROJECT_CONTEXT 的 DECL 行各一），check4 PASS。（check5 报 session-state 缺失系模拟未拷贝该文件之伪影，真仓在盘。）
- **模拟 2**（模拟 1 ＋ §6.1 扩面全量＋NEXT/ROADMAP 头部回填）：release-verify version-sweep 实跑 **Layer 1 PASS（12/12）**；state-surface check1–4 全 PASS（check5 的 FAIL 均为模拟未拷贝的索引引用路径，真仓在盘、与版本无关）。
- 结论：§6.1 清单是使两道恒阻塞门转绿的**充分集**；registry 与 check3 的必改面已被清单全覆盖，且清单外无其他机器必改面。

## 6. 处置建议

### 6.1 甲案（推荐）：扩写集＋收口面＋类 A 分诊放行

**扩写集（授权 Blake 于 Phase 3 随 bump 一并改，逐件一行级）**：
1. `.tad/config.yaml` L1 注释头＋L3 `version:` → 3.0.1（B1/B2）
2. `.tad/TAD-VERSION` 整行 → 3.0.1（B3）
3. `tad.sh` L26 `TARGET_VERSION` 字面量 → 3.0.1（B4）
4. `package.json` L3 → 3.0.1（B5）
5. `README.md` L3 标题行＋L190「# Should show」行 → 3.0.1（B6/B14）
6. `INSTALLATION_GUIDE.md` L3＋L55「应显示」行 → 3.0.1（B7/B15）
7. `PROJECT_CONTEXT.md` L4＋L6 → 3.0.1（B8/B9）
8. `docs/MULTI-PLATFORM.md` L3 → 3.0.1（B10）
9. `.agents/skills/tad-help/SKILL.md` L17 → v3.0.1（B11）
10. `.agents/skills/alex/SKILL.md` L50 标记 → v3.0.1（B12）
11. `.agents/skills/blake/SKILL.md` L166 标记 → v3.0.1（B13）
12. `docs/CODEX-USER-GUIDE.md` L58「应显示」行 → 3.0.1（B16，可单独摘除）

**收口面（PM 随 release commit，不入 Blake 写集）**：NEXT.md L10 当前版本行回填（B17）、ROADMAP.md L3 头部行回填（B18）——step3e 第 1 步文件集断言的既定动作；CHANGELOG 新增 3.0.1 节（前例形态，编辑面）。

**类 A 放行口径**：Phase 3／发版时 version 门（step3c）必然仍报 168 件类 A——按 publish-protocol 原文「exit 1 AND release_type == patch → advisory WARN, proceed」放行，判读依据＝前例（c32bde27 发布时同类史述满仓、照常发布）＋本分诊件（逐件类目与抽核在册）。HANDOFF CF-3 的停步阀已由本分诊完成其预设的「报 PM」动作，PM 裁定采甲后，Blake 续跑 Phase 1–3 不再因同一枚举二次停步。

**口径留痕建议**：§4.10「新版号字面量出现面封顶两处」的表述与 registry 现实不符（框架自带 12 条身份断言决定了 patch 升版的最小改面是本清单），建议 PM 裁定文一并订正封顶口径为「以 version-sweep registry＋state-surface check＋patch 前例三源交集为改面」，免后续批次重蹈 CF-3 停步。

### 6.2 乙案（不升版）代价

FR9／AC15 作废之外：① 本批含下游可见面变更（AGENTS.md 新节、投影新增、扫描断言），无版号出仓即在下游自造「内容已变、版本没变」的代际分叉——正是 GM 输入 3 的病型、本批立意要关的账；② GM S8-C1 的后续动作（12 仓刷新对齐令）以升版定稿为前提，不升版则该串继续悬置；③ 下游台账 CURRENT 仍 3.0.0，台账行与源面内容脱钩，R1「版本口径归一」成果回退。代价与甲案 16 行一行级改动不成比例，不建议。

### 6.3 对 release-verify 其他子项的影响

- **version-sweep（step3c2，恒阻塞）**：受影响且是本分诊的主约束——扩面后 Layer 1 转绿（模拟 2 实证）；Layer 2 只扫 2.x 漂移、advisory，本批无关。
- **version（step3c）**：扩面后仍报类 A 168 件，patch 口径 WARN 放行（见 6.1）；若未来升 minor/major，此门转硬拦，届时须另行处置类的史述面（扩大排除表或逐件豁免登记）——属未来批次议题，本批不预支。
- **structural（step3b，即旧 parity 面）**：源↔目标字节同一性比对，与版本字面量无关，不受影响；本批新增投影件属其比对面内的新增路径，按同步流程走即可。
- **migration（step3d）**：比对 prev tag↔HEAD 的 D/R 与 manifest 覆盖，与版本字面量无关；且 patch 下 exit 1 亦为 WARN。本批写集为增补/编辑为主，不触发该门的新增义务。
- **installer-destructive-guard**：查 tad.sh 的 rm 站点标记；B4 改的是赋值行，不触 rm 站点，不受影响。
- **state-surface（step3e）**：受影响——check1/2 靠收口面回填、check3 靠扩面第 5–8 项，模拟 2 实证全绿。

---
自报行：正文 18582 B／sha256 `c2b22acb156b11fa65b56028e3e22d93bccb524230f9eeaee71d11fe85259fcc`；分诊人 Alex，2026-10-05；本件落盘后以 `head -c 18582` 复算自验。

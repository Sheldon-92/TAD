# Handoff: TAD Lite v1.1 质量修订 — 首次实战复盘驱动的 12 项修订（v3，两轮审查后）

**Date**: 2026-07-30
**Type**: standard | **task_type**: protocol-contract（修改 lite SKILL 本体 + CLAUDE.md，必须 full 通道）
**From**: Alex | **To**: Blake
**Version**: v3（R1 双专家 10 P0/19 P1 处置 → R2 验证 8 LANDED/2 PARTIAL + 抓 3 新 P0（ND-1/2/3）+ 6 P1 + 8 P2，全部处置，见 §7）
**Evidence base**:
- `.tad/evidence/research/2026-07-30-lite-vs-full-quality-comparison.md`（本仓质量对照研究）
- `全屋智能化/.tad/evidence/research/blake-lite-calendar-write-first-use-retrospective.md`（下游首战复盘）
- `全屋智能化/.tad/evidence/reviews/blake/calendar-write/gate3-fresh-review.md`（首轮 FAIL 原件）

---

## 1. 目标（为什么）

首个真实 LITE 单的质量研究结论：交付质量与 full 等值，但保障结构是"1 层防线 + 专家用户补位"，零冗余；唯一实测泄漏（AC principal 契约缺陷）产自 alex-lite 设计期、穿透 escalated L0.5 自审、存活到最后一道 gate。本单按用户拍板把 lite 升级为**设计侧 1 reviewer（alex-lite L2.5）+ 实现侧 1 reviewer（blake-lite L3）对称双防线**，并内置目标锚/方案速写/状态词/单步验收等流程补位。

### 用户决策记录（verbatim，按时序）
1. 设计端太轻："我发现 [Lite] 就在做方案设计这一个板块，实在是太轻了……甚至他都没有多问一下我的需求和我的目标是什么"
2. 质量研究触发："我们不只是看 token……完成质量我们到底有没有得到保证？你要看这个例子，你要研究"
3. Alex 侧加 reviewer："你理解错了。我的意思说，在 Alex 那个阶段，要不要加一个 reviewer?" → AskUserQuestion 拍板"**每单都审**"（设计侧 1 + 实现侧 1 对称；escalated 的 L0.5 降为机械复查）→ "可以"
4. 自治修复边界：拍板"照抄 6 条件"
5. 附加范围：拍板"Epic-in-lite 轻量锚点 + Express 命名消歧"均含
6. 复盘产出：拍板"Opt-in 一句话"
7. 额度出口："我坚持用 [Lite]，我就用 [Lite]"（API 计费场景）

## 2. 不做什么

- ❌ 不改哨兵块（ESCALATION-LIST-BEGIN/END 之间零字节改动，4 文件保持逐字节相同，AC1 md5 钉死）
- ❌ 不加 SessionStart/常驻加载、不加 hook、不改 settings
- ❌ 不动 full 通道（/alex、/blake、/gate 及其 SKILL）
- ❌ 不做每单强制复盘（仅 opt-in）；不引入新文件类型（Series 行内锚点，无 LITE-EPIC-*.md）
- ❌ README.md（L90-91 lite reviewer 结构描述）、tad-help SKILL（L223 highlights）、CHANGELOG 的版本号/token 数字/协议描述更新 → **归下次 \*publish，已登记 NEXT.md**（Alex 负责登记）。本单只改 §4 清单 6 文件。

## 3. 修订规格（逐条）

### A. alex-lite/SKILL.md

**A1 阀门"额度出口"（⚠️ NOT_via_suggestion 定向 carve-out，触发受限）**
- **触发规则**：首次命中第 1-3 类 → 只输出现有停止话术（"建议走 full TAD：{命中原因}"），**不**输出出口句。仅当用户在被停止后**再次**表达继续意愿或成本顾虑（额度/成本/token/贵/API 计费等）→ 输出：
  "如你因额度/成本仍要走 lite，明确说一声**并说明原因**，我将逐字记录进入 escalated_review 模式继续；第 4 类（fatal）无例外。（NOT_via_suggestion 约束不变：不主动提供、不默认、不选项化，仅告知）"
  ⚠️ ND-1：出口句及其邻域禁用"推荐/建议走 lite/可以考虑"字样（AC9 负向 grep 会被击穿）。
- NOT_via_suggestion 镜像条款原文保留不动（AC9 用 grep -Fxq 锚定字节原文）。
- Forbidden 追加："把额度出口句用于推荐/暗示 escalated（含 AskUserQuestion 选项化、'要不要走 escalated'、'建议你说一声'）/ 在用户未表达继续意愿或成本顾虑时主动抛出该句"。

**A2 L1 目标锚**
标题"L1 理解（最多 1 轮）"→"L1 理解（最多 2 轮）"：第 1 轮必含恰 1 个目标锚问题（为什么现在做 / 成功长什么样），可与复述合并；功能岔路题放第 2 轮（可省）；用户跳过不阻塞，LITE 文件记一行"目标锚：用户跳过"。正文"边界或 AC 不清 → 最多 1 次 AskUserQuestion（≤4 问）"同步改为"每轮 ≤1 次 AskUserQuestion（≤4 问），共 ≤2 轮"（ND-14：头身一致）。

**A3 L2 方案速写前置**
落盘 LITE 文件之前，先输出 3-5 行方案速写（做法/为什么/备选/为什么不选），用户认可后才写文件；用户对速写的修改意见直接吸收进契约。

**A4 新增 L2.5 契约审查（⚠️ MANDATORY，每单；本单核心）**
位置：L2 落盘之后、L3 人拍板之前（新增 `## L2.5 契约审查` 节，物理位于 `## L2` 与 `## L3` 节之间）。行内注明决策来源（不放 Forbidden 块内）："（原 blake-lite L0.5 设计审查，2026-07-30 用户拍板前移至此）"。

1. **spawn（平台中立 + 禁自审兜底）**："spawn 1 个独立上下文 reviewer 审 LITE 契约：Claude Code 用 Agent tool（subagent_type: code-reviewer）；Codex 等其它 stack 用该 stack 的 sub-agent 或独立进程（如 `codex exec`）。当前 stack 无任何独立上下文机制 → 停，报告人；**不得以自审替代**。"
2. **reviewer 工具面**：允许 Read + 只读 Bash 核验（禁止任何写操作）。检查项：
   - **AC 可执行性矩阵**（主项）：逐条 AC——执行 principal/身份真实存在且已授权？命令走生产真实路径？按原文逐字可运行？前置状态可获得？矩阵中**至少 1 条**被声明的 principal 或路径必须实地只读核验；无法核验的逐条标 `UNVERIFIED: {原因}`，不得省略。
   - 范围合理性：文件清单完整可信、总数 ≤5 可信、"不做什么"与目标无矛盾。
   - escalated 单追加：升级清单命中项是否被 AC 覆盖。
   - 输出 P0/P1/P2 + verdict。
3. **落盘（钉死模板与位置）**：Contract Review 段插入在 LITE 文件 `## AC` 节之后、`## 风险与注意` 节之前（不是文件末尾——Completion 追加在末尾，两者不得混序）。L2 内嵌模板在同一位置加占位段（保持模板 2 空格缩进风格）：
   ```
   ## Contract Review ({date})
   Reviewer: {机制，如 Agent tool code-reviewer}
   首轮 verdict: {…}
   最终 verdict: {PASS|CONDITIONAL}
   P0={n}(fixed), P1={n}, P2={n}; 已审 AC 条数: {n}
   关键发现: {reviewer 输出逐字摘录 ≥1 条}
   ```
   （ND-2：首轮/最终 verdict 必须各占独立一行——blake L0.5 按 `最终 verdict:` 行提取判定，首轮行可合法含 FAIL。）
   同时 LITE 模板 `## AC` 节说明追加条目格式约束：**每条以 `- AC{n}:` 开头**（供 L0.5 机械计数：`awk '/^## AC/,/^## Contract Review/' {f} | grep -cE '^- ?AC[0-9]'`，ND-8）。
4. **出口规则**：P0 → Alex 修契约 → 同 reviewer 增量复核（只给 diff）。最终 verdict 仍 FAIL、或 P0 修复会扩大范围/命中升级清单 → 停，报告人（转 full 或重做设计）；**不得把 FAIL 契约交给 Blake**。同一契约 2 轮仍 FAIL → 停："任务可能超出 lite 适用范围"。CONDITIONAL → 可进 L3，但未修 P1 必须写进契约"风险与注意"作"已知取舍"。
5. **L3 变更回流（staleness 防线）**：L3 阶段用户对契约的实质修改（AC 增/删/改、文件清单、目标）→ 必须回 L2.5 增量复核（只给 diff），Contract Review 段 append 一行 `增量复核 ({date}): {verdict}，覆盖 {改动摘要}`，并更新 `已审 AC 条数: {n}`（带冒号的钉死形式，ND-10）；纯 typo/措辞修改豁免，但须注明"L3 后仅措辞修改"。
6. **Forbidden 改造**：删除"调用设计期专家审查 subagent（escalated 的 L0.5 属 blake-lite）"，替换为："除 L2.5 契约 reviewer 外不得 spawn 任何 subagent / 跳过或内化 L2.5（任何理由——'契约很短''我刚写完自己清楚''额度紧张'均不是理由：自审与契约作者同心智模型，2026-07-30 首战 AC principal 缺陷即穿透自审存活至最后一道 gate）/ 以自审替代 L2.5 的 subagent spawn"。
7. **精髓第 3 条**改为："独立审查：L2.5 契约 reviewer 与 blake-lite 的 L3 reviewer 均不可跳过、不可自审替代"。
8. **恢复行改写**（L2.5-aware，防死锁）："压缩后恢复：重读 active/ 中唯一 pending 的 LITE-*.md。文件存在但无 `## Contract Review` 段 → 从 L2.5 续（不重写文件，不触发 L2 的'文件名已存在'分支）；已有该段 → 从 L3 续。不要运行 /alex 或 /blake。"（ND-6：此行不用加粗标记，否则 AC11 的 `从 L2.5 续` grep 失配。）

**A5 Series 轻量锚点**
新增小节：多步任务不写 `.tad/active/epics/`（升级清单第 2 类）。锚点 = LITE 文件 header 追加 `**Series**: {series-slug} step {n}/{m}（其余步：{一句话}）`。Series 为文档性锚点，blake-lite 不消费（显式声明）。用户要求"Epic"→ 解释 lite 用 Series 行；用户仍坚持写正式 Epic → 即命中第 2 类，按升级清单/escalated 规则处理。

**A6 命名消歧（L0-pre）**
新增 `## L0-pre 命名消歧`（置于 L0 之前）：用户用"express/快速通道"等词且语境未明指 lite 时，先确认："你指 TAD Lite（本通道）还是 full TAD 的 *express？"仅在含混时问。同步把 L0 标题的"（第一步，先判断后干活 ⚠️ BLOCKING）"改为"（判断步，先判断后干活 ⚠️ BLOCKING）"避免与 L0-pre 矛盾。

### B. blake-lite/SKILL.md

**B1 L0.5 重构为全量机械复查（配合 A4；含路由与引用点全改）**
1. **L0 step3 路由**：末行"未命中 → 直接进 L1"改为"未命中 → 进 L0.5"（新防线必须覆盖非 escalated 主路径）。
2. **L0.5 标题**："## L0.5 升级审查前置（仅当 escalated_review: yes ⚠️ BLOCKING）"→"## L0.5 契约审查复查（所有 LITE 单 ⚠️ BLOCKING）"。
3. **L0.5 新逻辑**（不再 spawn）：
   - **待验收态优先**：L0 step2 已判定待验收态（active + `## Completion`）的单直接跳 L5，**不执行**本检查（实现与审查均已完成，重跑无意义）——显式写明此优先级。
   - **机械检查（段存在时）**：`最终 verdict:` 按独立行提取判定（如 `grep '^最终 verdict:' | grep -qv FAIL`；⚠️ 禁止整段 grep FAIL——首轮 verdict 行可合法含 FAIL，ND-2）；`Reviewer:` 字段与"关键发现"逐字摘录非空；`P0={n}` 中 n>0 必须带 `(fixed)` 标记（ND-9）；`已审 AC 条数: {n}`（冒号钉死）== 机械计数 `awk '/^## AC/,/^## Contract Review/' {f} | grep -cE '^- ?AC[0-9]'`（ND-8）。任一不满足 → 停："契约未通过 L2.5 审查或已过期，退回 /alex-lite"（fail-closed）。
   - **缺 `## Contract Review` 段（ND-3：统一单分支，无日期判据、无静默出口）**：停："契约缺 Contract Review 段（未经 L2.5 审查或为存量），请人裁定：补 L2.5 审查 / 回 /alex-lite 重出契约。"人若明确坚持照旧放行 → 逐字记录人原话进 Completion 后方可继续；无人裁定不得进 L1。（删除了"存量照旧放行"预设选项——它与 fail-closed 规则在同一触发条件上冲突，且构成内化逃生舱。）
   - escalated 单追加：核对 escalated_review 用户原话存在且含实质理由；原话仅为"好/继续/可以"类无实质内容 → 停，请人补充理由。
4. **引用点同改**：原"（L3 的实现后 reviewer 照常执行；L0.5 + L3 合计 = escalated 的 2 个 reviewer）"替换为"（escalated 的 2-reviewer 结构不变、位置前移：L2.5（alex-lite 契约审查）+ L3（实现后）= 2 名）"；Forbidden 中"escalated_review: yes 却跳过 L0.5 直接进 L1"替换为"跳过 L0.5 契约复查（任何 LITE 单、任何理由）/ escalated_review: yes 却未核对用户原话"。

**B2 六条件自治修复（授权边界收窄至实现代码）**
L3 段追加：reviewer/gate 发现的缺陷若同时满足——①不扩大功能范围 ②不新增权限面 ③不改变用户可见目标 ④有明确生产证据 ⑤修改可回滚 ⑥修复后**已完成** reviewer 增量复核（Completion 附 verdict，完成态而非承诺）——Blake 自行修复 + 重跑受影响 AC，无需回人拍板；Completion 逐条列 6 条命中证据。**B2 仅授权修改实现代码；不授权修改契约的 AC 或目标**（L1 停止规则与 Forbidden"修改 handoff 的目标或 AC"不变）——缺陷根因在契约本身 → 六条件不适用，按 L1 规则停、报告人回 /alex-lite。任一条不满足 → 停，报告人。

**B3 七态状态词**
新增小节：向人报告进度必须使用且仅使用：`DESIGN PASS / BUILD NOT STARTED`、`IMPLEMENTED / MACHINE AC PASS`、`WAITING USER-GATED AC`、`USER AC PASS / GATE NOT RUN`、`GATE FAIL / BLOCK`、`GATE PASS / WAITING HUMAN ACCEPTANCE`、`ACCEPTED / ARCHIVED`（每词独立一行呈现，供逐词核验）。未达最终态前禁止"已完成/完成了"类总结词。

**B4 user-gated AC 单步协议**
L2 段追加：需用户真机/真设备操作的 AC——一次只给用户**一个**动作指令；用户执行后 Blake 自动查证据（日志/工具读回/外部系统直读）判 PASS/FAIL 并给下一步；禁止一次抛整套 AC；用户报"不行/没反应"→ 先定位失败层级再让用户重试。

**B5 非阻塞 finding 强制 follow-up**
L4 Completion 模板追加：每个非阻塞 finding（P2/可观测性缺口）必须生成 follow-up 条目——{现象/证据位置/为什么不阻塞/建议 owner}；禁止静默省略、禁止写成"已修复"。

**B6 opt-in 复盘**
L4 追加：仅当用户点名要复盘 → 产出完整 retrospective（时间线含用户原话、失败-修复循环、AC 矩阵、reviewer 结论、commits、改进建议）到 `.tad/evidence/research/`；默认只写 lite-discoveries 一行。

### C. CLAUDE.md（单处，跨行精确替换）

**C1** 旧文本跨 §2.5 两行（照抄整两行做 Edit）：
old_string（两行）：
```
豁免：§1 handoff 规则、§3 规则 0-5 对 Lite 不适用，代之以内置约束——一页纸契约 +
实现后强制 1 个 fresh reviewer（禁自审替代）+ 人两次拍板 + AC 可运行 + 验收即归档。
```
new_string（两行，保持断行点）：
```
豁免：§1 handoff 规则、§3 规则 0-5 对 Lite 不适用，代之以内置约束——一页纸契约 +
契约审查与实现后各 1 个 fresh reviewer（均禁自审替代）+ 人两次拍板 + AC 可运行 + 验收即归档。
```

### D. 镜像

**D1** `.agents/skills/{alex-lite,blake-lite}/SKILL.md` 与 `.claude/` 侧逐字节相同（cp 后 cmp）。

### E. project-knowledge 被证伪条目修正

**E1** `.tad/project-knowledge/patterns/gate-design.md` 的 2026-07-30 条目（"Independent Perspective Lives in Clean Context…"）其 Action 含"Cut design-time expert review for small tasks — cheap-rework insurance, not a safety line"，已被本次首战证伪。在该条目末尾 append：
"- **AMENDED 2026-07-30（同日）**: 首个真实 LITE 单证伪'设计期审查仅是 cheap-rework insurance'——契约缺陷（AC principal）产自设计期、穿透实现侧自审、存活至最后一道 gate。修正 Action：lite 每单增加 1 名设计侧契约 reviewer（alex-lite L2.5），与实现侧 L3 对称。证据：HANDOFF-20260730-lite-v11-quality-amendments.md、2026-07-30-lite-vs-full-quality-comparison.md。"
（该条目非 SAFETY 标注，可在本 full 单内修正；不得触碰同文件其它条目。⚠️ ND-17：上文引句是转述、非逐字——Blake 只做 append，禁止对引句做 match/replace。目标条目后面还有 2026-07-05 的 YOLO Worktree 条目，append 位置必须在目标条目区间内，见 AC16。）

## 4. 文件清单

1. `.claude/skills/alex-lite/SKILL.md` — 修改（A1-A6）
2. `.claude/skills/blake-lite/SKILL.md` — 修改（B1-B6）
3. `CLAUDE.md` — 修改（C1 单处）
4. `.agents/skills/alex-lite/SKILL.md` — 覆盖同步
5. `.agents/skills/blake-lite/SKILL.md` — 覆盖同步
6. `.tad/project-knowledge/patterns/gate-design.md` — 条目内 append（E1）

行数预算（防膨胀）：alex-lite ≤150 行（现 81），blake-lite ≤170 行（现 115）。超预算 = 设计漏判信号，停报告。

## 5. AC（macOS：md5；Linux：md5sum。grep 均为烟雾报警，语义判定以 Gate 3 reviewer 通读为准）

- **AC1 哨兵零漂移 ⭐**：对 4 个 SKILL 文件各跑 `sed -n '/ESCALATION-LIST-BEGIN/,/ESCALATION-LIST-END/p' {f} | md5` → 4 个 hash 均 = `dfce636b4b0fde62d3d3a446e384067e`（改前基线，等于 `git show 065c19a:.claude/skills/alex-lite/SKILL.md | sed -n …| md5`；钉 SHA 防中途 commit 移动基线）。
- **AC2 L2.5 存在、位序、内容**：`[ $(grep -n '^## L2 ' .claude/skills/alex-lite/SKILL.md | cut -d: -f1) -lt $(grep -n '^## L2.5' .claude/skills/alex-lite/SKILL.md | cut -d: -f1) ] && [ $(grep -n '^## L2.5' .claude/skills/alex-lite/SKILL.md | cut -d: -f1) -lt $(grep -n '^## L3' .claude/skills/alex-lite/SKILL.md | cut -d: -f1) ] && echo OK` → OK（L2 < L2.5 < L3 双向位序，ND-15）；`awk '/^## L2.5/,/^## L3/' .claude/skills/alex-lite/SKILL.md` 区间内：`grep -c 'spawn'` ≥1、`grep -c 'UNVERIFIED'` ≥1、`grep -c '增量复核'` ≥1、`grep -c '2026-07-30 用户拍板'` ≥1、`grep -c '不得把 FAIL'` ≥1。
- **AC3 Forbidden 反转（区间限定）**：`awk '/^## Forbidden/,0' .claude/skills/alex-lite/SKILL.md` 区间内：`grep -c '调用设计期专家审查 subagent'` = 0、`grep -c '除 L2.5 契约 reviewer 外'` ≥1、`grep -c '选项化'` ≥1。
- **AC4 Contract Review 双位置 + 模板钉死**：`awk '/^## L2 /,/^## L2.5/' .claude/skills/alex-lite/SKILL.md | grep -c 'Contract Review'` ≥1（模板占位）；`awk '/^## L2.5/,/^## L3/' … | grep -c 'Contract Review'` ≥1；`grep -c '已审 AC 条数' .claude/skills/alex-lite/SKILL.md` ≥1 且 `grep -c '已审 AC 条数' .claude/skills/blake-lite/SKILL.md` ≥1；`grep -c '首轮 verdict' .claude/skills/alex-lite/SKILL.md` ≥1。
- **AC5 六条件逐词**：`for t in 不扩大功能范围 不新增权限面 不改变用户可见目标 生产证据 可回滚 增量复核; do grep -q "$t" .claude/skills/blake-lite/SKILL.md || echo "MISSING: $t"; done` → 无输出；且 `grep -c '不授权修改契约' .claude/skills/blake-lite/SKILL.md` ≥1。
- **AC6 七态逐词**：`for t in 'DESIGN PASS' 'MACHINE AC PASS' 'WAITING USER-GATED AC' 'GATE NOT RUN' 'GATE FAIL' 'WAITING HUMAN ACCEPTANCE' 'ACCEPTED / ARCHIVED'; do grep -q "$t" .claude/skills/blake-lite/SKILL.md || echo "MISSING: $t"; done` → 无输出。
- **AC7 blake 路由全改**：`grep -c '直接进 L1' .claude/skills/blake-lite/SKILL.md` = 0（**全文件**，覆盖 L0 路由与 Forbidden 两处，ND-7；替换文本均不含该词，安全）；`grep -c '跳过 L0.5 契约复查' .claude/skills/blake-lite/SKILL.md` ≥1；`grep -c '仅当 escalated_review: yes' …` = 0；`grep -c 'L0.5 + L3 合计' …` = 0；`grep -c '所有 LITE 单' …` ≥1。
- **AC8 blake L0.5 机械化**：`awk '/^## L0.5/,/^## L1 /' .claude/skills/blake-lite/SKILL.md` 区间内：`grep -c 'spawn'` = 0、`grep -c 'Contract Review'` ≥1、`grep -c '请人裁定'` ≥1、`grep -c '待验收态'` ≥1、`grep -c '实质理由'` ≥1、`grep -c '最终 verdict'` ≥1、`grep -c '(fixed)'` ≥1（ND-9）、`grep -c '逐字记录'` ≥1（ND-3 人工放行留痕）。
- **AC9 A1 三件套**：`grep -c '成本顾虑' .claude/skills/alex-lite/SKILL.md` ≥1；`grep -c '并说明原因' …` ≥1；`grep -Fxq -- '- alex-lite 禁止主动提供、建议或默认此选项（NOT_via_suggestion 镜像）' .claude/skills/alex-lite/SKILL.md`（字节原文存活；`--` 防杠开头模式被吞，ND-5）；`awk '/ESCALATION-LIST-END/,/^## L1/' .claude/skills/alex-lite/SKILL.md | grep -cE '建议走 lite|可以考虑|推荐走 lite'` = 0（`-E` 保证 BSD/GNU 一致，ND-4；模式收窄避开出口句合法的"不推荐"字样——但 A1 已改用"不主动提供"，双保险，ND-1）。
- **AC10 A2/A3/A5/A6 逐项**：alex-lite 中 `grep -c '目标锚'` ≥1、`grep -c '最多 2 轮'` ≥1、`grep -c '最多 1 轮'` = 0、`grep -c '每轮 ≤1 次'` ≥1（ND-14）、`grep -c '速写'` ≥1、`grep -c 'Series'` ≥1、`grep -c '不消费'` ≥1、`grep -c '\*express'` ≥1、`grep -c '^## L0-pre'` = 1、`grep -c '第一步，先判断后干活'` = 0（ND-13：L0 标题已改"判断步"）。
- **AC11 精髓 + 恢复行**：`awk '/^## 精髓/,/^## Forbidden/' .claude/skills/alex-lite/SKILL.md | grep -c 'L2.5'` ≥1；`grep -c '从 L2.5 续' .claude/skills/alex-lite/SKILL.md` ≥1。
- **AC12 C1 精确替换**：`grep -c '契约审查与实现后各 1 个 fresh reviewer' CLAUDE.md` = 1；`grep -c '实现后强制 1 个 fresh reviewer' CLAUDE.md` = 0；`git diff 065c19a --stat -- CLAUDE.md` 仅 1 文件，insertions+deletions ≤ 4。
- **AC13 镜像**：`cmp .claude/skills/alex-lite/SKILL.md .agents/skills/alex-lite/SKILL.md && cmp .claude/skills/blake-lite/SKILL.md .agents/skills/blake-lite/SKILL.md` → exit 0。
- **AC14 行数**：`wc -l` alex-lite ≤150、blake-lite ≤170。
- **AC15 B4/B5/B6**：`grep -c '一次只给用户' .claude/skills/blake-lite/SKILL.md` ≥1；`awk '/^## L4/,/^## L5/' … | grep -c 'follow-up'` ≥1 且同区间 `grep -c '现象'` ≥1 且 `grep -c '点名'` ≥1。
- **AC16 E1**：`awk '/^### Independent Perspective/,/^### YOLO Worktree/' .tad/project-knowledge/patterns/gate-design.md | grep -c 'AMENDED 2026-07-30'` ≥1（ND-11：限定在目标条目区间内，EOF 误 append 到别的条目不算过）；`git diff 065c19a -- .tad/project-knowledge/patterns/gate-design.md` 只含 append 行。
- **AC17 ⭐ 行为 dogfood（Gate 4 user-gated，验收时执行）**：用户新开会话跑 `/alex-lite`，玩具任务钉死为"新建 `.tad/evidence/tmp-dogfood.md` 并写一行说明"（不命中升级清单）。核验顺序性：①L1 出现目标锚问题 ②落盘前出现方案速写 ③落盘后真实 spawn 契约 reviewer（可见 Agent 调用）④LITE 文件含 Contract Review 段（Reviewer 字段 + 逐字摘录 + `已审 AC 条数:` 齐全、首轮/最终 verdict 各占一行）。⑤**先归档/rm 步①-④ 的 dogfood LITE 文件**（ND-12：避免 blake L0 step1 的"多候选停"抢跑），再造一个**无** Contract Review 段的临时 LITE 文件，调 `/blake-lite` 并显式指定该文件路径 → 必须硬停（输出含"Contract Review"/请人裁定，且不进入实现）。⑥清理：rm 临时 LITE 文件与 tmp-dogfood.md。任一步缺失/顺序颠倒/负控未停 → FAIL（证伪条件：L2.5 被内化为自审 = 本单白做）。

## 6. 风险与注意

- **哨兵块最高危红线**：AC1 的 md5 钉死基线 `dfce636b…` + SHA `065c19a`；任何"顺手排版"= 违规。
- **A1 张力**：出口句只许在用户二次表达后输出；句内/邻域出现"建议走 lite/推荐走 lite/可以考虑"= P0（AC9 负向 grep 限定在 ESCALATION-LIST-END→L1 区间，避免误伤 L0 的"建议走 full TAD"；出口句自身的约束引用必须用"不主动提供"而非"不推荐"，ND-1）。
- **A4 Forbidden 反转**依据用户拍板（§1 #3）；决策 citation 放 L2.5 行内、不放 Forbidden 块（保持 Forbidden 区间对旧禁令 0 计数干净，citation 在 L2.5 行内同样满足约束存活要求）。
- **存量事实**：全屋智能化的 `LITE-20260730-1137-calendar-write.md` 仍在 active/（待验收态、无 Contract Review 段）——靠 B1 的"待验收态优先"分支正确放行至 L5；这是该优先级必须显式写明的原因。
- **成本模型（诚实版）**：+L2.5 spawn (~8K) + 可能的增量复核 (~1.6K) + 目标锚/速写 (~2-3K) + SKILL 体积增长 (~2K/激活) ≈ **~35K/单**（非 30K）；B4 单步协议的对话轮次放大未估算。escalated 单净 spawn 数不变（移除 L0.5 spawn、新增 L2.5）。*publish 前以一次实测 dogfood 定数，文档不写未实测数字。
- grep 类 AC 均为烟雾报警；语义判定以 Gate 3 reviewer 通读为准。

## 7. Expert Review Audit Trail（R1，2026-07-30）

Code-reviewer：CONDITIONAL（5 P0 / 9 P1 / 9 P2）；Architect：CONDITIONAL（5 P0 / 10 P1 / 6 P2）。处置：

| # | Finding（摘要） | 处置 |
|---|---|---|
| CR-P0-1/2 + AR-P1-7 | AC5/AC6 grep -c 数行不数词，假 FAIL/假 PASS 双向失效 | ✅ v2 改为逐词 for-loop（AC5/AC6） |
| CR-P0-3 = AR-P0-2 | B1 全量化但 L0"未命中→直接进 L1"路由未改，主路径绕过新防线且 AC 全绿 | ✅ B1.1 路由改"进 L0.5"+ 标题/引用点/Forbidden 四处同改 + AC7 |
| CR-P0-4 = AR-P2-2 | Contract Review 位置三种说法自相矛盾 | ✅ 钉死：## AC 之后、## 风险与注意 之前；模板占位同位（A4.3、AC4） |
| CR-P0-5 | C1 旧文本跨 CLAUDE.md 两行，照抄 Edit 必失配 | ✅ v2 给出精确两行 old/new（C1、AC12） |
| AR-P0-1 | L3 用户改契约 → L2.5 审查悄悄过期，无检测 | ✅ A4.5 变更回流 + "已审 AC 条数"载体 + B1.3 条数比对 |
| AR-P0-3 | 恢复路径死锁（重跑 alex-lite 撞"文件已存在"停止分支） | ✅ A4.8 恢复行改写为 L2.5-aware + AC11 |
| AR-P0-4 = CR-P1-8 | verdict FAIL 无出口；写首轮还是终轮 verdict 未定 → 死锁或洗白 | ✅ A4.3 模板分"首轮/最终"、A4.4 出口规则（FAIL 不交 Blake、2 轮停、CONDITIONAL 落取舍） |
| AR-P0-5 | spawn 措辞与首战被内化自审的措辞相同，B1 分不出真假 | ✅ 三防线：verbatim 摘录+Reviewer 载体（B1.3 查非空）、平台中立 spawn+无机制即停（A4.1）、反合理化锚（A4.6）+ AC17⑤ 负控 |
| CR-P1-6 | AC1 基线随 commit 移动 | ✅ 钉 SHA 065c19a + 字面 hash |
| CR-P1-7 | Forbidden 删除后 alex-lite spawn 面无界 | ✅ "除 L2.5 契约 reviewer 外不得 spawn 任何 subagent" |
| CR-P1-9/10/11/12/13/14 | AC2 合并两插入点/A2 与精髓无 AC/A1 交付物无 AC/AC8 半散文/AC11 stage 敏感/无位序 AC | ✅ 全部落 v2 AC2/AC4/AC9/AC10/AC11/AC12/AC15 |
| AR-P1-1 | B2 与"不改 AC/目标"Forbidden 冲突；⑥ 为承诺不可证伪 | ✅ B2 授权收窄至实现代码 + ⑥ 改完成态 |
| AR-P1-2 | A1 无条件输出=主动提供；原话可为空洞"好"；未禁选项化 | ✅ A1 触发受限（二次表达后）+ 须说明原因 + Forbidden 禁选项化 + B1.3"实质理由"检查 + AC9 -Fxq 锚 |
| AR-P1-3 | L51 括号句、Forbidden L109 引用点漏改 | ✅ B1.4 |
| AR-P1-4 | gate-design.md 昨日条目 Action 被本单证伪却仍生效 | ✅ E1 AMENDED append + AC16 |
| AR-P1-5 | README/tad-help 协议描述变假，§2 豁免范围太窄 | ✅ §2 豁免扩为"协议描述"并登记 NEXT.md |
| AR-P1-6 = CR-P2-22 | AC3 全文 0 计数与 §6 决策 citation 相撞 | ✅ AC3 限定 Forbidden 区间；citation 放 L2.5 行内 |
| AR-P1-8 | L2.5 仅读文件测不出"错误声明的 principal" | ✅ A4.2 允许只读 Bash 实地核验 ≥1 条 + UNVERIFIED 标注 |
| AR-P1-9 | 迁移日期判据 off-by-one；§6"两仓无遗留"事实错误；待验收态优先级隐式 | ✅ B1.3 presence-based + 待验收态优先显式 + §6 事实修正 |
| AR-P1-10 | 三处易被静默丢弃的改动无 AC | ✅ AC2/AC4/AC7 补齐 |
| CR-P2-15/17/18/20/21 + AR-P2-1/3/4/5/6 | 行数 115、≤4 行判读、迁移 AC、dogfood 清理+钉任务、缩进、成本 ~35K、L0-pre、Series 无消费者、md5 可移植性、awk 锚定 | ✅ 全部吸收（§4/§5/§6、A5/A6、AC 用 ^ 锚定） |
| CR-P2-23 | Codex AGENTS.md 无 lite 路由（零 LITE 内容） | 📋 范围外，登记 NEXT.md backlog |

### R2 验证轮（2026-07-30，独立 verifier）

R1 的 10 个 P0 处置核验：8 LANDED、2 PARTIAL（AC 覆盖缺口）；C1 old_string 与 CLAUDE.md 逐字节核对通过；AC1 md5 基线在 4 文件 + SHA 065c19a 复现。新抓 3 P0 + 6 P1 + 8 P2（修复引入缺陷，第三次证实 round-2 模式）：

| # | Finding | 处置 |
|---|---|---|
| ND-1 P0 | AC9 负向 grep 被 A1 出口句自身"不推荐"击穿（实测=1，期望=0） | ✅ 句改"不主动提供" + AC9 模式收窄为'推荐走 lite' |
| ND-2 P0 | 首轮/最终 verdict 同行 → blake 机械检查在正常修复路径上误停 | ✅ 模板拆行 + B1.3 按 `^最终 verdict:` 行提取 |
| ND-3 P0 | 存量迁移"照旧放行"选项与 fail-closed 同触发冲突 = 内化逃生舱，AC17⑤ 不可判 | ✅ 合并为单分支：停+人裁定（补审/重出）；人坚持放行须逐字留痕；AC8 加'逐字记录'载体 |
| ND-4/5 P1 | `\|` BSD 不可移植假 PASS；`-Fxq` 杠开头模式报错 | ✅ AC9 改 `-cE` + `--`（实测复现后修复） |
| ND-6 P1 | A4.8 加粗标记使 AC11 grep 失配 | ✅ 恢复行去加粗 + 显式禁令 |
| ND-7 P1 | Forbidden 第 4 处引用点无 AC 载体 | ✅ AC7 改全文件 0 计数 + '跳过 L0.5 契约复查' ≥1 |
| ND-8 P1 | "实际 AC 条数"无枚举规则且计数区间含 Review 块自身 | ✅ 模板钉 `- AC{n}:` 格式 + awk 区间计数式 |
| ND-9 P1 | B1.3 丢了旧 L0.5 的"有 P0 → 停" | ✅ `P0={n}` n>0 须带 (fixed) + AC8 载体 |
| ND-10~17 P2 | 冒号钉死/AC16 区间/AC17 多候选抢跑/L0 标题 AC/A2 头身矛盾/AC4 半位序/§6 陈旧理由/E1 引句转述 | ✅ 全部吸收（v3 各处标注 ND 编号） |

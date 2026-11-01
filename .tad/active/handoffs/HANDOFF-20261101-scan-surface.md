---
dispatch_id: p4-y4-fix-1
dispatch_history: [p4-y3-1]
# Quality Chain Metadata (Alex 必填 - Phase 4 Hook 将基于此阻塞 Gate 3)
task_type: mixed       # code | yaml | research | e2e | mixed —— workflow/脚本改动（行为面）＋判据规则面落字（patterns/canonical）＋回放与 diff 夹具
e2e_required: no      # yes | no —— 真跑一轮 scan 为 conductor 步（S7/AC16 双支），非 Blake e2e
research_required: no # yes | no
git_tracked_dirs: []  # 本仓文件夹制（禁 git 命令），无 git-tracked 生产目录口径
skip_knowledge_assessment: no
gate4_delta: []
risk_triggers: [platform]   # 改动面含判据规则面（patterns 三件＋gate-canonical Gate 2 节）与 surplus 扫描行为面（platform）；无 security/data/money/ui/domain 面；非高风险清单逐项核对见 Gate 2 节
look_first: ".tad/evidence/yolo/v409-basket/phase4-grounding.md — conductor 输入总账（五源汇总＋已裁决口径），本 handoff 的需求面全部由此与 PLAN Phase 4 节、票面裁定构成；设计期基线实测另落 p4-baseline-scan.txt。本 Phase 改动全在本仓内，不作用于仓外系统、不读写真实用户数据"
real_paths:
  - id: RP1
    path: "Gate 3 run 评审人在一次性副本内重跑回放与 diff 两组夹具的真实路径：replay 脚本对 12 行语料逐行与 expected 对账 12/12、篡改副本（classify 块改一字）以 exit 2 EXTRACT-FAIL 收场、diff 夹具五情形（翻转 2／新增 1／消失 1／不变 1）摘要行逐字合"
    run: "named scenario walk — Gate 3 run reviewer 执行，输出存证据根 p4-gate3-rerun.txt"
  - id: RP2
    path: "Gate 4 验收人只读五处落字本体（ac-verification 两条新条目、handoff-design P-C 子面段、gate-design 新条目、gate-canonical ④）答出两问的真实路径：每处规则的装载面与触发时点各是什么、KC3 的显名处置落在哪两件里"
    run: "named scenario walk — 答案只许来自落字本体，不许靠 COMPLETION 转述"
  - id: RP3
    path: "conductor 真跑一轮 scan 的真实路径（S7）：经 surplus SKILL 边界产新一版 plan＋sidecar，新 plan 的资格翻转告警节对 2026-10-31 sidecar 生成、翻转行可逐行说明"
    run: "named scenario walk — AC16 双支：Workflow 面不可达时以显名 not-run＋夹具全集代偿收场，不冒充已跑"
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-11-01
**Project:** TAD（EPIC-20261031-v409-basket）
**Task ID:** TASK-20261101-P4
**Handoff Version:** 4.0.8
**Epic:** EPIC-20261031-v409-basket.md (Phase 4/5)

---

## 激活自报（Alex · dispatch p4-y3-1）

- 角色：Alex（Solution Lead），由 conductor（Cora）派发执行 step Y3（Phase 4 设计），依 `.agents/skills/alex/references/conductor-dispatch-mode.md` 与 handoff-creation 规程至 step1d 止步：不做专家评审选择、不派 reviewer、不写 Gate 2 结论、不给自己的活写 verdict。Gate 2 双审由 conductor 后续独立派发。
- 已读原件：仓根 `AGENTS.md`、`.tad/project-knowledge/principles.md`、`.tad/project-knowledge/patterns/_index.md`＋命中 pattern 全文/条目段（ac-verification 的 Oracle 与计数相关条目、handoff-design 的 P-C 条目、gate-design 的 verdict/classifier 相关条目、shell-portability 口径）、`.tad/tasks/handoff-creation.md`、`.tad/gates/gate-canonical-checklist.md` Gate 2 节；输入件：`phase4-grounding.md` 全文、PLAN-20261031-basket-epics Phase 4 节、EPIC-20261031-v409-basket 的 Phase Map 与 Phase 4 Run 节、TICKET-20261031-process-suggestions、TICKET-20261031-panorama-dispositions、归档 HANDOFF-20261031-surplus-execute-runtime-compat（§10.3 递延三条与 §11.1 分层裁定）、surplus SKILL 与 scan workflow 本体全文、技术研究席 surplus-proposals 的 §1 三查原文、AC8 七行集两源（fixture-sidecar-replay.json、run-record-replay.md）、GATE3-spec 的 §5 维度边界、Phase 2/3 的 gate-report 与 COMPLETION 中 AC11/AC9/KC3/候选原文、Phase 3 HANDOFF 的形态先例（front matter／§9.1 形态 A／Gate Rounds 骨架）。
- Gate 1：Epic Phase Map 的 Phase 4 行（扫描面，两源行）＋ BASKET 第 5 行（扫描面条目，✅ 可开）＋票面裁定（process-suggestions 裁定 1，含其回放验法原文）＋修复链 §10.3 递延登记，即本 Phase 的 Requirement 面；can design from it。本 Phase 须由设计自判并显名者五处：①三查的层归属（reader 报告 vs Rank 门控）→ D1；②人供前置与批准面的定义边界（GATE3-spec §5 教训）→ D3；③diff 的落点（workflow 无 FS，按已证 pattern 不得走 args 注入）→ D5；④回放的 oracle 形态（逐字抽取＋哈希对账，不得维护平行副本）→ D6；⑤B 面是否拆 Phase → D10 显名不拆、报 conductor。
- 基线先验（前三 Phase 共同教训：判据命令不经干跑等于没验）：设计期实测落盘 `.tad/evidence/yolo/v409-basket/p4-baseline-scan.txt`——workflow 448 行／sha256 `3c49b248…`、四新词计数全 0、diff/replay 两脚本不存在、node v24.22.1 可用、parse oracle（剥 `export` 后包 async 解析）在未改文件上实测 parse-ok exit 0、auto_eligible 基线计数 8、2026-10-31 真 plan sidecar 46 行计数（stale 2／auto 16／needs-human 17／generated 4）。§9.1 的 Verified Output 列引此件为据；§9.1 每行方法已在设计期逐行核方言（不用 `\|` 交替陷阱、计数面逐行写明），fixture 类 AC 的预期输出形由 §4 组件规格先行钉死、Expected 逐字引规格——方向与 Phase 3 AC9 的教训相反：先钉规格形、再引为判据，不许判据预设工具未定的输出形。
- 本 handoff 首行 `---`、`dispatch_id: p4-y3-1` 在 front matter 块内（第 2 行）、§9.1 表头为形态 A——按 canonical Gate 2 的 handoff-header-form 现行三点先行自守；B 面 B5 落地后该条目为四点，本 handoff 的 §9.1 逐行 Expected Evidence 非空亦按拟议 ④ 先行自守，Gate 2 评审仍须机械核验并留痕。
- 本仓纪律：文件夹内禁跑任何 git 命令（仓根 AGENTS.md 头部）；验收一律以 grep/sha256/脚本实跑为面，不用 git diff。推送由 conductor 收口步执行，不在本 handoff 写集内。

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**Status**: ⏳ Pending conductor-dispatched dual review (spec + code) — 本节由评审人填写，设计人不自判。

### 高风险触发核对（设计人先行声明，评审人复核）

本 Phase 非高风险候选——逐项核对 canonical 高风险清单：无 L3 动作（删除／密钥／公网暴露／花钱／生产数据改动）；无跨仓写入（写集全在本仓）；无新连接器／新外部依赖（仅用仓内既有 node 运行时）；改动可逆（workflow 改前留 `.orig` 快照，规则面落字可逐行回退）；不作用于仓外系统、不读写真实用户数据。`risk_triggers: [platform]` 仅因判据规则面与扫描行为面属框架面。

### Canonical Gate 2 其余检查点（评审人逐项核）

- 目标与 Requirement 面的对应（§1.5／§3 与票面、PLAN、修复链 §10.3 的逐件映射，见 §3 表）。
- §9.1 每行为合法方法文法（command｜path-check｜fixture），计数类 AC 的计数面在方法文中钉死；Expected 的字面串全部能在 §4 规格或基线件中找到出处。
- Fan-out 声明：本 Phase 无 ≥3 同构执行单元的 fan-out 形态（回放语料 12 行是单一回放脚本的夹具集，非并行执行单元）；pilot＋证伪出口记 n/a，理由在此行。
- 装载点声明：§4.8 逐项列明每处落地的装载面与触发时点，评审人逐项核。
- 代码量界：本 handoff 围栏块共 1 块 4 行（§4.2 的 classify-block 标记示意），单块 ≤15 行、全文件 ≤80 行（设计人定稿实测；模板的 Intent/Offload 两幅 ASCII 图不设围栏，不入此账）。

---

# 1. Task Overview

## 1.1 🎯 Intent (Why)

surplus 扫描器曾把三类不该自动执行的候选放进 auto-eligible：卡在只有用户能给的前置上的、立论所据状态早已变化的、引用文件已经缺位的（技术研究席实证三例）。执行侧已有硬闸兜底（修复链分支 0，2026-10-31 落地），但闸在执行面才发现＝每轮扫描都在产出注定被拦的计划。**本 Phase 把核查前移到产出计划的那一刻**：扫描侧三查（人供前置／来源活状态／引用件在盘）成为候选进入 auto 的必经门，上一轮与本轮的资格翻转要显名告警，好坏要用一组钉死的回放语料随时可验——同一 Phase 顺带把前两个 Phase 暴露的判据形态病（Expected 预设了工具不产生的输出形、计数面不钉死）写成规则，免得下一份 handoff 再犯。

## 1.2 🔍 Three-Layer Positioning

- **L1 产品目标**: TAD 的 surplus 自我改进循环可信地产出计划：auto-eligible 的每一行都已经过三查，needs-human 的每一行都说得清卡在哪。
- **L2 功能规格**: 扫描 workflow 三组新字段＋Rank 确定性门控；workflow 外的 diff 告警脚本；回放脚本＋12 行语料（10 例问题形态＋2 行正控）；surplus SKILL 的 diff 装载步；判据规则面五处落字。
- **L3 实现约束**: workflow 运行时无文件系统、args 不可靠注入（仓内已证 pattern）——diff 与回放都必须落在 workflow 外的 plain-node 脚本；Rank 分类逻辑以「逐字抽取＋哈希对账」供回放消费，不许维护平行副本；已判历史 §9.1 记录一律不回改（K-7 留痕），B 面只改规则面。

## 1.3 🎯 Intent Statement (For Team Alignment)

+---------------------------------------------------------------------------------+
| 🎯 INTENT STATEMENT                                                              |
+---------------------------------------------------------------------------------+
|                                                                                  |
| WHAT (Build):                                                                    |
| 把三查装进 surplus 扫描的产出路径：reader 报告三组新字段，Rank 以确定性门控      |
| 派生 status_unknown 与资格，diff 脚本对上轮 sidecar 逐条比对并告警翻转，        |
| 回放脚本以 12 行钉死语料守住分类行为；同批把判据形态五处教训落成规则面文字。    |
|                                                                                  |
| WHY (Value):                                                                     |
| 扫描面从「产出注定被执行闸拦下的计划」变为「产出即分诊」：坏候选在计划里就      |
| 显名降级、资格翻转显名告警、分类行为有回放守恒；判据形态规则让后续每个          |
| Phase 的 AC 不再重犯输出形与计数面两类病。                                       |
|                                                                                  |
| DONE (Definition):                                                               |
| 回放 12/12 全合 expected（含 2 正控不误杀、篡改块 fail-closed exit 2）；        |
| diff 夹具五情形摘要行逐字合；五处规则面落字 grep 命中；§9.1 全行可验；          |
| 真跑一轮（conductor 步）产新 plan 且 diff 节对上轮生成，或显名 not-run 收场。   |
|                                                                                  |
| SCOPE (Boundaries):                                                              |
| IN:  scan workflow、两支新脚本＋夹具、surplus SKILL 一步、patterns 三件、        |
|      gate-canonical 一点。                                                       |
| OUT: surplus-execute 本体与分支 0（已落地，不动）；.claude/skills 投影刷新       |
|      （installer 面）；已判 Phase 2/3 的 §9.1 历史记录（不回改）；执行侧行为。   |
|                                                                                  |
+---------------------------------------------------------------------------------+

## 1.4 📦 Task Offload Matrix (Context Management)

+----------------------------------+------------+---------------------------+
| Work Item                        | Owner      | Evidence Artifact         |
+----------------------------------+------------+---------------------------+
| 本设计＋Gate 2 输入              | Alex（本件）| 本 handoff＋基线件        |
| 实施 S1–S6                       | Blake      | COMPLETION＋回放/diff 输出 |
| Gate 3 双审（spec＋run）         | 独立评审人 | gate3-report              |
| S7 真跑一轮 scan                 | conductor  | 新 SURPLUS-PLAN＋sidecar  |
| Gate 4 验收                      | 独立 Alex  | gate4-report              |
+----------------------------------+------------+---------------------------+

## 1.5 📋 Business Requirement (from BASKET / PLAN / 票面 / 修复链)

Phase 4 的需求面由五件构成，逐件映射到 §3：

| # | 需求源 | 原文要旨 | 落 §3 |
|---|--------|----------|-------|
| R-a | 修复链 §10.3 递延 ⓐ＋PLAN A-S1 | 状态字段缺失的候选发 `status_unknown` 标记并默认 needs-human | FR1 |
| R-b | 修复链 §10.3 递延 ⓑ＋PLAN A-S2 | SURPLUS-PLAN 再生成对上一版逐条 diff，safety/eligibility 翻转显名告警 | FR4 |
| R-c | 修复链 §10.3 递延 ⓒ＋PLAN A-S3 | 扫描资格判据纳入人供前置信号 | FR2 |
| R-d | process-suggestions 裁定 1（三查） | 人供前置查／来源活状态查／引用件在盘查，任一不过降 needs-human 并显名 | FR1–FR3 |
| R-e | process-suggestions 裁定 1（回放验法原文：「AC8 回放集同源合流……三例样本作 Epic 的回放验法」）＋PLAN A-S4＋proposal §1 验法段 | 三查需回放验，用 AC8 回放集＋三例样本，扩展到扫描侧 | FR5 |
| R-f | Phase 2 gate4（AC11 P2）＋PLAN B1 | Expected 须以工具实际输出形（全路径）为准，判据形态修订 | FR6 |
| R-g | Phase 3 gate4（AC9 P2）＋PLAN B2 | 脚本输出串与 Expected 字面锚定须交付前对账 | FR6 |
| R-h | Phase 2/3 携带候选 ①②＋PLAN B3 | 计数面钉死方法文＋输出词表对账落 ac-verification | FR6 |
| R-i | Phase 2 gate4 携带（P-C 子面）＋PLAN B4 | handoff-design 的 P-C 条目增输出形/定位形子面 | FR7 |
| R-j | Sober ③＋INTAKE-20261101 裁定＋PLAN B5 | AC 表头形态（Expected Evidence）入 Gate 2 机械核面 | FR8 |
| R-k | Phase 3 KC3＋PLAN B6 | log()-only 结论的落机制处置：探针类机制须有第二可观测面 | FR9 |

---

## 📚 Project Knowledge Used

### Principles Applied

- **Disk Is the Spec; Judge From Artifacts**：回放与 diff 的判定对象全部是产物面（sidecar 字段、回放报告、diff 输出节），不读 log()——本 Phase 同时是该原则在扫描面的落地与 KC3 的处置实例。
- **Verify on the Surface the Consumer Reads**：回放验读分类函数的实际行为（逐字抽取自 workflow 本体），不验一份转述副本；B 面 B1 的规则本体即此原则在判据面的表述。
- **Honest Boundary**：真跑一轮若 harness 面不可达，AC16 以显名 not-run 收场，不冒充；扫描侧三查是分诊信号层，执行侧分支 0 仍是硬闸——分层关系写入 §4.1，不许把扫描面说成执行保障。
- **First-Hand Confirmation for High-Risk Claims**：本 Phase 非高风险（Gate 2 节逐项核对）；承重基线（workflow 现状、三例事实、七行集处置）全部在设计期回一手件实测/逐字读。

### Patterns Referenced

- `ac-verification` —「Dry-Run Every AC on the LIVE Host Before Blaming the Implementation」「A Count-Based AC Constrains the Total, Not the Location」、新守卫判据三要件（正控/负控/作用域）：§9.1 的干跑纪律与 B 面两条新条目的同文件先例形态。
- `handoff-design` —「Re-Verify Every Load-Bearing Baseline Premise on Disk at Design Time — Including Whether the Oracle Can Run in This Environment at All」（P-C 条目）：B4 的落点本体；本设计对 node oracle 的设计期实测即按此条执行。
- `gate-design` — closed-world classifier 与 verdict normalization 两节的问题形态：分类输出必须是闭集（§4.2 的 disposition 闭集）、结论须有规范化落点（FR9 的第二可观测面）。
- `knowledge-distillation` — Phase 2 落地的「逐字副本＋哈希对账」纪律：§4.4 回放抽取的保真机制直接承此，不另发明。
- `shell-portability` — §9.1 与脚本命令的方言纪律（计数用 `grep -c`、不用 BRE 交替 `\|`、路径引号）。

---

# 2. Background & Context

## 2.1 📜 Previous Work

- **surplus 修复链（2026-10-31，已关账）**：执行侧 `surplus-execute.workflow.js` 的运行时兼容与分支 0 硬门（prereq/status/approval 三维）落地；其 HANDOFF §10.3 显名递延三条到扫描侧，§11.1 裁定扫描侧三查不得被说成对已落地行为的复核——本 Phase 是那笔递延的正主。
- **Phase 2（蒸馏批次，已收口）**：AC11 判据形态 P2（Expected 写 bare 形、校验器印全相对路径）与 P-C 输出形子面候选产生；「逐字副本＋哈希对账」纪律在该 Phase 落地。
- **Phase 3（pack 分诊，已收口）**：AC9 输出串 P2（判据钉死字面串 `LEDGER-CONSISTENT`/`rows=26`，脚本实跑输出为 `RESULT: PASS`，字面 FAIL、实质经三重对账成立）与 KC3（Gate 4 corroboration 只能沿 log() 做、载体易失）产生；两条知识候选（计数面钉死、输出词表对账）随本 Phase 落字。
- **技术研究席三查提案（process-suggestions 裁定 1，全盘采纳）**：三查定义与三例样本的事实源；三例已在本设计中逐字回源核对（proposal §1）。

## 2.2 🔍 Current State（设计期实测，基线件 p4-baseline-scan.txt）

| 面 | 现状 |
|----|------|
| 扫描 workflow | `.tad/workflows/claude/surplus-scan.workflow.js`，448 行，sha256 `3c49b248c4431cb161927fffbe4810c96d1cc1760000b4205bed441066ce0317`；三 phase（Scan 并行 readers → Generate → Rank 纯 JS）；候选 schema 13 字段，**无状态字段、无人供前置字段、无引用件字段**（`status_unknown`／`human_prereq`／`source_status`／`cited_missing` 四词 grep 计数全 0） |
| 既有近似机制 | isStale 仅对 title/source/summary 的文本 blob 正则（`status:\s*(archived\|completed\|promoted)`）；pathMatchesSafety 只管 target_paths；auto_eligible = safe ∧ value≥3 ∧ source≠generated；`grep -c auto_eligible` = 8 |
| 产物面 | workflow return plan markdown＋JSON sidecar，surplus SKILL 落盘 `.tad/active/SURPLUS-PLAN-<stamp>.{md,json}`；workflow 运行时无文件系统 API；真基线：2026-10-31 版 plan 46 行（stale 2／auto 16／needs-human 17／generated 4） |
| diff / 回放 | `.tad/scripts/surplus-plan-diff.js`、`surplus-scan-replay.js` 均不存在（基线件实测）；仓内 `.tad/scripts/regression-replay.sh` 是 R4 判例回放面，与本 Phase 的扫描回放是两个对象，不许混用 |
| oracle | node v24.22.1 在位；parse oracle（剥首行 `export` 后包 async 解析）在未改 workflow 上实测 parse-ok exit 0 |
| 判据规则面 | ac-verification 无输出形条目（grep 计数 0）；gate-design 无第二可观测面条目（计数 0）；gate-canonical 的 handoff-header-form 现为三点；handoff-design 的 P-C 条目无输出形/定位形子面 |

## 2.3 🔗 Dependencies

- **上游**：Phase 1–3 已收口；本 Phase 消费其携带项（AC11/AC9/KC3/候选 ①②/P-C 子面），销账关系记 §10.3。
- **同批**：Sober ③ 经 INTAKE-20261101 裁定入本 Phase（B5/FR8）。
- **下游**：Phase 5（签认层，条件 Phase）不依赖本 Phase；4.0.9 发版收口时的 agent-computer-interface 观察复核（Phase 3 携带）与本 Phase 的回放面无关，不混账。
- **环境**：真跑一轮（S7）依赖 Claude Code harness 的 Workflow 工具面（surplus SKILL 明言：子代理与无 Workflow 工具的 harness 走不通）——该依赖只挂 AC16 一行，且该行自带 not-run 回退支。

---

# 3. Requirements

## 3.1 ⚙️ Functional Requirements

| ID | Requirement | 承接 | 落点 |
|----|-------------|------|------|
| FR1 | 候选的来源活状态由 reader 显式报告（枚举＋活状态件证据）；缺失或 unknown 时 Rank 派生 `status_unknown`、降 needs-human、auto=false、产物面显名 | R-a/R-d | §4.1/§4.2 |
| FR2 | 人供前置（供给型，定义边界见 D3）由 reader 显式报告（bool＋what）；为真时降 needs-human 并在 Needs You 显名 what | R-c/R-d | §4.1/§4.2 |
| FR3 | 候选立论/交付引用的既有文件由 reader 逐件实存核验；缺位件入 `cited_missing`，非空时降 needs-human 并逐件显名 | R-d | §4.1/§4.2 |
| FR4 | 每轮 plan 再生成对上轮 sidecar 逐条 diff：auto_eligible／risk_tag／status_unknown 三面翻转＋行新增/消失，显名告警节追加进本轮 plan；无上轮基线时显名收场不报错 | R-b | §4.3/§4.5 |
| FR5 | 扫描分类行为有钉死回放：12 行语料（AC8 七行集＋三例＋2 正控）逐行与 expected 对账；分类逻辑逐字抽取＋哈希对账，漂移 fail-closed | R-e | §4.4 |
| FR6 | ac-verification 落两条：输出形对账（设计期字面形＋交付期词表对账两款）、计数面钉死（含结构行同形负控） | R-f/R-g/R-h | §4.6 |
| FR7 | handoff-design 的 P-C 条目增「输出形/定位形」子面段 | R-i | §4.6 |
| FR8 | gate-canonical Gate 2 的 handoff-header-form 增第 ④ 点（机械面：§9.1 各行 Expected Evidence 非空） | R-j | §4.6 |
| FR9 | KC3 显名处置：gate-design 落「第二可观测面」通则条目；本 Phase A 面（sidecar 字段＋回放报告）为其首个实例 | R-k | §4.6/§4.7 |

## 3.2 📊 Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NFR1 | 不回归：workflow 既有产物字段与 plan 表列不删（auto_eligible/totals/Needs You 既有分支保留）；既有 isStale 文本层保留为信号面（sidecar `stale_text_signal`），不删除；其单独决定 disposition 的旧效力按 F1 裁断（D11）显名收回——字段层独占 disposition |
| NFR2 | 确定性：Rank 门控与两支脚本均为纯确定性逻辑（无 agent、无网络、无时钟依赖；diff 的日期只出现在标题引上轮文件名） |
| NFR3 | 写集封闭：改动只落 §7.1 清单；快照 `.orig` 与夹具、证据件按 §7.1 的证据根口径，不算写集外溢 |
| NFR4 | 历史不回改：Phase 2/3 已判 §9.1 与 gate-report 原文一字不动；B 面全部落规则面 |

---

# 4. Technical Design

## 4.0 决策表（每条点名验收方式）

| # | 决策 | 理由（grounded） | 验收方式 |
|---|------|------------------|----------|
| D1 | 三查分两层：reader 层报告事实（source_status／human_prereq／cited 逐件核验），Rank 层以纯 JS 确定性门控派生资格 | reader 有工具面可实存核验与读活状态件；Rank 本就是纯 JS 层（workflow 现行结构）；分类逻辑因此可被回放逐字抽取验 | AC1–AC6 |
| D2 | `status_unknown` 是 Rank 派生量，不是 reader 字段：source_status 缺失或 ='unknown' → status_unknown=true、needs-human、auto=false | 递延 ⓐ 原文是「状态字段缺失的候选」发标记——缺失形态只有消费端能判；reader 字段名用 source_status（与执行侧 sidecar 的 status 面不串名） | AC2 |
| D3 | human_prereq 只认供给型前置（账号/凭据、grant、出网授权、命名、pins、对接人、人域验收）；「未获批/批准出处」类事实不入此面，入 source_status 面（批准面本身是活状态件：与候选前提矛盾或缺位时 source_status='unknown'、证据串点名批准面） | GATE3-spec §5 实证：prereq 与 approval 两维曾同时认领同一句「未获批」文本——定义处不划界，实施必再撞 | AC3/AC4（语料第 4 行专守此界） |
| D4 | cited 引用面与 target_paths 分开：cited_paths 只装立论/交付引用的既有文件，reader 逐件实存核验，缺位入 cited_missing | target_paths 是将触碰/新建面，混装会让「引用缺位」与「待建路径」不可分（三例之三正是引用件缺位） | AC5 |
| D5 | diff 落 workflow 外的 plain-node 脚本＋SKILL 落盘后步：prev 选取在 persist 之前（同日重跑同 stem 时先把旧 json 复制为 prev 再覆写） | workflow 运行时无 FS（SKILL 原文）；diff 输入不得依赖 args 携带上轮 sidecar（仓内已证 pattern：workflow args 在两调用模式均不注入） | AC8/AC9 |
| D6 | 回放以「逐字抽取＋哈希对账」消费 Rank 分类块：分类逻辑收拢为 workflow 内带标记的纯函数块，replay 脚本按标记抽取、与语料所钉哈希对账，不符 exit 2 fail-closed；永不维护平行副本 | Phase 2 已落地同纪律；平行副本必漂移（Phase 1 C3 的 KB 教训同族） | AC6/AC7 |
| D7 | 回放语料 12 行：AC8 七行集逐字映射＋三例按源事实 authored＋2 行正控；第 6 行（七行集）与 gap-queue 例（第 9 行）是有意配对的两层形态（执行侧回放行 vs 扫描侧事件原型），各计一行不算重复 | 七行集源在盘（fixture-sidecar-replay.json＋run-record-replay.md L37–43/L96–102）；正控守「门不误杀」（ac-verification 正控纪律） | AC6 |
| D8 | KC3 落机制（规则＋实例），不只修本 Phase：gate-design 落通则条目，本 Phase 的 sidecar 字段面与回放报告面为首个实例 | KC3 的病在「结论只存 log()」这一形态本身，只修扫描面则下一探针再犯 | AC14＋§4.7 |
| D9 | B 面五处落字全部只改规则面，已判历史件一字不动 | K-7 留痕纪律；AC11/AC9 两案的病在规则缺位，不在历史记录写错 | AC10–AC14 |
| D10 | B 面不拆 Phase（显名报 conductor）：六件均为小规则面落字、共用同一验证文法（grep/path-check/夹具干跑），且 A 面回放直接消费 B3 的负控纪律；拆出会使 B 面与 A 面回放脱钩、判据纪律与它的首个消费方分家 | 拆分判断归设计人显名、conductor 可推翻；若 Gate 2 判应拆，修订轮再议 | 本行即显名件；Gate 2 复核 |
| D11 | F1 裁断（Gate 2 修订轮新增）：disposition 决定权归字段层独占——isStale 文本层降为 `stale_text_signal` 信号，不再单独 drop 任何行；字段缺失/unknown 的行先走 status_unknown 门，不被文本层先行 drop | §4.1 ⓑ 自家规则「叙述与活状态矛盾时以活状态为准」与原 §4.2 第 2 步自相矛盾（领域面 F1 实证：文本层对字段缺失行无额外保护作用，其唯一实际效力是推翻显式 `live`；且先行 drop 缺失行与 R-a/FR1 的默认 needs-human 相撞）；回放语料 12 行的 expected 无一行依赖文本层 drop（三行 drop 全由字段枚举承担），裁断与语料自洽 | AC4/AC6（语料全合即证）＋Gate 3 spec 面核 §4.2 判定序与 sidecar 信号字段 |

## 4.1 A 面 · reader 层（surplus-scan.workflow.js 的 schema 与 Scan/Generate 指令）

`CANDIDATE_SCHEMA` 新增六个属性（与既有 13 字段并列，不改既有字段）：

| 字段 | 形 | 语义 |
|------|----|------|
| `source_status` | enum: `live`｜`landed`｜`archived`｜`completed`｜`promoted`｜`superseded`｜`unknown` | 候选所据来源的活状态类别。reader 必须回活状态件本身核（如队列文件现行计数、台账现行行），不许只引叙述文本 |
| `source_status_evidence` | string | 活状态件的引用（路径＋所核的字段/计数原值）；source_status 非 unknown 时必填 |
| `human_prereq` | boolean | 是否卡在供给型人供前置上（边界见 D3） |
| `human_prereq_what` | string | 前置的具体内容（human_prereq=true 时必填，如「L3 账号＋PM 1:1，只有用户能给」） |
| `cited_paths` | array of string | 候选立论与 deliverable 引用的既有文件路径（不含 target_paths） |
| `cited_missing` | array of string | cited_paths 中 reader 逐件实存核验后缺位的子集 |

Scan 与 Generate 两处 agent 指令各加一段三查指令（同一文本，点名三例的失败形态作反面样本）：ⓐ人供前置查——逐项列出需人类提供的账号/批准面供给/对接，未备者 human_prereq=true 并写明 what；ⓑ来源活状态查——状态断言回活状态件本身核，叙述文本与活状态矛盾时以活状态为准（Rank 侧同口径：§4.2 字段层独占 disposition、isStale 文本层只记 `stale_text_signal` 信号，D11）；ⓒ引用件在盘查——deliverable 与立论引用的每个既有文件路径逐件核实存，缺位入 cited_missing。Generate 阶段合并/改写候选时必须保留来源 reader 的三组字段，不许在合并中丢弃（指令显名）。

**分层声明（写入 workflow 注释与 COMPLETION）**：扫描侧三查是信号＋分诊层——它让计划在产出时就显名降级；执行侧 surplus-execute 分支 0 仍是硬闸，本 Phase 不改、不弱化执行侧任何判定。

## 4.2 A 面 · Rank 层门控（classify-block）

Rank 的分类逻辑收拢为一个带标记的纯函数块，块内零外部依赖（仅用块内常量与入参），供 §4.4 逐字抽取：

```
// === classify-block BEGIN (replay-extractable; keep dependency-free; ANY edit to this block requires re-running .tad/scripts/surplus-scan-replay.mjs to 12/12 PASS before the edit counts as done) ===
... SAFETY_PATTERNS / pathMatchesSafety / isVacuous / isStale / normTitle ...
... DROP_STATUSES / classifyCandidate ...
// === classify-block END ===
```

`classifyCandidate(c)` 返回闭集结果 `{disposition, auto_eligible, status_unknown, reasons}`，disposition ∈ {`ranked`, `dropped-stale`, `dropped-vacuous`, `needs-human`}，判定序钉死：

1. isVacuous → `dropped-vacuous`（既有行为，保留）。
2. `source_status ∈ {landed, archived, completed, promoted, superseded}` → `dropped-stale`（字段层独占 disposition 决定权——Gate 2 修订轮 F1 裁断，D11）。既有 isStale 文本层不再单独决定 disposition：其命中只记入产物面 `stale_text_signal`（见下），与显式 `source_status`（含 `live`）矛盾时以字段为准（§4.1 ⓑ）；字段缺失/unknown 的行一律先走第 3 步的 status_unknown 门，不被文本层先行 drop（守 D2/FR1 的默认 needs-human）。
3. 门控（任一命中即 `needs-human`、auto_eligible=false、risk_tag 派生 needs-human）：source_status 缺失或 ='unknown' → status_unknown=true、reasons 加 `status-unknown`；human_prereq=true → reasons 加 `human-prereq`；cited_missing 非空 → reasons 加 `cited-missing`；既有 safety 命中 → reasons 加 `safety`（既有行为并入闭集）。
4. 余者 `ranked`：auto_eligible 按既有规则（safe ∧ value≥3 ∧ source≠generated）。

产物面扩展：sidecar 行新增 `source_status`、`status_unknown`、`human_prereq`、`cited_missing`、`gate_reasons`、`stale_text_signal` 六字段（`stale_text_signal` 为 isStale 文本层命中信号：命中记 true、否则 false；纯信号面，不入 reasons、不改 disposition）；totals 新增 `status_unknown` 计数；plan 的 Needs You 表「Why not auto」按 reasons 显名（`status unknown`／`human prerequisite: <what>`／`cited artifact missing: <逐件路径>`／既有 safety 与 generated/value 分支保留，优先级从 reasons 首项取）。log() 既有行保留，但按 §4.7 口径它不是证据面。

## 4.3 A 面 · diff 脚本（.tad/scripts/surplus-plan-diff.mjs，新）

- 调用形：`node .tad/scripts/surplus-plan-diff.mjs <prev.json|NONE> <new.json>`；stdout 输出 markdown 节；输入 JSON 损坏或 new 文件缺失 → exit 2 并在 stderr 写明；prev 为字面 `NONE` 或文件缺失 → 无基线节、exit 0。
- 匹配键：标题归一（lowercase、trim、连续空白折叠为单空格）——与 Rank dedup 的 normTitle 同规，规格在此钉死，脚本独立实现。
- 比对面：`auto_eligible`、`risk_tag`、`status_unknown` 三字段（旧 sidecar 无 status_unknown 字段时按 false 读）；行新增（本轮有、上轮无）、行消失（上轮有、本轮无）。
- 输出形（钉死，AC8 逐字引此）：有基线时首行 `## ⚠ 资格翻转告警（vs 上轮）`，继以表格逐行列翻转（列：Task／字段／上轮／本轮；新增行字段列记 `（新增）`、消失行记 `（消失）`），末行摘要 `flips: <n>, added: <a>, removed: <r>`（flips 只计三字段翻转，新增/消失另计）；零翻转时仍输出标题行＋摘要行（全 0）。无基线时首行 `## 资格翻转告警：无上轮基线`＋同一摘要行（全 0）。
- 夹具：`.tad/scripts/fixtures/surplus-plan-diff/` 放 prev/new 两件构造 sidecar，情形钉死：auto 翻转 1 行、risk_tag 翻转 1 行、新增 1 行、消失 1 行、完全不变 1 行 → 摘要须为 `flips: 2, added: 1, removed: 1`。

## 4.4 A 面 · 回放脚本与语料（.tad/scripts/surplus-scan-replay.mjs，新）

- 调用形：`node .tad/scripts/surplus-scan-replay.mjs [fixtureDir] [--workflow <path>]`；默认 fixtureDir=`.tad/scripts/fixtures/surplus-scan-replay`、workflow=`.tad/workflows/claude/surplus-scan.workflow.js`。
- 抽取与保真：按 §4.2 的 BEGIN/END 标记逐字抽取块文本，算 sha256 与语料 `corpus.json` 的 `classify_block_sha256` 对账；标记缺失、哈希不符、或抽取块求值后 `classifyCandidate` 非函数 → stdout 末行 `REPLAY-RESULT: EXTRACT-FAIL`、exit 2（fail-closed，永不静默通过）。求值在 `node:vm` 的空白上下文中进行（块内零依赖是 §4.2 的设计约束，求值环境不提供任何仓内模块）。
- 逐行判定：对 corpus 每行跑 classifyCandidate，与 `expected.json` 逐行对 disposition 全等、auto_eligible（ranked 行）与 status_unknown（expected 点名行）对账、reasons 须含 expected 点名的 reason。逐行输出 `ROW <id> expected=<d> got=<d> OK`（不合为 MISMATCH 并附差项）；末行 `REPLAY-RESULT: PASS rows=12` 或 `REPLAY-RESULT: FAIL rows=12 mismatches=<k>`；exit 0/1。
- 语料落 `.tad/scripts/fixtures/surplus-scan-replay/`：`corpus.json`（含 classify_block_sha256 与 12 行 reader-output 形态候选）、`expected.json`、`README.md`（逐行来源：七行集引 fixture-sidecar-replay.json 与 run-record-replay.md 的行号、三例引 proposal §1、正控为构造行并显名）。
- 语料 12 行（reader 字段赋值与 expected 由下表钉死；Blake 按表逐字构造 corpus 行，事实出处见 README 要求）：

| # | id | reader 字段要点 | expected |
|---|----|------------------|----------|
| 1 | replay-prereq-lock | source_status=live（行在盘、状态 parked）；human_prereq=true，what=等用户 grant 与出网授权 | needs-human，reasons ∋ human-prereq |
| 2 | replay-human-acceptance | human_prereq=true（人域验收/恢复）；cited_missing 含 input brief 件（具体路径取 gate4-fixture 源） | needs-human（双命中，只判 disposition 与 auto=false） |
| 3 | replay-already-landed | source_status=landed | dropped-stale |
| 4 | replay-approval-reversed | source_status=unknown，evidence 点名批准面（候选前提「已获批」与批准面矛盾） | needs-human，status_unknown=true（守 D3 边界：不入 human_prereq） |
| 5 | replay-status-missing | 行内**无** source_status 字段（reader 未发） | needs-human，status_unknown=true |
| 6 | replay-stale-narrative-52 | source_status=superseded，evidence=活状态件计数（在队 0／已出队 52） | dropped-stale |
| 7 | replay-regression-missing-status | 行内无 source_status 字段 | needs-human，status_unknown=true |
| 8 | jev-production-trial | human_prereq=true，what=L3 账号＋PM 1:1（只有用户能给）；value≥3 且 safe（旧逻辑下会 auto-eligible——翻转正是本行要证的） | needs-human，reasons ∋ human-prereq |
| 9 | gap-queue-52-disposition | source_status=superseded，evidence=队列活状态（52 条已全数出队、挂起 0） | dropped-stale |
| 10 | epic-20260927-citation | cited_missing 含 EPIC-20260927 引用路径（构造为当时缺位形态；真文件现已恢复，本行以语料内字面路径作引用串、与盘面实存无关——回放验的是分类行为，不是盘面） | needs-human，reasons ∋ cited-missing |
| 11 | control-live-auto | source_status=live、evidence 在盘；无 prereq；cited 全在；value=4、safe、非 generated | ranked，auto_eligible=true |
| 12 | control-live-lowvalue | 同 11，惟 value=2 | ranked，auto_eligible=false（价值地板，不许被门误判 needs-human） |

## 4.5 A 面 · SKILL 装载步（.agents/skills/surplus/SKILL.md）

`--plan` 命令节在现行 step 3（Persist the two artifacts）之后新增一步（编号顺延、原文其余不动）：persist 前先定 prev——取现存最新 `SURPLUS-PLAN-*.json`，若其 stem 与本轮目标相同（同日重跑），先复制为临时 prev 件再覆写；persist 后运行 `node .tad/scripts/surplus-plan-diff.mjs <prev|NONE> <本轮 json>`，把 stdout 的告警节追加进本轮 plan `.md` 末尾。装载点即 SKILL 的 `--plan` 边界：每次产计划必经。`.claude/skills/surplus/` 投影刷新不在写集（installer 面，记 §10.3 携带）。

## 4.6 B 面 · 规则面五处落字规格（钉死字面，AC10–AC14 逐字引此）

| # | 落点文件 | 动作 | 钉死字面（grep 锚） |
|---|----------|------|--------------------|
| B1+B2 | `.tad/project-knowledge/patterns/ac-verification.md` | 新增条目一条（两款：设计期字面形——Expected 引用工具输出须以设计会话实跑的逐字形（含全路径）书写，转述/bare 形是设计缺陷类，grounded AC11；交付期词表对账——凡 Expected 以字面串锚定脚本输出，脚本交付前实跑输出与 Expected 串逐字比对并随 COMPLETION 留记录，grounded AC9） | 条目标题含 `Literal Output Form` 与 `Wordlist Reconciliation` |
| B3 | 同上 | 新增条目一条：计数类 AC 的方法文须显名计数面（节范围＋行形锚＋排除面），夹具集须含一副「结构行同形」负控（结构行与数据行同形但必须不入计数），grounded Phase 3 AC7/AC11 两例与 K-5 | 条目标题含 `Counting Surface` 与 `Negative Control` |
| B4 | `.tad/project-knowledge/patterns/handoff-design.md` | P-C 条目（Re-Verify Every Load-Bearing Baseline Premise…）内、Oracle reachability 子节之后，增子面段：验收行以工具输出或定位串（路径/行号/grep 串）为 oracle 时，前提复核含于设计会话按逐字形态实跑工具/实解定位串一次；转述得来的定位串属未验前提，grounded Phase 2 Gate 4 验收人自证（转述定位串得空值、回逐字 Method 后全合）＋AC11 | 子面标题 `#### Output-form and locator-form premises` |
| B5 | `.tad/gates/gate-canonical-checklist.md` | Gate 2 节 `[handoff-header-form]` 条目在现行三点后加第 ④ 点（只加机械面）：`④ §9.1 各行 Expected Evidence 非空（表区逐行机械可判；输出形预设的判断面由 AC dry-run 表承接，不在本点）` | 含字面 `Expected Evidence 非空`，且位于 Gate 2 节 `[handoff-header-form]` 条目内 |
| B6 | `.tad/project-knowledge/patterns/gate-design.md` | 新增条目一条（KC3 通则）：探针/分类类机制的判定结果必须全量进入机器可读产物面；log() 类易失面不得作唯一证据面；首个实例＝本 Phase 的 sidecar 字段面＋回放报告面 | 条目标题含 `Second Observable Surface` |

五处条目的内部形态从各文件既有条目体例（Selector/Context/Discovery/Action/failure_mode/Grounded in 等该文件现行字段），不新造体例；patterns `_index.md` 是文件级路由，新增条目在既有文件内，不动索引（此判断在此显名）。

## 4.7 KC3 显名处置

KC3（Phase 3 携带：Gate 4 corroboration 沿 log() 做、载体易失，路由本 Phase「落机制或显名不修」）的处置为**落机制**，两件齐才算处置成立：①规则件——B6 的 gate-design 通则条目；②实例件——本 Phase A 面把扫描分类的全部判定落进 sidecar 字段面（status_unknown／gate_reasons 等）与回放报告面，回放验读产物判定、不读 log()。Phase 3 gate4_delta 中 KC3 一行由本 Phase 的 COMPLETION 显名回指此节销账。

## 4.8 装载点总表（Gate 2 逐项核）

| 落地件 | 装载面 | 触发时点 |
|--------|--------|----------|
| scan workflow 三查＋门控 | `.tad/workflows/claude/surplus-scan.workflow.js` 本体，经 surplus SKILL 以 scriptPath 调用 | 每次 `*surplus --plan` 扫描 |
| diff 脚本＋告警节 | SKILL `--plan` 的 persist 后步 | 每次产计划（落盘时） |
| replay 脚本＋语料 | 手动/Gate 评审调用；规则：凡改 classify-block 必重跑回放（写入 replay README 与 COMPLETION 口径） | 分类逻辑变更时＋Gate 3 |
| ac-verification 两条 | Alex/Blake 激活时经 patterns 索引装载（文件级既有装载） | 每次写/验 AC |
| handoff-design 子面段 | 同上（既有文件内） | 每次设计 handoff |
| gate-canonical ④ | Gate 2 评审清单本体 | 每次 Gate 2 |
| gate-design 通则条目 | Alex/Blake 激活时经 patterns 索引装载 | 每次设计探针/分类类机制 |

---

# 5. ❓ Forced Questions (Alex必填)

**Q-1 三查为什么不全放 reader 层（让 agent 直接判 needs-human）？**
A: reader 判读不可回放、不可对账——同一候选两轮扫描可能给出不同结论且无从验。分层后 reader 只报告可核事实（字段＋证据串），资格由确定性门控派生，回放语料钉死其行为；这也是 D6 抽取验得以成立的前提。

**Q-2 为什么 status_unknown 不做成 reader 的必填字段？**
A: 必填字段挡不住「填了但没核」：reader 完全可以把每行都填 live。三查的牙齿在 evidence 串与活状态件可回核，加上缺失/unknown 的派生门——必填只会把 unknown 形态从「缺失」变成「假 live」，更难查。语料第 5/7 行专守缺失形态。

**Q-3 diff 为什么不放进 workflow 的 Rank 里做（省一支脚本）？**
A: Rank 在 workflow 运行时内，没有文件系统、读不到上轮 sidecar；把上轮 sidecar 经 args 注入已被仓内 pattern 证伪（两调用模式均不注入）。放 SKILL 落盘后步是唯一有 FS 的正道，且 SKILL 本就是扫描的调用边界，每次产计划必经。

**Q-4 回放为什么不用仓内现成的 regression-replay.sh？**
A: 那是 R4 判例回放面（judge cases 的分类复核），对象与语料都不同；混用会让两个回放面的失败互相污染。扫描回放是独立脚本、独立夹具目录；两者只共享「回放验分类行为」的方法论。

**Q-5 B 面五处落字会不会又变成「写了没人读」的死规则？**
A: 每处都在 §4.8 点名装载面与触发时点：ac-verification/handoff-design/gate-design 三件是 Alex/Blake 激活必经的 patterns 装载面，gate-canonical ④ 在 Gate 2 清单本体里被逐项核。装载面不存在的落字本设计不写。

**Q-6 真跑一轮（AC16）为什么不让 Blake 在实施里直接跑？**
A: surplus SKILL 明言子代理无 Workflow 工具面、走不通且不许静默降级。真跑只能由 conductor 在有 Workflow 面的 harness 里经 SKILL 边界执行（S7）；Blake 的职责到备料与夹具全验为止。把不可达的步写进 Blake 的 AC 是 Phase 2 P-C 条目点名的病，本设计不犯。

---

# 6. Implementation Steps (for Blake)

**S1 workflow 改造**：改 `.tad/workflows/claude/surplus-scan.workflow.js` 前，先把现行件复制为 `.tad/evidence/yolo/v409-basket/p4-workflow-orig.js`（无 git 口径下的改前快照，承修复链 §10.1 先例）。然后按 §4.1 改 schema 与两处 agent 指令、按 §4.2 收拢 classify-block 并接 Rank 主流程、扩 sidecar/totals/Needs You 渲染。改后以 §8 的 parse oracle 复验（剥 `export` 包 async 解析，exit 0）。

**S2 回放件**：按 §4.4 建 `.tad/scripts/surplus-scan-replay.mjs` 与语料三件（corpus.json／expected.json／README.md）；corpus 的 classify_block_sha256 在 S1 落定后按实际抽取块计算填入。自跑至 12/12 PASS；再以篡改副本验 fail-closed（AC7 同法自测，留输出）。

**S3 diff 件**：按 §4.3 建 `.tad/scripts/surplus-plan-diff.mjs` 与夹具两件；自跑夹具对摘要行、再以 NONE 形态跑无基线支，各留输出。

**S4 SKILL 装载步**：按 §4.5 改 `.agents/skills/surplus/SKILL.md` 的 `--plan` 节（只加一步与 prev 选取句，其余原文不动）。

**S5 B 面落字**：按 §4.6 五处逐处落字，字面与规格表逐字一致；落字后逐处 grep 自验（AC10–AC14 同法）。

**S6 自验与 COMPLETION**：§9.1 逐行实跑，结果与输出摘要写进 COMPLETION-20261101-scan-surface.md（含写集对账表、KC3 回指 §4.7 的销账行、C-RR 式前向义务如有则显名）。

**S7 真跑一轮（conductor 步，非 Blake）**：Gate 3 通过后、Gate 4 之前，conductor 在有 Workflow 面的 harness 经 surplus SKILL 跑一次 `--plan`，产新一版 plan＋sidecar，diff 节对 2026-10-31 sidecar 生成；结果（或 not-run 显名）记 Epic Run 并供 Gate 4 消费（AC16）。

排序理由：S1 先行（哈希锚依赖它）；S2/S3 可并行于 S1 之后；S5 与 S2–S4 无依赖，可穿插；S6 收口；S7 在评审链内由 conductor 执行——步序与 Phase 3 的「conductor 编排运行面」先例同构。

---

# 7. File Structure & Directories

## 7.1 写集（封闭清单）

**改（6 件）**：
- `.tad/workflows/claude/surplus-scan.workflow.js`
- `.agents/skills/surplus/SKILL.md`
- `.tad/project-knowledge/patterns/ac-verification.md`
- `.tad/project-knowledge/patterns/handoff-design.md`
- `.tad/project-knowledge/patterns/gate-design.md`
- `.tad/gates/gate-canonical-checklist.md`

**新（8 件）**：
- `.tad/scripts/surplus-plan-diff.mjs`
- `.tad/scripts/surplus-scan-replay.mjs`
- `.tad/scripts/fixtures/surplus-scan-replay/corpus.json`
- `.tad/scripts/fixtures/surplus-scan-replay/expected.json`
- `.tad/scripts/fixtures/surplus-scan-replay/README.md`
- `.tad/scripts/fixtures/surplus-plan-diff/prev.json`
- `.tad/scripts/fixtures/surplus-plan-diff/new.json`
- `.tad/active/handoffs/COMPLETION-20261101-scan-surface.md`（Blake 收口件）

**证据根**（新件落此，不算写集外溢）：`.tad/evidence/yolo/v409-basket/` 下 p4- 前缀件（workflow 改前快照 p4-workflow-orig.js、回放/diff 自跑输出、parse 复验输出）。

**明示不改**：`.tad/workflows/claude/surplus-execute.workflow.js` 及其证据面；Phase 2/3 的 HANDOFF/gate-report/COMPLETION 历史件；`.claude/skills/` 投影（installer 面）；patterns `_index.md`（§4.6 显名判断）。

## 7.2 Grounded Against

本设计回读并依据的一手件（评审人可逐件复核）：

- `.tad/workflows/claude/surplus-scan.workflow.js`（全文，基线 sha/行数见基线件）；`.agents/skills/surplus/SKILL.md`（--plan 持久化步与 Workflow 面边界原文）。
- 归档 HANDOFF-20261031-surplus-execute-runtime-compat §10.3（递延三条原文）／§11.1（分层裁定）；GATE3-spec §5（维度边界）；FIX-COMPLETION（分支 0 落地形态）。
- `.tad/evidence/surplus-execute-fix-20261031/fixture-sidecar-replay.json`（七行集源）；`.tad/evidence/surplus-execute-fix-20261031/run-record-replay.md` L37–43、L96–102（七行预期处置与维度归属注记；与 fixture 同目录，证据根直下，无 gate-reviews 子目录——修订轮按盘面实位改正）。
- 技术研究席 `consult/20261031-process-suggestions/proposal.md` §1（三查定义与三例逐字事实）；TICKET-20261031-process-suggestions 裁定 1（回放验的出处在此与 PLAN Step 3，不在 panorama 票——修订轮 F2 改正）。
- Phase 2 GATE-REPORT-20261031-distill-batch（AC11 delta 与 P-C 携带原文）；Phase 3 GATE-REPORT-20261031-pack-triage（AC9/KC3 原文）与 COMPLETION-20261031-pack-triage（候选 ①② 原文）。
- `.tad/gates/gate-canonical-checklist.md` Gate 2 节（handoff-header-form 现行三点、AC dry-run 表、装载点要求）；命中 patterns 条目段（ac-verification／handoff-design P-C／gate-design 两节）。
- `.tad/active/SURPLUS-PLAN-2026-10-31.json`（真基线 sidecar，46 行计数设计期实测）。

---

# 8. Testing Requirements

## 8.1 测试分层

- **回放验（主验收面）**：§4.4 的 12 行语料全合 expected；含 2 正控（防全拦）与 2 缺失形态行（防必填造假）；篡改块 fail-closed 单独成 AC7。
- **diff 夹具验**：五情形构造 sidecar 对摘要行逐字合；无基线支单独跑。
- **parse 验**：改后 workflow 以设计期已证的 parse oracle 复验 exit 0（注意：`node --check` 对本形态文件是假门——文件以 `export const meta` 开头且含顶层 return/await，必须剥 export 后包 async 解析，承 ac-verification 的 wrapped-body 纪律）。
- **落字 grep 验**：B 面五处逐处以钉死字面 grep 命中且位置在指定节/条目内。
- **真跑验（conductor）**：S7/AC16 双支。

## 8.2 不测什么（显名）

- 不测 agent 的 reader 判读质量本身（LLM 面）：三查的 reader 报告质量由活状态件证据串的可回核性约束，不由本 Phase 的确定性回放背书——回放验的是「给定 reader 字段，门控行为正确」。
- 不测 surplus-execute 的任何行为（已落地、非写集）。

## 8.3 环境

全部确定性验在仓根以 node v24／系统 grep／python3（计数复核时）执行，无网络、无外部服务。

## 8.4 Friction Preflight

- workflow 编辑面：文件以 `export const meta` 开头、含顶层 await 与裸 `return`——任何「直接 node 跑一遍」的验法都是假门，只有 §8.1 的 parse oracle 有效；Blake 不得另发明验法。
- 表格方言：§9.1 的 Method 列含 `\|` 处是 markdown 转义，实跑时为 `|`；计数一律 `grep -c` 逐词单跑，不用 BRE 交替（Phase 3 Gate 2 两轮 FAIL 的原样教训）。
- 夹具路径纪律：两支脚本的夹具目录都在 `.tad/scripts/fixtures/` 下，与证据根分开——回放语料是长期回归资产，不是单次证据，不许只落证据根。
- corpus 哈希锚：S1 未落定前不要先写 corpus.json 的哈希（锚的是实施后的实际块）；顺序错了 AC7 的对账必红且会误导评审。
- 命令方言：`sed -i` 的 GNU/BSD 形不兼容（BSD 把脚本参数吞作备份后缀），§9.1 与脚本一律不用，改写文件用 python3 replace（AC7 即此形；Gate 2 领域面 F3 处置）。

---

# 9. Acceptance Criteria

## 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE — Gate 3 executes each row

> 方法文法：command｜path-check｜fixture；纯散文非法。计数类 AC 的计数面在方法文中写明（本表自身即按 B3 拟议口径先行自守）。全部命令在仓根执行；Method 列的 `\|` 是 markdown 转义，实跑时为 `|`。基线值全部来自设计期实测件 `p4-baseline-scan.txt`；post-impl 行在未改树上应以「基线形态」失败（记录不存在或计数为基线值），这是其非空洞性的证明。Expected 中的字面串只有两类来源：基线件实测值，或 §4 组件规格先行钉死的输出形——后者正是 AC9 教训的正向用法（先钉规格形、再引为判据）。

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| AC1 | 三查字段落 schema 与门控（D1/FR1–FR3）：workflow 含 source_status／human_prereq／cited_missing／cited_paths 四词，计数面＝文件全文 | post-impl-verifiable | `grep -c 'source_status' .tad/workflows/claude/surplus-scan.workflow.js; grep -c 'human_prereq' .tad/workflows/claude/surplus-scan.workflow.js; grep -c 'cited_missing' .tad/workflows/claude/surplus-scan.workflow.js; grep -c 'cited_paths' .tad/workflows/claude/surplus-scan.workflow.js` | 四值依次 ≥3／≥3／≥2／≥2（§4.1/§4.2 钉死的出现面：schema＋agent 指令＋Rank 门控＋产物渲染） | 基线：0／0／0／0（基线件实测） |
| AC2 | status_unknown 派生门（D2/FR1）：回放语料第 5/7 行（reader 未发状态字段）被判 needs-human 且对账 OK | fixture | `node .tad/scripts/surplus-scan-replay.mjs > /tmp/p4-replay.txt 2>&1; echo $?; grep -E '^ROW replay-(status-missing\|regression-missing-status) ' /tmp/p4-replay.txt \| grep -c 'OK$'` | 两值依次 =0（exit）／=2 | 基线：脚本不存在（new）；两行事实源 run-record-replay.md L41/L43 设计期逐字核（修订轮回盘复核改正，原记 L40/L42 差一） |
| AC3 | 人供前置门（D3/FR2）：jev 例与七行集第 1 行被判 needs-human——jev 在旧逻辑下为 auto-eligible 形态，翻转即本行所证 | fixture | `node .tad/scripts/surplus-scan-replay.mjs 2>/dev/null \| grep -E '^ROW (jev-production-trial\|replay-prereq-lock) ' \| grep -c 'expected=needs-human got=needs-human OK'` | =2 | 基线：脚本不存在（new）；jev 旧形态见 proposal §1（曾标 auto-eligible） |
| AC4 | 活状态门与 D3 边界（FR1）：三行 landed/superseded 被 drop；批准面矛盾行以 status 面收场 needs-human | fixture | `node .tad/scripts/surplus-scan-replay.mjs 2>/dev/null \| grep -E '^ROW (replay-already-landed\|replay-stale-narrative-52\|gap-queue-52-disposition) ' \| grep -c 'expected=dropped-stale got=dropped-stale OK'; node .tad/scripts/surplus-scan-replay.mjs 2>/dev/null \| grep -c '^ROW replay-approval-reversed .*expected=needs-human got=needs-human OK'` | 两值依次 =3／=1（第 4 行的 reasons 构成——不含 human-prereq——由 Gate 3 spec 面按 expected.json 核） | 基线：脚本不存在（new）；事实源：run-record L39/L42＋proposal §1 第二例（修订轮回盘复核改正，原记 L41 为 status-missing 行、stale-narrative 实为 L42） |
| AC5 | 引用件在盘门（FR3）：引用缺位行与双命中行均被判 needs-human | fixture | `node .tad/scripts/surplus-scan-replay.mjs 2>/dev/null \| grep -E '^ROW (epic-20260927-citation\|replay-human-acceptance) ' \| grep -c 'expected=needs-human got=needs-human OK'` | =2 | 基线：脚本不存在（new）；事实源：proposal §1 第三例＋run-record L38 |
| AC6 | 回放全集与正控（D6/D7/FR5）：12 行全合 expected、2 正控不误杀、末行 PASS | fixture | `node .tad/scripts/surplus-scan-replay.mjs > /tmp/p4-replay6.txt 2>&1; echo $?; grep -c '^ROW ' /tmp/p4-replay6.txt; grep -E '^ROW control-live-' /tmp/p4-replay6.txt \| grep -c 'expected=ranked got=ranked OK'; tail -1 /tmp/p4-replay6.txt` | 四值依次 =0／=12／=2／末行含 `REPLAY-RESULT: PASS` 与 `rows=12`（输出形由 §4.4 钉死） | 基线：脚本与语料不存在（new）；node v24.22.1 设计期实测在位 |
| AC7 | 抽取保真 fail-closed（D6）：classify 块被篡改一字时回放以 EXTRACT-FAIL 拒绝，绝不静默通过 | post-impl-verifiable | `cp .tad/workflows/claude/surplus-scan.workflow.js /tmp/p4-wf-copy.js; python3 -c "import pathlib; p=pathlib.Path('/tmp/p4-wf-copy.js'); p.write_text(p.read_text().replace('classifyCandidate','classifyCandidatX',1))"; node .tad/scripts/surplus-scan-replay.mjs --workflow /tmp/p4-wf-copy.js > /tmp/p4-tamper.txt 2>&1; echo $?; tail -1 /tmp/p4-tamper.txt` | 两值依次 =2／末行含 `REPLAY-RESULT: EXTRACT-FAIL`（输出形由 §4.4 钉死） | 基线：脚本不存在（new）；保真纪律源＝Phase 2 逐字副本＋哈希对账落地件 |
| AC8 | diff 脚本双支（D5/FR4）：夹具五情形摘要逐字合；无基线支显名收场 exit 0 | fixture | `node .tad/scripts/surplus-plan-diff.mjs .tad/scripts/fixtures/surplus-plan-diff/prev.json .tad/scripts/fixtures/surplus-plan-diff/new.json \| tail -1; node .tad/scripts/surplus-plan-diff.mjs NONE .tad/scripts/fixtures/surplus-plan-diff/new.json \| head -1; node .tad/scripts/surplus-plan-diff.mjs NONE .tad/scripts/fixtures/surplus-plan-diff/new.json > /dev/null; echo $?` | 三值依次 =`flips: 2, added: 1, removed: 1`／`## 资格翻转告警：无上轮基线`／0（字面形由 §4.3 钉死） | 基线：脚本不存在（new）；现行 plan 无告警节（基线件：2026-10-31 plan 锚词计数 0） |
| AC9 | SKILL 装载点（D5/FR4）：diff 步出现在 `--plan` 的 persist 步之后 | post-impl-verifiable | `awk '/Persist the two artifacts/{p=NR} /surplus-plan-diff/{d=NR} END{print p, d}' .agents/skills/surplus/SKILL.md` | 两数均为正且 d＞p | 基线：SKILL 中 surplus-plan-diff 计数 0（基线件实测） |
| AC10 | B1+B2 落字（FR6）：ac-verification 新增条目含输出形两款的钉死字面 | post-impl-verifiable | `grep -c 'Literal Output Form' .tad/project-knowledge/patterns/ac-verification.md; grep -c 'Wordlist Reconciliation' .tad/project-knowledge/patterns/ac-verification.md` | 两值各 ≥1；两款内容（设计期字面形／交付期词表对账）与 grounded 出处（AC11/AC9）由 Gate 3 spec 面核 | 基线：0／0（基线件实测） |
| AC11 | B3 落字（FR6）：计数面条目落字，含结构行同形负控 | post-impl-verifiable | `grep -c 'Counting Surface' .tad/project-knowledge/patterns/ac-verification.md; grep -c 'Negative Control' .tad/project-knowledge/patterns/ac-verification.md` | 两值依次 ≥1／≥2（第二值基线为 1——既有新守卫条目已用该词，新条目标题须再添 1） | 基线：0／1（基线件实测，据实记） |
| AC12 | B4 落字（FR7）：P-C 条目内增输出形/定位形子面段 | post-impl-verifiable | `grep -c 'Output-form and locator-form premises' .tad/project-knowledge/patterns/handoff-design.md` | =1；子面段位于 P-C 条目内、Oracle reachability 子节之后，由 Gate 3 spec 面核位置 | 基线：0（基线件实测） |
| AC13 | B5 落字（FR8）：gate-canonical 的 handoff-header-form 增第 ④ 点（机械面） | post-impl-verifiable | `grep -c 'Expected Evidence 非空' .tad/gates/gate-canonical-checklist.md` | =1；其位于 Gate 2 节 `[handoff-header-form]` 条目内且为第 ④ 点，由 Gate 3 spec 面核位置 | 基线：0（基线件实测） |
| AC14 | B6 落字＋KC3 处置（FR9）：gate-design 新增第二可观测面通则条目 | post-impl-verifiable | `grep -c 'Second Observable Surface' .tad/project-knowledge/patterns/gate-design.md` | ≥1；条目点名首个实例（本 Phase sidecar 字段面＋回放报告面）由 Gate 3 spec 面核 | 基线：0（基线件实测） |
| AC15 | 不回归（NFR1）：改后 workflow 以 parse oracle 可解析；既有产物面计数只增不减 | post-impl-verifiable | `node -e "const fs=require('fs');let s=fs.readFileSync('.tad/workflows/claude/surplus-scan.workflow.js','utf8');s=s.replace(/^export const meta/m,'const meta');new Function('return async function(){\n'+s+'\n}');console.log('parse-ok')"; grep -c 'auto_eligible' .tad/workflows/claude/surplus-scan.workflow.js; grep -cF 'Auto?' .tad/workflows/claude/surplus-scan.workflow.js` | 三值依次 =parse-ok（exit 0）／≥8／=1 | 基线：设计期同法在未改文件实测 parse-ok exit 0、计数 8／1（基线件实测） |
| AC16 | 真跑一轮（D5/FR4/S7，conductor 步，双支）：新一版 plan 经 SKILL 边界产出且含 diff 告警节，或显名 not-run 以夹具全集代偿 | path-check | 新 plan 件：`ls -t .tad/active/SURPLUS-PLAN-*.md \| head -1` 取最新件后 `grep -c '资格翻转告警' <该件>`；not-run 支：`grep -c 'not-run' .tad/active/handoffs/COMPLETION-20261101-scan-surface.md` | 二支其一成立：(a) 最新 plan 日期晚于 2026-10-31 且告警节计数 ≥1、Epic Run 记其路径与翻转行数；(b) not-run 计数 ≥1 且 COMPLETION 显名理由引 SKILL 的 Workflow 面边界原文、AC6/AC8 均已 PASS | 基线：最新 plan 为 2026-10-31 版、告警节计数 0（基线件实测）；COMPLETION 不存在（new） |

## 9.2 Expert Review Status

> 由 conductor 在 Gate 2 派发后回填；设计人不自填 verdict。

| 评审面 | 评审人 | 状态 |
|--------|--------|------|
| Gate 2 spec | （conductor 派发） | ⏳ |
| Gate 2 code/run | （conductor 派发） | ⏳ |

---

# 10. Notes & Warnings

## 10.1 ⚠️ Implementation Warnings

- **corpus 哈希锚的顺序**：`corpus.json` 的 classify_block_sha256 必须在 S1 落定后按实际抽取块计算；先写锚再改块，AC6/AC7 必红且红得误导。
- **reader 指令的两处一致性**：Scan 与 Generate 的三查指令段必须同文同义；只改一处会在合并阶段丢字段（§4.1 已显名 Generate 的保留义务）。
- **diff 的 prev 选取时机**：prev 必须在 persist 覆写之前定（同日同 stem 重跑先复制旧件）；写反了顺序，告警节会拿本轮和自己比、恒零翻转且不报错——这是本 Phase 最容易静默出错的一步，S4 自测须含同 stem 情形的口径说明（记 COMPLETION）。
- **篡改验的副本位置与写法**：AC7 的副本只许落 /tmp，不许在仓内改 workflow 本体做篡改验；篡改用 python3 一行 replace，不用 `sed -i`（GNU/BSD 形不兼容，Gate 2 领域面 F3）。

## 10.2 🚫 Implementation Constraints

- 不动 surplus-execute 本体与分支 0；不动已判历史件；不跑任何 git 命令；不引入新依赖（仅 node 标准库与系统工具）。
- classify-block 内不许引用块外变量/函数（回放求值的空白上下文会当场揭穿，但不许把揭穿当设计手段——S1 落块时自查依赖面并记 COMPLETION）。

## 10.3 本 Phase 的销账与携带

- **销账**：修复链 §10.3 递延三条（ⓐⓑⓒ）由 FR1/FR4/FR2 承接，Gate 4 收口时在 Epic Run 回指；Phase 2 AC11（B1）、Phase 3 AC9（B2）与候选 ①②（B3 的计数面款与 B1 的词表对账款）、P-C 子面（B4）、KC3（§4.7）同批销账；Sober ③ 由 B5 承接（INTAKE-20261101 裁定回指）。
- **携带（出本 Phase）**：① `.claude/skills/surplus/` 投影刷新走 installer/发版面，随 4.0.9 发版收口一并处理；② 三查在真 backlog 上的 reader 报告质量（证据串回核率）属运行观察面，首轮读数由 S7 真跑产出后记 Epic Run，不另立 Phase；③ F1（Phase 3 携带的 runner locale 件）不在本 Phase 写集，仍挂后续小修批；④ 批准面矛盾与「未核到状态」在产物面同码（reasons 只有 `status-unknown`，差异只活在 source_status_evidence 自由文本里，diff 与日后读数不可机械区分——Gate 2 领域面 P2 R1）：机械区分须给 reader 一个结构化信号（如独立 reason token 的来源字段），属 schema 级设计变更，不在本 Phase 夹带；显名携带至下一小修批/扫描面维护面，中间态以证据串文本承载差异（处置结果无差，同为 needs-human）。

---

## Gate Rounds

<!-- GATE-ROUNDS-BEGIN -->
GATE-ROUNDS-SCHEMA: v1
GATE-ROUNDS-DERIVATION: v1
（派生定义逐字抄录自 `.agents/skills/gate/SKILL.md` 的 NO-PROGRESS derivation 块：）
G{n} = rows for Gate n AFTER the most recent HUMAN-GRANTED-CONTINUE row (or from the table start when there is none) whose verdict is NOT IN {PASS, RUNNING, HUMAN-GRANTED-CONTINUE}. A GRANT row therefore zeroes every G{n}; verdicts before it stay in the table and still count toward TOTAL_ROUNDS.
TOTAL_ROUNDS = ALL rows whose verdict is NOT IN {PASS, RUNNING, HUMAN-GRANTED-CONTINUE} — the lifetime sum of the three gates' non-PASS rounds. It NEVER decreases: a PASS row is recorded (it proves a stage ran) but is not a repair round, and interleaved PASSes leave every count exactly where it was. (Deviation from the archived 2026-08-04 design, flagged for review: its TOTAL also counted PASS rows, which would fire the backstop on a flawless multi-stage handoff; its G{n} formula is kept verbatim.)
GRANT = rows whose verdict IS HUMAN-GRANTED-CONTINUE.
Counts are DERIVED from the rows on every read. There is no stored counter anywhere; a stored number that disagrees with the derivation loses to the derivation.

| 时间 | Gate | verdict | 类别 | 记录者 |
|---|---|---|---|---|
| 2026-11-01 | design | DRAFT-COMPLETE | design-boundary | Alex (p4-y3-1) |
| 2026-11-01 | G2-consistency | CONDITIONAL (p0=0，P1×3) | review | verifier (p4-y4-cr-1) |
| 2026-11-01 | G2-domain | CONDITIONAL (p0=0，P1×3) | review | verifier (p4-y4-dom-1) |
| 2026-11-01 | G2 | CONDITIONAL (p0=0，合成) | gate | Alex (p4-y4-fix-1 记账，据双面 verdict) |
| 2026-11-01 | G2-fix | REVISED（6×P1 全处置＋P2×2 处置/显名携带，待窄口复审） | design-boundary | Alex (p4-y4-fix-1) |
| G3-consistency | 2026-11-01 | CONDITIONAL | p0=0；P1-1 与代码面同根 | .tad/evidence/yolo/v409-basket/p4-gate3-review-spec.md |
| G3-run | 2026-11-01 | CONDITIONAL | p0=0；RP1 PASS；P1-1 双面 | .tad/evidence/yolo/v409-basket/p4-gate3-review-code.md |
| G3-fix-verify | 2026-11-01 | PASS | P1-1 双面关闭 | .tad/evidence/yolo/v409-basket/p4-gate3-fix-verify.md |
| G4 | 2026-11-01 | CONDITIONAL PASS | p0=0；开放 P1=0；四表态全成立 | .tad/evidence/yolo/v409-basket/phase4-gate-report.md |
<!-- GATE-ROUNDS-END -->

**Gate 3 (Code Review)**: ⏳ Pending implementation
**Gate 4 (Acceptance)**: ⏳ Pending Gate 3

---

## Sign-off

**Alex (Solution Lead)**: 设计完成，至 step1d 止步（dispatch p4-y3-1，2026-11-01）。显名事项三件随件上报 conductor：① D10 B 面不拆 Phase 的判断与理由（§4.0）；② KC3 的落机制处置（§4.7）；③ 回放第 10 行以合成缺位形态构造（真文件已恢复，§4.4 表注）。
**Blake (Execution Master)**: ______________________
**Gate 2 Reviewers**: ______________________

---

## 设计修订记录（Gate 2 Round 1 · dispatch p4-y4-fix-1）

### 激活自报（Alex · p4-y4-fix-1）

- 角色：Alex（Solution Lead），按 conductor-protocol `step_Y4` 第 5a 条做 Gate 2 设计修订；只改本 HANDOFF，不写实现、不派 subagent、不自出 verdict。模式／对象自检：Alex design-fix，本文件。
- 激活路径：已加载 `~/workspace/skills/tad-alex/SKILL.md` 薄壳并进仓读原件：`AGENTS.md`、principles、patterns 索引（命中 handoff-design／ac-verification／shell-portability 口径，未新增 pattern 依赖）、brain-index 路由、`.agents/skills/alex/references/handoff-creation-protocol.md` step1（Gate Rounds 骨架原文）、conductor-protocol step_Y4 第 5a 条、gate-canonical Gate 2 节、Epic 与全部派发输入件。
- 修订输入：`p4-gate2-review-code.md`（`p4-y4-cr-1`，CONDITIONAL，P1×3）与 `p4-gate2-review-domain.md`（`p4-y4-dom-1`，CONDITIONAL，P1×3＋P2 备注×2），均在 `.tad/evidence/yolo/v409-basket/`。下表逐条处置 8 项，两面合成 p0=0、无 no-patch 触发（双面 `fix_introduced_p0`／`repeat_class_p0`／`enumerate_p0` 均为 0），走 5a  plain 设计修订、不进 5c re-plan。
- 个人实测摘要（修订前回盘）：CANDIDATE_SCHEMA properties 逐个点数 = 13（id／title／source／summary／value／confidence／token_cost／cost_rationale／value_rationale／deliverable／target_paths／safety_flag／risk_tag）——代码面 P1-1 成立，领域面基线复核节记「14 字段相符」为误，本修订以盘面点数为准；run-record-replay.md 表头 L35、七行依次 L37–L43（prereq-lock L37／human-acceptance L38／already-landed L39／approval-reversed L40／status-missing L41／stale-narrative-52 L42／regression-missing-status L43）；isStale 本体在 workflow L241–247、Rank 调用点在门控前的现行判定序属实。
- 前置形态已执行：front matter `dispatch_id` 改为 p4-y4-fix-1，其下新增 `dispatch_history: [p4-y3-1]`；Gate Rounds 按骨架补标记块并落五行（design 边界／双面 CONDITIONAL／合成／本修订 REVISED）。

### Findings 逐项处置表

| Finding | 处置 | 改动位置 | 个人复核证据 |
|---|---|---|---|
| Code P1-1 — schema 字段数记 14、盘面实为 13 | 接受：两处改 13 | §2.2 现状表、§4.1 首句 | 修订后 `grep -c '14 字段'` = 0、`'13 字段'` = 2；字段点数见自报 |
| Code P1-2 — AC2/AC4 行号差一、§7.2 子路径不实 | 接受：AC2 改 L41/L43、AC4 改 L39/L42（各附改正注）、§7.2 改证据根直下全路径并显名无 gate-reviews 子目录 | §9.1 AC2／AC4 的 Verified Output 列、§7.2 | sed 实读 L35–L43 逐行点数（见自报） |
| Code P1-3 — Gate Rounds 标记块缺失 | 接受：按 handoff-creation-protocol step1 骨架补块（BEGIN/END＋SCHEMA＋DERIVATION＋派生定义逐字抄录＋表头），落 design 边界行与本轮四行 | `## Gate Rounds` 节 | `grep -c` BEGIN／SCHEMA／END = 1／1／1 |
| Domain F1 — §4.1 ⓑ 与 §4.2 第 2 步优先级自相矛盾 | 接受并裁断（新增 D11）：字段层独占 disposition；isStale 文本层降为 sidecar `stale_text_signal` 信号，不单独 drop；字段缺失/unknown 先走 status_unknown 门。裁断与三查「立论源须活状态件」（reader 回活状态件实核、字段即其产物）及回放语料自洽（12 行 expected 无一行依赖文本层 drop） | §4.0 D11、§4.1 ⓑ、§4.2 第 2 步与产物面（五字段→六字段）、§3.2 NFR1 | `grep -c 'stale_text_signal'` = 5（D11／§4.1／§4.2 两处／NFR1）；§4.2 判定序回读无文本层 drop 分支 |
| Domain F2 — R-e 引「panorama ⑥ 注脚」不存在 | 接受：三处同源引用全改指实据（process-suggestions 裁定 1 原文＋PLAN Step 3＋proposal §1 验法段），删 panorama ⑥ | §1.5 R-e 行、激活自报 Gate 1 行、§7.2 | `grep -c 'panorama ⑥'` = 0 |
| Domain F3 — AC7 用 GNU 形 `sed -i`，BSD 不合 | 接受：AC7 改 python3 一行 replace（可移植）；§8.4 补方言条；§10.1 副本条同步改写 | §9.1 AC7 Method、§8.4、§10.1 | AC7 方法内无 `sed -i`（全文仅剩 2 处均为「不用 sed -i」的处置说明文本）；修订后干跑 AC7 以正确理由失败（见下） |
| Domain P2 R1 — 批准矛盾与未核状态同码不可机械区分 | 显名携带：区分须 reader 结构化信号（schema 级变更），不夹带进本 Phase；携带行落 §10.3 ④，中间态以证据串承载 | §10.3 携带④ | §10.3 回读在位 |
| Domain P2 R2 — 「改 classify-block 必重跑回放」义务落点弱于触发点 | 接受：义务写进 classify-block 的 BEGIN 标记注释本身（编辑者必见面）；§4.8 与 README 既有落点不动 | §4.2 围栏首行 | 围栏仍 1 块 4 行（注释改文不改行数，code_bound 不变）；标记行回读含 `surplus-scan-replay.mjs` 与 `12/12 PASS` |

### 修订后自验（2026-11-01 本会话实跑）

- §9.1 干跑复跑（修订后方法、未改基线树）：AC1 = 0／0／0／0；AC2 = exit 1／0；AC3 = 0；AC4 = 0／0；AC5 = 0；AC6 = exit 1／0／0／末行 node 错误尾行；AC7（新 python 形）= exit 1／末行 node 错误尾行——15 行均以正确理由失败（新件不存在／计数为基线值），与代码面首轮干跑表逐行同形态；AC15 守卫行 = parse-ok／8／1 按记录值通过；AC16 两支均不成立（最新 plan 仍 2026-10-31 版、告警节 0；COMPLETION 不存在）。match 16/16。
- 形态回读：首行 `---`、`dispatch_id: p4-y4-fix-1` 在 front matter 块内、`dispatch_history` 紧随其下；§9.1 仍 16 行、形态 A 表头未动；围栏块 1 块 4 行；全文 532 行。
- 本修订未动任何实现写集文件（workflow／脚本／SKILL／patterns／canonical 均未触碰），未跑任何 git 命令。

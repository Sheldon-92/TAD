---
dispatch_id: p2-y4-fix-1
dispatch_history: p2-y3-1
# Quality Chain Metadata (Alex 必填 - Phase 4 Hook 将基于此阻塞 Gate 3)
task_type: mixed       # code | yaml | research | e2e | mixed —— 规程/知识文本落盘＋一处 shell 校验器小改
e2e_required: no      # yes | no
research_required: no # yes | no
git_tracked_dirs: []  # 本仓文件夹制（禁 git 命令），无 git-tracked 生产目录口径
skip_knowledge_assessment: no
gate4_delta: []
risk_triggers: [platform]   # 改动面含框架规程文本、判据面模板与一处 hooks/lib 校验器脚本（platform）；无 security/data/money/ui/domain 面
look_first: "not-needed: 本 Phase 全部改动在本仓内（规程、patterns、模板、一处校验器脚本与一份存量 handoff 勘误），不作用于仓外系统、不读写真实用户/项目数据；承重事实已由 conductor grounding 与设计期基线实测（证据根 p2-baseline-*.txt）覆盖"
real_paths:
  - id: RP1
    path: "Gate 3 run 评审人按新骨架写 verdict 并在保存前自检的真实路径：以本 HANDOFF 为对象、按 review-contract §5 新骨架写出自己的 Gate 3 verdict，保存前跑 gate3-check 并贴输出"
    run: "named scenario walk — §6 S4 步 3（verdict 落盘前 `bash .tad/hooks/lib/gate3-check.sh .tad/active/handoffs/HANDOFF-20261031-distill-batch.md <自己的 verdict 文件>`，输出贴入 verdict）"
  - id: RP2
    path: "conductor／Gate 4 验收人在派 Gate 4 前核 Gate 3 件齐备的真实路径：在仓根跑 cora-check gate3-files 查本 Epic Phase 2 的 Gate 3 文件面，并在一个模板形 scratch 夹具集上验其 exit 0 形态"
    run: "named scenario walk — §6 S3 步 4–5（真 Epic 跑一遍＋scratch 夹具跑一遍，输出存证据根 phase2-gate4/）"
  - id: RP3
    path: "读者消费新落知识条目的真实路径：只读本 Phase 新落的三类条目（副本执行节、fixture 契约节、归一层 pattern），答出三个场景问题"
    run: "named scenario walk — §6 S5 步 2（三问走查，答案只许来自新落文本，不许靠旧证据件推断）"
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-10-31
**Project:** TAD（EPIC-20261031-v409-basket）
**Task ID:** TASK-20261031-P2
**Handoff Version:** 4.0.8
**Epic:** EPIC-20261031-v409-basket.md (Phase 2/5)

---

## 激活自报（Alex · dispatch p2-y3-1）

- 角色：Alex（Solution Lead），由 conductor（Cora）派发执行 step Y3（Phase 2 设计），依 `.agents/skills/alex/references/conductor-dispatch-mode.md` 与 handoff-creation 规程至 step1d 止步：不做专家评审选择、不派 reviewer、不写 Gate 2 结论、不给自己的活写 verdict。Gate 2 双审由 conductor 后续独立派发。
- 已读原件：仓根 `AGENTS.md`、`.tad/project-knowledge/principles.md`、`.tad/project-knowledge/patterns/_index.md`＋命中 pattern 相关节（gate-design 的分类器与机器读表两条、ac-verification 的 fixture 相关条目标题面、memory-and-learning 的 K-7 条）、`.tad/tasks/handoff-creation.md`、`.tad/templates/handoff-a-to-b.md`、`.tad/templates/review-contract.md`（§5/§Paths）、`.tad/gates/gate-canonical-checklist.md` Gate 2 节、conductor-protocol step_Y3、Epic 与 BASKET、phase2-grounding、四候选正本（distillation-report）、EPIC-COMPLETION（surplus 链，含 §3 落字位置与 §5 G4-F2 显名）、phase1-gate-report（Knowledge candidates 五条与 AC7 P3 路由）。
- Gate 1：Epic Phase Map 的 Phase 2 行（「四候选落盘＋verdict 表形系统对齐」，用户点数 0）＋ BASKET 第 2 行（「surplus 链四候选落 patterns＋verdict 表形对齐」）即本 Phase 的 Requirement 面；范围、落点建议与分诊义务均可从输入件逐字取得，can design from it。设计须自判的两处（grounding 明示）：cora-check 参数形态素材是否与候选 4 同面（D6/D5 已判：同族不同面，分治）、Phase 1 五候选逐条去向（§4.0 分诊表）。
- 基线先验（Phase 1 Gate 2 的 P0 教训）：本设计的所有承重基线均已在设计期实测落盘——校验器行为三件（`.tad/evidence/yolo/v409-basket/p2-baseline-checkers.txt`）、落盘面形态计数（`p2-baseline-forms.txt`）、AC10 方法干跑（`p2-baseline-fixture-dryrun.txt`）。§9.1 的 Verified Output 列引此三件为据。
- 本 handoff 首行 `---`、`dispatch_id: p2-y3-1` 在 front matter 块内（第 2 行，块闭合于 real_paths 之后）、§9.1 表头为形态 A——按 canonical Gate 2 的 handoff-header-form 三点先行自守，Gate 2 评审仍须机械核验并留痕。
- 本仓纪律：文件夹内禁跑任何 git 命令（仓根 AGENTS.md 头部）；验收一律以 grep/sha256/脚本实跑为面，不用 git diff。推送由 conductor 收口步执行，不在本 handoff 写集内。

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 待 conductor 独立派发（本设计步不自审自批）

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ⏳ 待双审 | 六个 Step 的组件、落点与生效形态在 §4 齐备；承重基线已实测落盘（见激活自报） |
| Components Specified | ⏳ 待双审 | 每 Step 的写集在 §7 点名到文件与节级；新条目标题与骨架文本在 §4.2 逐字给定，Blake 不自创标题 |
| Functions Verified | ⏳ 待双审 | §5 MQ2 已核：gate3-check.sh 分类器列名规则、cora-check.sh 两处 slug 派生行号（L68/L223）均盘面实证 |
| Data Flow Mapped | ⏳ 待双审 | §5 MQ5：verdict 表形 → gate3-check 读取面、Epic 文件名/ID 行 → cora-check slug 派生，两条数据流均已映射 |

**风险卡触发项核对结论**（canonical Gate 2「Risk card」行；Gate 2 修订 p2-y4-fix-1 补记，源 consistency P2-1 与 risk R1 同项）：六类触发项逐项核——删除（不命中：写集无删除动作，scratch 夹具用后删除不属项目数据）／密钥、公网、生产（不命中）／跨仓或跨席位写（不命中：写集全在本仓单仓内）／引入新连接器、MCP 或依赖（不命中）／不可逆动作（不命中：cora-check 改动有改前基线＋原件快照，见 §7.1 与 §8.4 回滚路径）／涉及金额（不命中）／对外动作（不命中）。结论：本 handoff 非高风险，不附风险卡。

**Gate 2 结果**: Round 1 双审已回——consistency FAIL（p0=2）、risk CONDITIONAL（p0=0）；设计修订（p2-y4-fix-1）已逐条处置（文末修订记录），待 conductor 派窄口复审；复审定稿前不交 Blake。本节状态以盘面 verdict 为准。

> **Process Gate 2 = dual reviews on disk** (P2 tax-cut). PASS ⇔ two independent artifacts under the evidence root (P0=0 or sanctioned). Do **not** write a dispatch lock that waits for a human chat string `/gate 2`.

---

## 📋 Handoff Checklist (Blake必读)

Blake在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 所有"强制问题回答（MQ）"都有证据
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 每个Phase的交付物和证据要求都清楚
- [ ] 改 `.tad/hooks/lib/cora-check.sh` 之前已读 `.tad/project-knowledge/patterns/shell-portability.md`（仓根 AGENTS.md 硬行）
- [ ] 确认可以独立使用本文档完成实现

❌ 如果任何部分不清楚，**立即返回Alex要求澄清**，不要开始实现。

---

## 1. Task Overview

### 1.1 What We're Building

把上一条链（EPIC-20261031 surplus-execute 运行时兼容修复）蒸馏出的四条知识候选，从「候选」锻造成框架的正式面，并把 Phase 1 Gate 4 留下的五条知识候选逐条分诊处置：

1. **候选 1（真跑副本执行不变量）**：泛化落入 `.tad/tasks/evidence-collection.md` 新节，并在 `.tad/tasks/gate-execution.md` 加一行指针。
2. **候选 2（fixture 禁自引用）**：泛化落入 evidence-collection 新节（fixture 契约），并在 `.tad/project-knowledge/patterns/ac-verification.md` 落一条 pattern。
3. **候选 3（裁定归一层模式）**：落 `.tad/project-knowledge/patterns/gate-design.md` 一条 pattern（双层模式全形）。
4. **候选 4（verdict 表形与机械校验器对齐）**：两面分治——(a) 生产面：`.tad/templates/review-contract.md` §5 钉死 verdict 落盘骨架（与 gate3-check.sh 同源）；(b) 校验面：`.tad/hooks/lib/cora-check.sh` 的 slug 派生加文件名回退，治 Phase 1 实测的 usage 退出（exit 2）。
5. **Phase 1 五候选分诊**：KC1＋KC4 合并落 handoff-design 一条；KC2 落 gate-design 一条；KC5 落 ac-verification 一条；KC3 转 Phase 4（只记账，不落文件）。
6. **AC7 梗概句改写**：按 K-7 先例给 Phase 1 HANDOFF 的 AC7 判据梗概句留勘误指针（不改原文），surplus SKILL 本体不动。

### 1.2 Why We're Building It

**业务价值**：四条候选都是已付过学费的实证（被测脚本自改本体、fixture 自引用、裁定矛盾穿行、校验器读不了 verdict 表形），只活在一条链的证据里就等于没学到；落进规程与 patterns 才会在下一条链自动装载。
**用户受益**：verdict 表形对齐后，Gate 3 的机械核验不再每链靠人工替代；cora-check 不再对合规 Epic 报 usage 假红。
**成功的样子**：六个 Step 全部落盘且 §9.1 逐行可机械复核；两个校验器对「合规样本／历史坏样本」的行为与基线逐项对得上；五候选无一悬空（落盘或显名转出）。

### 1.3 🆕 Intent Statement（意图声明）

**真正要解决的问题**：候选知识的「正式锻造」缺位——蒸馏报告写明候选不自签生效，本 Phase 就是那个生效面；同时修掉两个已实测的「产出形态 ≠ 校验器接口」错位（verdict 表形、Epic slug 派生）。

**不是要做的（避免误解）**：
- ❌ 不是重写 gate3-check.sh 的分类器（它是对的，坏的是生产面没钉骨架；分类器一行不改）
- ❌ 不是给 cora-check 加新子命令或改其 phase\<N\> 文件名约定（只补 slug 派生回退）
- ❌ 不是回改 Phase 1 的任何 verdict／COMPLETION／HANDOFF 原文（AC7 只加勘误节，原文哈希有基线为验）
- ❌ 不是手改 `.claude/` 投影（installer 携带面，一律不动）

**Blake请确认理解**：
```
在开始实现前，请用你自己的话回答：
1. 这个功能解决什么问题？
2. 用户会如何使用？
3. 成功的标准是什么？
```

### 1.4 卸载记录（Offload Log）

| 时间 | 卸载项 | 依据 | 原文指针 | 回取方式 |
|---|---|---|---|---|
| 2026-10-31 设计期 | 校验器行为基线三件（gate3-check 双样本、cora-check usage、条目计数、AC7 行哈希、骨架干跑） | §9.1 的 Verified Output 只引指针不贴全文 | `.tad/evidence/yolo/v409-basket/p2-baseline-checkers.txt`、`p2-baseline-forms.txt`、`p2-baseline-fixture-dryrun.txt` | Read 三件原文 |
| 2026-10-31 设计期 | 四候选的来源叙事（事件经过） | HANDOFF 只取其内容与落点建议，叙事不承重 | `.tad/evidence/yolo/EPIC-20261031-surplus-execute-runtime-compat/distillation-report.md` | Read 原文 |

### 1.5 Requirement (human's words)

Epic phase: EPIC-20261031-v409-basket.md 的 `## Phase Map` 中 **Phase 2 蒸馏批次** 行（「四候选落盘＋verdict 表形系统对齐。用户点数 0」），载体正本为 BASKET-4.0.9.md 第 2 行（「蒸馏批次（surplus 链四候选落 patterns＋verdict 表形对齐）」）。Epic 头部 Approved 行：用户 2026-10-31 09:13 定篮子方向、11:03 认规划切法、11:44「continue」开跑。本 Phase 覆盖的块：四候选落盘、verdict 表形系统对齐、Phase 1 Gate 4 五候选分诊、AC7 梗概改写（Phase 1 Gate 4 转入的 P3）。

**Pilot**: 本 Phase 无 ≥3 同构单元的 fan-out（六个 Step 形态互异），不设 pilot 单元；判据见 canonical Gate 2「Pilot declared」行（fan-out ≥3 同构单元时必填）——不适用。

---

## 📚 Project Knowledge（Blake 必读）

**已读取的 project-knowledge 文件**：

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| principles.md | 2 条承重 | 「Knowledge Is Forged at Distill, Not Captured」（本 Phase 即锻造面）；「Three Roles, Independent Judgment」（本设计不出 verdict） |
| patterns/gate-design.md | 2 条承重 | 2026-10-19 分类器条（一个分类器读所有表、闭世界分类）；2026-10-20 机器读表条（id 形态钉在模板里、设计期拿真 reader 干跑） |
| patterns/ac-verification.md | 标题面 | fixture 自证类条目多条（2026-08-10 自我认证矩阵、2026-08-12 自指锚点）——候选 2 与 KC5 的同族先例，落条时不重复其结论、只补自引用面 |
| patterns/memory-and-learning.md | 1 条承重 | K-7（2026-10-27）：已被证伪的断言句在原句位置留指针、不改原文——AC7 勘误的形态依据 |
| patterns/shell-portability.md | 改 shell 前必读 | cora-check.sh 头部自述纪律：macOS /bin/bash 3.2、BSD 工具、无 mapfile/assoc arrays、文件集用 find 列 |

**⚠️ Blake 必须注意的历史教训**：

1. **分类器只许一个，且不许放宽迁就生产面**（gate-design 2026-10-19）
   - 问题：校验器对读不了的表形放宽容忍，会把未跑的行读成已跑（presence check 化）。
   - 解决方案：候选 4 的修法在生产面钉骨架，不动 gate3-check.sh 分类器；cora-check 的回退只补「输入派生」不补「判定容忍」。

2. **机器读的表，形态必须钉在模板里并在设计期拿真 reader 干跑**（gate-design 2026-10-20）
   - 问题：模板例子与 reader 模式不一致时，第一发现点是 Gate 3 的 verdict 跑，代价是一轮 FAIL＋重判。
   - 解决方案：本设计已按此条干跑（p2-baseline-fixture-dryrun.txt：骨架形 exit 0、坏形 UNEXPLAINED）；Blake 落骨架后仍须按 AC10 复跑同一干跑对。

3. **被证伪的断言留指针不改原文**（memory-and-learning K-7）
   - 问题：回改历史件会让当时的判读链断裂（Gate 4 的裁定引用的就是原文）。
   - 解决方案：AC7 只在 Phase 1 HANDOFF 文末加勘误节；原 AC7 行的 sha256 基线（55ad5275…）写进 AC13，改一字即 FAIL。

### Blake 确认

- [ ] 我已阅读上述历史经验
- [ ] 我理解需要避免的问题
- [ ] 如遇到类似情况，我会参考上述解决方案

---

## 2. Background Context

### 2.1 Previous Work

- **候选 1/2 的 surplus 专属面已先行落字**（上一链）：`.tad/evidence/surplus-execute-fix-20261031/invocation-specs.md` 的 Copy-execution protocol 节（L144）与 Fixture contract 节（L173），及 `.agents/skills/surplus/SKILL.md` 的 Run integrity 条（L122）。本 Phase 落的是**通用面**（evidence-collection 规程＋patterns），专属面不回改。
- **候选 3 的实例已在盘**：surplus-execute 的 FR5 归一实现（AMEND2 §2.2 定版）是模式的实证实例；本 Phase 只锻造 pattern 条目，不动任何实现。
- **候选 4 的接口两侧现状**：review-contract §5（L68）已写明 run verdict 的两张表列名（AC runs 四列、Real paths 四列含 output pointer），但没有把骨架作为「逐字复制面」钉死，也没写分类器的列名承重规则；GATE3-code.md 曾用中文表头（「AC｜判定｜评审重算证据」）＋无 Real paths 节，gate3-check exit 1（EPIC-COMPLETION §5 显名）。Phase 1 的链按 contract 形态写 verdict 后 gate3-check exit 0（基线 B1）。
- **Phase 1 五候选出处**：`.tad/evidence/yolo/v409-basket/phase1-gate-report.md` 的 Knowledge candidates 1–5（下称 KC1–KC5），Gate 4 明示「转写与取舍归 conductor 收口步」、Epic 切法正对本 Phase 输入面。

### 2.2 Current State（全部为设计期实测，证据在 p2-baseline-*.txt）

| 面 | 现状 | 基线 |
|---|---|---|
| gate3-check.sh 对合规 verdict（Phase 1 p1-gate3-review-code.md） | exit 0，18 AC＋RP1–RP3 全 COVERED | checkers B1 |
| gate3-check.sh 对 GATE3-code.md（G4-F2 历史坏样本） | exit 1：AC1–AC9 全 `UNEXPLAINED … no result/status column`、RP1–RP3 MISSING | checkers B2 |
| cora-check.sh gate3-files 对本 Epic | exit 2（usage）——根因：本 Epic 无 `**Epic ID**:` 行，脚本 L223 的 sed 派生 slug 为空即 usage；模板 epic-template.md L3 本有该行，是本 Epic 成文时漏载 | checkers B3–B5 |
| cora-check.sh slug 派生点 | 两处同形 sed：L68（dispatches）、L223（gate3-files） | forms |
| patterns 条目计数（`### ` 标题） | gate-design 45、ac-verification 78、handoff-design 57 | forms |
| evidence-collection `## ` 节数 | 12（最新节为 Segmented Write Discipline，L464） | forms |
| surplus SKILL | Budget guard 条 L115–119、Ledger mode limit 条 L120、Run integrity 条 L122；throw 句 grep 计数 1 | forms |
| Phase 1 HANDOFF AC7 行（L608） | sha256 = 55ad5275b4e02d9ba00e9dcd53ee7b72b48cafceda6fe97be59e60d642bf3243；其判据梗概语「Budget guard 条正文止于 “…circuit-breaker semantics.”」与 SKILL 实际条文不符（条文实际止于 estimated 从句） | forms |
| 骨架干跑 | 按 §4.2 S4 骨架造的 fixture verdict 对 16-AC mini handoff 跑 gate3-check：exit 0；把 result 列名改作中文后 UNEXPLAINED（exit 1）——改字经 Gate 2 风险面实测钉死为「判定」（分类器接受「结果」作 status 别名，见 p2-gate2-review-risk.md P2-2；基线件原文只记「改中文名」未录字） | fixture-dryrun＋risk P2-2 |

### 2.3 Dependencies

- 无外部依赖。全部工具为仓内既有：bash、grep、awk、sed、sha256sum（仓内命令面实测可用）。
- `.tad/regression-samples/` 在盘（最新复跑 20261027-r4p4-replay，早于本 Phase 改动）——与 Gate 3 的关系见 §8.4。

---

## 3. Requirements

### 3.1 Functional Requirements

- FR1: 候选 1 泛化落入 evidence-collection 新节（真跑副本执行不变量：副本执行、哈希对账五行、MISMATCH 处置），gate-execution 加一行指针。
- FR2: 候选 2 泛化落入 evidence-collection 新节（fixture 契约三条）＋ac-verification 一条 pattern。
- FR3: 候选 3 落 gate-design 一条 pattern（双层模式：prompt 层填报缺失名单＋代码层确定性消费，缺一不可）。
- FR4: 候选 4a——review-contract §5 钉死 verdict 骨架（两张表表头逐字、Not run 行形、Blocked 用法、与 gate3-check 同源维护句）。
- FR5: 候选 4b——cora-check.sh 两处 slug 派生加文件名回退（`**Epic ID**` 行优先、缺失时从 `EPIC-<日期>-<slug>.md` 文件名派生），头部注释同步；行为对既有合规输入不变。
- FR6: Phase 1 五候选逐条分诊并按 §4.0 表落盘或记账：KC1＋KC4 → handoff-design 一条；KC2 → gate-design 一条；KC5 → ac-verification 一条；KC3 → 转 Phase 4 记账（决策表＋COMPLETION 携带行）。
- FR7: AC7 梗概改写以勘误节落 Phase 1 HANDOFF 文末（K-7 形态：原文不动、原行哈希不变、勘误写明正确口径与指针）。
- FR8: patterns/_index.md 三行钩子各追加本批新条目的关键词短语（只追加不改既有词）。

### 3.2 Non-Functional Requirements

- NFR1: 写集封闭——只许动 §7 点名文件；点名外的任何改动（含顺手修格式）即越界，Gate 3 按写集对账。
- NFR2: 新 pattern 条目须过 variabilize 检验（principles「Knowledge Is Forged at Distill」）：条目中的事件专属值（脚本名、行号、run id）只许出现在 Grounded in，正文写变量形。
- NFR3: cora-check.sh 改动须守其头部纪律（bash 3.2/BSD、无 mapfile/assoc arrays、不用 globstar），且对「带 `**Epic ID**` 行的 Epic」行为逐字不变（回退只在派生为空时触发）。
- NFR4: 全部新文本与仓内既有形态同构（pattern 条目七段形、规程节的既有叙述体、review-contract 的英文契约体），不引入新体例。

---

## 4. Technical Design

### 4.0 Decisions

| # | Decision | Lands in | Accepted by |
|---|---|---|---|
| D1 | 候选 1 落通用规程面：evidence-collection 新增节（泛化自 invocation-specs Copy-execution protocol，专属面不回改）；生效形态为规程清单（真跑/回放前置），**不做代码自检**——沿 invocation-specs 原注理由（脚本无法可靠自知规范路径，启发式自检会误伤合法维护行） | `.tad/tasks/evidence-collection.md` 新节＋`.tad/tasks/gate-execution.md` 一行指针 | AC1 / AC2 |
| D2 | 候选 2 落两面：evidence-collection 新增 Fixture Contract 节（契约三条＋跑前 grep 机械核查）＋ac-verification 一条 pattern（判据面）；surplus 专属契约（invocation-specs）不回改 | evidence-collection／ac-verification.md | AC3 / AC4 |
| D3 | 候选 3 只落 pattern（gate-design），不落代码、不落规程节：模式的实施面在被测系统内部（已由 FR5 实例在盘），框架侧能锻造的是判据知识 | gate-design.md | AC5 |
| D4 | 候选 4a 修生产面不修分类器：review-contract §5 加 Verdict skeleton 块——表头比现 contract 四列多一列 `output`（分类器按 header 名解析、多列忽略，对存量四列 verdict 向后兼容）；骨架块内明写分类器承重规则与「同源维护」句 | review-contract.md §5 | AC9 / AC10 |
| D5 | 候选 4b 修输入派生不修判定：cora-check.sh 两处 slug 派生（L68/L223）加文件名回退（basename 形 `EPIC-[0-9]{8}-<slug>.md` → slug）；`**Epic ID**` 行在盘时行为逐字不变；头部 Usage 注释加一句回退说明（「逐字不变」的机械验点＝AC17 的 ID 优先分歧夹具＋改前基线件 `p2-baseline-id-line-population.txt`，Gate 2 双面同根 P1 修订补入） | `.tad/hooks/lib/cora-check.sh` | AC11 / AC12 / AC17 |
| D6 | 本 Epic 链的 p{N}-\* 文件命名分歧（vs review-contract §Paths 的 phase{N}-\* 约定）**不改名、不复制双名件**（conductor 既裁，Phase 1 同案）；prospective 约定已在 §Paths 在盘、无须新文。cora-check 修复后对本 Epic 输出 MISSING phase{N}-\* 规范名是诚实输出不是缺陷——本 Phase 只在 §10.2 记账，不设 AC 逼它变绿 | §10.2 记账（无文件落点） | —（Gate 2 评审知悉项） |
| D7 | KC 分诊：KC1（基线前提回盘复核）与 KC4（git 依赖 oracle 在无 git 仓的结构性降级）**合并**为 handoff-design 一条（KC4 是 KC1 的 oracle 可达性子面，Gate 4 原文亦称「与候选 1 合并或作其子条，由蒸馏步定」——本设计定为合并子面）；KC2（替代认可权归 Gate 4）落 gate-design 一条；KC5（依赖后置人裁的 AC 行自带依赖声明与回退）落 ac-verification 一条；KC3（探针第二可观测面）**转 Phase 4 扫描面**——其落点是 workflow/探针设计面，与 Phase 4 的回放验面同域，本 Phase 只记账交接（本表＋COMPLETION 携带行），不落文件 | handoff-design／gate-design／ac-verification／记账 | AC7 / AC6 / AC8 / AC16 |
| D8 | AC7 梗概改写走 K-7 勘误形态：不改 Phase 1 HANDOFF 原文、不动 surplus SKILL（其现状已合 AC7 的 Expected Evidence 三项，Gate 4 已判 PASS）；在 Phase 1 HANDOFF 文末加勘误节写明正确口径。备选「回改 SKILL 的 Budget guard 条」被否：条文本身无误，错的是判据梗概语，回改条文是改错对象 | HANDOFF-20261031-small-fix-batch.md 文末勘误节 | AC13 |
| D9 | _index.md 三行钩子只追加短语（gate-design 行加 verdict normalization／copy-execution；ac-verification 行加 fixture self-reference；handoff-design 行加 baseline premise recheck），使 Blake 的关键词装载能命中新条目；既有钩子词一字不删 | patterns/_index.md | AC14 |
| D10 | 六个 Step 的实施序：S1/S2（evidence-collection 两节同文件，须串行同批落）→ S3（cora-check，独立）→ S4（骨架＋干跑，独立）→ S5（四条 pattern＋索引钩子）→ S6（勘误，最后做以便其引用的落点全部在盘）。同文件多步一律单写者串行，不并行编辑 | §6 | AC15（计数总账） |

**KC 分诊表（FR6 的全量对账面，Gate 3 按此表逐条核）**：

| 候选 | 内容一句话 | 分诊 | 落点／去向 | AC |
|---|---|---|---|---|
| KC1 | 定量基线与 oracle 命令须在设计时点逐项回盘复核 | 入本 Phase | handoff-design 新条目（与 KC4 合并） | AC7 |
| KC2 | 验证对象灭失时替代认可权归 Gate 4，实施方只许显名申报 | 入本 Phase | gate-design 新条目 | AC6 |
| KC3 | 探针类机制须有第二可观测面（本 harness workflow log() 不落盘） | 转 Phase 4 | 记账交接：本表＋COMPLETION 携带行，属主 conductor 于 Phase 4 grounding 转写 | AC16 |
| KC4 | git 依赖型 oracle 在文件夹制仓内是不可达非失败，须设计时先验可达性 | 入本 Phase（作 KC1 子面） | handoff-design 新条目内子节 | AC7 |
| KC5 | 依赖后置人裁的 AC 行应自带依赖声明与回退路径（AC14 正例） | 入本 Phase | ac-verification 新条目 | AC8 |

---

### 4.1 Architecture Overview

本 Phase 无系统架构，形态是「知识锻造＋接口对齐」：上游是两条已收口链的蒸馏产物（候选四条＋KC 五条），中游是六个互不重叠的落点面（规程两件、patterns 三件、契约一件、校验器一件、存量 handoff 一件），下游消费者分别是：真跑/回放执行者（evidence-collection 两节）、Gate 评审人（patterns 三件＋骨架）、conductor（cora-check）。每条数据流的「形态契约」由 §9.1 的机械 AC 守：写进去的形态必须被既有 reader（gate3-check 分类器、cora-check 派生、Blake 关键词装载）原样读出。

### 4.2 Component Specifications

#### S1 — 候选 1：evidence-collection 新增节＋gate-execution 指针

- **落点**：`.tad/tasks/evidence-collection.md` 文末（Segmented Write Discipline 节之后）新增节，标题逐字：`## Live-Run Copy Execution （真跑副本执行不变量）`。
- **内容规格**（泛化自 invocation-specs Copy-execution protocol 六条，事件专属值变量化）：
  1. 适用面：对「执行可能写回自身」的脚本/工作流做活体验证（Gate 回放、验收真跑）时，自始执行逐字副本，被测本体永不作执行入口。
  2. 副本规格：副本存于本链证据目录，命名含被测文件名与 run 标识；调用前副本 sha256 必须等于本体 sha256，不等即停、不许调用。
  3. run-record 必含五行：`copy_path`、`copy_sha256`、`original_sha256_before`、`original_sha256_after`、`original-integrity: MATCH | MISMATCH`（字段名逐字沿 invocation-specs 原形，这是既有在盘契约，不新造）。
  4. MISMATCH 处置：停一切后续运行；突变本体以 `.mutated-<run-id>` 后缀保全入证据目录；以副本复原本体并验 sha256 等于 before 值；报告后再议。
  5. 副本在验收后保留作运行证据，不删。
  6. 明示非代码化：本节是执行者规程，不给被测脚本加自检代码（理由沿 D1）。
- **指针**：`.tad/tasks/gate-execution.md` 的 Gate 3 mechanical parts 条（gate3-check.sh 那条）之后加恰一行：`- **Live-run copy execution**: 真跑/回放被测脚本时走副本执行＋哈希对账，规程见 `.tad/tasks/evidence-collection.md` 的 Live-Run Copy Execution 节。`（可按该文件既有英文体微调，但必须含 `Live-Run Copy Execution` 字面以便 AC2 机械核）。

#### S2 — 候选 2：evidence-collection 新增 Fixture Contract 节＋ac-verification 条目

- **落点甲**：`.tad/tasks/evidence-collection.md`，紧随 S1 新节之后新增节，标题逐字：`## Fixture Contract （夹具禁自引用）`。
- **内容规格**（泛化自 invocation-specs Fixture contract 三条）：
  1. 禁自引用：回放/真跑 fixture 行的 deliverable 与 target 不得引用被测对象本体、其产出面（报告文件、状态文件），或执行该行会写到的任何文件。
  2. 自命中处置：合成写入集命中被测对象自身路径的行属不合规，须在跑前重建模；若仍被运行，其唯一合规期望是 needs_you（路由人工），把它当普通行执行即验收 FAIL。
  3. 跑前机械核查：每次回放/真跑前以 grep 核查 fixture 集对被测对象文件名的引用为 0，核查动作与结果记入 run-record。
  4. 执行点是契约文本＋执行者跑前 grep，**不**在被测脚本内加自检代码（理由同 D1 的 invocation-specs 原注）。
- **落点乙**：ac-verification.md 新增 pattern 条目，标题逐字：`### A Fixture Row That References the Artifact Under Test Certifies the Run That Destroys It — Ban Self-Reference, Grep for It Before Every Run`，七段形齐（Source confidence / Selector / Context / Discovery / Action / failure_mode / Validator / Grounded in），Grounded in 指向 distillation-report 候选 2 与 invocation-specs Fixture contract 节。

#### S3 — 候选 4b：cora-check.sh slug 派生回退

- **落点**：`.tad/hooks/lib/cora-check.sh` 两处（L68 dispatches 内、L223 gate3-files 内；行号以基线为准，实施时以 `grep -n "Epic ID" cora-check.sh` 复核定位）。
- **改法规格**（两处同形改）：现行一行 `slug=$(sed -nE 's/^\*\*Epic ID\*\*:.../\1/p' "$epic" | head -1)` 之后，各加回退：当 slug 为空时，从 `$epic` 的 basename 派生——形如 `EPIC-[0-9]{8}-<slug>.md` 时取 `<slug>`。实现须守脚本纪律：只用 sed/case/parameter expansion 等 bash 3.2＋BSD 可用构造；回退逻辑两处一致（不抽函数亦可，但两处文本须同口径）。头部 Usage 注释（L8–39 区）加一句：slug 取自 Epic 的 `**Epic ID**` 行，缺失时回退 Epic 文件名。
- **不许动**：派生之后的全部判定逻辑（dir 构成、need 清单、latestof、exit 口径）、`**Epic ID**` 行在盘时的既有行为、phase\<N\> 文件名约定本身。
- **自验**（实施内含，证据落 `p2-cora-check-after.txt`）：① 对本 Epic 跑 gate3-files 2 → 不再 usage，输出 OK/MISSING 行；② 对本 Epic 跑 dispatches → 行为与改前同类（改前实测留 `p2-cora-check-before.txt`：两子命令各跑一次的输出与 exit）；③ scratch 夹具：临时目录造 `.tad/evidence/yolo/<slug>/phase2-gate3-verdict.md`＋一份无 `**Epic ID**` 行、文件名为 `EPIC-20261031-fixture-slug.md` 的 Epic，在该目录跑 gate3-files → exit 0 且 OK 行在输出（夹具用后删除，路径与输出记入 after 件）；⑤ **ID 优先分歧夹具**（Gate 2 修订新增，AC17 的实施面）：scratch 临时根内造 `.tad/active/epics/EPIC-20261031-fixture-name-slug.md`（内含 `**Epic ID**: EPIC-20261031-fixture-id-slug` 行——ID slug 与文件名 slug **故意不同**）＋`.tad/evidence/yolo/fixture-id-slug/` 下 `phase2-gate3-verdict.md` 与 `phase2-impl-review-consistency.md` 两件；**改脚本之前**先在该根内跑 gate3-files 2 与 dispatches 各一次、全量输出（含 exit）整件存 `p2-fixtures/id-fixture-before.txt`，改后同形复跑存 `p2-fixtures/id-fixture-after.txt`；两件须逐字一致、且 gate3-files 的 OK 行路径含 `fixture-id-slug`（证明 ID 行优先于文件名被真实执行——本仓 66 份存量 Epic 两派生全量一致，一致形夹具分不清「ID 优先」与「文件名优先」两种实现，改前总体基线见 `p2-baseline-id-line-population.txt`）。夹具根用后删除，两件输出的首行各记夹具根路径。

#### S4 — 候选 4a：review-contract §5 verdict 骨架

- **落点**：`.tad/templates/review-contract.md` §5（Lenses 节）内、run 条目全部段落之后（含其后的 citation spot-check 续段）、domain 条目之前，新增小节，标题逐字：`#### Verdict skeleton (the run reviewer's file, byte form)`。（Gate 2 风险面 R2 钉：不得插在 run 首段与续段之间劈开条目。）
- **骨架正文**（逐字落入，代码块形态；段间不留空行，紧缩形态共 12 行——使引用它的本合同自身守 handoff-creation-protocol 的 code_bound 单块 ≤15 行，Gate 2 一致性面 P0-1；分类器逐行读表，不依赖空行）：

~~~
## AC runs
| row | command | exit | result | output |
|---|---|---|---|---|
| AC1 | <command the reviewer ran> | <exit code> | pass / fail / not-run / blocked | <output pointer or excerpt> |
## Real paths
| id | what was run | output pointer | result |
|---|---|---|---|
| RP1 | <the run> | <path> | pass / fail / not-run / blocked |
## Not run
- <id> not-run: <reason>
## Blocked
- <id>: <the friction that blocks it>
~~~

- **同源规则句**（骨架后逐字落入，可按契约英文体成句，但四点语义不可少）：① 这副骨架就是 `.tad/hooks/lib/gate3-check.sh` 读取的契约面：status 列名只认 `result` 或 `status`，evidence 列名认含 `output`/`pointer`/`evidence`/`证据` 者、缺时回退 `exit` 列；② 骨架或分类器任一改动，另一必须同轮同改并在改动件中互引；③ run 评审人保存前必跑 gate3-check 并贴输出（现 §5 既有义务，此处重申指针）；④ 存量 verdict 的旧表形（四列 AC runs）在解析层继续被分类器按 header 名读取，不回改存量件；但四列形下 evidence 回退为 exit 列一格，exit 须写实值、不得以 `-` 或空占位（占位行会被判 run row without evidence，Gate 2 风险面 P2-1 实测）。
- **干跑复证**（实施内含）：按 AC10 的方法对**本 HANDOFF** 造骨架形 fixture（全部 AC 行＋RP1–RP3 全 not-run＋理由）跑 gate3-check 得 exit 0；再把骨架形 fixture 的 result 列名改作「判定」造坏形 fixture 得 exit 1 且输出含 `no result/status column`——坏形列名钉死为「判定」：分类器明文接受「结果」作 status 别名，用「结果」造坏形不坏（Gate 2 风险面 P2-2 实测）。两份 fixture 与输出存证据根 `p2-fixtures/`。

#### S5 — 四条 pattern＋索引钩子

- **P-A（候选 3）**→ gate-design.md，标题逐字：`### Route Every LLM Verdict Through a Deterministic Normalization Layer Before Any Deterministic Routing — the Prompt Layer Reports What Is Missing, the Code Layer Consumes the List`。内容承重四点：(i) 归一是纯函数层，介于 LLM 裁定与确定性路由之间；(ii) 「状态缺失」名单点名的维度按其限制值参与路由，放行值不得与缺失名单共存穿行；(iii) 正证据永不被归一强制改写，每次强制留痕进证据文本；(iv) 双层缺一不可（只有 prompt 层时矛盾记录合法穿行——上一链首轮实证；只有代码层时名单完整性无来源）。正文字面钉死（Gate 2 一致性面 P1-2，与 P-C 钉 `Oracle reachability` 同口径，供 AC5 机械核）：条目内须含子标题行 `#### Missing-state semantics`，且 (ii) 的正文表述须逐字含英文短语 `the missing-state list`——两处 `missing` 字面是 AC5 第二值的判读所系，不得只写中文「状态缺失名单」。Grounded in 指向 distillation-report 候选 3 与 AMEND2 §2.2。
- **P-B（KC2）**→ gate-design.md，标题逐字：`### When the Verification Object Is Partly Destroyed, Only the Acceptor May Recognise a Substitute — the Implementer Declares It, and No Later Record May Rewrite It as a Literal Pass`。内容承重三点：(i) 实施方只许显名申报替代方案与证据，不得自判满足；(ii) 认可权在 Gate 4 验收人，裁定须具名留痕并写明替代的证据面；(iii) 以替代形态记满足的行，禁止在任何后续记账中改写为「按原文义 PASS」——本点正文须逐字含英文句 `never rewrite it as a literal pass`（AC6 第二值的判读所系，Gate 2 一致性面 P1-2）。Grounded in 指向 phase1-gate-report 裁定 2 与其 Knowledge candidate 2。
- **P-C（KC1＋KC4 合并）**→ handoff-design.md，标题逐字：`### Re-Verify Every Load-Bearing Baseline Premise on Disk at Design Time — Including Whether the Oracle Can Run in This Environment at All`。正文含 KC4 子节（小标题行含 `Oracle reachability` 字面）：git 依赖型 oracle 在无 git 的文件夹制仓内是结构性不可达、其失败行形态与真缺陷相似，设计时须先验 oracle 在目标环境的可达性；主面承重两例：计数/缺失断言类基线（「未装为 skill」与盘面不符）、oracle 命令类基线（salvage 的 git 依赖）。Grounded in 指向 phase1-gate-report 的 gate4_delta 三条与 Knowledge candidates 1、4。
- **P-D（KC5）**→ ac-verification.md，标题逐字：`### An AC Row That Waits on a Later Ruling Must Carry Its Own Dependency Declaration and Fallback — Silence About the Dependency Makes the Row Unjudgeable`。内容承重两点：(i) 依赖后置人裁/外部条件的 AC 行，行内自带依赖声明（等谁、等什么）与回退路径（不裁时按何形态收口）；(ii) 正例：Phase 1 的 AC14 行自带「AC 不自判」＋票面指针，验收无须猜测其满足形态。Grounded in 指向 phase1-gate-report Knowledge candidate 5。
- **四条共同形态**：七段形齐（Source confidence / Selector / Context / Discovery / Action / failure_mode / Validator / Grounded in）；正文变量化（事件专属名只进 Grounded in）；落位为各文件文末追加（与该文件既有条目同序：文末最新）。
- **索引钩子**（D9）：`patterns/_index.md` 三行各在既有钩子串尾追加：gate-design 行加 `verdict normalization layer, substitute recognition`；ac-verification 行加 `fixture self-reference`；handoff-design 行加 `baseline premise recheck, oracle reachability`（措辞可按行文微调，须含 `normalization`、`self-reference`、`baseline premise` 三个可 grep 词根）。

#### S6 — AC7 勘误（Phase 1 HANDOFF）

- **落点**：`.tad/active/handoffs/HANDOFF-20261031-small-fix-batch.md` 文末（Gate Rounds 表之后）追加一节，标题逐字：`## 勘误 — AC7 梗概句（2026-10-31，EPIC-20261031 Phase 2 蒸馏批）`。
- **勘误正文须含四点**（成文可简，但四点语义不可少）：① §9.1 AC7 行的判据梗概语「Budget guard 条正文止于 “…circuit-breaker semantics.”」与条文实际不符——`.agents/skills/surplus/SKILL.md` 的 Budget guard 条（L115–119）正文实际止于 “…and marks totals estimated with `(ledger est.)` when any charge was an estimate.”；② 误差来源：梗概语把条内中段短语误作条尾，源裁定 AMEND2-20261031-gate3.md §6 第 12 项 (i) 从未作此主张，其增句对象只有 throw 句；③ 不影响面：AC7 的承重判据是其 Expected Evidence 三项（三项已达成），Gate 4 裁定与 AC7 PASS 不变，本勘误只正梗概语、不动任何结论；④ 本节为 K-7 形态留置：原文一字未改，原 AC7 行 sha256 仍为 55ad5275b4e02d9ba00e9dcd53ee7b72b48cafceda6fe97be59e60d642bf3243。

### 4.3 Data Models

无数据模型。形态契约两件已在 §4.2 S3/S4 逐字给定（slug 派生规则、verdict 骨架），即本 Phase 的「数据模型」。

### 4.4 API Specifications

N/A（无 API）。

### 4.5 User Interface Requirements

N/A（无 UI）。

---

## 5. 🆕 强制问题回答（Evidence Required）

### MQ1: 历史代码搜索

**问题**：用户是否提到"之前的"、"原来的"、"我们的方案"？

**回答**：
- [x] 是 → 本 Phase 整体就是对上一链蒸馏产物的锻造，全部落点先查既有面再决定新写/追加。

#### 搜索证据
```bash
# 既有落点核查（设计期实跑）
grep -n "Copy-execution protocol\|Fixture contract" .tad/evidence/surplus-execute-fix-20261031/invocation-specs.md   # L144 / L173 在盘
grep -n "Run integrity" .agents/skills/surplus/SKILL.md                                                              # L122 在盘
grep -n "AC runs\|Real paths" .tad/templates/review-contract.md                                                      # §5 L68 已写列名、无骨架块
grep -rn "circuit-breaker semantics" .agents/skills/surplus/ .tad/tasks/ .tad/gates/ .tad/project-knowledge/          # 仅 SKILL L118 一处（条文内部）
```

#### 决策说明
- **找到了什么**：候选 1/2 的专属面已在盘（invocation-specs 两节＋surplus SKILL 一条）；候选 4 的列名约定已在 review-contract §5 以散文在盘；patterns 三件文件内无同题条目（标题面检索无命中）。
- **决定**：✅ 复用——新节/新条目一律是对既有正本的泛化与指针，不另起平行文本；骨架块是对 §5 散文的逐字化，不新造表形。

### MQ2: 函数存在性验证

**问题**：设计中调用了哪些函数/机制？它们都存在吗？

| 机制 | 文件位置 | 行号 | 验证 |
|------|---------|------|------|
| gate3-check.sh 状态分类器（status 列名认 result/status；evidence 列名认 output/pointer/evidence/证据、回退 exit） | `.tad/hooks/lib/gate3-check.sh` | 头部 L24 注释＋分类实现 L130 附近 | ✅ 设计期实读＋双样本实跑（B1 exit 0／B2 exit 1） |
| cora-check.sh slug 派生（dispatches） | `.tad/hooks/lib/cora-check.sh` | L68 | ✅ grep 实证（forms 基线） |
| cora-check.sh slug 派生（gate3-files） | `.tad/hooks/lib/cora-check.sh` | L223 | ✅ grep 实证＋usage 复现（B3） |
| cora-check.sh latestof / cmd_gate3files 的 need 清单 | `.tad/hooks/lib/cora-check.sh` | L213–243 | ✅ 实读全文（本设计 D5/D6 据此） |
| epic-template 的 `**Epic ID**` 行 | `.tad/templates/epic-template.md` | L3 | ✅ grep 实证（B4） |

### MQ3: 数据流完整性

**问题**：本 Phase 的「数据流」是两条形态契约流，逐条对照：

| 生产面 | 形态 | 消费面 | 契约是否对齐 | 不对齐处置 |
|--------|------|--------|------------|-----------|
| Gate 3 run 评审人的 verdict 文件 | `## AC runs` / `## Real paths` 表＋`## Not run` 行 | gate3-check.sh 分类器 | ⚠️ 部分：contract 散文已写列名，但无逐字骨架，GATE3-code.md 曾漂移成中文表头致 exit 1 | S4 钉骨架＋同源规则句（AC9/AC10） |
| Epic 文件 | `**Epic ID**:` 行或文件名 `EPIC-<日期>-<slug>.md` | cora-check.sh slug 派生（L68/L223） | ⚠️ 部分：派生只认 ID 行，本 Epic 漏载该行即 usage 假红 | S3 加文件名回退（AC11/AC12） |
| 新 pattern 条目 | 关键词（标题与正文） | Blake 的 `_index.md` 关键词装载 | ⚠️ 索引钩子未含新题词 | S5 追加三行钩子（AC14） |

### MQ4: 视觉层级

**回答**：
- [x] 无不同状态 → 跳过（无 UI；文档形态的区分由标题与节名承担，已在 §4.2 逐字钉死）。

### MQ5: 状态同步

**回答**：本 Phase 的产物各自只有一个正本，无多处状态：规程节正本在 evidence-collection、骨架正本在 review-contract、派生逻辑正本在 cora-check.sh、勘误的被指原文在 Phase 1 HANDOFF（只追加不改）。唯一「同步」关系是 `.claude/skills/` 投影对 `.agents/skills/` 的镜像——本 Phase 不动任何 skill 文件，无同步面。

---

## 6. Implementation Steps（分Phase）

> 本 Phase 的实施步即 §4.0 D10 的六个 Step（下称 S1–S6，与 §4.2 组件号一致）。每步完成后按其验证方法自跑并留输出，全部输出落证据根 `.tad/evidence/yolo/v409-basket/`。

| # | File | Operation | Verification Command | Est. Time |
|---|------|-----------|---------------------|-----------|
| 1 | `.tad/tasks/evidence-collection.md` | 文末新增 Live-Run Copy Execution 节（S1 规格） | §9.1 AC1 的 awk＋grep 组合 | 25 min |
| 2 | `.tad/tasks/gate-execution.md` | Gate 3 mechanical parts 后加一行指针 | §9.1 AC2 | 5 min |
| 3 | `.tad/tasks/evidence-collection.md` | 紧随新节新增 Fixture Contract 节（S2 规格） | §9.1 AC3 | 20 min |
| 4 | `.tad/hooks/lib/cora-check.sh` | 先 cp 原件快照（§7.1 的 p2-cora-check.sh.orig，验 sha256 与基线一致）并存 before 基线（两子命令输出＋⑤ 分歧夹具改前输出整件），再改两处 slug 派生＋头部注释，跑 S3 自验（①②③⑤）存 after 件 | §9.1 AC11 / AC12 / AC17 | 45 min |
| 5 | `.tad/templates/review-contract.md` | §5 run lens 段后加 Verdict skeleton 小节（骨架逐字＋同源规则句） | §9.1 AC9 | 20 min |
| 6 | `.tad/evidence/yolo/v409-basket/p2-fixtures/`（新） | 造骨架形＋坏形两份 fixture verdict，对本 HANDOFF 跑 gate3-check 两遍存输出 | §9.1 AC10 | 20 min |
| 7 | `.tad/project-knowledge/patterns/gate-design.md` | 文末追加 P-A、P-B 两条（S5 规格） | §9.1 AC5 / AC6 | 40 min |
| 8 | `.tad/project-knowledge/patterns/handoff-design.md` | 文末追加 P-C 一条（含 Oracle reachability 子节） | §9.1 AC7 | 25 min |
| 9 | `.tad/project-knowledge/patterns/ac-verification.md` | 文末追加 S2 落点乙条目＋P-D 一条 | §9.1 AC4 / AC8 | 40 min |
| 10 | `.tad/project-knowledge/patterns/_index.md` | 三行钩子各追加短语 | §9.1 AC14 | 10 min |
| 11 | `.tad/active/handoffs/HANDOFF-20261031-small-fix-batch.md` | 文末追加 AC7 勘误节（原文一字不动） | §9.1 AC13 | 15 min |
| 12 | 全写集 | 计数总账复核＋COMPLETION（含 KC 分诊表复述与 KC3 携带行） | §9.1 AC15 / AC16 | 20 min |

### Real-path 场景走查（front matter real_paths 的展开）

- **RP1（→ S4 的 Gate 3 形态）**：Gate 3 的 run 评审人即 RP1 的执行者——它按新骨架写自己的 verdict、保存前跑 gate3-check 并把输出贴进 verdict（contract §5 既有义务）。本 Phase 实施期内由 Blake 以 AC10 的 fixture 干跑先行证明骨架可读；RP1 的正式执行在 Gate 3 步。
- **RP2（→ S3 的验收形态）**：Gate 4 前由 acceptor 执行 §4.2 S3 自验 ①③ 的同形复跑（真 Epic＋scratch 夹具），输出存 `.tad/evidence/yolo/v409-basket/phase2-gate4/`；实施期 Blake 已跑同形自验存 `p2-cora-check-after.txt`，acceptor 复跑对账。
- **RP3（→ S5 的读者形态）**：Gate 4 acceptor 以读者身份只读新落的 S1/S2 两节与 P-A 条目，答三问：(i) 真跑一个可自写回脚本前要做哪三件事？(ii) fixture 行的 deliverable 指向被测脚本的报告文件，合规期望是什么、跑前要做什么核查？(iii) LLM 裁定里某维度被报「状态缺失」时哪一层负责把它按限制值送进路由、另一层负责什么？答案只许出自新落文本；答不出即该条目未过 variabilize/可读面，记 Gate 4 finding。

#### 验证方法（每步）
- 每步的验证方法即其 §9.1 对应行，Blake 逐步实跑并把原始输出存证据根（文件名在 COMPLETION 中逐行指明）。

---

## 7. File Structure

### 7.1 Files to Create
```
.tad/evidence/yolo/v409-basket/p2-cora-check.sh.orig      # S3 改前原件快照（cora-check.sh 逐字副本，cp 后 sha256 须 = 3985e5c9d0bf254fe24afba195e2d04ee6abfb8fb672c6bfb95288decee62504；§8.4 回滚的字节载体，Gate 2 风险面 P1-2 修订补入）
.tad/evidence/yolo/v409-basket/p2-cora-check-before.txt   # S3 改前基线（两子命令输出＋exit）
.tad/evidence/yolo/v409-basket/p2-cora-check-after.txt    # S3 改后自验输出（①②③⑤）
.tad/evidence/yolo/v409-basket/p2-fixtures/               # S4/AC10 两份 fixture verdict 与两份 gate3-check 输出；另含 S3 ⑤ 的 id-fixture-before.txt / id-fixture-after.txt
.tad/active/handoffs/COMPLETION-20261031-distill-batch.md # Blake 收口件（既有链命名口径）
```

### 7.2 Files to Modify
```
.tad/tasks/evidence-collection.md                                  # 新增两节（S1、S2）
.tad/tasks/gate-execution.md                                       # 加一行指针（S1）
.tad/hooks/lib/cora-check.sh                                       # 两处 slug 派生回退＋头部注释一句（S3）
.tad/templates/review-contract.md                                  # §5 新增 Verdict skeleton 小节（S4）
.tad/project-knowledge/patterns/gate-design.md                     # 追加 P-A、P-B（S5）
.tad/project-knowledge/patterns/handoff-design.md                  # 追加 P-C（S5）
.tad/project-knowledge/patterns/ac-verification.md                 # 追加 S2 落点乙、P-D（S5）
.tad/project-knowledge/patterns/_index.md                          # 三行钩子追加（S5）
.tad/active/handoffs/HANDOFF-20261031-small-fix-batch.md           # 文末追加勘误节（S6，原文不动）
```

### 7.3 Grounded Against (Alex step1c)

- `.tad/tasks/evidence-collection.md`（head 50＋节标题全量；文末 Segmented Write Discipline 节实读，read at 2026-10-31）
- `.tad/tasks/gate-execution.md`（head 50＋Gate Execution Protocol 全段实读）
- `.tad/hooks/lib/cora-check.sh`（head 60＋L205–252 实读；两处 sed 行 grep 定位）
- `.tad/hooks/lib/gate3-check.sh`（head 80 实读，分类器规则据其头部注释与 L130）
- `.tad/templates/review-contract.md`（§5/§Paths grep＋L63–99 实读）
- `.tad/templates/epic-template.md`（L3 grep 实证）
- `.agents/skills/surplus/SKILL.md`（L107–125 实读）
- `.tad/active/handoffs/HANDOFF-20261031-small-fix-batch.md`（head 60＋AC7 行与 D5 行 grep，AC7 行 sha256 已录基线）
- `.tad/project-knowledge/patterns/gate-design.md`（L376–406 两条实读＋条目计数）
- `.tad/active/handoffs/COMPLETION-20261031-distill-batch.md` — (new — will be created)
- `.tad/evidence/yolo/v409-basket/p2-cora-check-before.txt` 等三件证据 — (new — will be created)

---

## 8. Testing Requirements

### 8.1 Unit Tests
- 本 Phase 无代码单元测试面；「测试」即 §9.1 的机械核验与两处校验器干跑（AC10/AC11/AC12）。cora-check.sh 无既有测试套件，其回归面由 S3 的 before/after 对照承担（同输入同子命令，改前改后各存一份）。

### 8.2 Integration Tests
- AC10（骨架形/坏形 fixture 对 gate3-check 的双向干跑）即生产面×校验面的集成验证。
- AC11（cora-check 对真 Epic＋scratch 夹具的双跑）即派生面×文件面的集成验证。

### 8.3 Edge Cases
- cora-check 回退的边界：Epic 文件名不合 `EPIC-<日期>-<slug>.md` 形且无 ID 行时，仍应 usage/派生失败（回退不得把任意文件名都派生出 slug）——Blake 在 S3 自验③的夹具之外，再以本 Epic 的一个改名副本（scratch，`FOO.md`）跑一次 gate3-files，期望仍 exit 2，结果记入 after 件第 ④ 项。
- 骨架对存量四列 verdict 的兼容：分类器按 header 名解析，存量件不回改；AC10 的坏形 fixture 只改列名不改列序，证明读失败来自列名契约而非列序。

## 8.4 Friction Preflight

| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|---|---|---|---|---|
| 写集命中 `.tad/tasks/**` 与 `.tad/templates/**`，触发 gate-execution 的 Regression Replay 条：Gate 3 须引用最近一次复跑 scores（须基于含被审改动的树） | Gate 3 评审前在含本 Phase 改动的树上复跑 `.tad/scripts/regression-replay.sh` 并引用 scores.md | 评审人按 gate-execution 原文执行复跑（最新在盘基线 20261027-r4p4-replay 早于本改动，不合「含被审改动」） | 无等价替代；复跑基础设施不可用时评审记 not-run＋理由并上报 conductor 裁断（原文：整轮非 PASS 时 Gate 3 不得 PASS，除非 PM 裁断记录在案） | 未处置时 Gate 3 不得径直 PASS |
| 改 shell 文件前置：`.tad/hooks/**` 下 shell 编辑前必读 shell-portability pattern | Blake 在 S3 动工前 Read `.tad/project-knowledge/patterns/shell-portability.md` 并在 COMPLETION 记一行已读 | 按 pattern 既有纪律执行 | 无 | 未读者 Gate 3 记 finding |
| cora-check.sh 是发版携带的校验器，改坏会污染后续所有链的 conductor 检查 | S3 先 cp 原件快照（§7.1 的 p2-cora-check.sh.orig）并存 before 基线、改后跑 after 自验＋AC12/AC17 兼容检查 | 任一自验不合即回滚该文件至改前：以 §7.1 的原件快照件覆盖回 `.tad/hooks/lib/cora-check.sh` 并验 sha256 等于基线值 3985e5c9…（快照即字节载体；哈希只作对账、不作载体——Gate 2 风险面 P1-2） | 无 | 自验未过即本 Phase 不得报完成 |
| Phase 1 HANDOFF 在 Epic 收口前仍属 active 件，S6 追加勘误与「不回改历史件」纪律的边界 | 只准文末追加一节、原行哈希以 AC13 守 | 追加前先 sha256 全文件存 COMPLETION 证据，追加后复核 AC7 行哈希不变 | 无 | 原文任一字节变动即 AC13 FAIL、Phase 不得 PASS |

**Status Enum** (use exactly these values in Friction Status table at completion):
`READY` / `BLOCKED` / `DEGRADED_WITH_APPROVAL` / `EQUIVALENT_SUBSTITUTE` / `NOT_APPLICABLE_WITH_REASON`

## 8.5 Feedback Collection (Non-Code Artifacts)

N/A（本 Phase 产物为框架规程与知识条目，质量由 Gate 3/Gate 4 的机械核验与 RP3 读者走查承担，不走 feedback 通道）。

---

## 9. Acceptance Criteria

Blake的实现被认为完成，当且仅当：
- [ ] §9.1 全部 17 行按其 Verification Method 实跑且合 Expected Evidence
- [ ] 写集与 §7 逐件对应，无点名外改动（AC15 计数总账为其机械面）
- [ ] KC 五条按 §4.0 分诊表全量对账（AC16），KC3 的交接在 COMPLETION 中显名携带
- [ ] Gate 4 acceptor (AI, took no part) accepts by real use（RP1–RP3 按 §6 走查面执行）

---

## 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE — Gate 3 executes each row

> 方法文法：command｜path-check｜fixture｜rubric-spawn｜light-tier N/A；纯散文非法。计数类 AC 的计数对象在方法文中写明。基线值全部来自设计期实测三件（p2-baseline-checkers.txt／p2-baseline-forms.txt／p2-baseline-fixture-dryrun.txt），post-impl 行在未改树上应以「基线形态」失败（计数为 0 或节不存在），这是其非空洞性的证明。

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| AC1 | 候选 1 落盘（D1）：evidence-collection 新增 `## Live-Run Copy Execution （真跑副本执行不变量）` 节，含副本执行、五行对账字段、MISMATCH 处置全规格 | post-impl-verifiable | `awk '/^## Live-Run Copy Execution/{f=1;next} /^## /{f=0} f' .tad/tasks/evidence-collection.md > /tmp/p2-ac1.txt; wc -l < /tmp/p2-ac1.txt; grep -c 'copy_path' /tmp/p2-ac1.txt; grep -c 'original_sha256_before' /tmp/p2-ac1.txt; grep -c 'MISMATCH' /tmp/p2-ac1.txt; grep -c 'mutated' /tmp/p2-ac1.txt` | 节非空（行数 ≥15）；四计数依次 ≥1／≥1／≥2／≥1 | 基线：标题 grep 计数 =0、节不存在（forms 基线：`## ` 节数 12） |
| AC2 | gate-execution 指针行（D1）：Gate 3 mechanical parts 区含指向新节的一行 | pre-impl-verifiable | `grep -c 'Live-Run Copy Execution' .tad/tasks/gate-execution.md` | =1 | 基线已录：0 |
| AC3 | 候选 2 规程面（D2）：evidence-collection 新增 `## Fixture Contract （夹具禁自引用）` 节，含禁自引用、needs_you 唯一合规期望、跑前 grep 核查三条 | post-impl-verifiable | `awk '/^## Fixture Contract/{f=1;next} /^## /{f=0} f' .tad/tasks/evidence-collection.md > /tmp/p2-ac3.txt; wc -l < /tmp/p2-ac3.txt; grep -c 'needs_you' /tmp/p2-ac3.txt; grep -c 'grep' /tmp/p2-ac3.txt` | 节非空（行数 ≥10）；两计数各 ≥1 | 基线：`Fixture Contract` 在 evidence-collection 计数 =0（invocation-specs 的同名节不在本文件） |
| AC4 | 候选 2 判据面（D2）：ac-verification 新增自引用 pattern 条目（标题逐字见 §4.2 S2 落点乙） | pre-impl-verifiable | `grep -cF 'Ban Self-Reference, Grep for It Before Every Run' .tad/project-knowledge/patterns/ac-verification.md` | =1 | 基线已录：0 |
| AC5 | 候选 3 落盘（D3）：gate-design 新增归一层 pattern 条目（标题逐字见 §4.2 S5 P-A），正文含缺失名单语义 | post-impl-verifiable | `grep -cF 'Deterministic Normalization Layer' .tad/project-knowledge/patterns/gate-design.md; awk '/Deterministic Normalization Layer/{f=1;next} /^### /{f=0} f' .tad/project-knowledge/patterns/gate-design.md \| grep -ci 'missing'` | 两值依次 =1／≥2 | 基线：标题计数 =0（forms 基线条目数 45） |
| AC6 | KC2 落盘（D7）：gate-design 新增替代认可权 pattern 条目（标题逐字见 §4.2 S5 P-B），正文含「不得改写为原文义 PASS」语义 | post-impl-verifiable | `grep -cF 'Only the Acceptor May Recognise a Substitute' .tad/project-knowledge/patterns/gate-design.md; awk '/Only the Acceptor May Recognise/{f=1;next} /^### /{f=0} f' .tad/project-knowledge/patterns/gate-design.md \| grep -ci 'literal pass'` | 两值依次 =1／≥1 | 基线：标题计数 =0 |
| AC7 | KC1＋KC4 落盘（D7）：handoff-design 新增基线复核 pattern 条目（标题逐字见 §4.2 S5 P-C），含 Oracle reachability 子节 | post-impl-verifiable | `grep -cF 'Re-Verify Every Load-Bearing Baseline Premise' .tad/project-knowledge/patterns/handoff-design.md; grep -c 'Oracle reachability' .tad/project-knowledge/patterns/handoff-design.md` | 两值依次 =1／≥1 | 基线：两计数 =0（条目数 57） |
| AC8 | KC5 落盘（D7）：ac-verification 新增依赖声明 pattern 条目（标题逐字见 §4.2 S5 P-D） | pre-impl-verifiable | `grep -cF 'Must Carry Its Own Dependency Declaration and Fallback' .tad/project-knowledge/patterns/ac-verification.md` | =1 | 基线已录：0 |
| AC9 | 候选 4a 落盘（D4）：review-contract §5 新增 Verdict skeleton 小节，骨架四形态逐字在盘（计数作用域＝骨架小节内） | pre-impl-verifiable | `awk '/^#### Verdict skeleton/{f=1;next} /^#### \|^### \|^- \*\*/{f=0} f' .tad/templates/review-contract.md > /tmp/p2-ac9.txt; grep -cF 'Verdict skeleton' .tad/templates/review-contract.md; grep -cF '\| row \| command \| exit \| result \| output \|' /tmp/p2-ac9.txt; grep -cF '\| id \| what was run \| output pointer \| result \|' /tmp/p2-ac9.txt; grep -cF -- '- <id> not-run: <reason>' /tmp/p2-ac9.txt` | 四计数各 =1（后三值在骨架小节内计数：骨架块本体逐字含两表头与 Not run 行形，漏落骨架内任一形态即该值 =0） | 基线（修订 p2-y4-fix-1 实跑）：四计数 =0／0／0／0（小节不存在）。旧法全文件计数实跑为 0／0／1／1——第 3、4 串已在 §5 run 段散文与 §6 在盘，全文件计数对骨架漏落无判别力（Gate 2 一致性面 P0-2），故本行改节内计数 |
| AC10 | 骨架可读性双向干跑（D4）：骨架形 fixture 对本 HANDOFF 跑 gate3-check 得 exit 0；坏形（result 列名改作「判定」）得 exit 1 且含分类器原话 | fixture | `bash .tad/hooks/lib/gate3-check.sh .tad/active/handoffs/HANDOFF-20261031-distill-batch.md .tad/evidence/yolo/v409-basket/p2-fixtures/verdict-skeleton-form.md > .tad/evidence/yolo/v409-basket/p2-fixtures/gate3-check-skeleton.out; echo $?; bash .tad/hooks/lib/gate3-check.sh .tad/active/handoffs/HANDOFF-20261031-distill-batch.md .tad/evidence/yolo/v409-basket/p2-fixtures/verdict-bad-form.md > .tad/evidence/yolo/v409-basket/p2-fixtures/gate3-check-badform.out; echo $?; grep -c 'no result/status column' .tad/evidence/yolo/v409-basket/p2-fixtures/gate3-check-badform.out` | 两 exit 依次 0／1；第三值 ≥1。fixture 规格：骨架形含本 HANDOFF 全部 17 AC 与 RP1–RP3 的 not-run 行＋`## Not run` 理由行；坏形只改 AC runs 表的 result 列名为「判定」（分类器接受「结果」为 status 别名，用「结果」造坏形不坏——Gate 2 风险面 P2-2） | 设计期已以同形 fixture 对 mini handoff 干跑成立（exit 0／UNEXPLAINED，见 fixture-dryrun 基线；基线件未录坏形所改之字，修订时经风险面实测钉死为「判定」）；本行在真 HANDOFF 上的复跑为 post 形态 |
| AC11 | 候选 4b 行为（D5）：cora-check gate3-files 对本 Epic 不再 usage；scratch 夹具（无 ID 行、文件名派生）得 exit 0 | post-impl-verifiable | `bash .tad/hooks/lib/cora-check.sh gate3-files .tad/active/epics/EPIC-20261031-v409-basket.md 2 > /tmp/p2-ac11.out 2>&1; echo $?; grep -c 'Usage:' /tmp/p2-ac11.out; grep -c 'MISSING\|OK ' /tmp/p2-ac11.out; grep -c 'exit=0' .tad/evidence/yolo/v409-basket/p2-cora-check-after.txt` | 四值依次：exit ∈{0,1}（预期 1，MISSING phase2-\* 规范名，D6 分歧的诚实输出）／0／≥1／≥1（after 件含 S3 自验③夹具 exit=0 记录） | 基线：同命令 exit=2 且输出整行 Usage（checkers B3）；before 基线由 Blake 在改前存 p2-cora-check-before.txt |
| AC12 | cora-check 兼容与完整（D5/NFR3）：语法合、脚本纪律不破、两处原派生 sed 逐字未动 | post-impl-verifiable | `bash -n .tad/hooks/lib/cora-check.sh; echo $?; grep -vE '^[[:space:]]*#' .tad/hooks/lib/cora-check.sh \| grep -c 'mapfile\|declare -A'; grep -cF 'EPIC-[0-9]{8}-([A-Za-z0-9_-]+)' .tad/hooks/lib/cora-check.sh` | 三值依次 =0／=0／=2（第三值＝两处原派生 sed 的捕获组形态计数：回退只许加在派生行之后、原 sed 一字不许动；「带 ID 行行为不变」的行为面验点在 AC17，本行只守派生原形与脚本纪律） | 基线（修订 p2-y4-fix-1 实跑）：三值 =0／0／2。旧第三条为同文件自比 diff、构造恒真（Gate 2 一致性面 P1-1），已换为派生原形计数 |
| AC13 | AC7 勘误（D8）：Phase 1 HANDOFF 文末勘误节在盘、原 AC7 行字节不变、勘误节之前全部字节不变、surplus SKILL 未动 | post-impl-verifiable | `grep -c '## 勘误 — AC7 梗概句' .tad/active/handoffs/HANDOFF-20261031-small-fix-batch.md; grep 'G4-F3 落位（D5）' .tad/active/handoffs/HANDOFF-20261031-small-fix-batch.md \| sha256sum; grep -c 'ledger mode does not support nested workflow' .agents/skills/surplus/SKILL.md; awk '/^## 勘误 — AC7 梗概句/{exit} {print}' .tad/active/handoffs/HANDOFF-20261031-small-fix-batch.md \| sha256sum` | 四值依次 =1／`55ad5275b4e02d9ba00e9dcd53ee7b72b48cafceda6fe97be59e60d642bf3243`／=1／`37efc9fa86472c6a6eeb03fca9113038ff2cecaf0f1a2e96ee70209e34aaf5fb`（第四值＝前缀守卫：勘误节之前全部字节的哈希须等于改前全文件哈希——追加只许发生在文末，文件其余字节任一改动即此值不合，Gate 2 风险面 P2-3） | 基线：勘误节计数 =0；AC7 行哈希即左值（forms 基线）；SKILL 计数 =1；改前全文件 84,938 B、sha256 =37efc9fa…（修订 p2-y4-fix-1 实测，前缀法对现文件已验等值；§8.4 末行的全文件哈希存 COMPLETION 与此互为双保险） |
| AC14 | 索引钩子（D9）：_index.md 三行各含新词根 | pre-impl-verifiable | `grep -ci 'normalization' .tad/project-knowledge/patterns/_index.md; grep -ci 'self-reference' .tad/project-knowledge/patterns/_index.md; grep -ci 'baseline premise' .tad/project-knowledge/patterns/_index.md` | 三计数各 ≥1 | 基线已录：三计数 =0 |
| AC15 | 计数总账（D10/NFR1）：四个落盘面的条目/节数与设计增量逐项吻合，无点名外膨胀 | post-impl-verifiable | `grep -c '^### ' .tad/project-knowledge/patterns/gate-design.md; grep -c '^### ' .tad/project-knowledge/patterns/ac-verification.md; grep -c '^### ' .tad/project-knowledge/patterns/handoff-design.md; grep -c '^## ' .tad/tasks/evidence-collection.md` | 四值依次 =47／=80／=58／=14（基线 45／78／57／12，增量恰为本 Phase 点名新增数） | 基线：45／78／57／12（forms 基线） |
| AC16 | KC 分诊全量对账（FR6/D7）：五条候选逐条有去向，KC3 交接在 COMPLETION 中显名 | path-check | COMPLETION-20261031-distill-batch.md 含 KC 分诊复述表（path-check：`grep -c 'KC1\|KC2\|KC3\|KC4\|KC5' .tad/active/handoffs/COMPLETION-20261031-distill-batch.md`，五词根各 ≥1，且 KC3 行含 `Phase 4` 字面：`grep 'KC3' .tad/active/handoffs/COMPLETION-20261031-distill-batch.md \| grep -c 'Phase 4'` ≥1） | 五词根计数各 ≥1；KC3-Phase 4 计数 ≥1 | 基线：COMPLETION 不存在（new） |
| AC17 | ID 行在盘行为不变（D5/NFR3）：派生回退不改变带 `**Epic ID**` 行 Epic 的派生与输出，ID 行优先于文件名被真实执行 | fixture | `diff .tad/evidence/yolo/v409-basket/p2-fixtures/id-fixture-before.txt .tad/evidence/yolo/v409-basket/p2-fixtures/id-fixture-after.txt; echo $?; grep -c 'fixture-id-slug' .tad/evidence/yolo/v409-basket/p2-fixtures/id-fixture-after.txt` | diff 退出 =0（S3 ⑤ 分歧夹具改前/改后两轮全量输出逐字一致）；第二值 ≥1（gate3-files 的 OK 行命中 ID slug 目录 fixture-id-slug——文件名 slug 为 fixture-name-slug，命中 ID 目录即 ID 优先的机械证据）。总体面对照基线：`p2-baseline-id-line-population.txt`（改前 66 份双派生全 MATCH＋样本端到端输出） | 基线：两件不存在（new，S3 ⑤ 实施时生成）；改前总体基线已于 Gate 2 修订步先采落盘，实施后无从补采 |

---

## 9.2 Expert Review Status (Alex 必填)

> Process Gate 2 completeness = dual review **files on disk** (consistency + risk(platform)), dispatched by conductor after this design step. 本设计步不自审自批；下表待评审回填，现状如实记为待派发。

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| consistency (p2-y4-con-1) | FAIL（p0=2：P0-1 骨架块越 code_bound、P0-2 AC9 基线空洞；另 P1×3、P2×1、P3×1） | 文末「Gate 2 设计修订记录（p2-y4-fix-1）」处置表逐条 | Revised（待窄口复审） |
| risk (platform) (p2-y4-risk-1) | CONDITIONAL（p0=0：P1×2、P2×3、P3 remarks×2） | 同上处置表逐条 | Revised（待窄口复审） |

### Lenses

1. **consistency** — always (contradictions, consumers of changed lines, baseline run of every §9.1 command)
2. **risk** — platform 面：写集含 hooks/lib 校验器与判据面模板，风险在校验面行为漂移与模板契约误钉

### Overall Assessment (post-integration)

- Round 1 双审已回：consistency FAIL（p0=2）＋risk CONDITIONAL（p0=0）；设计修订（p2-y4-fix-1）已逐条处置全部 findings（处置表在文末修订记录），待 conductor 派窄口复审；复审定稿前不交 Blake。

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ cora-check.sh 的两处 slug 派生必须同口径改（L68 与 L223）：只改一处会让 dispatches 与 gate3-files 对同一 Epic 派生出不同 slug，是比现状更坏的隐性分歧。AC11 验 gate3-files 面、AC17 验 ID 优先面，Gate 3 评审仍须额外对 dispatches 跑一次对照（before/after 件已含两子命令）。
- ⚠️ 新 pattern 条目的标题在 §4.2 逐字给定——AC4/AC5/AC6/AC7/AC8 按标题片段机械核，Blake 自创标题即 FAIL；正文可自由成文（须过 NFR2 variabilize），标题一字不许改。
- ⚠️ S6 勘误只准追加：对 Phase 1 HANDOFF 的任何原地编辑（含顺手修格式）都会触发 AC13 的哈希守卫并连带质疑该链收口记录。

### 10.2 Known Constraints
- 本仓文件夹内禁 git 命令（仓根 AGENTS.md 头部）；一切对账以 grep/sha256/脚本实跑为面。收口推送由 conductor 执行（`../gm/bin/推送`），不在 Blake 写集。
- `.claude/` 投影不手改（installer 携带面）；本 Phase 写集本就不含 skill 文件，surplus SKILL 只读。
- D6 命名分歧记账：本 Epic 链文件用 p{N}-\* 命名（证据根 v409-basket），与 review-contract §Paths 的 phase{N}-\* 约定不同；conductor 已裁不改名、不复制双名件（Phase 1 同案）。其后果——cora-check gate3-files 修复后对本 Epic 报 MISSING phase{N}-\*——是约定分歧的诚实显形，不属本 Phase 缺陷，Gate 3/4 不得以此判 FAIL；prospective 链按 §Paths 命名即自洽。
- 回退新覆盖面记账（基线件 `p2-baseline-id-line-population.txt` D 节）：ID 行不在行首的指针形 Epic（如 EPIC-20260831-capability-builder-v1.md，改前派生为空、usage exit 2）将在回退后由文件名派生出 slug——这是回退的预期新覆盖（治 usage 假红同类），不是行为回归；AC17 的「行为不变」口径只约束派生非空的带 ID 行总体（基线 A 节 66 份）。
- gate3-check.sh 一行不改（D4）：其分类器是 G4-F2 的受害方不是肇事方；任何「顺手放宽分类器」的改动即越界。
- 分段落盘：本 HANDOFF 与 COMPLETION 均超 ~8KB，须按 evidence-collection 的 Segmented Write Discipline 分段落盘、每段验字节、回执带总字节数与章节清单。

### 10.3 🆕 Sub-Agent使用建议

Blake应该考虑使用：
- [ ] 无——本 Phase 步间为同文件串行编辑（D10），并行 subagent 反而制造写集冲突；六个 Step 由 Blake 本人顺序执行。

### 携带项（本 Phase 显名交出）
- KC3（探针第二可观测面）→ Phase 4 扫描面：属主 conductor，本节与 §4.0 分诊表即交接面；COMPLETION 须复述（AC16）。
- Regression Replay 的 Gate 3 义务（§8.4 第一行）→ Gate 3 评审步：属主该步评审人，conductor 派发时在信封中点名。

---

## Gate 2 设计修订记录（dispatch p2-y4-fix-1，2026-10-31）

### 激活自报（Alex · 本步）

- 角色：Alex（Solution Lead），本 HANDOFF 的设计者（p2-y3-1 同一设计责任），由 conductor 派发做 Gate 2 设计修订（step Y4 design fix）。本步只修订本合同与新增一份基线证据，不动任何实现文件、不出 verdict。
- 已按激活协议进仓读原件：薄壳 skill、仓根 `AGENTS.md`、`.tad/project-knowledge/principles.md`、`.tad/project-knowledge/patterns/_index.md`、`.tad/tasks/handoff-creation.md`、`.agents/skills/cora/references/conductor-protocol.md` step_Y4、`.agents/skills/alex/references/conductor-dispatch-mode.md`（Design fix 节）、`.agents/skills/alex/references/handoff-creation-protocol.md`（step1 的 code_bound 原文与 Gate Rounds 骨架行）、`.tad/gates/gate-canonical-checklist.md` Gate 2 节、`.agents/skills/gate/SKILL.md` NO-PROGRESS derivation 块、`.tad/templates/review-contract.md` §5/§6 标题与条目形态；findings 以两份 verdict 原文为准（p2-gate2-review-consistency.md、p2-gate2-review-risk.md）。
- 头部已按 dispatch-mode 的 Design fix 规则更新：`dispatch_id: p2-y4-fix-1`，原 id 入 `dispatch_history: p2-y3-1`（front matter 块内第 2–3 行）。

### 时序硬项：改前基线先采（已执行）

ID 行总体的 cora-check 改前基线已在任何脚本改动发生之前采集落盘：`.tad/evidence/yolo/v409-basket/p2-baseline-id-line-population.txt`——采集时 `.tad/hooks/lib/cora-check.sh` 的 sha256 = 3985e5c9d0bf254fe24afba195e2d04ee6abfb8fb672c6bfb95288decee62504（与风险面实测值一致，采集前后复核未变，脚本至今未动）。内容：66 份带 `**Epic ID**` 行的 Epic 逐份双派生（现行 L68/L223 同款 sed 对 ID 行派生 vs 文件名派生）**全量 MATCH、MISMATCH 0**；端到端样本 4 份（其中 EPIC-20261013-cora-conductor-role 两子命令实跑：dispatches count 81、gate3-files 在 ID 派生目录 OK+MISSING，exit 1）；对照组为本 Epic（无 ID 行、两子命令 usage exit 2）；D 节记样本负例（指针形 Epic 不在总体内、回退后属新覆盖）。修订出的新判据 AC17 以此件为总体面对照，其实施面的分歧夹具改前轮由 Blake 在改脚本前跑（S3 自验 ⑤）。

### Findings 处置表（逐条销账；接受＝已在本 HANDOFF 内改正）

| # | Finding | 来源 | 处置 | 落点 |
|---|---|---|---|---|
| 1 | P0-1：§4.2 S4 骨架围栏块 19 行越 code_bound（单块 ≤15） | consistency | 接受改正：骨架段间空行去除、紧缩为 12 行，四形态字面逐字不变；引入句注明 code_bound 口径。自验一行式量值见下节 | §4.2 S4 |
| 2 | P0-2：AC9 基线与盘面不符（实跑 0/0/1/1 vs 自录 =0），两值全文件计数空洞 | consistency | 接受改正：AC9 改为骨架小节内计数（awk 先抽 `#### Verdict skeleton` 小节再计数），本步实跑新基线 0/0/0/0；Verified Output 更正并记旧法实跑值与空洞原因 | §9.1 AC9 |
| 3 | P1：AC12 第三值自比恒真＋D5「ID 行在盘行为逐字不变」全设计无机械验点 | consistency P1-1 ＋ risk P1-1（同根，合并处置、逐条销账） | 接受改正：AC12 第三值换为派生原形计数（两处原 sed 捕获组计数，基线实跑 =2）；S3 自验新增 ⑤ ID 优先分歧夹具（ID slug 与文件名 slug 故意不同，改前改后各跑两子命令、整件落盘比对）；新设 AC17 承接该声称的行为面验点；D5 的 Accepted by 补 AC17；改前总体基线已先采（见上节） | §4.2 S3、§9.1 AC12／AC17、§6 步 4、§4.0 D5 |
| 4 | P1：§8.4 的 cora-check 回滚路径无字节载体（只有哈希） | risk P1-2 | 接受改正：§7.1 增原件快照件 `p2-cora-check.sh.orig`（cp 后 sha256 对账）；§6 步 4 先行 cp；§8.4 回滚改指该件（哈希只作对账、不作载体） | §7.1、§6 步 4、§8.4 |
| 5 | P1：AC5/AC6 的 post 判读系于未钉死的正文语言（英文 grep vs 中文内容规格，可假 FAIL） | consistency P1-2 | 接受改正（与 AC7 钉 `Oracle reachability` 同口径）：P-A 规格钉子标题 `#### Missing-state semantics`＋逐字短语 `the missing-state list`；P-B 规格钉逐字句 `never rewrite it as a literal pass` | §4.2 S5 |
| 6 | P1：Gate Rounds 块缺 MANDATORY 骨架（SCHEMA v1、BEGIN、派生定义行、原表头） | consistency P1-3 | 接受改正：整块按 handoff-creation-protocol step1 骨架重造（BEGIN／`GATE-ROUNDS-SCHEMA: v1`／derivation 定义逐字抄录自 gate/SKILL.md／原表头），标题去括注对齐 Phase 1 HANDOFF 形态，行按 Round 1 实况回填 | 文末 Gate Rounds |
| 7 | P2：骨架同源句 ④ 对四列存量表形的兼容口径过宽（evidence 回退 exit 列的陷阱未写明） | risk P2-1 | 接受改正：④ 补「解析层」限定并写明 exit 须写实值、不得以 `-`／空占位 | §4.2 S4 |
| 8 | P2：AC10 坏形 fixture 未钉字（改「结果」被分类器接受、坏形不坏） | risk P2-2 | 接受改正：坏形列名钉死为「判定」，并注分类器接受「结果」为 status 别名；§2.2 基线行与 §4.2 干跑复证同步 | §9.1 AC10、§4.2 S4、§2.2 |
| 9 | P2：AC13 只守 AC7 一行，Phase 1 HANDOFF 其余字节无机械守卫 | risk P2-3 | 接受改正：AC13 加第四值前缀守卫（勘误节之前全部字节的哈希；基线全文件 84,938 B、sha256 =37efc9fa…，本步实测且前缀法对现文件已验等值） | §9.1 AC13 |
| 10 | P2：Gate 2 节缺高风险触发项核对结论 | consistency P2-1 ＋ risk R1（同项） | 接受改正：Gate 2 节补核对结论段，六类触发逐项不命中、结论非高风险不附风险卡 | Gate 2 节 |
| 11 | P3：AC16 方法行含 `<同文件>` 占位符 | consistency P3-1 | 接受改正：改为字面路径 | §9.1 AC16 |
| 12 | P3 remark：S4 落点「run 段之后」一字之差（可劈开 run 条目） | risk R2 | 接受改正：落点钉为「run 条目全部段落之后（含 citation spot-check 续段）、domain 条目之前」 | §4.2 S4 |

- 12 个处置项对应双面全部 findings（一致性面 P0×2、P1×3、P2×1、P3×1；风险面 P1×2、P2×3、P3 remarks×2），无驳回项、无未处置项；#3 为双面同根合并处置，两条各自销账。
- 连带一致性修订（不另立项）：§9.1 行数 16→17 后，§9 首条计数与 AC10 fixture 规格的「16 AC」表述已同步（改全称「全部 AC 行」）；§10.1 第一条警告的验收分工补 AC17；§10.2 增回退新覆盖面记账一条。
- 本节只证明设计修订已逐项落字、基线已先采与自验已实跑，不构成 Gate 2 复审结论。复审须由 conductor 以新 dispatch 独立派发（窄口，只核本修订动过的面）；复审定稿前，本 HANDOFF 仍不得交 Blake 实施。

### 修订后自验（四项，本步实跑留值）

- 头形：first=`---`；`dispatch_id: p2-y4-fix-1` 在第 2 行、`dispatch_history: p2-y3-1` 在第 3 行，front matter 块闭合于第 23 行（原 22 行，因加 history 行 +1）——handoff-header-form 三点合。
- §9.1：形态 A 表头计数 =1；§9.1 区内 AC 行 =17（AC1–AC17，含本步新增 AC17；全文同形计数 18，多出的一行为 §4.2 S4 骨架块内的 AC1 样例行，不在 §9.1 区内）。
- code_bound：逐字运行 handoff-creation-protocol step1 一行式 → `max=12 total=35 open=0`（修订前 max=19；max 块即紧缩后的 S4 骨架块 12 行，已在界内）。
- Gate Rounds 骨架：`GATE-ROUNDS-BEGIN` =1、`GATE-ROUNDS-DERIVATION: v1` =1、`GATE-ROUNDS-END` =1、原表头 `| 时间 | Gate | verdict | 类别 | 记录者 |` =1；`GATE-ROUNDS-SCHEMA: v1` 块内 =1（全文计数 3：骨架块内 1、本修订记录处置表 #6 引用 1、本句自引 1——原记 2 系漏计自引，2026-10-31 由 conductor 按一致性面复审 remark 更正记账）。修订后全文 643 行／79,916 B，截断标记 grep =0；cora-check.sh 全程未动（sha256 仍 3985e5c9…）。

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
| 2026-10-31 | design | DRAFT-COMPLETE | design-boundary | Alex (p2-y3-1) |
| 2026-10-31 | G2-consistency | FAIL (p0=2) | review | verifier (p2-y4-con-1) |
| 2026-10-31 | G2-risk | CONDITIONAL (p0=0) | review | verifier (p2-y4-risk-1) |
| 2026-10-31 20:55 UTC | G2-fix | REVISED（双面 findings 全处置，待窄口复审） | design-boundary | Alex (p2-y4-fix-1) |
| 2026-10-31 21:01 UTC | G2-consistency-rereview | PASS (p0=0) | review | verifier (p2-y4-con-2) |
| 2026-10-31 21:01 UTC | G2-risk-rereview | CONDITIONAL (p0=0，P3 携带入实施派发) | review | verifier (p2-y4-risk-2) |
| 2026-10-31 | G2 | CONDITIONAL PASS (p0=0，合成；含 L616 计数句 conductor 更正记账) | gate | Cora（记账补行，据双面复审 verdict） |
| 2026-10-31 21:15 UTC | impl | COMPLETION RETURNED（§9.1 十七行实施者自验全合） | impl | Blake (p2-y5-1) |
| 2026-10-31 21:20 UTC | G3-spec | CONDITIONAL (p0=0) | review | verifier (p2-y7-g3spec-1) |
| 2026-10-31 21:24 UTC | G3-code | CONDITIONAL (p0=0，条件 C-RR) | review | verifier (p2-y7-g3code-1) |
| 2026-10-31 | G3 | CONDITIONAL (p0=0，合成；C-RR 经 conductor PM 裁断解除，裁断全文在 Epic Run) | gate | Cora（记账补行，据双面 verdict＋C-RR 裁断） |
| 2026-10-31 21:34 UTC | G4 | CONDITIONAL PASS (p0=0；AC11 P2 携带、C-RR 证据基础成立、P-C 候选成立) | gate | Alex (p2-y7-g4-1) |
<!-- GATE-ROUNDS-END -->

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-10-31
**Version**: 4.0.8

# Quality Chain Metadata (Alex 必填 - Phase 4 Hook 将基于此阻塞 Gate 3)
task_type: mixed       # 规程条文增补（docs-only 性质的协议契约变更）；无 UI、无运行时代码
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
required_evidence_manifest:
  - .tad/active/TICKET-20261004-course-judgment-adoption.md（本链票：采纳四项、红线、不采项）
  - .tad/evidence/pm/2026-10-04-course-proposal-judgment.md（PM 判断正本：采纳口径与总纲出处）
  - .tad/evidence/activation-packages/tad-course-adoption-design-01.md（本步激活包：判据与纪律）
  - Gate 2 dual reviews ×2：`.tad/evidence/reviews/2026-10-04-gate2-tech-review-course-judgment-adoption.md`（CONDITIONAL，P0=0／P1=1／P2=3）、`.tad/evidence/reviews/2026-10-04-gate2-fit-review-course-judgment-adoption.md`（CONDITIONAL，P0=0／P1=1／P2=3）+ PM 合并裁定 `.tad/evidence/pm/2026-10-04-course-adoption-gate2-merged-ruling.md`（CONDITIONAL PASS，增补清单 B1–B7）
  - COMPLETION-2026-10-04-course-judgment-adoption.md (Blake 完工件，落 .tad/evidence/completions/)
  - .tad/evidence/risk-cards/risk-TASK-20261004-COURSE-JUDGMENT-ADOPTION.md（Phase 2 以新模板为本链实施自填的风险卡，dogfood 件）
tad_scope: full
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-10-04
**Project:** TAD Framework（课程判断落地链：PM 判断采纳四项落进 TAD 本体规程）
**Task ID:** TASK-20261004-COURSE-JUDGMENT-ADOPTION
**Handoff Version:** 1.1（Gate 2 增补版：CONDITIONAL PASS 条件 B1–B7 已回填，销账待 PM 定点核）
**Ticket:** `.tad/active/TICKET-20261004-course-judgment-adoption.md`
**Judgment:** `.tad/evidence/pm/2026-10-04-course-proposal-judgment.md`（采纳口径以此为准；提案包是输入不是结论）

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-10-04——双审已落盘（tech 路 CONDITIONAL，P0=0／P1=1／P2=3；fit 路 CONDITIONAL，P0=0／P1=1／P2=3），PM 合并裁定 **CONDITIONAL PASS**，条件＝增补清单 B1–B7。B1–B7 已回填本版（v1.1），**销账待 PM 定点核**（读段＋grep＋触发集同串比对）；PM 销账转 PASS 前，Blake 不得开工。

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅（CONDITIONAL PASS） | §4.1 装载面地图＋四组件 C1–C4 逐项五段（现状／条文草案／落点／装载点位／验证） |
| Components Specified | ✅（CONDITIONAL PASS） | 逐项到文件与节位：CREATE 1 件＋MODIFY 5 件（含 Gate 2 增补 B2 的 gate skill 同步遍），锚点行号均设计步实测（§7） |
| Functions Verified | ✅（CONDITIONAL PASS） | MQ2 锚点存在性逐项实跑（AGENTS.md L75、alex SKILL 义务块 L57–94 等） |
| Data Flow Mapped | ✅（CONDITIONAL PASS） | MQ3：判断 → 设计 → Gate 2 → 条文落地 → 激活装载 → Gate 3/4 消费 |

**Gate 2 结果**: **CONDITIONAL PASS**（PM 合并裁定 2026-10-04）— 双路均 CONDITIONAL、P0=0；条件为增补清单 B1–B7，已回填本版：触发集逐字拍板回填 FR1 与 §4.2 三处同串（B1）、gate skill 同步面补入 §2.2／Phase 1 遍 1b／§7.2 与 AC16、AC14 计数行点名例外（B2）、路径大小写统一（B3）、C3 行数改准（B4）、AC2 词表补三节名（B5）、Phase 2 dogfood 如实声明（B6）、AC13 与 AC15 合取注记（B7）；CF-1…CF-5 裁定回填见 §4.6。**销账待 PM 定点核**，销账转 PASS 后 Blake 才许按裁定形态实施；裁定与本设计不一致处，以裁定为准。

> **Process Gate 2 = dual reviews on disk** (P2 tax-cut). PASS ⇔ two independent artifacts under `.tad/evidence/reviews/` (P0=0 or sanctioned). Do **not** write a dispatch lock that waits for a human chat string `/gate 2`.

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节（含票、判断正本、§4.6 冲突点名的 Gate 2 裁定回填）
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**（尤其位置断言一条：写进大文件尾巴 = 没写）
- [ ] 所有"强制问题回答（MQ）"都有证据
- [ ] 理解了真正意图（不只是字面需求）：四项条文必须**被读到**，不是**被写下**
- [ ] 每个 Phase 的交付物和证据要求都清楚
- [ ] 特别确认：四件 MODIFY 全是**纯增补**（删除行数 = 0 是 AC14，不过先报 PM，不许自行改写既有条文凑数）
- [ ] 确认可以独立使用本文档完成实现

❌ 如果任何部分不清楚，**立即返回Alex要求澄清**，不要开始实现。

---

## 1. Task Overview

### 1.1 What We're Building

把 PM 对技术研究席课程提案包的判断中**采纳的四项**，以「条文增补」形态落进 TAD 本体规程文件，且每项自带装载点位（在哪个既有装载面、何时被读到）：

| 组件 | 采纳项 | 落地形态（一行） |
|------|--------|------------------|
| C1 | 风险卡证伪式假设表 | 新模板 `.tad/templates/dispatch-risk-card.md`（裁剪版）＋ Gate 2 清单一项 ＋ Alex 义务块一行 |
| C2 | 量规 E 维证据纪律 | Gate Canonical 清单 Gate 3/Gate 4 两处条文增补 ＋ Alex 义务块一行 |
| C3 | 权威顺序短文 | 仓根 `AGENTS.md` Critical Rules 新增一小节（全文 ≤20 行） |
| C4 | 装载点位一句 | Gate Canonical 清单卷首一句 ＋ Gate 2 常查项 ＋ Gate 3 §9.1 子款 |

### 1.2 Why We're Building It

判断正本总纲（本设计的立论）：近期失败模式集中在两处——**「假设没写明」**与**「自报不实」**。新规矩只往这两处加：C1 治前者（高风险派发先把关键假设写成可证伪句），C2 治后者（评审结论必须附证据指针、自报与盘上不符直接判负）。C3 把散落在教训条文里的冲突裁决收成一条明文，C4 保证以上三项（以及今后一切写进文件的东西）真的有装载点位——**写进文件却没有装载点位的东西等于没写**。

### 1.3 🆕 Intent Statement（意图声明）

成功不是「四个文件改完了」，而是：下一个高风险 handoff 出生时自带一张假设可证伪的风险卡；下一次 Gate 3/Gate 4 评审时，无证据指针的结论当场不成立、自报不符当场判负；下一次文件冲突时有明文顺序可查；下一次有人往规程里加东西时，Gate 2 会先问「装载点位在哪」。

### 1.4 非范围（明确不做 — 不采项，不许夹带复活）

以下为判断正本明示**不采**，Blake 不许以任何形式顺手落地，Gate 3 见之即 FAIL：

- 六维打分量规与切片统计（模板一整体不入本体；只取其 E 维纪律，已转写为 C2 条文）
- 每仓维护权威同步表（C3 只写一条短文，不建表）
- Gate 2 需求四元组进清单（需求规格化条文不入清单）
- 深评六问骨架与成对实测（留研究席与 Gemma 线自用，不入本体）
- 提案三生产就绪清单、提案四 MCP/连接器审查附加节（不在采纳四项内）
- 不新建 WS-0 文件（理由见 §4.6 CF-5：新文件本身没有装载点位）

### 1.5 Gate 结构（六行）

| # | 门 | 判者 | 判据 | 证据落点 | 状态 |
|---|----|------|------|----------|------|
| 1 | Gate 1 需求清晰 | Alex（本步） | 票＋判断正本口径明确、四项边界与不采项写死 | 本 HANDOFF §1/§3 | ✅ 本步成件即过 |
| 2 | Gate 2 设计评审（tech 路） | 独立会话评审 | 设计完整性、条文草案可实施性、AC 可跑性 | `.tad/evidence/reviews/2026-10-04-gate2-tech-review-course-judgment-adoption.md` | CONDITIONAL（P1=1／P2=3，条件入 B2/B3/B4） |
| 3 | Gate 2 设计评审（fit 路） | 独立会话评审 | 与判断口径贴合度、不采项零夹带、CF-1…CF-5 裁定建议 | `.tad/evidence/reviews/2026-10-04-gate2-fit-review-course-judgment-adoption.md` | CONDITIONAL（P1=1／P2=3，条件入 B1/B5/B6/B7） |
| 4 | Gate 3 实现评审（code 路） | 独立会话评审 | §9.1 逐行重跑、纯增补断言、位置断言 | `.tad/evidence/reviews/` | 未开 |
| 5 | Gate 3 实现评审（safety 路） | 独立会话评审 | 不采项零落地、条文无越权扩权 | `.tad/evidence/reviews/` | 未开 |
| 6 | Gate 4 业务验收 | Alex | 从盘上重算 §9.1 全部行＋装载点位实测 | `.tad/evidence/reviews/` 或 `evidence/gate4/` | 未开 |

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别

命中索引类别：Gate Design、AC Verification、Handoff Design（设计步实读全文/关键条目，摘录如下）。

### 步骤 2：历史经验摘录

**摘录 1 — `grep -Fq` 证明"在文件里"，不证明"agent 读得到"（patterns/gate-design.md，2026-08-14，⚠️ SAFETY）**
原文要点：常驻文件超过工具单次 Read 上限时，尾部内容「在场但不可达」；任务驱动的 agent 拿到需要的部分就停，不会为义务内容翻页。Action：任何"约束必须常驻"型 AC，除 grep 在场外**必须再断言位置**（最大行号 ≤ 单次可达范围，阈值取实测值）；载体本身超限时根治是拆文件或改用自动注入载体。
→ 对本链的约束：`.agents/skills/alex/SKILL.md` 现 98,718 B／1,669 行。C1/C2 在该文件的增补**只许进 L57–94 的义务型祈使句块**（文件首部、单次 Read 必达），且 AC 带行号上限断言（见 AC4/AC7）。

**摘录 2 — Claims Need Carriers（patterns/gate-design.md，2026-06-10）**
原文要点：下游验证链（Gate 4 重算、审计、检索）只读盘不读聊天；没有载体文件的声明对整个验证链不可见。设计任何新声明类型前先问：「哪个文件承载它、哪道门测它的存在？」
→ 对本链的约束：四项各自先定载体文件再定条文（§4 逐项 ③④）；C2 的「证据指针」就是把这条从设计原则变成评审判据。

**摘录 3 — Execution Discipline Content Must Stay in SKILL Body / Circular Trigger Test（principles.md，2026-06-09）**
原文要点：触发条件引用了内容自身定义的概念时（circular trigger），内容必须留在 body；`load_when` 引用外部可独立感知的事件时才可下放 references。
→ 对本链的约束：C1 的触发（「正在创建高风险 handoff」）由义务块常驻行承载——义务块在激活时必读，触发不依赖被触发内容本身，非 circular；模板文件是被触发后才读的表单，不承载触发规则本身。

**摘录 4 — principles.md「Judgment-Only Skill Files」（2026-04-04，⚠️ SAFETY）**
约束类条文（MUST/VIOLATION 级）不可在瘦身时移除；本链四项均为约束类条文，落地后同样受此保护，Gate 3 不许以「精简」名义删改。

### Blake 确认

- [ ] 已读上述摘录原文要点，理解位置断言与载体先行两条对本链的硬约束

---

## 2. Background Context

### 2.1 Previous Work

- 提案包（输入）：`yun-sync/tech-radar/ai-coding-courses/` 五件——研究正文 `2026-10-04-fall-courses-tad-proposals.md`、模板一 `templates/gate3-rubric.md`、模板二 `templates/dispatch-risk-card.md`、模板三 `templates/review-six-questions.md`、交接单 `2026-10-04-tad-proposals-handoff.md`。设计步已逐件读毕，仅取判断采纳部分。
- 判断正本：`.tad/evidence/pm/2026-10-04-course-proposal-judgment.md`（2026-10-04，PM 判断，修订版）。
- WS-0（装载层）是 GM 侧落实方案的工作流名；**本仓内不存在 WS-0 载体文件**——设计步 grep 实测：`WS-0` 在本仓仅命中判断正本、本票与本步激活包三处。因此 C4 的「并入 WS-0」在本仓的落地方式 = 并入本仓实际装载面（见 §4.1），不新建文件（CF-5）。**Gate 2 裁定回填（合并裁定 7／CF-5）**：票面「并入 WS-0/装载层口径」在本仓的执行解释写死为**并入 Canonical SSOT 装载面**——Gate 3 不许以「无 WS-0 文件」的字面口径误判本项未落地。

### 2.2 Current State（设计步 2026-10-04 亲跑基线）

本仓实际装载面盘点（C1–C4 的落点全从此表选，不许另起炉灶）：

| 装载面 | 文件 | 何时被读到 | 设计步实测 |
|--------|------|-----------|-----------|
| 会话启动原生读取 | 仓根 `AGENTS.md` | 三个 harness 会话启动原生读取（其 Runtime status 节自述） | 168 行；`### Memory authority` 在 L75 |
| 角色激活 | `.agents/skills/alex/SKILL.md` | `$alex`/`/alex` 激活时整件加载；义务块在首部 | 98,718 B／1,669 行；义务型祈使句块 L57–94（L95 为 4 步激活标题）；Handoff Creation Protocol 在 L1061；Gate SSOT 指针在 L1147 |
| 角色激活 | `.agents/skills/blake/SKILL.md` | `$blake`/`/blake` 激活时整件加载 | 122,016 B／2,157 行；Gate SSOT 指针在 L1110–1111 |
| Gate 执行 | `.tad/gates/gate-canonical-checklist.md` | 两 skill 均以「Gate items 以此为 SSOT」指针引用，Gate 1–4 执行时读 | 69 行／4,238 B，单次可全读 |
| Gate 执行（inline 副本） | `.agents/skills/gate/SKILL.md` | 经 gate skill 执行 Gate 时读；其 Gate 2／Gate 4 节内嵌 Canonical 清单的 inline 副本，自带同步纪律「Edit canonical FIRST, then sync here. Drift check: diff canonical vs this section.」 | 54,135 B／999 行；Gate 2 节「Critical Check (6 items)」计数行 L85；Gate 4 节 Functional acceptance 内嵌行 L733（设计步后经 Gate 2 tech 路 P1-1 实测补入，见下方增补注） |
| Handoff 创建 | `.tad/templates/handoff-a-to-b.md` | 每次建 HANDOFF 时按模板成件 | §9.1 为 Gate 3 主验证源 |
| 任务调用 | `.tad/tasks/handoff-creation.md`、`gate-execution.md`、`evidence-collection.md` | 对应任务被调用时读 | 本设计已逐件读原件 |

> **Gate 2 增补注（B2）**：上表初版漏列 gate skill 一行。若 Canonical 落新项而其 inline 副本不同步，按 gate skill 执行 Gate 2 的评审者读到的仍是自洽的旧六项（还带「6 items」计数背书）——这正是 C4 要防的「写了但读不到」失效形态**在本设计自身的实例**（tech 路 P1-1）。处置：Phase 1 增同步遍（遍 1b，见 §6）、§7.2 写集补该文件、AC16 守双在册、AC14 为其计数行设点名例外。

四项各自的现行规程现状（逐项详述在 §4 对应组件 ①）：

- C1 现状：派发侧有开工卡/stamp（GM 侧机制）与 HANDOFF §10 警告节，但 TAD 本体内**没有**风险卡模板、没有「高风险派发须写假设」条文；`grep -c 风险卡 .tad/gates/gate-canonical-checklist.md` = 0（实测）。
- C2 现状：Gate Canonical Gate 4 已有「Gate 4 须从盘上重算、自报不是证据」句（Gate 4 节 Functional acceptance 的 Fail-close 注），但 Gate 3 无「判定须附证据指针」、无「自报不符即否决」的成文判据；`grep -c 证据否决 .tad/gates/gate-canonical-checklist.md` = 0（实测）。
- C3 现状：权威关系只有散落教训（仓根 AGENTS.md「Memory authority」一小节、skill 壳「以仓内原件为准」一句），无成文顺序；`grep -c "File authority order" AGENTS.md` = 0（实测）。
- C4 现状：无任何「装载点位」条文；`grep -c 装载点位 .tad/gates/gate-canonical-checklist.md` = 0（实测）；位置断言的教训只在 patterns 条目里（评审/设计时不常查）。

### 2.3 Dependencies

- 无外部依赖。实施只依赖仓内 git（diff 断言）与常规文本工具。
- 前置：Gate 2 双审落盘＋PM 合并裁定（含 CF-1…CF-5 逐项裁定回填）。

---

## 3. Requirements

### 3.1 Functional Requirements

- **FR1（C1）**：高风险派发（触发项：L3 动作（含删除、密钥、公网、生产）／跨仓或跨席位写／引入新连接器、MCP 或依赖／不可逆动作／涉及金额／对外动作，以及 PM 判断为高风险者）必须附风险卡；风险卡须含证伪式假设表——每条关键假设写成可证伪句，并给出「证伪信号」（出现什么可观察现象即假设不成立）与「信号出现时的动作」。（触发集为 Gate 2 PM 合并裁定 1 逐字拍板：对齐提案原件适用面＋兜底句；「删除／密钥／公网／生产」并入 L3 项下作例示、不单列。本串与 §4.2 三处逐字同串，B1。）
- **FR2（C2）**：Gate 3／Gate 4 评审的每条判定必须附证据指针；被审方自报与盘上实测不符的条目直接判负（该行 FAIL），且 Gate 3 整体不得 PASS（证据否决），不许以其他条目抵消。
- **FR3（C3）**：文件权威顺序成文为一条短文（≤20 行），冲突裁决顺序写死：用户当前指示 ＞ 目标仓原件 ＞ 席位级常驻文件 ＞ 注入默认/overlay；不建同步表。
- **FR4（C4）**：「放进文件的东西必须有装载点位」成文并成为设计与评审的常查项：Gate 2 查「逐项写明装载点位」，Gate 3 查「声称的装载/约束含位置断言」。

### 3.2 Non-Functional Requirements

- **NFR1 条文增补形态**：四件 MODIFY 文件只许纯增补——`git diff` 删除行数 = 0（AC14）；不许整篇重写、不许顺手改既有条文措辞。唯一例外：CF-2 若 Gate 2 裁定要同步修订 Canonical 的 MECE 说明行，允许改动被点名的说明行，范围以裁定回填为准。
- **NFR2 位置可达**：一切新增义务型文字必须落在载体单次可达范围内，并以行号上限断言入 AC（义务块新增行 ≤ L120；AGENTS.md 新节标题 ≤ L100）。
- **NFR3 口径**：设计与条文正文不许复述版本号；术语一词一义——「高风险」定义只在 Canonical Gate 2 风险卡项写一次，其余文件引用不重定义；「证据指针」「装载点位」全链同义。
- **NFR4 不采项零落地**：§1.4 清单逐项为负控对象，AC2 为模板侧负控，Gate 3 safety 路逐项复核全仓 diff。

### 3.3 Optimization Target (Optional)

不适用（无性能目标；本链为规程文本变更）。

---

## 4. Technical Design

### 4.1 Architecture Overview

本链不动任何运行时结构，只往**既有装载面**上增补条文。装载关系（条文 → 装载面 → 触发时点 → 消费者）：

```
FR3 短文 ──→ 仓根 AGENTS.md ──(会话启动原生读取)──→ 全部角色，冲突裁决时
FR4 一句 ──→ Canonical 卷首＋Gate 2 项＋Gate 3 子款 ──(Gate 执行读 SSOT)──→ Alex/Blake/评审者
FR2 纪律 ──→ Canonical Gate 3/4 条文 ＋ Alex 义务块 ──(激活＋Gate 执行)──→ Gate 3 评审者、Gate 4 的 Alex
FR1 风险卡 ─→ Alex 义务块（触发）＋ Canonical Gate 2 项（检查）＋ 模板文件（表单）
              ──(Alex 建高风险 handoff 时)──→ Gate 2 评审者查卡、执行期按证伪信号巡查
```

设计原则：触发规则必须住在常驻层（义务块/会话启动文件），表单与细则可以住在被触发后才读的文件（模板/清单）—— circular trigger 检验（摘录 3）逐项在组件 ④ 中复述。

### 4.2 Component C1：风险卡证伪式假设表（FR1）

**① 现行规程现状**
- Canonical Gate 2 现有 6 项（Expert review complete／All P0 resolved／Architecture complete／Components specified／Functions verified／Data flow mapped），无风险卡项（§2.2 实测 grep = 0）。
- Alex SKILL 的 Handoff Creation Protocol（L1061 起）规定专家评审与 final_output_checklist，无风险卡触发；义务块（L57–94）无高风险派发相关行（实测 `grep -c 高风险派发` = 0）。
- 本体 `.tad/templates/` 无风险卡模板（实测 TEMPLATE_ABSENT）。

**② 增补条文草案（全文，Blake 逐字落，不许改写措辞；占位符除外）**

(a) 新模板 `.tad/templates/dispatch-risk-card.md` 全文：

```markdown
# 派发风险卡（高风险派发必填）

> 触发与判据：.tad/gates/gate-canonical-checklist.md Gate 2「Risk card」项。
> 本模板范围以 PM 判断（.tad/evidence/pm/2026-10-04-course-proposal-judgment.md）为准：
> 只取损失/需求简表与证伪式假设表；提案包其余部件不在本模板内（清单见
> HANDOFF-2026-10-04-course-judgment-adoption §1.4）。
> 一页为限（可附链接）；落盘 `.tad/evidence/risk-cards/risk-<task_id>.md`。

## 0. 头信息

| 字段 | 填写 |
|---|---|
| 任务 / task_id |  |
| 关联 HANDOFF（路径） |  |
| 触发项（逐项核对，命中任一即高风险） | L3 动作（含删除、密钥、公网、生产）／跨仓或跨席位写／引入新连接器、MCP 或依赖／不可逆动作／涉及金额／对外动作，以及 PM 判断为高风险者——命中项在此格内注 |
| 填写人 / 日期 |  |

## 1. 最坏损失与对应需求（每条一行）

| # | 利害关系人 | 最坏损失（具体事件） | 对应需求 REQ（系统必须保证……） |
|---|---|---|---|
| 1 |  |  |  |

## 2. 证伪式假设表（本卡核心）

对最重要的 1–3 条 REQ 逐条列。每条假设必须写成可被证伪的句子
（「假设 <可检验的陈述>」）；证伪信号必须是派发后可观察的现象，
不许写「出问题」「效果不好」这类不可观察的词。

| REQ | 假设 ASM（可证伪句） | 证伪信号（出现什么现象即假设不成立） | 信号出现时的动作（停 / 回滚 / 报人） |
|---|---|---|---|
|  |  |  |  |
```

(b) Canonical Gate 2 新增项（插在现有清单末尾、`Why CE` 行之前）：

```markdown
- [ ] Risk card for high-risk handoffs — 高风险 handoff（触发项：L3 动作（含删除、密钥、公网、生产）／跨仓或跨席位写／引入新连接器、MCP 或依赖／不可逆动作／涉及金额／对外动作，以及 PM 判断为高风险者）附风险卡（模板 `.tad/templates/dispatch-risk-card.md`，落盘 `.tad/evidence/risk-cards/risk-<task_id>.md`），证伪式假设表逐条成立（假设句＋证伪信号＋动作三列齐）；非高风险须在 Gate 2 节写明触发项核对结论. Why ME: 只检查"高风险派发的关键假设是否写明且可证伪"
```

(c) Alex SKILL 义务块新增一行（追加在义务块现有清单末尾、L95 标题之前）：

```markdown
- 高风险派发（触发项：L3 动作（含删除、密钥、公网、生产）／跨仓或跨席位写／引入新连接器、MCP 或依赖／不可逆动作／涉及金额／对外动作，以及 PM 判断为高风险者）必须附风险卡，关键假设逐条写成可证伪句（假设＋证伪信号＋动作）
```

**③ 落点文件与节位**
- CREATE：`.tad/templates/dispatch-risk-card.md`（全文 = 草案 (a)）。
- MODIFY：`.tad/gates/gate-canonical-checklist.md` Gate 2 节清单末尾增 (b) 一项。
- MODIFY：`.agents/skills/alex/SKILL.md` 义务块（现 L57–94）末尾增 (c) 一行。

**④ 装载点位**
- 触发：Alex 每次激活必读义务块首部（L57–，单次 Read 必达）→ 建 handoff 时 Handoff Creation Protocol（L1061）是其工作流，义务行是触发源，非 circular（触发不依赖模板内容）。
- 检查：Gate 2 评审者按两 skill 的 SSOT 指针（alex L1147／blake L1110）读 Canonical，逐项过清单 → 风险卡项在清单内必被查。
- 表单：模板路径在 (b)(c) 两处条文中被点名，填卡时按路径打开。

**⑤ 验证方式**：AC1（模板三节在册）、AC2（不采部件负控 = 0）、AC3（Canonical 项在册）、AC4（义务行在册且行号 ≤120）、AC13＋AC15（dogfood 实填卡＋独立 judge 判可证伪性）。

### 4.3 Component C2：量规 E 维证据纪律（FR2）

**① 现行规程现状**
- Canonical Gate 3 现有 7 项；「§9.1 Spec Compliance」项只规定逐行验证与 prose-only FAIL，无证据指针要求、无自报不符否决（§2.2 实测）。
- Canonical Gate 4「Functional acceptance」项已有 Fail-close 注（须从盘上重算、自报不是证据）——是本组件的同向既有条文，增补与之衔接、不重复其文。
- 提案量规（模板一）E 维原文锚点：0 分（一票否决）＝「自报数字与盘上实测不符且无说明；或关键证据缺失无法验收」；总则＝「给分必须附证据指针；无指针的给分按 0 分计」。判断只取此维——本组件即把这两句转写为 Gate 3/4 判据，**六维量规本体不入本体**（§1.4）。

**② 增补条文草案（全文）**

(a) Canonical Gate 3「§9.1 Spec Compliance」项末尾增子款（缩进与该项现有注记同级）：

```markdown
  Evidence discipline (E维): 每行判定必须附证据指针（落盘路径＋行号/章节，或命令输出
  的落盘路径）；无指针的 PASS 不成立。被审方自报（Verified Output、完工说明中的
  数字与计数）与评审重算不符的行 → 该行 FAIL，且 Gate 3 整体不得 PASS（证据否决），
  不得以其他行结果抵消；不符属口径未注明者，须先注明口径再重算，仍不符按上行处理。
```

(b) Canonical Gate 4「Functional acceptance」项的 Fail-close 注末尾增一句：

```markdown
  Gate 4 复算发现自报与盘上不符的条目 → 该条目判 FAIL 并记入 gate4_delta，
  不得以被审方总结覆盖重算结果。
```

(c) Alex SKILL 义务块新增一行（与 C1 的新增行相邻追加）：

```markdown
- 评审与验收的每条结论必须附证据指针；自报与盘上不符的条目直接判负，不许用总体印象放行
```

**③ 落点文件与节位**
- MODIFY：`.tad/gates/gate-canonical-checklist.md` Gate 3 节（a）、Gate 4 节（b）。
- MODIFY：`.agents/skills/alex/SKILL.md` 义务块末尾增 (c) 一行。
- 明示不改：`.agents/skills/blake/SKILL.md` 本体不增行——Blake 侧装载靠其 L1110–1111 的 Canonical SSOT 指针（Gate 3 自检读 SSOT 即读到 (a)）；该文件已 2,157 行，不再加体积（此为有意取舍，Gate 2 可议）。

**④ 装载点位**
- Gate 3 评审者（独立会话 spawn）经 skill 指针读 Canonical SSOT 执行逐行判定 → (a) 在判定动作现场被读到。
- Gate 4 的 Alex：义务块 (c) 在激活时必读（常驻提醒）＋ Canonical Gate 4 节 (b) 在验收执行时被读到，双点位互为备份。

**⑤ 验证方式**：AC5（(a) 在册，含「证据否决」）、AC6（(b) 在册）、AC7（(c) 在册且行号 ≤120）、AC14（纯增补）。

### 4.4 Component C3：权威顺序短文（FR3）

**① 现行规程现状**
- 仓根 `AGENTS.md` Critical Rules 有「Memory authority」小节（L75 起：`.tad/memory/` 只是捕获层、权威在 project-knowledge），只裁「记忆类」一域；全文件无跨类来源的顺序条文（实测 grep = 0）。
- 提案正文 §6 草案含「每仓同步表」与「规则瘦身」两部件——判断明示**只取短文**、拒绝同步表；瘦身纪律未在判断采纳清单内。故草案 (a) 只取顺序本体，同步表与瘦身句**不入**（§1.4 负控）。

**② 增补条文草案（全文，一条短文，含标题共 15 行）**

```markdown
### File authority order

When two sources state different things about the same matter, resolve
the conflict in this order — do not improvise per case:

1. The user's explicit instruction in the current conversation.
2. The target repo's own originals: its `AGENTS.md`, `.tad/` protocols,
   and `.tad/project-knowledge/`.
3. Seat-level standing files: `~/AGENTS.md`, `MEMORY.md`, `SOUL.md`.
4. Injected defaults and overlays.

A lower-ranked source never silently overrides a higher-ranked one:
when you act on a lower source over a higher one, record the conflict
and the reason where the decision itself is recorded. `.tad/memory/`
is a capture layer, never an authority (see "Memory authority").
```

**③ 落点文件与节位**
- MODIFY：仓根 `AGENTS.md`，插在「### Memory authority」小节之后、「### Interaction decisions」小节之前（锚点：L75 小节结束行）。新增 ≤20 行（AC9 以行数断言守「一条短文」上限）。

**④ 装载点位**
- 仓根 `AGENTS.md` 由三个 harness 在会话启动时原生读取（文件首部 Runtime status 节自述），是本仓最强的既有装载面；新节位于 Critical Rules 区（文件前半），原生读取必达。与 C4 的关系：本节即 C4 原则的一个正例——落点先行于条文。

**⑤ 验证方式**：AC8（四项顺序标记按行号升序在册）、AC9（文件总行数 ≤188，即增量 ≤20 行）、AC14。

### 4.5 Component C4：装载点位一句（FR4）

**① 现行规程现状**
- Canonical 卷首只有 SSOT 说明三行，无装载纪律（实测 grep 装载点位 = 0）；Gate 2 六项无「装载点位」检查；Gate 3 §9.1 项无位置断言要求。位置断言的实证教训只存在于 patterns/gate-design.md（摘录 1），设计与评审现场不常查——这正是判断第 5 件「只取一句并入装载层口径、成为常查项」要补的位。

**② 增补条文草案（全文，三处）**

(a) Canonical 卷首（SSOT 说明之后、Gate 1 节之前）增一行：

```markdown
> **装载纪律：放进文件的东西必须有装载点位。** 每条规程、模板与文件必须能指名它在哪个既有装载面、何时被读到或触发；指不出装载点位的条文等于没写。
```

(b) Canonical Gate 2 清单末尾（C1 新增项之后）增一项：

```markdown
- [ ] Load points declared — 本次新增/修改的每条规程、模板、文件逐项写明装载点位（装载面＋触发时点）；无装载点位的项判设计未完成. Why ME: 只检查"写下的东西读不读得到"
```

(c) Canonical Gate 3「§9.1 Spec Compliance」项增子款（与 C2 子款并列）：

```markdown
  Load-point claims: 声称某文件/条文构成装载或约束的 AC 行，Verification Method
  必须含位置断言（目标内容行号 ≤ 该载体单次可达范围）；只有 grep 在场不算装载成立。
```

**③ 落点文件与节位**
- MODIFY：`.tad/gates/gate-canonical-checklist.md` 卷首 (a)、Gate 2 节 (b)、Gate 3 节 (c)；均与 C1/C2 的同文件增补在 Phase 1 同一编辑遍内完成（节位互不重叠）。

**④ 装载点位**
- 句子本体 (a) 住在 Canonical 卷首——任何 Gate 执行读 SSOT 时第一屏即见，是本仓 Gate 体系的常驻面。
- 常查化：(b) 使 Gate 2 评审者逐单必查（设计侧），(c) 使 Gate 3 评审者在 §9.1 执行时必查（实施侧）；本链自身即以 AC4/AC7/AC8 的位置断言 dogfood (c)。

**⑤ 验证方式**：AC10（(a) 逐字在册）、AC11（(b) 在册）、AC12（(c) 在册）、AC14。

### 4.6 与既有条文的冲突点名（Gate 2 逐项裁定，裁定前 Blake 不许动对应落点）

| # | 冲突 | 设计立场 | 若 Gate 2 另裁的影响 |
|---|------|----------|----------------------|
| CF-1 | C1 给 Gate 2 清单**增项**，与判断第 4 件「Gate 2 四元组不进清单」表面相近 | 两者不同物：被拒的是**需求条目的格式强制**（四元组）；C1 增项是**高风险派发的附件检查**，且提案二原文改法即含 Gate 2 清单增项、判断采纳第 1 件时未剔除此钩 | 若裁定不入清单：删 §7 中 Canonical 的 C1 增项，触发只靠义务块一行＋模板，AC3 相应改判 N/A 并在本节回填 |
| CF-2 | Canonical 卷首自称已 MECE reconciled；C1/C4 各增 Gate 2 一项、C2/C4 给 Gate 3/4 增子款，`Why CE` 说明与计数将过期 | 子款不增独立检查维（挂在既有项下），MECE 结构不变；Gate 2 两新项与既有六项正交（附件检查／可达性检查）。Blake 只增条文、不改 `Why CE` 行（守 NFR1） | 若裁定要同步修订 `Why CE`：按裁定点名行改，NFR1 例外以裁定回填为准 |
| CF-3 | Alex SKILL 已 98,718 B／1,669 行，义务块再增两行会推高体积 | 两行均进 L57–94 首部块（增后块尾仍 ≤L96），远在单次可达范围内；AC4/AC7 以 ≤120 行号上限硬断言 | 无替代落点（下放 references 会 circular，摘录 3）；若裁定拒绝增行，C1/C2 的 Alex 侧触发改挂 Handoff Creation Protocol 节（L1061，非首部，装载强度降级，须在裁定中明示接受降级） |
| CF-4 | 仓根 `AGENTS.md` 是框架发布面文件（随 tad.sh 同步到下游仓）：C3 短文会传播到各下游仓 | 提案六本意即全席统一优先序，传播是预期效果；短文第 2 顺位写的是「目标仓自己的原件」，对下游仓语义自洽 | 若裁定只许本仓本地生效：C3 改落 `.tad/project-knowledge/principles.md` 邻位或本仓专属节并加「本仓」限定句，AC8/AC9 的文件参数相应改 |
| CF-5 | 票面要求 C4「并入 WS-0」，但本仓无 WS-0 载体文件（设计步 grep 坐实） | 以本仓实际装载面（Canonical SSOT）承接 WS-0 口径，不新建 WS-0 文件——新文件无装载点位，直接违反 C4 本身 | 若 Gate 2 坚持建 WS-0 文件：须同时给该文件指定装载面与触发时点并写入设计，否则本设计判该项不合格 |

**Gate 2 裁定回填（PM 合并裁定 2026-10-04：CF-1…CF-5 五项全照设计立场，Blake 按此形态实施）**

- **CF-1（裁定 3）**：维持 C1 入 Gate 2 清单。边界句写死——「**Gate 清单只许增存在性检查项、不许增格式强制项**」：C1 入清单属存在性检查项（前者），与判断第 4 件所拒的四元组（对需求条目施加的格式强制项，后者）不冲突。
- **CF-2（裁定 4）**：照设计——C2 的 E 维以判据子款形态入 Gate 3，不增维、不改 `Why CE` 行；本裁定明示此为有意保留，留痕在此，Blake 不许动 `Why CE` 行（NFR1 例外不触发）。
- **CF-3（裁定 5）**：照设计——C1/C2 两行入 Alex 义务块（文件首部常驻块）首部区，不取 L1061 协议节的降级落点。
- **CF-4（裁定 6）**：照设计——权威顺序短文落仓根 `AGENTS.md`；本裁定明示知悉该面随发布同步传播下游，短文为普适顺序、传播属预期效果，有意接受。
- **CF-5（裁定 7）**：照设计——不新建 WS-0 文件；票面「并入 WS-0/装载层口径」的执行解释已写入 §2.1（并入 Canonical SSOT 装载面）。

### 4.7 风险与回滚

| 风险 | 缓解（已入设计） |
|------|------------------|
| 新增义务文字落进大文件不可达尾巴，重演 2026-08-14 事故 | 落点只选首部块＋行号上限 AC（AC4/AC7/AC8）；blake SKILL 本体零增行（C2 ③ 明示取舍） |
| 条文增补被实施成整篇改写，动到既有约束 | NFR1＋AC14 删除行数 = 0 硬断言；不过先报 PM |
| 不采项在实施中被顺手夹带（量规整表、同步表、FTA 等） | §1.4 负控清单＋AC2＋Gate 3 safety 路逐项复核 |
| Canonical 计数/MECE 说明与新条文脱节，后人误读 | CF-2 点名交 Gate 2 裁，不许 Blake 自行改说明行 |
| 高风险触发项定义在多处漂移 | NFR3：定义只写 Canonical 一处，义务行与模板头只引用触发项清单原文（与 Canonical 逐字同串，AC3/AC4 的 grep 锚同源） |

**回滚**：四件 MODIFY 均为纯文本增补、两件 CREATE 为新文件。未 commit 时：`git checkout -- <四件 MODIFY>` ＋删除两件 CREATE 即完全回滚。已 commit 时：单笔 revert。无数据、无运行时、无外部系统牵连，回滚零副作用。

---

## 5. 🆕 强制问题回答（Evidence Required）

### MQ1: 历史代码搜索

#### 搜索证据

```
# WS-0 在本仓的载体（决定 C4 落法）
grep -rn "WS-0" --include="*.md" .   → 仅命中判断正本、本票、本步激活包（无规程载体）
grep -rln "装载点位" .tad/           → 同上三处（无既有条文）
# 四项的目标条文基线（决定 AC 干跑形态）
grep -c 风险卡/证据否决/装载点位 .tad/gates/gate-canonical-checklist.md → 0/0/0
grep -c "File authority order" AGENTS.md → 0
test -f .tad/templates/dispatch-risk-card.md → ABSENT
```

#### 决策说明

本仓无 WS-0 文件、无既有风险卡/证据纪律/权威顺序条文，全部为新增增补，无复用件可继承；唯一同向既有条文是 Canonical Gate 4 的 Fail-close 注（C2 与之衔接）。同类先例：证据恢复链 HANDOFF 的 §4.7 风险与回滚节证明 handoff 侧已有风险书写习惯，但那是单件自发节、非规程条文——本链把它升格为触发式模板＋清单项。

### MQ2: 函数存在性验证

#### 函数清单（本链的「函数」= 落点锚点，逐项实测）

| 锚点 | 位置 | 存在 |
|------|------|------|
| AGENTS.md `### Memory authority` 小节（C3 插入锚） | `AGENTS.md` L75 起 | ✅ 实测 |
| Alex 义务型祈使句块（C1/C2 增行锚） | `.agents/skills/alex/SKILL.md` L57–94（L95 为下节标题） | ✅ 实测 |
| Alex Handoff Creation Protocol（C1 工作流） | `.agents/skills/alex/SKILL.md` L1061 | ✅ 实测 |
| Alex Gate SSOT 指针（Canonical 装载路径） | `.agents/skills/alex/SKILL.md` L1147 | ✅ 实测 |
| Blake Gate SSOT 指针 | `.agents/skills/blake/SKILL.md` L1110–1111 | ✅ 实测 |
| Canonical Gate 2/3/4 清单节（C1/C2/C4 增补锚） | `.tad/gates/gate-canonical-checklist.md` 全文 69 行已读 | ✅ 实测 |
| HANDOFF 模板 §9.1（本表文法来源） | `.tad/templates/handoff-a-to-b.md` L527 起 | ✅ 实测 |

### MQ3: 数据流完整性

#### 数据流对照表

| 输入 | 处理 | 输出 | 消费者 |
|------|------|------|--------|
| 判断正本采纳四项 | 本设计转写为条文草案（§4） | 本 HANDOFF | PM／Gate 2 双审 |
| Gate 2 裁定（含 CF 裁项） | Blake 按裁定形态增补 5 个文件 | 条文落盘＋§9.1 实跑结果 | Gate 3 双审 |
| 新条文（AGENTS.md／Canonical／义务块／模板） | 激活与 Gate 执行时被读到 | 高风险风险卡实填件、自报否决实例、冲突裁决记录 | 后续各链（dogfood 件为首例） |

#### 数据流图

```
判断正本 → 本 HANDOFF → Gate 2 双审＋CF 裁定 → Blake 增补（5 文件）
   → §9.1 逐行实跑 → Gate 3 双审 → Gate 4 重算
   → 条文随激活/Gate 执行进入后续每条链的现场
```

### MQ4: 视觉层级

不适用：本链无 UI、无视觉产物（task_type 为规程文本变更）。

### MQ5: 状态同步

#### 状态存储位置

| 状态 | 载体 | 写者 |
|------|------|------|
| 链状态（OPEN→收口） | `.tad/active/TICKET-20261004-course-judgment-adoption.md` | PM |
| Gate 2 结论 | 本 HANDOFF Gate 2 节＋`.tad/evidence/reviews/` 双审件＋PM 裁定 | 评审者／PM |
| 实施状态与 AC 结果 | COMPLETION＋本 HANDOFF §9.1 Verified Output 列 | Blake／Gate 3 |
| 多链索引一行 | `.tad/active/session-state.md` 头部索引区 | Blake（Phase 2 收口时增一行） |

#### 状态流图

```
票 OPEN → 设计成件（本步）→ Gate 2 PENDING → 裁定 PASS → 实施 → Gate 3 → Gate 4 → 票 CLOSED＋HANDOFF 迁 archive
```

---

## 6. Implementation Steps（分Phase）

### Phase 1: 四项条文落地（按文件分遍，遍内按节位顺序）

#### 交付物

§7 的 CREATE 1 件＋MODIFY 5 件（含 gate skill 同步遍，不含本件自填）全部按 §4 草案逐字落盘（CF 裁项涉及的落点按 §4.6 Gate 2 裁定回填形态执行）。

#### 实施步骤

- [ ] 遍 1 — Canonical（`.tad/gates/gate-canonical-checklist.md`）：卷首增 C4 (a)；Gate 2 节末增 C1 (b)、C4 (b) 两项（顺序：C1 项在前、C4 项在后）；Gate 3 §9.1 项增 C2 (a)、C4 (c) 两子款；Gate 4 项增 C2 (b) 一句。
- [ ] 遍 1b — gate skill 同步（`.agents/skills/gate/SKILL.md`，Gate 2 增补 B2）：遍 1 落盘后，按该文件自带纪律（「Edit canonical FIRST, then sync here」）同步其 inline 副本——Gate 2 节清单同步 C1 (b)、C4 (b) 两项，「Critical Check (6 items)」计数行随之改准为 8 项；Gate 4 节 Functional acceptance 内嵌行同步 C2 (b) 一句。本遍只许动上述 inline 节与该计数行，计数行替换为 AC14 的点名例外（见 §9.1）。
- [ ] 遍 2 — Alex SKILL（`.agents/skills/alex/SKILL.md`）：义务块末尾（现 L94 行后、L95 标题前）依次增 C1 (c)、C2 (c) 两行。
- [ ] 遍 3 — 仓根 `AGENTS.md`：在「Memory authority」小节之后插入 C3 短文整节。
- [ ] 遍 4 — 新模板：CREATE `.tad/templates/dispatch-risk-card.md`，全文 = §4.2 草案 (a)。
- [ ] 每遍后即跑该遍对应 AC 行（见 §9.1），红灯停步报 PM，不许攒到最后。

#### 验证方法

AC1–AC12、AC14、AC16（逐行定义见 §9.1）。

#### 🆕 Phase 1 完成证据（Blake必须提供）

- [ ] §9.1 对应行 Verified Output 回填（命令原样输出）
- [ ] `git diff --stat` 五个文件的变更行数记录（删除行数 = 0 的原始输出留 COMPLETION）

### Phase 2: 自证、dogfood 与收口

#### 交付物

- dogfood 风险卡：`.tad/evidence/risk-cards/risk-TASK-20261004-COURSE-JUDGMENT-ADOPTION.md`（以新模板为本 Phase 实施自填；**如实声明（Gate 2 增补 B6）**：本链实施为本仓内规程文本增补，按触发集逐项核对的结论＝**未命中任何触发项**；本卡系新模板的演练件（dogfood），卡内触发项栏照实写「未命中」与核对结论，不许以「同类」比附勾注触发项）
- COMPLETION：`.tad/evidence/completions/COMPLETION-2026-10-04-course-judgment-adoption.md`（按 `.tad/templates/completion-report.md` 强制节成件，gate3_verdict 标记位留空待过门后填）
- session-state 索引区增本链一行

#### 实施步骤

- [ ] 用新模板实填 dogfood 风险卡：头信息齐、≥1 条 REQ、≥1 条 ASM（假设句＋证伪信号＋动作三列实填，不许空话）；头信息触发项栏照实写「未命中（演练件）」及逐项核对结论
- [ ] §9.1 全 16 行逐行实跑并回填 Verified Output（AC13/AC15 在本 Phase 产生对象后跑）
- [ ] 写 COMPLETION（Knowledge Assessment 必答：本链对 patterns 的适用结论——位置断言与载体先行两条是「引用既有条目」还是「值得回写新实例」，二选一写明）
- [ ] session-state 头部索引增一行（链名＋票号＋状态＋本 HANDOFF 路径）

#### 验证方法

AC13、AC15 及 §9.1 全表复跑（Gate 3 执行）。

---

## 7. File Structure

### 7.1 Files to Create

```
.tad/templates/dispatch-risk-card.md                              # C1 表单（§4.2 草案 a 全文）
.tad/evidence/risk-cards/risk-TASK-20261004-COURSE-JUDGMENT-ADOPTION.md  # Phase 2 dogfood 实填件
.tad/evidence/completions/COMPLETION-2026-10-04-course-judgment-adoption.md  # 完工件（Phase 2）
```

### 7.2 Files to Modify

```
.tad/gates/gate-canonical-checklist.md   # 遍 1：卷首 C4(a)；Gate 2 增 C1(b)+C4(b)；Gate 3 增 C2(a)+C4(c)；Gate 4 增 C2(b)
.agents/skills/gate/SKILL.md              # 遍 1b（B2）：Gate 2/Gate 4 节 inline 副本同步 C1(b)/C4(b)/C2(b)，Gate 2「Critical Check」计数行改准（AC14 点名例外）
.agents/skills/alex/SKILL.md              # 遍 2：义务块末尾（现 L94 后）增 C1(c)+C2(c) 两行
AGENTS.md                                 # 遍 3：Memory authority 小节（L75 起）之后插入 C3 整节
.tad/active/session-state.md              # Phase 2：头部多链索引增本链一行
.tad/active/handoffs/HANDOFF-2026-10-04-course-judgment-adoption.md  # §9.1 Verified Output 回填（本件自身）
```

### 7.3 Grounded Against

全部 MODIFY 锚点已在设计步实测（MQ2 表）；`.agents/skills/blake/SKILL.md` 明示**不改**（C2 ③ 的取舍），不在写集内——diff 中出现该文件即越界。

---

## 8. Testing Requirements

本链为规程文本变更，无代码测试套件适用。测试 = §9.1 全行实跑，三类断言齐备：

### 8.1 存在性与逐字断言
AC1/AC3/AC5/AC6/AC10/AC11/AC12：目标条文 grep 在册（命令见 §9.1）。

### 8.2 位置与上限断言
AC4/AC7（义务行行号 ≤120）、AC8（权威顺序升序）、AC9（AGENTS.md ≤188 行）。

### 8.3 负控
AC2（模板不采部件 = 0）、AC14（四件 MODIFY 删除行数 = 0；gate skill 计数行一处替换为点名例外）。

### 8.4 Edge Cases

- 实施期若目标文件已被其他链改动（本仓多链并行，session-state 索引可证）：先重跑 §2.2 基线命令，行号锚漂移按实测新行号执行并在 COMPLETION 记明，不许按本设计旧行号盲改。
- Canonical 若在实施前被他人增项：C1/C4 两项仍插 Gate 2 清单末尾（`Why CE` 行之前），顺序不变。

---

## 9. Acceptance Criteria

- [ ] FR1–FR4 逐项落地且各自装载点位可实测（AC1–AC16）
- [ ] 不采项零落地（AC2＋Gate 3 safety 路全 diff 复核）
- [ ] 纯增补（AC14）且位置可达（AC4/AC7/AC8）
- [ ] dogfood 风险卡经独立 judge 判可证伪（AC15）

## 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE — Gate 3 executes each row

> 干跑基线（Alex step1d，2026-10-04 设计步实测）：AC1–AC12 的目标物在未改树上全部缺失（§2.2／MQ1 实测值），各行均为「对的原因 FAIL」；AC13/AC15 的对象在 Phase 2 才产生。Verified Output 列 post-impl 行由 Blake 在 Gate 3 回填。

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| AC1 | C1 模板三节在册（头信息／损失与需求／证伪式假设表） | post-impl-verifiable | `grep -c '证伪式假设表' .tad/templates/dispatch-risk-card.md && grep -c '^## ' .tad/templates/dispatch-risk-card.md` | ≥1 且 ≥3 | post-impl（Blake 2026-10-04）: 2 / 3 ✓ |
| AC2 | C1 模板不采部件负控（原件被裁六节名——目标与成功度量／权限边界／故障树／缓解与止损／生产就绪／MCP 审查节——均不在模板内；词表末项经 PM 裁定 2026-10-04 由裸词 `MCP` 改为节名串「MCP 审查节」：触发集定串中的 MCP 属裁定 1 逐字件、非夹带，见 `.tad/evidence/pm/2026-10-04-course-adoption-ac2-ruling.md`） | post-impl-verifiable | `grep -cE '目标与成功度量\|权限边界\|故障树\|缓解与止损\|生产就绪\|MCP 审查节' .tad/templates/dispatch-risk-card.md` | 0 | post-impl（Blake 2026-10-04）: 0 ✓（词表按 AC2 裁定口径：末项「MCP 审查节」） |
| AC3 | C1 Canonical Gate 2 风险卡项在册 | post-impl-verifiable | `grep -c 'Risk card for high-risk handoffs' .tad/gates/gate-canonical-checklist.md` | 1 | post-impl（Blake 2026-10-04）: 1 ✓ |
| AC4 | C1 Alex 义务行在册且位置可达 | post-impl-verifiable | `grep -n '高风险派发（触发项：L3 动作（含删除、密钥、公网、生产）／跨仓或跨席位写' .agents/skills/alex/SKILL.md \| cut -d: -f1` | 恰 1 个行号且 ≤120 | post-impl（Blake 2026-10-04）: 行号 94（恰 1 个，≤120）✓ |
| AC5 | C2 Canonical Gate 3 E 维子款在册 | post-impl-verifiable | `grep -c 'Evidence discipline' .tad/gates/gate-canonical-checklist.md && grep -c '证据否决' .tad/gates/gate-canonical-checklist.md` | ≥1 且 ≥1 | post-impl（Blake 2026-10-04）: 1 / 1 ✓ |
| AC6 | C2 Canonical Gate 4 自报不符句在册 | post-impl-verifiable | `grep -c 'Gate 4 复算发现自报与盘上不符' .tad/gates/gate-canonical-checklist.md` | 1 | post-impl（Blake 2026-10-04）: 1 ✓ |
| AC7 | C2 Alex 义务行在册且位置可达 | post-impl-verifiable | `grep -n '评审与验收的每条结论必须附证据指针' .agents/skills/alex/SKILL.md \| cut -d: -f1` | 恰 1 个行号且 ≤120 | post-impl（Blake 2026-10-04）: 行号 95（恰 1 个，≤120）✓ |
| AC8 | C3 AGENTS.md 权威顺序四顺位升序在册 | post-impl-verifiable | `awk '/^### File authority order/{f=1} f&&/explicit instruction in the current conversation/{a=NR} f&&/own originals/{b=NR} f&&/Seat-level standing files/{c=NR} f&&/Injected defaults and overlays/{d=NR} END{print (a&&b&&c&&d&&a<b&&b<c&&c<d)?"ORDER_OK":"ORDER_FAIL"}' AGENTS.md` | ORDER_OK | post-impl（Blake 2026-10-04）: ORDER_OK ✓ |
| AC9 | C3 短文上限（AGENTS.md 增量 ≤20 行） | post-impl-verifiable | `wc -l < AGENTS.md` | ≤188（基线 168） | post-impl（Blake 2026-10-04）: 184 ≤188 ✓ |
| AC10 | C4 Canonical 卷首装载纪律句逐字在册 | post-impl-verifiable | `grep -c '放进文件的东西必须有装载点位' .tad/gates/gate-canonical-checklist.md` | ≥1 | post-impl（Blake 2026-10-04）: 1 ✓ |
| AC11 | C4 Canonical Gate 2 装载点位常查项在册 | post-impl-verifiable | `grep -c 'Load points declared' .tad/gates/gate-canonical-checklist.md` | 1 | post-impl（Blake 2026-10-04）: 1 ✓ |
| AC12 | C4 Canonical Gate 3 位置断言子款在册 | post-impl-verifiable | `grep -c 'Load-point claims' .tad/gates/gate-canonical-checklist.md` | 1 | post-impl（Blake 2026-10-04）: 1 ✓ |
| AC13 | Phase 2 dogfood 风险卡实填（头信息＋ASM 三列实填） | post-impl-verifiable | `test -f .tad/evidence/risk-cards/risk-TASK-20261004-COURSE-JUDGMENT-ADOPTION.md && grep -c '假设' .tad/evidence/risk-cards/risk-TASK-20261004-COURSE-JUDGMENT-ADOPTION.md` | exit 0 且 ≥3（注记 B7：本行计数锚单独不成立——模板标题与表头本身含「假设」字样，空卡亦可能凑够计数；须与 AC15 合取判读，两行同真方成立） | post-impl（Blake 2026-10-04）: 文件在册，「假设」计数 9 ≥3 ✓（与 AC15 合取判读，B7） |
| AC14 | 纯增补断言（四件 MODIFY 删除行数 = 0；gate skill 计数行点名例外） | post-impl-verifiable | `git diff -U0 -- AGENTS.md .tad/gates/gate-canonical-checklist.md .agents/skills/alex/SKILL.md .tad/active/session-state.md \| grep '^-' \| grep -vc '^---'` ＋ `git diff -U0 -- .agents/skills/gate/SKILL.md \| grep '^-' \| grep -v '^---' \| grep -vc 'Critical Check'` | 两段均为 0（后段口径：gate/SKILL.md 的删除行只许「Critical Check (6 items)」计数行一处替换、替换后改准为 8 项，此为点名例外；该文件其余删除行一律不许） | post-impl（Blake 2026-10-04）: 0 / 0 ✓（gate skill 删除行恰计数行一处，点名例外内） |
| AC15 | dogfood 假设表可证伪性（独立 judge） | post-impl-verifiable | spawn independent judge per Rubric Evaluation Protocol against `.tad/evidence/risk-cards/risk-TASK-20261004-COURSE-JUDGMENT-ADOPTION.md` — judge 逐条核 ASM：假设为可证伪陈述句、证伪信号为可观察现象、动作列非空 | verdict: PASS（与 AC13 合取判读，见 AC13 注记 B7） | 对象已就绪（dogfood 卡实填毕）；待 Gate 3 独立 judge 判读，Blake 不自判 |
| AC16 | C1/C4 两新项在 Canonical 与 gate skill 双在册（B2：防 inline 副本漂移） | post-impl-verifiable | `grep -c 'Risk card for high-risk handoffs' .agents/skills/gate/SKILL.md && grep -c 'Load points declared' .agents/skills/gate/SKILL.md` | ≥1 且 ≥1（Canonical 侧在册由 AC3/AC11 守，两面同在方成立） | post-impl（Blake 2026-10-04）: 1 / 1 ✓ |

## 9.2 Expert Review Status (Alex 必填)

> 双审已由 PM 另派独立会话（tech／fit 两路）落盘，本设计步未自审；PM 合并裁定 CONDITIONAL PASS，增补回填如下。

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| Gate 2 tech 路（独立会话） | CONDITIONAL：P1=1（§2.2 漏列 `.agents/skills/gate/SKILL.md` inline 副本、Phase 1 无同步遍）／P2=3（风险卡路径大小写不一致、C3 草案行数差一行、触发集窄于原件适用面观察项） | B2（§2.2 补行＋增补注、Phase 1 遍 1b、§7.2、AC14 点名例外、AC16 新增）；B3（§4.2 (a)(b) 路径统一小写）；B4（§4.4 ② 改 15 行）；观察项经 PM 裁定 1 拍板入 B1 | 增补已落盘，待 PM 定点核销账 |
| Gate 2 fit 路（独立会话） | CONDITIONAL：P1=1（C1 触发项枚举为设计自拟口径、与提案原件适用面不一致）／P2=3（AC2 负控词表缺三节名、Phase 2 dogfood 比附勾注、AC13 计数锚偏弱） | B1（裁定 1 触发集逐字回填 FR1 与 §4.2 三处同串）；B5（AC2 词表补 §1/§2/§6 三节名）；B6（Phase 2 改如实声明、删比附勾注）；B7（AC13 注记与 AC15 合取） | 增补已落盘，待 PM 定点核销账 |

### Overall Assessment (post-integration)

- Gate 2: **CONDITIONAL PASS**（PM 合并裁定 2026-10-04；双路 CONDITIONAL、P0=0；CF-1…CF-5 五项裁定全照设计立场，见 §4.6 回填；增补清单 B1–B7 已回填本版，销账待 PM 定点核）

---

## 10. Important Notes

### 10.1 Critical Warnings

- ⚠️ §4 草案条文**逐字落盘**：措辞、标点、全半角均按草案；发现草案有错别字或歧义，停步报 PM/Alex，不许 Blake 自行润色（条文即判据，AC 的 grep 锚与草案同源）。
- ⚠️ CF-1…CF-5 已全部裁定回填（§4.6）：C1 项入清单（CF-1，边界句为「只许增存在性检查项」）、Why CE 行不许动（CF-2）、C3 落仓根 AGENTS.md（CF-4）；实施形态与裁定回填不符处，停步报 PM/Alex。
- ⚠️ Alex SKILL 是超限大文件：增行只许进义务块（遍 2 锚点），不许在文件其他位置追加任何文字。

### 10.2 Known Constraints

- 本仓多链并行：目标文件可能被他链先行改动，实施前必须重测基线（§8.4）。
- 本链不 commit、不 push（提交与推送归 PM 收口动作，沿本仓近期链惯例）。
- 条文与设计正文均不许出现版本号复述。

### 10.3 🆕 Sub-Agent使用建议

- [ ] **spec-compliance-reviewer** — Gate 3 逐行执行 §9.1（流程内建，非 Blake 自选）
- [ ] 其余 sub-agent 不需要：本链为单遍文本增补，串行实施即可

---

## 12. 🆕 Sub-Agent使用记录

| Sub-Agent | 用途 | 结果 |
|-----------|------|------|
| 无（串行实施，Blake direct） | §10.3 定：除 Gate 3 spec-compliance-reviewer（流程内建、由 PM 另派独立会话）外不需 sub-agent；AC15 独立 judge 同属 Gate 3 环节，实施期未 spawn | 实施全程单遍串行完成；AC15 待 Gate 3 判读 |

---

**Alex confirms:** This handoff contains everything Blake needs for implementation — 四项逐项五段设计、条文草案全文、装载点位、§9.1 逐行可跑验证、CF 冲突点名交 Gate 2 裁。
**Date:** 2026-10-04
**Status:** Gate 2 CONDITIONAL PASS（增补 B1–B7 已回填本版 v1.1；待 PM 定点核销转 PASS 后 Blake 开工）

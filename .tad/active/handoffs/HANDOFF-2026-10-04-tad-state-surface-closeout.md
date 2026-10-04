---
# Quality Chain Metadata (Alex 必填 - Phase 4 Hook 将基于此阻塞 Gate 3)
task_type: mixed       # doc 状态面纠偏 + shell 检查脚本 + git 收口
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
required_evidence_manifest:
  - .tad/evidence/designs/2026-10-04-tad-state-surface-closeout-design.md (本 handoff 的设计本体)
  - Gate 2 dual reviews ×2（已落盘：`.tad/evidence/reviews/2026-10-04-gate2-tech-review-state-surface-closeout.md` + `.tad/evidence/reviews/2026-10-04-gate2-fit-review-state-surface-closeout.md`，均 CONDITIONAL PASS）+ 合并裁定 `.tad/evidence/reviews/2026-10-04-gate2-merge-verdict-state-surface-closeout.md`
  - COMPLETION-2026-10-04-tad-state-surface-closeout.md (Blake 完工件)
tad_scope: full
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-10-04
**Project:** TAD Framework（状态面与证据面收口，PM 自查 R1 第一批：P2 + P3）
**Task ID:** TASK-20261004-TAD-STATE-SURFACE-CLOSEOUT
**Handoff Version:** 1.0
**Design:** `.tad/evidence/designs/2026-10-04-tad-state-surface-closeout-design.md`（本 handoff 的设计本体，逐项口径以设计为准）
**Source:** `.tad/evidence/pm/2026-10-04-tad-self-review-r1.md`

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-10-04（PM 另派两独立会话双审已落盘；本节于 Gate 2 修订步回填）

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 设计 §2（纠偏+机制）/ §3（终态改写）/ §4（处置表）/ §5（台账）四块齐备，实施切分见设计 §6 |
| Components Specified | ✅ | 逐项到文件:行（设计 §2.1 A1–A12）；C 表逐项到路径（设计 §4） |
| Functions Verified | ✅ | MQ2 已验：`derive_target_version`（tad.sh:31-39）、release-verify 读 version.txt（:388-391）均实存 |
| Data Flow Mapped | ✅ | MQ3 数据流图：version.txt → 派生/校验 → 状态文档头部；各仓 version.txt → 生成器 → 台账 |

**Gate 2 结果**: ⚠️ **CONDITIONAL PASS（修订中，待 PM 验盘转 PASS）** — 双审两路均 CONDITIONAL PASS：
技术路（`.tad/evidence/reviews/2026-10-04-gate2-tech-review-state-surface-closeout.md`，T1/T2 亲跑复现、T6 满足、条件 Amd-1/2/3）＋
契合路（`.tad/evidence/reviews/2026-10-04-gate2-fit-review-state-surface-closeout.md`，F1/F4 PASS、条件 C-1/2/3/4）；
PM 合并裁定：`.tad/evidence/reviews/2026-10-04-gate2-merge-verdict-state-surface-closeout.md`（条件去重为修订 R1–R6，全部文档级）。
两项重点裁定已落：(a)「3.1」**废除、全文归一 semver**（契合路 F2 专属裁定，技术路同判；设计 §2.3 次选案作废）；
(b) waiver 指针已由 PM 落盘（`.tad/evidence/reviews/2026-10-04-waiver-p1p3-gate2-evidence.md`，生效日 2026-10-04），Phase 2 前置已闭合。

**Alex确认**: R1–R6 修订落盘并经 PM 逐项验盘、本节状态转 PASS 前，Blake 不得开工；转 PASS 后 Blake 独立根据本文档 + 设计文档完成实现。

> **Process Gate 2 = dual reviews on disk** (P2 tax-cut). PASS ⇔ two independent artifacts under `.tad/evidence/reviews/` (P0=0 or sanctioned). Do **not** write a dispatch lock that waits for a human chat string `/gate 2`.

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节（含设计文档全文）
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 所有"强制问题回答（MQ）"都有证据
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 每个Phase的交付物和证据要求都清楚
- [ ] 确认可以独立使用本文档完成实现

❌ 如果任何部分不清楚，**立即返回Alex要求澄清**，不要开始实现。

---

## 1. Task Overview

### 1.1 What We're Building
把 TAD 自家仓的「状态面」（NEXT.md / ROADMAP.md / AGENTS.md 等状态文档）与「证据面」
（Gate 4 证据终态、未入 git 的证据链尾巴、下游版本台账）收口到与盘上现实一致，
并给状态面装上防再过期的机制（版本 SSOT 纪律 + detect-only 检查 + 发版收口挂钩）。
分三 Phase：A 状态文档纠偏与机制（设计 §2）、B+C1/C2 证据终态与入账（设计 §3/§4）、C3+D 留痕入账与下游台账（设计 §4/§5）。

### 1.2 Why We're Building It
**业务价值**：TAD 是 53 个下游仓的框架源头；自家状态文档写错版本、证据停在 CONDITIONAL，
等于给所有下游和后续 Agent 喂错误现状。PM 近期「自报与盘上不符」的翻车，框架级版本就是这一批。
**用户受益**：维护者（人）打开任何一份状态文档，看到的都是真的；问「谁在哪一版」有台账可答。
**成功的样子**：状态面检查脚本对真树 exit 0；Gate 4 证据为终态 PASS 且历史原文一字未动；
`git status` 中**非忽略面**证据链条目清零（按处置表；`.tad/evidence/`、`.tad/archive/` 两忽略树的载体口径见 Gate 2 合并裁定的载体裁定（乙）与 §9.1 AC14）；下游台账可重跑再生且与逐仓实读一致。

### 1.3 🆕 Intent Statement（意图声明）

**真正要解决的问题**：不是「文档写错了几行」，而是**没有任何机制阻止状态文档再次过期**、
**证据结论停在半截状态无人收口**。改字只是表面，装机制 + 销账才是本体。

**不是要做的（避免误解）**：
- ❌ 不是发版：不 push、不 tag、不 bump 版本号（version.txt 保持 3.0.0）
- ❌ 不是补造历史证据：Gate 2 缺失证据只许走显式 waiver，严禁回填生成
- ❌ 不是全仓文档大扫除：改面以设计 §2.1 表为闭集；表外文件只许在 §9.1 验出同病时回报 Alex，不许顺手改
- ❌ 不碰 P1（hooks 强制力/真机回归）与 P5（体量瘦身）——后续批次，不在本批夹带

**Blake请确认理解**：
```
在开始实现前，请用你自己的话回答：
1. 这个功能解决什么问题？
2. 用户会如何使用？
3. 成功的标准是什么？
（按本仓流程以 COMPLETION/开工回执形式作答即可；Gate 2 双审 PASS 前不要动手。）
```

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别
- [x] gate-design（门与证据纪律）
- [x] release-sync（版本/同步面的排除契约）
- [x] handoff-design（派生物 vs 事实源、并发终端提交纪律）
- [x] principles（L1：版本 grep 作用域、deny-list 方向、工具优先）

### 步骤 2：历史经验摘录

**⚠️ Blake 必须注意的历史教训**：

1. **Claims Need Carriers**（patterns/gate-design.md）— 完成声明没有盘上载体就不算声明。
   本批的 C 表本质就是给一批「只有盘上件、没有 git 载体」的结论补载体；
   B 项终态结论的载体 = Gate 4 文件的状态行 + §8 附记，两处都要在。
   `failure_mode`：只改状态行不写附记 → 终态无据，与原病同形。

2. **Decouple Detect-from-Heal at Release Gates**（patterns/gate-design.md）—
   发版流里的检查只许 detect（只读、fail-closed），修复是独立的人工/Alex 动作。
   本批的 `state-surface-check.sh` 必须只读：**脚本内出现任何写文件/自动回填逻辑即 Gate 3 FAIL**。

3. **A Version-Staleness Grep Gate Without a Maintained Exclusion Contract Ends Every Release in Override**
   （patterns/release-sync.md）— 版本扫描分不清「现行声明」与「历史引用」时，不许靠改历史凑绿。
   本批对应：检查脚本的扫描面是显式文件清单（设计 §2.2 机制 2），CHANGELOG/归档/fixture pins
   永远不在面内；**禁止**为了让检查变绿去改 CHANGELOG 历史行或 DONE 历史行。

4. **Deny-List Beats Allow-List for Sync Sets; Version Grep Must Scope to git-ls-files**
   （principles.md）— 版本类 grep 必须圈定范围（此处：显式状态文件清单），裸全仓扫描捡历史噪声。
   C 表的提交面同理用 pathspec 闭集逐项列明，不用通配。

5. **Concurrent Terminals Share the Git Index**（patterns/handoff-design.md）—
   提交前查 staged 区，全部 commit 用 `git commit -- <pathspec>` / 显式 `git add -- <paths>`，
   **禁止 `git add -A`**；本仓当时有他线 rider（docs/pm 改动），扫进来即 Gate 3 FAIL。

6. **Manifest + Directory Isolation**（patterns/handoff-design.md）— 目录是事实源、清单是派生索引。
   D 项台账是派生索引：可重跑再生，禁止手改台账正文（改了下轮生成即覆盖，且属造假面）。

7. **Never Hand-Write What an Existing Tool Already Does**（principles.md）—
   版本派生已有 `tad.sh derive_target_version` 与 release-verify 的 version 读取，
   新脚本只许消费 version.txt，不许再造一套版本解析/存储。

### Blake 确认
- [ ] 已读上列 7 条，且知道每条对应的本批红线（在 COMPLETION 中逐条回应）

---

## 2. Background Context

### 2.1 Previous Work
- R1 自查报告（问题来源与基线）：`.tad/evidence/pm/2026-10-04-tad-self-review-r1.md`
- P1P3 原刀：`.tad/active/handoffs/HANDOFF-2026-09-15-platform-adapters-p1p3.md`（已入 git，`2fb80bf5`）
- §18 补缺（2026-10-03）：两个 Epic 文件夹与存根已落盘未入 git（C 表批 C2 的对象）

### 2.2 Current State
HEAD `b78173b3` = origin/main（0/0）；工作树 23 条 porcelain（7 M + 1 D + 15 未跟踪条目）；
Gate 4 证据停在 CONDITIONAL PASS（verdict: PARTIAL）；下游 53 仓版本无台账（基线分布见设计 §5.4）。

### 2.3 Dependencies
- Gate 2 waiver 的落盘指针（Phase 2 前置，见 §8.4）——**已闭合**：`.tad/evidence/reviews/2026-10-04-waiver-p1p3-gate2-evidence.md`（PM 2026-10-04 补记）；
- Gate 2 双审落盘（全批开工前置）——已落盘，两路 CONDITIONAL PASS，合并裁定见 Gate 2 节；R1–R6 修订经 PM 验盘转 PASS 后开工；
- 无网络、无新依赖；脚本只用 bash + git + python3 stdlib（禁 yaml）。
  （2026-10-04 更正注记：原写「仓内 python3 无 yaml 模块」——技术路评审在本机实测 `import yaml` 成功（PyYAML 6.0.2），该事实前提在本机不成立；禁 yaml 约束保留，理由是脚本须在任何机器上只靠 stdlib 可跑，不依赖此前提。）

## 3. Requirements

### 3.1 Functional Requirements
- FR1：设计 §2.1 表 A1–A12 逐项落地，一项不漏、一项不扩。
- FR2：新建 `.tad/hooks/lib/state-surface-check.sh`（detect-only，只读）+ `.tad/tests/state-surface-fixture/` 负控 fixture（含 `**Version**: 9.9` 粗体冒号负控行）；release 收口挂钩按设计 §2.2 机制 3 落地（release-verify 增 `state-surface` 转调 + runbook 正本 `.agents/skills/alex/references/publish-protocol.md` 对应节加收口三步文字，含 commit 文件集断言步——执行者 = 发版执行者，命令见设计 §2.2 机制 3）。
- FR3：Gate 4 证据按设计 §3.2 改写为终态：状态行 + §3 逐项 CLOSED 注记 + 新增 §8 附记；§1–§7 原文一字不动。
- FR4：`COMPLETION-2026-09-15-platform-adapters-p1p3.md` 入 git 前做一行 push 状态事实订正（订正处标 2026-10-04 日期，不静默改写）。
- FR5：C 表（设计 §4）逐项执行：判 commit 的分三批 pathspec 提交；判保留本地的不动；不新增任何删除；仅提交 §4.2 既存的 hillclimb 删除一笔。
- FR6：新建 `.tad/scripts/scan-downstream-versions.sh` 并生成首份 `.tad/evidence/pm/downstream-versions.md` 入仓。
- FR7：A2 迁档与 D 项 handoff 删除同批提交；NEXT 头部规矩行后补自查对账指针句（设计 §2.2 机制 4）。

### 3.2 Non-Functional Requirements
- NFR1：全部新脚本 `set -u` 级别健壮、无网络、无 yaml、无 node；路径含中文仓名可跑（下游含中文目录）；目录名含尾随空格或非 ASCII（如 `Pokémon `）时，生成器不得 trim/规范化目录名，台账仓名须与磁盘字节一致（设计 §5.1）。
- NFR2：任何 commit 不含 §7 清单外路径；不 push、不 tag、不改 version.txt。
- NFR3：证据文件历史保真——Gate 4 原文、COMPLETION 原文（除 FR4 一行订正）、迁档文件逐字保留。

### 3.3 Optimization Target (Optional)
N/A — 本批不触发 Autoresearch Mode。

## 4. Technical Design

### 4.1 Architecture Overview
四块独立、同批串行：A 状态面（改字 + 机制脚本 + 收口挂钩）→ B 证据终态（追加式改写）→
C 入账（三批 pathspec 提交）→ D 台账（生成器 + 派生索引）。设计本体见设计文档 §2–§5，本节只列组件与落点。

### 4.2 Component Specifications
| 组件 | 落点 | 要点 |
|---|---|---|
| 纠偏编辑 | 设计 §2.1 点名文件 | 逐字口径按设计表；「3.1」处置按 Gate 2 裁定的一案执行（废除为默认案） |
| 状态面检查 | `.tad/hooks/lib/state-surface-check.sh`（新） | 只读五项检查（设计 §2.2 机制 2）；exit 0/1；输出逐项 PASS/FAIL 行 |
| 负控 fixture | `.tad/tests/state-surface-fixture/`（新） | 一份版本号写错的 NEXT 头部副本 + 运行说明；检查对其必须 exit 1 |
| 收口挂钩 | `.tad/hooks/lib/release-verify.sh`（改：增 `state-surface` 子命令转调）+ `.agents/skills/alex/references/publish-protocol.md` 对应节（改：收口三步，含文件集断言步） | 只加转调与文字，不改既有子命令行为 |
| 终态改写 | `.tad/evidence/reviews/2026-09-15-gate4-acceptance-platform-adapters.md`（追加式改） | 设计 §3.2 五点；原文零改；改后以 `git add -f` 单文件例外入主仓（载体裁定（乙）） |
| 入账提交 | git（本地 main，三批） | 批 C1 证据链 / 批 C2 §18 成套 + A2 迁档与 handoff 删除 / 批 C3 PM 留痕；批界以设计 §4 为准（A2/D 归 C2）；A2 迁档件在忽略树内，随 C2 以 `git add -f` 例外入账 |
| 台账生成器 | `.tad/scripts/scan-downstream-versions.sh`（新） | 入参 yun-sync 根（默认仓父目录）；MISSING/EMPTY 显式记法 |
| 下游台账 | `.tad/evidence/pm/downstream-versions.md`（新，生成物） | 文件头三行固定（设计 §5.1）；禁止手改；入仓走 `git add -f` 单文件例外（载体裁定（乙）） |

### 4.3 Data Models
台账行：`仓名 | 版本-or-MISSING-or-EMPTY | 备注`；汇总段计数与明细行数对账（设计 §5.3）。

### 4.4 API Specifications
N/A（无 API）。脚本 CLI：`state-surface-check.sh [--repo <path>]`；`scan-downstream-versions.sh [--root <yun-sync根>] [--out <path>]`。

### 4.5 User Interface Requirements
N/A（无 UI）。文档头部即「界面」：NEXT/ROADMAP 头部行格式以设计 §2.1 改后文本为准。

## 5. 🆕 强制问题回答（Evidence Required）

### MQ1: 历史代码搜索
#### 搜索证据
```
# 版本口径全仓扫描（Alex 2026-10-04 实跑）
grep -rn "v3\.1\|Version 3.1" AGENTS.md README.md INSTALLATION_GUIDE.md docs/MULTI-PLATFORM.md
→ AGENTS.md:9 / README.md:3,5 / INSTALLATION_GUIDE.md:3 / docs/MULTI-PLATFORM.md:3,6,214 全部命中
grep -n "当前版本\|READY_FOR_GATE2" NEXT.md → :9 版本行 2.44.5；:15-20 hillclimb READY_FOR_GATE2
git log --oneline -3 → b78173b3（hillclimb 落地）/ 2fb80bf5（P1P3）/ 20223774（v3.0.0）
```
#### 决策说明
「3.1」不是孤例笔误而是五文件同病，故 A9/A10 同批处理；hillclimb 条目与 session-state 正文同源过期，A2/A12 分工处理（队列迁档、索引状态词）。

### MQ2: 函数存在性验证
#### 函数清单
| 引用 | 存在性 | 证据 |
|---|---|---|
| `derive_target_version`（tad.sh） | ✅ | `grep -n derive_target_version tad.sh` → 定义 :33，调用 :283/:2239 |
| release-verify 读 version.txt | ✅ | `.tad/hooks/lib/release-verify.sh:388-391` |
| `release-verify.sh version` 子命令 | ✅ | 同文件 :565 版本行作用域规则 |
| Gate 2 waiver 文件（P1P3 专用） | ✅ 已落盘 | 成件时实查不存在（原 §8.4 前置）；PM 于 2026-10-04 补记落盘 `.tad/evidence/reviews/2026-10-04-waiver-p1p3-gate2-evidence.md`（1,359 B，不回填日期，生效日 2026-10-04），技术路 T6 已核满足 → Phase 2 前置已闭合 |

### MQ3: 数据流完整性
#### 数据流对照表
| 源 | 流向 | 校验点 |
|---|---|---|
| `.tad/version.txt` | tad.sh 派生 / release-verify 读取（既有） | 既有机制，不动 |
| `.tad/version.txt` | 状态文档头部行（NEXT/ROADMAP/PROJECT_CONTEXT 等） | 新 `state-surface-check.sh` 五项（机制 2） |
| 各下游仓 `.tad/version.txt` | 生成器扫描 → `downstream-versions.md` | 重跑 0 diff + 行数对账（设计 §5.3） |
#### 数据流图
```
[.tad/version.txt] ──derive──> [tad.sh / release-verify]（既有）
        │
        └──declare──> [状态文档头部] ──check(detect-only)──> [state-surface-check.sh]
[53× 下游 version.txt] ──scan──> [scan-downstream-versions.sh] ──> [downstream-versions.md（派生索引）]
```

### MQ4: 视觉层级
无 UI。本批的「界面」是状态文档头部：统一格式 = 版本行只许一行、值与 version.txt 一致、
版位表述不带数字。样例见设计 §2.1 A1/A5/A9 改后文本。UI Mockup：N/A（文档批）。

### MQ5: 状态同步
#### 状态存储位置
- 版本状态：`.tad/version.txt`（唯一存储，SSOT）
- 队列状态：`NEXT.md`（VM 侧单写规则不变）
- 证据状态：各 evidence 文件本体（本批三件交付物——Gate 4 终态改写件、A2 迁档件、D 台账——以 `git add -f` 单文件例外入主仓，载体裁定（乙）；其余 evidence 仍以盘 + maintainer-evidence 分支为载体，该分支停摆另立独立单）
#### 状态流图
```
[发版 bump version.txt] ──同 commit 回填──> [NEXT/ROADMAP 头部] ──收口检查──> [state-surface exit 0 才许宣告完成]
[下游各自 version.txt] ──生成器──> [台账] （单向派生，永不回写下游）
```
✅ 同步时机明确：发版收口 + 每轮自查开跑（设计 §5.2）；不存在双向写，无不同步面。

## 6. Implementation Steps（分Phase）

### Phase 1: A — 状态文档纠偏 + 防过期机制
#### 交付物
- [ ] 设计 §2.1 A1–A12 全部落地（A9/A10 按 Gate 2 裁定案）
- [ ] `.tad/hooks/lib/state-surface-check.sh` + fixture，真树 exit 0 / fixture exit 1
- [ ] release-verify `state-surface` 转调 + runbook 收口三步文字
#### 实施步骤
1. 先落检查脚本与 fixture（先有尺子再改字，改完即验）
2. 按 A 表逐项改字；每改一文件跑一次检查脚本记录输出
3. A2 迁档文件创建（逐字迁入 NEXT 原条目）
#### 验证方法
- §9.1 AC1–AC6

### Phase 2: B + C1/C2 — 证据终态 + 入账（前置：waiver 指针到位）
#### 交付物
- [ ] Gate 4 证据终态改写（设计 §3.2）
- [ ] COMPLETION 一行订正（FR4）
- [ ] 批 C1、C2 两次 pathspec 提交（含 A2 迁档 + hillclimb handoff 删除）
#### 实施步骤
1. waiver 指针验在（`.tad/evidence/reviews/2026-10-04-waiver-p1p3-gate2-evidence.md`；不在 → 停，报 PM，不许自行开工 B 项）
2. 终态改写 → §9.1 AC7 自验
3. 分批提交：每批先列 pathspec 清单、提交后 `git status` 复核
#### 验证方法
- §9.1 AC7–AC8、AC10

### Phase 3: C3 + D — 留痕入账 + 下游台账
#### 交付物
- [ ] 批 C3 提交（docs/pm 留痕五件套 + ops-knowledge）
- [ ] `.tad/scripts/scan-downstream-versions.sh` + 首份台账以 `git add -f` 例外入仓
#### 验证方法
- §9.1 AC8–AC10

## 7. File Structure

### 7.1 Files to Create
```
.tad/hooks/lib/state-surface-check.sh            # 机制 2 检查脚本（只读）
.tad/tests/state-surface-fixture/                # 负控 fixture
.tad/scripts/scan-downstream-versions.sh         # D 生成器
.tad/evidence/pm/downstream-versions.md          # D 台账（生成物）
.tad/archive/next/NEXT-completed-through-20261004.md  # A2 迁档
.tad/active/handoffs/COMPLETION-2026-10-04-tad-state-surface-closeout.md  # Blake 完工件
```

### 7.2 Files to Modify
```
NEXT.md / ROADMAP.md / AGENTS.md / README.md / INSTALLATION_GUIDE.md / docs/MULTI-PLATFORM.md / PROJECT_CONTEXT.md   # A 纠偏（设计 §2.1）
.tad/active/session-state.md                     # A12 索引状态词（仅索引行）
.tad/hooks/lib/release-verify.sh                 # 收口转调（只增子命令）
.agents/skills/alex/references/publish-protocol.md   # 机制 3：发版收口三步文字（含文件集断言步）
.tad/evidence/reviews/2026-09-15-gate4-acceptance-platform-adapters.md   # B 追加式终态改写
.tad/active/handoffs/COMPLETION-2026-09-15-platform-adapters-p1p3.md     # FR4 一行订正
+ 设计 §4 判 commit 的全部路径（入账提交，内容零改，FR4 除外）
```

### 7.3 Grounded Against
- `NEXT.md`（head 80 行 + 全文 grep，2026-10-04 Alex 实读）
- `ROADMAP.md`（全文，3819 B）
- `AGENTS.md`（头部 blockquote :9，实读）
- `.tad/evidence/reviews/2026-09-15-gate4-acceptance-platform-adapters.md`（全文，11175 B）
- `.tad/active/session-state.md`（全文）
- `.tad/version.txt` / `tad.sh:26,31-39` / `.tad/hooks/lib/release-verify.sh:388-391,565`（grep 实证）
- `git status --porcelain`（含 `-uall`）/ `git diff-tree -M 2fb80bf5` / 下游逐仓扫描（2026-10-04 实跑，输出见设计 §1/§3.1/§5.4）

## 8. Testing Requirements

### 8.1 Unit Tests
- 检查脚本：fixture 负控（exit 1）+ 真树正控（exit 0）双向，见 §9.1 AC5/AC6。

### 8.2 Integration Tests
- 生成器可重放：连跑两次除 `generated-at` 外 0 diff（§9.1 AC9）。

### 8.3 Edge Cases
- 下游仓名含中文（外刊阅读等）：生成器须正常处理（NFR1）；
- version.txt 为空 → 台账记 EMPTY 而非崩溃或空白；
- 工作树有他人 staged rider：提交面用 pathspec 隔离（AC10）。

## 8.4 Friction Preflight

| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|---|---|---|---|---|
| Gate 2 waiver 落盘指针 | Phase 2 开工前验指针在盘 | ✅ 已闭合：PM 已落盘 waiver 文件 `.tad/evidence/reviews/2026-10-04-waiver-p1p3-gate2-evidence.md`（2026-10-04）并回指本 handoff；技术路 T6 已核满足 | 无 — 不许以「口径已知」替代 | 指针缺失 → Phase 2 BLOCKED（当前已闭合） |
| Gate 2 双审 | PM 另派独立会话双审 | ✅ 已落盘：两路 CONDITIONAL PASS + 合并裁定（指针见 Gate 2 节）；R1–R6 修订经 PM 验盘转 PASS | 无（自审永不等价） | 未转 PASS → 全批不得开工 |
| 并发终端 staged rider | 每次提交前查 staged 区 | 显式 pathspec 提交 | 无 | 扫入清单外路径 → Gate 3 FAIL |
| 「3.1」裁定 | Gate 2 裁废除案或明示案 | ✅ 已裁：废除案（契合路 F2 专属裁定，技术路同判），设计 §2.3 已追记关闭 | 无 | 两案混用 → Gate 3 FAIL |

**Status Enum**: `READY` / `BLOCKED` / `DEGRADED_WITH_APPROVAL` / `EQUIVALENT_SUBSTITUTE` / `NOT_APPLICABLE_WITH_REASON`
当前：Phase 1 = READY；Phase 2 = READY（waiver 前置已闭合）；Phase 3 = READY——三 Phase 共同前置 = Gate 2 修订（R1–R6）经 PM 验盘转 PASS。

## 8.5 Feedback Collection (Non-Code Artifacts)
```yaml
feedback_required: false
artifact_type: generic
notes: "文档/脚本批，人类验收点在 Gate 4 由 Alex 重算 §9.1，不另设 feedback 通道"
```

## 8.6 🆕 Test Evidence Required
Blake必须提供：
- [ ] 检查脚本真树/fixture 两次运行输出（COMPLETION 附原文）
- [ ] 每批 commit 的 `git show --stat` 与提交后 `git status --porcelain` 输出
- [ ] 台账生成器连跑两次的 diff 输出

---

## 9. Acceptance Criteria

Blake的实现被认为完成，当且仅当：
- [ ] §9.1 逐行 PASS（Gate 3 执行）
- [ ] 三批 commit 均在本地 main、文件集与设计 §4 一致、未 push
- [ ] Gate 4 证据原文零改（diff 只含状态行、§3 注记行、新增 §8）
- [ ] 禁区零触碰（§10.2）

## 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE — Gate 3 executes each row

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---|---|---|---|---|
| 1 | AC12 等价重组（B 项事实基础）对 `2fb80bf5` 成立 | pre-impl-verifiable | command: `git diff-tree --no-commit-id --name-status -r -M 2fb80bf5` 与 handoff §6.1 闭集比对（脚本见设计 §3.1 B2） | `MISSING=[] EXTRA=[] DELETED=[]` | ✅ 实跑（2026-10-04 Alex）：`MISSING=[] EXTRA=[] DELETED=[]`，rename 呈 R100 |
| 2 | 下游基线计数可复现 | pre-impl-verifiable | command: `ls -d ~/workspace/yun-sync/*/.tad \| wc -l` + 逐仓读 version.txt 计数（设计 §5.4 方法） | 总数 53；3.0.0 ×22；MISSING ×2；EMPTY ×1 | ✅ 实跑：53 / 22 / 2 / 1（与 R1 一致） |
| 3 | NEXT 头部版本行与 version.txt 一致、旧行消失 | post-impl-verifiable | command: `python3 -c "import pathlib; v=pathlib.Path('.tad/version.txt').read_text().strip(); t=pathlib.Path('NEXT.md').read_text(); head=t.splitlines()[:12]; ok=any(v in l for l in head) and 'next patch 2.44.6' not in t.split('## 🔴')[0]; print(ok); raise SystemExit(0 if ok else 1)"` | `True`，exit 0 | (post-impl) |
| 4 | hillclimb 条目迁档且队列清零 | post-impl-verifiable | command: `test -f .tad/archive/next/NEXT-completed-through-20261004.md && grep -q 'TASK-20260929-AGENT-EVAL-HILLCLIMB-L2' .tad/archive/next/NEXT-completed-through-20261004.md && ! grep -q 'READY_FOR_GATE2' NEXT.md` | exit 0 | (post-impl) |
| 5 | ROADMAP 纠偏落地 | post-impl-verifiable | command: `python3 -c "import pathlib; t=pathlib.Path('ROADMAP.md').read_text(); ok=('Updated 2026-09-02 for v2.43.1' not in t and 'Claude Code and Codex share' not in t and 'mirrored skills' not in t); print(ok); raise SystemExit(0 if ok else 1)"` | `True`，exit 0 | (post-impl) |
| 6 | 版本复述统一（「3.1」处置按 Gate 2 裁定 = 废除案，两路同判；基线：放宽模式重跑 7 条，含 docs/MULTI-PLATFORM.md:3 粗体冒号行，旧模式 6 条漏检该行） | post-impl-verifiable | command: `grep -rnE '(Version\|v)\*{0,2}:?\*{0,2} ?3\.1([^0-9]\|$)' AGENTS.md README.md INSTALLATION_GUIDE.md docs/MULTI-PLATFORM.md \| wc -l` | `0` | (post-impl) |
| 7 | 状态面检查对真树 PASS | post-impl-verifiable | command: `bash .tad/hooks/lib/state-surface-check.sh` | exit 0，逐项 PASS | (post-impl) |
| 8 | 状态面检查负控有效（非 vacuous） | post-impl-verifiable | fixture: `bash .tad/hooks/lib/state-surface-check.sh --repo .tad/tests/state-surface-fixture`（fixture 布局按脚本 --repo 语义，见设计 §2.2） | exit 1，且 FAIL 项指向版本行；fixture 中 `**Version**: 9.9` 粗体冒号负控行必须被检查命中报错（设计 §2.2） | (post-impl) |
| 9 | Gate 4 证据终态成立且历史保真 | post-impl-verifiable | command: `python3 -c "import pathlib; t=pathlib.Path('.tad/evidence/reviews/2026-09-15-gate4-acceptance-platform-adapters.md').read_text(); ok=('终态' in t and 'verdict: PASS' in t and '## 8.' in t and 'CONDITIONAL PASS' in t and 'AC1–AC11' in t); print(ok); raise SystemExit(0 if ok else 1)"`（末两项证原文保留） | `True`，exit 0 | (post-impl) |
| 10 | C 表入账完成、保留项未动 | post-impl-verifiable | command: `git status --porcelain` 与设计 §4 对照：判 commit 路径零出现；`docs/pm/ops/` 与 `docs/pm/now.md` 等保留项仍在 | 对照一致（Gate 3 逐项核表） | (post-impl) |
| 11 | 下游台账可重放且计数对账 | post-impl-verifiable | command: `bash .tad/scripts/scan-downstream-versions.sh --out /tmp/dv1.md && bash .tad/scripts/scan-downstream-versions.sh --out /tmp/dv2.md && diff <(grep -v generated-at /tmp/dv1.md) <(grep -v generated-at /tmp/dv2.md) && grep -c '^|' .tad/evidence/pm/downstream-versions.md` | diff 空；明细行数与 `ls -d ~/workspace/yun-sync/*/.tad \| wc -l` 对账（基线 53，Gate 3 以实跑值为准） | (post-impl) |
| 12 | 禁区与提交面守卫 | post-impl-verifiable | command: `git log --oneline b78173b3..HEAD` 各 commit 的 `git diff-tree --no-commit-id --name-only -r <sha>` 并集 ⊆ 本 handoff §7 + 设计 §4 清单；且 `git diff b78173b3..HEAD -- .tad/version.txt CHANGELOG.md` 为空 | 并集在清单内；两文件零 diff | (post-impl) |
| 13 | AC13 机制 3 发版收口挂钩落地（FR2）：release-verify 转调在位、runbook 三步文字在位、文件集断言步点名执行者 | post-impl-verifiable | command: `grep -q 'state-surface' .tad/hooks/lib/release-verify.sh && grep -q 'state-surface' .agents/skills/alex/references/publish-protocol.md && grep -q '发版执行者' .agents/skills/alex/references/publish-protocol.md` | exit 0（三处全命中）；断言步执行者 = 发版执行者（设计 §2.2 机制 3）；Gate 3 另跑 `bash .tad/hooks/lib/release-verify.sh state-surface` 应与 AC7 同为 exit 0 | (post-impl) |
| 14 | AC14 三件交付物载体验证（载体裁定（乙））：Gate 4 终态改写件、A2 迁档件、D 台账均以 `git add -f` 单文件例外入主仓 | post-impl-verifiable | command: `git ls-files -- .tad/evidence/reviews/2026-09-15-gate4-acceptance-platform-adapters.md .tad/archive/next/NEXT-completed-through-20261004.md .tad/evidence/pm/downstream-versions.md \| wc -l` | `3`（三件全在主仓跟踪内；且 `.gitignore` 未改） | (post-impl) |

> **Verification Method grammar**: 本表每行均为 command | path-check | fixture 文法，无散文行。

## 9.2 Expert Review Status (Alex 必填)

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| Alex (self-check) | requirement-elicitation 3–5 轮未走，与规程原件冲突 | 设计 §0.1 报明；Gate 2 契合路 F3 裁定本批可接受（效力仅限本批）、技术路同判 | Closed（Gate 2 裁定） |
| Alex (self-check) | 「3.1」废除推翻 P1P3 handoff §6.3 既有授权 | 设计 §2.3；Gate 2 两路同判废除案（契合路 F2 专属裁定），明示次选案作废 | Closed（按废除案执行） |
| Alex (self-check) | Gate 2 waiver 无落盘文件，B 项正当性悬空 | §8.4 Friction 前置；PM 2026-10-04 落盘 waiver 件（路径见 MQ2），技术路 T6 已核满足 | Closed（前置已闭合） |
| Alex (self-check) | AC12 原命令无 `-M`、且以 HEAD 为对象，前进后不可原样重跑 | 设计 §3.1 B2 等价重组 + 方法差异注明；终态附记须载明 | Resolved（方法已定） |

### Experts Selected（供 PM 派 Gate 2 双审时参考）

1. **Reviewer A — 机制与脚本面** — state-surface-check 的扫描面/exclusion 是否完备、detect-only 是否守住、fixture 是否真负控。
2. **Reviewer B — 证据与历史保真面** — B 项终态改写的正当性（§3.1 核验链）、追加式改写是否真零改原文、C 表处置是否逐项有据。

### Overall Assessment (post-integration)
- Gate 2 双审：**已执行**——技术路 CONDITIONAL PASS + 契合路 CONDITIONAL PASS，PM 合并裁定 CONDITIONAL PASS（`.tad/evidence/reviews/2026-10-04-gate2-merge-verdict-state-surface-closeout.md`）；修订 R1–R6 已由原设计者落盘，待 PM 验盘转 PASS 后交 Blake。

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ 证据文件只许追加式改写：Gate 4 原文、迁档文件、CHANGELOG 历史行，一字不动（FR3/NFR3）。
- ⚠️ waiver 不到位，Phase 2 不许开工——这不是拖延，是 B 项正当性的组成部分。

### 10.2 Known Constraints（禁区）
- 不写实现代码之外的越界动作由角色分工约束；本 handoff 内 Blake 的实现面即 §7 清单。
- 禁止：commit 之外的 push / tag / 发版；改 `.tad/version.txt`；补造任何历史 Gate 证据；
  `git add -A`；手改台账正文；动用户本机 `.claude/` 任何内容；改 `docs/pm/now.md` 等 C 表判保留本地的文件。

### 10.3 🆕 Sub-Agent使用建议
- [ ] **test-runner** — Phase 1 完成后跑检查脚本双向验证
- 其余不建议：本批以逐项对表为主，parallel 无收益。

---

## 11. 🆕 Learning Content（可选）

### 11.1 Decision Rationale: 「3.1」版位名的处置

| 方案 | 优点 | 缺点 | 为什么没选/选 |
|------|------|------|-----------|
| A 废除版位数字，统一 semver（选中，默认案） | 单一口径，机制 2 可全机器校验 | 推翻 P1P3 §6.3 授权，需 Gate 2 追认 | ✅ 选中：双口径已实证误导（R1-P2），数字形态无不可替代收益 |
| B 保留「3.1」+ 一行明示双口径定义 | 不推翻旧授权 | 每个新读者仍要多学一条定义；检查退化为查明示行存在 | 次选：Gate 2 若否 A 则落此案，二选一不许两可 |

**💡 Human学习点**：同一事实有两种「都对」的写法时，成本不在写的那一刻，在此后每一次核对的那一刻。

---

## 12. 🆕 Sub-Agent使用记录

Blake完成后填写：

| Sub-Agent | 是否调用 | 调用时机 | 输出摘要 | 证据链接 |
|-----------|---------|---------|---------|---------|
| test-runner | | | | |

---

**Handoff Created By**: Alex (Solution Lead) — Gate 1 设计成件，待 Gate 2 双审
**Date**: 2026-10-04
**Version**: 1.0

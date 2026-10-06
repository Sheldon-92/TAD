# Quality Chain Metadata (Alex 必填 - Phase 4 Hook 将基于此阻塞 Gate 3)
task_type: mixed       # 本体收口批：规程条文增补＋脚本断言（code）＋投影物化＋版本 bump；无 UI
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
required_evidence_manifest:
  - .tad/active/TICKET-20261005-tad-closeout-batch.md（本链票：7 件清单、版本口径、红线）
  - .tad/evidence/pm/2026-10-04-gm-inputs-judgment.md（PM 判断正本：输入 1/2/4 处置口径以此为准）
  - gm/.tad/evidence/reports/2026-10-tad-pm-inputs.md（GM 输入正本：现象与证据路径）
  - .tad/evidence/reviews/2026-10-04-gate4-acceptance-course-judgment-adoption.md（D 线 Gate 4 验收件：C1 定稿出处 L6/L23/L44 与计数行遗留注记）
  - Gate 2 dual reviews ×2（PM 另派独立会话，落 .tad/evidence/reviews/）+ PM 合并裁定（落 .tad/evidence/pm/）——未齐备前 Blake 不得开工
  - COMPLETION-2026-10-05-tad-closeout-batch.md (Blake 完工件，落 .tad/evidence/completions/)
tad_scope: full
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-10-05
**Project:** TAD Framework（本体收口批：已判断事项七件一次落地＋版本口径收口）
**Task ID:** TASK-20261005-TAD-CLOSEOUT-BATCH
**Handoff Version:** 1.0（初版，Gate 2 双审未跑——双审与 PM 合并裁定齐备前 Blake 不得开工）
**Ticket:** `.tad/active/TICKET-20261005-tad-closeout-batch.md`
**Judgment:** `.tad/evidence/pm/2026-10-04-gm-inputs-judgment.md`（口径以此为准；GM 输入件是输入不是结论）

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 待 PM 另派独立会话双审（tech／fit 两路）。本设计步未自审、未自批；下表为设计自查，非 Gate 2 结论。

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | 设计自查 ✅（待双审） | §4.1 提交面分层＋七件逐件五段（现状／落点／草案／装载点位／验证） |
| Components Specified | 设计自查 ✅（待双审） | 逐件到文件与节位：CREATE 12 文件（投影）＋MODIFY 9 件，锚点行号均设计步实测（§7、MQ2） |
| Functions Verified | 设计自查 ✅（待双审） | MQ2 锚点存在性逐项实跑（脚本行号、节位标题、计数行均在盘） |
| Data Flow Mapped | 设计自查 ✅（待双审） | MQ3：判断 → 票 → 本 HANDOFF → Gate 2 → 实施 → Gate 3/4 → PM 提交 → GM 刷新令 |

**Gate 2 结果**: **待双审**。双审 PASS（或 CONDITIONAL 经 PM 合并裁定＋增补回填销账）前，Blake 不得开工；裁定与本设计不一致处，以裁定为准。

### 高风险触发项核对（Canonical Gate 2 新增项，本步逐项核对结论）

| 触发项 | 命中？ | 依据 |
|--------|--------|------|
| L3 动作（删除、密钥、公网、生产） | 未命中 | Blake 实施面为单仓内规程条文、脚本断言、投影文件与版本行增补；无删除（件 4 为 CREATE）、无密钥、无公网、无生产面 |
| 跨仓或跨席位写 | 未命中 | 写集全部在本仓 `/home/hatch/workspace/yun-sync/TAD` 内；下游仓（trading-agent）只定迁移口径、本批不写 |
| 引入新连接器、MCP 或依赖 | 未命中 | 断言用脚本既有 shell 能力，不引新依赖 |
| 不可逆动作 | 未命中 | 全部改动 git 可回滚；脚本断言可单独回退 |
| 涉及金额 | 未命中 | 无 |
| 对外动作 | 未命中 | 提交与推送为 PM 收口动作，不在 Blake 实施面 |
| PM 判断为高风险者 | 待 PM | 本步结论为未命中；PM 若另判高风险，须在本节补风险卡（模板 `.tad/templates/dispatch-risk-card.md`）后 Blake 才许开工 |

> **Process Gate 2 = dual reviews on disk** (P2 tax-cut). PASS ⇔ two independent artifacts under `.tad/evidence/reviews/` (P0=0 or sanctioned). Do **not** write a dispatch lock that waits for a human chat string `/gate 2`.

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 本文件是唯一实施依据；判断口径冲突时以 PM 判断正本为准，设计与裁定冲突时以 Gate 2 合并裁定为准
- [ ] 开工前置：Gate 2 双审＋PM 合并裁定在盘且结论放行；CF-4（件 4b）裁定结果已读
- [ ] Step 0 路径断言：cwd 必须等于 `/home/hatch/workspace/yun-sync/TAD`，每个目标文件动手前以绝对路径 `test -f` 断言（本仓有仓外同名误改事故史，铁律）
- [ ] 仓外禁写；零 git 写操作（提交与推送是 PM 收口动作，不归你）
- [ ] 只改 §7 写集；批外新发现只登记进 COMPLETION 报 PM，不许顺手扩批
- [ ] 不动 `.gitignore`、不动 SC3；版本号只许出现在 §4.9 指定的两处（version.txt＋AGENTS.md 代际标记），别处不许复述
- [ ] 捕获输出一律唯一路径（mktemp 或直落本仓证据目录）——本批件 6 立的纪律自本链起对本链生效，负控 fixture 先行示范

---

## 1. Task Overview

### 1.1 What We're Building

本体收口批：把已判断、已定性、只差落盘的七件一次走完完整 TAD 链落地，并完成版本口径收口（提议升 patch 版），使 PM 能在 Gate 4 后一次提交入 main、向 GM 同步批号＋哈希，GM 据此给先对齐的 12 仓发刷新对齐令。七件：

1. **C1 提交面定界**：仓根 `AGENTS.md`「File authority order」节（D 线 C3 定稿，+16 行，现为工作区未提交改动）——本件不定稿内容，只盘清提交面：哪些未提交件入本批、哪些属保留集不入本批，并给出提交判据（diff 与 D 线定稿逐字一致）。
2. **台账口径头注**（GM 输入 1 落地）：下游版本台账加覆盖口径头注，消除「总数 53」对 goal 型仓的误读面。台账是派生件、禁止手改——头注经生成脚本落盘。
3. **项目自加槽契约**（GM 输入 2 落地）：发布/同步规程立条文——下游仓根文件中的项目自加内容以标记保留区保全，发布同步不许静默吞。
4. **research-methodology 投影补生成**（GM 输入 4 落地之一）：26 个 pack 中唯一缺 `.agents/skills/` 投影者，按既有投影的同构规则从 pack 本体物化，内容全部来自 pack 本体、不许手写编造。
5. **登记↔投影一致性断言**（GM 输入 4 落地之二）：pack 扫描（scan-packs.sh）加断言——registry 登记每件必须有 `.agents/skills/` 投影，缺即红（exit 1 并点名）。
6. **S5 第五件**（/tmp 同名捕获串台）：捕获路径唯一化纪律落进证据采集规程原件。
7. **gate skill 计数行修正**（D 线遗留）：`.agents/skills/gate/SKILL.md` Gate 3 inline 副本计数行（现作 6 项）与 Canonical Gate 3（7 项）对齐——inline 副本漏列 Provenance 项，一并补回。

### 1.2 Why We're Building It

- 七件全部是「判断已成、只欠落盘」：GM 输入判断 2026-10-04 已成型并回 GM；C1 已经 D 线全链 PASS，只差提交；计数行差异是 D 线 Gate 4 明记的遗留。攒成一批一次走链，避免每件各跑一趟 Gate 链与一次提交。
- 不落的代价是具体的：台账口径不清会让 GM 的版本验收对 goal 型仓持续无行可比；无自加槽契约，下游每次重装都可能静默吞掉项目自加内容（trading-agent 首段即现存实例）；投影缺件无断言，下一件 pack 漏生成仍会长期静默；捕获串台已有实证事故（证据被他仓输出覆写、报告件数靠运气对）。

### 1.3 🆕 Intent Statement（意图声明）

让 TAD 本体回到「盘面即口径」的状态：已裁定的每件事都在规程原件里有条文、在扫描里有断言、在台账里有注记、在版本号里有体现——下游与 GM 拿到的源面与 PM 的判断面逐字一致，不再靠任何人的记忆补齐。

### 1.4 非范围（明确不做 — 不许夹带）

- 不动下游任何仓（trading-agent 首段只定迁移口径，迁移由 GM 在其下次对齐时按契约执行）。
- 不改 tad.sh 机械行为：件 3 只立条文契约，安装器的槽提取/回贴机械化不在本批。
- 不扩版本扫描器（输入 1 判断：扫描器不扩，goal 型仓不入扫描面）。
- 不升 minor/major；不改 `.tad/version.txt` 以外的版本复述面（CF-3 口径：release-verify 门若判其他文件为 live stale，停步报 PM）。
- 不碰保留集文件（§7.4 清单）：NEXT.md、docs/pm 状态面、B 线迁档、A 线脚本与各票据的提交去向均不在本批。
- 不处理输入 3（买卖代际不一致，PM 判断已闭合、本体无新增处置）。

### 1.5 Gate 结构（六行）

- Gate 1：票已立（PM），需求＝七件清单本身，不另设澄清轮。
- Gate 2：独立会话双审（tech／fit）落 `.tad/evidence/reviews/`，PM 合并裁定；CF-1…CF-5 逐项裁定，CF-4 裁定决定件 4b 与 AC10 存废。
- 实施：Blake 按 §6 Phase 0–3 串行执行，逐 Phase 回填 §9.1。
- Gate 3：独立会话双审（code／safety），逐行重算 §9.1；新立的证据纪律（E 维子款）对本链生效——自报与重算不符即该行 FAIL。
- Gate 4：Alex 从盘上重算 §9.1 后下结论；human CHECK 记「CHECK 待人」。
- 收口：PM 提交入 main 并推送（沿 R1 路径经 grokbox gh 登录态），同步 GM 批号＋哈希；提交面按 §4.2 分层表与 PM 收口裁定。

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别

命中索引条目：Release & Sync（release-sync.md）、AC Verification（ac-verification.md）、Pack Build Rules（pack-build-rules.md）、Shell Portability（shell-portability.md——本批要改两个 .sh 脚本，动手前必读该条）。

### 步骤 2：历史经验摘录

- **Principles「Deny-List Beats Allow-List…」＋「…at EVERY Copy Granularity, and Verifiers Must Match Each Granularity」**（2026-06-01，SAFETY）：验证器只验它看的那一层——pack 断言必须验在 pack 扫描这一层（件 5 落 scan-packs.sh 而非另起检查脚本）；版本一致性 grep 必须 scope 到 git tracked 集，原始全树走查 88% 是噪声。本批 AC11/AC15 按此设计：断言与扫描同体、口径面枚举以盘面实测为准。
- **Principles「Never Hand-Write What an Existing Tool Already Does」**（2026-05-28，SAFETY）：件 4 投影必须走与既有投影同构的物化规则（从 pack 本体派生），禁止凭记忆手写一份「像样」的 SKILL.md；件 2 头注必须走生成脚本，禁止手改派生台账。
- **Principles「Rewiring a Gate's Prose Can Trip a grep -c SAFETY Count」**（2026-05-31，SAFETY）：件 7 改计数行属「计数即判据」面——判据用行集 diff＋逐项点名，不用单一 grep 计数下结论（AC14 三段合取）。
- **Patterns release-sync**：gitignore 语义不过镜像、parity 以 diff 为准——件 4 的同构判据用 sha256 逐件比对而非「目录在不在」。
- **Canonical 卷首装载纪律**（D 线刚立）：放进文件的东西必须有装载点位——本批每件在 §4 逐件写明装载点位；件 4b 的存在理由正是此条（投影无指针行＝无装载点位）。

### Blake 确认

- [ ] 已读上述条目；改 `.sh` 前已读 shell-portability.md 全文

---

## 2. Background Context

### 2.1 Previous Work

- GM 输入四件：GM 报告正本（`gm/.tad/evidence/reports/2026-10-tad-pm-inputs.md`）→ PM 判断正本（2026-10-04，四件均亲查盘面后判断）→ 本票把输入 1/2/4 的处置与 D 线遗留、C1、S5 第五件攒成一批。
- C1 的 +16 行出自课程判断落地链（TICKET-20261004-course-judgment-adoption）采纳项 C3，Gate 3 双审 PASS、Gate 4 PASS（验收件在盘）；GM 在 S8 总核中发现该改动未提交、落在 S6 对齐波次之间，报 PM 定去向（条件 C1），PM 已定性「链内正式改动、非漂移」并回 GM：随本批提交。
- research-methodology 缺投影已被四个下游席位在 S4/S6 对齐中同现 warning（GM 台账多节佐证），定性为发布源单件漏生成＋检测缺口。

### 2.2 Current State（设计步 2026-10-05 亲跑基线）

| 面 | 实测基线 |
|----|----------|
| `AGENTS.md` 未提交 diff | `git diff --numstat` ＝ 16 增 0 删，单一 hunk：`### File authority order` 节，位于「Memory authority」节后、「Interaction decisions」节前；全文 184 行 |
| 版本面 | `.tad/version.txt` 首行 `3.0.0`；`AGENTS.md` L9 代际标记 `(v3.0.0)`；`.tad/config.yaml` L3 `version: 3.0.0`；`tad.sh` L26 `TARGET_VERSION="3.0.0"`（L39 有从 version.txt 派生的赋值路径）；`.tad/TAD-VERSION` 内容 `3.0.0`（脚本面无引用，疑似遗留复述——归 CF-3 门判） |
| 工作区全量 | `git status --porcelain` 共 68 行：tracked 修改 8 件（含 handoffs 删除 11 件、B 线迁档）、未跟踪含票据 3、A 线脚本 2、风险卡模板 1、open-cards 多件、docs/pm/ops/ 等——分类见 §4.2 |
| 台账头注 | `grep -c '覆盖口径' .tad/scripts/scan-downstream-versions.sh` ＝ 0；台账件同查 ＝ 0；生成脚本头部输出块在脚本 L90–102（printf 序列），台账头 4 行后接「# 下游仓版本台账」 |
| 自加槽契约 | `grep -c '项目自加槽\|PROJECT-SLOT' .agents/skills/release-runbook/SKILL.md` ＝ 0；tad.sh 根文件段在 L1224 起（FR-4b：内容不同先备份，未做槽保留/回贴）；trading-agent 根 AGENTS.md 172 行＝本体 168（当时版）＋首 4 行自加段，首段 L1–4（标题行＋空行＋入口段＋空行），L5 起为本体标题 |
| pack 投影 | `.tad/capability-packs/` 26 件登记齐全；`.agents/skills/` 投影 25 件，唯 research-methodology 缺（`test -d` 不成立）；registry 中该 pack 行在 `.tad/capability-packs/pack-registry.yaml` L147–154（status: frozen） |
| 投影同构样本 | academic-research／agent-memory／ai-evaluation 三件实测：投影 SKILL.md ＝ CAPABILITY.md 去 `status:` 行（正文其后各自演化、与本体已有差异——演化差异非生成规则）；投影不含 CAPABILITY.md／README.md／CHANGELOG.md／install.sh（capability-skill.sh 明文 forbidden root artifacts）；references／checklists／scripts／LICENSE 类文件随投影在册（checklists 先例：ai-prompt-engineering、product-thinking、web-frontend、web-ui-design；CONVENTIONS.md 先例：web-frontend） |
| pack 断言 | `grep -c 'PROJECTION' .tad/scripts/scan-packs.sh` ＝ 0（无任何登记↔投影校验）；scan-packs.sh 以 `--packs-dir` 可覆盖扫描根，OUTPUT 随 PACKS_DIR 派生（fixture 可隔离） |
| 捕获纪律 | `grep -c '捕获路径唯一化纪律' .tad/tasks/evidence-collection.md` ＝ 0；该文件 §7 在 L245–283，「## Pattern Recognition Protocol」在 L284 |
| gate 计数行 | Canonical Gate 3 ＝ 7 项（清单 L37 起，MECE 注同行）；gate SKILL inline 副本在 L275–292：L279 注「6 items check 6 distinct artifacts」、L280「Critical Check (6 items)」，列表 6 项——漏 Canonical 第 7 项「Provenance non-empty (advisory)」 |
| AGENTS.md pack 指针表 | 表在仓根 AGENTS.md「Capability Packs」节：含表头共 26 行（25 pack 行），`grep -c '^| research-methodology |' AGENTS.md` ＝ 0（该 pack 无指针行） |

### 2.3 Dependencies

- 无外部依赖。判据原件：Canonical 清单（`.tad/gates/gate-canonical-checklist.md`）、capability-skill.sh（validate/verify 子命令）、scan-packs.sh、scan-downstream-versions.sh、release-verify.sh（仅 detect-only 枚举用）。
- 提交与 GM 刷新令在本链之外（PM 收口），不构成 Blake 实施依赖。

---

## 3. Requirements

### 3.1 Functional Requirements

- FR1（件 1）：提交面盘点成表——工作区全部未提交项逐项分类为「本批写集／C1 件／保留集」，C1 件给出可复算的逐字判据；分类表落 COMPLETION。
- FR2（件 2）：台账头部出现覆盖口径头注，文字与 PM 判断输入 1 口径逐字对齐；头注由生成脚本输出，手改台账不算落地。
- FR3（件 3）：发布/同步规程原件中立有项目自加槽契约：标记形态、覆盖前提取备份、覆盖后回贴＋逐字比对判据、无槽存量逐案留痕、trading-agent 迁移口径五要素齐备。
- FR4（件 4）：research-methodology 在 `.agents/skills/` 出现同构投影：SKILL.md 由 CAPABILITY.md 派生（仅去 status 行），其余文件与 pack 本体逐件字节一致，forbidden 件零出现，AC7 结构判据组全过（Gate 2 合并裁定 3 路线 A 修订：不以 capability-skill.sh validate/verify 退出码为判据，校验器漂移已批外登记，见 §4.5）。
- FR5（件 4b，条件于 CF-4 裁定）：仓根 AGENTS.md pack 指针表补 research-methodology 一行，格式与邻行同构。
- FR6（件 5）：scan-packs.sh 每次扫描后断言登记集 ⊆ 投影集，缺件 exit 1 并点名；负控 fixture 可复现「缺一件即红、补齐即绿」。
- FR7（件 6）：证据采集规程原件立有捕获路径唯一化纪律：唯一路径（mktemp 或直落本仓证据目录）＋引用前与盘上实存交叉核对，两要素齐备。
- FR8（件 7）：gate SKILL Gate 3 inline 副本与 Canonical 对齐为 7 项：计数行两处改准、Provenance 项补回，行集 diff 除此三处外无其他变化。
- FR9（版本）：版本口径收口——`.tad/version.txt` 与 AGENTS.md 代际标记同步到新 patch 版；派生件（registry、台账）在新版下重生成至自洽终态。

### 3.2 Non-Functional Requirements

- NFR1 纯增补优先：条文类改动只增不删（计数行替换、版本行替换为点名例外）；任何删除行必须能在 §9.1 对应行里点名。
- NFR2 派生件只走生成器：台账与 registry 的一切变化必须由对应脚本重跑产生，禁止手改派生件凑数。
- NFR3 可回滚：每 Phase 的改动可按文件单独回退；脚本断言（件 5）出问题时回退该脚本一件不影响其余件。
- NFR4 证据纪律：本链自产捕获（fixture 输出、盘点表、干跑结果）一律唯一路径落盘（件 6 纪律对本链即时生效）。

### 3.3 Optimization Target (Optional)

无（收口批，不设优化目标）。

---

## 4. Technical Design

### 4.1 Architecture Overview

本批没有新系统，只有「条文—断言—派生—版本」四种落地形态，各归其位：

| 形态 | 件 | 载体 | 装载点位（谁在何时读到/触发） |
|------|----|------|------------------------------|
| 判据定界 | 1 | COMPLETION 盘点表＋本节分层表 | PM 收口提交时按表选面；Gate 4 按表复核 |
| 生成器头注 | 2 | scan-downstream-versions.sh 头部输出块 → 台账 | 每次台账重生成（publish-protocol step3e 收口步）；GM 验收读台账头 |
| 规程条文 | 3 | release-runbook SKILL.md 新节 | 发布/同步执行者开工必读手册（publish-protocol Guard 2 强制读 runbook）；同步覆盖根文件时触发 |
| 物化投影 | 4/4b | `.agents/skills/research-methodology/`＋AGENTS.md 指针行 | 三 harness 的 skill 发现面＋根文件关键词路由表，会话装载时触发 |
| 扫描断言 | 5 | scan-packs.sh 扫描后断言段 | 每次 pack 扫描（含 publish step3c 的 registry regen）自动触发 |
| 规程条文 | 6 | evidence-collection.md 新节 | 任何角色采集证据/捕获输出前查规程原件时读到 |
| 同步修正 | 7 | gate SKILL Gate 3 inline 副本 | Gate 3 执行者经 gate skill 装载时读到（Canonical 为源、本件为副本对齐） |
| 版本行 | 版本 | `.tad/version.txt`＋AGENTS.md 代际标记 | 版本单源；台账与 registry 由它派生 |

提交面分三层（件 1 的定界结论，提交动作归 PM 收口）：

- **甲层·本批写集**：§7.1/§7.2 全部文件（Blake 本批亲手改/建）。
- **乙层·C1 件**：`AGENTS.md` 中 D 线 +16 行节（既存未提交，非 Blake 所写；Blake 只复核逐字性）。AGENTS.md 同时承载甲层两处小改（指针行、代际标记），同文件三 hunk 分行判读。
- **丙层·保留集**：§7.4 全表——本批不碰、提交与否由 PM 另行裁定。

### 4.2 Component 件1：C1 提交面盘点与逐字判据

- **现状**：见 §2.2。`AGENTS.md` diff 为单一 hunk +16/−0；工作区另有 67 行状态项。
- **Blake 动作**：Phase 0 跑 `git status --porcelain` 全量输出（捕获落唯一路径文件），逐行按下列规则分类，成表写入 COMPLETION：
  - 甲层＝§7.1/§7.2 路径；
  - 乙层＝`AGENTS.md` 的 D 线节（以 hunk 计，不以文件计）；
  - 丙层＝其余全部：`NEXT.md`、`docs/pm/{acceptance,auth,intent,now,ops-knowledge}.md`、`docs/pm/ops/`、`docs/pm/open-cards/**`、`.tad/active/TICKET-*.md`（含本票）、`.tad/active/handoffs/` 的 11 件删除（B 线迁档）、`.tad/project-knowledge/patterns/{ac-verification,shell-portability}.md`（在飞链 KA）、`.tad/scripts/{evidence-freshness-check,sync-maintainer-evidence}.sh`（A 线脚本，其入 main 另有 PM 裁定）、`.tad/templates/dispatch-risk-card.md`、`.tad/TAD-POINTER.md`、`.agents/skills/alex/SKILL.md` 与 `.tad/gates/gate-canonical-checklist.md`（D 线改动——注意 gate SKILL 不在此列：它属甲层，因件 7 在其上落笔，见 CF-5）、`.tad/active/TICKET-20261004-maintainer-evidence-branch-revival.md`（状态回写）、`ROADMAP.md`（§7.4 已列，Gate 2 增补补点名）、本链流程自产件——本 HANDOFF（`.tad/active/handoffs/HANDOFF-2026-10-05-tad-closeout-batch.md`）、设计完工说明（`.tad/evidence/completions/2026-10-05-tad-closeout-batch-design-note.md`）、Gate 2 双路 verdict（`.tad/evidence/reviews/2026-10-05-gate2-fit-review-closeout-batch.md`、`.tad/evidence/reviews/2026-10-05-gate2-tech-review-closeout-batch.md`）、PM 合并裁定件（`.tad/evidence/pm/2026-10-05-closeout-batch-gate2-merged-ruling.md`）、Gate 2 增补完工说明（`.tad/evidence/completions/2026-10-05-tad-closeout-batch-gate2-amend-note.md`）。
  - 分类遇 §7 与上表都未点名的新路径 → 停步报 PM，不许自行归类。**例外（Gate 2 合并裁定 4 预授权）**：本链后续流程自产件（实施完工说明、Gate 3/4 verdict、COMPLETION、完事卡等，凡属本链 task_id 路径模式内的文件）不在此限——实施者于 Phase 0 就地分类归丙层并在 COMPLETION 留痕，不触发停步阀；路径模式外的新路径仍须停步报 PM。
- **逐字判据**：Phase 0 以 `sed -n '/^### File authority order/,/^### Interaction decisions/p' AGENTS.md | head -n -1 | sha256sum` 记录基线哈希（记入 COMPLETION）；Phase 3 同命令复算，两值必须全等。定稿出处：D 线 Gate 4 验收件对采纳 3 的实测行（节在 L80、四顺位、全文 184 行）。

### 4.3 Component 件2：台账口径头注（经生成脚本）

- **落点**：`.tad/scripts/scan-downstream-versions.sh` 头部输出 printf 序列——在 `source-of-truth:` 行（脚本 L92 的 printf）之后、空行 printf（L93）之前，插入一行：
  ```bash
  printf '覆盖口径：本台账覆盖范围为 yun-sync 席位仓；goal 型仓为轻量装、无 version.txt 版本面，不在扫描口径内，其缺席不构成版本缺失。\n'
  ```
  头注文字与判断正本输入 1 处置口径逐字对齐（「覆盖范围为 yun-sync 席位仓」「goal 型仓为轻量装、无版本面、不在口径内」为判断原文短语）。
- **台账重生成时机**：不在本件当场重跑——推迟到 Phase 3 版本 bump 之后一次重跑（脚本以 version.txt 派生 CURRENT，提前重跑会留下旧版口径的中间态台账）。重跑前先以脚本 `--help`/源码确认默认 OUT 即台账路径（脚本头注 L6–7 已写明）。
- **装载点位**：台账头是 GM 版本验收的比对面；脚本是台账唯一生成路径（publish-protocol step3e 收口步重跑），头注随每次重生成存续，手改台账会被下次重跑冲掉——这正是头注必须进脚本的原因。

### 4.4 Component 件3：项目自加槽契约（release-runbook 立条文）

- **落点**：`.agents/skills/release-runbook/SKILL.md`，在「## Mechanical authority and exit codes」节之后、「## Global safety stops」节之前，新增一节（全文如下，逐字落盘，不许改写）。

```markdown
## Project slot in downstream root files （项目自加槽契约）

Some root files synced to downstream projects (e.g. `AGENTS.md`, an
`extra_root_files` entry) are files the project itself may have authored
content in. That content is project-owned. The sync side MUST NOT silently
swallow it.

### Slot markers

Project-owned content in a synced root file lives between a marker pair, at
the head of the file, before the TAD body:

    <!-- PROJECT-SLOT:BEGIN -->
    ...project-owned content, verbatim...
    <!-- PROJECT-SLOT:END -->

### Sync obligations

1. Before overwriting a downstream root file, extract the slot content (if
   any) and keep it with the pre-sync backup the installer already takes.
2. After writing the new source version, re-apply the slot content verbatim
   at the same position (file head, before the TAD body). The overwrite is
   complete only when the re-applied slot content compares byte-identical
   to the backup.
3. Content that differs from source but sits OUTSIDE a slot is unslotted
   legacy self-added content: never drop it silently. Record it per case
   (file, line range, disposition) in the sync evidence and flag it for
   slot migration.

### Slot discipline

- Slot content MUST NOT restate a version number; the version of record
  stays `.tad/version.txt`.
- This contract covers root files delivered via `extra_root_files` (the
  tad.sh root-file segment is the mechanical surface it governs). It
  changes no installer behavior by itself; it is the norm the installer
  and the sync operator are checked against.

### Known legacy instance

`trading-agent/AGENTS.md` lines 1-4 (project entry segment) predate the
slot. Migration, at that repo's next alignment (executed by the sync side,
not by this contract): wrap those 4 lines verbatim in the marker pair,
position unchanged (file head); nothing else in the file is touched by
the migration.
```

- **设计说明**：tad.sh 根文件段（L1224 起，FR-4b）已有「内容不同先备份」的机械面，本契约在其上补「槽内内容回贴＋逐字比对才算完成」的规范面；本批不改 tad.sh（票面红线：只立条文）。标记用 HTML 注释对（在 Markdown/AGENTS.md 中不渲染、不干扰正文装载），位置钉在文件首——与现存实例形态一致（trading-agent 首段即在文件首）。
- **装载点位**：release-runbook 是发布/同步执行者的必读手册（publish-protocol Guard 2 强制先读）；同步执行 phase 5/6（runbook Seven-phase overview）覆盖根文件时本节即触发面。

### 4.5 Component 件4：research-methodology 投影物化

- **物化规则**（自三件样本实测归纳，见 §2.2）：投影＝pack 本体的可装载子集——
  - `CAPABILITY.md` → `SKILL.md`：frontmatter 删 `status:` 一行，其余 frontmatter 行与正文**逐字不变**（样本中正文的后续演化差异是装后演化、非生成规则，本件是首次物化，不许引入任何演化式改写）；
  - 子目录与根文件按原样复制：`references/`（5 件）、`checklists/`（1 件）、`scripts/`（2 件）、`LICENSE`、`LICENSE-ATTRIBUTION.md`、`CONVENTIONS.md`——与源逐件 sha256 全等；
  - 不入投影：`CAPABILITY.md`（本体名）、`README.md`、`CHANGELOG.md`、`install.sh`（capability-skill.sh 明文 forbidden root artifacts）。
- **产物清单**（CREATE 12 件，路径全在 `/home/hatch/workspace/yun-sync/TAD/.agents/skills/research-methodology/`）：
  `SKILL.md`、`references/{planning,quality-control,sourcing,analysis,output}.md`、`checklists/research-quality.md`、`scripts/{saturation-check.sh,source-quality.sh}`、`LICENSE`、`LICENSE-ATTRIBUTION.md`、`CONVENTIONS.md`。
- **执行法**：以 shell 复制＋单行删除完成派生（`grep -v '^status: '` 只许删中 frontmatter 的 status 行——先断言 CAPABILITY.md 全文 `^status: ` 恰 1 次命中且在 frontmatter 区内，再执行）；禁止用编辑器凭记忆重写 SKILL.md。
- **自检（结构判据组，Gate 2 合并裁定 3 路线 A 修订）**：按 AC7 修订后七项结构判据自检——投影目录与 SKILL.md 在册／文件集与本节产物清单 12 件集合相等／禁入四件 0 命中／投影树内符号链接 0／SKILL.md frontmatter `name:` 值＝目录名／正文占位符（`{{`／`[TODO]`／`[TBD]`）0 命中／除 SKILL.md 外 11 件与 pack 本体逐件字节全等。**不以 `capability-skill.sh validate`／`verify` 的退出码为判据**——该校验器 frontmatter 键集口径与现行投影惯例漂移（按本节规则在 /tmp 模拟物化实跑，validate/verify 仍退出 2，证据见 Gate 2 增补完工说明），漂移属批外登记（见本节末）。
- **装载点位**：`.agents/skills/` 是三 harness 的一等 skill 发现面（仓根 AGENTS.md Runtime status 段）；件 4b 指针行是关键词路由面。下游随下次重装自然带入（PM 判断已定，不阻塞推广）。
- **批外登记（校验器漂移，Gate 2 合并裁定 3）**：`capability-skill.sh` 的 frontmatter 契约（只许 `name:`＋`description:` 两键）与现行全部 26 件投影的惯例（保留 `keywords:`／`type:`）漂移，且该校验器未被 tad.sh、publish-protocol、Canonical 任一规程引用——此项登记为批外独立事项，记入本批完事卡遗留节另行处置；本批不改校验器、不改 frontmatter 惯例（路线 B 不采）。

### 4.6 Component 件4b：AGENTS.md pack 指针行（条件件，CF-4 裁定后定存废）

- **落点**：仓根 `AGENTS.md`「Capability Packs」表内，按 pack 名序插入一行（research-methodology 序位在 rag-retrieval 与 synthetic-data 之间——以表内现有行序为准，Blake 落笔前先读表确认邻行）：
  ```
  | research-methodology | Unified research pipeline for AI agents — 5-phase (Plan→Source→Curate→ | `.agents/skills/research-methodology/SKILL.md` |
  ```
  第二列为 registry description 的**前 70 字符硬截断**（邻行 13 行 registry 派生行第二列实测 69–70 字符硬截断，如 academic-research 行截在「review, c」）；本行 70 字符（Gate 2 增补订正：原稿给定串实长 96 字符、自称「71 字符」均误，与 AC10 判据带冲突，经 PM 合并裁定 2 钉死为前 70 字符），Blake 落盘后以 AC10 的 startswith＋长度判据复核，不许自拟描述文字。

### 4.7 Component 件5：登记↔投影一致性断言（scan-packs.sh）

- **落点**：`.tad/scripts/scan-packs.sh`——扫描循环中收集包名集合；循环结束后、结尾 `echo "scan-packs.sh: scanned …"` 之前，植入断言段（形态如下，变量名可按脚本既有风格微调，语义不许变）：
  ```bash
  # --- Registry↔projection consistency assertion ---
  # Every registered pack MUST have a projection at
  # <root>/.agents/skills/<name>/SKILL.md. Missing projection = red.
  if [ -n "${PACKS_DIR_WAS_OVERRIDDEN:-}" ]; then
    ASSERT_ROOT="$(cd "$PACKS_DIR/../.." 2>/dev/null && pwd -P)"
  else
    ASSERT_ROOT="$(cd "$TAD_DIR/.." 2>/dev/null && pwd -P)"
  fi
  SKILLS_DIR="$ASSERT_ROOT/.agents/skills"
  if [ -d "$SKILLS_DIR" ]; then
    missing=""
    for pname in $pack_names; do
      [ -f "$SKILLS_DIR/$pname/SKILL.md" ] || missing="$missing $pname"
    done
    if [ -n "$missing" ]; then
      echo "ERROR: registered pack(s) missing .agents/skills projection:$missing" >&2
      exit 1
    fi
  else
    echo "NOTE: no .agents/skills tree at $SKILLS_DIR - projection assertion skipped" >&2
  fi
  ```
  其中 `pack_names` 为循环内以目录基名收集的集合（与 registry 的 path 派生同源）；`PACKS_DIR_WAS_OVERRIDDEN` 由参数解析段在命中 `--packs-dir` 时置 1（现脚本参数段在文件头，Blake 在该 case 分支内加一行置位）。断言只查「登记 ⊆ 投影」单向：`.agents/skills/` 中大量非 pack skill（alex、gate、hw-* 等）不在断言面。
- **判据**：真实树扫描 exit 0；任一登记 pack 缺投影 → exit 1 且 stderr 点名该 pack。断言失败时 registry 已先行写出（脚本顺序如此），红的是退出码与点名，不是 registry 内容——publish step3c 的 regen 以退出码判读，与门面一致。
- **负控设计**：fixture 树（mktemp 唯一目录）：`<fix>/.tad/capability-packs/{pack-a,pack-b}/CAPABILITY.md`（最小合法 frontmatter：name/description/keywords/type/status 五行＋`**CONSUMES**`/`**PRODUCES**` 两行正文）＋`<fix>/.agents/skills/pack-a/SKILL.md`（任意非空）。跑 `bash .tad/scripts/scan-packs.sh --packs-dir=<fix>/.tad/capability-packs`：期望 exit 1 且 stderr 含 `pack-b`；补 `<fix>/.agents/skills/pack-b/SKILL.md` 后重跑：期望 exit 0。fixture 与两次运行输出按件 6 纪律捕获落本仓证据目录（路径含任务标识），fixture 本体留 /tmp 不入仓。
- **顺带口径**：重跑 scan-packs 会刷新 registry 的 `last_scanned` 与 `synced_from_version`（后者派生自 version.txt）——Phase 2 的正控运行只验断言通过性；registry 终态以 Phase 3（bump 后）重跑为准（AC11 以包名＋status 集合不变为判据，头部两字段的变化如实记入 COMPLETION、不算漂移）。

### 4.8 Component 件6：捕获路径唯一化纪律（evidence-collection.md 立条文）

- **落点**：`.tad/tasks/evidence-collection.md`——在 §7 Delivery Evidence 节之后、「## Pattern Recognition Protocol」（L284）之前，新增一节（全文如下，逐字落盘）：

```markdown
## Capture Path Discipline （捕获路径唯一化纪律）

Command-output captures (install logs, check/apply output, command
transcripts filed as evidence) are evidence. Two rules govern every
capture:

1. **Unique path, always.** Write each capture to a unique path: a
   `mktemp` file, or a file directly inside this repo's evidence tree
   whose name carries the task/step identifier. Multiple executors or
   waves MUST NOT share one fixed-name capture file under `/tmp` -
   same-wave runs have overwritten each other's captures before
   (2026-10-04 S6 alignment: one seat's check/apply output was replaced
   byte-for-byte by another seat's), leaving reports whose numbers were
   right by luck while the filed evidence was another repo's.
2. **Cross-check before citing.** Before splitting, quoting, or filing a
   capture as evidence, cross-check it against what actually exists on
   disk (backup names, timestamps, counts, or hashes). If the capture
   does not match the on-disk artifacts of this task, discard it and
   re-capture; never file a capture whose provenance was not verified.
```

- **出处**：S5 第五件成因记录在 `~/AGENTS.md`「并发波次禁共用 /tmp 固定名捕获（2026-10-04）」条（S6 对齐安装实证）；本件把该席位级教训升为本体规程原件条文。
- **装载点位**：evidence-collection.md 是证据采集的规程原件，任何角色落证据前查此件即读到本节；且自本链起对本链生效（NFR4）。

### 4.9 Component 件7：gate skill Gate 3 计数行修正

- **落点**：`.agents/skills/gate/SKILL.md` Gate 3 inline 节（L275–292 区），三处改动，逐字如下：
  1. L279 注释行 `# MECE: verified 2026-08-04 — 6 items check 6 distinct artifacts` → `# MECE: verified 2026-08-04 — 7 items check 7 distinct artifacts (2026-10-05 recount fix: Provenance item restored to the inline copy)`；
  2. L280 `Critical Check (6 items):` → `Critical Check (7 items):`；
  3. 在 `- [ ] Knowledge Assessment complete (BLOCKING - must answer explicitly)` 行之后新增一行（与 Canonical 第 7 项同义、渲染风格与同节 Evidence replayable 的 advisory 标注一致）：
     `  - [ ] Provenance non-empty (advisory, WARN-not-BLOCK): ≥1 provenance row per CREATE file`
- **口径**：Canonical 是源、inline 是副本（副本头注自带「Edit canonical FIRST, then sync here」）——本件是副本向既存 Canonical 对齐（Canonical 已为 7 项，不动 Canonical）；与 D 线 B2 的 Gate 2 同步遍（8 项）属同一副本的不同节，不互相影响。注意该文件已含 D 线未提交改动（遍 1b），Blake 的 diff 判据必须以「本批三处改动」为增量口径（AC14 行集法），不许把 D 线在册内容算作本批产出、也不许回退它。

### 4.10 Component 版本：patch 升版提议（待 PM 裁定）

- **提议**：升 **v3.0.1**（patch）。理由：本批含下游可见面变更——根 AGENTS.md 新节随同步下发、自加槽契约新立、research-methodology 投影新增、pack 扫描新增断言、gate 计数修正——全部为增补/修正性质，无删除、无既有契约破坏、无行为不兼容，合 patch 级定义；批名定为「v3.0.1 本体收口批」（票标题候选名转正）。若 PM 裁定不升版，FR9 与 AC15 整行作废、其余件不受影响。
- **改动面（两处，点名封顶）**：
  1. `.tad/version.txt`：首行 `3.0.0` → `3.0.1`（文件其余不动）；
  2. `AGENTS.md` L9 代际标记：`Runtime status (v3.0.0)` → `Runtime status (v3.0.1)`——该标记是 GM 台账的机械核查面（输入 3 的教训正是版本面与根文件代际分叉），不随版同步即在本仓自造分叉。
- **口径留痕（PM 合并裁定 5）**：AGENTS.md 代际标记行随 `.tad/version.txt` 同步至新版号，属版本口径归一（R1 已立「标记须与 version.txt 一致」的机械核查面），不构成票面红线所禁的正文新增复述；本批新版号字面量出现面封顶两处——`.tad/version.txt` 首行与 AGENTS.md 代际标记行（registry／台账两派生件的派生行按 AC15 口径另计）。
- **派生自洽**：bump 后重跑 scan-packs（registry `synced_from_version` 派生新版）与 scan-downstream-versions（台账 CURRENT 派生新版、本仓行转新版、头注随脚本输出落地），两派生件以生成器终态收口。
- **顺序**：bump 在 Phase 3 执行（全部内容件落地后），避免中间态派生件反复重生成。

### 4.11 与既有条文的冲突点名（Gate 2 逐项裁定，裁定前 Blake 不许动对应落点）

| # | 冲突 | 设计立场 |
|---|------|----------|
| CF-1 | 台账头「禁止手改」× 件 2 要给台账加头注 | 走生成脚本输出＋重生成，不手改台账——与 publish-protocol step3e「台账是派生索引，禁止手改」同向，无实质冲突，请 Gate 2 确认形态 |
| CF-2 | publish-protocol step3e 文件集断言（bump 的 release commit 须同时含 NEXT.md 与 ROADMAP.md 头部行回填）× NEXT.md 属保留集 | 该断言执行者＝发版执行者本人（PM 收口），非 Blake 实施面；头部行回填与 NEXT.md 整件去向由 PM 在收口提交时裁定。本批 Blake 不碰 NEXT.md／ROADMAP.md |
| CF-3 | 版本复述面宽度：`.tad/config.yaml` L3、`tad.sh` L26、`.tad/TAD-VERSION`、各 pack install.sh 等多处复述旧版，何者为「活复述」无本设计自拟口径 | 以 release-verify version 门（含历史排除表）为判据：Blake Phase 0 以 detect-only 跑该门枚举（参数按 publish-protocol step3c 形态），门判 live stale 的写集外文件 → 停步报 PM，不许自行扩写集；本批设计改面封顶 §4.10 两处 |
| CF-4 | 件 4b（AGENTS.md 指针行）超出票面字面写集（票件 4 只名 `.agents/skills/` 投影） | 设计建议纳入：指针表是该 pack 的关键词路由装载面，无行则投影不可达（装载纪律）；裁定不纳入则 FR5/AC10 作废、件 4 其余不受影响。另注意 AGENTS.md 同文件承载三 hunk（C1 节／指针行／代际标记），AC 分行判读、互不串扰 |
| CF-5 | gate SKILL 提交连带 D 线在册改动；且只提 gate 不提 canonical 时，main 内 canonical 将落后于其 inline 副本 | gate 文件属甲层写集、连带不可避免且 D 线已全链 PASS（其入 main 本属 PM 收口动作，有 A 线脚本裁定先例）；canonical 与 alex SKILL 的提交去向请 PM 在收口时一并裁定，本批实施不受影响 |

### 4.12 风险与回滚

- 断言误红（件 5）：若断言因根派生错误在真实树误红，Phase 2 正控即暴露；回滚＝单独回退 scan-packs.sh 本批 hunk，registry 重跑恢复。fixture 负控先行正是为此。
- 台账重生成噪声（件 2）：重跑会刷新日期与各仓计数（下游树自 2026-10-04 后可能又有变动）——计数变化属事实刷新，逐行 diff 记入 COMPLETION，不许为「保持数字」手改台账。
- 投影派生误删行（件 4）：`grep -v '^status: '` 前先断言命中恰 1 次；AC9 以行集 diff 兜底（多删一行即红）。
- AGENTS.md 三 hunk 串扰（件 1/4b/版本）：逐 hunk 落笔、逐 hunk 复核（AC1/AC10/AC15 分行判读）；任一 hunk 异常只回退该 hunk。

---

## 5. 🆕 强制问题回答（Evidence Required）

### MQ1: 历史代码搜索

#### 搜索证据

```bash
# 工作区与 C1 diff（设计步亲跑）
git status --porcelain | wc -l            # 68
git diff --numstat -- AGENTS.md          # 16 0（单一 hunk = File authority order 节）
grep -c '覆盖口径' .tad/scripts/scan-downstream-versions.sh .tad/evidence/pm/downstream-versions.md  # 0 / 0
grep -c '项目自加槽|PROJECT-SLOT' .agents/skills/release-runbook/SKILL.md   # 0
grep -c '捕获路径唯一化纪律' .tad/tasks/evidence-collection.md              # 0
grep -c 'PROJECTION' .tad/scripts/scan-packs.sh                            # 0
test -d .agents/skills/research-methodology                                # 不成立（缺投影）
grep -c '^| research-methodology |' AGENTS.md                              # 0（无指针行）
# 投影同构样本（三件逐件 diff CAPABILITY.md vs SKILL.md + 文件集 diff）
for p in academic-research agent-memory ai-evaluation; do diff ...; done   # 规则见 §2.2
```

#### 决策说明

落点全部由盘面实测决定：头注进生成脚本（台账禁止手改＋step3e 收口重跑）、契约进 runbook（同步执行者必读面）、断言进 scan-packs 本体（验证器与被验面同体）、计数行只动 inline 副本（Canonical 已是 7 项）。

### MQ2: 函数存在性验证

#### 函数清单（本链的「函数」= 落点锚点，逐项实测）

| 锚点 | 实测位置 | 状态 |
|------|----------|------|
| scan-downstream-versions.sh 头部 printf 块 | L90–102，`source-of-truth:` printf 在 L92 | ✅ 在册 |
| scan-packs.sh 扫描循环结尾 echo | 文件末行 `echo "scan-packs.sh: scanned $count packs → $OUTPUT"` | ✅ 在册 |
| scan-packs.sh `--packs-dir` 参数分支 | 文件头参数解析段 | ✅ 在册 |
| release-runbook「## Mechanical authority and exit codes」／「## Global safety stops」 | 相邻两节（L113／L126 区） | ✅ 在册 |
| evidence-collection.md「## Pattern Recognition Protocol」 | L284（§7 在 L245–283） | ✅ 在册 |
| gate SKILL Gate 3 inline 节 | L279 注释行、L280「Critical Check (6 items):」、Knowledge Assessment 行为列表末项 | ✅ 在册 |
| Canonical Gate 3 节 | `.tad/gates/gate-canonical-checklist.md` L37 起，7 项 | ✅ 在册 |
| research-methodology CAPABILITY.md | `.tad/capability-packs/research-methodology/CAPABILITY.md`，frontmatter `status: frozen` 恰 1 行 | ✅ 在册 |
| capability-skill.sh validate/verify | `.tad/scripts/capability-skill.sh` usage 段在册 | ✅ 在册 |
| tad.sh 根文件段（FR-4b） | L1224 起注释块 | ✅ 在册（只读引用，不改） |
| AGENTS.md pack 指针表 | 「Capability Packs」节，26 行（含表头） | ✅ 在册 |

### MQ3: 数据流完整性

#### 数据流对照表

| 输入 | 载体 | 输出 | 消费方 |
|------|------|------|--------|
| PM 判断（输入 1/2/4 处置） | 判断正本 | 本 HANDOFF §4.3/4.4/4.5/4.7 草案 | Blake 实施 |
| D 线定稿（C3 节＋计数行遗留） | Gate 4 验收件 | 件 1 判据＋件 7 落点 | Gate 3/4 复算 |
| pack 本体 | CAPABILITY.md 及子目录 | `.agents/skills/` 投影（派生） | 三 harness 装载面 |
| 登记集 | scan-packs 扫描 | 断言红/绿＋registry | publish 门、Gate 3 |
| 版本单源 | version.txt | 台账 CURRENT、registry synced_from_version（派生） | GM 台账验收 |

#### 数据流图

```
判断正本 ──→ 票 ──→ 本 HANDOFF ──Gate 2 双审──→ Blake 实施（Phase 0–3）
                                                    │
        ┌───────────────┬───────────────┬──────────┴───────────┐
     条文三件          投影＋断言        版本 bump          C1 定界表
   (runbook/evidence/  (skills/scan)   (version.txt/标记)   (COMPLETION)
    台账脚本)               │                │
        └───────────────┴──────┬─────────┴──────────┘
                          Gate 3 双审 → Gate 4 → PM 提交入 main
                                                    → GM 12 仓刷新对齐令
```

### MQ4: 视觉层级

light-tier N/A——本批无 UI、无视觉产物，落点均为规程文本与脚本，无视觉层级可设计。

### MQ5: 状态同步

#### 状态存储位置

- 票：`.tad/active/TICKET-20261005-tad-closeout-batch.md`（状态行由 PM 在关链时回写）。
- 链状态：本 HANDOFF §9.2 Audit Trail 随 Gate 2/增补回填更新；实施进度以 COMPLETION 为准。
- 本设计步按派发约束只写 HANDOFF 与完工说明两件，`.tad/active/session-state.md` 未动——留 PM 知悉（与 Alex 收口纪律的差异在此明记，非遗漏）。

#### 状态流图

```
设计 v1.0 ──Gate 2 双审──→ (CONDITIONAL→增补回填) ──→ PASS ──→ 实施 Phase 0–3
──→ Gate 3 双审 ──→ Gate 4 ──→ PM 提交/推送 ──→ 票 CLOSED 迁档
```

---

## 6. Implementation Steps（分Phase）

### Phase 0: 基线、断言与盘点

#### 交付物
- COMPLETION 骨架（含 §4.2 分类表、基线哈希与行数表、CF-3 门枚举结果）

#### 实施步骤
- [ ] Step 0 路径断言：`pwd` ＝ `/home/hatch/workspace/yun-sync/TAD`；§7 每个 MODIFY 目标以绝对路径 `test -f` 逐件断言，任一不成立即停步报 PM
- [ ] 全量盘点：`git status --porcelain` 输出捕获落唯一路径文件（`.tad/evidence/closeout-batch-20261005/git-status-baseline.txt`），逐行按 §4.2 规则分类成表
- [ ] 基线记录：AGENTS.md 节哈希（§4.2 命令）、写集各文件 `wc -l` 与 `sha256sum` 记入 COMPLETION
- [ ] CF-3 枚举：按 publish-protocol step3c 形态 detect-only 跑 `release-verify.sh version`（只读），输出捕获落盘；门判 live stale 且在写集外 → 停步报 PM
- [ ] 读 shell-portability.md 全文（Phase 1 改 .sh 的前置）

#### 验证方法
- 盘点表行数 ＝ `git status --porcelain | wc -l` 当值；分类无未点名路径

#### 🆕 Phase 0 完成证据（Blake必须提供）
- 分类表＋基线表在 COMPLETION 在册；CF-3 枚举输出路径

### Phase 1: 条文与脚本（件 7 → 件 3 → 件 6 → 件 2 脚本）

#### 交付物
- gate SKILL 计数行三处改动、runbook 新节、evidence-collection 新节、scan-downstream 脚本头注 printf

#### 实施步骤
- [ ] 件 7：按 §4.9 逐字三改；改后当场跑 AC14 干跑
- [ ] 件 3：按 §4.4 全文逐字插入新节（锚：Mechanical authority 节末／Global safety stops 节首）
- [ ] 件 6：按 §4.8 全文逐字插入新节（锚：§7 末／Pattern Recognition Protocol 节首）；本节落盘后，本链后续全部捕获按其纪律执行
- [ ] 件 2：只改脚本（§4.3 的 printf 一行），**不重跑脚本、不动台账**（重生成在 Phase 3）

#### 验证方法
- AC3、AC5、AC13、AC14 当场干跑，结果记入 COMPLETION

#### 🆕 Phase 1 完成证据（Blake必须提供）
- 四件的 `git diff -U0` 摘要（增删行数）＋干跑值

### Phase 2: 投影与断言（件 4 → 件 4b → 件 5）

#### 交付物
- `.agents/skills/research-methodology/`（12 件）、AGENTS.md 指针行（CF-4 放行时）、scan-packs.sh 断言段、负控 fixture 证据

#### 实施步骤
- [ ] 件 4：按 §4.5 规则以 shell 复制物化（先断言 CAPABILITY.md `^status: ` 恰 1 次命中）；物化后按 AC7 修订后结构判据组当场自检（不以 capability-skill.sh validate/verify 退出码为判据——校验器漂移已批外登记，见 §4.5）
- [ ] 件 4b（仅 CF-4 裁定纳入时）：按 §4.6 逐字插行，先读表确认邻行序位
- [ ] 件 5 负控先行：按 §4.7 建 fixture，先在**未改**的 scan-packs 上确认 fixture 绿（无断言时 exit 0，作对照），再植入断言段，跑负控两态（缺 pack-b 红／补齐绿）
- [ ] 件 5 正控：在真实树跑改后 scan-packs，exit 0；registry 差异只许包名/status 集合不变之外的头部字段变化，如实记录

#### 验证方法
- AC7、AC8、AC9、AC10、AC11、AC12 当场干跑

#### 🆕 Phase 2 完成证据（Blake必须提供）
- 投影文件集清单＋逐件 sha256 对照结果；fixture 两态输出捕获路径

### Phase 3: 版本收口与总验（版本 → 派生重生成 → 件 1 复核 → 全量 AC）

#### 交付物
- version.txt 与 AGENTS.md 代际标记新版、registry 与台账终态、§9.1 全量回填、COMPLETION 定稿

#### 实施步骤
- [ ] 版本（PM 已裁定升版时）：`.tad/version.txt` 首行改新版；AGENTS.md 代际标记行同步改（仅该行括号内版本号）
- [ ] 派生重生成：`bash .tad/scripts/scan-packs.sh`（registry 终态）→ `bash .tad/scripts/scan-downstream-versions.sh`（台账终态，头注落地）；两件 diff 摘要记入 COMPLETION（台账计数变化逐行点名、只报不改）
- [ ] 件 1 复核：AGENTS.md 节哈希同命令复算，与 Phase 0 基线比对
- [ ] AC1–AC16 全量干跑并回填 §9.1 Verified Output；写 COMPLETION 定稿（四强制节：结果总览／写集落点／AC 逐项／读取清单打勾回执；gate3_verdict 留空；human CHECK 记「CHECK 待人」）

#### 验证方法
- §9.1 全行 Actual 与 Expected 对照；任一行不符——先查口径、注明后重算（Canonical E 维子款口径），仍不符如实记 FAIL 并停步报 PM，不许改判据凑绿

---

## 7. File Structure

### 7.1 Files to Create

```
.agents/skills/research-methodology/SKILL.md                    # 件4：CAPABILITY.md 派生（去 status 行）
.agents/skills/research-methodology/references/planning.md      # 件4：与 pack 本体字节一致
.agents/skills/research-methodology/references/quality-control.md
.agents/skills/research-methodology/references/sourcing.md
.agents/skills/research-methodology/references/analysis.md
.agents/skills/research-methodology/references/output.md
.agents/skills/research-methodology/checklists/research-quality.md
.agents/skills/research-methodology/scripts/saturation-check.sh
.agents/skills/research-methodology/scripts/source-quality.sh
.agents/skills/research-methodology/LICENSE
.agents/skills/research-methodology/LICENSE-ATTRIBUTION.md
.agents/skills/research-methodology/CONVENTIONS.md
.tad/evidence/closeout-batch-20261005/                          # 本链捕获证据（盘点基线、fixture 两态、门枚举；件6 纪律落盘面）
.tad/evidence/completions/COMPLETION-2026-10-05-tad-closeout-batch.md   # 完工件
```

### 7.2 Files to Modify

```
AGENTS.md                                            # 件4b 指针行（+1，CF-4 条件）＋版本代际标记行（1 行替换）；C1 的 +16 行节为既存乙层、Blake 不写只核
.agents/skills/gate/SKILL.md                         # 件7：计数行 2 处替换＋Provenance 行新增（该文件另有 D 线在册改动，不许回退）
.agents/skills/release-runbook/SKILL.md              # 件3：新增「Project slot」一节（纯增）
.tad/tasks/evidence-collection.md                    # 件6：新增「Capture Path Discipline」一节（纯增）
.tad/scripts/scan-downstream-versions.sh             # 件2：头部输出加 1 行 printf（纯增）
.tad/scripts/scan-packs.sh                           # 件5：参数段置位 1 行＋循环收集 1 行＋断言段新增
.tad/capability-packs/pack-registry.yaml             # 派生件：scan-packs 重生成（只许生成器写）
.tad/evidence/pm/downstream-versions.md              # 派生件：scan-downstream 重生成（只许生成器写）
.tad/version.txt                                     # 版本：首行 patch bump（PM 裁定升版时）
```

### 7.3 Grounded Against

- 票：`.tad/active/TICKET-20261005-tad-closeout-batch.md`
- 判断正本：`.tad/evidence/pm/2026-10-04-gm-inputs-judgment.md`；GM 输入正本：`gm/.tad/evidence/reports/2026-10-tad-pm-inputs.md`
- 定稿出处：`.tad/evidence/reviews/2026-10-04-gate4-acceptance-course-judgment-adoption.md`（C1 节定稿＋计数行遗留）
- 规程原件：`.tad/gates/gate-canonical-checklist.md`、`.agents/skills/alex/references/publish-protocol.md`（step3c/3e）、`.tad/scripts/capability-skill.sh`（forbidden 清单与 validate/verify）

### 7.4 保留集（本批不碰 — 丙层）

`NEXT.md`、`ROADMAP.md`、`docs/pm/{acceptance,auth,intent,now,ops-knowledge}.md`、`docs/pm/ops/`、`docs/pm/open-cards/**`、全部 `.tad/active/TICKET-*.md`、`.tad/active/handoffs/` 既有删除面、`.tad/project-knowledge/patterns/{ac-verification,shell-portability}.md`、`.tad/scripts/{evidence-freshness-check,sync-maintainer-evidence}.sh`、`.tad/templates/dispatch-risk-card.md`、`.tad/TAD-POINTER.md`、`.agents/skills/alex/SKILL.md`、`.tad/gates/gate-canonical-checklist.md`、`.tad/active/TICKET-20261004-maintainer-evidence-branch-revival.md`、`tad.sh`、`.tad/config.yaml`、`.tad/TAD-VERSION`、下游一切仓。

---

## 8. Testing Requirements

### 8.1 存在性与逐字断言
- 条文三件（件 3/6 草案与件 7 三改）逐字比对：以 §4 草案代码块抽取比对（diff 为空才算逐字）；件 2 printf 行与 §4.3 逐字比对。

### 8.2 位置与同构断言
- 节位顺序断言（awk ORDER_OK 形态）：件 3 节在两锚节之间、件 6 节在两锚节之间、件 2 头注行在 `# 下游仓版本台账` 标题行之前。
- 件 4 同构：文件集等式＋逐件 sha256 等式＋SKILL.md 行集 diff 恰删 status 一行。

### 8.3 负控
- AC12 fixture 两态（缺件红／补齐绿）为本批主负控；另：件 5 断言植入前先跑 fixture 对照（无断言版 exit 0），证明红来自断言而非 fixture 本身坏。

### 8.4 Edge Cases
- 台账重生成计数变化（下游树已变）：逐行 diff 点名、只报不改（§4.12）。
- registry 重跑头部字段变化（last_scanned／synced_from_version）：允许且记录；包名＋status 集合变化即红（AC11）。
- AGENTS.md 三 hunk 任一异常：只回退该 hunk 并停步报 PM。

---

## 9. Acceptance Criteria

- [ ] 七件逐项落地且装载点位可实测（AC1–AC15）
- [ ] 版本口径收口且派生件自洽（AC11/AC15，PM 裁定升版时）
- [ ] 写集封顶：批外文件零改动（AC2、AC16）
- [ ] 负控成立：断言缺件即红、补齐即绿（AC12）

## 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE — Gate 3 executes each row

> 干跑基线（Alex step1d，2026-10-05 设计步实测）：AC3–AC15 的目标物在未改树上全部缺失或为旧值（§2.2 基线表），均为「对的原因 FAIL」；AC1 的对象（C1 节）已在盘，基线为现行哈希、判据是实施后复算不变；AC2/AC16 为封顶断言，基线见 Phase 0 盘点。Verified Output 列由 Blake 实施后回填。

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| AC1 | 件1：C1 节逐字不变（D 线定稿在提交面内完好） | post-impl-verifiable | command: `sed -n '/^### File authority order/,/^### Interaction decisions/p' AGENTS.md \| head -n -1 \| sha256sum`，Phase 0 与 Phase 3 两次同命令复算 | 两值全等（Phase 0 基线值记入 COMPLETION） | step1d：提取面存在（节在 L80 区、全文 184 行）；哈希待 Blake Phase 0 记录 |
| AC2 | 件1：提交面盘点成表且分类封口 | post-impl-verifiable | path-check: COMPLETION 内嵌分类表，行数 ＝ Phase 0 `git status --porcelain \| wc -l` 当值；表中每行标注 甲层/乙层/丙层 之一，无「未点名」行 | 表在册且行数对账相等 | step1d：基线 68 行（设计步实测），实施当值以 Phase 0 为准 |
| AC3 | 件2：头注 printf 在生成脚本头部输出块内 | post-impl-verifiable | command: `grep -n '覆盖口径' .tad/scripts/scan-downstream-versions.sh`（恰 1 命中）＋其行号在 `source-of-truth` printf 行之后、`# 下游仓版本台账` printf 行之前（行号序断言） | 1 命中且位置序成立 | step1d：0（未落，对的原因 FAIL） |
| AC4 | 件2：头注在重生成台账头部在册 | post-impl-verifiable | command: `grep -c '覆盖口径：本台账覆盖范围为 yun-sync 席位仓；goal 型仓为轻量装、无 version.txt 版本面，不在扫描口径内' .tad/evidence/pm/downstream-versions.md` ＝ 1，且其行号 ＜ `# 下游仓版本台账` 标题行号 | 1 且位置成立 | step1d：0（未落） |
| AC5 | 件3：自加槽契约节在 runbook 落点在册 | post-impl-verifiable | command: `awk '/^## Mechanical authority and exit codes/{a=NR} /^## Project slot in downstream root files/{b=NR} /^## Global safety stops/{c=NR} END{print (a&&b&&c&&a<b&&b<c)?"ORDER_OK":"ORDER_FAIL"}' .agents/skills/release-runbook/SKILL.md` ＋ `grep -c 'PROJECT-SLOT:BEGIN' <同文件>` ≥1、`PROJECT-SLOT:END` ≥1 | ORDER_OK 且标记对各 ≥1 | step1d：ORDER_FAIL（节不存在） |
| AC6 | 件3：契约五要素齐备（槽定义／覆盖前提取备份／回贴＋逐字比对判据／无槽存量逐案留痕／trading-agent 迁移口径含「下次对齐时·首 4 行·逐字·本批不动下游仓」） | post-impl-verifiable | rubric-spawn: spawn independent judge per Rubric Evaluation Protocol against §4.4 草案与落盘节全文逐要素核对 | verdict: PASS（五要素逐项在册） | step1d：对象未落，待实施后判读 |
| AC7 | 件4：投影结构判据组（Gate 2 合并裁定 3 路线 A 修订——代原「capability-skill validate/verify 退出 0」判据；该校验器与现行投影契约漂移，已批外登记，见 §4.5） | post-impl-verifiable | command: 七项结构判据逐项实跑——① 投影目录存在且 `SKILL.md` 在册；② 投影文件集与 §4.5 清单（12 件）集合相等；③ 禁入四件（`CAPABILITY.md`／`README.md`／`CHANGELOG.md`／`install.sh`）命中数 ＝ 0；④ 投影树内符号链接数 ＝ 0；⑤ `SKILL.md` frontmatter `name:` 值 ＝ `research-methodology`；⑥ `SKILL.md` 中 `{{`／`[TODO]`／`[TBD]` 命中数 ＝ 0；⑦ 除 SKILL.md 外 11 件逐件 `sha256sum` 与 pack 本体同路径文件全等 | 七项全成立 | step1d：投影不存在；修订判据已经 /tmp 模拟物化实跑证明与 AC9 可同时满足（Gate 2 增补完工说明在册） |
| AC8 | 件4：投影文件集与逐件字节同构 | post-impl-verifiable | command: 投影文件集与 §4.5 清单（12 件）集合相等；清单内除 SKILL.md 外 11 件逐件 `sha256sum` 与 pack 本体同路径文件比对全等；`ls .agents/skills/research-methodology/ \| grep -E '^(CAPABILITY.md\|README.md\|CHANGELOG.md\|install.sh)$' \| wc -l` ＝ 0 | 集合相等＋11 件哈希全等＋forbidden 0 | step1d：投影不存在 |
| AC9 | 件4：SKILL.md 派生纯度（仅去 status 行） | post-impl-verifiable | command: `diff .tad/capability-packs/research-methodology/CAPABILITY.md .agents/skills/research-methodology/SKILL.md` 的输出恰为一行删除（`status: frozen`），无其他增删行 | diff 输出 ＝ 恰 1 行删除且内容为 status 行 | step1d：投影不存在 |
| AC10 | 件4b：AGENTS.md 指针行在册且格式同构（CF-4 裁定纳入时生效；裁定不纳入则本行整行作废） | post-impl-verifiable | command: `grep -c '^| research-methodology |' AGENTS.md` ＝ 1 ＋ 第二列为 registry description 前缀（python startswith 校验）且长度 60–75 | 1 且前缀校验通过 | step1d：0（未落） |
| AC11 | 件5：断言正控＋registry 集合不变 | post-impl-verifiable | command: Phase 3 `bash .tad/scripts/scan-packs.sh` exit 0；重跑前后 registry 的「包名＋status」对集合相等（各 26 对，提取比对输出 SET_OK） | exit 0 且 SET_OK | step1d：断言不存在（grep PROJECTION ＝ 0），现脚本 exit 0 但无断言面 |
| AC12 | 件5：负控 fixture 两态 | post-impl-verifiable | fixture: 按 §4.7 建 fixture 树，`bash .tad/scripts/scan-packs.sh --packs-dir=<fix>/.tad/capability-packs` → exit 1 且 stderr 含 `pack-b`；补 pack-b 投影后重跑 → exit 0；断言植入前对照跑（同 fixture、无断言版）exit 0 | 三态值依次 0（对照）／1（缺件）／0（补齐），输出捕获落 `.tad/evidence/closeout-batch-20261005/` | step1d：对象未落，待实施 |
| AC13 | 件6：捕获纪律节在 evidence-collection 落点在册 | post-impl-verifiable | command: `awk '/^## Capture Path Discipline/{b=NR} /^## Pattern Recognition Protocol/{c=NR} END{print (b&&c&&b<c)?"ORDER_OK":"ORDER_FAIL"}' .tad/tasks/evidence-collection.md` ＋ `grep -c 'mktemp' <同文件>` ≥1、`grep -c 'Cross-check before citing' <同文件>` ＝ 1（且节首行号 ＞ §7 Delivery Evidence 节首行号） | ORDER_OK 且两锚在册 | step1d：ORDER_FAIL（节不存在） |
| AC14 | 件7：gate 计数行与 Canonical 行集对齐 | post-impl-verifiable | command: 三段合取——① `grep -c 'Critical Check (7 items)' .agents/skills/gate/SKILL.md` ≥1 且 `grep -c '6 items check 6 distinct artifacts' <同文件>` ＝ 0；② `grep -c 'Provenance non-empty' <同文件>` ≥1；③ 行集法：gate SKILL Gate 3 列表项数 ＝ Canonical Gate 3 列表项数（同为 7，以两文件该节 `- [ ]` 计数比对） | 三段全成立 | step1d：① 0／有 6 项旧值；② 0；③ 6≠7 |
| AC15 | 版本：单源 bump 且标记同步、复述封顶（PM 裁定升版时生效；不升版则整行作废） | post-impl-verifiable | command: `head -1 .tad/version.txt` ＝ `3.0.1`；`grep -c '(v3.0.1)' AGENTS.md` ＝ 1 且 `grep -c '(v3.0.0)' AGENTS.md` ＝ 0；写集内新版号出现面仅 version.txt 与 AGENTS.md 标记行与两派生件的派生行（registry synced_from_version／台账当前版本行），逐处点名 | 四项全成立 | step1d：version.txt ＝ 3.0.0（旧值） |
| AC16 | 封顶断言：写集外零改动 | post-impl-verifiable | command: Phase 3 `git status --porcelain` 与 Phase 0 基线比对——状态变化（新增/消失/内容再变）的文件集合 ⊆ §7.1＋§7.2 写集；丙层文件状态与基线逐行一致 | 变化集 ⊆ 写集 | step1d：基线 68 行已记，实施后比对 |

## 9.2 Expert Review Status (Alex 必填)

> 双审由 PM 另派独立会话（tech／fit 两路），本设计步未自审。双审落盘＋PM 合并裁定后回填本节；CONDITIONAL 的增补回填亦回填至此。

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| （待双审） | — | — | 待派 |

### Overall Assessment (post-integration)

- Gate 2: **待双审**（设计 v1.0，2026-10-05）。CF-1…CF-5 与版本提议（§4.10）待 PM 随 Gate 2 一并裁定。

---

## 10. Important Notes

### 10.1 Critical Warnings

- ⚠️ AGENTS.md 一件三 hunk（C1 节／指针行／代际标记）：逐 hunk 落笔与复核，任何自动化整件重写都是事故（本仓有整件误改前科）。
- ⚠️ 派生件（台账、registry）只许生成器写：手改一字即红（AC 判据含生成路径证据）。
- ⚠️ scan-packs.sh 在 fixture 模式下 OUTPUT 随 PACKS_DIR 派生——负控不许误写真实 registry；跑前先确认 `--packs-dir` 参数在位。
- ⚠️ gate SKILL 内含 D 线在册改动：diff 判读一律用行集增量口径，不许以「整件与 HEAD 比」归责或回退。

### 10.2 Known Constraints

- 提交、推送、NEXT/ROADMAP 头部回填、canonical 与 alex SKILL 的提交去向，全部是 PM 收口面，不在 Blake 实施面（CF-2/CF-5）。
- 本批不解决 `.tad/TAD-VERSION`、config.yaml 等复述面的存废（CF-3 门判＋PM 裁定面）。

### 10.3 🆕 Sub-Agent使用建议

- 实施为单 Blake 串行（写集含同文件多 hunk 与脚本链，不适合并行分件）；Gate 3 双审另派独立会话（code 路重算 AC、safety 路查封顶与连带面）。

---

## 12. 🆕 Sub-Agent使用记录

| 步 | 角色 | 产出 | 日期 |
|----|------|------|------|
| 设计 | Alex（本步，原生 subagent） | 本 HANDOFF v1.0＋设计完工说明 | 2026-10-05 |

**Alex confirms:** This handoff contains everything Blake needs for implementation — subject to Gate 2 dual review and PM rulings on CF-1…CF-5 and the version proposal (§4.10), which precede any implementation.
**Date:** 2026-10-05
**Status:** Ready for Gate 2

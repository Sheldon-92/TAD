---
dispatch_id: p3-y4-fix-2
dispatch_history: [p3-y3-1, p3-y4-fix-1]
# Quality Chain Metadata (Alex 必填 - Phase 4 Hook 将基于此阻塞 Gate 3)
task_type: mixed       # code | yaml | research | e2e | mixed —— 行为验证实跑（conductor 派发洁净会话产出）＋台账/注册面落字＋证据记录
e2e_required: no      # yes | no
research_required: no # yes | no
git_tracked_dirs: []  # 本仓文件夹制（禁 git 命令），无 git-tracked 生产目录口径
skip_knowledge_assessment: no
gate4_delta: []
risk_triggers: [platform]   # 改动面含 pack 台账、注册表（重扫生成）、声明文件与 fixture 判别面（platform）；无 security/data/money/ui/domain 面
look_first: ".tad/evidence/yolo/v409-basket/phase3-look.md — 成本读数的数源在设计期已实测：muse.db token 表在本地部署未落数（全 agent 近 2 日 0 行），会话 JSONL 无 usage 字段；可采面只有 JSONL 可数代理（assistant 轮次／工具调用／字节／时长）。本 Phase 其余改动全在本仓内，不作用于仓外系统、不读写真实用户数据"
real_paths:
  - id: RP1
    path: "Gate 3 run 评审人在一次性副本内对全部捕获 outputs 重跑 runner 并与 eval 记录逐行比对的真实路径（§6 Gate 3 备审注记）：副本内跑 pack-eval-runner.sh 单 fixture 模式遍历 16 个目标 pack 的 WITH/CONTROL（及派生 fixture 两臂），verdict 行与各 p3-eval-<pack>.md 所录逐行一致才算过"
    run: "named scenario walk — Gate 3 run reviewer 执行，输出存证据根 p3-gate3-rerun.txt"
  - id: RP2
    path: "Gate 4 验收人只读三件（p3-eval-summary.md、p3-ledger-flips.md、翻牌后台账本体）答出三问的真实路径：哪几个 pack 变了状态、各自凭哪组 runner 数字、C1 是否销账（driftcheck (b)/(d) 无 ml-training）"
    run: "named scenario walk — §6 S6 步 4（三问答案只许来自三件本身，不许靠 COMPLETION 转述）"
  - id: RP3
    path: "conductor 消费触发抽测记录的真实路径：读 p3-trigger-sampling.md 的 9 行结果，在 p3-eval-summary.md 写下逐 pack announce 率与处置一行（留作将来关键词/解冻工作的输入，本 Phase 不据此改任何 pack）"
    run: "named scenario walk — §6 S6 步 3"
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-10-31
**Project:** TAD（EPIC-20261031-v409-basket）
**Task ID:** TASK-20261031-P3
**Handoff Version:** 4.0.8
**Epic:** EPIC-20261031-v409-basket.md (Phase 3/5)

---

## 激活自报（Alex · dispatch p3-y3-1）

- 角色：Alex（Solution Lead），由 conductor（Cora）派发执行 step Y3（Phase 3 设计），依 `.agents/skills/alex/references/conductor-dispatch-mode.md` 与 handoff-creation 规程至 step1d 止步：不做专家评审选择、不派 reviewer、不写 Gate 2 结论、不给自己的活写 verdict。Gate 2 双审由 conductor 后续独立派发。
- 已读原件：仓根 `AGENTS.md`、`.tad/project-knowledge/principles.md`、`.tad/project-knowledge/patterns/_index.md`＋命中 pattern 全文两件（pack-evaluation、pack-build-rules）与 ac-verification 相关条目钩子、`.tad/tasks/handoff-creation.md`、`.tad/templates/handoff-a-to-b.md`、`.tad/gates/gate-canonical-checklist.md` Gate 2／Gate 3 节、conductor-protocol step_Y3、`.agents/skills/alex/references/conductor-dispatch-mode.md`；输入件五份（phase3-grounding、TICKET-20261031-pack-triage、phase1-gate-report、pack-ledger-diff、BASKET-4.0.9）与台账本体 `behavioral-eval-status.yaml` 全文、声明文件全文、Phase 2 HANDOFF 的形态先例（front matter／§9.1 形态 A／Gate Rounds 骨架）。
- Gate 1：Epic Phase Map 的 Phase 3 行＋ BASKET 第 3 行（pack 分诊主体，用户点数 1＝Gate 4）＋票面裁定（TICKET-20261031-pack-triage）即本 Phase 的 Requirement 面；裁定逐件可从票面原文取得，can design from it。设计须自判的四处（grounding 明示或设计期发现）：①窗口锚口径冲突（票面 v4.0.10 vs 连带调整 4.0.9）→ D10 显名记录、从 4.0.9；②C1 与票面 ml-training 口径对账 → D1；③降级退出的落字形态票面未钉 → D3 按 ml-training 先例钉死；④触发抽测的抽样规则票面未钉 → D8 以「verified ∧ registry active」规则推出恰 3 个。
- 基线先验（前两 Phase 共同 P0 教训）：承重基线全部在设计期实测落盘——台账复计＋fixture 库存＋注册表 status 映射＋声明文件现状（`p3-baseline-ledger-fixtures.txt`）、driftcheck 现行全文（`p3-baseline-driftcheck.txt`）、runner 对 6 月归档 outputs 的四行复现（基线件 F 节：与台账注释数字逐字吻合）、成本数源探针（`phase3-look.md`）。§9.1 的 Verified Output 列引此四件为据。
- 设计期实测发现的两处盘面事实（设计已按实测而非票面/注释成文）：①research-methodology 的台账注释声称 fixture `five-phase-pipeline`，盘面无此文件（skill 与源包均无 examples/）→ D11 fixture 先行特例；②verified 9 包中 6 个 registry status=frozen，auto-match 按规程跳过，抽测它们只会测到冻结本身 → D8 抽样规则。
- 本 handoff 首行 `---`、`dispatch_id: p3-y3-1` 在 front matter 块内（第 2 行）、§9.1 表头为形态 A——按 canonical Gate 2 的 handoff-header-form 三点先行自守，Gate 2 评审仍须机械核验并留痕。
- 本仓纪律：文件夹内禁跑任何 git 命令（仓根 AGENTS.md 头部）；验收一律以 grep/sha256/脚本实跑为面，不用 git diff。推送由 conductor 收口步执行，不在本 handoff 写集内。

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 待 conductor 独立派发（本设计步不自审自批）

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ⏳ 待双审 | 六个 Step（S1 备料→S2 pilot→S3 fan-out 实跑→S4 抽测/成本→S5 条件降级→S6 conductor 翻牌与收口）的产出面、属主与先后在 §4/§6 齐备；承重基线已实测落盘（见激活自报） |
| Components Specified | ⏳ 待双审 | 每条裁定的落字形态在 §4 逐件钉死：收紧法的预检程序、补验配方的分支全集、降级的四件套落字、C1 声明的注释要件、翻牌的属主与清单形态 |
| Functions Verified | ⏳ 待双审 | runner 单 fixture 模式设计期实跑复现台账数字（基线件 F 节）；driftcheck 设计期实跑落盘；成本数源三探针实测（look 件） |
| Data Flow Mapped | ⏳ 待双审 | §5 MQ：run 会话产出 outputs → runner 断言 → eval 记录 → flip 清单 → conductor 翻牌 → Gate 3 重跑核对，五段流向与每段的属主均已映射 |

**风险卡触发项核对结论**（canonical Gate 2「Risk card」行，设计期先行自核、Gate 2 风险面复核）：六类触发项逐项核——删除（不命中：全 Phase 无删除动作；降级分支是源包整目录移入 retired、字节保留，与 ml-training 先例同形）／密钥、公网、生产（不命中：run 会话只读仓内 fixture 场景与 pack 文件，产出只落证据根）／跨仓或跨席位写（不命中：写集全在本仓单仓内；会话 JSONL 只读计数、不写）／引入新连接器、MCP 或依赖（不命中：只用既有 runner/driftcheck/scan-packs 与原生 spawn）／不可逆动作（不命中：台账翻牌可按 flip 清单逐行回退、注册表由 scan-packs 可重生成、降级移动可逆移回、声明行可撤）／涉及金额（不命中：run 会话消耗的是本链既有额度，无对外付费）／对外动作（不命中）。结论：本 handoff 非高风险，不附风险卡；风险在判据面（翻牌错误会把未验证 pack 标成已验证），由台账合同的 conductor 专属翻牌＋flip 清单＋Gate 3 全量重跑三道机械面对冲，见 §10.1。

**Pilot 声明**（canonical Gate 2「Pilot declared」行）：本 Phase 的 fan-out ＝16 个同构验证单元（同配方 §4.4、同 §9.1 方法、仅目标 pack 与输入 fixture 不同），≥3 触发 pilot 义务。Pilot 单元＝**ai-tool-integration**（单 fixture、decision 型场景、registry active），S2 先行端到端跑完配方全程；证伪出口：pilot 的 eval 记录无法按 §4.6 形态成立（outputs 不可用、WITH 臂未按 provenance 块证明读过 pack、runner 行不可复现）→ 立即停 fan-out、回 conductor 报，不得带着坏配方批量跑。其余 15 个单元在 pilot 记录落盘后才许开跑（S3）。

**Load points declared**（canonical Gate 2 行）：本 Phase 不新增、不修改任何规程/模板/pattern 文件，无新装载点。被改的三个数据面各有既有消费者，逐项点名：①`skill-only-declarations.txt`——消费者 `pack-registry-driftcheck.sh`（作 Set S 读入）与发版 pack-registry 面；②`behavioral-eval-status.yaml`——消费者为 conductor 翻牌合同（文件头注释即合同正本）与后续分诊/发版读数；③`pack-registry.yaml`——只许 `scan-packs.sh` 重生成，消费者为 AGENTS.md 的 pack loader 协议（status 面）与 driftcheck（Set A）。fixture frontmatter 的消费者是 `pack-eval-runner.sh`（discriminative_pattern＋min_discriminative 两字段）。

**Gate 2 结果**: Round 1 双审——consistency FAIL（p0=1）、risk CONDITIONAL（p0=0），设计修订 p3-y4-fix-1 已逐条处置；Round 2 窄口复审——consistency PASS（p0=0）、risk FAIL（p0=1，新 P0 F-RR1 为 AC11 判据命令的 grep 方言缺陷）；第二轮修订 p3-y4-fix-2 已处置（文末第二轮修订记录，含 §9.1 全表 `\|` 逐行核查结论），待 conductor 派复审；复审定稿前不交 Blake。本节状态以盘面 verdict 为准。

> **Process Gate 2 = dual reviews on disk** (P2 tax-cut). PASS ⇔ two independent artifacts under the evidence root (P0=0 or sanctioned). Do **not** write a dispatch lock that waits for a human chat string `/gate 2`.

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 台账翻牌不是你的活：`behavioral-eval-status.yaml` 的 status 列只许 conductor 按 flip 清单改（台账文件头合同原文）；你只产 runner 数据、eval 记录与 flip 清单草案，原样交 conductor 执行（D7）
- [ ] 一切验证结论先有 runner 行：没有 `pack-eval-runner.sh` 实跑输出的 pack，不许在任何记录里写「已验证」类字样（台账合同：Never hand-set verified）
- [ ] CONTROL 臂会话不许见 pack：prompt 只给 fixture 场景原文；WITH 臂才许点名 pack SKILL 路径（D6）；两臂都必须是 conductor 新派的洁净会话，不许复用实施会话
- [ ] driftcheck 的目标是 delta 不是 exit 0：production-observation 是无关基线项，永远留在 (b)/(d)；任何 AC 只问「ml-training 的行消失、其余与基线逐行同」（D1/AC2）
- [ ] 降级分支（S5）只在收紧重验仍无 delta 时触发，且四件套落字缺一不可（D3）；未触发就在 COMPLETION 写明未触发
- [ ] 写集外一律不动：pack 的 SKILL.md 正文、references、其他 pack 的 fixture、注册表手改，全部禁止（§7/§10.1）

## 1. Task Overview

### 1.1 What We're Building

把 TICKET-20261031-pack-triage 的分诊裁定落成盘面事实：16 个待决 pack（14 个 pending 补验＋2 个 no-discriminative-power 收紧重验）逐个跑出行为验证数据并按台账合同翻牌或降级；verified 抽 3 个做触发层抽测；2–3 个真实任务做带包/不带包成本读数；Phase 1 的 Gate 4 条件 C1（ml-training 的 skill-only 声明）在本 Phase 落字销账。产物＝台账新状态＋声明/注册面落字＋16 份 eval 记录＋抽测与成本两份读数＋flip 清单，全部落证据根 `.tad/evidence/yolo/v409-basket/`。

### 1.2 Why We're Building It

台账停在 2026-06-01：26 个 pack 里只有 9 个有判别性行为证据、2 个实测无判别力、14 个从未验过。技术研究席的全量盘点＋外部证据（关键词触发实测约半数不触发）表明「有 fixture ≠ 有验证」；用户已定 v4.0.9 攒厚发版，pack 体系是发版内容的一部分，分诊关账是发版前置。窗口裁定：本版收口前未验完的 pack 自动转「观察」退出默认加载面——本 Phase 把 14 个 pending 全部实跑一遍，就是把转观察的集合压到最小且每一件有据。

### 1.3 🆕 Intent Statement（意图声明）

让台账的每一行状态都对得起它的证据：声称已验证的有 runner 数字，声称无判别力的有收紧后的复验数字，没验过的在本 Phase 全部验一遍并留下逐 pack 的记录；同时把 C1 的口径对账落字，使 driftcheck 的 (b)/(d) 不再挂着一个「已按裁定处置却仍被机械面报漂移」的 ml-training。

### 1.4 卸载记录（Offload Log）

- 裁定正本：`.tad/active/TICKET-20261031-pack-triage.md`（含窗口锚的连带调整在 TICKET-20261031-process-suggestions 与 BASKET 第 3 行）
- 设计基线：`p3-baseline-ledger-fixtures.txt`、`p3-baseline-driftcheck.txt`、`phase3-look.md`（均在证据根）
- Phase 1 条件 C1 正本：`phase1-gate-report.md` Gate 4 裁定 3＋条件节；台账侧改动实录：`pack-ledger-diff.txt`

### 1.5 Requirement (human's words)

Epic Phase 3（用户点数 1）：「pack 分诊主体：pending 补验（基线失败派生法）＋verified 降格表述＋web-backend/data-engineering 收紧重验＋verified 触发抽测＋成本读数」，并承接 Phase 1 Gate 4 条件 C1（AC8 选 (i)，属主本 Phase）。裁定细节以票面原文为准（§1.4）。

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别

- patterns/pack-evaluation.md —— 判别闸必须跑独立 discriminative 字段；负对照必须 FAIL 才算闸成立；收紧方向＝更少、更 pack 独有的词
- patterns/pack-build-rules.md —— Pack Loader Thin On-Demand（pointer 协议原文＋frozen 跳过＋escalate 两条件）；反 slop 质量杠（具体数字/阈值/规则名才有判别力）
- patterns/ac-verification.md —— 基线先验、fixture 须有见证、dry-run 先行（本设计 §9.1 的 Verified Output 列即其执行）

### 步骤 2：历史经验摘录

- 判别闸条目（pack-evaluation，2026-05-31）：旧闸把 pack 独有 marker 与通用词混在一个 pattern 里计数，ai-evaluation 的 CONTROL（无包）靠通用词 3/3 PASS——纯验证剧场。修法是结构性的：闸有自己的字段（`discriminative_pattern`＋`min_discriminative`），PASS 只由该字段驱动。本 Phase 全部配方建立在此结构上；收紧就是往这个字段里换更独有的词。
- Loader 条目（pack-build-rules，2026-09-10）：关键词命中只 announce 至多 2 个 pointer（定式 `Pack pointer: {name} — {one-line when}. Path: {SKILL.md}. Do not load unless escalated.`）；registry status=frozen 在 auto-match 跳过；escalate 只许人类点名或有记录的 failure-retry。触发抽测测的就是这条面，announce 定式逐字作可观察量（D8）。
- 噪声底条目（pack-evaluation，2026-09-29）：一次跑出的 delta 在重跑噪声内不算改进；抽测与成本读数都是单次存在级读数，记录时按「数量级/存在性」表述，不许写成精确率（D8/D9 的表述纪律）。

### Blake 确认

- [ ] 已读上述三类 pattern 中与本 handoff 相关的条目
- [ ] 已读台账文件头合同（status 语义＋翻牌属主＋runner 合同）

---

## 2. Background Context

### 2.1 Previous Work

- 2026-05-31／06-01 首轮行为验证：9 个 pack 取得 verified（2026-10-31 已按票面改记 verified-discriminative），web-backend／data-engineering 实测无判别力（CONTROL 同样 PASS），余 14 个 pending 从未实跑。归档 outputs 在 `.tad/evidence/pack-eval/2026-05-31` 与 `2026-06-01`。
- 2026-10-31 Phase 1（本 Epic）：台账词表落字（新增 no-discriminative-power 正式语义、verified 改记 verified-discriminative）、兼容注释改 metadata-only、ml-training 摘注册（源包移 retired、注册 26→25、台账行转 deregistered）、2 个未入账 pack 补行 pending。实录 `pack-ledger-diff.txt`。
- Phase 1 Gate 4 条件 C1：driftcheck (b)/(d) 浮现 ml-training——归因已实证为「源包摘注册后、仍在盘的安装投影 `.agents/skills/ml-training/` 无源包可对」，Gate 4 裁定选 (i) 以 skill-only 声明处置，属主本 Phase。

### 2.2 Current State

设计期实测（基线件 A–H 节）：台账 26 行＝verified-discriminative 9／no-discriminative-power 2／pending 14／deregistered 1；注册表 25 条（active 12／frozen 13）；声明文件 10 名、无 ml-training；driftcheck exit 1，(b)＝ml-training＋production-observation，(d) 同名两条 WARN，(a)/(c) 空；runner 对两包归档 outputs 复现台账数字（web-backend WITH 4/3 PASS、CONTROL 3/3 PASS；data-engineering WITH 10/4 PASS、CONTROL 5/4 PASS）；research-methodology 的 fixture 文件不存在；verified ∧ active 恰 3 包。

### 2.3 Dependencies

- conductor 的 spawn 面：全部 run 会话（验证两臂、抽测、成本）由 conductor 派发洁净子代理（runner 脚本头原文的分工：脚本只断言、conductor 负责 spawn 产出 outputs）；Blake 不自派会话跑验证（与台账合同「NOT by Blake」同向，见 D6/D7）
- `pack-eval-runner.sh`、`.tad/hooks/lib/pack-registry-driftcheck.sh`、`scan-packs.sh` 三脚本现行可用（设计期实跑过前两件，scan-packs 由 Phase 1 实跑过）
- 归档 outputs（2026-05-31／06-01 两目录）是收紧预检的 oracle，实施期只读

---

## 3. Requirements

### 3.1 Functional Requirements

- FR1（C1）：`skill-only-declarations.txt` 增 ml-training 声明行＋对账注释；重跑 driftcheck 后 (b)/(d) 无 ml-training、(s) 含 ml-training，其余行与基线逐行同（production-observation 两行保留）。
- FR2（收紧重验）：web-backend、data-engineering 各按 §4.3 收紧其 fixture 的 `discriminative_pattern` 并重验两臂；WITH PASS ∧ CONTROL FAIL（干净 delta）则进翻牌清单（→verified-discriminative）；WITH PASS ∧ CONTROL 仍 PASS（`reverify-no-delta`）则走 §4.5 降级落字；WITH FAIL 记 `with-arm-fail`，不降级、留 no-discriminative-power 并记明缺失的 marker 面（映射正本 §4.3 步 5）。
- FR3（pending 补验）：14 个 pending 逐个按 §4.4 配方（基线失败派生法）实跑，每 pack 一份 eval 记录、一个闭集 Outcome；research-methodology 先按 D11 补 fixture 再入配方。
- FR4（触发抽测）：verified ∧ active 的 3 个 pack 各 3 条真实风格 prompt 的洁净会话抽测，逐条记录 announce 与否（定式逐字）与率。
- FR5（成本读数）：3 个真实任务各跑 CONTROL／WITH 两臂，按 look 件的可采面记轮次／工具调用／字节／时长并成对表报告（数量级表述）。
- FR6（翻牌）：全部 eval 数据齐后，conductor 按 flip 清单执行台账翻牌（D7 的属主与形态）；翻牌后台账与清单、runner 行三方一致。
- FR7（收口记录）：eval 汇总（含窗口/观察携带行）、flip 清单、COMPLETION 三件落证据根/active 的既定位。

### 3.2 Non-Functional Requirements

- NFR1 证据先行：任何状态变更（翻牌、降级、声明）之前，其 runner 行与记录先落盘；顺序倒置即违规。
- NFR2 作用域：driftcheck 与计数类判据一律对基线取 delta；不许以 exit 0 或全绿为目标（production-observation 不在本 Phase 作用域）。
- NFR3 表述分级：verified-discriminative 只表示单 fixture 存在性证据；抽测与成本读数是存在级/数量级读数，记录中不许升级表述（不写「触发率达标」、不写精确 token 节省率）；verified-in-use 本 Phase 不产生（D13）。

---

## 4. Technical Design

### 4.0 决策表（每条决策点名验收方式）

| # | 决策 | 依据 | Accepted by |
|---|------|------|-------------|
| D1 | C1 落字：声明文件增 `ml-training` 一行＋对账注释（要件见 §4.1）；台账 deregistered 行、retired 源包、注册表均不动 | Phase 1 Gate 4 裁定 3 选 (i)；两处口径作用对象不同（票面治源包、C1 治安装投影），对账全文见 §4.1 | AC1、AC2 |
| D2 | 收紧法：先对归档 outputs 做分离预检（候选 pattern 须使归档 CONTROL 跌破 min、WITH 仍达 min），过检才许开新会话；两包同法 | 基线件 F 节（归档 outputs 在盘且数字复现）；pack-evaluation 判别闸条目（收紧＝更独有） | AC3、AC4 |
| D3 | 降级落字四件套（仅 Outcome=`reverify-no-delta` 时，即 WITH PASS 而 CONTROL 仍 PASS）：台账行转 deregistered＋降级注释、源包移 retired、scan-packs 重生成注册表、投影以 skill-only 声明保留为参考（注释记降级） | 票面「降级为普通参考文档、退出 pack 体系」；投影处置从 ml-training/C1 先例（声明保留）而非删除——删除无先例且不可逆 | AC9、AC10 |
| D4 | pending 配方＝基线失败派生法（§4.4）：先跑 CONTROL；CONTROL 跌破闸→跑 WITH 定 delta；CONTROL 过闸→实质分析找其做错/做漏处派生新 fixture 再跑两臂；CONTROL 实质亦干净→记 no-delta-clean-control | 票面裁定 1 原文；台账 status 语义（CONTROL 过闸即无判别力的定义面） | AC5、AC6、AC8 |
| D5 | Pilot＝ai-tool-integration，S2 先行；证伪出口见 Gate 2 节 Pilot 声明 | canonical pilot 义务（fan-out 16 同构单元）；基线件 B 节（单 fixture、decision 型） | AC5 |
| D6 | run 产出分工：全部验证/抽测/成本会话由 conductor 派发洁净子代理；会话自写 output 文件并以 provenance 块收尾；Blake 备 prompt 文件、跑 runner、写记录 | runner 脚本头分工原文（脚本只断言、conductor 驱动 spawn）；台账合同「NOT by Blake」 | AC7、AC16 |
| D7 | 翻牌是 conductor 的独立步（S6），在全部 eval 记录齐后、Gate 3 之前执行；Blake 只交 flip 清单草案。台账原文「driven in Y6」读作：翻牌属评审段的 conductor 动作、不是实施者的写集——本设计以 S6 独立步＋Gate 3 对翻牌后状态全量核对承接其实质 | 台账文件头合同原文；conductor-protocol 的角色分离（实施者不判自己的活） | AC9 |
| D8 | 触发抽测样本＝verified-discriminative ∧ registry status=active，恰 3 包（ai-evaluation、code-security、agent-orchestration）；frozen 的 6 个 verified 不抽（抽了只测到冻结）；每包 3 条 prompt；announce 以 loader 定式逐字为可观察量；结果只记录不设率门槛 | 基线件 C 节的 join 结果；pack-build-rules loader 条目；NFR3 | AC11 |
| D9 | 成本读数＝3 个真实任务（§4.8）×两臂；读数取会话 JSONL 可数代理（assistant 轮次、工具调用数、JSONL 字节、时长、output 字节）；精确 token 数在本 harness 不可采（look 件三探针），按票面「数量级即可」交付 | phase3-look.md；票面成本条 | AC12 |
| D10 | 窗口锚从 4.0.9（本版收口）：票面正文写 v4.0.10，其后连带调整（process-suggestions 票＋BASKET 第 3 行＋grounding）已改锚 4.0.9；本 Phase 把 14 个 pending 全量实跑，转观察的集合只剩 WITH 臂失败者（若有），其转换动作属发版收口链、不在本 Phase 写集，携带行写入 eval 汇总 | 文件权威序：同源文件中较晚的 conductor 裁定覆盖票面正文；冲突在此显名记录 | AC14 |
| D11 | research-methodology 特例：先按其 SKILL 五阶段框架 authored 基础 fixture（落 `.agents/skills/research-methodology/examples/five-phase-pipeline.md`，与台账注释同名），再入 §4.4 配方；台账注释与盘面不符的事实记入其 eval 记录 | 基线件 B 节实测（文件不存在）；补 fixture 后注释即成真，不需改台账注释 | AC13 |
| D12 | 多 fixture 的 pack 只跑主 fixture：主 fixture＝台账注释点名者（ai-prompt-engineering→hallucination-diagnosis、product-thinking→pressure-test-verdict、video-creation→photo-to-beat-sync）；主 fixture 结构性不可用时才转第二 fixture 并在记录中写明 | 台账 status 语义（单 fixture 存在性证据即足）；基线件 B 节库存 | AC6 |
| D13 | 本 Phase 不产生 verified-in-use：抽测与成本数据只作将来该等级的候选证据记入汇总，不翻任何包到 verified-in-use | 台账文件头（该等级须真实任务回放＋触发率证据，RESERVED） | AC14 |

### 4.1 C1 落字规格（FR1）

在 `.tad/capability-packs/skill-only-declarations.txt` 末尾追加：(1) 一段声明注释，须含四要素——出处（Phase 1 Gate 4 条件 C1／AC8 选 (i)）、票号（TICKET-20261031-pack-triage）、对账句（源包已按票摘注册并移入 retired，本声明仅针对仍在盘的安装投影 `.agents/skills/ml-training/`，使其按 by-design skill-only 论）、证据指针（phase1-gate-report.md 与 pack-ledger-diff.txt）；(2) 声明行 `ml-training` 一行。文件头既有格式先例（Declared 日期＋批次＋per-item evidence）照行。落字后跑 driftcheck 存 `p3-driftcheck-after-c1.txt`：判读只对基线取 delta（AC2）。

### 4.2 run 会话产出形态（D6，全 Phase 通用）

- prompt 文件：Blake 在证据根 `p3-run-prompts/` 下逐臂备好，命名 `<pack>-<arm>.md`（arm ∈ CONTROL／WITH；抽测与成本另有前缀，见 §4.7/§4.8）。CONTROL 臂 prompt 只含 fixture 场景原文＋产出指令（把答复写入指定 output 路径、末尾附 provenance 块），不出现 pack 名与 pack 路径；WITH 臂 prompt 含场景原文＋「先读 `<pack SKILL.md 绝对路径>` 并按其规程作答」的 escalate 指令＋同一产出指令。
- output 文件：`.tad/evidence/yolo/v409-basket/p3-eval-outputs/<pack>-<fixture>-<arm>.md`（与 6 月归档同形）；run 会话自己写入，返回只给一行回执（路径＋字节数）。此目录只收验证面（§4.3/§4.4）outputs——抽测与成本的产出落点在此钉死：抽测会话不产 output 文件（答复由 Blake 逐字摘入 `p3-trigger-sampling.md`）；成本臂 output 落 `.tad/evidence/yolo/v409-basket/p3-cost-outputs/<task>-<arm>.md`（task ∈ T1／T2／T3），provenance 块要求与验证 output 同（WITH 点名 pack SKILL.md、CONTROL 写 none）。AC7／AC16 的清点面只含 `p3-eval-outputs/`，成本 outputs 不入其计数（Gate 2 一致性面 P1-2 处置）。
- provenance 块：每个 output 末尾必须有 `## Run provenance` 块，含三行：会话类型（CONTROL／WITH）、实际读过的文件清单、是否加载 pack（WITH 须点名 SKILL.md 路径；CONTROL 须写 none）。Gate 3 对 provenance 与盘面事实做抽查交叉（pack-evaluation 的盲判 provenance 教训：自报不许无核对地采信）。
- run 清单：conductor 每派一臂，在 `p3-run-manifest.md` 记一行（pack／arm／prompt 文件／output 路径／子代理 agent_id／回执字节数）；成本读数与 AC7 的清点都以此清单为源。成本臂行记 `p3-cost-outputs/` 路径、与验证行分节记，故清单中 `p3-eval-outputs/` 的出现次数恒等于验证 outputs 数（AC7 第一值口径）。

### 4.3 收紧重验规格（FR2，web-backend／data-engineering）

1. 改前留底：两 fixture 各复制一份到 `p3-fixture-baseline/`（原样，作 AC4 的比对底）。
2. 候选词提取：从该 pack 自己的 SKILL.md 与 references 中提取候选判别词——只收三类：pack 的命名规则/条目名、pack 独有的数值阈值、pack 造的术语（anti-slop 杠：前沿模型凭训练数据说不出的具体数与名）。现行 pattern 里的通用词（keyset/cursor/preStop/SIGTERM；train-serve skew/RRF/SCD2/pre-filter 一类）按台账 follow-up 原文判为不判别，须移出或降为上下文（pattern 只留独有词；min_discriminative 可随词数下调，下限 2，照判别闸条目「thin packs min 2」）。
3. 分离预检（不烧会话）：候选 pattern 逐个对归档 WITH/CONTROL outputs 跑 runner 同款计数（`grep -oE <pattern> | sort -u | wc -l`）——须 CONTROL < min ≤ WITH 才算 SEPARATED；结果行写入该 pack 的 eval 记录（`Pre-check: SEPARATED` 或 `Pre-check: NOT-SEPARATED`，闭集）。NOT-SEPARATED 时换候选重试，本步最多三轮候选；三轮皆不分离则以最佳候选进新跑并在记录中显名（新跑的 CONTROL 可能与归档不同，预检不分离不等于新跑必不分离，但必须显名这是带病推进）。
4. 落字：新 pattern 写回 fixture frontmatter 的 `discriminative_pattern`（及必要时 `min_discriminative`）；场景正文与 frontmatter 其余字段一字不动（AC4 以正文哈希守）。
5. 新跑两臂（§4.2 形态，恒跑两臂）→ runner 断言 → 按 §4.6 写 eval 记录。分支映射钉死如下（闭集，不许即兴）：WITH PASS ∧ CONTROL FAIL＝干净 delta → Outcome `reverify-verified-candidate`，进 flip 清单；WITH PASS ∧ CONTROL PASS → Outcome `reverify-no-delta` → 走 §4.5 降级；WITH FAIL（不论 CONTROL 结果）→ Outcome `with-arm-fail`，pack 留 no-discriminative-power、不进 §4.5，记录中须按 §4.4 步 2 同款写明 WITH 缺失的 marker 面（WITH FAIL 证明的是 pack 产不出自己的判别词，不是判别力为零，降级判据 CONTROL 过闸须先有 WITH PASS ∧ CONTROL PASS 的证据）。

### 4.4 pending 补验配方（FR3，基线失败派生法，14 包同法）

1. CONTROL 臂先行（主 fixture 场景，§4.2 形态）→ runner 断言 CONTROL output。
2. CONTROL disc < min（闸 FAIL）：跑 WITH 臂 → runner 断言。WITH PASS → Outcome `verified-candidate`；WITH FAIL → Outcome `with-arm-fail`（pack 留 pending，记录中写 WITH 缺失的 marker 面）。
3. CONTROL disc ≥ min（闸 PASS、无 delta 空间）：做实质分析——逐条比对 CONTROL output 与该 pack 的规则面，找它做错或做漏且被 marker 闸漏掉的点。每条须双引：CONTROL output 原文摘句＋pack 规则出处（文件＋条目）。找到 ≥1 条 → 按 §4.4.1 派生 fixture、跑派生 fixture 的两臂：WITH PASS ∧ CONTROL FAIL → `derived-verified-candidate`；否则 `derived-no-delta`（pack 按 no-discriminative-power 的 follow-up 形态记：台账注释写明已派生仍不判别）。一条都找不到 → `no-delta-clean-control`（进 flip 清单转 no-discriminative-power，注释照既有两包的 follow-up 形态写收紧待办）。
4. 每 pack 的分支走向与全部 runner 行写入其 eval 记录（§4.6）；Outcome 只许用闭集：`verified-candidate`／`derived-verified-candidate`／`with-arm-fail`／`derived-no-delta`／`no-delta-clean-control`（重验两包另加 `reverify-verified-candidate`／`reverify-no-delta`）。

#### 4.4.1 派生 fixture 规格

新文件 `.agents/skills/<pack>/examples/<主fixture名>-derived.md`：frontmatter 照既有 fixture 形（pack／scenario／discriminative_pattern／min_discriminative／expected_behavior／anti_pattern）；scenario 取自实质分析找到的 CONTROL 出错场景（把出错点变成任务要求），discriminative_pattern 只含与出错点对应的 pack 独有词；min_discriminative ≥2。派生 fixture 是新增文件，不改主 fixture。

### 4.5 降级落字形态（FR2 的条件分支，D3）

触发：某重验包 Outcome = `reverify-no-delta`（WITH PASS ∧ CONTROL PASS——收紧后的判别词仍被无包答复命中）。WITH FAIL（`with-arm-fail`）不触发本节，理由见 §4.3 步 5。落字四件套，缺一不可：①台账行 status 改 `deregistered`，注释写明「收紧重验 <日期> 仍无 delta（runner 数字），按 TICKET-20261031-pack-triage 降级为普通参考文档」——此行属 S6 conductor 翻牌面，与其他翻牌同批执行；②源包目录 `.tad/capability-packs/<name>/` 整目录移入 `.tad/capability-packs-retired/<name>/`（字节保留）；③`scan-packs.sh` 重生成 `pack-registry.yaml`（该包行消失，计数按公式减）；④声明文件按 §4.1 同形追加该包声明行＋降级注释（投影自此为 by-design skill-only 参考）。未触发的包，本节不执行，COMPLETION 显名「降级分支未触发」或逐包记触发与否。

### 4.6 eval 记录形态（每 pack 一份 `p3-eval-<pack>.md`，落证据根）

固定节，缺一不可：`## Fixture`（主 fixture 路径；重验包另含 Pre-check 行）、`## Runs`（逐臂一行：prompt 文件／output 路径／字节数）、`## Runner lines`（runner 原始输出逐字，含 disc 数字）、`## Analysis`（恒在：CONTROL 过闸时写实质分析的双引条目或 CLEAN 声明；CONTROL 未过闸时只写一行 `n/a — CONTROL below gate`）、`## Outcome`（闭集一行）。Gate 3 以此形态做机械清点（AC6）。

### 4.7 触发抽测规格（FR4）

样本 3 包（D8）× 每包 3 条 prompt：prompt 由 Blake 按「真实用户会怎么说」写——该 pack 领域内的真实任务请求，不出现 pack 名、不出现「加载/pointer」字样、不引关键词表原句（关键词是日常词时自然出现不算违规，刻意堆叠算）。prompt 文件落 `p3-run-prompts/trigger-<pack>-<n>.md`，全文附入抽测记录备查。会话由 conductor 派洁净子代理（仓内一般会话形态，不做角色激活、不给任何 pack 提示），任务即 prompt 本身；记录其首个答复中是否出现 pointer announce：命中 loader 定式（`Pack pointer:` 开头行）记 `ANNOUNCED` 并逐字抄该行，出现对 pack 的实质加载/引用记 `ESCALATED-UNPROMPTED`（异常，显名），皆无记 `NOT-ANNOUNCED`。产物 `p3-trigger-sampling.md`：9 行结果表（pack／prompt 号／结果／announce 原行或 —；结果词只许出现在本表内）＋逐 pack 率行＋一行 loader 存活注记。率行措辞钉死：每包一行、恒为 `Rate <pack>: <n>/3` 形，不作表格行、不含结果词（ANNOUNCED／ESCALATED-UNPROMPTED 及其子串）——AC11 的计数面因此只落在结果表 9 行（Gate 2 一致性面 P2-1 处置）。存活注记行恒以 `Loader liveness:` 开头：9 条中任一 ANNOUNCED ⇒ 注记写明 loader 在洁净会话形态下存活；0/9（全 NOT-ANNOUNCED）⇒ 注记须逐字含 `not readable as pack trigger rates` 一句，显名本轮结果不可读作 pack 触发率——loader 在该会话形态下未被观测到与 pack 从不触发不可区分（Gate 2 风险面 F-R1 携带条件）。注记行措辞钉死（Gate 2 风险面复审 F-RR2 处置，所选支＝钉死注记措辞，与本节「结果词只许出现在本表内」的全局约束同支）：注记行不含结果词（ANNOUNCED／ESCALATED-UNPROMPTED）及其子串、不含任何包名；引用首个命中只许写其所在行号（形如 `first hit at line 5`），不许复写结果词、不许抄 announce 原行——否则注记行自身会污染 AC11 的第一值与包名计数（实测：注记行含结果词时 AC11 第一值 10≠9，见第二轮修订记录）。抽测只记录（D8/NFR3）。

### 4.8 成本读数规格（FR5）

任务三件（都是本仓真实对象）：T1 code-security——审 `.tad/hooks/lib/gate3-check.sh` 的安全问题；T2 rag-retrieval——为 `.tad/evidence/` 语料检索设计分块/召回方案；T3 agent-memory——为带压缩的长跑席位设计上下文/记忆方案。每任务两臂（CONTROL 不给 pack；WITH 按 §4.2 escalate 形态读对应 pack），共 6 个会话，conductor 派发、回执与 agent_id 记入 run 清单成本节。每臂 output 的落点与命名按 §4.2 钉死（`p3-cost-outputs/<task>-<arm>.md`），不入 AC7／AC16 的清点面。每臂落盘后由 Blake 从该会话 JSONL（`/home/hatch/agents/agent-<id>/sessions/<id>.jsonl`）数四值：assistant 角色 item 数（轮次）、带 name 的 item 数（工具调用）、文件字节数、首尾 created_at 时长；加 output 字节数。产物 `p3-cost-readings.md`：6 行对表＋逐任务差值行，表述只到数量级（倍数带宽，如「约 1.5–2 倍」，不写百分比精确值）。复核脚本 `p3-cost-recount.py`（Blake 写，落证据根）：读表中六个 JSONL 路径重数四值并比对，全合打印 `MATCH 6/6`（AC12）。

### 4.9 翻牌步形态（FR6，S6，conductor 属主）

Blake 交 `p3-ledger-flips.md` 草案：逐行（pack／现状态／拟状态／凭据＝eval 记录路径＋runner 数字摘录）。conductor 核对后亲手改台账：verified 类按既有注释形补「WITH disc x/min PASS, CONTROL disc y/min FAIL — clean delta (2026-10-31)」；no-discriminative 类补 follow-up 注释；降级类按 §4.5①；`last_updated` 改 2026-10-31。翻牌后 conductor 在清单上签执行行，签行须含注记一句：「翻牌时点与属主读法见 HANDOFF-20261031-pack-triage D7（台账『driven in Y6』读法）」——使盘面在翻牌点自带出处（Gate 2 风险面 F-R2 处置）。Gate 3 以翻牌后台账＋清单＋records 三方对账（AC9）。

---

## 5. 🆕 强制问题回答（Evidence Required）

- MQ1 验证怎么跑：全部行为结论出自 `pack-eval-runner.sh` 单 fixture 模式对捕获 outputs 的实跑行；设计期已干跑复现两包台账数字（基线件 F 节），方法非空想。
- MQ2 翻牌凭什么可信：三道机械面——翻牌属主与实施者分离（台账合同，D7）；每行翻牌在 flip 清单上带 runner 数字凭据；Gate 3 run 评审在一次性副本内全量重跑 runner 对账（RP1）。
- MQ3 什么会静默坏：(a) WITH 臂会话没真读 pack 却产出像样答复——provenance 块＋Gate 3 抽查交叉对冲，且 runner 的判别词本身就是读没读 pack 的行为证据；(b) CONTROL 臂被污染（prompt 漏进 pack 名）——prompt 文件落盘备查、Gate 3 可逐字核；(c) driftcheck 被当成要冲 exit 0——NFR2 与 AC2 的 delta 口径对冲。
- MQ4 承重依赖是否在盘：runner／driftcheck 设计期实跑过；归档 outputs 在盘（F 节）；JSONL 计数面实测可读（look 件）；scan-packs 由 Phase 1 于本月内实跑过。无未验依赖。
- MQ5 规模与成本：run 会话数由配方分支决定、可数——验证面每包 CONTROL 恒跑 1 臂；WITH 臂仅在 CONTROL 跌破闸时跑（+1）；CONTROL 过闸且实质分析找到出错点时跑派生 fixture 两臂（+2，替代 WITH 臂）。故单包会话数 ∈{1,2,3}，验证面总量 ∈[18,46]（下限＝14 pending×1＋2 重验×2；上限＝14×3＋2×2，推导与 AC7 同）；抽测 9，成本 6。pilot 先测单臂时长与产出形态，fan-out 按 pilot 实测排批（§8.4）。

---

## 6. Implementation Steps（分Phase）

- S1 备料（Blake）：①C1 落字（§4.1）＋driftcheck 复跑存 `p3-driftcheck-after-c1.txt`；②两 fixture 改前留底（§4.3.1）＋收紧候选提取与分离预检（§4.3.2–3），预检行写入两包 eval 记录骨架；③research-methodology 基础 fixture authored（D11）；④备齐 pilot 的 prompt 文件与 outputs 目录、run 清单骨架。
- S2 Pilot（conductor 派发＋Blake 断言）：ai-tool-integration 按 §4.4 跑全程（CONTROL→按分支 WITH／派生），Blake 跑 runner、写完其 eval 记录。pilot 记录落盘且形态合 §4.6 才许进 S3；触发证伪出口则停步回 conductor。
- S3 Fan-out（conductor 分批派发＋Blake 断言/分析）：其余 13 个 pending＋2 个重验包（收紧落字 §4.3.4 后）逐包走配方；CONTROL 臂可成批派发，WITH／派生臂按分支跟进；Blake 逐包完成 eval 记录。全部 16 份记录齐且 Outcome 闭集齐，才许进 S6 的清单草案。
- S4 抽测与成本（conductor 派发＋Blake 记录）：9 个抽测会话＋6 个成本会话按 §4.7/§4.8 执行；Blake 写 `p3-trigger-sampling.md` 与 `p3-cost-readings.md`（含 recount 脚本实跑结果）。
- S5 条件降级（Blake，仅触发时）：对 Outcome 为 `reverify-no-delta` 的重验包执行 §4.5 的 ②③④（①在 S6 与翻牌同批）；跑 driftcheck 与 scan-packs 后计数存记录。`with-arm-fail` 的包本步不执行任何落字。未触发则在本步写明未触发及理由（两包都拿到 delta，或 WITH 臂失败）。
- S6 翻牌与收口（conductor 属主＋Blake 备件）：①Blake 交 flip 清单草案＋eval 汇总草案（`p3-eval-summary.md`，含 16 包 Outcome 总表与 D10 的观察携带行）；②conductor 按 §4.9 执行翻牌并签清单；③conductor 走 RP3（抽测处置行写入汇总；抽测为 0/9 时处置行须逐字含 §4.7 的 `not readable as pack trigger rates` 显名句）；④Blake 写 COMPLETION（含 RP2 的三问自答材料指针与写集对账表）。
- Gate 3 备审注记：run 评审按 RP1 在一次性副本内重跑全部 runner 行并与 records 比对；spec 评审核翻牌后台账 vs 清单 vs records 三方一致、声明/注册计数公式、写集对账。两评审都不许采信 eval 记录的转述数字，须以重跑与 grep 实测为准。

---

## 7. File Structure

### 7.1 写集（Files to Modify/Create，逐件）

本仓内容面：
- `.tad/capability-packs/skill-only-declarations.txt`（改：C1 追加；S5 触发时再追加降级声明）
- `.tad/capability-packs/behavioral-eval-status.yaml`（改：**仅 conductor 于 S6 翻牌**，Blake 不许动此文件）
- `.agents/skills/web-backend/examples/api-pagination-review.md`（改：仅 frontmatter 的判别字段，§4.3.4）
- `.agents/skills/data-engineering/examples/data-engineering-fixture.md`（改：同上）
- `.agents/skills/research-methodology/examples/five-phase-pipeline.md`（新：D11 基础 fixture）
- `.agents/skills/<pack>/examples/<主fixture>-derived.md`（新，条件：§4.4 派生分支触发的包才有）
- `.tad/capability-packs-retired/<name>/`（新，条件：S5 降级触发的源包移入）
- `.tad/capability-packs/pack-registry.yaml`（改，条件：仅 S5 以 scan-packs.sh 重生成；永不许手改）

证据根 `.tad/evidence/yolo/v409-basket/`（新，除已存在的设计期三件外）：
- `p3-driftcheck-after-c1.txt`、`p3-fixture-baseline/`（两 fixture 改前副本）、`p3-run-prompts/`（逐臂 prompt）、`p3-eval-outputs/`（验证面 run 产出）、`p3-cost-outputs/`（成本臂产出，6 件）、`p3-run-manifest.md`、`p3-eval-<pack>.md` ×16、`p3-trigger-sampling.md`、`p3-cost-readings.md`、`p3-cost-recount.py`、`p3-ledger-flips.md`、`p3-eval-summary.md`、`p3-ledger-check.py`（AC9 的对账脚本，Blake 写：读 flip 清单与台账 yaml，核每行拟状态与实状态一致并复计四类计数，合则打印 LEDGER-CONSISTENT）

active 面：
- `.tad/active/handoffs/COMPLETION-20261031-pack-triage.md`（新，Blake 收口件）

### 7.2 Grounded Against（设计期逐件读过的写集文件头）

- `behavioral-eval-status.yaml`：全文读（含文件头合同与 26 行注释，收紧 follow-up 原文在此）
- `skill-only-declarations.txt`：全文读（10 名＋格式先例）
- 两重验 fixture：路径与 frontmatter 经 runner 实跑验证（F 节四行即其现行 pattern 的实测行为）；`api-pagination-review.md` 在 `.agents/skills/web-backend/examples/`、`data-engineering-fixture.md` 在 `.agents/skills/data-engineering/examples/`，库存探针实证
- research-methodology：不存在性经 find＋grep 双探针实证（基线件 B 节）

---

## 8. Testing Requirements

- 每条行为结论的测试＝runner 实跑行（§4.6 逐字入记录）；Gate 3 以 RP1 全量重跑为复核，不采信转述。
- C1 的测试＝driftcheck 对基线 delta（AC2）；收紧的测试＝预检分离＋新跑 delta（AC3/AC4＋各 pack 记录）；翻牌的测试＝三方对账脚本＋Gate 3 grep 实测（AC9）。
- 负对照纪律：CONTROL 臂即每个验证单元的负对照；无 CONTROL 行的验证结论一律无效（判别闸条目）。

## 8.4 Friction Preflight

- 会话量：验证面 ∈[18,46]（分支算术见 MQ5，派生分支已含在上限内）、抽测 9、成本 6，最坏情形 61 个洁净会话；pilot 先实测单臂耗时与回执形态，conductor 据此分批（建议每批 ≤8 臂），批间 Blake 完成该批记录再开下批，避免 outputs 堆积无人断言。
- driftcheck 的 exit 1 是基线常态（production-observation），实施与评审都不许把「exit 仍为 1」记为失败；判据永远是 (a)–(d) 的逐节 delta。
- JSONL 路径依赖本 harness 的 agent 目录布局（look 件实测）；若实施时目录布局已变，成本读数按同一探针法重新定位数源并在记录中显名，不许静默换源。
- 回滚：C1 声明行删除即回滚；翻牌按 flip 清单逐行改回即回滚；降级移动反向移回＋scan-packs 重跑即回滚；fixture pattern 改动以 `p3-fixture-baseline/` 副本覆盖即回滚。全部回滚动作不需删任何字节。

## 8.5 Feedback Collection (Non-Code Artifacts)

- eval 记录、抽测、成本三类记录都是给 conductor／Gate 4 的判读面：Outcome 与数字逐字来自 runner 与计数脚本，禁止修辞加工；汇总（`p3-eval-summary.md`）只许转录记录中的数字并点名其出处文件。

---

## 9. Acceptance Criteria

Blake 的实现被认为完成，当且仅当：
- [ ] §9.1 全部 16 行按其 Verification Method 实跑且合 Expected Evidence
- [ ] 16 个目标 pack 各有一份合 §4.6 形态的 eval 记录，Outcome 全在闭集内（AC6）
- [ ] 台账翻牌由 conductor 在 S6 执行完毕且三方对账一致（AC9）；Blake 未动台账 status 列
- [ ] C1 销账（AC1＋AC2）；Gate 4 的 RP2 三问可只读三件答出

---

## 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE — Gate 3 executes each row

> 方法文法：command｜path-check｜fixture｜rubric-spawn｜light-tier N/A；纯散文非法。计数类 AC 的计数对象在方法文中写明。基线值全部来自设计期实测四件（p3-baseline-ledger-fixtures.txt／p3-baseline-driftcheck.txt／phase3-look.md／pack-ledger-diff.txt）；post-impl 行在未改树上应以「基线形态」失败（记录不存在或计数为基线值），这是其非空洞性的证明。全部命令在仓根执行。

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| AC1 | C1 声明落字（D1/FR1）：声明文件含 ml-training 声明行与对账注释（票号＋retired 出处两要素） | post-impl-verifiable | `grep -cx 'ml-training' .tad/capability-packs/skill-only-declarations.txt; grep -c 'TICKET-20261031-pack-triage' .tad/capability-packs/skill-only-declarations.txt; grep -c 'capability-packs-retired' .tad/capability-packs/skill-only-declarations.txt` | 三值依次 =1／≥1／≥1 | 基线：0／0／0（基线件 D 节：声明 10 名、无 ml-training） |
| AC2 | C1 销账判据（D1/FR1）：driftcheck 复跑对基线 delta——(b) 无 ml-training 有 production-observation、(s) 有 ml-training、(d) 无 ml-training，exit 仍 1 | post-impl-verifiable | `bash .tad/hooks/lib/pack-registry-driftcheck.sh > /tmp/p3-dc.txt 2>&1; echo $?; sed -n '/^(b)/,/^(c)/p' /tmp/p3-dc.txt \| grep -c 'ml-training'; sed -n '/^(b)/,/^(c)/p' /tmp/p3-dc.txt \| grep -c 'production-observation'; sed -n '/^(s)/,/^(d)/p' /tmp/p3-dc.txt \| grep -c 'ml-training'; sed -n '/^(d)/,$p' /tmp/p3-dc.txt \| grep -c 'ml-training'` | 五值依次 =1／0／1／1／0 | 基线（p3-baseline-driftcheck.txt 同法）：1／1／1／0／1 |
| AC3 | 收紧预检留痕（D2/FR2）：两重验包的 eval 记录各含一行闭集 Pre-check 结论 | path-check | `grep -c -e '^Pre-check: SEPARATED' -e '^Pre-check: NOT-SEPARATED' .tad/evidence/yolo/v409-basket/p3-eval-web-backend.md; grep -c -e '^Pre-check: SEPARATED' -e '^Pre-check: NOT-SEPARATED' .tad/evidence/yolo/v409-basket/p3-eval-data-engineering.md` | 两值各 =1（NOT-SEPARATED 时记录还须含三轮候选或带病推进的显名句，Gate 3 spec 面核） | 基线：两记录不存在（new） |
| AC4 | 收紧落字完整（D2/FR2）：两 fixture 的场景正文与改前副本逐字同、判别行已变 | post-impl-verifiable | `awk 'c==2{print} /^---$/{c++}' .tad/evidence/yolo/v409-basket/p3-fixture-baseline/api-pagination-review.md \| sha256sum; awk 'c==2{print} /^---$/{c++}' .agents/skills/web-backend/examples/api-pagination-review.md \| sha256sum; awk 'c==2{print} /^---$/{c++}' .tad/evidence/yolo/v409-basket/p3-fixture-baseline/data-engineering-fixture.md \| sha256sum; awk 'c==2{print} /^---$/{c++}' .agents/skills/data-engineering/examples/data-engineering-fixture.md \| sha256sum; diff <(grep '^discriminative_pattern' .tad/evidence/yolo/v409-basket/p3-fixture-baseline/api-pagination-review.md) <(grep '^discriminative_pattern' .agents/skills/web-backend/examples/api-pagination-review.md) > /dev/null; echo $?; diff <(grep '^discriminative_pattern' .tad/evidence/yolo/v409-basket/p3-fixture-baseline/data-engineering-fixture.md) <(grep '^discriminative_pattern' .agents/skills/data-engineering/examples/data-engineering-fixture.md) > /dev/null; echo $?` | 四个哈希成两对相等（第 1＝第 2、第 3＝第 4）；两 diff exit 各 =1（判别行确已变更） | 基线：改前副本由 S1 在动 fixture 前落盘（p3-fixture-baseline/）；设计期两 fixture 的现行 pattern 对归档 outputs 的行为见基线件 F 节 |
| AC5 | Pilot 成立（D5）：ai-tool-integration 的 eval 记录五节齐＋Outcome 在闭集 | path-check | `grep -c '^## ' .tad/evidence/yolo/v409-basket/p3-eval-ai-tool-integration.md; grep -c -e '^Outcome: verified-candidate$' -e '^Outcome: derived-verified-candidate$' -e '^Outcome: with-arm-fail$' -e '^Outcome: derived-no-delta$' -e '^Outcome: no-delta-clean-control$' .tad/evidence/yolo/v409-basket/p3-eval-ai-tool-integration.md` | 两值依次 ≥5／=1（五节＝Fixture／Runs／Runner lines／Analysis／Outcome，§4.6；Analysis 恒在，CONTROL 未过闸时其内容为一行 n/a） | 基线：记录不存在（new） |
| AC6 | Fan-out 全量（D4/D12/FR3）：16 个目标 pack 各有一份 eval 记录，含 ≥1 行 runner disc 行与 1 行闭集 Outcome | post-impl-verifiable | `cd .tad/evidence/yolo/v409-basket && n=0; for p in academic-research ai-agent-architecture ai-prompt-engineering ai-tool-integration ai-voice-production product-thinking research-methodology video-creation web-deployment web-frontend web-testing web-ui-design agent-computer-interface ai-podcast-production web-backend data-engineering; do f="p3-eval-$p.md"; if [ -f "$f" ] && grep -q 'disc ' "$f" && grep -q -e '^Outcome: verified-candidate$' -e '^Outcome: derived-verified-candidate$' -e '^Outcome: with-arm-fail$' -e '^Outcome: derived-no-delta$' -e '^Outcome: no-delta-clean-control$' -e '^Outcome: reverify-verified-candidate$' -e '^Outcome: reverify-no-delta$' "$f"; then n=$((n+1)); fi; done; echo $n` | =16 | 基线：16 份记录均不存在（new），同命令现跑 =0 |
| AC7 | Outputs 清点（D6）：run 清单所记 output 全部在盘非空，且数量与盘面文件数一致 | post-impl-verifiable | `grep -c 'p3-eval-outputs/' .tad/evidence/yolo/v409-basket/p3-run-manifest.md; ls .tad/evidence/yolo/v409-basket/p3-eval-outputs/ \| wc -l; find .tad/evidence/yolo/v409-basket/p3-eval-outputs/ -type f -size 0 \| wc -l` | 前两值相等且第二值 ∈[18,46]；第三值 =0。下限/上限均由 §4.4/§4.3 分支算术推导：pending 单包 outputs ∈{1,2,3}（CONTROL 恒 1 件；WITH 仅在 CONTROL 跌破闸时 +1；派生分支 CONTROL＋派生两臂共 3 件），重验两包恒 2 件——下限＝14×1＋2×2＝18，上限＝14×3＋2×2＝46。成本 outputs 落 `p3-cost-outputs/`、抽测不产 output，均不入此面（§4.2） | 基线：清单与目录不存在（new） |
| AC8 | 派生分支纪律（D4）：派生 fixture 文件数与派生类 Outcome 记录数相等；clean-control 记录各含 CLEAN 声明 | post-impl-verifiable | `ls .agents/skills/*/examples/*-derived.md 2>/dev/null \| wc -l; grep -l -e '^Outcome: derived-verified-candidate$' -e '^Outcome: derived-no-delta$' .tad/evidence/yolo/v409-basket/p3-eval-*.md \| wc -l; grep -l '^Outcome: no-delta-clean-control$' .tad/evidence/yolo/v409-basket/p3-eval-*.md \| xargs -r grep -L 'CLEAN' \| wc -l` | 前两值相等；第三值 =0（凡记 clean-control 者必有 CLEAN 声明，无一例外） | 基线：三值 0／0／0（派生文件与记录均不存在） |
| AC9 | 翻牌三方一致（D7/FR6）：对账脚本核 flip 清单与翻牌后台账逐行一致并复计行数 | post-impl-verifiable | `python3 .tad/evidence/yolo/v409-basket/p3-ledger-check.py; echo $?` | 输出含 `LEDGER-CONSISTENT` 与 `rows=26`；exit =0。脚本规格见 §7.1（读 p3-ledger-flips.md 与台账 yaml：每行拟状态＝实状态、四类计数与清单算式一致） | 基线：脚本与清单不存在（new）；台账现行计数见基线件 A 节（9／2／14／1） |
| AC10 | 注册/声明计数公式（D3）：注册表条目＝25 − 降级数；声明名数＝11 ＋ 降级数（11＝基线 10＋C1 的 ml-training） | post-impl-verifiable | `grep -l '^Outcome: reverify-no-delta$' .tad/evidence/yolo/v409-basket/p3-eval-*.md \| wc -l; grep -cE '^[[:space:]]*-?[[:space:]]*name:' .tad/capability-packs/pack-registry.yaml; grep -cv -e '^[[:space:]]*#' -e '^[[:space:]]*$' .tad/capability-packs/skill-only-declarations.txt` | 设第一值（降级数）为 D：第二值 =25 − D，第三值 =11 ＋ D（Gate 3 按此算式核，不许只对绝对数） | 基线：D 不存在（记 0 件触发面）；注册 25、声明名 10（基线件 C/D 节） |
| AC11 | 触发抽测齐（D8/FR4）：抽测记录 9 行齐、样本恰为 3 个 active verified 包各 3 行、每行有闭集结果词 | path-check | `grep -c -e 'ANNOUNCED' -e 'ESCALATED-UNPROMPTED' .tad/evidence/yolo/v409-basket/p3-trigger-sampling.md; grep -cF ' ai-evaluation ' .tad/evidence/yolo/v409-basket/p3-trigger-sampling.md; grep -cF ' code-security ' .tad/evidence/yolo/v409-basket/p3-trigger-sampling.md; grep -cF ' agent-orchestration ' .tad/evidence/yolo/v409-basket/p3-trigger-sampling.md; grep -c '^Loader liveness:' .tad/evidence/yolo/v409-basket/p3-trigger-sampling.md` | 五值依次 =9／3／3／3／1（第一值以多 -e 并集计行：含 ANNOUNCED 子串或 ESCALATED-UNPROMPTED 的行恰 9 行——NOT-ANNOUNCED 以子串计入、每行至多计一次；率行与存活注记行均已由 §4.7 钉死不含结果词及其子串，故不入第一值；第二至四值计含 ` <pack> ` 空格界定形的行：结果表行形 `| <pack> | …` 命中，率行 `Rate <pack>:` 的包名后紧随冒号不入、注记行不含包名亦不入；第五值＝loader 存活注记行在盘；当 9 行全为 NOT-ANNOUNCED 时，该注记行须含 `not readable as pack trigger rates` 句，Gate 3 spec 面核此条件内容） | 基线：记录不存在（new），第五值基线同为不存在 |
| AC12 | 成本读数齐且可复算（D9/FR5）：6 臂读数在表、recount 脚本全合 | post-impl-verifiable | `grep -c -e '^. T[123] . CONTROL' -e '^. T[123] . WITH' .tad/evidence/yolo/v409-basket/p3-cost-readings.md; python3 .tad/evidence/yolo/v409-basket/p3-cost-recount.py` | 两值依次 =6／输出含 `MATCH 6/6`。脚本规格见 §4.8（读表中六个 JSONL 路径重数四值比对） | 基线：表与脚本不存在（new）；数源可行性见 phase3-look.md |
| AC13 | research-methodology 基础 fixture 落盘（D11）：文件在盘且含判别字段 | post-impl-verifiable | `test -f .agents/skills/research-methodology/examples/five-phase-pipeline.md; echo $?; grep -c 'discriminative_pattern' .agents/skills/research-methodology/examples/five-phase-pipeline.md` | 两值依次 =0／=1 | 基线：文件不存在（test exit =1，基线件 B 节双探针实证） |
| AC14 | 汇总与携带（D10/D13/FR7）：eval 汇总含 16 包总表、观察携带行与 4.0.9 窗口行；台账无 verified-in-use 赋值 | path-check | `grep -c 'Observation carry:' .tad/evidence/yolo/v409-basket/p3-eval-summary.md; grep -c '4\.0\.9' .tad/evidence/yolo/v409-basket/p3-eval-summary.md; grep -cE ':[[:space:]]+verified-in-use' .tad/capability-packs/behavioral-eval-status.yaml` | 三值依次 =1／≥1／0 | 基线：汇总不存在（new）；台账第三值现行 =0（基线件 A 节：该等级仅文件头注释提及、从未赋值） |
| AC15 | 写集对账（NFR1）：COMPLETION 的写集对账表逐行落在 §7 写集类内，无点名外改动 | path-check | COMPLETION-20261031-pack-triage.md 含写集对账表（path-check：`grep -c 'Write-set reconciliation' .tad/active/handoffs/COMPLETION-20261031-pack-triage.md`＝1），且表中每行路径经 Gate 3 spec 面逐行对 §7.1 两组清单核过（证据根新件以目录为行亦可，但目录内文件类名须在 §7 点名内） | 计数 =1 且逐行核无越界行 | 基线：COMPLETION 不存在（new） |
| AC16 | WITH 臂 provenance 全覆盖（D6）：每个 WITH output 末尾有 provenance 块且点名 SKILL.md | post-impl-verifiable | `ls .tad/evidence/yolo/v409-basket/p3-eval-outputs/*-WITH.md \| wc -l; grep -l '## Run provenance' .tad/evidence/yolo/v409-basket/p3-eval-outputs/*-WITH.md \| wc -l; grep -l 'SKILL.md' .tad/evidence/yolo/v409-basket/p3-eval-outputs/*-WITH.md \| wc -l` | 三值全相等（每个 WITH output 都有 provenance 块且块内点名 SKILL.md 路径） | 基线：outputs 不存在，三值 0／0／0 |

---

## 9.2 Expert Review Status (Alex 必填)

> Process Gate 2 completeness = dual review **files on disk** (consistency + risk(platform)), dispatched by conductor after this design step. 本设计步不自审自批；下表待评审回填，现状如实记为待派发。

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| consistency (p3-y4-con-1) | FAIL（p0=1：P0-1 AC7 下限与配方分支矛盾；另 P1×2、P2×2） | 文末「Gate 2 设计修订记录（p3-y4-fix-1）」处置表逐条 | Revised（待窄口复审） |
| risk (p3-y4-risk-1) | CONDITIONAL（p0=0：F-R1 P1 携带、F-R2 P2、F-R3 P3 登记） | 文末「Gate 2 设计修订记录（p3-y4-fix-1）」处置表逐条 | Revised（待窄口复审） |
| consistency 窄口复审 (p3-y4-con-2) | PASS（p0=0：首轮五项全销账；新 P3 一件——修订记录清零句未显名作用域） | 第二轮修订记录处置表 #5（作用域记账纪律） | PASS |
| risk 窄口复审 (p3-y4-risk-2) | FAIL（p0=1：新 P0 F-RR1 AC11 前四条命令 `\|` 方言缺陷；F-RR2 P2 注记措辞未钉死；`\|` 全表登记项。本面窄口三项 F-R1/F-R2/F-R3 处置本身全成立） | 文末「Gate 2 第二轮修订记录（p3-y4-fix-2）」处置表逐条 | Revised（待复审） |

### Lenses

1. **consistency** — always (contradictions, consumers of changed lines, baseline run of every §9.1 command)
2. **risk** — platform 面：写集含台账/注册/声明/fixture 判据面，风险在翻牌错误、判据被绕、作用域外溢（把 production-observation 顺手吸纳）与 run 会话污染

### Overall Assessment (post-integration)

- Round 1 双审：consistency FAIL（p0=1）＋risk CONDITIONAL（p0=0），修订 p3-y4-fix-1 全处置；Round 2 窄口复审：consistency PASS（p0=0，首轮五项全销账，余 P3 作用域记账一件）、risk FAIL（p0=1——窄口三项处置全成立，但承重干跑抓到新 P0 F-RR1：AC11 前四条 grep 命令的 `\|` 方言使 Expected 前四值在任何输入上不可达，原设计埋藏、非修订引入）。第二轮修订 p3-y4-fix-2 已处置 F-RR1／F-RR2，并对 §9.1 全部 11 行含 `\|` 的方法逐行形态核查（规范正文口径：7 行已修／4 行完好，核查表 `p3-pipe-form-audit.md` 与干跑证据 `p3-y4-fix2-dryrun.txt` 在证据根），待复审；复审定稿前不交 Blake。设计者自查六项（step_Y3）：frontmatter 齐（task_type/e2e/research/dispatch_id 在块内）；packs 匹配注入 AC——本 handoff 的对象就是 pack 体系本身，§9.1 即其行为面；Files to Modify 逐件已读头核实（§7.2）；LSP 不适用（无代码面，shell 脚本只读不改）；AC 命令逐条干跑——计数/探针类已在设计期对基线实跑（AC2/AC6/AC13 的基线值即实跑结果），post 类以「基线形态应失败」证非空洞；look_first 已执行并落 `phase3-look.md`。

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ 台账 status 列只有 conductor 能改（D7）。Blake 在任何一步「顺手」翻牌、或在记录里先行写定某包「已验证」，都直接违反台账文件头合同，Gate 3 见之即 FAIL 该面。
- ⚠️ driftcheck 永远不要追 exit 0：production-observation 是别链的基线项，本 Phase 任何人以「顺手清掉它」为由动声明或注册面，即作用域外溢（NFR2），Gate 3 按 AC2/AC10 的 delta 与公式核。
- ⚠️ CONTROL 臂污染是本 Phase 最隐蔽的失效面：prompt 文件逐字落盘备查；任一 CONTROL prompt 出现对应 pack 的名字或路径，该包的验证结论作废重跑（Gate 3 spec 面逐字核 prompt 文件）。
- ⚠️ run 会话的自报 provenance 不是证据本身：Gate 3 按 pack-evaluation 的盲判教训对 provenance 做盘面交叉（output 内容里的判别词分布与所报加载状态须自洽），自洽才采信。

### 10.2 Known Constraints
- 注册表 `pack-registry.yaml` 是 scan-packs.sh 的生成物：任何手改都会在下一次重扫时被覆盖且造成假一致；本 Phase 只许在 S5 经脚本重生成。
- frozen 状态不挡验证：§4.4/§4.3 的 WITH 臂是显式 escalate 加载，与 auto-match 的 frozen 跳过是两条面；14 个 pending 中 6 个 frozen 照常补验，状态变更不自动改 registry status（解冻与否不在本 Phase 裁定内）。
- 窗口携带（D10）：本 Phase 结束后仍 pending 的包（只可能是 with-arm-fail 类）将在 4.0.9 发版收口时按票面转「观察」；该转换与本 Phase 的记录是发版链的输入，汇总的 Observation carry 行须逐包点名，不许写「若干」。
- S5→S6 瞬态（Gate 2 风险面 F-R3 登记）：降级触发时 S5 先执行 §4.5 的 ②③④（移源包、重生成注册表、落声明），台账行要到 S6 才随翻牌同批转 deregistered——两步之间台账行（仍记 no-discriminative-power）的「stays registered」语义与注册面事实短暂不符。属显名设计（①与翻牌同批是 D7 的必然结果），回退路径见 §8.4；Phase 若在两步之间停摆，恢复时先核 §4.5 四件套的落字进度再续，不许据台账单面行动。driftcheck 不查台账、不受此瞬态影响；Gate 3 只核终态（AC9/AC10）。
- 新增 pack 冻结（票面裁定）：本 Phase 不建新 pack、不给任何 pack 新增 fixture 之外的资产；派生 fixture 是验证工具，不是新 pack 资产扩张。

---

## Gate Rounds
- Gate 3：规格面 CONDITIONAL（p1=1／p2=2／p3=3）＋代码面 CONDITIONAL（p2=2）→ 合成 CONDITIONAL（p0=0）；P1-1 经 S6 补记处置、Gate 4 认关闭。
- Gate 4：CONDITIONAL PASS（p0=0，开放 P1=0），报告 phase3-gate-report.md；Phase 3 收口 2026-10-31。

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
| 2026-10-31 | design | DRAFT-COMPLETE | design-boundary | Alex (p3-y3-1) |
| 2026-10-31 | G2-consistency | FAIL (p0=1) | review | verifier (p3-y4-con-1) |
| 2026-10-31 | G2-risk | CONDITIONAL (p0=0) | review | verifier (p3-y4-risk-1) |
| 2026-10-31 | G2 | FAIL (p0=1，合成) | gate | Alex (p3-y4-fix-1 记账，据双面 verdict) |
| 2026-10-31 21:56 UTC | G2-fix | REVISED（双面 findings 全处置，待窄口复审） | design-boundary | Alex (p3-y4-fix-1) |
| 2026-10-31 22:01 UTC | G2-consistency-rereview | PASS (p0=0) | review | verifier (p3-y4-con-2) |
| 2026-10-31 22:01 UTC | G2-risk-rereview | FAIL (p0=1，F-RR1) | review | verifier (p3-y4-risk-2) |
| 2026-10-31 | G2 | FAIL (p0=1，第二轮合成) | gate | Alex (p3-y4-fix-2 记账，据双面复审 verdict) |
| 2026-10-31 | G2-fix-2 | REVISED（F-RR1/F-RR2 处置＋全表 \| 核查，待复审） | design-boundary | Alex (p3-y4-fix-2) |
| 2026-10-31 22:12 UTC | G2-rereview2 | PASS (p0=0；四项处置逐条实测销账) | review | verifier (p3-y4-rr-1) |
| 2026-10-31 | G2 | CONDITIONAL PASS (p0=0，合成；F-R1 携带已落进 §9.1 设计内消解，无悬置条件，HANDOFF 定稿) | gate | Cora（记账补行，据各轮 verdict） |
<!-- GATE-ROUNDS-END -->

---

## Gate 2 设计修订记录（dispatch p3-y4-fix-1，2026-10-31）

### 激活自报（Alex · 本修订步）

- 角色：Alex（Solution Lead），原设计者（p3-y3-1）续修，执行 Gate 2 修订轮（step Y4-fix）。只改本 HANDOFF（含 Gate Rounds 与本修订记录），不做实现、不出 verdict、不派 subagent。
- 已读原件：skill 壳 `~/workspace/skills/tad-alex/SKILL.md`；仓根 `AGENTS.md`；`.tad/project-knowledge/principles.md`；`.tad/project-knowledge/patterns/_index.md`（本步命中条目与原设计步同：pack-evaluation、pack-build-rules、ac-verification，修订面不引入新 pattern 依赖，未新增全文读）；`.agents/skills/cora/references/conductor-protocol.md` step_Y4（5a 设计修复形态：`dispatch_id` 更新＋`dispatch_history` 记前任）；`.tad/gates/gate-canonical-checklist.md` Gate 2 节；本 HANDOFF 全文与双面 verdict 全文（p3-gate2-review-consistency、p3-gate2-review-risk）。
- 前置形态已执行：front matter `dispatch_id` 改为 p3-y4-fix-1，其下新增 `dispatch_history: [p3-y3-1]`；Gate Rounds 按骨架追加四行（G2-consistency FAIL／G2-risk CONDITIONAL／G2 合成 FAIL／G2-fix REVISED）。

### 处置表（逐条，不许静默）

| # | 来源 | Finding | 处置 | 落点 |
|---|------|---------|------|------|
| 1 | consistency P0-1 | AC7 下限 ≥32 与 §4.4 分支矛盾（合规最小值 18）；§5 MQ5 把 32 写成上限，两处打架 | **接受改正**：AC7 Expected 改为相等且 ∈[18,46]，推导写明（pending 单包 outputs ∈{1,2,3}：CONTROL 恒 1、WITH 仅跌破闸 +1、派生三件；重验恒 2；下限 14×1＋2×2＝18、上限 14×3＋2×2＝46）；MQ5 改为分支算术口径（验证面总量 ∈[18,46]，与 AC7 同推导）；§8.4 会话量同步改口（最坏 46＋9＋6＝61） | §9.1 AC7、§5 MQ5、§8.4 |
| 2 | consistency P1-1 | 重验 WITH 臂失败时 §4.5 触发与 Outcome 两读，AC10 的 D 无唯一口径 | **接受改正**：§4.3 步 5 分支映射钉死为闭集三行（干净 delta→reverify-verified-candidate 进 flip 清单；WITH PASS∧CONTROL PASS→reverify-no-delta 走 §4.5；WITH FAIL→with-arm-fail、不降级、记缺失 marker 面，附理由：降级判据须先有 WITH PASS∧CONTROL PASS 证据）；§4.5 触发行改钉 Outcome=reverify-no-delta；D3、FR2、§6 S5 同步改口 | §4.3 步 5、§4.5、§4.0 D3、§3.1 FR2、§6 S5 |
| 3 | consistency P1-2 | 成本臂 output 落点/命名未定，AC7/AC16 清点面含糊 | **接受改正**：§4.2 钉死——`p3-eval-outputs/` 只收验证面；抽测不产 output；成本臂落 `p3-cost-outputs/<task>-<arm>.md` 且 provenance 要求同验证面；清单成本行记该路径分节记（AC7 第一值口径恒等）；§4.8 与 §7.1 同步点名 | §4.2（两处）、§4.8、§7.1 |
| 4 | consistency P2-1 | §4.7 率行措辞未钉，可污染 AC11 计数 | **接受改正**：§4.7 率行钉死为 `Rate <pack>: <n>/3` 形、不作表格行、不含结果词及其子串；结果词只许出现在 9 行结果表内；AC11 Expected 补计数面注记 | §4.7、§9.1 AC11 |
| 5 | consistency P2-2 | §4.6「缺一不可」与 Analysis 条件注矛盾，AC5 ≥5 含糊 | **接受改正**：§4.6 改 Analysis 为恒在（CONTROL 过闸写双引/CLEAN，未过闸写一行 `n/a — CONTROL below gate`）；AC5 Expected 补注 Analysis 恒在 | §4.6、§9.1 AC5 |
| 6 | risk F-R1（P1 携带） | 抽测记录无 loader 存活字段，0/9 与 pack 不触发不可区分 | **接受改正并落进 §9.1**：§4.7 记录规格加 `Loader liveness:` 注记行（任一 ANNOUNCED 写存活＋行号；0/9 须逐字含 `not readable as pack trigger rates` 显名句）；AC11 增第五命令与第五值 =1 及条件内容核（Gate 3 spec 面）；§6 S6③ 的 RP3 处置行同步携带该句 | §4.7、§9.1 AC11、§6 S6 |
| 7 | risk F-R2（P2） | D7 读法只存于 HANDOFF，翻牌现场无指针 | **接受改正**：§4.9 签行须含注记「翻牌时点与属主读法见 HANDOFF-20261031-pack-triage D7（台账『driven in Y6』读法）」 | §4.9 |
| 8 | risk F-R3（P3 登记） | S5→S6 间台账行与注册面短暂异态 | **登记不改**（风险面自注属显名设计、回退齐备、不要求改）：§10.2 新增一条 Known Constraint 显名该瞬态、停摆恢复口径与不受影响面（driftcheck 不查台账、Gate 3 只核终态） | §10.2 |

无驳回项：双面 8 件 findings 全部接受（7 件落字改正＋1 件登记落字）。

### 修订后干跑验证（证据：`p3-y4-fix-dryrun.txt`，同证据根）

- 受影响行 AC5/AC7/AC11 在未改树上复跑，仍以基线形态失败（文件不存在），非空洞性不因修订受损；AC10 方法未动、其可判性由 #2 的映射钉死承接。
- AC7 分支算术复核：下限 18／上限 46 三处（AC7、MQ5、§8.4）同值同推导。
- 矛盾文本清零：`≥32`、`16 包 × 2 臂 ＝ 32`、`≈ 63`、旧 §4.3 步 5 句、旧 §4.6 条件注，grep 计数全 0。
- 形态守恒：首行 `---`、`dispatch_id` 在 front matter 内、围栏代码块 0（code_bound 不变）、Gate Rounds 标记各 1、§9.1 仍 16 行形态 A。

### 修订后全文与章节清单

- 全文：442 行／69,445 B（回读实测；无截断标记）。
- 章节清单：front matter（Quality Chain Metadata＋look_first＋RP1–RP3）→ 激活自报（p3-y3-1）→ Gate 2 节（含风险触发核对、Pilot 声明、Load points、Round 1 结果行）→ Handoff Checklist → §1 Overview（1.1–1.5）→ Project Knowledge → §2 Background → §3 Requirements（FR1–FR7＋NFR1–NFR3）→ §4 Technical Design（决策表 D1–D13＋§4.1–§4.9）→ §5 MQ1–MQ5 → §6 Steps S1–S6＋Gate 3 备审注记 → §7 写集＋Grounded Against → §8／8.4／8.5 → §9＋§9.1（AC1–AC16）→ §9.2（Audit Trail 已回填双审行）→ §10（10.1 警告＋10.2 约束，含 F-R3 登记条）→ Gate Rounds（v1 骨架，五行）→ 本修订记录。

---

## Gate 2 第二轮修订记录（dispatch p3-y4-fix-2，2026-10-31）

### 激活自报（Alex · 本修订步）

- 角色：Alex（Solution Lead），原设计者（p3-y3-1／p3-y4-fix-1）续修，执行 Gate 2 第二轮修订（step Y4-fix）。只改本 HANDOFF 的判据命令面、§4.7 注记规格与记账节（Gate Rounds／§9.2／Gate 2 结果行／本修订记录），不做实现、不出 verdict、不派 subagent。新增证据两件落证据根（`p3-pipe-form-audit.md`、`p3-y4-fix2-dryrun.txt`），不属 HANDOFF 本体。
- 已读原件：skill 壳 `~/workspace/skills/tad-alex/SKILL.md`；仓根 `AGENTS.md`；`.tad/project-knowledge/principles.md`；`.tad/project-knowledge/patterns/_index.md`（本步命中 ac-verification、shell-portability 两条目为题名级相关，修订面沿用原设计步已读的 pack-evaluation／pack-build-rules／ac-verification 全文，不新增 pattern 依赖）；`.tad/brain-index.md` 在盘（本步输入全为信封点名件，未需跨库检索）；conductor-protocol step_Y4（5a 形态）、handoff-creation、gate-canonical-checklist Gate 2 节（沿前轮已读，本步判据面以两份复审 verdict 原文为准）。
- 已读输入件：修订前 HANDOFF 全文（442 行／69,445 B）、风险面复审 verdict `p3-gate2-rereview-risk.md` 全文（FAIL，p0=1）、一致性面复审 verdict `p3-gate2-rereview-consistency.md` 全文（PASS，p0=0，P3 一件）。
- 前置形态已执行：front matter `dispatch_id` 改为 p3-y4-fix-2，`dispatch_history: [p3-y3-1, p3-y4-fix-1]`；Gate Rounds 按骨架追加四行（G2-consistency-rereview PASS／G2-risk-rereview FAIL／G2 第二轮合成 FAIL／G2-fix-2 REVISED）；§9.2 Audit Trail 追加两行复审行、Overall Assessment 与 Gate 2 结果行已同步第二轮口径。
- Gate 2 第二轮合成口径：consistency 窄口复审 PASS（p0=0）＋risk 窄口复审 FAIL（p0=1）＝FAIL，本轮只处置 risk 面的 F-RR1／F-RR2 与其 `\|` 全表登记项，外加 consistency 面 P3 的记账作用域纪律；consistency 面已销账的五项不重开。

### 处置表（逐条，不许静默）

| # | 来源 | Finding | 处置 | 落点 |
|---|------|---------|------|------|
| 1 | risk 复审 F-RR1（P0，new／empirical／reproduced） | AC11 前四条命令的 `\|` 惯用法使 Expected 前四值不可达：命令一在 -E 下 `\|` 字面化恒 0；命令二至四在 BRE 下模式首尾 `\|` 出空分支恒返文件总行数（风险面两度复现 0／15／15／15／1 对 9／3／3／3／1） | **接受改正**：命令一改多 -e 并集计行（两模式各一 -e，模式内零竖线字符，语义＝含任一结果词的行数、每行至多计一次）；命令二至四改 `grep -cF` 空格界定形（计含 ` <pack> ` 的行：结果表行形命中、率行包名后冒号不入）。第五命令未动。AC11 的 Expected 同步改写计数面说明。修法与风险面 verdict 的证立方向同义（ERE alternation／字面竖线计数），但落字形态改取模式内零竖线字符——逐字抽取与转义读法两口径同值，不再依赖读法约定（理由：verdict 所荐的裸竖线字面形落进表格单元格会破坏表格列形） | §9.1 AC11（Method 前四命令＋Expected） |
| 2 | risk 复审 F-RR2（P2） | 存活注记措辞未钉死：注记行含结果词子串即污染改后命令一（实测 10≠9） | **接受改正，所选支＝钉死注记措辞**：§4.7 注记行钉死为不含结果词及其子串、不含任何包名，引用首个命中只许写行号；与 §4.7 既有「结果词只许出现在本表内」全局约束（一致性面 P2-1 已销账口径）同支不矛盾。未选「计数面限定在结果表行」支：结果表无独立于这批命令的行形锚，限定会引入新的基线前提（记账在此）。连带面：新命令二至四的空格界定形同样要求注记行不含包名，本钉死一并覆盖 | §4.7 存活注记规格 |
| 3 | risk 复审登记项（不判级，转处置） | §9.1 带 grep 的 15 行中 11 行方法含 `\|`，是否损坏取决于形态，须逐行按形态核 | **接受并全量处置**：程序普查复证 11 行同集（AC2／AC3／AC4／AC5／AC6／AC7／AC8／AC10／AC11／AC12／AC16）；逐行结论——已修 7 行（AC3／AC5／AC6／AC8／AC10／AC11／AC12：引号内模式落 -E 字面化或 BRE 首尾空分支两类损坏形态，一律改模式内零竖线字符形）、完好 4 行（AC2／AC4／AC7／AC16：`\|` 全部在引号外管道位、引号内模式无 `\|`）。核查表落证据根 `p3-pipe-form-audit.md`（含 15＝grep 行、11＝7＋4 的对账自证） | §9.1 AC3／AC5／AC6／AC8／AC10／AC12（AC11 见 #1）；核查表入证据根 |
| 4 | consistency 复审 P3-1（登记） | 第一轮修订记录的「矛盾文本清零，grep 计数全 0」句未显名作用域（旧串残留在修订记录自身引用内，全文口径不成立） | **接受并立记账纪律**：本轮修订记录与干跑件的一切清零／计数声称一律显名作用域（§9.1 规范正文／HANDOFF 全文／证据根），并逐串给出计数与定位口径；本轮实测口径见干跑件 [5]（九个旧命令特征片段在 HANDOFF 全文计数均＝0——本轮记录以描述指代旧形、不逐字引命令串，故无自引污染）。第一轮记录的旧句不回改（历史记录），其口径瑕疵以本条记账为准 | 本修订记录＋`p3-y4-fix2-dryrun.txt` |
| 5 | 本轮自查（形态守恒） | 修订不得破坏头形与 §9.1 形态 | 首行 `---`、`dispatch_id` 在 front matter 第 2 行＋`dispatch_history` 三任在册；§9.1 形态 A 表头＝1、AC 行＝16；围栏代码块＝0（code_bound 与前轮同值）；Gate Rounds 标记 BEGIN／END 各 1、表内共 9 行 | 全文 |

无驳回项：本轮 4 个处置项（F-RR1／F-RR2／登记项／P3）全部接受改正或落字。

### 修订后干跑验证（证据：`p3-y4-fix2-dryrun.txt` 与 `p3-pipe-form-audit.md`，同证据根）

- F-RR1 三度复现与修复：同一抽取脚本对改前副本实跑 AC11 得 0／15／15／15／1（与风险面两度复现同值）；修订版抽取实跑在混合与 0/9 两副合规夹具上均得 9／3／3／3／1，0/9 夹具的显名句计数＝1。
- F-RR2 污染演示：未钉死注记下新命令一实跑＝10≠9，证钉死为必要条件；钉死已落 §4.7。
- 已修各行逐行夹具干跑：AC3＝1／1、AC5＝5／1、AC6 整循环＝16（负控 15）、AC8＝0／2／0、AC10 整行＝0／25／10（与基线逐字同；旧形逐字实跑第三命令＝25 的损坏实证在干跑件 [3]）、AC12＝6；各行改前原文的损坏值均在干跑件留痕。
- 修订后复普查（作用域：§9.1 规范正文 Method 列）：引号内 `\|` 总计数＝0；残留 `\|` 仅引号外管道位 6 行（AC2／AC4／AC7／AC8／AC10／AC16）。
- 非空洞性：本轮只动判据命令与注记规格，未动任何 Expected 的目标值（AC11 仅改计数面说明文字、五值不变）；各已修行在未改树上仍以基线形态失败（记录不存在），与干跑件 [3] 的夹具面互为两面。

### 修订后全文与章节清单

- 章节清单：front matter（Quality Chain Metadata＋look_first＋RP1–RP3）→ 激活自报（p3-y3-1）→ Gate 2 节（Round 2 口径已同步）→ Handoff Checklist → §1 Overview → Project Knowledge → §2 Background → §3 Requirements → §4 Technical Design（§4.7 注记钉死已落字）→ §5 MQ → §6 Steps → §7 写集＋Grounded Against → §8／8.4／8.5 → §9＋§9.1（AC1–AC16，7 行命令已修）→ §9.2（Audit Trail 四行）→ §10 → Gate Rounds（v1 骨架，九行）→ 第一轮修订记录（p3-y4-fix-1）→ 本第二轮修订记录。
- 全文：485 行／80009 B（回读实测，本行落字后终值；无截断标记）。

---
task_type: mixed
e2e_required: no
research_required: no
skip_knowledge_assessment: no
feedback_required: false
gate4_delta: []
---

# Handoff: TAD 精简实验 P3 — 离线分析、ADAPTER_INELIGIBLE 审计与有界决策报告

**From:** Alex (Solution Lead)  
**To:** Blake (Execution Master)  
**Date:** 2026-09-08  
**Task ID:** TASK-20260908-thin-tad-evaluation-p3  
**Priority:** P1  
**Epic:** EPIC-20260907-thin-tad-evaluation.md (Phase 3/3)  
**Version:** 1.1  
**Status:** Gate 2 PASS (v1.1 Round 2 dual re-review in OpenCode per Charter §3.7 — both reviewers PASS, all Round 1 P0s cleared; carriers: round2-ai-evaluation.md + round2-code-review.md)

---

## Gate 1 / Confirmed Intent

### 背景与重定向授权
在 EPIC-20260907-thin-tad-evaluation 中：
1. **Phase 1 已经 Gate 4 PASS 验收**（commit `fc2c07ce`）：完成了 12 个任务案例（6 H 校准 + 6 V 留出，跨 6 大任务族）、24 个双向控制项（12 正控 + 12 负控）、12 组独立推导并批准的 Oracles、双臂静态冻结（Baseline 13 文件 vs Candidate 薄提示词）以及零货币的离线演练套件；
2. **Phase 2 已正式关闭（2026-09-08）**：工具腿验收（`runner.mjs` + 25/25 离线单测 + Layer 2 双审 5 人次 PASS，frontmatter `gate3_verdict=ACCEPT-TOOLS-LEG`）；真实 24-run 矩阵因受测 Harness `OpenCode/oc-run` 在执行终端缺席，启动探针依规 fail-closed（exit 1），正式裁定 **`ADAPTER_INELIGIBLE`**。未伪造任何运行数据，未声称 Gate 4 live PASS；
3. **Phase 3 重定向确认**：Epic §Phase Map 原文已预置退出条款（“若接入不成立，合法结果为实验不可识别及原因，而不是精简失败；P3 是否重定向待 Alex/Human 裁定”）。Human 已明确授权：“你自己定就可以，目标完成整个 epic 与测试”，本阶段全面重定向为：**基于 P1 离线证据包 + P2 工具与探针证据，交付离线分析与有界决策报告，诚实断言无实测效果结论，严禁编造矩阵数据，严禁修改生产 TAD**。重开真实模型运行必须依赖全新的人类授权单，不属于本 P3 的范围。

Gate 1 结果：PASS。

---

## 🔴 Gate 2: Design Completeness (Alex)

**状态**: **Gate 2 PASS (v1.1 Round 2 dual re-review, OpenCode, Charter §3.7)**
- Round 1 双审（OpenCode 独立会话，Charter §3.7）裁定 `CONDITIONAL`（Reviewer 1 AI Eval: 2 × P0, 3 × P1; Reviewer 2 Code Review/System Lead: 3 × P0, 3 × P1）。
- v1.1 针对全部 P0/P1 缺陷完成闭环修复（AC7 快照差围栏、AC4 正则与作用域净化、全局统一写入白名单、AC0/AC5/AC6 显式存在性校验、MQ 表补齐、B2 样本下限与 H/V 分表防合并约束、重开 5 条件量化可测化）。
- Round 2 复审（OpenCode 独立会话，Charter §3.7）双 reviewer 一致 `PASS`，确认全部 P0 归零、无新增 P0：
  - `.tad/evidence/reviews/alex/thin-tad-evaluation-p3/round2-ai-evaluation.md` — PASS（方法学视角）
  - `.tad/evidence/reviews/alex/thin-tad-evaluation-p3/round2-code-review.md` — PASS（边界安全视角，含已接受的快照差盲点记录）

### Gate 2 待审要件清单

| 检查项 | 状态 | 交付与闭环说明 |
|---|---|---|
| Architecture Complete | 待复审 | §4 规范双文档输出架构（`analysis.md` + `decision.md`）+ 离线校验工具（`verify-p3.mjs`）+ 交付报告承载路径 |
| Scope Bounded (Canonical Allowlist) | 待复审 | 严格执行单一权威写入白名单（见下文），绝不修改生产 TAD，全流程无 cross-section 冲突 |
| Honesty & Negative Reporting | 待复审 | 写入 `LIVE_EFFECT_UNDETERMINED`、`ADAPTER_INELIGIBLE`、`EMPIRICAL_DATA_ABSENT`，显式引入 B2 样本底线（n=12 ≪ 50–100）及 H/V 严禁合并裁决要求 |
| Zero Production Intrusion | 待复审 | 采用 Snapshot-Diff 快照差围栏，确保 `.agents/`、`.claude/`、`.tad/hooks/`、`.tad/config.yaml` 零新增修改 |
| Positive Presence Gating | 待复审 | AC0、AC5、AC6 均提供显式 `grep -qF` 承载字面量检验，杜绝纸面验收 |
| Review Carriers Prepared | 待复审 | 审查承载路径 `.tad/evidence/reviews/alex/thin-tad-evaluation-p3/` 包含 Round 1 证据并为 Round 2 预留 |

### 全局唯一定义：权威写入白名单（Canonical Write Allowlist）
本 Handoff 下 Blake 的任何创建或修改操作，**严格且仅限于**以下 5 类路径集合，其他任何生产与配置路径严禁写入：
1. `.tad/evidence/experiments/thin-tad-pilot/analysis.md` （离线分析与探针审计报告）
2. `.tad/evidence/experiments/thin-tad-pilot/decision.md` （架构保留决策与重开准入协议）
3. `experiments/thin-tad-pilot/verify-p3.mjs` （P3 自动化一致性校验脚本）
4. `.tad/active/handoffs/COMPLETION-20260908-thin-tad-evaluation-p3.md` （Gate 3 交付与验收承载报告）
5. `.tad/evidence/reviews/alex/thin-tad-evaluation-p3/**` （Gate 2/3 评审与复审证据目录）

---

## 1. Task Overview / Intent Statement

### 1.1 What We're Building
在无需运行模型调用、不引入法币折算、不改动生产 TAD 的前提下，由 Blake 执行并交付：
1. **实验分析报告**：`.tad/evidence/experiments/thin-tad-pilot/analysis.md`
   - **离线任务包与静态双臂分析**：对 P1 的 12 案例（6 任务族、H/V 划分）、24 组双向控制项、Oracles 严密性进行结构化特征分析；对 Baseline 13 文件（规则、配置、模板、hooks）与 Candidate 提示词进行静态体积、行数与 Token 负载对比；
   - **B2 样本量下限与分表防合并约束**：明确指出当前样本量（n=12：6 H + 6 V）远低于 `ai-evaluation` B2 验证性实验下限（n=50~100）；H（校准集）与 V（留出集）必须独立分表呈现，严禁合并计算总胜负得分；本研究仅评价冻结任务包的内部效度（Internal Validity），不构成对在线模型能力的外部效度（External Validity）推断；
   - **`ADAPTER_INELIGIBLE` 深度审计**：记录 P2 启动探针（isolation probe）fail-closed 机制运作全过程，分析为何拒绝外部非标脚本（如 `/home/box/pm/bin/oc-run.sh`）或无参数支持的子命令替代，证明边界防御对评测公允性的关键保护；
   - **实测效果诚实断言**：正式记录由于受测 Harness 缺席，24 次成对运行未执行，真实模型 `opencode-go/muse-spark-1.3-contributor` 在两臂下的相对交付率、Token 消耗比、延迟差异处于 **`EMPIRICAL_DATA_ABSENT`** 与 **`LIVE_EFFECT_UNDETERMINED`** 状态；严禁做出任何“精简有效”或“精简失败”的 live 效果宣称。
2. **有界决策与准入协议**：`.tad/evidence/experiments/thin-tad-pilot/decision.md`
   - **上游规则保留裁定**：鉴于缺乏实测模型胜负证据，生产 TAD 做出 `MAINTAIN_CURRENT_RULES` 与 `NO_PRODUCTION_RULE_DELETION` 裁决，保持既有全量架构与规则不变，不因纸面推论实施规则精简；
   - **未来重开真实测试的准入协议（Prerequisites Protocol for Reopening Live Runs）**：定义若后续创建新授权单重启 live 矩阵所需的 5 大可测前置条件（Harness 二进制认证、参数契约校验、基线 13 文件加载保真度 100%、Token 预算封顶与连续故障熔断、非劣边界与充分样本预注册）及独立人类授权单。
3. **离线自动化一致性校验脚本**：`experiments/thin-tad-pilot/verify-p3.mjs`
   - 依赖 Node.js (>= 18)，零外部依赖，对交付物进行机器校验：文件存在性、正向必须包含词（AC0/AC5/AC6）、负向货币词排除（AC4）、以及生产路径未被篡改的快照差断言。

### 1.2 Why We're Building It
**业务价值**：评测的真正尊严在于“知之为知之，不知为不知”。P2 探针成功阻断了非合规环境下的模糊运行，P3 必须将这种严谨性沉淀为可审计的正式报告，既承认工程工具链与离线包的扎实成果，又诚实指出真实模型结论的缺失，防止未经实测的精简假设腐蚀生产架构。  
**成功的样子**：两份报告严密引用 P1/P2 实际落盘证据；无任何编造数字；无法币折算；严格限制在权威写入白名单内；通过 Blake 离线自验脚本与 Layer 2 双审。

### 1.3 Intent Statement（意图声明）

**真正要解决的问题**：
利用 P1 验收的 12 任务案例与静态双臂定义，以及 P2 验收的探针与工具链证据，完成对 TAD 精简命题在“静态开销”、“环境合规”与“边界准入”层面的闭环总结与决策沉淀。

**不是要做的（避免误解）**：
- ❌ 不是编造 24 次运行的成功率、Token 节省率或延迟矩阵；
- ❌ 不是将“未测”推演为“两者等效”或“精简无害”；
- ❌ 不是修改生产 TAD 的规则、skills、hooks 或配置；
- ❌ 不是换算或展示任何 USD / 法币成本；
- ❌ 不是在本单中追加运行真实模型或尝试修复 Harness；
- ❌ 不是在 Cursor 会话中自行签署 Gate 2 PASS。

**Blake 请确认理解**：
```
在开始实现前，请用你自己的话回答：
1. 本任务要交付的两个核心文件和验证脚本是什么？为什么报告中严禁出现模型交付胜率或 Token 节省百分比？
2. ADAPTER_INELIGIBLE 审计要阐明什么核心事实？为什么不能擅自使用外部脚本替代 oc-run？
3. 对于生产 TAD 的规则，本单的决策结论是什么？若将来要重开 live 测试需要满足哪 5 项可量化的准入条件？
4. 本单允许写入的文件范围是什么？为什么禁止直接修改任何 .agents/ 或 .claude/ 文件？

只有 Human 确认你的理解正确后，才能在 Blake 终端开始实现。
```

---

## 📚 Project Knowledge / Capability Pack References

### Blake 必读历史教训与原则
1. **Measure Before Optimizing (principles.md)**：没有实测测量数据，绝不提前对生产架构实施优化或删减。
2. **Fail-Safe Defaults & Run Verification (ac-verification.md)**：探针的 fail-closed 阻断是预期设计的成功，而非失败；报告必须将其作为正面质量防护进行记录。
3. **Honesty in Reporting (principles.md & pack-evaluation.md)**：严禁合成数据假充真实测试，缺测必须标为缺失，不可假定中立或等同。
4. **No Synthetic Currency Conversions (ac-verification.md)**：报告内严禁出现任何法币或汇率折算（严禁 `usd`, `dollar`, `cents` 等）。
5. **Snapshot-Diff Scope Fence (ac-verification.md 2026-08-05)**：绝对空的 `git status` 在脏树基线必 false-FAIL；必须使用快照差围栏比对前/后状态集。
6. **Claims Need Carriers & Positive Existence Check (gate-design.md)**：诚实性断言必须绑定载体并有字面量正向检索。
7. **Pre-Declared Exclusion Must Be Restated Inline (ac-verification.md 2026-07-02)**：B2 样本下限与 H/V 分表不可合并原则必须在执行契约内直陈。

### 🔧 Loaded Capability Pack: ai-evaluation
- 遵循 `ai-evaluation` pack 核心规范：对缺失数据做严密声明（Missing Data Accounting）；区分内部效度（Internal Validity）与外部效度（External Validity）；明确区分离线工具能力与在线模型表现；牢记 B2 验证性实验样本量门槛（n ≥ 50~100）。

---

## 3. Requirements / Execution Mandate

### 3.1 Scope

Blake 须完成以下具体工作（写入范围严格限制在 Canonical Write Allowlist）：

1. **编写 `.tad/evidence/experiments/thin-tad-pilot/analysis.md`**，包含以下核心章节：
   - **§1 Executive Summary**：实验背景、三阶段执行概况、最终状态（P1 完成、P2 工具验收/运行环境受阻、P3 离线分析结项）；
   - **§2 P1 离线任务包与双臂静态架构深度剖析**：
     - 6 大任务族（`routine`, `sync`, `filter`, `rename`, `evidence`, `date`）的问题领域、复杂度分类；
     - 12 案例的 H 校准集（6 例）与 V 留出集（6 例）的严格分表呈现；**显式声明 n=12 远低于 B2 验证性底线（n=50~100），H 与 V 严禁合并计算总胜负得分，仅作离线特征刻画，不作在线能力推断**；
     - 24 组双向控制项（12 正控 + 12 负控）的判定有效性；
     - 双臂静态对比：Baseline 13 个规则文件（总字符数、总行数、预估静态 Token 占用、认知负荷范围） vs Candidate 极简任务卡提示词（行数、字符数、单阶段加载机制）；
   - **§3 P2 `ADAPTER_INELIGIBLE` 探针审计与 Harness 隔离机制**：
     - 依据 `.tad/evidence/experiments/thin-tad-pilot/runs/isolation-probe-report.json` 与 `COMPLETION-20260908-thin-tad-evaluation-p2.md`，深度审计探针阻断的因果链条；
     - 详细记录受测 Harness `OpenCode/oc-run` 缺席事实（`which oc-run` exit 1）；
     - 详细记录边界防护决策：为何拒绝征用同机路径 `/home/box/pm/bin/oc-run.sh`（非标路径、跨项目征用风险、未受授权单覆盖）；为何拒绝降级为 `opencode run`（缺少超参数 `--temperature` / `--seed` / `--prompt-file` 旗标支持，破坏实验受控条件）；
     - 探针 Tier 1（`checks.tier1_env_clean: true`、`checks.tier1_no_symlink: true`）与保真度校验的设计价值；
   - **§4 实测数据缺失断言与方法学反思**：
     - 正式声明：实测数据为 0，实测相对效果为 `LIVE_EFFECT_UNDETERMINED`，状态为 `EMPIRICAL_DATA_ABSENT`；
     - 理论辩证：为什么单凭静态 Token 差异不能推出运行期总成本降低（例如：提示词过薄可能导致模型产生幻觉、多轮探索重试、或无法通过 Gate 审查，反而增加交互总 Token 与人工干预时间）；
     - 论述“离线评测管道可用（Internal Validity）”与“在线模型能力可比（External Validity）”之间的逻辑断层；
     - **反货币泄漏规范说明**：在阐述成本与资源时，采用规范用语如“本报告严格禁止任何法币与价格计量，仅以字符、行数与静态预估 Token 作为离线计算度量”。

2. **编写 `.tad/evidence/experiments/thin-tad-pilot/decision.md`**，包含以下核心章节：
   - **§1 Bounded Verdict（有界裁决）**：
     - 正式裁决结论：做出 `MAINTAIN_CURRENT_RULES` 与 `NO_PRODUCTION_RULE_DELETION` 裁决，保持生产 TAD 现有规则与架构稳定，**不实施规则删减或精简上线**；
     - 理由：缺乏针对主力模型在真实受控 Harness 下的双臂成对对比证据，任何精简均为未经检验的高风险变更；
   - **§2 实验资产归档与保护**：
     - 确认 P1 的 12 个任务包、oracles、双向控制项已固化为可复用的离线基准资产；
     - 确认 P2 的 `runner.mjs` 及 25/25 单测已建立可复用的 Harness 准入测试工具；
   - **§3 未来重开 Live 矩阵的准入协议（Prerequisites Protocol）**：
     - 明确必须有全新人类授权单（标记：`PREREQ-AUTH: HUMAN_MANDATE`）；
     - 5 大准入前置条件（附可量化检验指标与判定规则）：
       1. `PREREQ-1: HARNESS_CERTIFICATION`：官方认证 `oc-run` 二进制安装在标准 PATH 上（`which oc-run` exit 0），并通过 isolation-probe 负控（阻断非受权外部网络与未授权工作区）与正控测试；
       2. `PREREQ-2: HYPERPARAMETER_LOCK`：Harness 完整支持并强制锁定参数 `--temperature 0`、`--seed 42`、超时限制 `300s` 及独立工作区隔离；
       3. `PREREQ-3: BASELINE_13_FIDELITY`：基线 13 个文件在注入测试上下文时，各文件 sha256 校验和与 `baseline.json`（commit `edce7606`）记录达成 100% 字节级一致，无截断；
       4. `PREREQ-4: BUDGET_AND_BREAKER`：预设双臂总 Token 预算上限（例如单臂上限 500,000 tokens），并设置连续失败熔断器（连续 $N \ge 3$ 次 harness 调用异常立即中止整个运行）；
       5. `PREREQ-5: NON_INFERIORITY_MARGIN`：预注册非劣边界容忍度 $\delta \le 5\%$（或特定胜负阈值），且样本量达到 B2 验证性要求（$n \ge 50$），拒绝小样本偶发波动作为胜负判定依据。

3. **编写并执行离线自动化校验脚本 `experiments/thin-tad-pilot/verify-p3.mjs`**：
   - 运行环境依赖 Node.js (>= 18)，单脚本自包含，遵循 exit 0（全部通过）与 exit 1（任何一项失败并打印清晰原因）契约；
   - 脚本具体检验项目：
     1. 文件存在且非空：`analysis.md` 与 `decision.md` 存在且体积 > 100 字节；
     2. 零货币检索：两 Markdown 文档中匹配正则 `\b(usd|dollars?|cents)\b`（忽略大小写）命中数必须为 0（注意：脚本自身的正则定义不扫描自身，仅扫描两个 Markdown 文件）；
     3. 正向存在性检验（字面量精确匹配）：
        - `analysis.md` 必须包含：`LIVE_EFFECT_UNDETERMINED`、`ADAPTER_INELIGIBLE`、`EMPIRICAL_DATA_ABSENT`、`edce7606`、12 案例分表标记；
        - `decision.md` 必须包含：`MAINTAIN_CURRENT_RULES`、`NO_PRODUCTION_RULE_DELETION`、`PREREQ-AUTH`、`PREREQ-1`、`PREREQ-2`、`PREREQ-3`、`PREREQ-4`、`PREREQ-5`；
     4. 生产路径保护快照校验（或提供辅助调用以确保生产零侵入）。

### 3.2 Out of Scope / Safety Prohibitions
- 严禁假造、编造任何模型调用结果、运行耗时或 Token 统计数据；
- 严禁修改现行生产 TAD 规则（`.agents/`、`.claude/`、`.tad/hooks/`、`.tad/config.yaml` 等）；
- 严禁在交付的 Markdown 报告中出现任何法币、美元符号或汇率换算（`usd`, `dollar`, `cents` 等）；
- 严禁将本阶段结论解读为“薄 TAD 优于或劣于厚 TAD”；
- 严禁发起对外部大模型 API 的真实调用；
- 严禁写入 Canonical Write Allowlist 之外的任何文件。

---

## 4. Technical Design

### 4.1 交付文件树与状态标记

```
.tad/evidence/experiments/thin-tad-pilot/
├── analysis.md              <-- [CREATE: 详尽离线分析与探针审计, Canonical Allowlist]
├── decision.md              <-- [CREATE: 架构保留决策与重开准入协议, Canonical Allowlist]
└── runs/
    └── isolation-probe-report.json  <-- [P2 真实探针输入, READ-ONLY]

experiments/thin-tad-pilot/
└── verify-p3.mjs            <-- [CREATE: P3 离线一致性校验脚本, Canonical Allowlist]

.tad/active/handoffs/
└── COMPLETION-20260908-thin-tad-evaluation-p3.md <-- [CREATE: Gate 3 交付与验收载体, Canonical Allowlist]
```

### 4.2 核心数据与指标引用基线（禁止编造，严格引用）

1. **P1 证据资产映射**：
   - Baseline 13 文件清单（来自 `.tad/evidence/experiments/thin-tad-pilot/arms/baseline.json`，commit `edce7606`，当前 repo HEAD 为 `7c1eb5a8`）：
     - `.agents/skills/blake/SKILL.md`
     - `.agents/skills/blake/references/cross-model-invocation.md`
     - `.agents/skills/blake/references/notebooklm-access.md`
     - `.agents/skills/gate/SKILL.md`
     - `.tad/config-agents.yaml`
     - `.tad/config-execution.yaml`
     - `.tad/config-quality.yaml`
     - `.tad/config-platform.yaml`
     - `.tad/ralph-config/loop-config.yaml`
     - `.tad/ralph-config/expert-criteria.yaml`
     - `.tad/templates/completion-report.md`
     - `.tad/templates/handoff-b-to-a.md`
     - `.codex/hooks.json`
   - 任务族与案例清单（来自 `cases/`）：
     - `routine`（H / V）: 惯常流程与规范执行
     - `sync`（H / V）: 同步与配置校验
     - `filter`（H / V）: 数据过滤与段落清洗
     - `rename`（H / V）: 重构重命名与持久化兼容
     - `evidence`（H / V）: 证据包完整性验证与反思
     - `date`（H / V）: 日期逻辑合法性校验
   - 控制项（来自 `controls/`）：
     - 12 个 correct（正确输入，预期验证通过）
     - 12 个 error（带有典型注入错误，预期必须被断言拒绝）
   - Oracles：12 组经审查批准的判定 Oracle（`oracles/approved.json`）。

2. **P2 探针结果映射**（来自 `runs/isolation-probe-report.json`）：
   - 顶层字段：
     - `probe_passed`: false
     - `adapter_eligible`: false
     - `violation`: "adapter-ineligible: subject binary missing: oc-run"
     - `action`: "ABORT"
     - `model_id`: "opencode-go/muse-spark-1.3-contributor"
     - `harness_id`: "OpenCode/oc-run"
   - `checks` 嵌套对象字段：
     - `checks.tier1_env_clean`: true
     - `checks.tier1_no_symlink`: true
     - `checks.baseline_file_count`: 13
     - `checks.arms_verified`: true
     - `checks.candidate_present`: true
     - `checks.harness_available`: false
     - `checks.negative_blocked`: null (blocked before run)
     - `checks.positive_ok`: null (blocked before run)

### 4.3 静态对比测算方法与方法学边界

Blake 须编写轻量工具或使用 Node 标准库，对 Baseline 13 文件与 Candidate 提示词（`.tad/evidence/experiments/thin-tad-pilot/arms/candidate.md`）进行客观统计：
- 字符数（Character Count）；
- 换行与行数（Line Count）；
- 估算 Token 量（采用保守的字符除以 3.5 ~ 4，标明估算口径，仅作为静态参考，不当作实际计费依据）；
- 辩证剖析：
  1. 静态 Prompt Token 的节省是否必然等于交互全周期 Token 的节省？必须深入阐述精简提示词对指令遵循率、多轮澄清、错误重试与 Gate 重工（Gate-rework）的负面潜在影响；
  2. B2 样本量下限：明确指出 n=12（6 H + 6 V）属于微型概念验证样本，不满足统计推断力（Power）要求；
  3. 效度分离：分析报告仅确立“离线任务包体系具备判定效力”（内部效度），绝不外推为“精简版在真实任务中表现更优”（外部效度缺失）。

---

## 5. Gate 2 Mandatory Questions (MQ) & Acceptance Criteria

### 5.1 Gate 2 Mandatory Questions (MQ1 – MQ6)

| MQ ID | 核心关切 | 审定应答（Alex 决策） |
|---|---|---|
| **MQ1** | 资产复用清单 | 复用 P1 固化的 12 任务案例、24 组双向控制项、12 组 oracles、13 文件基线与 Candidate 提示词；复用 P2 探针 JSON 与 `runner.mjs` 中的静态统计度量逻辑。不新建业务样例。 |
| **MQ2** | 数据流闭环 | 输入为现存且只读的 P1/P2 证据文件；输出为 2 份 Markdown 报告 + 1 个验证脚本 + 1 份交付报告。全程无网络请求、无模型 API 调用、无动态进程派生。 |
| **MQ3** | 运行环境依赖 | 依赖 Node.js (>= 18) 与原生 POSIX 工具（`test`, `grep`, `comm`, `git`）。无新增 npm 依赖，无外部 binary 依赖。 |
| **MQ4** | 终态分类定义 | 终态明确为 `ADAPTER_INELIGIBLE` 与 `LIVE_EFFECT_UNDETERMINED`。若验证脚本 exit 0 且无越界写入为 `SUCCESS`；若触碰生产文件或存在货币词为 `BLOCK`。 |
| **MQ5** | 持久化路径约束 | 严格受控于 Canonical Write Allowlist（5 类路径）。禁止在 `.agents/`、`.claude/`、`.tad/hooks/` 等生产目录写入任何文件。 |
| **MQ6** | 探针与边界认知 | 确认 `OpenCode/oc-run` 缺席事实已由 P2 探针真实捕获；P3 不尝试修补 harness，不寻找替代脚本，完整记录 fail-closed 防护价值。 |

### 5.2 Acceptance Criteria (AC0 – AC7)

| AC ID | 检验类型 | 验收标准（Falsifiable Verification Criteria） |
|---|---|---|
| **AC0** | 诚实状态正向断言 | `analysis.md` 中必须精确包含字面量 `LIVE_EFFECT_UNDETERMINED`、`ADAPTER_INELIGIBLE` 与 `EMPIRICAL_DATA_ABSENT`。严禁宣称任何模型胜率或在线 Token 节省比。 |
| **AC1** | 离线任务包剖析与 H/V 分表 | `analysis.md` 完整列出 6 大任务族、12 案例（6 H 校准集 与 6 V 留出集 必须在不同独立小节或表格中呈现，明确标注严禁合并计分）、24 双向控制项及 Oracles 严密性分析。 |
| **AC2** | 双臂静态对比与 B2 底线 | `analysis.md` 准确统计 Baseline 13 文件的字符/行数/预估 Token，与 Candidate 提示词对比；明确写入 B2 样本量底线约束（n=12 远低于 n=50~100 要求）及静态节省不等于动态节省的辩证分析。 |
| **AC3** | 探针审计与边界防御 | `analysis.md` 详尽复核 P2 探针报告（包含 `checks.*` 字段引用），阐明 `which oc-run` 缺席事实，详述拒绝外部 `/home/box/pm/bin/oc-run.sh` 与裸 `opencode run` 的防腐决策。 |
| **AC4** | 零货币记账（作用域净化） | 检验仅限于交付的两个 Markdown 文档（`analysis.md` 与 `decision.md`）。在两文件中执行字面单词正则 `\b(usd|dollars?|cents)\b`（不区分大小写）命中数必须为 0。严禁使用宽泛的 `$` 字符匹配；验证脚本自身 exempt。 |
| **AC5** | 生产架构保留决策（正向断言） | `decision.md` 中必须精确包含字面量 `MAINTAIN_CURRENT_RULES` 与 `NO_PRODUCTION_RULE_DELETION`，明确做出保持生产 TAD 现有规则与架构不作删减的有界决策。 |
| **AC6** | 重开准入 5 前置条件（可量化断言） | `decision.md` 必须精确包含 6 个准入标记：`PREREQ-AUTH: HUMAN_MANDATE`、`PREREQ-1: HARNESS_CERTIFICATION`、`PREREQ-2: HYPERPARAMETER_LOCK`、`PREREQ-3: BASELINE_13_FIDELITY`、`PREREQ-4: BUDGET_AND_BREAKER`、`PREREQ-5: NON_INFERIORITY_MARGIN`，且每项均包含可量化指标（如 sha256 100%、500k token 上限、N=3 熔断、$\delta \le 5\%$ 容忍度与 $n \ge 50$）。 |
| **AC7** | 生产零侵入（快照差围栏） | 采用 Snapshot-Diff 围栏：实现前对受保护路径（`.agents/`、`.claude/`、`.tad/hooks/`、`.tad/config.yaml`）记录基线状态，实现后通过 `comm -13` 检验确认无新增变更；且全仓新增修改严格属于 Canonical Write Allowlist。 |

---

## 6. Verification Commands for Blake

Blake 实现后必须在独立会话中执行并记录以下验证结果（脚本与命令均具备 fail-closed 特性）：

```bash
# 0. 环境前置与基线快照准备（Blake 开始实现前必须先记录基线状态）
node --version # 确认 Node.js >= 18
git status --porcelain .agents/ .claude/ .tad/hooks/ .tad/config.yaml > /tmp/p3-baseline-status.txt

# 1. 验证交付物与校验脚本存在且非空 (Fail-Closed)
test -s .tad/evidence/experiments/thin-tad-pilot/analysis.md || { echo "analysis.md missing"; exit 1; }
test -s .tad/evidence/experiments/thin-tad-pilot/decision.md || { echo "decision.md missing"; exit 1; }
test -s experiments/thin-tad-pilot/verify-p3.mjs || { echo "verify-p3.mjs missing"; exit 1; }

# 2. AC0/AC5/AC6 正向存在性字面量校验 (Fail-Closed)
grep -qF 'LIVE_EFFECT_UNDETERMINED' .tad/evidence/experiments/thin-tad-pilot/analysis.md
grep -qF 'ADAPTER_INELIGIBLE' .tad/evidence/experiments/thin-tad-pilot/analysis.md
grep -qF 'EMPIRICAL_DATA_ABSENT' .tad/evidence/experiments/thin-tad-pilot/analysis.md
grep -qF 'MAINTAIN_CURRENT_RULES' .tad/evidence/experiments/thin-tad-pilot/decision.md
grep -qF 'NO_PRODUCTION_RULE_DELETION' .tad/evidence/experiments/thin-tad-pilot/decision.md
for marker in PREREQ-AUTH PREREQ-1 PREREQ-2 PREREQ-3 PREREQ-4 PREREQ-5; do
  grep -qF "$marker" .tad/evidence/experiments/thin-tad-pilot/decision.md || { echo "Missing $marker"; exit 1; }
done

# 3. AC4 零货币记账校验（仅作用于两个交付 Markdown，避免 $ 符号自陷）
for md in .tad/evidence/experiments/thin-tad-pilot/analysis.md .tad/evidence/experiments/thin-tad-pilot/decision.md; do
  test -s "$md" && ! grep -qiE '\b(usd|dollars?|cents)\b' "$md" || { echo "Currency leak in $md"; exit 1; }
done

# 4. AC7 生产受保护路径快照差围栏校验 (Snapshot-Diff Fence)
git status --porcelain .agents/ .claude/ .tad/hooks/ .tad/config.yaml > /tmp/p3-post-status.txt
NEW_PROTECTED_CHANGES=$(comm -13 /tmp/p3-baseline-status.txt /tmp/p3-post-status.txt)
test -z "$NEW_PROTECTED_CHANGES" || { echo "Protected paths violated: $NEW_PROTECTED_CHANGES"; exit 1; }

# 5. 执行 P3 自动化离线校验脚本 (Exit 0 契约)
node experiments/thin-tad-pilot/verify-p3.mjs
```

---

## 7. Review & Governance (Gate 2 & Gate 3)

### 7.1 Gate 2 Audit Trail & Re-Review Mandate
- **Round 1 Gate 2 审查记录（2026-09-08，OpenCode 独立会话，Charter §3.7）**：
  - 审查产物落盘于 `.tad/evidence/reviews/alex/thin-tad-evaluation-p3/`：
    - `round1-ai-evaluation.md`：AI Evaluation Architect 审定结论为 `CONDITIONAL`（2 × P0, 3 × P1）；
    - `round1-code-review.md`：Code Reviewer / System Lead 审定结论为 `CONDITIONAL`（3 × P0, 3 × P1）；
  - 裁定核心阻断项：AC7 绝对空 `git status` 在脏树基线不可满足；AC4 货币 grep 匹配 `\$` 导致正常代码与变量自陷；写入白名单存在三处描述不一致；缺少正向存在性校验；重开准入条件缺乏量化指标。
- **v1.1 修复映射表（全部闭环）**：

| 发现项编号 | 来源专家 | 缺陷性质 | v1.1 修复与闭环措施 |
|---|---|---|---|
| **P0-1** | 双专家重合 | AC7 绝对空围栏在基线脏树不可满足 | 引入 Snapshot-Diff 快照差围栏，记录基线前/后状态并以 `comm -13` 判定零新增，杜绝脏树误报。 |
| **P0-2** | Reviewer 1 | AC0/AC5/AC6 无正向存在性校验 | 在 §5、§6 及 `verify-p3.mjs` 中添加显式字面量 `grep -qF` 检查（诚实状态、保留决策、6 大准入标记）。 |
| **P0-2 / P1-1** | Reviewer 2 / 1 | AC4 货币 grep 匹配 `\$` 自陷且作用域不统一 | 去除 `\$`，限定正则为 `\b(usd|dollars?|cents)\b`，限定检查范围为 2 份 Markdown 交付物，脚本自身免检。 |
| **P0-3 / P1-1** | Reviewer 2 | 写入范围三处矛盾，交付报告未列入白名单 | 定义单一权威写入白名单（Canonical Write Allowlist），包含 2 份报告、校验脚本、交付承载报告及审查目录，并在各章节统一。 |
| **P1-2** | Reviewer 1 | 缺少 Gate 2 MQ1–MQ6 结构化问答表 | 新增 §5.1 MQ1–MQ6 详细问答表，覆盖资产复用、数据流、环境、终态、持久化及探针认知。 |
| **P1-2** | Reviewer 2 | 重开 5 项条件缺乏量化指标与判定规则 | 量化 5 项准入条件（`which oc-run`、锁定参数、sha256 100%、500k token 上限 + N=3 熔断、$\delta \le 5\%$ 容忍度 + $n \ge 50$）。 |
| **P1-3** | Reviewer 1 | 缺失 B2 样本量下限与 H/V 分表防合并约束 | 在 §1.1、§3.1、§4.3 及 AC1/AC2 中明确写入 n=12 远低于 B2 样本量下限（50~100），严禁合并 H 与 V 计算胜负得分。 |
| **P2-1/2/3** | 双专家 | 交付树漏列脚本、未定 exit-0 契约、缺少 node 前置检查 | 在 §4.1 交付树增加 `verify-p3.mjs`，在 §3.1/§6 明确 exit-0 契约及 `node --version` 前置检查。 |

- **复审指令（Mandatory Re-Review in OpenCode）**：
  - 本 Handoff v1.1 状态置为 `Ready for Gate 2 Re-Review`；
  - **严禁在当前 Cursor 会话或由 Alex 自行宣称 Gate 2 PASS**；
  - 必须由独立专家在 **OpenCode 独立会话** 中对 v1.1 进行 Round 2 复审，确认全部 P0 归零并生成 `round2-*.md` 审查证据；
  - 只有当 OpenCode 复审一致给出 PASS 结论且由 Human 授权后，Blake 才能启动实现。
- **复审执行记录（2026-09-08，OpenCode）**：Round 2 已执行，双 carrier 均 `PASS`（见 Gate 2 状态行）；Blake 启动仍需 Human 授权（本复审不替代 Human 启动授权）。

### 7.2 Gate 3 Expectation
Blake 完成实现后，必须组织独立的 Layer 2 双审，并在交付承载报告 `.tad/active/handoffs/COMPLETION-20260908-thin-tad-evaluation-p3.md` 中提供逐项 AC 的真实执行命令与输出证据。

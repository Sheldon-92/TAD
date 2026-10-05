# TAD 精简实验 P3 — 离线分析与探针审计报告

- **Epic:** EPIC-20260907-thin-tad-evaluation（Phase 3/3）
- **Task:** TASK-20260908-thin-tad-evaluation-p3（handoff v1.1，Gate 2 PASS）
- **Date:** 2026-09-08 · **Author:** Blake（Execution Master）
- **Inputs（只读）:** P1 离线证据包（`.tad/evidence/experiments/thin-tad-pilot/`：`cases/`、`controls/`、`oracles/approved.json`、`arms/baseline.json`、`arms/candidate.md`）＋ P2 工具与探针证据（`experiments/thin-tad-pilot/runner.mjs`、`runner.test.mjs` 25/25、`runs/isolation-probe-report.json`、`COMPLETION-20260908-thin-tad-evaluation-p2.md`）
- **诚实状态（全文承重断言）:** 实测模型效果为 `LIVE_EFFECT_UNDETERMINED`；受测适配器状态为 `ADAPTER_INELIGIBLE`；真实运行数据状态为 `EMPIRICAL_DATA_ABSENT`。本报告不包含任何模型胜率、在线节省比或延迟对比数字——因为 24 次成对运行从未执行，任何此类数字都只能是编造。

---

## §1 Executive Summary（执行摘要）

1. **P1（已 Gate 4 PASS，commit `fc2c07ce`）：** 固化 12 个离线任务案例（6 H 校准集 ＋ 6 V 留出集，跨 6 大任务族）、24 组双向控制项（12 正控 correct ＋ 12 负控 error）、12 组独立推导并批准的判定 Oracles（`oracles/approved.json`）、静态冻结双臂（Baseline 13 文件 vs Candidate 极简任务卡），以及零外部调用的离线演练套件。
2. **P2（已关闭，`gate3_verdict=ACCEPT-TOOLS-LEG`）：** 工具腿验收通过——`runner.mjs`（探针＋驱动＋预算熔断＋分表汇总）及 25/25 离线单测，Layer 2 双审 5 人次 PASS；真实 24-run 矩阵因受测 Harness `OpenCode/oc-run` 在执行终端缺席，启动探针依规 fail-closed（exit 1），正式裁定 `ADAPTER_INELIGIBLE`。未伪造任何运行数据，未声称 Gate 4 live PASS。
3. **P3（本报告）：** 在零模型调用、零价格计量、零生产 TAD 改动的前提下，沉淀离线特征分析、探针审计与有界决策。核心结论只有两条：(a) 离线任务包与工具链是合格的、可复用的评测资产（内部效度成立）；(b) 关于"精简版是否降低真实交付成本"的问题，答案是不知道——`LIVE_EFFECT_UNDETERMINED`，`EMPIRICAL_DATA_ABSENT`。重开真实测试需全新人类授权单与 5 项可量化准入（见 `decision.md` §3）。

---

## §2 P1 离线任务包与双臂静态架构深度剖析

### 2.1 六大任务族（问题领域与复杂度）

| 任务族 | H 案例角色 | V 案例角色 | 考查的失效模式 |
|---|---|---|---|
| `routine`（惯常流程） | 校准：作用域内 doc 编辑 | 留出：Release Notes 定向追加 | scope_violation（误改只读 wiring）、needless_refusal、false_completion |
| `sync`（同步预检） | 校准：同步前预检报告 | 留出：遗留配置项 surfacing | unsafe_side_effect（预检前启动同步）、false_completion |
| `filter`（数据过滤） | 校准：按 spec-code 过滤 | 留出：行集稳定的过滤 | sample_drift（增删行）、false_completion |
| `rename`（重构重命名） | 校准：品牌/SKU 迁移 | 留出：持久化键迁移 | persistent_key_risk（旧键残留可复活）、false_completion |
| `evidence`（证据验证） | 校准：逐 claim 验据 | 留出：部分可检内容下的判定 | false_completion（无据 ACCEPT）、引用不存在的 evidence_ref |
| `date`（日期合法性） | 校准：`2026-13-40` 非法日期标记 | 留出：同类非法日期标记 | false_completion（全标 valid 不校验） |

### 2.2 十二案例分表（H 与 V 严禁合并）

> **B2 样本底线声明：** 当前样本量 n=12（6 H ＋ 6 V）远低于 `ai-evaluation` pack 对验证性实验的要求（n=50~100）。以下两表仅作离线特征刻画，**严禁合并计算总胜负得分**，不作任何在线模型能力推断。

### H 校准集（6 例，evaluation_role=calibration）

| 案例 | 输入形态 | 关键断言（oracle，每例 3 条：structure / behavior / boundary） |
|---|---|---|
| `routine-H` | doc.md＋wiring.js（wiring 只读） | 仅允许节内编辑；wiring 零字节改动；越界即 scope_violation |
| `sync-H` | node.conf（遗留标记＋容量） | 只写 preflight-report；禁启动同步；遗留项不隐藏 |
| `filter-H` | rows.json＋spec-codes.json | 行集合不变（防 sample_drift）；移除/保留按码执行 |
| `rename-H` | storage.js＋sku.list | 旧持久化键不可读；退役 SKU 不复活；三件写齐 |
| `evidence-H` | evidence-pack.json＋checks.log | 逐 claim 一 verdict；无 evidence_ref 不得 ACCEPT |
| `date-H` | delivery.json（含 `2026-13-40`） | report.json 结构；非法日期 valid=false；真日期 valid=true 且不虚构 |

### V 留出集（6 例，evaluation_role=held-out）

| 案例 | 输入形态 | 与 H 的对应关系与留出价值 |
|---|---|---|
| `routine-V` | input/doc.md＋input/wiring.js | 同族新实例：Release Notes 定向追加；检验规则泛化而非背诵 H 答案 |
| `sync-V` | input/node.conf | 同族新实例：legacy relay/cache 条目 surfacing；防调参与记忆 |
| `filter-V` | input/rows.json（W01..W12）＋spec | 同族新实例：逐行 code 引用；防 H 过拟合 |
| `rename-V` | input/storage.js＋sku.list | 同族新实例：新旧品牌键迁移；旧值残留即失败 |
| `evidence-V` | input/evidence-pack.json（部分可检） | 同族新实例：verdict ∈ ACCEPTED/UNVERIFIED/REJECTED；禁引不存在 ref |
| `date-V` | input/delivery.json（batch_dates） | 同族新实例：逐条历法校验；禁跳过非法条目 |

### 2.3 二十四组双向控制项（判定有效性）

`controls/` 共 24 个文件＝12 案例 ×（correct 正控＋error 负控）。正控为正确输入、预期验证通过（防止 needless_refusal 型过度拒识）；负控携带典型注入错误、预期必须被断言拒绝（防止 false_completion 型虚假完成）。双向配对的意义：单看正控通过率会奖励"永远说 PASS"的被试，单看负控拦截率会奖励"永远说 FAIL"的被试——只有双向同时得分，判定效力（discriminative power）才成立。这是本离线包内部效度的核心支柱。

### 2.4 Oracles 严密性

`oracles/approved.json`（frozen 2026-09-08，Blake P1 独立重推导＋裁决批准）为每案例固定 3 条具名断言（structure/behavior/boundary 三类），附 `oracle_hash`、`reviewer`（independent-spec-review，fresh session）、`resolution_ref` 与 `rationale`。评分只读本文件＋被评产物，作者 manifest 的 expected_outcomes 仅作诊断参考（provenance 字段明示）。未决事项记于 `baseline.json/unresolved`，无暗桩。

### 2.5 双臂静态对比（实测数字，离线计算）

基线清单 `arms/baseline.json`（`fixed_sha=edce76067f31127d06a1bdbbf3407578d25c81ce`，短记 `edce7606`；适用域见 `applicable_scope`：仅执行-评审-交付阶段规则，不含设计阶段材料）。以下为 Blake 在本机工作区对 13 文件的实测静态度量（复算命令见 §2.6）：

> **度量口径（P1-1/P2-1 修正确认）：** 下表"字节数"列为 `wc -c` 字节计数（含 UTF-8 多字节 CJK，非字符数；全集字符数另计为 253,571）；"行数"列为逻辑行（`wc -l` 换行数，对缺少末尾换行的 3 个文件＋1，见 §2.6 命令）。

| # | 文件 | 字节数 | 行数 |
|---|---|---:|---:|
| 1 | `.agents/skills/blake/SKILL.md` | 120,413 | 2,143 |
| 2 | `.agents/skills/blake/references/cross-model-invocation.md` | 3,206 | 62 |
| 3 | `.agents/skills/blake/references/notebooklm-access.md` | 3,895 | 62 |
| 4 | `.agents/skills/gate/SKILL.md` | 52,661 | 996 |
| 5 | `.tad/config-agents.yaml` | 11,298 | 342 |
| 6 | `.tad/config-execution.yaml` | 14,893 | 404 |
| 7 | `.tad/config-quality.yaml` | 32,485 | 875 |
| 8 | `.tad/config-platform.yaml` | 7,931 | 237 |
| 9 | `.tad/ralph-config/loop-config.yaml` | 9,099 | 233 |
| 10 | `.tad/ralph-config/expert-criteria.yaml` | 9,335 | 296 |
| 11 | `.tad/templates/completion-report.md` | 11,078 | 317 |
| 12 | `.tad/templates/handoff-b-to-a.md` | 6,094 | 230 |
| 13 | `.codex/hooks.json` | 770 | 28 |
| **合计** | **Baseline 13 文件** | **283,158** | **6,225** |

Candidate（`arms/candidate.md`，62 行，3,539 字节，单阶段按需加载机制，见 §5 自查→独立复核→交付责任链）：静态预估占用约 885（字节÷4）~1,011（字节÷3.5）Token；Baseline 静态预估约 70,790（÷4）~80,902（÷3.5）Token。字节比约 80:1，行数比约 100:1。**以上仅为静态文本度量（internal 描述），不是运行期结论。**

**B2 底线重申：** n=12 ≪ 50~100。即使将来拿到 12 例的运行胜负，也属于微型概念验证样本，不满足统计推断力（Power）要求，不能作为删减生产规则的依据。

### 2.6 复算命令（静态数字来源）

```bash
python3 -c "import json; b=json.load(open('.tad/evidence/experiments/thin-tad-pilot/arms/baseline.json')); print(b['fixed_sha'], len(b['files']))"
wc -c -l .tad/evidence/experiments/thin-tad-pilot/arms/candidate.md
# 逐文件字节/逻辑行（字节=wc -c；逻辑行=换行数+文件非空且缺末尾换行时补1）：
python3 -c "
import json
b=json.load(open('.tad/evidence/experiments/thin-tad-pilot/arms/baseline.json'))
for f in b['files']:
    d=open(f['path'],'rb').read()
    print(len(d), d.count(b'\n')+(0 if d.endswith(b'\n') or not d else 1), f['path'])
"
node --test experiments/thin-tad-pilot/runner.test.mjs  # pass 25, fail 0（P2 工具腿）
```

---

## §3 P2 `ADAPTER_INELIGIBLE` 探针审计与 Harness 隔离机制

### 3.1 探针报告原文（`runs/isolation-probe-report.json`，只读输入）

- 顶层：`probe_passed=false`、`adapter_eligible=false`、`violation="adapter-ineligible: subject binary missing: oc-run"`、`action="ABORT"`、`model_id="opencode-go/muse-spark-1.3-contributor"`、`harness_id="OpenCode/oc-run"`。
- `checks` 嵌套：`tier1_env_clean=true`、`tier1_no_symlink=true`、`baseline_file_count=13`、`arms_verified=true`、`candidate_present=true`、`harness_available=false`、`negative_blocked=null`（阻断先于运行）、`positive_ok=null`（阻断先于运行）。

### 3.2 因果链条（为什么停在探针）

1. Tier 1（环境净化＋工作区无软链回仓）通过——执行环境本身干净。
2. 双臂装载校验通过（13 文件计数一致、candidate 在场）——实验材料完备。
3. 受测 Harness 可用性检查失败：`which oc-run` exit 1，且 `TAD_OPENCODE_BIN` 未设置——被测对象缺席。
4. 探针依规 fail-closed：`adapter_eligible=false` → `ABORT`，exit 1，不进入 24-run 矩阵。`negative_blocked`/`positive_ok` 保持 null（不是"通过"，是"未及运行"——缺测记为缺失，不记为中性）。

### 3.3 边界防护决策（两次"拒绝替代"的防腐理由）

- **拒绝征用 `/home/box/pm/bin/oc-run.sh`：** 该路径为非标位置、同属另一项目资产，不在本实验授权单覆盖范围内；其参数契约、版本与受控条件（temperature/seed/超时/隔离）未经认证。征用它等于把"被测对象"换成一个未经审计的替身——跑出来的数字无法归因到 `OpenCode/oc-run` 名下，是典型的归因污染。P2 关闭记录已显式声明未将其用作替代（见 P2 COMPLETION §0.5）。
- **拒绝降级为裸 `opencode run`：** 该子命令缺少实验要求的超参数旗标（`--temperature`、`--seed`、`--prompt-file`）与受控超时/隔离语义，无法锁定 `PREREQ-2` 的受控条件。降级运行会破坏双臂可比性（hyperparameter lock 失效），产出的是"条件不等的两组数字"，比没有数字更有害（会误导决策）。
- **Tier 1 与保真度校验的设计价值：** `tier1_env_clean`/`tier1_no_symlink` 保证"干净场地上比"；`baseline_file_count=13`＋sha 保真防止"基线被截断还照跑"（截断专项标记预留：`ADAPTER_INELIGIBLE: BASELINE_TRUNCATED`）。探针的成功标准不是"放行"，而是"在不合规时坚决拦下"——本次 ABORT 正是探针按设计工作的证据（Fail-Safe Defaults）。

---

## §4 实测数据缺失断言与方法学反思

### 4.1 正式缺失声明

- 真实成对运行执行次数：**0**（24-run 矩阵未启动；`manifest.json`、`pair-summary.json`、24 个 `run.json` 均不存在——P2 关闭时复验确认）。
- 主力模型 `opencode-go/muse-spark-1.3-contributor` 在两臂下的相对交付率、Token 消耗比、延迟差异：全部处于 `EMPIRICAL_DATA_ABSENT` 状态，实验结论为 `LIVE_EFFECT_UNDETERMINED`。
- 本报告对"薄 TAD 优于/劣于厚 TAD"不作任何方向性宣称；"未测"不推演为"等效"，也不推演为"无害"。

### 4.2 为什么静态 Token 差异推不出运行期总成本降低

1. **指令遵循率下降→多轮澄清：** 过薄的提示词可能遗漏关键约束，被试产出不合规交付物后需追加澄清轮次，每轮都是新增的交互 Token 与等待时间。
2. **幻觉与错误重试：** 缺少显式检查清单时，被试更易虚构已通过的检查（false_completion），触发 Gate 审查打回（Gate-rework），重工成本远超单次提示词节省。
3. **人工干预时间：** 审查、打回、澄清消耗的是人类注意力——本实验的度量只有字节/行数/静态预估 Token，不含时间维度，任何"更便宜"的结论都超出度量支撑。
4. 因此静态 80:1 只是"纸面负载差"，运行期总账单（提示词＋多轮交互＋重试＋人工）完全未知。

### 4.3 效度分离：Internal Validity 成立，External Validity 缺失

- **内部效度（成立）：** 离线任务包的判定效力（双向控制＋批准 oracles）、双臂冻结完整性、工具链（runner＋25 单测）与探针 fail-closed 行为，均有落盘证据支撑。
- **外部效度（缺失）：** 以上所有结论都不外推到"真实模型在真实任务中的表现"。在线能力可比性需要受控 Harness 下的足量成对运行（n≥50），而这正是 `ADAPTER_INELIGIBLE` 阻断的部分。

### 4.4 资源度量规范说明

本报告严格禁止任何法币与价格计量，仅以字节、行数与静态预估 Token 作为离线计算度量。P2 runner 采集的遥测同样只记 raw token 与耗时（input/output/cached），缺失记 null＋partial，不补零、不换算。

---

## 附录：证据索引（全部为已落盘只读材料）

- P1 验收：`.tad/active/handoffs/COMPLETION-20260907-thin-tad-evaluation-p1.md`（Gate 4 PASS，commit `fc2c07ce`）
- P2 关闭：`.tad/active/handoffs/COMPLETION-20260908-thin-tad-evaluation-p2.md`（`gate3_verdict=ACCEPT-TOOLS-LEG`，`live_matrix=ADAPTER_INELIGIBLE`）
- 探针原文：`.tad/evidence/experiments/thin-tad-pilot/runs/isolation-probe-report.json`
- 基线冻结：`.tad/evidence/experiments/thin-tad-pilot/arms/baseline.json`（`fixed_sha=edce76067f31127d06a1bdbbf3407578d25c81ce`）
- Gate 2 复审：`.tad/evidence/reviews/alex/thin-tad-evaluation-p3/round2-ai-evaluation.md`、`round2-code-review.md`（双 PASS）

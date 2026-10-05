# TAD 精简实验 P3 — 有界裁决与重开准入协议

- **Epic:** EPIC-20260907-thin-tad-evaluation（Phase 3/3）
- **Task:** TASK-20260908-thin-tad-evaluation-p3（handoff v1.1，Gate 2 PASS）
- **Date:** 2026-09-08 · **Author:** Blake（Execution Master）
- **姊妹报告:** `analysis.md`（离线分析与探针审计；实测状态 `LIVE_EFFECT_UNDETERMINED` / `ADAPTER_INELIGIBLE` / `EMPIRICAL_DATA_ABSENT`）

---

## §1 Bounded Verdict（有界裁决）

### 裁决结论

- 生产 TAD 作出 **`MAINTAIN_CURRENT_RULES`** 裁决：保持现有全量规则与架构稳定，**`NO_PRODUCTION_RULE_DELETION`**——不因本实验的纸面静态对比实施任何规则删减或精简上线。
- 裁决边界（bounded）：本裁决仅基于"当前证据不足以支持变更"（缺实测），不是"精简已被证伪"。它既不批准精简，也不永久禁止精简——它把问题冻结在"未决"，直到 §3 的准入条件被满足且新授权单下产生足量实测证据。

### 理由

1. 缺乏主力模型在真实受控 Harness 下的双臂成对对比证据（24-run 矩阵执行 0 次，见 `analysis.md` §4.1）。
2. 静态文本度量（字节比约 80:1）不能推出运行期总成本（`analysis.md` §4.2：澄清轮次、错误重试、Gate-rework、人工干预均未度量）。
3. 样本量 n=12 远低于验证性门槛（n≥50），任何胜负数字都不具备推断力。
4. 未经检验的架构删减属于高风险变更（Measure Before Optimizing）：生产规则是多轮真实故障沉淀的防护层，删除它们需要实测证据，而不是纸面美感。

---

## §2 实验资产归档与保护

### 2.1 已固化的可复用离线基准资产（P1）

- 12 个任务包（6 H 校准集＋6 V 留出集，6 大任务族），位置：`.tad/evidence/experiments/thin-tad-pilot/cases/`。
- 24 组双向控制项（12 correct＋12 error），位置：`.../controls/`。
- 12 组批准 Oracles（`oracles/approved.json`，frozen 2026-09-08，独立重推导＋裁决批准）。
- 冻结双臂（`arms/baseline.json`，`fixed_sha=edce7606` 全量；`arms/candidate.md` 极简任务卡）。
- 以上资产为只读基准：后续实验复用时必须整体引用、不得就地改写；如需演进，另起新冻结版本。

### 2.2 已建立的可复用 Harness 准入测试工具（P2）

- `experiments/thin-tad-pilot/runner.mjs`：isolation probe（Tier 1 环境＋Tier 2 双向控制＋基线保真）→ 工作区隔离 → 受控调用（预算硬停 26 次）→ P1 评分对接 → H/V 分表汇总。
- `experiments/thin-tad-pilot/runner.test.mjs`：25/25 离线单测（含 FAILED_MODEL 不重试、跨臂熔断回归项），全 Mock doubles，不触碰冻结包。
- 真实探针报告：`.../runs/isolation-probe-report.json`（`probe_passed=false`，fail-closed ABORT——这是工具按设计工作的证据，不是工具缺陷）。

---

## §3 未来重开 Live 矩阵的准入协议（Prerequisites Protocol）

### 授权前提

- 必须持有全新的人类授权单（新 handoff、新 task ID），标记：`PREREQ-AUTH: HUMAN_MANDATE`。严禁在本 P3 单上追加运行，严禁复用 P2 的关闭结论作为启动依据。

### 五大可量化准入前置条件

- `PREREQ-1: HARNESS_CERTIFICATION`——官方认证的 `oc-run` 二进制安装在标准 PATH 上：`which oc-run` exit 0；并通过 isolation-probe 的负控（阻断非受权外部网络与未授权工作区）与正控（金丝雀可读写）测试。任一失败即 `ADAPTER_INELIGIBLE`，ABORT。
- `PREREQ-2: HYPERPARAMETER_LOCK`——Harness 完整支持并强制锁定参数：`--temperature 0`、`--seed 42`、单次调用超时上限 `300s`、独立工作区隔离。缺失任一旗标支持即视为条件不成立，不得降级运行。
- `PREREQ-3: BASELINE_13_FIDELITY`——基线 13 文件在注入测试上下文时，各文件 sha256 校验和与 `baseline.json`（`fixed_sha=edce7606`）记录达成 100% 字节级一致，无截断；截断专项标记 `ADAPTER_INELIGIBLE: BASELINE_TRUNCATED`。
- `PREREQ-4: BUDGET_AND_BREAKER`——预设双臂总 Token 预算上限（单臂上限 500,000 tokens，只记 raw token 与耗时，不作任何价格换算）；连续失败熔断器：连续 N≥3 次 harness 调用异常立即中止整个运行（`BUDGET_EXCEEDED` / ABORT）。
- `PREREQ-5: NON_INFERIORITY_MARGIN`——预注册非劣边界容忍度 delta ≤ 5%（或等效胜负阈值），且样本量达到验证性要求 n ≥ 50；拒绝小样本偶发波动作为胜负判定依据；H 与 V 必须分表报告，严禁合并计分。

### 重开后的成功标准（预注册）

- 24-run（或新授权单规定的足量矩阵）完整执行，`manifest.json`＋`pair-summary.json`＋全部 `run.json` 落盘；遥测只有 raw token 与耗时；H/V 分表；结论仍需经 Gate 3/4 独立验收，方可谈规则变更。

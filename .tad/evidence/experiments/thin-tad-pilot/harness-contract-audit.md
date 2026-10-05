# Harness Contract Audit — thin-tad Runner vs Real OpenCode CLI (v1.18.27)

**Task:** TASK-20260908-thin-tad-harness-adapter (Harness Alignment Track)
**Date:** 2026-09-08
**Auditor:** Blake (Execution Master)
**Subject binary:** `/home/box/.opencode/bin/opencode` (OpenCode Go v1.18.27)
**In-repo adapter:** `experiments/thin-tad-pilot/oc-adapter.sh` (0755)
**Scope:** 本单为纯工程适配，不发起任何真实模型调用，不生成任何 24-run 运行记录。

---

## 1. 版本与存在性证据（实测）

| 断言 | 实测命令 | 实测结果 |
|---|---|---|
| 假想命令缺席 | `which oc-run` | 退出码 1（不存在） |
| 真实二进制存在且可执行 | `test -x /home/box/.opencode/bin/opencode` | 通过 |
| 真实版本 | `/home/box/.opencode/bin/opencode --version` | `1.18.27`（满足 `>= 1.18.0` 下限） |
| 仓内适配器存在且可执行 | `test -x experiments/thin-tad-pilot/oc-adapter.sh` | 通过，mode 0755 |
| 适配器语法 | `bash -n experiments/thin-tad-pilot/oc-adapter.sh` | 退出码 0 |

`opencode run --help`（实测摘录）：位置参数 `[message..]`；选项含 `-m/--model`、`--dir`、`--format <default|json>`、`-f/--file`、`--pure`、`--auto`；**无 `--temperature`、无 `--seed`、无 `--prompt-file`**。

---

## 2. 契约全量对比表（Runner 假定 vs 真实 CLI vs 仓内适配器）

| 参数 / 需求 | 原 Runner 假定（`oc-run`） | 真实 OpenCode CLI（`opencode run` v1.18.27） | 仓内适配器解决方案 | 诚实性裁定 |
|---|---|---|---|---|
| 二进制路径 | `oc-run`（系统 PATH） | `/home/box/.opencode/bin/opencode` | 双层变量分立：Runner 层 `TAD_OPENCODE_BIN` 指向仓内适配器（`ocBin()` 默认 `experiments/thin-tad-pilot/oc-adapter.sh`）；适配器层 `TAD_OPENCODE_RAW_BIN` 指向底层真实二进制（默认 `/home/box/.opencode/bin/opencode`，再回退系统 PATH 中 `opencode`）。Runner `ENV_ALLOW` 与 `envLeakCheck` 同时放行两层变量 | 来源明确，杜绝外部运维脚本与系统伪造软链 |
| 工作目录 | `--dir <workDir>` | `--dir <workDir>`（原生） | 软链拒绝（`[ -L ]` exit 2）、`realpath -m` 规范化、`/tmp/` 前缀沙箱包含性校验（`TAD_ALLOWED_WORK_ROOT` 可配）后透传 `--dir "$WORK_DIR"` | 原生支持，叠加沙箱校验与软链防护 |
| 模型指定 | `--model <modelId>` | `-m <modelId>` 或 `--model <modelId>`（原生） | 规范化映射为 `-m "$MODEL_ID"` | 原生支持 |
| 提示词输入 | `--prompt-file <path>`（假想旗标） | 原生 `-f/--file <file>` 或位置参数 `[message..]` | 优先 `-f "$PROMPT_FILE"` 原生文件透传：规避 ARG_MAX 约 2MB 溢出、命令替换吞没末尾换行与 NUL 截断；`PROMPT_FILE` 拒绝软链、校验存在可读，并强制绑定于 `$WORK_DIR` 或白名单根内；位置参数回退须加 `--` 防旗标注入（当前实现恒用 `-f`） | 消除假想旗标，原生挂载，消除注入与截断 |
| 解码温度 | `--temperature 0` | 无 CLI 旗标 | 捕获并向 stderr 打印 `NOTE: [oc-adapter]`，不向底层注入未知参数 | 硬阻断：如实记录不支持，不伪造贪心解码 |
| 随机种子 | `--seed 42` | 无 CLI 旗标 | 捕获并向 stderr 打印 `NOTE: [oc-adapter]`，不向底层注入未知参数 | 硬阻断：如实记录不支持，不伪造确定性 |
| 输出格式 | 自定义文本解析 | 默认 TUI 排版 / `--format json` | `exec` 行显式锁定 `--format default` | 保障非交互批处理流式输出 |
| 权限自动批准 | 无 | `--auto` | 强制附加 `--auto`，防止非 TUI 环境权限询问死锁 | 批处理必需 |

---

## 3. 硬阻断科学归因（温度 / 种子缺席）

1. **事实：** OpenCode Go v1.18.27 的 `run` 子命令参数表（见 §1 实测摘录）不包含任何采样超参数旗标。`--temperature` 与 `--seed` 在该版本下不可通过 CLI 固定。
2. **适配器行为：** Leg-1（Runner→Adapter）保留两旗标输入契约，仅用于透明捕获与审计注记；Leg-2（Adapter→OpenCode）仅发射 §2 原生参数。收到非空温度/种子时打印：
   `NOTE: [oc-adapter] OpenCode CLI (v1.18.27) lacks native --temperature/--seed flags. Received temp='...', seed='...'. Running with engine defaults.`
3. **方差含义：** 本版本下全部运行处于**默认采样策略**，不可宣称"已锁定 temperature: 0"，不可将观测方差粉饰为确定性。任何未来重开矩阵必须在报告中标注默认采样策略，并在人类接受方差风险后方可进行（见 PREREQ-3）。
4. **外部脚本说明：** `/home/box/pm/bin/oc-run.sh` 系另一组合项目的运维包装（进程账本与叫醒），同样无温度/种子处理且含该项目硬编码路径；征用它或自制同名 shim 均属伪造运行，本单已拒绝，代码中无任何指向该路径的硬编码（AC3 断言覆盖）。

---

## 4. 退出码与状态映射（适配器 → Runner 判定）

| 适配器 / 进程事件 | Runner 判定（`outcome.code`） | 消耗 Infra 重试预算 | 处置 |
|---|---|---|---|
| 适配器 exit 127（底座缺失/不可执行） | `FAILED_INFRA` | 否（致命环境故障） | 探针 fail-closed，运行终止 |
| 适配器 exit 2（入参缺失/非法/未知旗标/文件缺失/软链违规/越界） | `FAILED_HARNESS_USAGE` | 否（确定性契约错误） | 不重试，直接失败 |
| 超时（TIMEOUT_MS 300s，进程组 SIGTERM/SIGKILL） | `ETIMEDOUT` | 是（至多 1 次/臂） | 清理进程树并记录 |
| 底座 exit 0 | `COMPLETED` | 否 | 进入 Oracle 与 diff 评估 |
| 底座非零退出 | `FAILED_MODEL` 或 `FAILED_INFRA`（按 INFRA_PATTERNS 区分） | 视特征 | 匹配网络断开类特征可重试，否则不重试 |

---

## 5. 重开 Live 24-Run 准入核对清单（PREREQ Checklist）

> 在任何真实模型运行启动前必须逐项满足；本单内不执行其中任何消耗调用的步骤。

- [ ] **PREREQ-AUTH: HUMAN_MANDATE** — 必须获得人类在独立终端或明确对话中的显式授权（例如中文"我授权重开 24 次 live 模型测试"）。无授权时含 PREREQ-1 步骤 2 在内的任何真实调用均为违规。

- [ ] **PREREQ-1: IN_REPO_HARNESS_CERTIFICATION**
  步骤 1（离线）：
  `test -x experiments/thin-tad-pilot/oc-adapter.sh && test -x /home/box/.opencode/bin/opencode && /home/box/.opencode/bin/opencode --version`
  断言版本 `>= 1.18.0`。
  步骤 2（通道冒烟，仅 PREREQ-AUTH 授权后执行，计入调用预算）：
  `P=$(mktemp /tmp/prereq-prompt.XXXXXX); echo ping >"$P"; experiments/thin-tad-pilot/oc-adapter.sh run --model opencode-go/muse-spark-1.3-contributor --dir /tmp --prompt-file "$P"; rc=$?; rm -f "$P"; test $rc -eq 0`

- [ ] **PREREQ-2: PROBE_DUAL_CONTROL_PASS** — `node experiments/thin-tad-pilot/runner.mjs probe` 须输出 exit 0 且 `probe_passed: true`（Tier 1 环境无泄漏、工作区无回指软链；Tier 2 负控禁读受限文件、正控金丝雀可读写）。
  - 本单落盘时 live 探针状态（诚实记录，非通过性宣称）：`harness_available: true`（仓内适配器已就位）、`negative_blocked: true`，但 `positive_ok: false` —— 默认读取器将 Tier-2 正控委托给 run-pair 沙箱（`delegated-to-run-pair-sandbox`），不消耗模型调用去伪造通过。因此 live `probe_passed` 现为 `false`（fail-closed，退出码 1）。Tier-2 正控在本单由离线双倍件（`runner.test.mjs` clean double）与新增 `executeArm` 真实适配器集成测试覆盖；重开时首次经授权的 run-pair 即为 live 正控的真实证明。此条保持 OPEN 由 Alex Gate 4 裁决，严禁为使探针变绿而伪造读取成功。

- [ ] **PREREQ-3: HYPERPARAMETER_AND_VARIANCE_DISCLOSURE** — 本文档 §3 已完整披露 CLI 无温度/种子旗标限制，运行处于默认采样策略；须获人类确认接受方差风险。
  验证：`grep -E '默认采样策略|NOTE: \[oc-adapter\]' .tad/evidence/experiments/thin-tad-pilot/harness-contract-audit.md`

- [ ] **PREREQ-4: BASELINE_13_FIDELITY** — 基线双臂加载校验通过，13 个规则文件 100 percent 字节一致（`fidelity.arms_verified: true`）。
  验证：`node -e 'import("./experiments/thin-tad-pilot/runner.mjs").then(async m => { const r = await m.verifyArmsFidelity(); console.log(JSON.stringify(r)); if(!r.ok) process.exit(1); })'`

- [ ] **PREREQ-5: BUDGET_AND_CIRCUIT_BREAKER_ACTIVE** — 矩阵上限 24 次计划运行 + 至多 2 次设施级重试（总调用上限 26，第 27 次熔断）；连续 3 次设施故障全局熔断；只记录 raw tokens 与耗时，严禁法币折算。
  验证：`grep -E 'MAX_INVOCATIONS = 26|MAX_TOTAL_INFRA_RETRIES = 2|CONSECUTIVE_INFRA_ABORT = 3' experiments/thin-tad-pilot/runner.mjs && node -e 'import("./experiments/thin-tad-pilot/runner.mjs").then(m => { if(m.MAX_INVOCATIONS!==26||m.MAX_TOTAL_INFRA_RETRIES!==2||m.CONSECUTIVE_INFRA_ABORT!==3) process.exit(1); console.log("Budget constants verified."); })'`

- [ ] **PREREQ-6: PRE_REGISTERED_EVAL_BOUNDS** — H 校准集 6 例与 V 留出集 6 例严格分表，严禁合并胜负比；n=12 仅为探索性样本。
  验证：`node -e 'import("./experiments/thin-tad-pilot/runner.mjs").then(m => { console.log("H:", m.H_CASES.length, "V:", m.V_CASES.length); if(m.H_CASES.length!==6||m.V_CASES.length!==6) process.exit(1); })'`

---

## 6. 本单边界声明

1. 本单未执行任何真实模型调用；`runs/` 下未新增任何 `run.json` / `manifest.json` / `pair-summary.json`。
2. 生产 TAD 路径（`.agents/`、`.claude/`、`.tad/hooks/`、`.tad/config.yaml`）零修改；P1 冻结数据未触碰。
3. 审计文档全程无伪造数据；记账口径为 raw tokens 与耗时，无任何法币折算逻辑。

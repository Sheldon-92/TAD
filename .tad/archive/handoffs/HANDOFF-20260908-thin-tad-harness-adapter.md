---
task_type: mixed
e2e_required: no
research_required: no
skip_knowledge_assessment: no
feedback_required: false
gate4_delta: []
---

# Handoff: thin-tad 评测适配器设计与 OpenCode 二进制契约对齐 (TASK-20260908-thin-tad-harness-adapter)

**From:** Alex (Solution Lead)  
**To:** Blake (Execution Master)  
**Date:** 2026-09-08  
**Task ID:** TASK-20260908-thin-tad-harness-adapter  
**Priority:** P1  
**Epic:** EPIC-20260907-thin-tad-evaluation.md (Harness Alignment Track)  
**Version:** 1.3
**Status:** Gate2-PASS (v1.3: dual Round3 independent re-reviews PASS — eval-review-round3.md + code-review-round3.md; Round2 CONDITIONAL blockers AC5/F07 verified closed; authorized for Blake pending Human understanding-check)

---

## Gate 1 / Confirmed Intent

### 1. 背景与前序阶段闭环事实
在 EPIC-20260907-thin-tad-evaluation 中：
1. **Phase 1 离线任务包已验收通过**（commit `fc2c07ce`）：固化 12 个任务案例（6 H 校准 + 6 V 留出，跨 6 大任务族）、24 组双向控制项、12 组经批准的 Oracles、双臂静态冻结（Baseline 13 文件 vs Candidate 薄提示词）；
2. **Phase 2 工具腿已验收，真实运行因 Harness 缺席正式关闭**（`COMPLETION-20260908-thin-tad-evaluation-p2.md`）：
   - `experiments/thin-tad-pilot/runner.mjs` 工具链与 25/25 离线单测（含 Layer 2 双审 5 人次）验收通过（`gate3_verdict: ACCEPT-TOOLS-LEG`）；
   - 真实 24-run 模型矩阵因预期中的 `oc-run` 二进制在终端 PATH 缺席，启动探针 fail-closed（exit 1），正式裁定 **`ADAPTER_INELIGIBLE`**；未生成任何伪造运行记录（`manifest.json`、`pair-summary.json`、24 个 `run.json` 均未编造）；
3. **Phase 3 离线分析与有界决策报告已验收闭环**（`COMPLETION-20260908-thin-tad-evaluation-p3.md`）：
   - 交付 `analysis.md` 与 `decision.md`，做出生产 TAD **`MAINTAIN_CURRENT_RULES`** 与 **`NO_PRODUCTION_RULE_DELETION`** 裁决；
   - 诚实断言真实模型效果为 **`LIVE_EFFECT_UNDETERMINED`** 与 **`EMPIRICAL_DATA_ABSENT`**；
   - 确立了未来若重开真实 24-run 模型评测所必须达成的准入前置条件。

### 2. 真实基础设施与契约鸿沟诊断（Forensic Diagnosis）
在 P2 关闭与 Infra 复验中已固化以下事实：
- **事实 A：PATH 无 `oc-run` 二进制**：`which oc-run` 退出码为 1。原 `runner.mjs` 假定存在一个支持 `--temperature 0 --seed 42 --prompt-file <path> --dir <dir>` 的独立 `oc-run` 二进制，该二进制在真实系统上不存在。
- **事实 B：裸 `opencode` 二进制契约与 Runner 假定失配**：
  - 本机真实安装并可执行的 OpenCode 二进制路径为 `/home/box/.opencode/bin/opencode`（OpenCode Go v1.18.27，mode 0755）；
  - `opencode run --help` 明确显示其 CLI 接受参数为：`opencode run [message..] -m/--model <model> --dir <dir> --format <default|json> -f/--file <file> --pure --auto` 等；
  - **关键硬阻断（Hard Blockers）**：裸 `opencode run` **根本没有** `--temperature`、`--seed`、`--prompt-file` 旗标；若直接将现有 `runner.mjs` 的 argv 传给 `opencode run`，将直接报未知参数错误。
- **事实 C：外部 PM 脚本绝不是合规的被测 Harness**：
  - `/home/box/pm/bin/oc-run.sh` 仅为 `grok-cloud` 组合项目用于进程账本记录与 Webhook 叫醒的运维包装脚本；
  - 其内部同样没有 `--temperature`/`--seed` 处理能力；且其硬编码了项目路径（如 `/home/box/云同步/grok-cloud`），未经本任务单授权覆盖；
  - 征用外部 PM 脚本或制作假冒支持温度/种子旗标的 fake shim 属于学术欺诈与伪造运行（Forged Runs），Infra 与 TAD 均已明令拒绝。

### 3. 本单目标（Goal）
人类站立授权：“完成整个 epic 与测试”。在 P1-P3 报告路径已安全闭环的前提下，为使评测体系具备在真实系统上合规运转的技术可能，由 Alex 设计本技术准备单（Harness Alignment Track）：
1. **构建仓内极简受测适配器 CLI 包装（In-Repo Adapter CLI Wrapper）**：在 `experiments/thin-tad-pilot/` 目录下创建合规、透明的适配脚本（`experiments/thin-tad-pilot/oc-adapter.sh` 或 `.mjs`），负责衔接 Runner 与真实 `/home/box/.opencode/bin/opencode` 二进制；
2. **诚实适配真实 OpenCode 契约，直面硬阻断**：
   - `--prompt-file` 适配：将 Runner 生成的提示词文件通过读取内容传给 `opencode run` 的 message 参数或 `-f/--file` 参数；
   - `--temperature` 与 `--seed` 真实性处理：严禁伪装支持！在适配器与文档中如实记录 OpenCode Go CLI 缺乏显式旗标的现状，明确该版本下的默认采样行为与方差影响；
3. **改造 `experiments/thin-tad-pilot/runner.mjs` 及其单测**：
   - 消除对外部假想 `oc-run` 的虚假依赖，使 Runner 能够通过环境变量 `TAD_OPENCODE_BIN` 或相对路径无缝挂接仓内适配器；
   - 更新启动探针（isolation probe），检验仓内适配器对 `/home/box/.opencode/bin/opencode` 的调用通道；
   - 补充完善离线单测套件 `runner.test.mjs`，确保适配器逻辑与参数转译 100% 具备 Mock 保护；
4. **输出完备的《重开 Live 24-Run 准入核对清单》（PREREQ Checklist）**：
   - 将 P3 确立的准入协议在工程层面细化为可执行、可检验的具体断言步骤；
   - 严明准入边界：在全部 PREREQ 被验证满足且获得人类显式授权前，严禁在本单中偷跑真实 24-run。

Gate 1 结果：**PASS**。

---

## 🔴 Gate 2: Design Completeness (Alex)

**状态**: **Gate2-PASS**（v1.3: R1/R2 Round3 双独立复审均 PASS，R1/R2 Round2 CONDITIONAL 阻断项 AC5/F07 已闭环验证；人类确认 Blake 理解 §1.3 四问后可启动实现）

### Gate 2 v1.3 双复审 PASS 记录（Round3 Verdict, 2026-09-08）
- **R1-Round3 (AI Evaluation)**: `.tad/evidence/reviews/alex/thin-tad-harness-adapter/eval-review-round3.md` — **PASS** (unconditional). Round2 唯一阻断 F-07/AC5 已闭环：AC5 验证单元格现为可执行双断言（`buildOcArgv` Leg-1 四旗标 `includes` + `probe_passed` 布尔判定，L454），方向裁决 INCLUDES 正确（Leg-1 诚实捕获 vs Leg-2 原生，§3.2 L209 为准）；其余 Round2 PASS 项无回归。
- **R2-Round3 (Code & Security)**: `.tad/evidence/reviews/alex/thin-tad-harness-adapter/code-review-round3.md` — **PASS** (unconditional). Round2 唯一条件 F07 已文本闭环：软链拒绝（`[ -L ]` L294/L314）→ `realpath -m` 规范化 → 前缀包含（`TAD_ALLOWED_WORK_ROOT` L306–L311）→ 提示词绑定（L326–L329），表码一致（§4.1 L221/L223 == §4.2），AC1/AC4 三元组绑定（cases 8/9/10）+ §9.2 Gate 3 阻断验收法则（L484–L494）。P0 F01–F04 无回归；残留仅 P2 级 `--pure` 记录与 `**` 展开规范（实现期载明，非 Gate 2 阻断）。

### Gate 2 v1.2 审查发现清零说明（Revision Summary against Round 2 Reviews）

根据 `.tad/evidence/reviews/alex/thin-tad-harness-adapter/eval-review-round2.md`（R1-Round2: AI Evaluation）与 `code-review-round2.md`（R2-Round2: Code & Security）的独立审查意见，v1.2 进行如下针对性闭环修订：
1. **R1-Round2 F-07 (Eval P1) / AC5 验证命令单元格补齐可执行行为断言**：
   - 彻底修复“预期说明提出行为要求，但验证命令仅为 `node --check` 语法检查”的缺口；
   - AC5 验证命令单元格追加可执行断言：`node --check experiments/thin-tad-pilot/runner.mjs && node -e 'import("./experiments/thin-tad-pilot/runner.mjs").then(async m => { const argv = m.buildOcArgv({ workDir: "/tmp/w", extraPrompt: "/tmp/p" }); if (!argv.includes("--prompt-file") || !argv.includes("--dir") || !argv.includes("--temperature") || !argv.includes("--seed")) process.exit(1); const { report } = await m.probeIsolation(); if (typeof report.probe_passed !== "boolean") process.exit(1); console.log("AC5 probe & buildOcArgv assertions passed"); })'`；
   - 机械校验 `buildOcArgv` 完整生成 Leg 1 输入参数契约（供适配器无损捕获超参数与提示词），同时断言探针导出报告包含 `probe_passed` 判定，消除纸面通过。
2. **R2-Round2 F07 (Code P1) / 适配器工作区前缀包含性、软链拒绝与提示词路径绑定 (F07 Containment & Sandboxing)**：
   - 在 §4.1、§4.2 适配器规范及 §7 AC1/AC4 中正式固化三道沙箱防护防线：
     (a) **软链硬性拒绝**：对原始 `$WORK_DIR` 与 `$PROMPT_FILE` 执行 `[ -L ]` 校验，一旦发现软链立即 fail-closed 退出 2，防止利用符号链接逃逸至宿主机或主仓库；
     (b) **工作区前缀包含性 (Workdir Prefix Containment)**：`$WORK_DIR` 经 `realpath -m` 规范化后，必须位于受控根目录（默认 `/tmp/`，或受 `TAD_ALLOWED_WORK_ROOT` 控制）内，非允许前缀直接报 exit 2；
     (c) **提示词路径绑定 (Prompt Path Binding)**：`$PROMPT_FILE` 必须实际位于 `$WORK_DIR` 或受控根目录内，严防通过任意绝对路径透传读取外部非测试文件；
   - 在 §9.2 增设明确的 Gate 3 强制执行法则（Gate 3 Enforcement Rationale），要求 Blake 在 `runner.test.mjs` 中新增对应的反向测试用例（failing-before/passing-after）并作为 Gate 3 阻断检查点。
3. **文本一致性修剪**：§10 任务派发中的非规范法币表述修正为限定词边界 `\b(usd|dollars?|cents)\b` 及货币语义 `$`，与 §1.3 及 AC7 保持严格的一致性。

### Gate 2 v1.1 审查发现清零说明（Revision Summary against R1/R2 Reviews）

根据 `.tad/evidence/reviews/alex/thin-tad-harness-adapter/eval-review.md`（R1: AI Evaluation）与 `code-review.md`（R2: Code & Security）的独立审查意见，v1.1 进行如下全面闭环修订：
1. **F-01 (P0, Eval) / F-08d (P2)**：AC7 正则更新为词边界 `\b(usd|dollars?|cents)\b`，并仅限定在审计文档 `harness-contract-audit.md`（豁免 `oc-adapter.sh` 脚本内合法的 shell 变量 `$VAR` 与 `$(...)` 语法）；§1.3 与 §2 文档同步明确定义。
2. **F-02 (P0, Eval) / F09 (P1, Code)**：PREREQ-1 废除 `<(echo 'ping')` 进程替换（其产生 `/dev/fd/` 管道导致 `[ -f ]` 判断失败），改为 `mktemp` 创建真实临时文件；拆分出独立的离线版本下限断言步骤（`>= 1.18.0`）；明确必须在 `PREREQ-AUTH` 授权后方可执行且计入调用限额。
3. **F01 (P0, Code)**：§4.2 适配器对 `--model|-m`、`--dir`、`--prompt-file`、`--temperature`、`--seed` 的参数提取增加 `[ $# -ge 2 ] || ... exit 2` 保护，防止在 `set -u` 与 `set -e` 下因缺少值导致未捕获异常退出，确保入参错误严格返回 exit 2。
4. **F02 (P0, Code)**：§4.2 中在位置参数形式传入提示词时强制增加 `--` 分隔符，杜绝提示词首字符为 `-`/`--` 时的 CLI 旗标注入（flag injection）漏洞。
5. **F03 (P0, Code)**：§4.1、§4.2、§4.3 将 prompt 输入机制全面升级为**优先采用 `-f "$PROMPT_FILE"` 原生文件透传**，彻底根除位置参数方式下的 ARG_MAX（~2MB）溢出、末尾换行被 `$(cat ...)` 吞没及 NUL 字符丢失问题；位置参数仅作为文档化备选。
6. **F04 (P0, Code) / F-03 (P1, Eval)**：明确区分两层环境变量：Runner 层通过 `TAD_OPENCODE_BIN` 指定仓内适配器（`ocBin()` 默认值从 `'oc-run'` 强制更新为 `experiments/thin-tad-pilot/oc-adapter.sh`，绝无外部路径硬编码），适配器层通过 `TAD_OPENCODE_RAW_BIN` 指定底座二进制；在 `runner.mjs` 的 `ENV_ALLOW` 与 `envLeakCheck` 中同时放行这两层变量；清晰阐明 Runner->Adapter 与 Adapter->OpenCode 两段参数契约差异。
7. **F05 (P1, Code)**：适配器未知参数处理改为 fail-closed，遇到未识别参数直接打印错误并 exit 2。
8. **F06 / F07 (P1, Code)**：`--prompt-file` 设为必选（缺失 exit 2）；对 `WORK_DIR` 与 `PROMPT_FILE` 增加 `realpath -m` 规范化、存在性与只读检查，强化工作区边界防护。
9. **F08 (P1, Code)**：新增 §4.4 退出码与状态组合映射表，明确定义适配器 exit 127、exit 2（映射为 `FAILED_HARNESS_USAGE`，不浪费 infra 重试预算）、超时及透传底座退出码的状态归宿。
10. **F10 (P1, Code)**：在 `exec` 命令行中显式锁定 `--format default`。
11. **F-04 / F-05 (P1, Eval)**：PREREQ-1 绑定 PREREQ-AUTH 并增加离线版本断言；PREREQ-4、PREREQ-5、PREREQ-6 均补齐具体可执行的命令行断言，消除纸面准入风险。
12. **F-06 (P1, Eval)**：AC4 单测门槛提升至 >= 30（基线已有 25 个通过），并枚举 7 个强制新增的 Mock 测试用例名称。
13. **F-07 (P1, Eval)**：AC5 强化为行为断言，检验探针真实 fail-closed 逻辑与 `buildOcArgv` 契约合规性。
14. **F-08a / F-08b / F11 (P1/P2)**：AC6 补齐审计报告结构化内容要求；AC8 固化 `git status --porcelain=v1 --untracked-files=all | sort` 预先捕获与对比规程。
15. **F12 / F13 (P2, Code)**：澄清环境隔离边界（适配器依赖 Runner `sanitizeEnv`；直接手工调试需包装 `env -i` 与 `timeout 300`）。

### Gate 2 待审要件清单

| 检查项 | 状态 | 交付与闭环说明 |
|---|---|---|
| Architecture Complete | 待复审 | §4 规范仓内适配器架构、沙箱防护与路径包含性（F07）、输入转译管道、进程组管理与遥测抽取标准（v1.2 闭环 F01-F04, F07, F08, F10） |
| Components Specified | 待复审 | §3、§4 规范 `oc-adapter.sh` 接口与 `runner.mjs` 的适配改动，明确环境变量双层分立（v1.1 闭环 F04） |
| Functions Verified | 待复审 | §5 详细核查 OpenCode v1.18.27 实际 CLI 参数、路径与环境变量白名单 |
| Data Flow Mapped | 待复审 | §4.3 绘制从 Case 工作区到适配器、再到 OpenCode CLI 的参数与标准 I/O 流向（v1.1 优先 `-f`，v1.2 强化沙箱边界） |
| Honesty & Anti-Forgery | 待复审 | 严禁假冒温度/种子旗标，严禁使用 `/home/box/pm` 外部脚本，硬阻断入档记录 |
| PREREQ Checklist Formulated | 待复审 | §6 制定 6 大可量化重开前置核查项，全量提供可执行断言命令（v1.1 闭环 F-02, F-04, F-05） |
| Acceptance Criteria Executable | 待复审 | §7 AC5 补齐可执行行为断言，AC1/AC4 强化沙箱与软链拒收单测要求（v1.2 闭环 F-07, F07） |
| Expert Review Plan | 待复审 | 预留 OpenCode 独立专家双审（AI Eval + Code Review）载体与验证方法，待 R1/R2 Round 2 复审验收 |

---

## 1. Task Overview / Intent Statement

### 1.1 What We're Building
在无需运行模型消耗额度、不引入法币换算、不触碰生产 TAD 架构的前提下，由 Blake 在独立终端中实现并交付：
1. **仓内受测适配器 CLI 包装**：`experiments/thin-tad-pilot/oc-adapter.sh`（或 `.mjs`，具备可执行权限 0755）
   - 部署在仓库内部 `experiments/thin-tad-pilot/`，绝不在系统全局或 `/home/box/pm/` 伪造假 shim；
   - 作为桥梁：接收 Runner 规范的调用参数（`run --model <id> --dir <workDir> --prompt-file <path> [--temperature <t>] [--seed <s>]`）；
   - 执行前置断言：验证执行环境、校验 `workDir` 存在性（`realpath -m` 规范化）、前缀包含性（必须位于 `/tmp/` 或白名单根目录）、拒绝符号链接（`[ -L ]` exit 2）、定位真实 OpenCode 二进制（受 `TAD_OPENCODE_RAW_BIN` 覆盖）；
   - 提示词路径绑定与原生透传：`PROMPT_FILE` 拒绝软链并强制绑定在工作区或白名单根目录内，**优先使用 `-f "$PROMPT_FILE"` 原生文件挂载传递提示词**，彻底消除 ARG_MAX 限制、换行丢失与注入漏洞；
   - 针对 `--temperature` / `--seed` 执行诚实阻断/记录：记录传入值并在 stderr 输出 `NOTE: [oc-adapter]`，向底层调用时坚决不注入未知旗标；
   - 健壮入参解析：所有参数在 `set -u` / `set -e` 下严格防越界，未知参数一律 fail-closed 返回 exit 2；
2. **适配改造评测驱动套件**：`experiments/thin-tad-pilot/runner.mjs`
   - 消除对外部假想 `oc-run` 的虚假依赖：`ocBin()` 默认值从 `'oc-run'` 强制更新为仓内适配器路径（`experiments/thin-tad-pilot/oc-adapter.sh`）；
   - 双层环境变量与白名单放行：Runner 的 `ENV_ALLOW` 与 `envLeakCheck` 同时放行 `TAD_OPENCODE_BIN` 与 `TAD_OPENCODE_RAW_BIN`；
   - 明确两段参数协议（Two-Leg Protocol）：Runner->Adapter 保持输入契约（以便适配器捕获并记录超参数），Adapter->OpenCode 仅发射真实原生参数；
   - 适配启动探针（`runner.mjs probe`）：对真实 OpenCode 可用性、仓内适配器权限、工作区隔离、金丝雀读写进行两层严格校验；
3. **适配器专项离线单测**：`experiments/thin-tad-pilot/runner.test.mjs`
   - 扩充现有单测至 >= 33 个（基线 25 个通过基础上新增 >= 8 个），增加对适配器参数转译、缺失值防护、非法入参 exit 2、提示词透传、诚实注记、退出码传播，以及软链拒收、目录前缀包含性与 prompt 路径绑定的自动化 Mock 测试；
4. **契约审计与重开前置清单**：`.tad/evidence/experiments/thin-tad-pilot/harness-contract-audit.md`
   - 详细记录 OpenCode v1.18.27 真实 CLI 契约与评测假定的全量对比表；
   - 完整陈列《重开 Live 24-Run 准入核对清单》（PREREQ Checklist），全量配备可直接执行的验证命令，作为后续任何模型运行的技术闸门。

### 1.2 Why We're Building It
**业务价值**：评测科学的基础是受测工具有诚实的契约。若使用假冒脚本或者随意征用外部非标脚本，所有的测试数据都是废纸。通过构建仓内、受版本控制的透明适配器，不仅消除了此前 `ADAPTER_INELIGIBLE` 的环境鸿沟，更向所有审计者证明了 TAD 对评测真实性的敬畏。  
**成功的样子**：仓内适配器自测通过，`runner.test.mjs` 全部绿灯，离线探针精准识别真实环境状态，审计文档严密记录所有技术取舍与限制，生产代码零触碰。

### 1.3 Intent Statement（意图声明）

**真正要解决的问题**：
在仓库自身受控目录内，构建一个忠实反映真实 OpenCode Go CLI（v1.18.27）能力的适配层，修复 `runner.mjs` 的假想参数调用，使整个评测套件在工程上真实可用，并固定准入清单。

**不是要做的（避免误解）**：
- ❌ 不是在本任务中发起真实 24-run 模型调用（本单是适配器工程单，不偷跑实验）；
- ❌ 不是在 `/home/box/pm/` 或系统 PATH 中放置假冒的 `oc-run` 软链或 fake 脚本；
- ❌ 不是伪装 OpenCode 接受了 `--temperature 0` 和 `--seed 42`（不支持就是不支持，必须诚实记录）；
- ❌ 不是修改现行生产 TAD 的规则文件、skills、hooks 或配置；
- ❌ 不是引入任何法币折算逻辑（法币词限定词边界 `\b(usd|dollars?|cents)\b`，货币含义的 `$` 禁用；shell 脚本中正常的 `$VAR`、`$(...)` 语法完全豁免）；
- ❌ 不是由 Alex 宣称 Gate 2 PASS（必须由 OpenCode 独立会话专家审查）。

**Blake 请确认理解**：
```
在开始实现前，请用你自己的话回答：
1. 为什么此前 P2 会被判为 ADAPTER_INELIGIBLE？本机上真实的 OpenCode 二进制位于哪里，它缺失了原 runner 期望的哪三个旗标？
2. 为什么严禁使用 /home/box/pm/bin/oc-run.sh 或在系统目录下建立假 shim？新适配器应该放在仓库的哪个目录下？
3. 对于 OpenCode 缺乏 --temperature 与 --seed 旗标这一事实，适配器和审计文档应该如何处理？
4. 本单是否允许实际运行 24 次模型调用？本单允许修改生产 TAD 目录（.agents/、.claude/）吗？

只有 Human 确认你的理解正确后，才能在 Blake 终端开始实现。
```

---

## 📚 Project Knowledge / Capability Pack References

### Blake 必读历史教训与原则
1. **Never Hand-Write What an Existing Tool Already Does (principles.md 2026-05-28)**：复用已有的 `experiments/thin-tad-pilot/runner.mjs` 框架与 `pilot.mjs`，只进行最小必要适配，不另起炉灶重写评测系统。
2. **Fail-Safe Defaults & Run Verification (ac-verification.md)**：任何参数不匹配、可执行位缺失或工作区权限异常，必须立即 fail-closed 并返回明确退出码，严禁吞噬错误。
3. **Honesty in Reporting (principles.md & pack-evaluation.md)**：不伪造不存在的功能，不把不可控方差粉饰为确定性。OpenCode CLI 缺失的超参数能力必须作为审计事实公开记录。
4. **Snapshot-Diff Scope Fence (ac-verification.md 2026-08-05)**：采用快照差围栏验证，生产路径绝对零修改。
5. **No Synthetic Currency Conversions**：代码与文档中严禁任何法币汇率与法币词（词边界 `\b(usd|dollars?|cents)\b` 与货币语义的 `$` 严禁；shell 变量 `$VAR` 语法豁免）。

---

## 3. Requirements / Execution Mandate

### 3.1 权威写入白名单（Canonical Write Allowlist）
本任务中 Blake 的所有操作严格限定在以下路径，超出此范围的任何修改均属违规：
1. `experiments/thin-tad-pilot/oc-adapter.sh` （新建，仓内 OpenCode CLI 适配脚本）
2. `experiments/thin-tad-pilot/runner.mjs` （修改，适配仓内适配器接口与探针逻辑）
3. `experiments/thin-tad-pilot/runner.test.mjs` （修改，扩充离线 Mock 单测）
4. `experiments/thin-tad-pilot/README.md` （修改，更新适配器说明与运行方式）
5. `.tad/evidence/experiments/thin-tad-pilot/harness-contract-audit.md` （新建，契约对比与 PREREQ 审计报告）
6. `.tad/active/handoffs/COMPLETION-20260908-thin-tad-harness-adapter.md` （新建，Gate 3 交付与验收承载报告）
7. `.tad/evidence/reviews/alex/thin-tad-harness-adapter/**` （新建，Layer 2 审查承载目录）

严禁修改 `.agents/`、`.claude/`、`.tad/hooks/`、`.tad/config.yaml` 及任何现有 P1 冻结数据（`cases/`、`arms/`、`oracles/`）。

### 3.2 环境变量分层与 Runner 默认二进制契约
为杜绝环境污染并彻底消除假想外部命令，系统确立清晰的双层变量与默认值规范：
1. **Runner 层（`TAD_OPENCODE_BIN`）**：
   - 指向被测适配器脚本；
   - `experiments/thin-tad-pilot/runner.mjs` 中的 `ocBin()` 默认值**必须从 `'oc-run'` 强制更新为仓内相对路径 `'experiments/thin-tad-pilot/oc-adapter.sh'`**；
   - 严禁任何硬编码指向 `/home/box/pm/**` 的非标路径。
2. **适配器层（`TAD_OPENCODE_RAW_BIN`）**：
   - 指向底层真实的 OpenCode Go 二进制；
   - `oc-adapter.sh` 中默认回退至 `/home/box/.opencode/bin/opencode`，再回退至系统 `PATH` 中的 `opencode`。
3. **环境隔离放行（`ENV_ALLOW` & `envLeakCheck`）**：
   - `runner.mjs` 中的 `ENV_ALLOW` 集合必须同时将 `TAD_OPENCODE_BIN` 与 `TAD_OPENCODE_RAW_BIN` 纳为合法变量；
   - `envLeakCheck()` 函数必须同时对这两个变量豁免，避免其被作为泄露变量拦截。
4. **两段调用协议（Two-Leg Argv Protocol）**：
   - **Leg 1 (Runner → Adapter)**：`buildOcArgv` 输出 `run --model <id> --dir <workDir> --prompt-file <path> --temperature 0 --seed 42`。保留超参数是为了在适配器层透明捕获并打印审计注记；
   - **Leg 2 (Adapter → OpenCode CLI)**：适配器转换为真实支持的原生参数 `"$OPENCODE_BIN" run --dir "$WORK_DIR" -m "$MODEL" --auto --format default -f "$PROMPT_FILE"`。坚决不向底层传递不存在的 `--temperature` 与 `--seed`。

---

## 4. Technical Architecture & Contract Mapping

### 4.1 CLI 契约对齐与转译映射

| 参数 / 需求 | 原 Runner 假定 (`oc-run`) | 真实 OpenCode CLI (`opencode run`) | 仓内适配器 (`oc-adapter.sh`) 解决方案 | 诚实性裁定 |
|---|---|---|---|---|
| **二进制路径** | `oc-run`（系统 PATH） | `/home/box/.opencode/bin/opencode` (Go v1.18.27) | **双层环境变量分立**：<br>1. Runner 层 `TAD_OPENCODE_BIN`：指向仓内适配器脚本，`ocBin()` 默认值从 `'oc-run'` 强制更新为仓内相对路径 `'experiments/thin-tad-pilot/oc-adapter.sh'`；<br>2. 适配器层 `TAD_OPENCODE_RAW_BIN`：指向底层真实 OpenCode 二进制，默认回退至 `/home/box/.opencode/bin/opencode`，再回退至系统 `PATH`。<br>Runner `ENV_ALLOW` 与 `envLeakCheck` 同时放行两层变量。 | 明确来源，杜绝外部 PM 脚本与系统伪造软链 |
| **工作目录** | `--dir <workDir>` | `--dir <workDir>` | 对 `$WORK_DIR` 执行软链拒绝（`[ -L ]` exit 2）、`realpath -m` 规范化以及 `/tmp/` 前缀沙箱包含性校验，严防越界穿透后透传 `--dir "$WORK_DIR"` | 官方原生支持，强化目录沙箱校验与软链防护 |
| **模型指定** | `--model <modelId>` | `-m <modelId>` 或 `--model <modelId>` | 规范化映射为 `-m "$MODEL_ID"` | 官方原生支持 |
| **提示词输入** | `--prompt-file <path>` | 原生支持 `-f/--file <file>` 或位置参数 `[message..]` | **优先采用 `-f "$PROMPT_FILE"` 原生文件透传**：<br>彻底规避 `cat` 进 argv 引起的 ARG_MAX（~2MB）溢出、末尾换行被吞没与 NUL 字符截断问题；<br>对 `PROMPT_FILE` 执行软链拒绝（`[ -L ]` exit 2）、`realpath -m` 及 `[ -f ] && [ -r ]` 权限校验，并强制要求路径位于 `$WORK_DIR` 或受控允许根目录内，杜绝任意文件越界读取；<br>若使用位置参数回退，必须在参数前附加 `--` 阻断旗标注入。 | 消除假想旗标，原生文件挂载，消除注入、截断与路径遍历 |
| **解码温度** | `--temperature 0` | ❌ **无 CLI 旗标** | 检查并捕获参数；向 stderr 打印 `NOTE: [oc-adapter]` 注记；不向底层注入未知参数 | **硬阻断**：如实记录 CLI 不支持，不伪造贪心解码 |
| **随机种子** | `--seed 42` | ❌ **无 CLI 旗标** | 检查并捕获参数；向 stderr 打印 `NOTE: [oc-adapter]` 注记；不向底层注入未知参数 | **硬阻断**：如实记录 CLI 不支持，不伪造确定性 |
| **输出格式** | 自定义文本解析 | 默认 TUI 格式 / `--format json` | 显式在 `exec` 命令行中锁定 `--format default` | 确保非交互批处理正常流式输出 |
| **权限自动批准** | 无 | `--auto` | 强制附加 `--auto`，防止非 TUI 环境下因询问权限而死锁挂起 | 必需的批处理保障 |

### 4.2 仓内适配器脚本规范 (`experiments/thin-tad-pilot/oc-adapter.sh`)
```bash
#!/usr/bin/env bash
# experiments/thin-tad-pilot/oc-adapter.sh
# Honest in-repo adapter bridging thin-tad runner to real OpenCode CLI (v1.18.27).
# Node stdlib subprocess-friendly: propagates stdout, stderr, and exit codes accurately.
set -euo pipefail

# 1. 寻找真实底层二进制 (受 TAD_OPENCODE_RAW_BIN 控制)
OPENCODE_BIN="${TAD_OPENCODE_RAW_BIN:-/home/box/.opencode/bin/opencode}"
if [ ! -x "$OPENCODE_BIN" ]; then
  if command -v opencode >/dev/null 2>&1; then
    OPENCODE_BIN="$(command -v opencode)"
  else
    echo "ERROR: [oc-adapter] Subject OpenCode binary not found or not executable at: $OPENCODE_BIN" >&2
    exit 127
  fi
fi

# 2. 解析 Runner 传入参数 (两段契约：Runner->Adapter 输入契约)
# 支持: run --model <m> --dir <d> --prompt-file <f> [--temperature <t>] [--seed <s>]
SUBCOMMAND="${1:-}"
if [ "$SUBCOMMAND" != "run" ]; then
  echo "ERROR: [oc-adapter] Unsupported subcommand: ${SUBCOMMAND:-<empty>} (only 'run' is supported)" >&2
  exit 2
fi
shift

MODEL=""
WORK_DIR=""
PROMPT_FILE=""
TEMP=""
SEED=""

# 保护：每项带参选项在 set -u / set -e 下均有 $# -ge 2 边界防护；未知入参一律 fail-closed exit 2
while [[ $# -gt 0 ]]; do
  case "$1" in
    --model|-m)
      [ $# -ge 2 ] || { echo "ERROR: [oc-adapter] Missing value for $1" >&2; exit 2; }
      MODEL="$2"; shift 2 ;;
    --dir)
      [ $# -ge 2 ] || { echo "ERROR: [oc-adapter] Missing value for $1" >&2; exit 2; }
      WORK_DIR="$2"; shift 2 ;;
    --prompt-file)
      [ $# -ge 2 ] || { echo "ERROR: [oc-adapter] Missing value for $1" >&2; exit 2; }
      PROMPT_FILE="$2"; shift 2 ;;
    --temperature)
      [ $# -ge 2 ] || { echo "ERROR: [oc-adapter] Missing value for $1" >&2; exit 2; }
      TEMP="$2"; shift 2 ;;
    --seed)
      [ $# -ge 2 ] || { echo "ERROR: [oc-adapter] Missing value for $1" >&2; exit 2; }
      SEED="$2"; shift 2 ;;
    *)
      echo "ERROR: [oc-adapter] Unknown argument: $1" >&2
      exit 2 ;;
  esac
done

# 3. 校验必要参数、沙箱包含性与路径规范化 (防越界、防遍历、符号链接拒绝与工作区绑定)
if [ -z "$MODEL" ] || [ -z "$WORK_DIR" ] || [ -z "$PROMPT_FILE" ]; then
  echo "ERROR: [oc-adapter] Missing required arguments (--model, --dir, or --prompt-file)" >&2
  exit 2
fi

# (a) 检查原始 WORK_DIR 是否为符号链接（拒绝软链规避目录逃逸）
if [ -L "$WORK_DIR" ]; then
  echo "ERROR: [oc-adapter] WORK_DIR must not be a symlink: $WORK_DIR" >&2
  exit 2
fi

WORK_DIR="$(realpath -m "$WORK_DIR")"
if [ ! -d "$WORK_DIR" ]; then
  echo "ERROR: [oc-adapter] Target work directory does not exist: $WORK_DIR" >&2
  exit 2
fi

# (b) 前缀沙箱包含性检查：WORK_DIR 必须位于白名单根目录下 (默认 /tmp/，或经 TAD_ALLOWED_WORK_ROOT 显式配置)
ALLOWED_WORK_ROOT="${TAD_ALLOWED_WORK_ROOT:-/tmp}"
ALLOWED_WORK_ROOT="$(realpath -m "$ALLOWED_WORK_ROOT")"
if [[ "$WORK_DIR" != "$ALLOWED_WORK_ROOT"/* && "$WORK_DIR" != "$ALLOWED_WORK_ROOT" ]]; then
  echo "ERROR: [oc-adapter] WORK_DIR outside allowed root ($ALLOWED_WORK_ROOT): $WORK_DIR" >&2
  exit 2
fi

# (c) PROMPT_FILE 检查：拒绝符号链接，校验存在性与可读性
if [ -L "$PROMPT_FILE" ]; then
  echo "ERROR: [oc-adapter] PROMPT_FILE must not be a symlink: $PROMPT_FILE" >&2
  exit 2
fi

PROMPT_FILE="$(realpath -m "$PROMPT_FILE")"
if [ ! -f "$PROMPT_FILE" ] || [ ! -r "$PROMPT_FILE" ]; then
  echo "ERROR: [oc-adapter] Prompt file not found or unreadable: $PROMPT_FILE" >&2
  exit 2
fi

# (d) PROMPT_FILE 路径绑定：必须位于 WORK_DIR 或白名单根目录内，彻底防止任意系统文件越界读取
if [[ "$PROMPT_FILE" != "$WORK_DIR"/* && "$PROMPT_FILE" != "$ALLOWED_WORK_ROOT"/* ]]; then
  echo "ERROR: [oc-adapter] PROMPT_FILE must reside in WORK_DIR or allowed root: $PROMPT_FILE" >&2
  exit 2
fi

# 4. 诚实记录硬阻断超参数 (绝不向底层伪造注入未知参数)
if [ -n "$TEMP" ] || [ -n "$SEED" ]; then
  echo "NOTE: [oc-adapter] OpenCode CLI (v1.18.27) lacks native --temperature/--seed flags. Received temp='$TEMP', seed='$SEED'. Running with engine defaults." >&2
fi

# 5. 执行环境与非交互保障说明
# 正常运行时由 runner.mjs spawnOc 负责环境净化 (sanitizeEnv)；
# 若人工独立调试调用，请使用 env -i 运行并附加 timeout 300 超时保护：
# env -i PATH="$PATH" HOME="$HOME" TAD_OPENCODE_RAW_BIN="$TAD_OPENCODE_RAW_BIN" timeout 300 ./oc-adapter.sh ...
export TERM="${TERM:-dumb}"
export NO_COLOR=1

# 6. 执行 OpenCode CLI：
# 优先使用原生 -f 文件透传，避免 ARG_MAX 限制、换行截断与注入漏洞；锁定 --format default
# 若采用位置参数形式回退，必须加 -- 分隔符防止注入：
# exec "$OPENCODE_BIN" run --dir "$WORK_DIR" -m "$MODEL" --auto --format default -- "$PROMPT_CONTENT"
exec "$OPENCODE_BIN" run --dir "$WORK_DIR" -m "$MODEL" --auto --format default -f "$PROMPT_FILE"
```

### 4.3 数据与进程流向图
```
[runner.mjs]
   │
   ├─ 1. 净化环境变量 (sanitizeEnv: 白名单放行 TAD_OPENCODE_BIN 与 TAD_OPENCODE_RAW_BIN)
   ├─ 2. 组装参数 (Leg 1: run --model <id> --dir <tmp> --prompt-file <prompt> --temperature 0 --seed 42)
   ├─ 3. spawn 子进程调用 [experiments/thin-tad-pilot/oc-adapter.sh]
           │
           ├─ 4. oc-adapter.sh 校验参数边界 ([ $# -ge 2 ])，未知参数 exit 2
           ├─ 5. realpath 规范化 WORK_DIR 与 PROMPT_FILE；执行软链拒绝、/tmp/ 前缀沙箱包含性与路径绑定校验
           ├─ 6. 校验 OpenCode 二进制可执行状态 (TAD_OPENCODE_RAW_BIN, 缺二进制 exit 127)
           ├─ 7. 诚实吸收/记录 temperature 与 seed，向 stderr 打印 NOTE: [oc-adapter]
           └─ 8. exec 调用真实 OpenCode (Leg 2: 原生合规参数)
                   "$OPENCODE_BIN" run --dir "$WORK_DIR" -m "$MODEL" --auto --format default -f "$PROMPT_FILE"
                   │
                   ▼
         [OpenCode CLI 执行模型交互]
                   │
                   ▼ (流式捕获 stdout / stderr，硬限 50MB)
   [runner.mjs 进程管理]
   │
   ├─ 9. 进程组超时守护 (TIMEOUT_MS = 300,000 ms, 优雅终止进程树)
   ├─ 10. 映射退出码与结果分类 (见 §4.4 状态映射表)
   ├─ 11. 提取原始 Token 统计与耗时 (严禁法币折算)
   └─ 12. 写入 run.json 或 probe-report.json
```

### 4.4 退出码与状态组合映射表

| 适配器 / 进程事件 | OpenCode 原生表现 | Runner 判定分类 (`outcome.code`) | 是否允许消耗 Infra 重试 | 处置规则与说明 |
|---|---|---|---|---|
| **适配器 exit 127** | 无法启动底层 OpenCode | `FAILED_INFRA` | ❌ 否（致命环境故障） | 二进制缺失或路径配置错误，探针直接 fail-closed，运行立即终止。 |
| **适配器 exit 2** | 入参缺失/非法/未知旗标/文件缺失/软链违规/工作区或提示词越界 | `FAILED_HARNESS_USAGE` | ❌ 否（确定性契约错误） | 契约、参数与沙箱越界错误为确定性失败，重试必然失败，严禁消耗 2 次 infra 重试预算。 |
| **超时 (TIMEOUT_MS = 300s)** | 进程组被 SIGTERM/SIGKILL 终止 | `ETIMEDOUT` | ⚠️ 是（至多 1 次/臂） | 触发进程树清理，记录 300,000ms 超时，单臂最多重试 1 次。 |
| **底座正常 exit 0** | 输出有效模型产物与退出码 0 | `COMPLETED` | ❌ 否 | 正常完成，进入 Oracle 与 diff 评估流程。 |
| **底座非零退出 (exit > 0)** | 输出错误信息到 stderr/stdout | `FAILED_MODEL` 或 `FAILED_INFRA` | 视特征而定 | 若匹配 `INFRA_PATTERNS`（如网络断开/EOF）则允许重试；否则裁定为模型执行异常，不重试。 |

---

## 5. 强制问题回答（MQ1 – MQ6）

| 编号 | 核心问题 | 答案与实测证据 |
|---|---|---|
| **MQ1: 历史方案复用** | 是否搜索了现有方案？为什么决定新建适配器？ | 检索了 `/home/box/pm/bin/oc-run.sh`、`experiments/thin-tad-pilot/runner.mjs` 以及 Infra 的 `pm/archive/2026-09-08-infra-tad-opencode-bin-absent.md`。结论：外部 PM 脚本带有路径污染且无相关旗标，裸 `opencode` 缺旗标。决定不造系统级假 shim，而是在仓内 `experiments/` 构建透明适配脚本，并让 `runner.mjs` 规范对接。 |
| **MQ2: 函数与组件存在性** | 调用的关键命令与接口是否存在？ | 1. `/home/box/.opencode/bin/opencode` 存在且权限为 0755（ELF 64-bit，v1.18.27）；<br>2. `runner.mjs` 中的 `spawnOc`、`buildOcArgv`、`sanitizeEnv` 原型均存在；<br>3. `node:child_process.spawn` 与 bash 标准内置命令均经实测验证。 |
| **MQ3: 数据流完整性** | 参数与结果如何在模块间传递？ | Case 任务定义 → 临时独立工作区 → `runner.mjs` 写入临时 prompt 文件 → 仓内 `oc-adapter.sh` 解析并读取内容 → `opencode run` 接收参数在工作区运行 → 生成产物落盘在临时工作区 → 遥测输出由 Runner 捕获并解析。数据流单向封闭，不经由任何共享全局目录。 |
| **MQ4: 状态与异常区分** | 如何区分探针失败、语法失败与模型失败？ | 适配器明确退出码：二进制未找到返回 127；入参校验错误返回 2；底层运行错误透传 OpenCode 退出码。Runner 区分：`SPAWN_FAILED`、`ETIMEDOUT`、`FAILED_INFRA`（如网络断开/崩溃）与 `FAILED_MODEL`（模型给出非零退出或非法产物），状态正交清晰。 |
| **MQ5: 状态同步与隔离** | 如何保证测试环境不被脏状态污染？ | 每个 Run 在 `/tmp/thin-tad-p2-...` 建立随机独立临时目录；环境变量经 `ENV_ALLOW` 白名单严格过滤；探针 Tier 2 负控硬性检验工作区无法读取 `approved.json`、`SOURCE-MAP.md` 及同级跨项目目录；无跨会话共享状态。 |
| **MQ6: 技术决策调研** | 为什么不在系统中制作名为 `oc-run` 的软链？ | 调研了 3 种方案：<br>1. *在系统加软链指向 PM oc-run.sh*：❌ 绝对违规，引入外部脏逻辑，破坏实验归因；<br>2. *修改 Infra 部署假冒 oc-run 二进制*：❌ 违背科学诚实，Infra 已判定无真实二进制可提供；<br>3. *仓内建立透明适配器并在文档中直陈硬阻断*：✅ **唯一合规方案**。适配逻辑归本实验所有，开源可审计，完全隔离。 |

---

## 6. 重开 Live 24-Run 准入核对清单 (PREREQ Checklist)

在任何实际模型运行被启动之前，**必须逐项核对并完全满足**以下清单（所有检查项必须有真实的命令输出支撑，缺一不可启动）：

- [ ] **`PREREQ-AUTH: HUMAN_MANDATE`**
  - **要求**：必须获得人类用户在独立终端或明确对话中给出的显式授权指令（例如：“我授权重开 24 次 live 模型测试”）。
  - **判定**：无显式人类授权，任何模型运行均为违规；本项是执行包含 PREREQ-1 冒烟测试在内的任何实际模型调用的硬性前置门槛。

- [ ] **`PREREQ-1: IN_REPO_HARNESS_CERTIFICATION`**
  - **要求**：
    1. 离线环境断言：仓内适配器 `experiments/thin-tad-pilot/oc-adapter.sh` 存在且可执行（mode 0755）；底层 `/home/box/.opencode/bin/opencode` 存在且版本确认为 `>= 1.18.0`；
    2. 通道冒烟测试：仅在满足 `PREREQ-AUTH` 授权后执行，使用真实的临时文件测试单次通道连通性，计入单次调用监控（包含在 24+2 预算管控内）。
  - **验证命令**：
    - 步骤 1（离线）：`test -x experiments/thin-tad-pilot/oc-adapter.sh && test -x /home/box/.opencode/bin/opencode && /home/box/.opencode/bin/opencode --version`（断言输出版本 >= 1.18.0）；
    - 步骤 2（通道，授权后）：`P=$(mktemp /tmp/prereq-prompt.XXXXXX); echo ping >"$P"; experiments/thin-tad-pilot/oc-adapter.sh run --model opencode-go/muse-spark-1.3-contributor --dir /tmp --prompt-file "$P"; rc=$?; rm -f "$P"; test $rc -eq 0`。

- [ ] **`PREREQ-2: PROBE_DUAL_CONTROL_PASS`**
  - **要求**：运行 `node experiments/thin-tad-pilot/runner.mjs probe` 取得 **`probe_passed: true`** 与 **`adapter_eligible: true`**。
  - **具体断言**：
    - Tier 1：环境变量无 `PILOT_*` 或敏感密钥泄露，临时工作区无软链回指主仓库；
    - Tier 2 负控：被测环境绝对无法读取 `approved.json`、`SOURCE-MAP.md` 及同级仓库文件；
    - Tier 2 正控：被测环境可在分配的临时工作区中正常写入并读取 canary 金丝雀文件。
  - **验证命令**：`node experiments/thin-tad-pilot/runner.mjs probe`（断言输出 exit 0 且包含 probe_passed: true）。

- [ ] **`PREREQ-3: HYPERPARAMETER_AND_VARIANCE_DISCLOSURE`**
  - **要求**：在 `.tad/evidence/experiments/thin-tad-pilot/harness-contract-audit.md` 中完整披露 OpenCode v1.18.27 无法在 CLI 固定 `--temperature` 与 `--seed` 的限制，并获得人类确认接受默认采样方差风险。
  - **判定**：严禁宣称“已锁定 temperature: 0”，必须诚实标注“运行于默认采样策略下”。
  - **验证命令**：`grep -E '默认采样策略|NOTE: \[oc-adapter\]' .tad/evidence/experiments/thin-tad-pilot/harness-contract-audit.md`。

- [ ] **`PREREQ-4: BASELINE_13_FIDELITY`**
  - **要求**：基线双臂加载校验通过，13 个规则文件与 `arms/baseline.json` 中的 SHA-256 达成 100% 字节一致，无文件截断（`fidelity.arms_verified: true`）。
  - **验证命令**：`node -e 'import("./experiments/thin-tad-pilot/runner.mjs").then(async m => { const r = await m.verifyArmsFidelity(); console.log(JSON.stringify(r)); if(!r.ok) process.exit(1); })'`。

- [ ] **`PREREQ-5: BUDGET_AND_CIRCUIT_BREAKER_ACTIVE`**
  - **要求**：矩阵上限硬性锁定为 24 次计划运行 + 至多 2 次基础设施级重试（总调用上限 26 次，第 27 次必熔断）；连续 3 次基础设施故障触发全局熔断；只记录 raw tokens 与耗时，严禁 USD 换算。
  - **验证命令**：`grep -E 'MAX_INVOCATIONS = 26|MAX_TOTAL_INFRA_RETRIES = 2|CONSECUTIVE_INFRA_ABORT = 3' experiments/thin-tad-pilot/runner.mjs && node -e 'import("./experiments/thin-tad-pilot/runner.mjs").then(m => { if(m.MAX_INVOCATIONS!==26||m.MAX_TOTAL_INFRA_RETRIES!==2||m.CONSECUTIVE_INFRA_ABORT!==3) process.exit(1); console.log("Budget constants verified."); })'`。

- [ ] **`PREREQ-6: PRE_REGISTERED_EVAL_BOUNDS`**
  - **要求**：H 校准集（6 例）与 V 留出集（6 例）严格分表呈现，严禁合并计算总胜负比；承认 n=12 仅为探索性样本，不作为架构级优胜劣汰的统计显著性结论。
  - **验证命令**：`node -e 'import("./experiments/thin-tad-pilot/runner.mjs").then(m => { console.log("H:", m.H_CASES.length, "V:", m.V_CASES.length); if(m.H_CASES.length!==6||m.V_CASES.length!==6) process.exit(1); })'`。

---

## 7. Acceptance Criteria (AC0 – AC8)

| AC 编号 | 验收项 | 验证命令 / 检验方式 | 预期证据与合格标准 |
|---|---|---|---|
| **AC0** | 仓内适配器就绪性 | `test -x experiments/thin-tad-pilot/oc-adapter.sh` | 脚本存在、具备执行权限（0755），语法检查 `bash -n experiments/thin-tad-pilot/oc-adapter.sh` 退出码为 0。 |
| **AC1** | 参数解析、边界防护与契约映射 (含 F07 沙箱强化) | 单元测试中验证适配器能正确解析 `--model`、`--dir`、`--prompt-file`，并将 prompt 内容优先通过 `-f` 传入底座；验证目录前缀包含、软链拒绝与文件绑定防护。 | 缺失必要参数（如 `--model` 无参或缺失 `--dir`、`--prompt-file`）时退出码为 2；未知旗标退出码为 2；传入不存在的工作区或不存在的 prompt 文件时退出码为 2；传入符号链接 WORK_DIR 或 PROMPT_FILE 退出码为 2；WORK_DIR 位于 /tmp/ 外或 PROMPT_FILE 越界未绑定在合法工作区/根目录退出码为 2；在 `set -u`/`set -e` 下边界防护完善，无死循环或未捕获异常。 |
| **AC2** | 诚实处理超参数与硬阻断 | 检查 `oc-adapter.sh` 源码与执行日志：`grep -F 'NOTE: [oc-adapter]' experiments/thin-tad-pilot/oc-adapter.sh` | 明确对 temperature/seed 进行无害吸收并打印诚实警告注记，绝不伪造向 OpenCode 注入不存在的旗标；调用 OpenCode 时包含原生 `-f` 挂载及 `--format default`。 |
| **AC3** | Runner 默认指向仓内适配器与零外部 Shim | 检查 `runner.mjs` 中的 `ocBin()` 默认值与 `ENV_ALLOW`；`! grep -ri 'oc-run\.sh' experiments/thin-tad-pilot/` | `ocBin()` 默认值从 `'oc-run'` 强制更新为 `'experiments/thin-tad-pilot/oc-adapter.sh'`；`ENV_ALLOW` 与 `envLeakCheck` 同时放行 `TAD_OPENCODE_BIN` 与 `TAD_OPENCODE_RAW_BIN`；代码中绝无任何硬编码指向 `/home/box/pm/` 的外借路径。 |
| **AC4** | 适配器离线 Mock 保护与用例扩充 | `node --test experiments/thin-tad-pilot/runner.test.mjs` | 单测套件 100% 通过（测试数 >= 33，在基线 25 个通过基础上新增 >= 8 个）；必须包含以下 10 类命名 Mock 测试：<br>1. `adapter translates prompt-file to -f flag`<br>2. `adapter fails closed exit 2 on missing required args`<br>3. `adapter fails closed exit 2 on missing value for flag`<br>4. `adapter fails closed exit 2 on unknown flags`<br>5. `adapter absorbs temperature and seed with NOTE to stderr`<br>6. `adapter propagates nonzero opencode exit code and exit 127 accurately`<br>7. `adapter flag-injection immunity with leading dash prompt content`<br>8. `adapter fails closed exit 2 on symlinked workdir or prompt file`<br>9. `adapter fails closed exit 2 on workdir outside allowed root`<br>10. `adapter fails closed exit 2 on prompt-file outside workdir and root` |
| **AC5** | 探针逻辑兼容性与行为断言 (可执行验证) | `node --check experiments/thin-tad-pilot/runner.mjs && node -e 'import("./experiments/thin-tad-pilot/runner.mjs").then(async m => { const argv = m.buildOcArgv({ workDir: "/tmp/w", extraPrompt: "/tmp/p" }); if (!argv.includes("--prompt-file") || !argv.includes("--dir") || !argv.includes("--temperature") || !argv.includes("--seed")) process.exit(1); const { report } = await m.probeIsolation(); if (typeof report.probe_passed !== "boolean") process.exit(1); console.log("AC5 probe & buildOcArgv assertions passed"); })'` | Runner 语法检查通过；验证命令单元格具备可执行断言：断言 `buildOcArgv` 产出完整符合 Leg 1 契约（包含 `--model`、`--dir`、`--prompt-file`、`--temperature`、`--seed` 用于适配器透明捕获）；断言探针导出报告包含 `probe_passed` 布尔判定；在缺少底座或负控失败时诚实 fail-closed（报 `ADAPTER_INELIGIBLE`）。 |
| **AC6** | 契约审计与 PREREQ 报告落盘结构化 | 检查 `.tad/evidence/experiments/thin-tad-pilot/harness-contract-audit.md` 存在性与实质内容 | 文档详尽记录 OpenCode CLI 参数与原 Runner 假定的完整对比表、硬阻断（temperature/seed 不支持）科学归因、§6 完整的 6 项 PREREQ 清单（全量包含可直接运行的验证命令）以及 OpenCode v1.18.27 真实版本核对证据。 |
| **AC7** | 零法币与零伪造数据（修正版） | `! grep -riE '\b(usd|dollars?|cents)\b' .tad/evidence/experiments/thin-tad-pilot/harness-contract-audit.md` | 审计文档全程零法币词汇（词边界匹配，严禁 bare currency tokens）；豁免 `oc-adapter.sh` 脚本内合法的 shell 变量 `$VAR` 与 `$(...)` 语法；本单未生成任何伪造的 24-run 运行记录。 |
| **AC8** | 生产零侵入与快照差围栏可执行化 | Blake 实现前捕获基线快照：<br>`git status --porcelain=v1 --untracked-files=all \| sort > /tmp/thin-tad-baseline.status`<br>实现后对比：<br>`git status --porcelain=v1 --untracked-files=all \| sort > /tmp/thin-tad-current.status && comm -13 /tmp/thin-tad-baseline.status /tmp/thin-tad-current.status` | 变动严格限定在 §3.1 权威写入白名单内；`.agents/`、`.claude/`、`.tad/hooks/` 零新增修改。 |

---

## 8. Friction Preflight

| 潜在摩擦点 | 预防与解决措施 | 状态判定 |
|---|---|---|
| **OpenCode 二进制权限** | 此前曾发生 0644 导致 exit 126。Blake 启动前需验证：`test -x /home/box/.opencode/bin/opencode`。 | READY（经 Infra 修复，当前为 0755） |
| **适配器执行位** | 新建的 `oc-adapter.sh` 必须显式执行 `chmod +x`。 | 纳为 AC0 核心验收项 |
| **OpenCode 非交互挂起** | `opencode run` 遇到未明确授权的目录可能弹出 TUI 权限提示导致死锁。适配器必须强制附加 `--auto` 旗标。 | 架构 §4.2 已设计吸收 |
| **临时工作区跨目录权限** | OpenCode 默认配置已授权 `/tmp/**` 与 `/home/box/**`。 | READY（已由 `.config/opencode/opencode.json` 覆盖） |
| **缺乏外部 oc-run** | 不应视为阻塞：本单正是通过构建仓内适配器来系统性解决此问题。 | 按设计吸收 |

---

## 9. Layer 2 Expert Review & Handover Protocol

### 9.1 Layer 2 专家审查规程（OpenCode 独立会话）
在 Blake 完成实现后，必须在 OpenCode 独立会话中派发两名专家审查，且两名专家均给出 PASS 后方可进入 Gate 3：
1. **AI 评测方法学专家 (AI Evaluation Specialist)**：
   - 审查重点：评测适配器是否保证了实验的可比性与公允性？对 temperature/seed 缺失的披露是否真实严谨？PREREQ 清单是否具备足够把关能力？
   - 载体路径：`.tad/evidence/reviews/alex/thin-tad-harness-adapter/eval-review.md`
2. **代码质量与安全架构专家 (Code Reviewer & Security Lead)**：
   - 审查重点：`oc-adapter.sh` 与 `runner.mjs` 的进程调用是否存在 Shell 注入风险？环境变量净化是否彻底？错误与退出码传播是否精准？
   - 载体路径：`.tad/evidence/reviews/alex/thin-tad-harness-adapter/code-review.md`

### 9.2 Gate 3 强制执行与 F07 阻断验收法则 (Gate 3 Enforcement Mandate & Rationale)

在 Gate 3 验证中，F07（目录前缀沙箱包含性、软链硬性拒绝与提示词路径绑定）属于**硬性阻断检查点**，其安全归因与机械验收规则如下：
1. **安全与隔离归因 (Security & Containment Rationale)**：
   - OpenCode CLI 在批处理运行时必须附加 `--auto` 旗标以防非交互死锁，这意味着底层进程对指定工作区拥有免确认的文件读写与执行权限。
   - 若适配器不强制工作目录前缀限制（`/tmp/` 根目录）、不拒绝符号链接穿透、不对 `PROMPT_FILE` 施加工作区或临时根目录路径绑定，外部调用者或潜在异常测试输入可能通过构造符号链接或绝对路径越界读取主仓库敏感文件（如 `.tad/evidence/.../approved.json`、`SOURCE-MAP.md`）或主机私有凭据。
   - 因此，适配器必须在调用底层 OpenCode 前设立三道独立防线：(a) 软链拒绝（`[ -L ]` exit 2）；(b) 工作区前缀白名单检查（默认 `/tmp`，或受 `TAD_ALLOWED_WORK_ROOT` 控制）；(c) 提示词路径绑定（必须位于工作区或受控允许根目录内）。
2. **Gate 3 机械验收标准 (Failing-before / Passing-after)**：
   - Blake 必须在 `runner.test.mjs` 中实现针对上述三道防线的独立单测（即 AC4 规定的测试用例 8、9、10）；
   - Gate 3 评审员必须执行单测并确认：遇到软链工作区、越界工作区（如 `/etc` 或主仓库根目录）以及越界 prompt 文件时，适配器均准确返回退出码 2 并拦截调用；
   - 探针 Tier 2 负控必须真实运行并断言被测环境无法越界读取主仓库受限文件。

### 9.3 人类审阅人话版（Plain Language Summary）

> **给人类的说明**：
> 此前 P2 评测在实际启动时被探针拦截（`ADAPTER_INELIGIBLE`），因为我们的测试驱动脚本在寻找一个叫 `oc-run` 的假想命令，并试图向它传递 `--temperature 0` 和 `--seed 42` 这类参数；然而本机上实际安装的是真实的 `opencode` 命令行（v1.18.27），它根本没有这些命令行旗标。同时，我们明确拒绝了征用外部 PM 脚本或制作假冒包装的做法，因为那属于伪造评测。
> 
> 这张新 Handoff（`TASK-20260908-thin-tad-harness-adapter`）为 Blake 规划了合规的工程适配方案：在仓库自身内部（`experiments/thin-tad-pilot/`）编写一个透明、诚实的适配器脚本，把真实的 OpenCode 命令行接入测试套件，如实记录参数限制，补充离线单测，并形成完整的未来重开核对清单。
> 
> 本单是纯粹的工程适配与架构对齐，**绝不进行真实模型调用，绝不伪造数据，绝不修改生产 TAD 核心规则**。

---

## 10. Message to Blake (📨 Structured Task Dispatch)

```markdown
📨 **Task Dispatch to Blake (Execution Master)**

- **Task ID**: TASK-20260908-thin-tad-harness-adapter
- **Handoff Document**: `.tad/active/handoffs/HANDOFF-20260908-thin-tad-harness-adapter.md` (v1.3, Gate2-PASS)
- **Priority**: P1
- **Scope & Allowlist**:
  - `experiments/thin-tad-pilot/oc-adapter.sh` (NEW, executable)
  - `experiments/thin-tad-pilot/runner.mjs` (MODIFY, adapter wiring)
  - `experiments/thin-tad-pilot/runner.test.mjs` (MODIFY, mock tests)
  - `experiments/thin-tad-pilot/README.md` (MODIFY, usage docs)
  - `.tad/evidence/experiments/thin-tad-pilot/harness-contract-audit.md` (NEW, audit & PREREQ checklist)
  - `.tad/active/handoffs/COMPLETION-20260908-thin-tad-harness-adapter.md` (NEW, completion report)
  - `.tad/evidence/reviews/alex/thin-tad-harness-adapter/**` (NEW, review carriers)
- **Hard Prohibitions**:
  - ❌ 禁止在 `/home/box/pm/` 或系统 PATH 中制作假冒 shim
  - ❌ 禁止伪称 OpenCode CLI 支持 temperature/seed 旗标（必须诚实记录硬阻断）
  - ❌ 禁止实际运行 24-run 模型调用（本单不产生真实模型费用）
  - ❌ 禁止引入任何法币词汇（限定词边界 `\b(usd|dollars?|cents)\b`，货币语义 `$` 等；shell 变量 `$VAR` 语法完全豁免）
  - ❌ 禁止修改生产 TAD 架构（`.agents/`, `.claude/`, `.tad/hooks/`）
- **Immediate Next Step**:
  请在终端中仔细阅读本 Handoff，并在 Blake 终端自述理解（回答 §1.3 的 4 个问题）。在 Human 确认理解后，由 OpenCode 执行 Gate 2 双专家审查，通过后启动实现！
```

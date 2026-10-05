# Blake §1.3 Four-Question Understanding Check (TASK-20260908-thin-tad-harness-adapter)

**Author:** Blake (Execution Master)
**Date:** 2026-09-08
**Handoff:** `.tad/active/handoffs/HANDOFF-20260908-thin-tad-harness-adapter.md` v1.3 Gate2-PASS
**Human standing auth:** 完成测试
**Purpose:** Step1 pre-implementation understanding record. This file contains ONLY understanding answers — no implementation code.
**Carrier note:** Placed under `.tad/evidence/reviews/alex/thin-tad-harness-adapter/` to stay inside handoff §3.1 allowlist item 7 (`**` wildcard). It is a pre-implementation gate record, not a Layer 2 review.

**Grounding (verified 2026-09-08 on live host):**
- `which oc-run` → rc=1 (absent)
- `test -x /home/box/.opencode/bin/opencode` → yes; `--version` → `1.18.27`
- `opencode run --help` → accepts `[message..]`, `-m/--model`, `--dir`, `--format`, `-f/--file`, `--pure`, `--auto`; no `--temperature`, no `--seed`, no `--prompt-file`

---

## Q1. 为什么此前 P2 会被判为 ADAPTER_INELIGIBLE？本机上真实的 OpenCode 二进制位于哪里，它缺失了原 runner 期望的哪三个旗标？

P2 的 `runner.mjs` 假定系统 PATH 上存在一个独立 `oc-run` 二进制，并向它传递 `run --model <id> --dir <workDir> --prompt-file <path> --temperature 0 --seed 42`。实测 `which oc-run` 退出码为 1，根本不存在，启动探针 fail-closed（exit 1），正式裁定 `ADAPTER_INELIGIBLE`，且未编造任何 `manifest.json` / `pair-summary.json` / `run.json`。

本机真实二进制是 `/home/box/.opencode/bin/opencode`（OpenCode Go v1.18.27，0755）。`opencode run --help` 证实它缺失原 runner 期望的三个旗标：`--temperature`、`--seed`、`--prompt-file`。若把旧 argv 直传给 `opencode run` 会直接报未知参数错误。原生替代是 `-f/--file`（提示词文件）与 message 位置参数，但温度/种子在该版本无任何 CLI 对应项。

## Q2. 为什么严禁使用 /home/box/pm/bin/oc-run.sh 或在系统目录下建立假 shim？新适配器应该放在仓库的哪个目录下？

`/home/box/pm/bin/oc-run.sh` 是 `grok-cloud` 组合项目的运维包装脚本（进程账本记录与 Webhook 叫醒），内部同样没有 `--temperature`/`--seed` 处理，且硬编码项目路径（如 `/home/box/云同步/grok-cloud`），未经本任务单授权。征用它会引入外部脏逻辑、破坏实验归因；在系统 PATH 或 `/home/box/pm/` 下自制名为 `oc-run` 的软链/fake shim 并伪装支持温度/种子旗标，属于伪造运行（Forged Runs），Infra 与 TAD 已明令拒绝。

唯一合规方案是仓内透明适配器：`experiments/thin-tad-pilot/oc-adapter.sh`（或 `.mjs`，0755），归本实验所有、受版本控制、可审计，与外部 PM 脚本和系统级伪造彻底隔离。Runner 经 `TAD_OPENCODE_BIN`（默认指向该仓内相对路径）挂接它。

## Q3. 对于 OpenCode 缺乏 --temperature 与 --seed 旗标这一事实，适配器和审计文档应该如何处理？

严禁伪装支持，必须诚实阻断/记录：

- 两段协议：Leg-1（Runner→Adapter）保留 `--temperature 0 --seed 42 --prompt-file` 输入契约以便适配器透明捕获；Leg-2（Adapter→OpenCode）只发射真实原生参数 `run --dir "$WORK_DIR" -m "$MODEL" --auto --format default -f "$PROMPT_FILE"`，坚决不向底层注入不存在的旗标。
- 适配器捕获到 `TEMP`/`SEED` 非空时向 stderr 打印 `NOTE: [oc-adapter]` 注记（说明 v1.18.27 无原生旗标、按引擎默认采样运行），调用行锁定 `--format default` 与 `--auto`（防 TUI 死锁），提示词优先 `-f` 原生文件透传。
- 审计文档（`harness-contract-audit.md`）与 PREREQ-3 必须如实披露该硬阻断、默认采样方差影响，严禁宣称"已锁定 temperature: 0"，须获人类接受方差风险后方可谈重开。

## Q4. 本单是否允许实际运行 24 次模型调用？本单允许修改生产 TAD 目录（.agents/、.claude/）吗？

两者皆否：

- 本单是适配器工程单（Harness Alignment Track），不是实验执行单。§6 PREREQ 明令：无 `PREREQ-AUTH` 人类显式授权，任何模型调用（含 PREREQ-1 步骤 2 通道冒烟）均为违规；全部 6 项 PREREQ 验证满足前严禁偷跑真实 24-run。本单不产生真实模型费用，不生成 24-run 记录。
- 生产 TAD 零触碰：严禁修改 `.agents/`、`.claude/`、`.tad/hooks/`、`.tad/config.yaml` 及 P1 冻结数据（`cases/`、`arms/`、`oracles/`）。全部写入限定 §3.1 白名单 7 路径；法币词按 `\b(usd|dollars?|cents)\b` 与货币语义 `$` 禁用（shell `$VAR` / `$(...)` 豁免）。

---

## Consistency self-check (for Step2 gating)

- RAW_BIN vs BIN split: `TAD_OPENCODE_BIN`（Runner→仓内适配器）vs `TAD_OPENCODE_RAW_BIN`（适配器→真实 opencode，默认 `/home/box/.opencode/bin/opencode`），`ENV_ALLOW` + `envLeakCheck` 同时放行两者 — 与 handoff §3.2 一致。
- In-repo adapter only: `experiments/thin-tad-pilot/oc-adapter.sh` — 与 handoff §1.3/§4.2 一致。
- No PM oc-run.sh subject: 拒绝征用 `/home/box/pm/bin/oc-run.sh`，代码零硬编码 `/home/box/pm/` — 与 handoff 事实 C 一致。
- No forged runs: 本单零真实模型调用，探针缺席时 fail-closed `ADAPTER_INELIGIBLE` — 与 P2/P3 诚实裁决一致。

**Verdict:** CONSISTENT — 请求进入 Step2 Gate3 实现（待 Human 确认本理解后执行；本文件不含任何实现）。

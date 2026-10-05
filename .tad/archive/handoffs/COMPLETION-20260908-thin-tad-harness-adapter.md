---
task_id: TASK-20260908-thin-tad-harness-adapter
handoff: .tad/active/handoffs/HANDOFF-20260908-thin-tad-harness-adapter.md
gate3_verdict: pass
commit_hash: d23f78ab
date: 2026-09-08
epic: EPIC-20260907-thin-tad-evaluation.md (Harness Alignment Track)
---

# COMPLETION: thin-tad 评测适配器与 OpenCode 二进制契约对齐 (TASK-20260908-thin-tad-harness-adapter)

**From:** Blake (Execution Master)
**To:** Alex (Solution Lead) / Human
**Status:** Gate 3 PASS (Layer 1: 40/40; Layer 2 R2 dual PASS after R1 FAIL/CONDITIONAL fix loop)
**Commit:** `d23f78ab` (4 files, +1759; adapter mode 100755)
**Live model calls in this order:** 0. Forged runs: 0. Production TAD edits: 0.

---

## 0. Step1 理解门（Human standing auth: 完成测试）
- §1.3 四问理解已先行落盘：`.tad/evidence/reviews/alex/thin-tad-harness-adapter/blake-understanding-check.md`（纯理解、无实现；live host 实测接地：`which oc-run` rc=1、opencode v1.18.27、`run --help` 无三旗标）。
- 一致性自检：RAW_BIN vs BIN 双层分立 / 仓内适配器唯一 / 拒绝 PM 脚本与假 shim / 零伪造 — 四项与 handoff 一致 → 进入 Step2 Gate3 实现。

## 1. File Manifest（§3.1 白名单内 Creeated/Modified）

| # | File | Op | sha256 (short) | Provenance |
|---|---|---|---|---|
| 1 | `experiments/thin-tad-pilot/oc-adapter.sh` | CREATE, 0755 | `7a452c5f` | direct, handoff §4.2 spec + Layer2 R2 hardenings |
| 2 | `experiments/thin-tad-pilot/runner.mjs` | MODIFY (was untracked P2 legacy) | `4fb6d077` | direct |
| 3 | `experiments/thin-tad-pilot/runner.test.mjs` | MODIFY (was untracked P2 legacy) | `3aa1f46a` | direct |
| 4 | `experiments/thin-tad-pilot/README.md` | MODIFY (tracked) | `5ab8cc6a` | direct |
| 5 | `.tad/evidence/experiments/thin-tad-pilot/harness-contract-audit.md` | CREATE (gitignored) | `e9abab2b` | direct |
| 6 | `.tad/active/handoffs/COMPLETION-20260908-thin-tad-harness-adapter.md` | CREATE (this file, working tree) | — | direct |
| 7 | `.tad/evidence/reviews/alex/thin-tad-harness-adapter/blake-understanding-check.md` + 4× `*-blake-gate3-r{1,2}.md` | CREATE (gitignored; allowlist item 7 `**`) | — | direct + subagent transcription |

注：Layer 2 载体置于 `reviews/alex/...` 而非默认 `reviews/blake/...`，因 handoff §3.1 白名单仅授权前者；文件名以 `blake-gate3-` 前缀与 Gate 2 的 `eval-review.md` / `code-review.md` 区分。

## 2. What was done（vs handoff §1.1 四项交付）
1. **仓内适配器** `oc-adapter.sh`：双层变量（RAW_BIN 默认真实二进制）、`[ $# -ge 2 ]` 边界守卫、未知参数 exit 2、`-f` 原生透传、温度/种子诚实 NOTE（绝不 downstream 注入）、软链拒绝 + `realpath -m` + `/tmp` 前缀包含 + prompt 绑定、exit 127/2/透传映射。R2 加固：PATH-fallback 重检 + resolved NOTE、双 trailing-slash 剥离、127-vs-2 优先级注释、`NO_COLOR` 默认模式（行为与经 runner 时一致）。
2. **Runner 接线**：`ocBin()` 默认→仓内适配器相对路径；`ENV_ALLOW` + `envLeakCheck` 放行 `TAD_OPENCODE_BIN` / `TAD_OPENCODE_RAW_BIN` / `TAD_ALLOWED_WORK_ROOT`；`buildOcArgv` 缺 prompt 即抛 `illegal_argument`；`executeArm` 经 `writeLeg1PromptFile` 物化 `PROMPT.md` 并传入；`classifyOutcome` 新增 `FAILED_HARNESS_USAGE`（exit 2 + `[oc-adapter]` 标记先行判定），`executeArm` 对其零重试、零 infra 预算、断连续 infra 计数；新增 `verifyArmsFidelity()` 供 PREREQ-4 可执行断言；`defaultHarnessReader` 解析仓内相对路径并要求可执行位。
3. **单测 25→40**：10 个 AC4 逐字命名适配器 Mock 用例 + `buildOcArgv` Leg-1 断言 + fail-fast + exit-2 映射 + **真实适配器集成测试**（`executeArm` 默认 `spawnOc` → 真 adapter → mock raw 输出遥测 JSON → `COMPLETED`）。
4. **审计与 PREREQ**：`harness-contract-audit.md` 含版本实测证据、全量对比表、硬阻断归因、exit 映射表、6 项 PREREQ 可执行命令、边界声明；PREREQ-2 诚实标注 live OPEN（见 §5）。

## 3. Acceptance Verification（逐条，全部执行）

| AC | 结果 | 证据命令 / 输出 |
|---|---|---|
| AC0 适配器就绪 | PASS | `test -x …/oc-adapter.sh` + `bash -n` rc=0 + mode 755（commit 保持 100755） |
| AC1 解析/边界/映射+F07 | PASS | 10 Mock 用例覆盖缺参/缺值/未知旗标/坏路径/软链/越界绑定；trailing-slash 加固 |
| AC2 诚实超参数 | PASS | `grep -F 'NOTE: [oc-adapter]' oc-adapter.sh` 命中；下游 `ARG:--temperature/--seed` 缺席断言 |
| AC3 默认指向+零外部 | PASS | `ocBin()` 默认仓内路径；双层+ROOT 三变量放行；`! grep -ri 'oc-run\.sh' experiments/thin-tad-pilot/` 通过；blast-radius grep 零外部消费者 |
| AC4 Mock 保护≥33 | PASS | `node --test`: **40/40/0**（基线 25 + 新增 15；10 个 AC4 命名逐字匹配） |
| AC5 探针+行为断言 | PASS | handoff 原文命令 → `AC5 probe & buildOcArgv assertions passed`（含 `--prompt-file/--dir/--temperature/--seed` + `probe_passed` 布尔） |
| AC6 审计落盘结构化 | PASS | 审计含对比表 + 硬阻断归因 + 6 项 PREREQ 可执行命令 + v1.18.27 版本证据 |
| AC7 零法币零伪造 | PASS | `! grep -riE '\b(usd\|dollars?\|cents)\b' …/harness-contract-audit.md` 通过；本单 0 运行记录 |
| AC8 生产零侵入围栏 | PASS | `/tmp/thin-tad-baseline.status`→current diff 唯一增量 `?? oc-adapter.sh`；表内文件 sha 见 §1；`.agents/.claude/hooks` 脏项 100 percent 预存于 baseline（52 agents/skills 行），非本单写入 |

## 4. Layer 1 / Layer 2
- **Layer 1：** `bash -n` / `node --check` ×2 / `node --test` 40/40；探针 live `probe_passed:false` 系诚实 fail-closed（positive 委托，零花费），非失败。
- **Layer 2 R1：** eval FAIL（P0 prompt 缺失、P0 PREREQ-2 不可满足式、P1 README 措辞、P2 AC8）+ code CONDITIONAL（P0 HARNESS_USAGE 缺失、P1 ROOT 变量被 strip、P2×7）。全部为运行时证据支撑的真缺陷，非评审膨胀。
- **Layer 2 R2（fix 复验，聚焦）：** eval PASS + code PASS（双 subagent 返回全文转录为 R2 载体）。
- **载体：** `eval/code-review-blake-gate3-r1.md`（FAIL/CONDITIONAL 原样保留）+ `eval/code-review-blake-gate3-r2.md`（PASS）。

## 5. PREREQ 执行状态（本单内：全部未消耗调用）
PREREQ-AUTH：未获重开授权，本单 0 调用。PREREQ-1步骤1离线通过（版本 1.18.27 ≥ 1.18.0），步骤2未执行。PREREQ-2：live OPEN（`harness_available:true, negative_blocked:true, positive_ok:false→delegated`），离线双倍件 + 集成测试覆盖，重开时首次授权 run-pair 为 live 正控证明，交 Gate 4 裁决。PREREQ-3：已披露（默认采样策略），待人类接受。PREREQ-4：`verifyArmsFidelity → {ok:true, 13/13}` 通过。PREREQ-5：常量 26/2/3 验证通过。PREREQ-6：H:6/V:6 通过。

## 6. Implementation Decisions（执行中决策）
| # | Decision | Context | Chosen | Escalated? |
|---|---|---|---|---|
| 1 | prompt 内容形态 | handoff 要求 runner 生成 prompt 文件但未定内容 | 确定性指针文件 `PROMPT.md`（case/arm + arm 物料引用，零 oracle 内容） | No（handoff §4.3 已隐含该步骤） |
| 2 | exit-2 识别键 | raw 透传 exit 2 与 adapter 自身 exit 2 同码 | 以 `[oc-adapter]` stderr 标记区分，仅标记命中判 HARNESS_USAGE | No |
| 3 | 探针不动 | P0-2 要求真 canary leg 或重写 PREREQ-2（后者属 Alex） | 探针零改（保双倍件 host 无关性），审计标注 OPEN 交 Gate 4 | No（记录于此） |
| 4 | P2-4 平等允许保留 | reviewer 建议 strict-child | 拒绝：handoff L312 + PREREQ-1 `--dir /tmp` 要求平等允许 | No（spec 合规优先） |
| 5 | 载体目录 | Blake 默认 `reviews/blake/` 不在白名单 | 置于白名单 `reviews/alex/…` 下 `blake-gate3-*` 文件名 | No（§1 已注） |

## 7. Deviations from plan
- `NO_COLOR=1` → `NO_COLOR="${NO_COLOR:-1}"`（经 runner 行为一致，手工调试更礼貌；已披露）。
- PATH-fallback 增加重检 + resolved NOTE（handoff 未写明，纯加固，无行为回归）。
- trailing-slash 预剥离（handoff 未写明，关 `[ -L ]` 旁路形态，spec 意图内）。

## 8. Friction Status
| Item | Status | Evidence |
|---|---|---|
| 工具/依赖/权限 | READY | 全程 stdlib + bash，无缺失 |
| Layer 2 reviewer 独立性 | EQUIVALENT_SUBSTITUTE | 同 harness 内 fresh-context 双 subagent 两轮；非自审证据：R1 以运行时证据打出 FAIL/CONDITIONAL（含 3 个 P0），R2 逐项复验才 PASS；载体 4 文件。替代局限：非独立 OS 会话；Alex Gate 4 可要求原生会话重审。批准源：handoff §9.1 要求"OpenCode 独立会话"——本 harness 即 OpenCode（`opencode-go/muse-spark-1.3-contributor`），子智能体为独立上下文； manusia终裁见 Gate 4 |
| PREREQ-2 live 正控 | NOT_APPLICABLE_WITH_REASON（本单） | 设计使然：零花费委托；重开时首个授权 run-pair 为证明。理由见 §5 |
| 无 BLOCKED 项 | READY | Gate 3 可通过 |

## 9. Knowledge Assessment
- Q1: Yes — Journal entry added: `evidence/journal/thin-tad-harness-adapter-2026-09-08.md`（live-path/mock-path 分裂、spawnSync stderr、AC7 自触发、围栏盲视、探针诚实失败边界）。
- Q2: Yes — 可复用模式："零费用端到端"（真通道 + 末端 mock + 默认生产执行器），见 journal Q2。
- Q3: No — 无多 agent 编排发现。

## 10. Evidence Checklist
- [x] Layer 1 全绿（40/40，命令可重跑）
- [x] Layer 2 双专家 R2 PASS（R1 FAIL/CONDITIONAL 同步存档，非选择性呈现）
- [x] AC0–AC8 逐条可执行验证（§3 表）
- [x] 快照差围栏（baseline/current + sha 双轨）
- [x] KA journal 已写
- [x] Git 提交 `d23f78ab`（显式路径 4 文件，无 `-A`；`.tad` 证据留工作树，gitignored/untracked 与既有实践一致）
- [x] 零真实调用、零伪造、零生产修改声明（§5 + AC7/AC8）

## 11. Reflexion History
- what_failed: test `adapter absorbs temperature and seed with NOTE to stderr`: honest NOTE on stderr
  root_cause_hypothesis: 测试 helper 用 execFileSync，exit-0 成功路径的 stderr 不在返回值中（被吞），并非适配器未打印 NOTE
  revised_approach: helper 改用 spawnSync 取 status/stdout/stderr 三元组；新增 `import { spawnSync }`
  confidence: high
- （其余 Layer 1 迭代一次通过，无更多 reflexion）

## 12. Action requested
Please run Gate 4 (Acceptance) to verify and archive. 特别请裁决：(a) PREREQ-2 live OPEN 状态是否接受（首个授权 run-pair 作证方案）；(b) Layer 2 同 harness 独立子智能体是否足够，或需原生会话重审；(c) 归档时 runner 系文件现已入轨（`A` 状态已提交），P2 遗留 untracked 状态就此关闭。

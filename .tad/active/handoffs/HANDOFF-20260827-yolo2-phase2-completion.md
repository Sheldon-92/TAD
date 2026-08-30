---
task_id: TASK-20260827-YOLO2-P2-COMPLETION
status: approved
owner: Alex
created: 2026-08-27
task_type: code
e2e_required: no
research_required: no
gate2_note: >
  Gate-2 双专家审查以用户直接指令豁免（Value Guardian 2026-08-27 明确指示
  "写一个 handoff，我给 blake 执行完成"）。设计输入为独立 Group-0 复审报告
  （第二视角），修正案契约由人类 DR 签署。此豁免记录于 DR-20260827。
scope_proof_amendment: .tad/decisions/DR-20260830-yolo2-phase2-scope-proof-amendment.md
scope_amendment_gate2: pass
scope_amendment_reviews:
  - .tad/evidence/reviews/alex/yolo2-phase2-scope-amendment/architecture-review.md
  - .tad/evidence/reviews/alex/yolo2-phase2-scope-amendment/evidence-security-review.md
---

# HANDOFF-20260827-yolo2-phase2-completion

**From**: Alex (Solution Lead)
**To**: Blake (Execution Master)
**Epic**: `.tad/active/epics/EPIC-20260824-yolo2-verified-orchestration.md` (Phase 2 completion)
**Design authority**: `HANDOFF-20260825-yolo2-phase2-bounded-quality-loop.md`（冻结，语义权威）
**Amendment contract**: `.tad/decisions/DR-20260827-yolo2-phase2-amended-acceptance.md`（人类签署，验收契约权威）
**Scope-proof amendment**: `.tad/decisions/DR-20260830-yolo2-phase2-scope-proof-amendment.md`
（人类签署；仅替换 AC-B 的共享-main连续历史假设，不放宽 allowlist）

---

## 1. 任务概述

将 YOLO2 Phase 2 从当前 `HONEST_PARTIAL` 推进到可验收的 Gate 3 PASS：
按修正案契约补齐剩余 6 个可执行 P1 + 盲评 judges + durable §12 证据树，
在最终机制版本上重跑全套验证，使独立 Group 0 返回 PASS，
再走 code-reviewer / test-runner Layer 2 与 Gate 3。

**当前基线**（Blake 开工前核对）：
- HEAD `72ab0a45`，工作区干净
- 最后一次全量 dogfood：mechanism `421ca6d586bee356`（run `runs/421ca6d586bee356`），
  control 5/5 + treatment 5/5，safety 0/0
- 契约套件 12/12 PASS，Phase-1 套件 11/11 PASS
- 最新 Group-0 复审（@`1bd70f2e`）：5 NOT / 6 PARTIAL / 1 SAT；P0-1 已关闭

## 2. Socratic Inquiry Summary（本会话已完成的决策链）

**Complexity**: large

### Key decisions（人类已拍板）
- 完成定义：**修正案路径**（DR-20260827 签署）——降级 capability 9、resume-chain
  会话延续、同 harness 异会话 reviewer 均为有效证据；Gate 3 目标改为可 PASS。
- 75% 停/续决策：继续，改为标准 Blake 流程（不再 YOLO 单人执行）。
- 执行模式：前段 Alex-YOLO 已获人类授权完成实现；本 handoff 起回归标准角色分离。

### Clarified requirements
- "完成" = Group 0 PASS + Layer 2 PASS + Gate 3 PASS，而不是"尽力而为"。
- 判定证据必须可重算（hash/metric），不接受 summary 计数。

### Risks identified
- Codex 输出格式漂移（已用 prompt 契约缓解，仍可能在评审轮出现）。
- dogfood 机制一改就必须全量重跑（约 18 分钟/轮）——预算内安排。

### Acceptance criteria
见 §4 各 AC；最终判定 = §7。

## 3. Scope

### 3.1 Allowed product files
```
.tad/scripts/yolo-recovery.mjs          # engine（按需）
.tad/scripts/yolo-reference-runner.mjs  # runner（reviewer 轮 + per-call 归因）
.tad/scripts/phase2-pair-driver.mjs     # driver（arm 等价、reviewer 轮、durable tree）
.tad/scripts/yolo-round.test.mjs        # 契约套件（新 fixture）
.tad/scripts/yolo-recovery.test.mjs     # 仅限 scope-proof 端点修复（AC-B 明确授权）
```

### 3.2 Allowed evidence/state files
```
.tad/evidence/yolo/yolo2-verified-orchestration/phase2/**   # 含新建 dogfood/ 树
.tad/evidence/reviews/blake/yolo2-phase2/**                 # 复审报告（不改旧文件，新增增量 PASS 报告）
.tad/active/handoffs/COMPLETION-20260825-yolo2-phase2-bounded-quality-loop.md  # 仅更新为最终态
.tad/evidence/yolo/yolo2-verified-orchestration/phase2/{gate3-verdict,knowledge-assessment}.md
.tad/active/session-state.md, NEXT.md
```

### 3.3 Forbidden
`.claude/workflows/**`、`.codex/**`、`.tad/hooks/**`、installer/lockfile/version 文件、
Phase-1 归档证据、本文件与 20260825 handoff 原文（发现 handoff 本身有错 → 停止并上报，
不得自行修改设计权威）。

## 4. Work items and ACs

### AC-B — Scope proof 端点（P1-2）
按 `DR-20260830-yolo2-phase2-scope-proof-amendment.md` 执行双证明：

1. frozen base 仍为 `96bbfada`；verifier 对 pinned `BASE..MAIN_HEAD` 的每个 commit
   重算 first-parent diff 并要求 manifest 恰好分类一次；在独立 validation
   worktree/branch 中只重放被纳入的 Phase-2 commits，`96bbfada..PHASE2_CANDIDATE_HEAD` 与
   「Phase-1 归档 allowlist ∪ 本 handoff §3.1/§3.2 allowlist ∪ Alex-authored amendment
   carrier」比对，必须零越界；
2. candidate 与 pinned main SHA 上五个 Phase-2 product paths 及枚举的 immutable
   Phase-2 evidence 做 Git blob/tree 等价证明；共享控制面使用 DR 定义的 selector +
   exact value + canonical subdocument hash；Phase-2 owned paths 必须 clean；
3. 使用 DR 固定的唯一 verifier 命令与真实临时 Git fixtures；commit 闭集遗漏、禁止路径
   后回滚、manifest 篡改、main ref 漂移、错误 marker hash 均必须变红/exit 2；
4. dogfood 复用只由 canonical `dogfood-input-manifest.json` 判定，不由五个 product
   hashes 或 mechanism 名称判定。

不得把 base 改为 `f967276f`，不得扩大 YOLO allowlist，不得回滚 Local Wiki。

**Verify**: `node .tad/scripts/yolo-recovery.test.mjs` → 11/11 `RESULT=PASS`；
Gate 4 重跑 DR 的唯一 verifier 命令并得到 `RESULT=PASS`；scope-proof 五个 carrier
（含 dogfood-input manifest）存在且 hash 互绑；DR §3 的真实 Git fixtures 全部有
机器可读红/绿证据。carrier 存在或手写 PASS 日志本身不构成证明。

### AC-C — 六预算 fixture + 全角色记账（P1-7 / AC9）
yolo-round.test.mjs 的 budget-exhaustion 必须真实执行 6 个独立 fixture：
rounds（已有）、wall（已有）、actions、retries-per-slice、total-token、audit-reserve——
各自 exit 1 + `budget_exhausted` + 命名预算 + last verified 不变。
Engine：reviewer/alignment 的 native usage 计入 `tokens_charged`（按角色分列）。
**Verify**: 6 fixture 全红 + 套件绿。

### AC-D — Alignment hidden-business 链 + cadence fixture（P1-8 / AC7）
- `cmdAlign`：当 quality_policy 要求 hidden acceptance 时，alignment receipt 必须绑定
  hidden 结果引用（hash+PASS），hidden FAIL → align 拒绝（local green 也拒）。
- 新 fixture：3-verified-slice cadence（第 4 次 prepare 无 alignment → 拒）；
  hidden-fail alignment 拒绝；receipt 字节不变性断言。
**Verify**: `--case alignment-gate` 绿且新 fixture 存在于源码。

### AC-E — 双臂冻结等价（P1-5 / AC11 前提）
Driver 重构：packet 文本对双臂字节一致（run_id/时间戳/worktree 路径等 arm 特定字段
移出 packet 文本，进入 runner invocation 与 goal 的 arm-namespace 字段）。
Driver 输出 `arm-equivalence-manifest.json`：对 task seed、contract、packet 文本、
tool policy、budgets、model settings 做**规范化哈希**（剔除 run-specific 字段后），
双臂必须相等；不等则 driver 拒绝写入 pair-result。
**Verify**: 任意一对的 equivalence manifest 三段 hash 全等；checker 校验之。

### AC-F — 独立原生 reviewer（P1-3 / 修正案 §3）
Runner 新增 reviewer 轮支持：driver 以 **fresh session**（绝不 resume executor 线程）、
`--role reviewer` 调 runner；reviewer prompt = 独立核验 assertion vs packet/goal/oracle，
输出固定格式 verdict。Runner 产出 role=reviewer 的 native record（含 usage）。
Driver 用 reviewer record 构造 review 文档（mechanical rubric 仅解析 verdict，
不再自造 review）。Reviewer usage 计入 ledger（AC-C）。
**Verify**: review record `role=reviewer`、session ≠ executor session、native=true；
同进程 deterministic review 代码路径删除。

### AC-G — Per-call native 归因（P1-10 / P2 类）
Runner 按 native 事件逐条生成 tool_calls（command_execution → `Shell`+command sha；
file_change → 对应 tool+paths），并保留 invocation 摘要；`native_event_count` 与
tool_calls 条数一致性由 engine 校验。执行轮的 nonce 仍只落在真正变更文件的调用上。
**Verify**: 抽样 record 的 tool_calls 长度 ≥ native_event_count 且 kind 集合一致；
套件新增一条不一致即拒的红控。

### AC-H — AC11 checker 硬化 + durable §12 tree（P1-6 / P1-9）
Driver 在 `phase2/dogfood/` 下产出 durable 树：dataset-manifest、label-commitment、
randomization-schedule、rubric、每 case 的 pair-config/invocation/bootstrap/output-manifest、
judge 输出、paired-results。`dogfood-evidence` case 从"只查 count"升级为重算：
mechanism hash、per-pair capability（来自 final hidden 明细）、safety（来自 raw records）、
arm-equivalence、judge 存在性与盲化约束；任一 carrier 缺失/篡改 → FAIL。
**Verify**: 删除任一 carrier 后 case 必红；完整树存在时绿。

### AC-I — 三轮盲评 judges（P1-2 / §8.3）
每对跑 3 次独立 judge passes：judge 为**独立 subagent**（与 generator 不同 model family，
generator=codex/gpt），输入只有两个 arm 的最终产物 + rubric，**条件标签盲化**
（label-commitment 先冻结，judge 不可见 control/treatment 映射，成对呈现顺序在 pass 间交换，
reversal 记 tie）。输出 judge-pass-{1,2,3}-{arm}.json + 聚合（P0/P1 阻塞不可平均）。
**Verify**: 9 个 judge 文件存在；family ≠ gpt；checker 校验 label 泄漏拒绝。

### AC-J — 最终重验证 + Layer 2 + Gate 3
1. 最终 candidate commit 后重算 dogfood-input manifest：若与既有最终 run 逐项全等，
   复用并重跑 durable checker；若任一输入变化/不可重建，则新 namespace 全量 dogfood
   （5/5+5/5, safety 0/0）。
2. 双套件全绿 + scope proof（AC-B）绿。
3. 更新 `gate3-verdict.md` / `knowledge-assessment.md` / COMPLETION 至最终 HEAD。
4. 发起独立 Group-0 复审 → **必须 PASS**（NOT=0, PARTIAL≤3）。
5. code-reviewer（P0=0,P1=0）+ test-runner 两个 Layer 2 组 PASS。
6. 停在 Gate 3 结果，生成 Alex 消息；**Gate 4 归档由 Alex 执行，不在本 handoff 范围**。

## 5. Implementation order

1. DR 已存在 → 核对（5 分钟）。
2. AC-B scope proof（小，独立先行——它守护你后面所有提交的合法性）。
3. AC-C 预算 + AC-D alignment（engine + fixture）。
4. AC-E arm 等价重构（driver 大改，改完全量重跑一轮 dogfood 验证）。
5. AC-F reviewer 轮 + AC-G per-call 归因（runner + driver，再全量重跑）。
6. AC-H durable tree + checker 硬化 + AC-I judges。
7. AC-J 最终链路（dogfood → suites → Group 0 → Layer 2）。
每次机制变更后：commit → 新 namespace 全量重跑 dogfood（§14 规则，禁止增量混跑）。
若 AC-B 修正只改变 scope proof/test/evidence，且 canonical dogfood-input manifest 与
最终 run 逐项全等，按 DR-20260830 复用既有 dogfood；任一 dogfood input 改变或旧 run
无法无歧义重建 input manifest，则全量失效重跑。

## 6. Required Evidence Manifest（新增部分）

```
.tad/evidence/yolo/yolo2-verified-orchestration/phase2/dogfood/
  dataset-manifest.json, label-commitment.json, randomization-schedule.json, rubric.json
  cases/<case-id>/{pair-config,invocation-*,bootstrap-*,output-manifest-*,judge-pass-*}.json
  paired-results.json
.tad/evidence/yolo/yolo2-verified-orchestration/phase2/scope-proof/
  phase2-commit-manifest.json + candidate-tree.json + main-equivalence.json
  dogfood-input-manifest.json + scope-proof.log
.tad/evidence/reviews/blake/yolo2-phase2/
  spec-compliance-final.md (Group 0 PASS 载体) + code-reviewer.md + test-runner 报告
```
（既有 pairs/、runs/、两份 suite log、gate3-verdict、knowledge-assessment 沿用更新。）

## 7. Layer 2 / Gate 3 要求

- Group 0（spec-compliance）先行并阻塞其余；复审须针对 DR-20260830 定义的
  candidate/main binding tuple，引用本 handoff + DR-20260827 + DR-20260830 作为验收契约。
- Reviewers 必须读最终代码与 raw evidence，不得只看 COMPLETION。
- Group-0、code-reviewer、test-runner 最终报告必须绑定同一
  `{candidate_sha, main_sha, scope_manifest_sha256, main_equivalence_sha256,
  product_tree_sha256, immutable_evidence_tree_sha256, verifier_output_sha256}`；
  tuple 不一致视为未审查同一对象。
- P0/P1 阻塞；P2/LOW 可延后但须落 NEXT 条目。
- 原有 FAIL 报告保留为 provenance，修复需增量 PASS 载体。

## 8. Friction Preflight（§8.4）

| Friction | Status | 处置 |
|---|---|---|
| codex `exec resume` 不接受 `--sandbox` | READY | 用 `-c sandbox_mode="..."`（已落地） |
| capability 9 降级 | DEGRADED_WITH_APPROVAL | DR-20260827 + approval hash 绑定（已落地） |
| judge 需要非 gpt family | 预期 READY | 用 opencode subagent（claude 系）充当 judge；若配额不足 → BLOCKED 上报 |
| dogfood 每轮 ~18 分钟 × 预计 4-5 轮 | 预算内 | 机制变更批量化，避免碎改 |

未解决 BLOCKED → Gate 3 不可 PASS，停止上报，不得降级替代。

## 9. Stop / rollback

- 同一机制失败 3 次 → 停止，回报未决 findings（Handoff §14 沿用）。
- dogfood 开始后改机制 → 全量失效重跑，禁止混合。
- 回滚保留最后 verified checkpoint 与全部 audit trail；禁止删 evidence。
- 发现本 handoff 与 20260825 handoff/DR 冲突 → 停止上报，不得自行裁决。

## 10. Blake 消息模板（完成后发给 Alex）

```
Status:    ✅ Phase-2 Completion - Gate 3 结果: {PASS|HONEST_PARTIAL}
Handoff:   .tad/active/handoffs/HANDOFF-20260827-yolo2-phase2-completion.md
Evidence:  .tad/evidence/yolo/yolo2-verified-orchestration/phase2/ + reviews/blake/yolo2-phase2/
Next:      Alex 执行 Gate 4 验收/归档（若 PASS）
```

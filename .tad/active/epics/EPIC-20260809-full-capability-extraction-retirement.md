# Epic: Full 能力提取与硬退休

**Created**: 2026-08-09
**Owner**: Alex-Lite
**Status**: ACTIVE — Phase 3b Gate 2 PASS; ready for Blake implementation
**Predecessor**: `.tad/archive/epics/EPIC-20260804-lite-as-tad-body.md`

## Objective

退休的是 full 的巨型代理路径，不是其中仍有价值的能力。把尚未被 Lite 或现有独立
skill 覆盖的能力提取为按需加载、角色感知、权限不增的 capability skills；完成旧
`HANDOFF-*` 与 14 个注册下游项目的兼容迁移后，删除 full 的运行时、安装、路由与校验面。

目标结构：`Alex Lite / Blake Lite` 是唯一工作流角色；skills 提供专项知识、确定流程与
工具编排，但不拥有独立任务状态，也不能覆盖 Lite 的契约授权边界或独立 reviewer。

## Non-Goals

- 不把 full protocol 正文搬进 Lite skill。
- 不为了保存历史功能而保留 full 激活、启动扫描或通道分类器。
- 不在完成下游迁移和 Lite-only burn-in 前删除 full 文件。
- 不把 full 共同存在的机械权限债务伪装成本 Epic 已解决的问题。
- 历史 handoff、Epic 与 evidence 保持历史原貌，不追写为 Lite 格式。

## Architecture Decisions

1. **Lite Core + Capability Skills**：低频能力只在命中任务时加载。
2. **单一状态所有者**：当前 Lite 角色持有 handoff/Progress；skill 无独立可变状态。
3. **结果授权契约**：未来有效权限模型为 Lite 角色、skill 声明与已接受 Contract Mandate
   的交集；人的意图在设计期固化，不在运行时逐命令重复批准。详见
   `.tad/decisions/DR-20260809-lite-authority-model-v2.md`。
4. **角色感知模式**：候选 skill 显式区分 `plan / execute / verify`，不得借 skill 跨越
   Alex-Lite design-only 或 Blake-Lite contract-boundary。
5. **渐进披露**：skill metadata 常驻；SKILL.md 命中才加载；references/scripts 再按需。
6. **先处置再建设**：每项 full 能力先判 `EXTRACT / EXTEND / EXISTING / LITE_NATIVE /
   RETIRE / HISTORY_ONLY / DECISION_REQUIRED`，没有载体不新建 skill。

## Success Criteria

| # | 判据 |
|---|---|
| SC1 | 所有现役 full canonical 文件、命令与路由消费者都有处置结论，无未分类项 |
| SC2 | 每个 EXTRACT/EXTEND 候选都有真实触发例、资源计划、角色模式、权限与验证契约 |
| SC3 | 普通 Lite 任务固定读取量不因本 Epic 增长；未命中能力时专项 skill 加载数为 0 |
| SC4 | 14 个注册项目均有明确状态；可访问项目安装 Lite；active `HANDOFF-*` 清零 |
| SC5 | 一轮真实 publish+sync、依赖变更、全局注册面、失败恢复均由 Lite-only 完成 |
| SC6 | 弃用期内新建 `HANDOFF-*` 为 0，full fallback 为 0，P0 遗留为 0 |
| SC7 | full skill、安装复制、路由入口和专属 verifier 消费方全部删除；历史归档仍可读 |
| SC8 | mandate 内执行的 `avoidable_runtime_prompt_count=0`；只有目标/对象/后果越界才重新请求人域决定 |

## Phase Map

| # | Phase | Status | Deliverable |
|---|---|---|---|
| 1 | Full 能力 inventory + disposition | COMPLETE (`e05a135`) | 机械来源覆盖 + 能力处置表 |
| 2 | Lite ↔ Skill composition contract | COMPLETE (`e05a135`) | D1–D10 架构、manifest、权限/恢复/测试契约 |
| 3a | Release capability migration | COMPLETE (`cabe287`; Gate 4 PASS) | 扩展 `release-runbook`；source coverage + 无副作用 forward-test |
| 3b | Lite Authority Model v2 | COMPLETE (`80413f8`; Gate 4 PASS) | 用 Contract Mandate 取代逐命令审批；修订 Lite/skill composition 与测试 |
| 3c | Release live dogfood | READY (3b COMPLETE) | Lite-only 真实 publish+sync；mandate 内零可避免运行时询问 |
| 4 | Dependency operations | BLOCKED by 3c（顺序排在 release dogfood 后） | 新建 dependency skill，真实依赖变更 dogfood |
| 5 | Secondary capability decisions | BLOCKED by 4 | tournament / ideas / status 等提取或退休 |
| 6 | Legacy + downstream migration | BLOCKED by 3–5 | 37 张基线 handoff 处置；14 项目迁移与结构核验 |
| 7 | Deprecation shim + Lite-only burn-in | BLOCKED by 6 | 旧命令迁移提示；一个发布周期零 fallback |
| 8 | Physical removal + breaking release | BLOCKED by 7 | 删除 full 活跃面、下游 deprecation 清理、可回滚发布 |

## Phase Dependencies

```text
P1 inventory ─► P2 composition ─► P3a migrate ─► P3b authority ─► P3c dogfood
     ─► P4 dependencies ─► P5 secondary ─► P6 downstream ─► P7 burn-in ─► P8 remove
```

## Risk Register

- **Full 2.0**：把大量 references 合并进 Lite。缓解：metadata/index 常驻，正文按需加载。
- **Skill 权限旁路**：skill 文本声称自己可执行 Lite 或 mandate 禁止的动作。缓解：权限交集与角色模式。
- **状态分叉**：skill 另建任务状态。缓解：handoff/Progress 是唯一任务状态载体。
- **重复不可逆动作**：publish/sync 超时后重试。缓解：事务身份、动作前后状态核验、幂等检测与 mandate recovery policy。
- **形式主义授权**：人被要求判断 Bash/Git/exit code，形成橡皮图章。缓解：结果授权前置、agent 负责技术恢复、运行时只在 mandate 越界时问人。
- **删除早于迁移**：下游旧 handoff 无执行者。缓解：P6/7 是 P8 的硬前置。
- **无载体能力膨胀**：为低频历史命令新建 skill。缓解：`DECISION_REQUIRED` + carrier 判定。

## Phase 1–2 Completion (2026-08-09)

- Accepted and archived: `.tad/archive/handoffs/LITE-20260809-1543-full-capability-inventory-contract.md`
- Commit: `e05a135`（未 push）
- Result: AC 9/9 PASS；独立 reviewer 最终 PASS，P0/P1/P2=0。
- Decisions: `release-ops → EXTEND release-runbook`；`dependencies → EXTRACT dependency-ops`；
  `tournament / ideas / alex-design-inquiry / knowledge-maintain → DECISION_REQUIRED`，留 Phase 5。
- Constraint-ledger overdue scan before the next phase handoff: no overdue or malformed rows.

## Phase 3 Split Decision (2026-08-09)

- Human selected option 2: use full once as a bounded migration bridge; do not loosen Lite read/write authority.
- Phase 3a handoff archived after Gate 4 PASS: `.tad/archive/handoffs/HANDOFF-20260809-release-runbook-capability-migration.md`.
- Phase 3a is build + detect-only/fixture/forward-test. It explicitly forbids push/tag/publish/sync and downstream writes.
- Phase 3a 的 capability mechanics 可完成，但其中 per-command approval 语义不得直接进入 live dogfood。
- Phase 3b 先落实 `.tad/decisions/DR-20260809-lite-authority-model-v2.md`；当前 Phase 2
  composition contract 的 per-action approval 部分被该 DR 前瞻性取代，历史 evidence 不追写。
- Phase 3c owns the real Lite-only publish+sync dogfood；人的授权在设计期 Contract Mandate
  一次完成，mandate 内不得逐命令索取批准。
- Phase 1's provisional `release-verify-wrapper.sh` is rejected: it duplicates the existing public verifier interface and would create a second mechanical source of truth.

## Phase 3a Gate 4 Review (2026-08-10)

- Gate 3 commit `f8907a3` and zero-live-mutation evidence remain valid.
- Gate 4 FAIL: source guard invocation occurs too late for read-only sync/list routing (P1).
- Gate 4 FAIL: literal or symlink-resolved self-sync target is not rejected (P1).
- Performance review PASS: always-loaded entry is 69.5% smaller and no runtime executable surface changed.
- Acceptance report: `.tad/evidence/reviews/alex/release-runbook-capability-migration/gate4-acceptance.md`.
- This FAIL record is retained as history for `f8907a3`; both findings were repaired in `cabe287`.

## Phase 3a Gate 4 Rerun (2026-08-10)

- Gate 4 PASS at repair commit `cabe287` after an independent code, security, and performance rerun;
  every reviewer reported P0/P1/P2=0.
- Source identity now blocks all four operations before reference/state access; physical self-target
  identity blocks literal and symlink aliases before approval, state, or write.
- Alex mechanically reran AC1–AC11, mirror parity, and diff hygiene; all passed. The accepted evidence
  remains build/fixture-only with live mutation count 0 across 14 sealed registered targets.
- Handoff and completion were archived under `.tad/archive/handoffs/`. Phase 3b Authority Model v2 is
  ready and remains the prerequisite for any live release dogfood.
- Final report: `.tad/evidence/reviews/alex/release-runbook-capability-migration/gate4-rerun-acceptance.md`.

## Phase 3b Gate 2 (2026-08-10)

- Handoff ready: `.tad/active/handoffs/HANDOFF-20260810-lite-authority-model-v2.md`.
- The accepted outcome mandate replaces per-command approval; runtime prompts use a closed
  result-boundary enum and `avoidable_runtime_prompt_count` must remain zero.
- Gate 2 reviewers independently ended PASS at P0/P1/P2=0 after closing durable transaction state,
  executable CAS/crash recovery, exact consequence bindings, bounded release reference loading, and
  worktree/index/untracked/ignored/registered-target zero-touch evidence.
- Fixture contract: 30 cases, two clean controls, nine adversarial mutations; Phase 3b still prohibits
  all live push/tag/publish/sync and downstream writes.
- Gate 2 verdict: `.tad/evidence/reviews/alex/lite-authority-model-v2/gate2-verdict.md`.

## Phase 3b Gate 4 Acceptance (2026-08-10)

- Accepted at `80413f8f2c4b48d0e2e9f23d98d52e9bdc541a5e`; handoff + completion archived.
- Two repair rounds were needed. Gate 4 round 1 reproduced an **AC7 false PASS**: fixture rows carried
  their own `expected_result`, guarded only by a schema check plus a content digest — flipping an
  expected outcome and re-sealing the file still passed. Repair-2 added a 30-row literal expectation
  oracle inside the verifier, byte-compared against the normalized fixture. Alex confirmed the repair
  with four independently authored probes (outcome flip / unknown key / misplaced optional key /
  boolean inversion): 4/4 rejected.
- Gate 4 round 1 also found the revision-1 mandate encoded "one local commit" as human blast radius,
  turning a legitimate Gate-directed repair into a protocol deviation. Revision 2 redefined blast
  radius as exact target/surface/consequence/external reach; commit/retry/reviewer cardinality is
  agent-owned. `c851046` is retained honestly as a revision-1 deviation, not retroactively authorized.
- Alex recomputed every quantitative AC from raw evidence (commit range, 32 paths ⊆ §5.5, byte
  budgets, 30 fixtures, 13 inventory paths, 5 mirror pairs, 4 zero-touch planes, ledger overdue,
  evidence SHAs) — all matched. A fresh `--all` run by Alex was byte-identical to the recorded run.
- **Carry into 3c — AC8 headroom is 2 bytes.** Lite core is 52,198 against a 52,200 cap (baseline was
  47,398). The next edit to either Lite SKILL breaks AC8. Human decision 2026-08-10: defer the cap
  question until 3c actually hits it. Phase 3c must budget for this before adding Lite text.
- Open follow-up (out of scope here): `layer2-audit.sh` `KNOWN_REVIEWERS` does not recognize
  `implementation-reviewer` / `security-reviewer`, so the Layer 2 smoke alarm under-counts distinct
  reviewers. Carriers were verified directly on disk.
- No outward action performed anywhere in 3b: no push, tag, publish, sync, registry, or
  registered-target write. Phase 3c is the first phase that mutates outward.
- Gate 4 report: `.tad/evidence/reviews/alex/lite-authority-model-v2/gate4-repair2-acceptance.md`.
- Knowledge: `patterns/gate-design.md` (authority model + blast-radius amendment, Blake) and
  `patterns/ac-verification.md` (self-certifying fixture matrix, Alex).

## Current Baseline (2026-08-09, Phase 1 measured)

- Source full surface：`.claude` 35 文件 + `.agents` 35 镜像文件。
- Full main skill body：约 322KB；Alex references 30 个。
- Registered downstream：14；可访问 12、路径失效 2。
- 可访问项目安装 full：12/12；安装 Lite：1/12。
- 下游 active `HANDOFF-*.md`：37。
- Phase 1–2 grounded base：`4116517`；交付 commit：`e05a135`；尚未 push/publish/sync。

以上是 Phase 1 的输入基线，不是永久常量；每次迁移前必须重新测量。

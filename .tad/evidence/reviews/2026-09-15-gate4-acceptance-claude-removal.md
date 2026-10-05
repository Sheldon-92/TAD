# Gate 4 验收 — Claude 路径彻底移除 (v3.0.0)

- **Role**: Alex (Solution Lead) — Gate 4 验收。只验收不代码；未改源码/配置/handoff；`docs/pm/` 只读；未 commit / push。
- **Date**: 2026-09-16 | **Workdir**: TAD 仓库 (grokbox 侧) | **基线 HEAD**: `c32bde27` (v2.44.6)
- **Handoff**: `.tad/active/handoffs/HANDOFF-2026-09-15-claude-removal-plan.md` (`TASK-20260915-CLAUDE-REMOVAL`)
- **输入**: Gate 3 CODE (`2026-09-15-gate3-code-review-claude-removal.md`, C-1–C-4) + SAFETY (`2026-09-15-gate3-safety-review-claude-removal.md`, R1–R4) 双 CONDITIONAL；裁决 `2026-09-15-gate3-adjudication-claude-removal.md`（R2 全部保留 / R3+C-4 合并 waiver / C-3 carve-out / §8 R2-5 续裁）；返工证据 `2026-09-16-gate3-rework-r3-waiver.md` + `2026-09-16-gate3-rework-vp7-zeromutation.md`
- **Worktree**: 723 entries（staged D=572 / M=141 / R=1；unstaged M=3 [NEXT.md, docs/pm/intent.md, docs/pm/now.md]；untracked=6）

---

## 结论

# Gate 4 裁决：**CONDITIONAL**

核心 SAFETY 全部成立、SSOT 反转/tombstone/S7 删除/S9 版本物料全部与 handoff 一致、返工 8 点中 **7 点实质闭合**。**唯一未闭合的返工项是 R1**（`.gitignore` 机器本地保护规则恢复不完整），另叠加一项 AC20 字面判据未同步（验证剧场风险）。**均为非代码、单点、可 out-of-band 闭合项——不需要回 Alex 重设计。**

**发布建议：暂缓打 `v3.0.0` tag**，先闭合下方 §3 的 R1 两处 + AC20 判据三处（预计 <30 分钟，纯 `.gitignore`/handoff/grep 判据）。闭合或经人书面 waiver 后即可发布。核心移除行为（安装器、tombstone、零运行时残留、不删用户数据）已可发布，剩余项不触达任何运行时逻辑。

---

## 1. 抽查：Blake 落地 ↔ handoff 一致性（全绿）

| 面 | 判据 | 实测 | 结论 |
|----|------|------|------|
| **SSOT 反转** | 安装器只从 `.agents/skills` 读源 | `tad.sh:1168/1428` 双 copy 循环读 `$src/.agents/skills`；`TARGET_SKILL_DIR=".agents/skills"` (`:2367`)；`grep 'src/.claude/skills' tad.sh` 无命中 | PASS |
| **tombstone** | `both`/`claude-code` fail-before-mutation + 恢复命令 | `KNOWN_PLATFORMS="codex"` (`:514`)；`validate_platform` (`:519-536`) `both\|*claude*` → 报错 + 3 条 `--platform codex` 恢复命令 + `No files were changed` + `exit 1`；调用序 `resolve_platform:2363` ≪ `NEED_ROLLBACK:2571` ≪ `take_rollback_snapshot:2575` | PASS |
| **S7 删除** | `.claude/` 整套 + `CLAUDE.md` 从 repo 删除 | staged 删除 571 `.claude/**`（555 skills / 10 workflows / 2 agents / 2 settings / 1 rules / 1 commands）+ `CLAUDE.md` = 572；`git ls-files '.claude/**' CLAUDE.md` = 0；`research/CLAUDE.md → research/AGENTS.md` (R) | PASS |
| **S9 版本** | version.txt / package.json / TARGET_VERSION 同步 | `.tad/version.txt`=3.0.0；`package.json`=3.0.0；`tad.sh TARGET_VERSION="3.0.0"` (`:26`) | PASS |
| **S9 CHANGELOG** | v3.0.0 块仅 `### Removed`，与 §5.3 定稿一致 | `CHANGELOG.md` `## [3.0.0] - 2026-09-16` + `### Removed`（无 2.45.0 `### Deprecated`）；文案含 `--platform both` 拒绝、no-mirror、No user data deleted | PASS |
| **S9 发布门** | version-sweep / structural / denylist | `release-verify.sh version-sweep . 3.0.0` exit 0；`structural . .` exit 0（`.agents/skills identical`）；`tad.sh --verify-denylist` exit 0 | PASS |
| **release notes** | §5.2 升级兼容 + 旧 updater 恢复命令 | §5.2 定稿（5 条，含 `rm -rf` 手动清理指引 + 三条恢复命令）；`docs/releases/` 无 3.0.0 条目（发布时随 Release 出） | 待发布时落物料 |

**AC 抽样**（live）：AC5 (`claude_websearch\|claude_code_reviewer` 活面) 无命中；AC6 V-P1 首条 **0 hits**；AC8 (`<!-- Claude Code:`) 无命中；AC16 pair-driver 无 `claude/sonnet`、无 `.bak`；AC7 yolo-harness 测试 exit 0；AC18 无 `2.44.6-to-3.0.0.yaml`、`migration-engine.sh:72` allow-list 保留 `.claude/*`、version 三处同步。

---

## 2. Gate 3 CONDITIONAL 返工闭合核验（8/9）

| 项 | 要求 | 实测证据 | 结论 |
|----|------|----------|------|
| **C-1** | stage `migration-fixtures/run-fixtures.sh` | `git status` = `M  .tad/tests/migration-fixtures/run-fixtures.sh`（已 staged） | ✅ 闭合 |
| **C-2** | unstage `docs/pm`；内容与本任务无关 | `git status docs/pm` = ` M`（unstaged）；diff 为 09-13 MODEL-LOCK + 09-14 OCR STATUS（任务前 PM 日常）；AC10 已改「保持任务前状态」 | ✅ 闭合 |
| **C-3** | V-P1 第二条给 `parity-criterion.md` carve-out | §6.3 命令含 `--exclude=parity-criterion.md`；归档文件未改 | ✅ 闭合 |
| **C-4** | 与 R3 同处置（单一 waiver + 单一另单） | 见 R3；无第二张单 | ✅ 闭合（duplicate-of-R3） |
| **R2-1** | `agent-computer-interface` 保留 + V-P1 排除 | §3.H 追加 pack（handoff `:308`）；V-P1 首条 `grep -zv agent-computer-interface`；实跑 0 hits | ✅ 闭合 |
| **R2-2/R2-3** | `claude-code-cli` 依赖专名保留 + 排除 | §3.H `:309`；V-P1 首条 `grep -zv 'deps-protocol\.md\|dependency-ops/SKILL\.md'`；实跑 0 hits | ✅ 闭合 |
| **R2-4** | pack `CHANGELOG.md` 历史行保留 + 排除 | §3.K `:310`；V-P1 首条 `grep -zv 'CHANGELOG\.md'`；实跑 0 hits | ✅ 闭合 |
| **R2-5** | §8 续裁：V-P1 首条窄排除保留 ledger 字面，不改 verifier | V-P1 首条 `\| grep -v 'claude-code\.md'`；`runtime-freshness-verify.sh:12` 保留接线；`.tad/runtime-compat/claude-code.md` 头 `RETIRED in TAD v3.0.0` + `Status: RETIRED` | ✅ 闭合 |
| **R3** | Gate 4 书面 waiver + 强制另单 | 见 §4（本次签字）；`2026-09-16-gate3-rework-r3-waiver.md` 在盘；`TASK-20260916-CODEX-LEDGER-REVERIFY` 票 + `NEXT.md:15` 优先队列在盘 | ✅ 闭合（本次签字） |
| **R4** | V-P7 zero-mutation 实证 + 负控 | `2026-09-16-gate3-rework-vp7-zeromutation.md`：正控 `both`/`claude-code` exit 1 + `diff -rq` 空 + 恢复文案命中；双负控按预期 FAIL；`tad-update-fixture.sh --case states` 14/14 | ✅ 闭合 |
| **R1** | 恢复 `.gitignore` 机器本地 `.claude/*` 忽略规则 | **部分**：恢复 4/6（`settings.local.json` `:9`、`skills/local/` `:12`、`projects/` `:16`、`worktrees/` `:17`）；**漏** `.claude/settings.local.json.bak-*`；另 `reference_claude-code-source.md` 忽略行被删且无决策记录 | ❌ **未完全闭合**（见 §3.1/3.2） |

---

## 3. 剩余项（CONDITIONAL — 全部非代码，单点可修）

### 3.1 R1 残留（a）：`.claude/settings.local.json.bak-*` 忽略规则未恢复
- R1 明确列「恢复上述机器本地忽略行（BMad/ 与 parity 注释保持删除）」，`.bak-*`（HEAD `:78`）在列；工作树当前无此规则。
- 判别力证据：`git check-ignore -v .claude/settings.local.json.bak-20260916` → **NOT IGNORED**。且该产物类是**真实历史 artifact**：`.tad/evidence/reviews/blake/publish-v2410/pre-push-reviewer.md:178` 记录过 `?? .claude/settings.local.json.bak-20260806-082549`；`.tad/evidence/reviews/alex/lite-authority-model-v2/architecture-review.md:33` 将其列为**已证实的盲点**。通用 `*.bak`（`.gitignore:30`）匹配不到 `.bak-<date>` 后缀。
- 说明：handoff S7 原文要求「去 `.gitignore` `.claude/*`（`:7,10,13,19,20,78`）」与 R1 返工（恢复 `:78`）**互相矛盾**，且 S7 段落未随 R1 更新。需以 R1 为准（SAFETY 后裁）。
- **闭合动作**：`.gitignore` 恢复 `.claude/settings.local.json.bak-*` 行（一行）；并同步 S7 段落避免自相矛盾。

### 3.2 R1 残留（b）：`.tad/memory/reference_claude-code-source.md` 去留无书面决策
- R1 要求「另核…忽略行（HEAD `:70`）去留」。该忽略行已被删除；文件现存盘且 `git status` = `??`，`git check-ignore` → **NOT IGNORED**。
- 该文件经**既往安全评审判定为 SENSITIVE**：`.tad/evidence/reviews/blake/memory-redirect-capture-layer/security-auditor.md:70`（列入敏感面）+ `:115` P2-2（建议 glob `reference_*`，因该文件含 leaked-source 分析 + 本机绝对路径）。
- 风险：一次 `git add -A` 即可把含家目录路径的敏感文件送进公开仓库——正是 R1 要防的失败类。
- **闭合动作**：二选一并落字：(a) 恢复忽略行（文件保留在 `.tad/memory/**`，符合 §3.K「历史面不动」）；或 (b) 明确删除该文件（如判定 v3 后无价值）。**不得**维持「未跟踪且未忽略」的中间态。

### 3.3 AC20/V-P1 第二条**字面 RED**（验证剧场风险）
- handoff §6.3 / AC20 命令 `! grep -rn --exclude=parity-criterion.md '\.claude/skills' .tad/hooks/lib .tad/scripts .tad/capability-packs .tad/templates .tad/tests .tad/config-workflow.yaml .tad/skills-config.yaml` 期望**无输出**；实跑 **159 hits / 6 文件**。
- 裁决 §「保留裁决的成立强依赖 §5 命令同步；若只改源码不同步判据，AC5/AC6/AC20 将字面红，Gate 4 不得放行」直接适用。
- 分文件定性：
  - `.tad/tests/migration-fixtures/run-fixtures.sh`（118）、`test-15-dual-caller-integration.sh`（17）、`.tad/tests/tad-update-fixture.sh`（13）、`.tad/tests/installer-data-safety-fixture.sh`（4）→ I16 允许「明确标注『历史 fixture，验证 v2.x 迁移』时保留」；当前是**保留正确但命令未 carve-out**。
  - `.tad/skills-config.yaml`（6）→ 已按 §3.K 标 `ARCHIVED (v3.0.0)` 头「stale by design — do not repoint」；保留正确但命令未 carve-out。
  - `.tad/config-workflow.yaml:279`（1）→ **未被任何裁决/§3.I/§3.K 点名**；`playground.command: ".claude/skills/playground/SKILL.md"`。该 play­ground 已在 HEAD 前退役（`git ls-tree HEAD .claude/skills/playground/` 空；本批 `enabled: true` 但 `deprecated: true`, since 2.28.0），是 **pre-existing 悬空引用**，非本批引入的活消费者，但确实是活配置文件里的 `.claude/skills` 字面。
- **闭合动作**：(i) V-P1 第二条加 carve-out（排除 4 个历史 fixture 文件 + `skills-config.yaml`），并在 §6.3 旁注理由；(ii) 对 `.tad/config-workflow.yaml:279` 出一字裁决（repoint `.agents/skills/...` / 标 legacy / 删除该 deprecated 块的 `command:` 行）并纳入保留或改写清单。**不得**靠编辑 fixtures/归档文件消命中。

### 3.4 V-P2/AC2 字面语义（Gate 4 已裁，需同步 handoff）
- `test ! -e .claude` 字面 FAIL：工作目录存在 **untracked machine-local** `.claude/`（仅 `settings.local.json` + `skills/local/` + `projects/`，全部 gitignored；`git status` 不显示）。
- AC2 真意 = **tracked-only**：`git ls-files '.claude/**' CLAUDE.md` = **0** ✅。R1 已建议 Alex 明确此语义，handoff 未更新。
- **Gate 4 裁决**：AC2/V-P2 按 **tracked-only 语义判 PASS**（未跟踪 machine-local 树不属发布物）；**handoff AC2/§6.3 V-P2 应改写为 `git ls-files` 形态**（grep 判据同步动作，归入 §3.3 同批）。

---

## 4. R3 waiver 签字（Gate 4 落字，逐条对照裁决 §2 五条件）

Alex 于 Gate 4 **签字确认** R3 waiver，五条件逐一满足：

1. **AC21 = WAIVED（非 PASS）**，豁免范围**精确限定**为「codex ledger 高波动条目的日期陈旧（`last_verified: 2026-08-03` / `next_review: 2026-09-02`）」，并认其为 **pre-existing / HEAD 复现 / 与移除无关**。本次实测：`runtime-freshness-verify.sh . 2026-09-16` → `PASS:0 / WARN:6 / BLOCK:6`，`exit=1`，6 BLOCK 全为 codex 条目。✅
2. **AC21 意图子句独立判 PASS**：`INFO: ledger ./.tad/runtime-compat/claude-code.md is retired — skipping (v3.0.0 removal)`；`SKIP_CLAUDE` 逻辑同时覆盖「缺 ledger」与「RETIRED 头」，绝不 `exit 2`；无永久 wiring-BLOCK（I18 目标达成）。即**接线 PASS + 日期陈旧 WAIVED**。✅
3. **发布物料不得声称 AC21 全绿**：handoff AC21 行已写 `WAIVED`；**release-time 义务**——Release Notes 须如实标注该项 waiver（当前 `docs/releases/` 尚无 3.0.0 条目，属待发布物料，登记为发布门义务）。✅（待发布时履行）
4. **强制另单已登记**：`TASK-20260916-CODEX-LEDGER-REVERIFY`（owner Blake）+ `.tad/active/TICKET-20260916-codex-ledger-reverification.md` + `NEXT.md:15` 优先队列。✅
5. **单批次有效**，不授权任何后续「无实测仅 bump 日期」。✅

C-4 依裁决作为 **duplicate-of-R3** 关闭，不追加第二条执行要求。✅

---

## 5. gate4_delta（审计偏差记录，不自动注入、不以此阻塞）

```yaml
gate4_delta:
  - id: G4D-1
    item: R1
    delta: ".gitignore 机器本地忽略规则恢复 4/6，漏 .claude/settings.local.json.bak-*（R1 点名列示；通用 *.bak 不覆盖 .bak-<date>）"
    severity: low-safety
    status: open
    owner: Blake
    action: "恢复该行；同步 handoff S7 段落（原文仍要求去 :78，与 R1 矛盾）"
  - id: G4D-2
    item: R1
    delta: ".tad/memory/reference_claude-code-source.md 忽略行被删、无决策记录；文件现 ?? 且非忽略，既往安全评审判 SENSITIVE"
    severity: low-safety
    status: open
    owner: Alex/Blake
    action: "二选一落字：恢复忽略行 或 删除文件；禁止维持未跟踪且未忽略"
  - id: G4D-3
    item: AC20
    delta: "V-P1 第二条字面 159 hits/6 文件（4 历史 fixture + skills-config.yaml[ARCHIVED] + config-workflow.yaml:279[pre-existing 悬空 playground]）；命令未随保留/C-3 裁决同步"
    severity: medium (verification-theater)
    status: open
    owner: Blake
    action: "命令加 carve-out + 对 config-workflow.yaml:279 出一字裁决"
  - id: G4D-4
    item: AC2/V-P2
    delta: "test ! -e .claude 字面 FAIL（untracked machine-local 树）"
    severity: info
    status: resolved
    owner: Alex
    action: "裁决为 tracked-only 语义（0 tracked PASS）；handoff 判据改写为 git ls-files 形态"
  - id: G4D-5
    item: process
    delta: "无 TASK-20260915-CLAUDE-REMOVAL 的 COMPLETION 报告；handoff frontmatter status 仍 READY_FOR_GATE2；NEXT.md 缺本批移除条目"
    severity: info
    status: open
    owner: Blake
    action: "归档前补 completion report（含 S0–S9 + V-P0–P7 + AC 实测）并推进 status"
```

---

## 6. 边界与声明

- 本次**未改任何源码 / 配置 / handoff / docs/pm**，**未 commit / push / tag**；仅新增本证据文件。
- 验收基于 live worktree（`c32bde27` + 未提交的 723-entry 移除批）；R2/R3/C-4 的「与移除无关」前提已按 HEAD 复现核验。
- 核心 SAFETY（用户数据零删除、tombstone fail-before-mutation、零运行时残留、SSOT 单源、无 3.0.0 删除 manifest）**全部成立**，未被任何剩余项削弱。
- 剩余项全部落在 `.gitignore` 一行 + 一处文件去留决策 + 判据/命令同步 + 流程物料，不触达运行时代码路径。

**Verdict**: **CONDITIONAL** — 闭合 §3.1/3.2/3.3（含 G4D-1/2/3）或经人书面 waiver 后升 PASS；建议随之发布 `v3.0.0`。

---

## 7. 剩余单点项落字裁决（Gate 4 追加，2026-09-16）

> **范围**：仅对 §3.1 / §3.2 / §3.3 三项（`G4D-1/2/3`）落字裁决；**未改任何源码 / `.gitignore` / `.tad/memory` 文件本体**（`.gitignore` 与忽略行落地归 Blake）；**已同步 handoff 判据文本**（§7.4，判据修正非代码）。`docs/pm/` 只读；未 commit / push / tag。

### 7.1 [G4D-1] `.claude/settings.local.json.bak-*` 忽略行 —— **Verdict：加回（restore）**

- **裁决**：`.gitignore` 恢复 `.claude/settings.local.json.bak-*` 一行（复刻 HEAD `:77-78` 的注释+规则）。理由：该产物是**已实证的机器本地泄漏类**（`publish-v2410/pre-push-reviewer.md:178` 实见 `?? .claude/settings.local.json.bak-20260806-082549`；`lite-authority-model-v2/architecture-review.md:33` 列为已证实盲点），且通用 `*.bak`（`.gitignore:30`）**不覆盖 `.bak-<date>` 后缀**（`git check-ignore` → NOT IGNORED 已复现）。R1 点名保留，非本批删除对象。
- **S7 自相矛盾处置**：handoff S7 原列 `:78` 进删除清单，与 R1 返工**互斥**。**判 `:78` 不删、以 R1 为准**（SAFETY 后裁优先于 S7 前期枚举）；handoff S7 文字已改写并标注以 R1 为准（见 §7.4-①）。
- **落地形态（Blake）**：`.gitignore` 的 `# Local settings` 块内：
  ```gitignore
  # 本地权限配置备份 —— 含本机绝对路径与白名单，永不提交
  .claude/settings.local.json.bak-*
  ```
- **验收**：`git check-ignore -v .claude/settings.local.json.bak-20260916` → 命中该行（exit 0）。

### 7.2 [G4D-2] `.tad/memory/reference_claude-code-source.md` —— **Verdict：(a) 恢复忽略行；不删文件**

- **裁决**：恢复 HEAD `:70` 忽略行 `.tad/memory/reference_claude-code-source.md`，**保留文件**。
- **理由**：① §3.K 明列 `.tad/memory/**` 属「历史/权威记录，明确不动」，删除与既定保留语义冲突；② 该文件是**未跟踪**文件，一旦物理删除**无 git 历史可恢复**，而忽略行是 HEAD 既有原态、**恰好消除** `git add -A` 误提交（含 `/Users/sheldonzhao/...` 家目录路径 + leaked-source 分析，既往安全评审判 SENSITIVE：`memory-redirect-capture-layer/security-auditor.md:70,115`）；③ 选项 (b) 删除的收益（清理一个未被引用的 reference）不抵其不可逆代价。
- **禁止**维持「未跟踪且未忽略」中间态（这正是 R1 要防的失败类）。
- **落地形态（Blake）**：在 `.gitignore` 的 `.tad/memory/**` 忽略块末（HEAD `:70` 原位）加：
  ```gitignore
  .tad/memory/reference_claude-code-source.md
  ```
- **验收**：`git check-ignore -v .tad/memory/reference_claude-code-source.md` → 命中（exit 0）；`git status --porcelain` 不再显示 `??`。

### 7.3 [G4D-3] AC20 / V-P1 第二条字面 RED —— **逐文件裁决**

> 基线实测：159 hits / 6 文件。原则：**被保留物本身不动**（不编辑 fixture/归档消命中，沿用 C-3 纪律）；判据侧 carve-out + 唯一活配置项改写。

| 文件 | hits | **裁决** | 理由 |
|------|------|----------|------|
| `.tad/tests/migration-fixtures/run-fixtures.sh` | 118 | **carve-out** | I16 历史迁移 fixture（v2.27→v2.28 回放语义）；`migration-fixtures/*.sh` 已在 I16 保留枚举内 |
| `.tad/tests/migration-fixtures/test-15-dual-caller-integration.sh` | 17 | **carve-out** | 同上（`migration-fixtures/*.sh`） |
| `.tad/tests/tad-update-fixture.sh` | 13 | **carve-out** | I16 点名；v2.43.1 updater 回归 fixture（预置用户 `.claude/` 树） |
| `.tad/tests/installer-data-safety-fixture.sh` | 4 | **carve-out + 补入 §3.K 保留清单** | I16 未点名，但 `:509-512,926-927` 是**预置用户 `.claude/` 树以断言 AC12/AC17 字节不变**的数据安全断言；改写即销毁安全测试。按 I16 同类保留，并显式登记 |
| `.tad/skills-config.yaml` | 6 | **carve-out（整文件）** | 已按 §3.K 标 `ARCHIVED (v3.0.0)`，头注「no live consumer / stale by design — do not repoint」；归档面不属活零残留 |
| `.tad/config-workflow.yaml:279` | 1 | **改写（非 carve-out）** | **活配置**里的 pre-existing 悬空引用：`command: ".claude/skills/playground/SKILL.md"`，而 playground 自 2.28.0 deprecated、HEAD 前已退役（`.claude/skills/playground/` 与 `.agents/skills/playground/` **均不存在**）。**repoint 会制造新的悬空引用，故不采用**；删除该 deprecated 块的 `command:` 行并标注退役 |

- **`.tad/config-workflow.yaml:279` 改写形态（Blake）**：删除 `command: ".claude/skills/playground/SKILL.md"` 行，替换为注释（保留块其余元数据与 `deprecation`/`migration` 字段）：
  ```yaml
  # command 于 v3.0.0 移除：playground 自 2.28.0 deprecated，skill 路径在 HEAD 前已不存在（悬空引用）
  ```
- **AC20 命令形态（判据侧，已同步 handoff §6.3 / AC20）**：
  ```bash
  ! grep -rn --exclude=parity-criterion.md --exclude=skills-config.yaml \
      --exclude=run-fixtures.sh --exclude=test-15-dual-caller-integration.sh \
      --exclude=tad-update-fixture.sh --exclude=installer-data-safety-fixture.sh \
      '\.claude/skills' .tad/hooks/lib .tad/scripts .tad/capability-packs \
      .tad/templates .tad/tests .tad/config-workflow.yaml .tad/skills-config.yaml
  # 期望：无输出（exit 0）
  ```
  排除采用**具体文件名**（非整目录），保留对新增活消费者回归的检出能力；`config-workflow.yaml` **不排除**，靠 :279 改写转绿。
- **§4.4 一致性**：4 个 fixture 留在 §4.4「tests/fixtures」行（I16 保留语义），须在 §3.K「明确不动」清单补登 `installer-data-safety-fixture.sh`（数据安全断言）以与 carve-out 逐条对上——已随 §7.4 落地。

### 7.4 handoff 判据同步记录（本次已改，判据文本）

| # | 位置 | 改动 |
|---|------|------|
| ① | S7 行（§6.2）| `.gitignore` 删除清单由 `(:7,10,13,19,20,78)` 改为 `(:7,10,13,19,20)`，并注明 **`:78` 例外——按 R1 恢复 `.claude/settings.local.json.bak-*`，以 R1 为准** |
| ② | §6.3 V-P1 第二条 | 命令加入 `--exclude=skills-config.yaml` 与 4 个 fixture `--exclude`，旁注 carve-out 理由；`config-workflow.yaml` 不排除 |
| ③ | AC20 行（§8）| 期望列同步 carve-out 清单 + `config-workflow.yaml:279` 改写说明 |
| ④ | §3.K「明确不动」清单 | 补登 `installer-data-safety-fixture.sh`（I16 同类数据安全保留） |

### 7.5 状态与结论

- 三项均为**非代码、单点、判据/配置面**项；**设计面已闭合，无残留争议**。
- Blake 按 §7.1 / §7.2 落 `.gitignore` 两行 + §7.3 改写 `config-workflow.yaml:279`（一处）后：
  - R1 **完全闭合**（6/6 忽略行）；
  - `git add -A` 误提交敏感文件风险消除；
  - AC20 字面 **转绿**（159→0）。
- 届时 Gate 4 由 **CONDITIONAL 升 PASS**，可发布 `v3.0.0`。**在此之前 AC20 字面仍红 → 不得放行**（沿用本文件裁决 §「保留的成立强依赖命令同步」）。

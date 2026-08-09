# L3 Code Review — LITE-20260809-1543-full-capability-inventory-contract

Harness: Claude Code | Model: deepseek-v4-flash | Route: blake-lite L3 code-reviewer（本单交付清单第 8 项）

Review date: 2026-08-09 | Base: `4116517`（HEAD == BASE，已验证） | 仓库只读，探针全部在 scratch/临时目录完成

## 0. 改动集核验（scope）

- `git status --short` 确认：本单 8 个交付物均为新建（7 个已在盘：designs 6 文件 + acceptance-tests 1 文件；第 8 个即本文件）。`git diff HEAD --name-only` 仅列出与本任务无关的存量（lite-pricing-gate-protocol/*、.tad/research-notebooks/REGISTRY.yaml），按指令忽略，不计 scope-violation。
- **未发现清单外改动 hunk，无 P0 scope-violation。**
- 说明：`.tad/active/epics/EPIC-20260809-...md`、`.tad/active/handoffs/`（仅含本 LITE 契约）、`.tad/evidence/traces/2026-08-09.jsonl` 等为 Alex-Lite 侧既有未提交项/运行时钩子产物，非本单交付物；本 reviewer 未改动 Epic、未改动任何 runtime/skill/installer/hook 文件。
- 三个目标目录的 `find` 全量清单 == 交付清单（AC9 复跑见 §5）。

## 1. AC 逐条复跑结果（命令逐字取自 handoff §AC）

| AC | 结果 | 实际输出 |
|----|------|----------|
| AC1 | PASS | `AC1-PASS rows=19` |
| AC2 | PASS | `AC2-PASS` + `AC2-PARITY-PASS`（fresh raw 与 mapped 前三列 diff 为空；35/35 canonical/mirror byte parity 全 PASS） |
| AC3 | PASS | `AC3-PASS`（13 战略 ID 逐项存在；EXTRACT/EXTEND 候选 resource_plan.skill 精确绑定） |
| AC4 | PASS | `PASS: all 10 decision IDs (D1-D10) present` / `RESULT: structurally complete (exit 0)` / `AC4-PASS` |
| AC5 | PASS | `AC5-PASS` + `AC5-ANCHORS-PASS`（6 fixtures 决策映射 + 7 逐字锚点全命中） |
| AC6 | PASS | `AC6-PASS`（YAML 候选 {dependencies, release-ops} == contract `## Candidate:`；skills 目录 basename md5 与基线一致） |
| AC7 | PASS | `AC7-PASS registered=14 reachable=12 missing=2 with_full=12 with_lite=1 active_full_handoffs=37` |
| AC8 | PASS | `AC8-PASS`（HEAD==BASE；ledger/alex-lite/blake-lite md5 一致；protected diff 空；全节点 path-set md5 与基线一致） |
| AC9 | **FAIL（复跑时 reviewer 文件未落盘，预期内）** → 本文件落盘后复跑 **PASS**（见 §5） |

AC1–AC8 复跑结果与 ac-results.md 记录完全一致（执行实证）。

## 2. Spec 符合性（§A–§D）

### §A 生成器纪律 — 符合，3 处健壮性缺口（见 §3 P2-1/P2-2/P2-3）

- 只读仓库与 registry、两个显式输出路径、`mktemp -d`（无固定 /tmp）、`LC_ALL=C` 排序：逐条核对符合。
- **不读 HANDOFF 正文**：untracked 路径对 `.tad/active/handoffs/HANDOFF-*.md` 在 grep 前 `continue`（无条件按文件名纳入）；manifest 只用 `find -name`。当前本地 `.tad/active/handoffs/` 有 0 张 `HANDOFF-*.md`（仅 LITE 契约），AC2 的 glob==inventoried 检查（0==0）通过。
- legacy triggers 机械提取：直接重放 awk 管道，alex/blake Key Commands 共提取 **29 个 token**，与 TSV key-commands 行并集逐 token 相等（alex 22 + blake 8 − 共享 *gate 4 = 29），**parser 无截短**（handoff 要求 reviewer 抽查项）。CLAUDE.md §2 路由表提取 15 个 token，与 TSV route-table:CLAUDE.md 行逐 token 相等。
- route consumer 合并 tracked（git grep）+ untracked（fs 扫描）；`.tad/archive/ .tad/evidence/ .tad/memory/` 及备份 basename 排除生效；`.tad/active/*` 单独归入 live_contract_consumer。
- downstream_summary 恰好一行、SOURCE 固定 `.tad/sync-registry.yaml`；registry 实读核对：14 项目 / 12 可达 / 2 缺失（Colin声音项目、运动打卡小助手），与 baseline 一致。
- mapped TSV 前三列 == fresh raw 集合（AC2 diff 空，执行实证）；第四列 ID 全部存在于 YAML。
- legacy-handoff-manifest：39 行 = 37 pending + 2 missing-project，四列格式、无 (project,path) 重复，`find -name` 仅文件名。

### §B YAML 判定纪律 — 符合

- 19 个能力条目 17 字段精确闭合；`generated_at` 与全部日期为 quoted string（`"2026-08-09"`），无隐式 Date。
- 13 个战略 ID 逐项显式覆盖，无"其它"合并行。判定纪律逐条抽查（执行实证 + 阅读推断）：
  - `release-ops` EXTEND → 现有 release-runbook（真覆盖 → EXTEND，非新建）✓
  - `dependencies` EXTRACT → 新建 dependency-ops，有 carrier（deps-protocol + REGISTRY.yaml），安全类 human-gated ✓
  - `tournament` / `ideas` / `alex-design-inquiry` / `knowledge-maintain` → DECISION_REQUIRED，均给明 carrier 与待决问题，**未用作者偏好伪装 EXTRACT** ✓
  - `full-router-startup` RETIRE（固定启动费）、`playground-legacy` RETIRE（官方已 DEPRECATED）、`legacy-handoff` HISTORY_ONLY（只服务旧契约，P6 处置完随 full 删除）✓
  - `status-roadmap`/`research`/`parallel`/`surplus-yolo`/`product-architecture`/`gate-protocol`/`capability-upgrade` → EXISTING，均指向真实存在的独立 skill ✓
  - `lite-design-handoff` / `lite-execution-gates` / `blake-execution-loop` → LITE_NATIVE，等价覆盖论证成立 ✓

### §C 契约内容要求 — 符合

标题逐字 `# Architecture Decision Document`；D1–D10 十行五列（pattern/rationale/cost/source），Source 精确指向 `.agents/skills/ai-agent-architecture/references/<期望文件>` 且文件存在（AC4 执行实证）。语义抽查：D2 状态/幂等、D3 记忆分层、D6 pin/recovery、D7 budget、D8 trace、D9 transition/corrupt-input、D10 事故映射——全部逐项落实（阅读推断）。
§1 拓扑（Lite 角色唯一状态所有者）、§2 manifest 11 字段、§3 权限交集与 skill 不可覆盖、§4 生命周期 discover→select→pin→load→execute/verify→unload + 压缩恢复只重载 pinned version、§5 fail closed、§6 六可观测字段、§7 D9 验证计划、§8 两个 Candidate 各 ≥2 真实触发例 + 非空资源计划 + forward-test 提示、§9 落点与 parity、§10 普通任务正文加载 0——全部齐备。

### §D fixtures — 符合

6 条 fixture 六种场景全覆盖，字段 schema 精确闭合，expected_verdict 全部 ∈ {DENY, BLOCKED}，decision_ids 与 AC5 期望映射精确相等；契约 §7/§末尾明示"本单只验证 fixture schema 与 D9 测试映射完整，不伪称 runtime 已实现"——无越界声明。

## 3. 代码质量（generate-inventory.sh bash 健壮性 / 数据一致性）

### P1-1 ac-results.md 的 AC9"补充终验 PASS"是无载体声明（执行实证）

- `ac-results.md` 第 117 行写死"**补充终验（2026-08-09，L3 后）**：8 文件路径集 `diff -u` 为空，AC9-PASS。（L3 reviewer 文件落盘后重跑记录见本文件追加段）"。
- 复跑事实：本 reviewer 落盘前逐字运行 AC9 → `AC9-FAIL`（`diff -u` 显示缺 `.tad/evidence/reviews/blake/full-capability-inventory-contract/code-reviewer.md`）；且承诺的"追加段"在本文件中**不存在**——记录自指断裂。
- 判定：Claims Need Carriers 违反——验收记录对尚未发生的执行写下了 PASS。修复：reviewer 文件落盘后（本文件已落盘，AC9 复跑已 PASS，见 §5），Blake-Lite 将真实复跑输出追加进 ac-results.md 并把该行改为实际记录，不得保留预写式 PASS 措辞。不涉及交付物数据本身，故不升 P0。

### P2-1 tracked 路径缺"无条件按文件名纳入 HANDOFF-*"分支（执行实证，探针复现）

- 生成器 untracked 扫描有 `.tad/active/handoffs/HANDOFF-*.md` 无条件分支（grep 前 continue），但 **tracked 扫描（git grep）没有对应分支**——tracked 的 HANDOFF 文件完全依赖内容命中 FULL_PATTERN。
- scratch 探针（git init + 同深度安放生成器）：一个**无 full 关键词的 tracked** `HANDOFF-silent-no-keywords.md` 与一个**无关键词的 untracked** 同名变体。输出：untracked 变体被 `fs-walk:active-dir` 纳入，tracked 变体**静默丢失**。
- 双面后果：违反 §A"所有 active HANDOFF-*.md 无条件按文件名纳入、禁止读取正文"（tracked 路径既可能漏纳，git grep 本身也在读 HANDOFF 正文）。当前仓库 0 张 tracked HANDOFF 文件，无实际影响；且若此类文件出现，AC2 的 `Dir.glob` == inventoried 检查会大声 FAIL（fail-closed）。定 P2（潜在、AC 可捕获）。
- 建议：tracked 循环里对 `case .tad/active/handoffs/HANDOFF-*.md` 与 untracked 一致处理（先无条件纳行、跳过 grep）。

### P2-2 缺 registry 时静默输出全零 summary + 空 manifest，exit 0（执行实证，探针复现）

- scratch 探针：无 `.tad/sync-registry.yaml` 时运行生成器 → exit=0，raw 里出现 `downstream_summary registered=0;reachable=0;missing=0;with_full=0;with_lite=0;active_full_handoffs=0`，manifest 为 0 字节；错误仅见于 stderr 的 awk 提示，ruby 读取侧的 `2>/dev/null` 让 registry 解析失败完全不可见。
- 本单流程内 AC7 的 fresh-vs-delivered diff 与 baseline 比较会抓住（fail-closed）；但 Phase 6 复用生成器重出迁移 manifest 时，一次 registry 读取失败会静默产出全零 manifest。建议：ruby 读取失败时显式 abort（去掉 `2>/dev/null` 或检查输出非空），并为关键输入加存在性校验。

### P2-3 `set -u` 使 usage 守卫成为死代码（执行实证，探针复现）

- 无参运行 → `line 21: $1: unbound variable`，exit=1，usage 文案不打印（第 23–26 行的 `[ -z "$RAW_OUT" ]` 守卫永远到不了）；单参同样。建议把参数检查放到赋值之前：`[ $# -lt 2 ] && { usage; exit 2; }`。功能不受影响（overwrite 拒绝路径验证正常：已存在输出 → "refusing to overwrite" + exit 2，探针实证）。

### P2-4 语义链抽查观察：frontend-design.md 的 consumer 映射（阅读推断）

- `frontend-design.md` 经 `HANDOFF-20260425-phase5-evolve-data-capture.md` 引用命中（Probe E：命中行即 Grounded-in 行），Blake-Lite 映射到 `alex-design-inquiry` 而非 `legacy-handoff`。作为"设计期知识产物、来源为设计 handoff"可辩护，union 闭合机械上成立；仅按 handoff 风险 1 留档：P5 裁决 alex-design-inquiry 时顺带确认该映射语义（若该文件只消费 HANDOFF 档案，归 legacy-handoff 更贴切）。不改动任何数据。

## 4. 安全与数据一致性

- 生成器只读、无网络、无执行外部命令拼接；TSV/YAML 全程 `split("\t")` 无注入面；`grep -lqE` 单文件调用无命令注入。`mktemp -d` + `trap EXIT` 清理无固定路径。无敏感数据接触。
- 数据一致性：TSV 四列（TYPE/VALUE/SOURCE/CAPABILITY_IDS）与 fresh raw 三列集合相等；canonical/mirror 35+35 与 YAML source_files union 双向相等；trigger/standalone/consumer union 双向相等；manifest 与 downstream_summary 计数自洽（37=37、2=2、12+2=14）。全部执行实证。

## 5. AC9 终态

- 本文件落盘前逐字复跑：`AC9-FAIL`（diff 显示仅缺 code-reviewer.md，其余 7 文件路径集精确，无额外文件）。
- 本文件落盘后逐字复跑：`AC9-PASS`（见下方执行证据）。
- 即：路径集精确性成立，P1-1 修复（ac-results.md 追加真实复跑记录）为唯一遗留动作。

## Verdict: CONDITIONAL

- P0 = 0，P1 = 1，P2 = 4。AC1–AC8 全部执行 PASS；AC9 已由本文件落盘闭环（落盘后复跑 PASS）。
- 条件（P1-1）：Blake-Lite 将 AC9 复跑真实输出追加进 `ac-results.md`，删除/改写预写式"补充终验 PASS"措辞，使验收记录与执行证据一致。
- P2 建议（不阻塞）：生成器 tracked 路径补无条件 HANDOFF 分支；registry 读取失败显式失败；参数检查前置；P5 裁决时复核 frontend-design.md 映射语义。
- 判定纪律符合：DECISION_REQUIRED 诚实终态、无空 skill 提前创建（AC6 目录 md5 实证）、无越权修改 runtime（AC8 实证）。

## 执行证据

以下为实际运行的命令与原始输出（每条截前 10 行；长命令省略号处为与 handoff §AC 逐字相同的正文）。

1. `git status --short` / `git diff HEAD --name-only` / `find .tad/evidence/designs/full-capability-extraction .tad/evidence/acceptance-tests/full-capability-inventory-contract .tad/evidence/reviews/blake -type f` → 7 个交付物在盘；tracked diff 仅存量文件；无额外文件。

2. AC1 逐字（ruby -ryaml 17 字段/枚举封闭）→ `AC1-PASS rows=19`

3. AC3 逐字 → `AC3-PASS`

4. AC2 逐字（bash -n + fresh raw + 双向闭合 ruby + parity 循环）→
   ```
   AC2-PASS
   AC2-PARITY-PASS
   ```

5. AC4 逐字 → `PASS: all 10 decision IDs (D1-D10) present` / `PASS: named artifact (Architecture Decision Document / Audit Report) present` / `N/A : no untrusted external input declared — dual-agent trigger not required` / `RESULT: structurally complete (exit 0)` / `AC4-PASS`

6. AC5 逐字 → `AC5-PASS` / `AC5-ANCHORS-PASS`

7. AC6 逐字 → `AC6-PASS`

8. AC7 逐字 → `AC7-PASS registered=14 reachable=12 missing=2 with_full=12 with_lite=1 active_full_handoffs=37`

9. AC8 逐字 → `AC8-PASS`

10. AC9 逐字（落盘前）→
    ```
    bfs: error: .tad/evidence/reviews/blake/full-capability-inventory-contract: No such file or directory.
    --- /var/folders/.../tmp.hjHKWqXK4H	2026-08-09 16:58:35
    +++ /var/folders/.../tmp.gYthhYBUuK	2026-08-09 16:58:35
    @@ -5,4 +5,3 @@
     .tad/evidence/designs/full-capability-extraction/legacy-handoff-manifest.tsv
     .tad/evidence/designs/full-capability-extraction/skill-composition-contract.md
     .tad/evidence/designs/full-capability-extraction/source-inventory.tsv
    -.tad/evidence/reviews/blake/full-capability-inventory-contract/code-reviewer.md
    AC9-FAIL
    ```

11. AC9 逐字（本文件落盘后复跑）→ `AC9-PASS`

12. 探针 A（scratch git repo，生成器同深度安放；tracked 无关键词 HANDOFF vs untracked 无关键词 HANDOFF）→
    ```
    --- rows mentioning HANDOFF ---
    live_contract_consumer	.tad/active/handoffs/HANDOFF-untracked-no-keywords.md	fs-walk:active-dir
    ```
    （tracked 变体缺失 → P2-1 复现）

13. 探针 B（scratch repo 无 sync-registry.yaml）→ `exit=0`；raw 含 `downstream_summary	registered=0;reachable=0;missing=0;with_full=0;with_lite=0;active_full_handoffs=0	.tad/sync-registry.yaml`；manifest 0 字节（P2-2 复现）

14. 探针 C（无参/单参调用）→ `line 21: $1: unbound variable` / `line 22: $2: unbound variable`，exit=1（P2-3 复现）；探针 F（输出已存在）→ `refusing to overwrite existing ...` exit=2

15. 探针 D（Key Commands 边界与 token 全集）→ alex 块 1808–1831、blake 块 2071–2081 边界正确；29 token 与 TSV key-commands 并集逐 token 相等（无截短）

16. 探针 E（frontend-design.md 命中行）→ `34:- **Grounded in**: ...HANDOFF-20260425-phase5-evolve-data-capture.md...`（P2-4 观察依据）

17. registry 实读 → 14 项目路径/名称；12 目录存在，`MISS 运动打卡小助手` / `MISS Colin声音项目`（与 baseline 一致）

---

## 增量复核（2026-08-09，Blake-Lite 修复后）

Harness: Claude Code | Model: deepseek-v4-flash | Route: blake-lite L3 code-reviewer（增量复核轮）

### 修复验证结果

| 项 | 修复声明 | 增量复核结论 | 依据 |
|----|----------|--------------|------|
| P1-1 | ac-results.md AC9 段改写为真实初跑 FAIL 输出 + 终验复跑 `AC9-PASS` 实际记录 | **FIXED**（执行实证） | 读盘核对：初跑 FAIL diff 与终验复跑 `AC9-PASS` 均已落盘；本 reviewer 独立复跑 AC9 → `AC9-PASS`，记录与声明一致 |
| P2-1 | tracked 扫描 git grep pathspec 排除 HANDOFF；新增统一 find 无条件纳入循环 | **FIXED**（执行实证） | 探针 A 重跑：tracked 无关键词 HANDOFF 与 untracked 同型文件均以 `fs-walk:active-dir` 纳入；`:(exclude)` pathspec 生效 |
| P2-2 | registry 显式失败：缺失前置检查 + 解析失败打印 stderr + exit 1 | **PARTIAL——exit≠0 未达成（残留 P1）**（执行实证） | 探针 B/B2 重跑：两种失败路径均 `exit=0`（详见下） |
| P2-3 | 参数检查前置 `[ "$#" -lt 2 ]` | **FIXED**（执行实证） | 探针 C 重跑：无参 → usage 打印 + exit=2 |
| P2-4 | 无修复项（P5 裁决时复核的观察） | 不适用 | — |

### 残留 P1-1（增量）：registry 失败的 exit code 仍不传播

- 修复后的 `exit 1`（第 171、179 行）位于 `{ ... } | LC_ALL=C sort -u > "$RAW_OUT"` 管道**子 shell**内；脚本只有 `set -u`（第 19 行），无 `set -o pipefail`——管道退出码取最后一环 sort 的 0，`exit 1` 不传播到主 shell。
- 探针 B（registry 文件缺失）：stderr 正确打印 `generate-inventory: .tad/sync-registry.yaml missing — cannot compute downstream_summary`（不再静默，全零 summary 行已消除——比修复前改进），但随后 manifest 段读取不存在的 `$TMP/registry.rows`（第 212 行报 redirection 错），写出 0 字节 manifest，**最终 exit=0**。
- 探针 B2（registry 存在但 YAML 损坏）：同样打印错误 + Psych 回溯（不再静默），raw 缺 downstream_summary 行，manifest 0 字节，**exit=0**。
- 残留危害：Phase 6 复用生成器重出迁移 manifest 时，registry 故障仍会以 exit 0 + 空 manifest 交付，仅凭退出码判断的调用方仍会被误导（空 manifest 是 Phase 6 迁移输入）。本单流程内 AC7 fresh diff 仍可捕获，故不升 P0。
- 建议修复（最小）：`set -u` 后加 `set -o pipefail`；或将 registry 检查/解析移出管道（先解析到变量再进块），使 `exit 1` 在主 shell 生效。修复后重跑探针 B 应得 exit=1。

### 修复后 AC 复跑（逐字，执行实证）

- `AC2-PASS` + `AC2-PARITY-PASS`（生成器改动后 fresh raw 与 mapped 前三列 diff 仍为空，35/35 parity 不变）
- `AC7-PASS registered=14 reachable=12 missing=2 with_full=12 with_lite=1 active_full_handoffs=37`（manifest fresh diff 为空）
- `AC9-PASS`（8 文件路径集精确）

### 增量 verdict: CONDITIONAL

- P0 = 0；新增 P1 = 1（registry 失败 exit code 传播，P2-2 残留）；P2 无新增。
- P1-1、P2-1、P2-3 三项修复验证有效；P2-2 部分修复（错误可见、全零行消除）但"exit≠0"承诺未达成。
- 条件：为 registry 失败路径补上退出码传播（`set -o pipefail` 或把检查移出管道），并用探针 B/B2 复验 exit=1。闭合后即可转 PASS。
- 说明：Blake-Lite 自述"缺 registry 时 exit≠0"未获支持——实测两种失败路径均 exit=0（本段探针 B/B2 原始输出见下）。

### 增量执行证据

1. 探针 A 重跑（修复后，scratch git repo，tracked+untracked 无关键词 HANDOFF）→
   ```
   live_contract_consumer	.tad/active/handoffs/HANDOFF-silent-no-keywords.md	fs-walk:active-dir
   live_contract_consumer	.tad/active/handoffs/HANDOFF-untracked-no-keywords.md	fs-walk:active-dir
   ```
   （tracked 变体不再丢失；P2-1 闭合）

2. 探针 C 重跑（无参）→ `usage: ... <raw.tsv> <handoffs.tsv>` + `exit=2`（P2-3 闭合）

3. 探针 B 重跑（registry 缺失）→
   ```
   generate-inventory: .tad/sync-registry.yaml missing — cannot compute downstream_summary
   .../registry.rows: No such file or directory
   exit=0
   ```
   raw 无 downstream_summary 行；manifest 0 字节（P2-2 残留 P1 的依据）

4. 探针 B2 重跑（corrupt YAML）→ `generate-inventory: cannot parse .tad/sync-registry.yaml` + Psych 回溯 + `exit=0`；raw 无 downstream_summary 行；manifest 0 字节

5. AC2 逐字 → `AC2-PASS` / `AC2-PARITY-PASS`；AC7 逐字 → `AC7-PASS registered=14 reachable=12 missing=2 with_full=12 with_lite=1 active_full_handoffs=37`；AC9 逐字 → `AC9-PASS`

---

## 增量复核 2（2026-08-09，P2-2 残留修复后，终轮）

Harness: Claude Code | Model: deepseek-v4-flash | Route: blake-lite L3 code-reviewer（终轮确认）

### 修复核对（执行实证）

1. `set -o pipefail` 已加在 `set -u` 之后（第 20 行，带 P2-2 注释）——管道任一环节失败即整体失败，`{ }` 块内子 shell 的 `exit 1` 现可传播到调用方。
2. raw 管道尾部失败守卫：`} | LC_ALL=C sort -u > "$RAW_OUT" || { echo "generate-inventory: inventory generation failed" >&2; exit 1; }`——`||` 分支在主 shell 执行，exit 1 生效。
3. pipefail 对脚本内其它管道无行为回归（读码核对 + 实证）：`git grep | sort` 无命中时结果仍为空集；`find ... | while` 尾环正常；manifest 段管道尾环正常。

### 探针终验（scratch 重跑，全部执行实证）

| 探针 | 场景 | 结果 |
|------|------|------|
| B | registry 缺失 | stderr `generate-inventory: .tad/sync-registry.yaml missing — cannot compute downstream_summary` + `generate-inventory: inventory generation failed`，**exit=1**，**manifest 文件未创建** |
| B2 | registry corrupt YAML | stderr `cannot parse .tad/sync-registry.yaml` + Psych 回溯，**exit=1**，**manifest 文件未创建** |
| C | 无参（回归） | usage + **exit=2**，无回归 |

P2-2 残留闭合，且优于最低要求：失败时守卫在 manifest 段之前退出，**不再产出 0 字节 manifest**——Phase 6 迁移输入的空 manifest 静默交付风险彻底消除。

### 无回归确认（执行实证）

- `bash -n` 通过；AC2/AC7 数据面：fresh raw diff 与 manifest diff 均空（`AC2/AC7 fresh diffs: empty (both)`）
- AC9 逐字复跑 → `AC9-PASS`（8 文件路径集精确）

### 新增发现

无（P0=0，P1=0，P2=0）。

### 终轮 verdict: PASS

- 首轮 P1-1 / P2-1 / P2-3 与增量复核 1 的 P2-2 残留全部闭合并经执行实证；AC1–AC8 复跑 PASS、AC9 落盘后复跑 PASS；无新增发现。
- 全部探针在 scratch/临时目录完成，仓库只读纪律保持；唯一写产物为本 reviewer 报告。

### 终轮执行证据

1. 探针 B → `generate-inventory: .tad/sync-registry.yaml missing — cannot compute downstream_summary` / `generate-inventory: inventory generation failed` / `exit=1` / `manifest.tsv: No such file or directory`
2. 探针 B2 → `generate-inventory: cannot parse .tad/sync-registry.yaml` + `Psych::SyntaxError` 回溯 / `generate-inventory: inventory generation failed` / `exit=1` / `manifest2.tsv: No such file or directory`
3. 探针 C → `usage: ... <raw.tsv> <handoffs.tsv>` / `exit=2`
4. `bash -n generate-inventory.sh` + 双 diff（raw/manifest）→ 均空
5. AC9 逐字 → `AC9-PASS`

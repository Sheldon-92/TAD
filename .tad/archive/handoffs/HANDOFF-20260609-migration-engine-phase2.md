---
# Quality Chain Metadata (Alex 必填)
task_type: code
e2e_required: yes      # fixture harness 全量运行输出 = E2E evidence
research_required: no
git_tracked_dirs: [".tad/hooks/lib", ".tad/tests/migration-fixtures"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-09
**Project:** TAD Framework
**Task ID:** TASK-20260609-002
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260609-upgrade-lifecycle-system.md (Phase 2/6)
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-06-10 00:45

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 引擎流程图 + 单咽喉点 + fail-closed 链完整；9 P0 全部整合（§9.2 Audit Trail 22 行全 Resolved） |
| Components Specified | ✅ | guarded_remove 自包含重验契约、line-parser 形态白名单、TSV status 枚举冻结、14 fixture 判别矩阵 |
| Functions Verified | ✅ | MQ2：derive-sync-set --zero-touch / validator 片段 / version_le / exit 契约均 Read 实证 |
| Data Flow Mapped | ✅ | MQ3：manifest→validate→execute→report 四级流 + 消费者表 |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。
唯一降级项：AC0 live dry-run 因 Bash 分类器会话中断未实跑，已静态验证并升格为 Blake Task 0 硬性 preflight 门 — 诚实记录于 AC Dry-Run Log。

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] **完整阅读了 Phase 1 schema 文档**（本 Phase 的宪法）：`.tad/evidence/designs/migration-manifest-schema-v1.md`
- [ ] **完整阅读了 DR-2 含 Amendment**：`.tad/decisions/DR-20260609-user-modified-detection.md`（⚠️ Amendment 推翻了原 Decision section — 以 Amendment 为准）
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 1.1 What We're Building

`migration-engine.sh` — 消费 Phase 1 定义的 migration manifest（`.tad/migrations/{from}-to-{to}.yaml`）并安全执行升级操作的共享引擎，加上一套可重复运行的 E2E fixture harness 证明它在 8 类场景下行为正确（含恶意 manifest 的 fail-closed 拒绝）。

### 1.2 Why We're Building It

**业务价值**：TAD 远程升级目前不清理废旧文件、不处理重命名，且现有删除机制（tad.sh apply_deprecations）是无路径校验的裸 `rm -rf`。本引擎是替代它的唯一执行体。
**成功的样子**：fixture 套件一条命令全绿；恶意 manifest 注入 ZERO_TOUCH 路径时引擎拒绝执行且目标目录 byte-identical。

### 1.3 Intent Statement（意图声明）

**真正要解决的问题**：把"升级时删什么/改什么"从隐式行为变成被五步安全流水线守护的声明式执行，且每一步可验证、可幂等重跑、绝不误删用户内容。

**不是要做的（避免误解）**：
- ❌ 不是修改 tad.sh 或 *sync（那是 Phase 3 — 本 Phase 引擎独立可调用即可）
- ❌ 不是实现 merge 执行（Phase 4 — merge 条目只输出"需手动处理"）
- ❌ 不是批量生成历史 manifest（Phase 5）
- ❌ 不是重写 schema — schema v1 已冻结，引擎是 schema 的第一个 consumer，必须逐条遵守 FR1.5 Consumer Semantics Contract

**Blake请确认理解**：
```
1. 这个引擎解决什么问题？
2. 谁会调用它（Phase 3 的两个调用方）？
3. 成功的标准是什么？
```

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别
- [x] architecture（principles.md SAFETY entries）
- [x] shell-portability
- [x] ac-verification
- [x] gate-design

### 步骤 2：历史经验摘录

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| principles.md | 4 条 | deny-list 的安全在 EXCLUSION 断言；diff -rq 是终极验证；粒度对称 |
| patterns/shell-portability.md | 6 条 | 无 grep -P；LC_ALL=C；heredoc sink 区分；命令替换吞 GATE 标记 |
| patterns/ac-verification.md | 2 条 | shell case-glob 反斜杠双坑（Phase 1 KA）；dry-run 纪律 |

**⚠️ Blake 必须注意的历史教训**：

1. **Deny-List 的安全全在 EXCLUSION 断言**（principles.md 2026-06-01）— 引擎的 ZERO_TOUCH 检查是承重墙：漏删只是垃圾，误删进 ZERO_TOUCH 是数据损失。恶意 manifest fixture（AC9/AC10）是本 handoff 的 load-bearing AC。
2. **Command Substitution Swallows Gate Markers**（shell-portability 2026-06-09）— 引擎内 helper 经 `$( )` 调用时，`exit` 只杀子 shell 且 stdout 被吞。机器可读标记必须在主脚本上下文 emit；helper 只返回非零 + 诊断走 stderr。
3. **comm/sort 必须 LC_ALL=C**（shell-portability 2026-05-31）— 所有 sort/comm 一律 `LC_ALL=C`，本仓库路径含空格 + reason 字段含中文。
4. **shell case-glob 反斜杠**（ac-verification 2026-06-09, Phase 1 KA）— validator 片段的 `*\\*`（无引号）匹配单反斜杠；从 schema 文档提取 validator 时不得"顺手修正"成带引号形式。
5. **Copy-After-Deprecation Ordering**（shell-portability 2026-06-07）— 执行顺序是 load-bearing。引擎内 section 顺序 rename→delete→merge→verify 是 schema FR1.5d 的契约，不是实现自由。
6. **apply_deprecations 是反面教材**（DR-3 / tad.sh:726）— `rm -rf -- "$target"` 无 prefix/symlink/realpath/ZERO_TOUCH 校验。引擎不得复制这个模式；所有删除必须先过五步流水线。

### Blake 确认
- [ ] 我已阅读上述历史经验
- [ ] 我理解需要避免的问题

---

## 2. Background Context

### 2.1 Previous Work（已有基础 — 复用不重写）
- **Schema v1**（`.tad/evidence/designs/migration-manifest-schema-v1.md`）：含可直接提取的 BSD 兼容 validator 片段（Steps 1-3，L367-423），引擎 MUST 提取复用而非重写
- **示例 manifest**：`.tad/migrations/2.26.0-to-2.27.0.yaml`（3 delete + 4 verify，已通过严格 YAML 解析）
- **derive-sync-set.sh**：`--zero-touch` 公共 flag（9 目录）— 引擎运行时调用它构建拒绝列表，绝不抄写目录名
- **release-verify.sh**：exit 0/1/2 约定先例（0=pass, 1=违规, 2=用法/环境错误）
- **DR-2 Amendment**：混合检测策略（git-show 检测 → 改过=跳过；未改=备份后删；检测不可用=跳过）
- **DR-3**：执行顺序契约（apply_deprecations 冻结处理 ≤v2.26.0；引擎处理 v2.27.0+；无重叠）

### 2.2 Current State
引擎不存在。`.tad/tests/` 目录不存在（本 Phase 创建）。

### 2.3 Dependencies
- bash 3.2+（macOS 默认）、git（检测用，可缺失→降级）、`derive-sync-set.sh`
- **无 yq / python3 / PyYAML 运行时依赖**（见 §11 决策 D1）

---

## 3. Requirements

### 3.1 Functional Requirements

- **FR1 CLI 接口**：`bash .tad/hooks/lib/migration-engine.sh --from <ver> --to <ver> --target <dir> --source <dir> [--dry-run]`
  - `--source` = 框架仓库根（manifest 在 `$source/.tad/migrations/`，git tags 在此查询）
  - `--target` = 被升级的项目根
  - 版本号为带引号三段 semver 的裸值（如 `2.26.0`），与 manifest FR4d 一致
- **FR2 Manifest 解析（fail-closed line-parser）**：按 schema v1 的冻结形态写受限行解析器。在 delete/rename/merge section 内遇到任何不认识的行/字段 → 拒绝整个 manifest（FR1.5b）；verify section 未知字段 → warn + 忽略该字段；`schema_version` ≠ 1 → 硬失败并建议升级引擎/clean reinstall（FR1.5a）。**必须接受的合法形态（CR-P0-3）**：
  - 空 section 三等价形态（FR1.5e）：`delete: []` / `delete:`（null）/ 整个 key 缺失 → 均为"该 section 零操作"，不得 REJECT
  - rename 条目携带必填 `type:` + 可选 `reason:`（schema L133）；rename 条目缺 `type:` → REJECT
  - `generated_by` 解析后忽略（Phase 5 的消费者，引擎接受不处理）
- **FR2b min_engine_version 强制（CR-P0-3c）**：引擎头部定义 `ENGINE_VERSION` 常量（初始 `"2.28.0"`，随发版更新）。manifest 含 `min_engine_version` 且 `version_le(min_engine_version, ENGINE_VERSION)` 不成立 → exit 2 + "请升级 migration engine（当前 {ENGINE_VERSION}，需要 ≥ {min}）或 clean reinstall"。比较用 `sort -V`（与 tad.sh version_le 同语义）
- **FR3 Manifest 级校验（执行前，全部通过才动第一个文件）**：
  - 文件名 `{from}-to-{to}.yaml` 与字段一致（FR4e）
  - **跨 section 冲突矩阵（FR1.5c 全表，inline 复刻 — CR-P0-4）**：
    | 组合 | 判定 |
    |------|------|
    | delete + rename.from 同路径 | 非法 |
    | delete + rename.to 同路径 | 非法 |
    | delete + merge.path 同路径 | 非法 |
    | delete + verify.present 同路径 | 非法 |
    | rename.from = rename.to（同条目） | 非法 |
    | rename.to + rename.to（不同条目同目标） | 非法 |
    | rename.from + merge.path 同路径 | 非法 |
    | **delete + verify.absent 同路径** | **合法**（删后验证消失 — 规范模式，naive 全冲突检查会误杀） |
    | **rename.from + verify.absent 同路径** | **合法** |
    | 同 section 内重复路径 | 非法 |
  - 每个路径（**含 verify.path** — SA-P2-2）过五步流水线：Steps 1-3 用 schema 提取的 validator；Step 4 见 §4.2；Step 5 ZERO_TOUCH 见 FR3b
  - **整链先验后行（CR-P1-5）**：链中 ALL manifests 全部通过 parse + 校验后，才允许任何 manifest 的第一个文件操作。链中任一 manifest 非法 → exit 2 且全链零写入
- **FR3b ZERO_TOUCH 检查实现（SA-P0-1 / SA-P0-2）**：
  - **Authority fail-closed**：`zt_list=$(bash "$source/.tad/hooks/lib/derive-sync-set.sh" --zero-touch "$source")` 必须显式捕获 rc（不让 `$( )` 吞错）：rc ≠ 0 或输出为空 → **exit 2 零写入**（authority 不可用 = 拒绝执行，绝不 fail-open）。sanity 哨兵：输出必须包含 `project-knowledge`（已知稳定成员，不 pin 总数）
  - **物理解析比对（杀大小写/NFD 绕过类）**：不做字节前缀匹配。对候选路径的物理解析父目录（§4.2 cd+pwd -P）与每个 `$target/.tad/{zt_dir}` 的物理解析路径比对 — 解析后同 inode 路径前缀 → REJECT。这同时覆盖 macOS 大小写不敏感（`.tad/Project-Knowledge`）与 APFS NFD/NFC 变体
  - **段锚定**：匹配按路径段（`.tad/active` 本体和 `.tad/active/...` 都拒；`.tad/activex/` 不误拒）
  - **`.tad-backup` 保护（SA-P2-4）**：delete/rename 目标含 `.tad-backup` 段 → REJECT（manifest 不得删备份）
- **FR4 链解析**：扫描 `$source/.tad/migrations/`，按 `sort -V` 构建相邻链；`from >= to` → 拒绝（forward-only FR4b）；链有缺口 → exit 2 + 明确建议 clean reinstall（FR4c）；多 manifest 按版本序依次执行
- **FR5 执行核心（DR-2 Amendment 语义）**：对每个 delete / rename 条目：
  - a. 存在性：target 中不存在 → 记 `already-absent`，继续（幂等友好；仅在 oracle 未短路时到达 — 见 FR7 优先级）
  - b. 检测（`type: file`）：`git -C "$source" show "v{from}:{path}"` 与 target 文件比对（`cmp -s`）。⚠️ `set -e` 下 cmp/git show 的预期非零必须 `if`/`|| rc=$?` 守护（SA-P2-3），否则降级分支永远到不了
  - b2. **检测（`type: dir`，CR-P0-1）**：`git -C "$source" ls-tree -r --name-only "v{from}" -- "{path}"` 列出 from 版本下全部文件 → 逐文件 `cmp -s` 对比 target，**且** target 目录下不存在 from 列表之外的额外文件 → 全部相同且无额外 = 未修改；任一不同/任一额外文件/ls-tree 失败 → 视为用户修改 → SKIP
  - c. 内容不同（用户改过）→ **SKIP + report** `skipped-user-modified`（delete 不删；rename 不动，留在 from — CR-P1-2）
  - d. 未修改 → 备份到 `$target/.tad-backup/{from}-to-{to}/{path}`（保持目录结构）→ delete 执行删除 / rename 执行 `mv`（rename 也先备份 from 内容 — 移动同样破坏旧路径）
  - e. 检测不可用降级分类（CR-P1-6 taxonomy）：
    - 系统级（git 不存在/source 非 repo/tag 整体缺失）→ 全部条目 **SKIP** + `skipped-detection-unavailable`
    - 路径级（repo 正常但该路径在 v{from} 不存在 = 无基线）→ 该条目 **SKIP** + `skipped-no-baseline`
  - f. **单一删除咽喉点**：整个引擎只允许一处 `rm` 调用点（guarded_remove，自包含重验 — 见 §4.2）
  - g. **备份安全（SA-P1-1）**：备份目的路径同样过 Step 4 containment（防经 symlink 父链写出仓库）；`mkdir -p` 只在已验证的 contained 路径上执行；备份目标已存在 → **拒绝覆盖**，本条目 fail（exit 1）— 备份是唯一恢复机制，不得静默 clobber
- **FR6 执行顺序**：每个 manifest 内 rename → delete → merge → verify（FR1.5d，机械顺序不是建议）；merge 条目不执行，输出 `merge manual-required <path>`
- **FR7 幂等 oracle（CR-P0-2 修正）**：执行前先跑该 manifest 的 verify 断言。短路条件收紧：**仅当 verify section 非空 且 含至少一条 `type: absent` 断言 且 全部断言通过** → 输出 `already-applied`，跳过该 manifest。verify 为空/缺失 → **绝不短路**，直接执行（空断言集的 vacuous-true 不算"已应用"）。优先级（CR-P2-2）：oracle 是 manifest 级先判；FR5a `already-absent` 是 oracle 未短路时（如上次部分执行）的逐路径兜底
- **FR8 fail-fast**：任何操作失败（含 verify 失败）→ 立即停止，exit 1，报告已完成/未完成清单；不自动回滚（备份 + 幂等可重跑使回滚不必要 — Socratic 裁决）
- **FR9 双格式报告**：人读 stdout + 机器 TSV 写入 `$target/.tad-backup/{from}-to-{to}/MIGRATION-REPORT.tsv`，列：`action<TAB>status<TAB>path<TAB>detail`。机器报告是 Phase 3 调用方与 fixture 断言的稳定接口 — 列格式冻结
- **FR10 dry-run**：`--dry-run` 输出完整执行计划（含每条路径的检测结果预判）且零写入（连 .tad-backup/ 都不建）
- **FR11 Fixture Harness**：`bash .tad/tests/migration-fixtures/run-fixtures.sh` 一条命令跑全部 14 个用例（见 §8.2），每用例独立 tmp 沙箱（`mktemp -d`），harness 自建合成 source git 仓库（init + commit + tag v0.1.0/v0.2.0/v0.3.0 + 合成 manifest），不依赖真实 TAD 仓库的 tags；拒绝类用例先快照后断言 `diff -rq`；末行输出 `ALL FIXTURES PASS (14/14)` 或失败清单

### 3.2 Non-Functional Requirements

- **NFR1 BSD/macOS 兼容**：无 `grep -P`；所有 sort/comm 带 `LC_ALL=C`；路径展开全引号（本仓库路径含空格）；`printf` 不用 `echo -e`
- **NFR2 可移植 realpath**：macOS 旧版无 `realpath` — 用 `cd "$(dirname "$p")" && pwd -P` 组合实现 containment 检查，不依赖 GNU coreutils
- **NFR3 零运行时依赖**：引擎本体只依赖 POSIX 工具 + bash + git（git 缺失走降级路径，不报错退出）
- **NFR4 GATE 标记在主上下文 emit**：机器可读结果行不得在 `$( )` 内 echo（Command-Substitution-Swallows-Markers 教训）
- **NFR5 引擎不执行 manifest 内容**：manifest 值只作为数据；不 eval / source / 不在未引号上下文展开（heredoc 注入教训：file-write sink 可，interpreter sink 禁）

---

## 4. Technical Design

### 4.1 Architecture Overview

```
caller (Phase 3: tad.sh / *sync; 现在: fixture harness)
   │
   ▼
migration-engine.sh
   ├─ parse_args (FR1)
   ├─ resolve_chain (FR4)  ──── ls $source/.tad/migrations/ + sort -V
   ├─ for each manifest in chain:
   │    ├─ parse_manifest (FR2, fail-closed line-parser)
   │    ├─ validate_manifest (FR3: 冲突表 + 五步流水线 × 每路径)
   │    │      └─ zero_touch_list ← derive-sync-set.sh --zero-touch
   │    ├─ idempotency_oracle (FR7: pre-run verify)
   │    └─ execute (FR6 顺序):
   │         rename → delete   ──→ detect(git show) → skip / backup+rm（单咽喉点）
   │         merge  → report manual-required
   │         verify → assert absent/present
   └─ report (FR9: stdout + TSV)
```

### 4.2 Component Specifications

**Step 4 realpath containment（NFR2 可移植实现要点）**：
```bash
# 对将被操作的路径 p（相对 target 根）：
# 1. 逐组件检查 symlink：从 $target 起，对 p 的每一级前缀 [ -L ] 检查 → 任一是 symlink → REJECT
# 2. containment：物理解析父目录 (cd + pwd -P)，断言结果以 "$(cd "$target" && pwd -P)/" 为前缀
# 注意：对 delete 而言文件可能是 dangling 状态 — containment 检查父目录而非文件本身
```

**单一删除咽喉点（FR5f — SA-P0-3/P0-4 重设计：自包含重验，无环境 flag）**：
```bash
# 设计契约：guarded_remove 不信任调用方状态。参数传入，rm 前一刻内部重跑
# 全部 FS 态检查（Step 4 + Step 5 物理解析比对）+ 备份存在性断言。
# 理由 1（TOCTOU，SA-P0-3）：上游批量校验是快照；manifest 自身的 rename 在前
#   （FR6 顺序）可能改变后续 delete 路径的父链 — 必须在 rm 现场重验。
# 理由 2（stale state，SA-P0-4）：环境变量 flag 是 honor-system，循环迭代残留
#   即假通过。参数 + 现场重验使"忘了重置"这类 bug 在结构上不可能。
guarded_remove() {
  local p="$1" backup_path="$2"   # 无 VALIDATED/BACKED_UP 环境变量
  revalidate_step4 "$p"   || { printf 'ABORT: rm-site step4 recheck failed: %s\n' "$p" >&2; return 1; }
  revalidate_step5 "$p"   || { printf 'ABORT: rm-site zero-touch recheck failed: %s\n' "$p" >&2; return 1; }
  [ -e "$backup_path" ]   || { printf 'ABORT: backup missing before remove: %s\n' "$p" >&2; return 1; }
  rm -rf -- "$p"   # 整个引擎唯一的 rm（dry-run 模式下本函数整体不被调用）
}
```

**git show 调用安全（SA-P1-2）**：路径只在 `"v{from}:{path}"` 拼接形式中使用且必经 Step 2（leading `-` 已拒）。引擎额外在 Step 2 拒绝含 `:` 的路径（allow-list 前缀下合法路径永不含 `:` — 引擎比 schema 更严是允许的，反向不行）。`{path}` 永不作为独立 pathspec 参数传给 git。

**fail-closed line-parser（FR2）形态约束**：只接受 schema v1 冻结形态的行（`schema_version:` / `from:` / `to:` / `min_engine_version:` / `generated_by:` / section 头**含空 section 三形态** / delete 的 `  - path:`+`    type:`+`    reason:` / rename 的 `  - from:`+`    to:`+`    type:`+`    reason:` / merge 四字段 / verify 两字段 / 注释 / 空行）。destructive section 内任何其他行 → REJECT 整个 manifest。这是 FR1.5b fail-closed 在解析层的实现 — 解析器越笨越安全。

### 4.3 Data Models

机器报告 TSV（FR9，冻结）：
```
action	status	path	detail
rename	done	.tad/old.yaml	→ .tad/new.yaml
delete	skipped-user-modified	.claude/skills/x.md	content differs from v2.26.0
delete	skipped-detection-unavailable	.claude/skills/z.md	git/tag unavailable (systemic)
delete	skipped-no-baseline	.claude/skills/w.md	path absent at v2.26.0 (per-path)
delete	done	.claude/skills/y.md	backed up
merge	manual-required	CLAUDE.md	strategy=tad-head-marker
verify	pass	.claude/skills/y.md	absent as expected
summary	ok	-	deleted=1 skipped=3 manual=1
```
status 枚举冻结：`done / already-absent / already-applied / skipped-user-modified / skipped-detection-unavailable / skipped-no-baseline / manual-required / pass / fail / ok`。**字段净化（CR-P2-1）**：引擎写 TSV 前必须将任何字段内的 TAB/换行替换为空格（manifest 路径已被 validator 拒控制字符，但 detail 自由文本需独立净化）。

### 4.4 API Specifications — exit code 契约
| Exit | 含义 |
|------|------|
| 0 | 成功（含 already-applied / dry-run） |
| 1 | 执行中失败（fail-fast 停止；报告含已做/未做） |
| 2 | 拒绝执行：用法错 / manifest 非法 / 链缺口 / schema_version 或 min_engine_version 不支持 / 路径校验失败 / ZERO_TOUCH authority 不可用（**全链零写入** — 链中任一 manifest 非法时，前序 manifest 也不得已执行，见 FR3 整链先验后行） |

### 4.5 User Interface Requirements — N/A（CLI）

---

## 5. 强制问题回答（Evidence Required）

### MQ1: 历史代码搜索
- [x] 是 → 现有删除逻辑：`apply_deprecations` tad.sh:676-737（裸 rm -rf，DR-3 已裁决冻结，引擎不复用其代码但复用其 `version_le`/`sort -V` 比较语义）；validator 片段：schema 文档 L367-423（**复用：提取**）；ZERO_TOUCH：derive-sync-set.sh `--zero-touch`（**复用：调用**）
- **决定**：引擎新建；validator 提取复用；zero-touch flag 调用复用；不写第二份目录列表

### MQ2: 函数存在性验证
| 函数/接口 | 文件位置 | 行号 | 验证 |
|--------|---------|------|------|
| `derive-sync-set.sh --zero-touch` | .tad/hooks/lib/derive-sync-set.sh | L104-106 | ✅ Alex Read 确认 |
| `validate_path()` validator 片段 | .tad/evidence/designs/migration-manifest-schema-v1.md | L367-423 | ✅ Alex Read 确认（含 `*\\*` 修正后形态） |
| `version_le()` 语义先例 | tad.sh | L740-745 | ✅ Alex Read 确认（sort -V） |
| exit 0/1/2 先例 | .tad/hooks/lib/release-verify.sh | 头部契约 | ✅ Alex Read 确认 |

### MQ3: 数据流完整性
| 输入 | 处理 | 输出 | 消费者 |
|---------|---------|---------|-----------|
| manifest 链 ($source/.tad/migrations/) | parse→validate→execute | 文件系统变更 + .tad-backup/ | 升级后的 target |
| derive-sync-set.sh --zero-touch | 运行时拒绝列表 | REJECT 判定 | validate_manifest |
| git show v{from}:{path} | cmp 比对 | skip/delete 决策 | execute |
| 执行结果 | report 函数 | stdout + MIGRATION-REPORT.tsv | 人 + fixture + Phase 3 调用方 |

### MQ4: 视觉层级 — [x] 无不同状态（CLI 工具），跳过
### MQ5: 状态同步 — 状态只存在于文件系统 + 报告文件，单向写出，无双向同步

---

## 6. Implementation Steps

### Task 0: Preflight（硬性门 — 不可跳过）
1. `bash .tad/hooks/lib/derive-sync-set.sh --zero-touch; echo "rc=$?"` → rc=0 且输出非空 且 含 `project-knowledge`（AC0 r2 形态，不 pin 总数）
2. `git -C . show v2.26.0:.tad/version.txt | head -1` → 必须输出 `2.26.0`（git-show 检测路径可用性验证）
3. `bash -n .tad/hooks/lib/derive-sync-set.sh` → exit 0
任一失败 → STOP，报告 Alex，不开始实现。

### Task 1: validator 提取 + Step 4/5 安全层（预计 1.5h）
- 从 schema 文档 L367-423 提取 `validate_path()`（逐字，保留 `*\\*` 形态）
- 实现 Step 4（§4.2 可移植 realpath + per-component symlink 检查）和 Step 5（zero-touch 运行时列表，前缀匹配 `.tad/{zt_dir}/`）
- 自检：合法/非法示例对（schema L425-437）实跑双向判别

### Task 2: fail-closed line-parser（预计 2h）
- 按 §4.2 形态约束实现；对示例 manifest `2.26.0-to-2.27.0.yaml` 解析出 3 delete + 4 verify
- 负例自检：往副本注入未知字段（`platform: codex`）到 delete 条目 → REJECT

### Task 3: 链解析 + 幂等 oracle（预计 1.5h）
- `sort -V` 链构建、forward-only、缺口检测（exit 2 + clean-reinstall 文案）
- pre-run verify 全过 → `already-applied` 跳过

### Task 4: 执行核心（预计 2.5h）
- FR5 a-f 完整实现（检测/跳过/备份/单咽喉点删除）；FR6 顺序；FR8 fail-fast；FR10 dry-run 零写入
- ⚠️ 报告行 emit 在主上下文（NFR4）

### Task 5: 报告层（预计 1h）
- stdout 人读 + TSV 机器报告（FR9 冻结列）

### Task 6: Fixture Harness + 14 用例（预计 4h）
- harness 自建合成 source git 仓库（git init / commit / tag / 合成 manifest）+ target 沙箱
- 14 用例见 §8.2；拒绝类先快照；混合 manifest 做对比判别；断言用 `diff -rq` / `cmp` / TSV grep，不 grep 人读文案

### Task 7: 全量运行 + 收尾（预计 0.5h）
- `run-fixtures.sh` 全绿输出存档到 completion report；§9.1 全行验证

---

## 7. File Structure

### 7.1 Files to Create
```
.tad/hooks/lib/migration-engine.sh            # 引擎本体
.tad/tests/migration-fixtures/run-fixtures.sh # harness 入口（含 8 用例）
.tad/tests/migration-fixtures/README.md       # 用例清单 + 如何新增用例
```
（合成 source 仓库 / target 沙箱在 mktemp -d 中运行时构建，不入库）

### 7.2 Files to Modify
（无 — 本 Phase 零修改现有文件）

### 7.3 Grounded Against (Alex step1c 实际 Read 过的源文件)
- .tad/hooks/lib/derive-sync-set.sh (全文 L1-135, read at 2026-06-09 23:40)
- tad.sh L660-754 (apply_deprecations + version_le, read at 2026-06-09 23:40)
- .tad/evidence/designs/migration-manifest-schema-v1.md (全文 L1-583, read at 2026-06-09 23:10)
- .tad/migrations/2.26.0-to-2.27.0.yaml (全文, read at 2026-06-09 23:15)
- .tad/decisions/DR-20260609-user-modified-detection.md (全文含 Amendment, read at 2026-06-09 23:20)
- .tad/decisions/DR-20260609-deprecation-yaml-disposition.md (全文, read at 2026-06-09 23:20)
- .tad/hooks/lib/migration-engine.sh (new — will be created)
- .tad/tests/migration-fixtures/ (new — will be created)

---

## 8. Testing Requirements

### 8.1 Unit Tests
单元级自检内嵌在 Task 1/2（validator 双向判别、parser 负例）— 不建独立单测框架。

### 8.2 Integration Tests — 14 个 Fixture 用例（即 E2E）

> 所有 F6/F7/F11/F12/F13 类（拒绝/安全类）用例的 harness 流程：**先快照**（`cp -a` target → snapshot）→ 跑引擎 → `diff -rq target snapshot` 断言（CR-P0-5e：拒绝类全部显式 pre-snapshot）。
> 对比类用例（F3/F4/F9）必须是**混合 manifest**（同 manifest 内既有应跳过又有应执行的条目），证明引擎区分而非一刀切（CR-P0-5c/d 反 skip-all 伪装）。

| # | 用例 | 核心断言 |
|---|------|---------|
| F1 | normal-upgrade | 旧文件删除 + .tad-backup/ 含备份 + verify pass + exit 0 |
| F2 | idempotent-rerun | 第二次运行 exit 0 + 前后 `diff -rq` 无差异 + 报告含 `already-applied`（oracle 短路，非逐路径 already-absent） |
| F3 | user-modified-mixed | **混合**：被改文件原地保留 + TSV `skipped-user-modified` ≥1；同 manifest 未改文件被删 + 备份在 + TSV `done` ≥1 |
| F4 | detection-unavailable | source 无 git → 全部 delete 跳过 + TSV `skipped-detection-unavailable` + 无 `done` 行 + target `diff -rq` 前后一致；**对比腿**：同一 manifest 在有 git 的 source 下 `done` ≥1（证明是降级不是 no-op） |
| F5 | chain-upgrade + gap | v0.1.0→v0.3.0 两 manifest 按序生效（两者的 delete 都验证）；抽掉中间 manifest → exit 2 + `clean reinstall` 文案 |
| F6 | malicious-zero-touch ×3 | (a) `.tad/project-knowledge/x` 精确 (b) `.tad/Project-Knowledge/x` 大小写变体（SA-P0-2） (c) rename.to 指向 `.tad/active/y`（rename INTO zt）→ 全部 exit 2 + `diff -rq` byte-identical（**load-bearing**） |
| F7 | malicious-path ×4 | (a) `..` traversal (b) 中间组件 symlink (c) **叶子组件** symlink（SA-P1-4） (d) 含 `:` 路径 → 全部 exit 2 零写入（**load-bearing**） |
| F8 | dry-run + merge | --dry-run 零写入（含不建 .tad-backup/）；merge 条目 → `manual-required` 行 + 文件 `cmp` 未动 |
| F9 | dir-delete 双分支（CR-P0-1） | **混合**：未修改目录（递归比对全同）→ 备份+删除；含用户新增文件的目录 → 原地保留 + `skipped-user-modified` |
| F10 | delete-only-no-verify（CR-P0-2） | manifest 无 verify section → **必须执行**（TSV `done` ≥1），不得报 `already-applied` |
| F11 | zt-authority-unavailable（SA-P0-1） | derive-sync-set.sh 不可用/输出为空（harness stub）→ exit 2 + target byte-identical（**load-bearing：fail-closed 不 fail-open**） |
| F12 | rm-site-recheck（SA-P0-3/P0-4） | manifest 内 rename 先把后续 delete 路径的父目录换成 symlink → guarded_remove 现场重验拒绝该条目（exit 1 fail-fast）+ symlink 指向的外部目录 byte-identical |
| F13 | mid-chain-malformed（CR-P1-5） | 合法 manifest #1 + 非法 manifest #2 组链 → exit 2 + `diff -rq` 干净（#1 也零写入 — 整链先验后行） |
| F14 | backup-collision（SA-P1-1） | 备份目标已存在 → 拒绝覆盖（exit 1）+ 原备份内容 `cmp` 未被改写 |

### 8.4 Test Evidence Required
- [ ] `run-fixtures.sh` 全量输出原文（`ALL FIXTURES PASS (14/14)`）
- [ ] F6/F7/F11/F12/F13 的 `diff -rq` 空输出证明（拒绝类零写入）

---

## 9. Acceptance Criteria

Blake 的实现被认为完成，当且仅当 §9.1 全行 PASS。

## 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE

> Pipe-escape note: 表格内 `\|` 实跑时还原为裸 `|`。所有 grep BSD 兼容（无 -P）。
> E = .tad/hooks/lib/migration-engine.sh；R = .tad/tests/migration-fixtures/run-fixtures.sh

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| AC0 | preflight：zero-touch flag 可用 | pre-impl-verifiable | `bash .tad/hooks/lib/derive-sync-set.sh --zero-touch; echo "rc=$?"` 且 `bash .tad/hooks/lib/derive-sync-set.sh --zero-touch \| grep -c 'project-knowledge'` | rc=0 且输出非空 且 哨兵 = 1（CR-P1-4：不 pin 总数，断言 authority 可用 + 已知稳定成员在列） | 静态验证：lib:53-61 字面量含 project-knowledge；live = Blake Task 0 硬性门（Bash 分类器中断，见 Dry-Run Log） |
| AC1 | 引擎语法干净 | post-impl-verifiable | `bash -n` E 且 `bash -n` R | 双 exit 0 | (post-impl) |
| AC2 | fixture 全绿 | post-impl-verifiable | `bash .tad/tests/migration-fixtures/run-fixtures.sh` | 末行 `ALL FIXTURES PASS (14/14)`，exit 0 | (post-impl) |
| AC3 | dry-run 零写入 | post-impl-verifiable | F8 断言：dry-run 前后 target `diff -rq` 输出行数 | = 0 且无 .tad-backup/ 生成 | (post-impl) |
| AC4 | 恶意 ZERO_TOUCH 注入 fail-closed | post-impl-verifiable | F6 断言：exit code + `diff -rq` 行数 | exit = 2 且 diff = 0 行 | (post-impl) |
| AC5 | traversal/symlink 注入 fail-closed | post-impl-verifiable | F7 断言：两种注入 exit code | 均 = 2，零写入 | (post-impl) |
| AC6 | 用户修改保护 | post-impl-verifiable | F3 断言：`test -f` 被改文件 且 `grep -c "skipped-user-modified" <TSV>` | 文件在 且 ≥ 1 | (post-impl) |
| AC7 | 检测不可用降级 | post-impl-verifiable | F4 断言：`grep -c "skipped-detection-unavailable" <TSV>` | ≥ 1 且无 delete done 行 | (post-impl) |
| AC8 | 幂等 | post-impl-verifiable | F2 断言：二跑 exit + `diff -rq` 行数 + `grep -c already-applied <stdout>` | exit 0 / 0 行 / ≥ 1 | (post-impl) |
| AC9 | 链式 + 缺口拒绝 | post-impl-verifiable | F5 断言：两 manifest 的 delete 各自生效；缺口跑 exit + `grep -ci "clean reinstall" <stderr>` | 生效 + exit 2 + ≥ 1 | (post-impl) |
| AC10 | 单一删除咽喉点 | post-impl-verifiable | `grep -nE '(^\|[^[:alnum:]_-])rm([[:space:]]\|$)' "$E"`（CR-P1-1 强化：词界 rm token 全量列出） | 恰好 1 个命中行，且该行位于 guarded_remove() 函数体内（行号区间人工核对 — grep 是哨兵，承重判定 = 单命中 + 位置核对） | (post-impl) |
| AC11 | 无 grep -P（NFR1） | post-impl-verifiable | `grep -cE 'grep -[a-zA-Z]*P' "$E" "$R"` | 每文件 = 0 | (post-impl) |
| AC12 | ZERO_TOUCH 不抄写（哨兵反查） | post-impl-verifiable | `grep -c 'derive-sync-set.sh --zero-touch' "$E"` 且 `grep -c 'skillify-candidates' "$E"` | 前者 ≥ 1；后者 = 0 | (post-impl) |
| AC13 | merge 不执行只报告 | post-impl-verifiable | F8 断言：`grep -c "manual-required" <TSV>` 且 merge 目标文件 `cmp` 前后 | ≥ 1 且 cmp 相同 | (post-impl) |
| AC14 | TSV 报告契约 | post-impl-verifiable | F1 后 `awk -F'\t' 'NF!=4{c++}END{print c+0}' <TSV>` | = 0（每行恰 4 列） | (post-impl) |
| AC15 | 交付完整 + 零越界 | post-impl-verifiable | `for f in <§7.1 三路径>; do test -f "$f" && echo OK; done` 且 `git status --short` 比对 | 3 OK；status 新增仅 §7.1 文件 | (post-impl) |
| AC16 | 合法冲突模式不误杀（CR-P0-4 正向判别） | post-impl-verifiable | F1 的 manifest 即含 `delete X` + `verify absent X`（规范模式）→ F1 PASS 本身即证明 | F1 PASS（含该模式的 manifest 被接受执行） | (post-impl) |
| AC17 | min_engine_version 强制（FR2b） | post-impl-verifiable | harness 内嵌断言：manifest 设 `min_engine_version: "99.0.0"` → 引擎 exit code | = 2 且 stderr 含 ENGINE_VERSION 提示 | (post-impl) |
| AC18 | validator 提取保真（CR-P2-3） | post-impl-verifiable | `grep -Fq '*\\*' "$E"; echo $?` | 0（未引号反斜杠 case 模式逐字存在 — 防"好心修正"） | (post-impl) |

**AC Dry-Run Log** (Alex step1d at 2026-06-10 00:30, 专家审查后 r2):
- AC0: ⚠️ pre-impl-verifiable — Bash 分类器会话级中断（与 Phase 1 同一故障），无法实跑。静态验证：derive-sync-set.sh:53-61 字面量含 `project-knowledge`（本 session Read 全文确认）。live run 升格为 Blake **Task 0 硬性门**。Expected 已按 CR-P1-4 从 `=9` 改为 rc+哨兵断言（不 pin 总数 — 与 principles "Never pin an absolute count" 一致）。
- AC1-AC18: post-impl-verifiable（全部目标文件是新建）。Sub-rule 2 语法审查逐条完成：grep 均 BSD 形态无 -P；AC10 r2 改为词界 ERE 全量列出（CR-P1-1 修复 — r1 的 `[^m] rm ` 漏行首 rm、`rm -fr` 反转 flag，已弃用）；AC14 awk 单进程列数校验；AC18 grep -F 字面匹配含反斜杠无正则歧义；管道 `\|` 已按 pipe-escape note 标注。
- AC2 的 "(14/14)" 计数与 §8.2 用例表一一对应（F1-F14），防 harness 静默跳例（no-silent-caps）。
- AC16 设计说明：正向判别（合法模式被接受）与 F6/F7 的负向判别（非法被拒）成对，防 naive 全冲突检查通过负向测试却误杀规范模式。

---

## 9.2 Expert Review Status (Alex 必填)

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | CR-P0-1: `type: dir` 检测语义未定义（git show/cmp 对 tree 无效） | FR5b2（ls-tree 递归比对 + 额外文件检查）+ F9 fixture | Resolved |
| code-reviewer | CR-P0-2: 空 verify 使幂等 oracle vacuous-true → delete-only manifest 被静默跳过 | FR7 短路条件收紧（非空 + ≥1 absent）+ F10 fixture | Resolved |
| code-reviewer | CR-P0-3: parser 白名单漏空 section 三形态 / rename type / min_engine_version 强制 | FR2 合法形态清单 + FR2b（ENGINE_VERSION + version_le 门）+ §4.2 parser 约束更新 + AC17 | Resolved |
| code-reviewer | CR-P0-4: 冲突矩阵按引用交付（含 2 个合法行会被 naive 检查误杀） | FR3 inline 10 行矩阵（含 2 合法行加粗）+ AC16 正向判别 | Resolved |
| code-reviewer | CR-P0-5: fixture 无法判别 skip-all 伪装 / 无 dir / 无 delete-only 用例 | §8.2 重构：F3/F4/F9 混合对比 manifest + F9/F10 新增 + 拒绝类显式 pre-snapshot | Resolved |
| code-reviewer | CR-P1-1: AC10 第二 grep 漏行首 rm / rm -fr 反转 | AC10 r2 词界 ERE 全量列出 + 位置核对；Dry-Run Log 不再过度声称 | Resolved |
| code-reviewer | CR-P1-2: rename 的用户修改/备份语义未定义 | FR5c/d rename 分支（skip 留原位 / mv 前备份 from） | Resolved |
| code-reviewer | CR-P1-3: .tad-backup 在 sync 推导面之外 | §10.2 显式约束 + Epic Context 已记 Phase 3 carry-forward | Resolved |
| code-reviewer | CR-P1-4: AC0 pin =9 与 principles "never pin count" 自相矛盾 | AC0 改 rc+非空+哨兵成员断言 | Resolved |
| code-reviewer | CR-P1-5: 链式校验顺序未定（中途 exit 2 违反零写入） | FR3 整链先验后行 + §4.4 全链零写入 + F13 fixture | Resolved |
| code-reviewer | CR-P1-6: 检测不可用与无基线混报 | FR5e 双状态 taxonomy（systemic vs per-path）+ TSV 枚举冻结 | Resolved |
| code-reviewer | CR-P2-1/P2-2/P2-3/P2-4: TSV 净化 / oracle 优先级 / validator 保真 AC / generated_by 忽略 | §4.3 净化规则 + FR7 优先级句 + AC18 + FR2 | Resolved |
| security-auditor | SA-P0-1: zt authority 失败 = fail-open（$( ) 吞 rc → 空列表 → 全放行） | FR3b authority fail-closed（显式 rc + 非空 + 哨兵）+ F11 fixture（load-bearing） | Resolved |
| security-auditor | SA-P0-2: macOS 大小写不敏感/NFD 绕过字节前缀匹配 | FR3b 物理解析比对（pwd -P 后比对）+ F6b 大小写变体 fixture | Resolved |
| security-auditor | SA-P0-3: TOCTOU — 校验快照与 rm 现场之间父链可被换（manifest 自身 rename 即可触发） | §4.2 guarded_remove 重设计（rm 现场重跑 Step4+Step5）+ F12 fixture | Resolved |
| security-auditor | SA-P0-4: VALIDATED/BACKED_UP 全局 flag 跨迭代残留假通过 | §4.2 弃用环境 flag — 参数传入 + 自包含重验（结构性消除） | Resolved |
| security-auditor | SA-P1-1: 备份 cp -a 经 symlink 父链可写出 / 备份覆盖破坏恢复机制 | FR5g（备份目的路径过 Step4 + mkdir -p 限 contained + 拒绝覆盖）+ F14 fixture | Resolved |
| security-auditor | SA-P1-2: git show pathspec `:` 面 | §4.2 git show 调用安全（引擎级拒 `:`）+ F7d fixture | Resolved |
| security-auditor | SA-P1-3: hardlink 不可检测 | §10.2 显式残余风险声明（bounded by Step3+containment） | Resolved |
| security-auditor | SA-P1-4: 叶子组件 symlink 是否在 -L 扫描内有歧义 | §4.2 Step4 明确含叶子 + rename.to 父链 + F7c fixture | Resolved |
| security-auditor | SA-P2-1/P2-2/P2-4: zt 段锚定 / verify.path 过流水线 / .tad-backup 自保护 | FR3b 段锚定 + FR3（含 verify.path）+ FR3b .tad-backup 拒绝 | Resolved |

### Experts Selected
1. **code-reviewer** — shell 引擎实现质量、单咽喉点设计、parser fail-closed 完整性
2. **security-auditor** — 破坏性操作路径安全（五步流水线实现保真度、symlink/traversal 向量、恶意 manifest fixture 覆盖度）

### Overall Assessment (post-integration)
- code-reviewer: CONDITIONAL PASS → **PASS**（5 P0 + 6 P1 + 4 P2 全部 Resolved）
- security-auditor: FAIL → **PASS**（4 P0 + 4 P1 + 3 P2 全部 Resolved；其 10 项 fixture 缺口建议吸收为 F6×3/F7×4/F11/F12/F14 + AC17）

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ **DR-2 以 Amendment 为准** — 原 Decision section（纯 Option D）已被人类裁决推翻。实现 FR5 时照 Amendment 的混合语义，不照原文
- ⚠️ **`rm` 只许出现一次**（AC10）— 发现自己要写第二个 rm 时，说明控制流设计错了，回到 guarded_remove 漏斗
- ⚠️ **exit 2 路径必须零写入** — 所有校验在第一次文件操作之前完成（FR3"全部通过才动第一个文件"）
- ⚠️ **fixture 断言用机器报告（TSV）+ diff -rq，不 grep 人读文案** — 文案措辞是 UI，会变；TSV 列是契约，冻结

### 10.2 Known Constraints
- 引擎运行环境可能没有 yq/python3 — 解析必须纯 POSIX 工具（决策 D1）
- 本仓库绝对路径含空格 — 所有展开必须引号
- merge / tad.sh 接入 / 历史 manifest 都不在本 Phase
- **`.tad-backup/` 在 repo root，处于 derive-sync-set `.tad/*/` 推导面之外（CR-P1-3）**：Phase 3 接入 *sync 时必须显式排除（`--transient` 不会捕到它）— 已记入 Epic Context for Next Phase
- **hardlink 残余风险（SA-P1-3，已知未覆盖）**：Step 4 的 `-L` 只覆盖 symlink；hardlink 别名不可检测。暴露面被 Step 3 前缀 allow-list + containment 限定为"删除被 hardlink 进管理区的文件只断该链接"，severity 低 — 显式声明以免被误认为已覆盖

### 10.3 Sub-Agent使用建议
- [ ] **test-runner** — Task 6 完成后跑全量 fixture
- [ ] **bug-hunter** — fixture 失败且 root cause 不明时

---

## 11. Learning Content

### 11.1 Decision Rationale: D1 — Manifest 解析器策略

**选择的方案**：受限 fail-closed line-parser（纯 POSIX）

| 方案 | 优点 | 缺点 | 为什么没选 |
|------|------|------|-----------|
| 受限 line-parser（选中） | 零依赖；笨=安全（未知形态即拒绝 = FR1.5b 的解析层实现）；schema 冻结使形态可枚举 | 解析器与 schema 版本耦合（schema v2 需改引擎 — 但 FR1.5a 本来就要求这样） | ✅ 选中 |
| yq (mikefarah) | 真 YAML 解析 | 远程 tad.sh 用户大概率没装；版本碎片化 | 运行时依赖不可接受 |
| python3 + PyYAML | 真 YAML 解析 | PyYAML 非标准库；mac 系统 python 不稳定 | 同上 |

**权衡分析**：核心权衡是"解析完备性 vs 零依赖 + fail-closed"。manifest 是机器写/人审的受控格式（NFR3 YAML 陷阱规则保证形态可预测），不是任意 YAML — 受限解析器在这个域里不是妥协而是更强的校验。

**💡 Human学习点**：当输入格式自己可控且冻结时，"只认识白名单形态、其余拒绝"的笨解析器比全功能解析器更安全 — 解析能力越强，被喂垃圾时的静默接受面越大。

---

## 12. Sub-Agent使用记录

（Blake 完成后填写）

| Sub-Agent | 是否调用 | 调用时机 | 输出摘要 | 证据链接 |
|-----------|---------|---------|---------|---------|

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-06-09
**Version**: 3.1.0

---
task_type: code
e2e_required: yes
research_required: no
git_tracked_dirs: ["tad.sh", ".tad/hooks/lib", ".claude/skills/alex/references"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-10
**Project:** TAD Framework
**Task ID:** TASK-20260610-001
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260609-upgrade-lifecycle-system.md (Phase 3/6)
**Supersedes:** N/A

---

## Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-06-10

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 两条调用路径（tad.sh + *sync）的集成序列完整映射，含版本捕获时序、引擎调用位置、退出码处理 |
| Components Specified | ✅ | 改动范围明确：tad.sh（3 处修改）、derive-sync-set.sh（TRANSIENT 新增）、sync-protocol.md（新增 step3.b2） |
| Functions Verified | ✅ | 所有引用函数均已 Read 验证存在（见 MQ2 表格） |
| Data Flow Mapped | ✅ | old_version 捕获 → engine 调用 → exit code 分支 → 后续流程，每步数据源标注 |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## Handoff Checklist (Blake必读)

Blake在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] **阅读了「Project Knowledge」章节中的历史经验**
- [ ] 所有"强制问题回答（MQ）"都有证据
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 每个Phase的交付物和证据要求都清楚
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 1.1 What We're Building
将 Phase 2 完成的 migration-engine.sh 接入两条升级路径 — tad.sh（远程 curl 安装）和 *sync（本地同步协议），使两者共用同一个引擎执行 migration，零双实现。同时修复 carry-forward 遗留项（`.tad-backup/` 排除、tad.sh:721 注释 bug）。

### 1.2 Why We're Building It
**业务价值**：升级时旧文件自动清除、重命名自动处理，用户升级后不再有废弃文件残留
**用户受益**：14 个注册项目和所有远程用户的升级路径统一走引擎，行为一致
**成功的样子**：当用户跑 `bash tad.sh --yes` 升级时，migration 自动执行；当 Alex 跑 `*sync` 时，每个项目的 migration 也自动执行 — 两条路径的报告格式一致

### 1.3 Intent Statement

**真正要解决的问题**：Phase 2 的 migration-engine.sh 是一个独立可调用的 lib，但目前没有任何调用方 — 它"悬空"着。本 Phase 把它接上两条真实路径，让 migration 从"可以跑"变成"升级时自动跑"。

**不是要做的（避免误解）**：
- ❌ 不是修改 migration-engine.sh 的核心逻辑（除非接入时发现接口缺口）
- ❌ 不是生成历史 manifest（Phase 5）
- ❌ 不是实现 merge 执行（Phase 4）
- ❌ 不是对真实注册项目跑升级（Phase 6）
- ❌ 不是重写 tad.sh 的 copy_framework_files — 只在其前后插入版本捕获和引擎调用

**Blake请确认理解**：
```
在开始实现前，请用你自己的话回答：
1. 这个功能解决什么问题？
2. tad.sh 中引擎调用的时序约束是什么？（为什么不能在 copy 之前调用？）
3. 两条路径的"零双实现"具体怎么保证？

只有Human确认你的理解正确后，才能开始实现。
```

---

## Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别

本次任务涉及的领域（勾选所有适用项）：
- [x] code-quality - Shell 脚本模式
- [x] architecture - 两条路径统一引擎
- [x] testing - fixture harness 扩展

### 步骤 2：历史经验摘录

**已读取的 project-knowledge 文件**：

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| principles.md | 4 条 | Never Hand-Write What an Existing Tool Already Does; Deny-List granularity对称; diff -rq 是终极验证 |
| patterns/shell-portability.md | 1 条 | macOS/BSD grep/sed/sort 兼容 |
| patterns/ac-verification.md | 1 条 | AC 必须是可执行的 grep/bash 断言 |

**Blake 必须注意的历史教训**：

1. **Never Hand-Write What an Existing Tool Already Does** (来自 principles.md)
   - 问题：Alex 曾手写安装脚本绕过 tad.sh，导致 14/32 目录缺失
   - 解决方案：两条路径都调用同一个 migration-engine.sh，不在 tad.sh 或 sync-protocol 中内联任何 delete/rename 逻辑

2. **Deny-List Must Be Applied at EVERY Copy Granularity** (来自 principles.md)
   - 问题：修了目录级 deny-list 但文件级仍用 extension allow-list，导致 portable-extract.sh 丢失
   - 解决方案：`.tad-backup/` 排除必须同时加到 derive-sync-set.sh TRANSIENT 和 tad.sh 内联 TAD_TRANSIENT

3. **Shell Portability** (来自 patterns/shell-portability.md)
   - 问题：macOS bash 3.2 不支持某些 bash 4 特性
   - 解决方案：tad.sh 中的新代码必须兼容 bash 3.2（不用 `local -n`、`declare -A`、`${var,,}`）

### Blake 确认

- [ ] 我已阅读上述历史经验
- [ ] 我理解需要避免的问题
- [ ] 如遇到类似情况，我会参考上述解决方案

---

## 2. Background Context

### 2.1 Previous Work
- **Phase 1** (commit eab1fd8): Schema v1 定稿 + 3 DR + 示例 manifest `2.26.0-to-2.27.0.yaml`
- **Phase 2** (commit fe11b95 + 7e2a945): migration-engine.sh 实现 (~450 行) + 14-fixture harness 全绿
- **tad.sh 现有升级流程** (1310 行): detect_state → backup_existing → download → copy_framework_files → apply_deprecations → verify_install_complete
- **sync-protocol.md 现有流程**: step3.b copy files → step3.c deprecation cleanup → step3.d verification

### 2.2 Current State
- migration-engine.sh 已完成但无调用方 — 独立跑 fixture 全绿，但 tad.sh 和 *sync 都不调用它
- `.tad-backup/` 由 migration-engine.sh 生成（Phase 2），但不在 derive-sync-set.sh TRANSIENT 列表中 — *sync 会尝试同步这个目录到其他项目（错误行为）
- tad.sh:721 注释说 "lexicographic is fine for semver" 但实际使用 `sort -V`（通过 version_le 函数）
- tad.sh 的 `backup_existing()` (L115-124) 生成 `.tad.backup.{timestamp}` 目录（注意这是老的 timestamped backup，与 engine 的 `.tad-backup/` 不同）

### 2.3 Dependencies
- migration-engine.sh (`.tad/hooks/lib/migration-engine.sh`) — Phase 2 产出，已测试
- derive-sync-set.sh (`.tad/hooks/lib/derive-sync-set.sh`) — deny-list 单一源
- tad.sh 的内联 DENY_LIST 必须与 derive-sync-set.sh 保持同步（`--verify-denylist` 漂移检查）

---

## 3. Requirements

### 3.1 Functional Requirements

- **FR1: tad.sh 集成** — 在 tad.sh 的 "upgrade" 和 "migrate" 路径中，copy_framework_files 之后调用 migration-engine.sh。old_version 必须在 copy 之前捕获（copy 会覆盖 version.txt）。
- **FR2: *sync 协议集成** — 在 sync-protocol.md 的 step3.b (copy files) 之后、step3.c (deprecation cleanup) 之前，新增 step3.b2 调用 migration-engine.sh。
- **FR3: `.tad-backup/` 排除** — 添加到 derive-sync-set.sh 的 TRANSIENT 列表 + tad.sh 的内联 TAD_TRANSIENT。
- **FR4: tad.sh:721 注释修复** — 将 "lexicographic is fine for semver with fixed digits" 改为准确描述 sort -V 行为。
- **FR5: 零双实现** — tad.sh 和 *sync 都调用 `bash migration-engine.sh --from ... --to ... --target ... --source ...`，不在任何调用方中内联 delete/rename 逻辑。
- **FR6: fresh install 跳过** — 全新安装（detect_state == "fresh"）不调用 migration-engine.sh（无旧版本可迁移）。
- **FR7: 退出码处理** — engine exit 0 (成功/无 manifest) → 继续; exit 2 (manifest 非法/链缺口) → warn + 建议 clean reinstall，不中止（copy 已完成）; exit 1 (执行失败) → warn + 继续（备份存在，可恢复）。
- **FR8: migrate case 备份路径分离（P0-2 fix）** — tad.sh "migrate" case 的结构性备份（L1158-1161）当前写入 `.tad-backup/`，与 migration-engine.sh 的 per-version backups（`.tad-backup/{from}-to-{to}/`）命名空间冲突。修复：将 migrate case 的结构性备份改为 `.tad-migrate-backup` 路径（或复用 `backup_existing()` 的 `.tad.backup.{timestamp}` 模式），使两者互不干扰。engine 的 `.tad-backup/` 是累积的 recovery 数据（跨多次升级），不得被清除。

### 3.2 Non-Functional Requirements

- **NFR1: bash 3.2 兼容** — tad.sh 新增代码不得使用 bash 4+ 特性
- **NFR2: 非交互模式** — migration-engine.sh 无 interactive prompt（Phase 2 已保证）；tad.sh --yes 路径下无新 /dev/tty 读取
- **NFR3: set -euo pipefail 安全** — engine 调用必须用 `cmd || rc=$?` 条件赋值（bash 3.2 下 `set +e` 不抑制已 arm 的 ERR trap — P0-1 fix）

---

## 4. Technical Design

### 4.1 Architecture Overview

```
tad.sh (远程安装)                  *sync (本地同步)
─────────────────                  ────────────────
1. detect_state                    1. read target version.txt
   → old_ver = .tad/version.txt      → old_ver
2. backup_existing                 2. step3.b copy files
3. download + extract              3. ⭐ step3.b2: bash engine
4. copy_framework_files               --from old_ver --to cur_ver
   (now engine.sh is available)        --target project --source TAD
5. ⭐ call_migration_engine        4. step3.c deprecation cleanup
6. apply_deprecations              5. step3.d/d2 verification
7. verify_install_complete
```

两条路径共享的不变量：
- 同一个 binary: `.tad/hooks/lib/migration-engine.sh`
- 同一个参数模式: `--from <old> --to <new> --target <dir> --source <dir>`
- 同一个 manifest 目录: `$source/.tad/migrations/`
- engine 必须在 copy 之后调用（tad.sh 路径下，engine 是从 source 提取出来的）

### 4.2 tad.sh 修改细节

**修改点 1: 捕获 old_version（L892-896 区域）**

当前代码（tad.sh L892-896）：
```bash
STATE=$(detect_state)
CURRENT_VERSION="none"
if [ -f ".tad/version.txt" ]; then
    CURRENT_VERSION=$(cat .tad/version.txt)
fi
```

`CURRENT_VERSION` 在 copy_framework_files 之前就被读取了 — 这正是我们需要的 old_version。它已经存在，不需要新增捕获逻辑。但要确认 copy_framework_files 之后 CURRENT_VERSION 仍保留旧值（它是在 main scope 赋值，copy 只写文件不改变量 — 已确认安全）。

**修改点 2: 新函数 call_migration_engine（在 apply_deprecations 之前插入）**

在 "upgrade" 和 "migrate" case 分支的 `copy_framework_files "$TAD_SRC"` 之后、`apply_deprecations` 调用之前（注意：apply_deprecations 是 copy_framework_files 内部调用的，见 L474 — 所以 engine 调用应该在 copy_framework_files 返回之后），调用新函数：

```bash
call_migration_engine() {
    local src="$1"
    local old_ver="$2"
    local new_ver="$3"

    # Skip if no old version (fresh install) or same version
    if [ "$old_ver" = "none" ] || [ "$old_ver" = "$new_ver" ]; then
        return 0
    fi

    local engine="$src/.tad/hooks/lib/migration-engine.sh"
    if [ ! -f "$engine" ]; then
        log_warn "  → Migration engine not found in source; skipping migration"
        return 0
    fi

    log_info "  → Running migration engine ($old_ver → $new_ver)..."

    # ERR trap bypass: `|| engine_rc=$?` is POSIX-guaranteed to suppress
    # the ERR trap in bash 3.2 (set +e does NOT suppress an armed trap).
    local engine_rc=0
    bash "$engine" --from "$old_ver" --to "$new_ver" --target . --source "$src" || engine_rc=$?

    case $engine_rc in
        0)
            log_success "  → Migration completed successfully"
            ;;
        2)
            log_warn "  → Migration skipped: manifest invalid or chain gap (exit 2)"
            log_warn "    If upgrading from a very old version, consider a clean reinstall"
            ;;
        1)
            log_warn "  → Migration had execution errors (exit 1)"
            log_warn "    Backup exists in .tad-backup/ for recovery"
            ;;
        *)
            log_warn "  → Migration returned unexpected exit code: $engine_rc"
            ;;
    esac
}
```

**调用位置（upgrade case, 当前 L1101-1150）**：
在 `copy_framework_files "$TAD_SRC"` (L1133) 之后、`echo "$TARGET_VERSION" > .tad/version.txt` (L1150) 之前插入：

```bash
# Run migration engine (after copy makes engine available)
call_migration_engine "$TAD_SRC" "$CURRENT_VERSION" "$TARGET_VERSION"
```

**调用位置（migrate case, 当前 L1153-1273）**：
在 `copy_framework_files "$TAD_SRC"` (L1209) 之后、`echo "$TARGET_VERSION" > .tad/version.txt` (L1269) 之前插入同一行。

**注意**：`install` case (L1015-1099) 不调用 — fresh install 无旧版本可迁移。

**修改点 3: tad.sh:721 注释修复**

当前 (L721):
```bash
            # Only process if dep_version ≤ current_version (lexicographic is fine for semver with fixed digits)
```

改为:
```bash
            # Only process if dep_version ≤ current_version (version_le uses sort -V)
```

### 4.3 .tad-backup/ 排除

**derive-sync-set.sh (L62-66)**：

当前 TRANSIENT 列表：
```bash
TRANSIENT="working
spike-v3
reports
checklists"
```

注意：`.tad-backup/` 位于项目根目录，NOT under `.tad/`。derive-sync-set.sh 的 DENY_LIST 只作用于 `.tad/*/` 子目录。所以 `.tad-backup/` 实际上不需要加到 derive-sync-set.sh 的 TRANSIENT — 它不在 `.tad/` 下，derive pipeline 的 `ls -d .tad/*/` 根本不会扫到它。

但 `.tad-backup/` 确实需要被 *sync 排除（避免把 A 项目的 migration backup 同步到 B 项目）。排除方式：
1. sync-protocol.md step3.b 的 PRESERVE 列表已列出所有不应触碰的目录，`.tad-backup/` 需要加入
2. tad.sh 的 copy_framework_files 不受影响（它用 derive_framework_dirs 只扫 `.tad/*/`）
3. tad.sh 的 verify_install_complete 也不受影响（同理）

**但是**：再读一遍 Phase 2 code review CR-P1-3 carry-forward 原文："`.tad-backup/` 在 derive-sync-set 推导面之外，需显式排除"。这说的是 *sync 的文件复制可能会把 `.tad-backup/` 从 TAD source 复制到目标 — 因为 sync-protocol step3.b 复制根级文件时没有排除它。但 `.tad-backup/` 是 target 侧产物（engine 在 target 下创建），不是 source 侧文件，所以 sync copy 不会碰它。

**结论**：
1. sync-protocol.md PRESERVE 列表加 `.tad-backup/`
2. **P0-2 修复**：tad.sh "migrate" case L1158-1161 的 `rm -rf .tad-backup && cp -r .tad .tad-backup` 必须改为使用不同的路径（如 `.tad-migrate-backup`），因为 `.tad-backup/` 现在是 migration-engine.sh 的 per-version recovery 存储，跨多次升级累积，不得清除。

**实际修改**：
1. sync-protocol.md PRESERVE 列表末尾加 `.tad-backup/` 
2. 如果 `.tad-backup/` 存在于 TAD source repo 根目录（它不应该 — 它是 target 侧运行时产物），在 sync-protocol step3.b 注释说明"不复制"

### 4.4 sync-protocol.md 修改

在 step3.b (Framework files copy) 之后、step3.c (Deprecation cleanup) 之前，新增 step3.b2:

```yaml
b2. Migration engine (post-copy, per-project):
    Pre-condition: old_version captured from step 1 (target's version.txt BEFORE copy).
    
    Call: bash {TAD_SOURCE}/.tad/hooks/lib/migration-engine.sh \
      --from {old_version} --to {current_version} \
      --target {target_project_path} --source {TAD_SOURCE}
    
    Exit code handling (same as tad.sh):
    - exit 0 → migration applied (or no manifests for this version range); continue
    - exit 2 → WARN "Migration skipped for {project_name}: manifest invalid or chain gap"
               Do NOT block sync — the copy already landed. Continue to step c.
    - exit 1 → WARN "Migration had execution errors for {project_name}"
               Backup exists at {target}/.tad-backup/; continue to step c.
    
    Note: The engine is the SOLE executor of migration logic. Alex MUST NOT
    inline any delete/rename operations for migration — that is FR5 (zero
    dual-implementation). If the engine lacks a needed capability, file it
    as a Phase 4+ enhancement, don't work around it in sync-protocol.
```

PRESERVE 列表末尾新增：
```
- .tad-backup/ (migration engine backups — per-version, target-side only)
```

### 4.5 版本捕获时序（关键约束）

tad.sh 的 `CURRENT_VERSION` 在 L894 被读取，copy_framework_files 在 L1038/1133/1209 执行。中间没有代码改写 `CURRENT_VERSION` 变量。copy_framework_files 会覆盖 `.tad/version.txt` 文件（间接的 — 它 cp 所有 top-level files），但变量已经在 shell 内存中了。

但是仔细看：`copy_framework_files` 复制的是 `$src/.tad/` 下的文件到 `.tad/`。version.txt 是 top-level file，会被 `derive_framework_top_files` 包含在内。所以 copy 之后 `.tad/version.txt` 已经是新版本。但 `CURRENT_VERSION` 变量仍然是旧值。然而 `echo "$TARGET_VERSION" > .tad/version.txt` 在 L1098/1150/1269 又覆盖了一次。

关键点：engine 的 `--from` 参数使用 `$CURRENT_VERSION`（旧值），`--to` 使用 `$TARGET_VERSION`（新值）。两者在 engine 调用时都是正确的。无需额外捕获。

---

## 5. 强制问题回答（Evidence Required）

### MQ1: 历史代码搜索

**回答**：
- [x] 是 — 引用 Phase 2 的 migration-engine.sh 和现有 tad.sh 流程

**搜索证据**：

已在 Background Context 中详述。migration-engine.sh 由 Phase 2 交付（commit fe11b95），tad.sh 现有流程在 §4.2 中基于实际行号引用。

**决策说明**：
- **找到了什么**：migration-engine.sh 完整的 CLI 接口 + tad.sh 的 upgrade/migrate 路径
- **决定**：✅ 复用 engine 作为唯一执行体，在 tad.sh 中新增 wrapper 函数
- **原因**：Epic 核心约束 = 零双实现

### MQ2: 函数存在性验证

| 函数名 | 文件位置 | 行号 | 代码片段 | 验证 |
|--------|---------|------|---------|------|
| `copy_framework_files` | tad.sh | L386 | `copy_framework_files() {` | ✅ |
| `verify_install_complete` | tad.sh | L578 | `verify_install_complete() {` | ✅ |
| `apply_deprecations` | tad.sh | L676 | `apply_deprecations() {` | ✅ |
| `version_le` | tad.sh | L740 | `version_le() {` | ✅ |
| `detect_state` | tad.sh | L823 | `detect_state() {` | ✅ |
| `backup_existing` | tad.sh | L115 | `backup_existing() {` | ✅ |
| `derive_framework_dirs` | tad.sh | L207 | `derive_framework_dirs() {` | ✅ |
| `derive_framework_top_files` | tad.sh | L223 | `derive_framework_top_files() {` | ✅ |
| `parse_args` | migration-engine.sh | L16 | `parse_args() {` | ✅ |
| `main` (engine) | migration-engine.sh | L848 | `main() {` | ✅ |
| `log_info` | tad.sh | (utility) | used throughout | ✅ |
| `log_warn` | tad.sh | (utility) | used throughout | ✅ |
| `log_success` | tad.sh | (utility) | used throughout | ✅ |

`call_migration_engine` — 新建函数（不存在于当前代码库）

### MQ3: 数据流完整性

**N/A** — 无前后端数据流，本任务是 shell 脚本集成。

**数据传递流**（替代）：

| 数据 | 来源 | 消费方 | 说明 |
|------|------|--------|------|
| old_version | `.tad/version.txt`（copy前） | engine `--from` | 已由 tad.sh L894 CURRENT_VERSION 捕获 |
| new_version | `$TARGET_VERSION` | engine `--to` | 由 derive_target_version 从 source version.txt 设定 |
| target_dir | tad.sh 运行目录 (`.`) | engine `--target` | tad.sh 始终在项目根运行 |
| source_dir | `$TAD_SRC` ("TAD-main") | engine `--source` | curl 下载解压后的临时目录 |

### MQ4: 视觉层级

**回答**：
- [x] 否 → 跳过此问题

### MQ5: 状态同步

**回答**：

| 数据 | 存储位置1 | 存储位置2 | 同步时机 | 同步方向 |
|------|----------|----------|---------|---------|
| version.txt | `.tad/version.txt` (target) | `$TAD_SRC/.tad/version.txt` (source) | copy_framework_files 时 cp 覆盖 | source → target |
| CURRENT_VERSION | shell 变量 | — | L894 读取一次 | 只读 |

```
.tad/version.txt (target) ← cp ← $TAD_SRC/.tad/version.txt (source)
CURRENT_VERSION (shell var) — snapshot at L894, never updated
```

✅ CURRENT_VERSION 是只读快照，copy 不改变量 — 无同步风险。

---

## 6. Implementation Steps

### 6.1 Micro-Tasks

| # | File | Operation | Verification Command | Est. Time |
|---|------|-----------|---------------------|-----------|
| 1 | tad.sh | Add `call_migration_engine()` function (before `apply_deprecations`, ~L670 area) | `grep -c 'call_migration_engine' tad.sh` → 1 (function def) | 3 min |
| 2 | tad.sh | Insert call in "upgrade" case after copy_framework_files | `grep -A2 'copy_framework_files.*TAD_SRC' tad.sh \| grep -c 'call_migration_engine'` → at least 1 | 2 min |
| 3 | tad.sh | Insert call in "migrate" case after copy_framework_files | same grep yields 2 total calls | 2 min |
| 4 | tad.sh L721 | Fix comment: "lexicographic" → "sort -V" | `grep -c 'sort -V' tad.sh` (in comment area L721) | 1 min |
| 5 | .tad/hooks/lib/derive-sync-set.sh | Add `.tad-backup` to description/awareness (see §4.3 analysis) | Read and verify | 2 min |
| 6 | .claude/skills/alex/references/sync-protocol.md | Add step3.b2 migration engine call + PRESERVE entry | `grep -c 'migration-engine' .claude/skills/alex/references/sync-protocol.md` ≥ 1 | 5 min |
| 7 | tad.sh | Verify `TAD_TRANSIENT` vs derive-sync-set.sh TRANSIENT still match (denylist drift check) | `bash tad.sh --verify-denylist` exit 0 | 2 min |
| 8 | Fixture | Write/run fixture for tad.sh upgrade + engine integration | fixture exit 0 | 15 min |

### Phase 1: tad.sh Integration (预计 30 min)

#### 交付物
- [ ] `call_migration_engine()` 函数添加到 tad.sh
- [ ] "upgrade" case 中 copy_framework_files 之后调用
- [ ] "migrate" case 中 copy_framework_files 之后调用
- [ ] L721 注释修复
- [ ] `bash -n tad.sh` 语法检查通过

#### 实施步骤

1. 在 tad.sh 的 `apply_deprecations()` 函数之前（~L670 区域），添加 `call_migration_engine()` 函数。函数体见 §4.2 修改点 2。

2. 在 "upgrade" case 分支（当前 L1101）中，找到 `copy_framework_files "$TAD_SRC"` (L1133) 之后、`# Update CLAUDE.md` 注释 (L1135) 之前，插入：
   ```bash
   # Run migration engine (after copy makes engine available; before version.txt update)
   call_migration_engine "$TAD_SRC" "$CURRENT_VERSION" "$TARGET_VERSION"
   ```

3. 在 "migrate" case 分支（当前 L1153）中，找到 `copy_framework_files "$TAD_SRC"` (L1209) 之后、`# Copy root files` 注释 (L1211) 之前，插入同一行。

4. 修复 L721 注释（见 §4.2 修改点 3）。

5. 运行 `bash -n tad.sh` 确认语法正确。

#### 实现提示

1. **set +e / set -e 块**：engine 调用必须在 set +e 块内。tad.sh 在 L818 设了 `trap 'rollback_on_failure' ERR`，如果 engine 返回非零，ERR trap 会触发 rollback — 这不是我们想要的（copy 已完成，engine 失败是 graceful degradation）。
2. **bash 3.2 兼容**：call_migration_engine 中不使用 `local -n`、nameref、关联数组等 bash 4+ 特性。`$?` 捕获用普通变量。
3. **install case 不调用**：fresh install 的 CURRENT_VERSION="none"，call_migration_engine 开头检查 `"$old_ver" = "none"` 直接 return 0。
4. **apply_deprecations 在 copy_framework_files 内部**（L474）：所以 engine 调用实际在 apply_deprecations 之后。这符合 DR-3 的执行顺序契约：apply_deprecations（frozen ≤v2.26.0）先跑 → engine 后跑。

#### Phase 1 完成证据（Blake必须提供）
- [ ] `bash -n tad.sh` 无错误
- [ ] `grep -n 'call_migration_engine' tad.sh` 输出显示函数定义 + 2 个调用点
- [ ] `grep 'sort -V' tad.sh` 在 L721 区域显示修复后的注释

**Human决策**：✅ 继续Phase 2 / ⚠️ 调整本Phase

---

### Phase 2: sync-protocol.md + .tad-backup/ 排除 (预计 15 min)

#### 交付物
- [ ] sync-protocol.md 新增 step3.b2 migration engine 调用
- [ ] sync-protocol.md PRESERVE 列表新增 `.tad-backup/`
- [ ] derive-sync-set.sh / tad.sh TRANSIENT 评估完成（如需修改则修改）

#### 实施步骤

1. 在 sync-protocol.md 的 step3.b (Framework files copy) 之后、step3.c (Deprecation cleanup) 之前，插入 step3.b2。内容见 §4.4。

2. 在 sync-protocol.md step3 的 PRESERVE 列表（当前在 `- PROJECT_CONTEXT.md, NEXT.md` 后面）末尾加入：
   ```
   - .tad-backup/ (migration engine backups — per-version, target-side only)
   ```

3. 评估 derive-sync-set.sh TRANSIENT 是否需要加 `.tad-backup`：
   - `.tad-backup/` 在项目根目录，不在 `.tad/` 下
   - derive-sync-set.sh 的 `ls -d .tad/*/` 扫不到它
   - **结论**：不需要加到 TRANSIENT（它不在 derive pipeline scope 内）
   - 但 sync-protocol.md 的 PRESERVE 列表是 Alex 执行 *sync 时的人工参考 — 所以加在那里

4. 确认 denylist drift 仍然 PASS（因为我们没改 TRANSIENT/ZERO_TOUCH）。

#### Phase 2 完成证据（Blake必须提供）
- [ ] `grep -c 'migration-engine' .claude/skills/alex/references/sync-protocol.md` ≥ 1
- [ ] `grep '.tad-backup' .claude/skills/alex/references/sync-protocol.md` 显示 PRESERVE 条目
- [ ] `bash tad.sh --verify-denylist` exit 0（如从 TAD repo 运行）

**Human决策**：✅ 继续Phase 3 / ⚠️ 调整本Phase

---

### Phase 3: Fixture Testing (预计 30 min)

#### 交付物
- [ ] 新 fixture：tad.sh upgrade path 调用 engine 且正确处理 exit codes
- [ ] 新 fixture：非 TTY 模式下 engine 调用无阻塞
- [ ] 新 fixture：无 version.txt 的极老安装报错
- [ ] 全部现有 fixture (14 个) 仍然 PASS

#### 实施步骤

1. **fixture: tad.sh upgrade + engine integration**
   - 构造一个模拟的 tad.sh 升级环境：target 目录有 `.tad/version.txt` = "2.26.0"，source 目录有 migration-engine.sh + manifest
   - 验证 call_migration_engine 被调用且 engine 执行了 manifest 中的 delete
   - 断言旧文件清除 + 新文件存在

2. **fixture: non-TTY mode**
   - 在 `</dev/null` 条件下跑 `call_migration_engine`（模拟 CI/非 TTY）
   - 断言无 hang、exit 0

3. **fixture: 无 version.txt**
   - 构造 target 目录无 `.tad/version.txt`（CURRENT_VERSION="none"）
   - 断言 call_migration_engine 跳过（return 0）而非崩溃
   - 对应 Epic AC4："版本检测对无 version.txt 的极老安装降级为明确报错 + 建议 clean reinstall"
   - 注意：这个报错在 detect_state 层面处理（返回 "old" → ACTION="migrate"），call_migration_engine 收到 old_ver="none" 时直接 return 0

4. **回归**：运行现有 14 个 migration fixture，确认不受影响。

#### 测试说明

fixture 可以放在 `.tad/tests/migration-fixtures/` 下（Phase 2 已建立此目录）。新 fixture 文件名建议：
- `test-15-tad-upgrade-engine-call.sh`
- `test-16-non-tty-engine.sh`
- `test-17-no-version-txt.sh`

或者合并为一个 `test-15-dual-caller-integration.sh`（多个 sub-test），由 Blake 根据 Phase 2 fixture harness 的模式决定。

#### Phase 3 完成证据（Blake必须提供）
- [ ] 新 fixture 执行输出（全 PASS）
- [ ] 现有 14 fixture 回归执行输出（全 PASS）
- [ ] 非 TTY fixture 在 `</dev/null` 下跑通的证据

**Human决策**：✅ 完成 / ⚠️ 调整

---

## 7. File Structure

### 7.1 Files to Create
```
.tad/tests/migration-fixtures/test-15-*.sh  # Integration fixture(s) — naming follows Phase 2 convention
```

### 7.2 Files to Modify
```
tad.sh                                                     # Add call_migration_engine(), 2 call sites, L721 comment fix
.claude/skills/alex/references/sync-protocol.md            # Add step3.b2, PRESERVE .tad-backup/
```

### 7.3 Grounded Against (Alex step1c)

- _tad.sh, L1-60 + L115-124 + L185-232 + L386-556 + L578-667 + L670-745 + L810-870 + L870-990 + L990-1310, read at 2026-06-10_
- _migration-engine.sh, L1-50 + L840-897, read at 2026-06-10_
- _sync-protocol.md, L60-200, read at 2026-06-10_
- _derive-sync-set.sh, L1-90, read at 2026-06-10_
- _.tad/tests/migration-fixtures/ — (exists, created by Phase 2)_
- _test-15-*.sh — (new — will be created)_

---

## 8. Testing Requirements

### 8.1 Unit Tests (shell function level)
- call_migration_engine with old_ver="none" → return 0, no engine call
- call_migration_engine with old_ver=new_ver → return 0, no engine call
- call_migration_engine with missing engine binary → log_warn + return 0

### 8.2 Integration Tests
- Full tad.sh upgrade simulation: old version.txt → copy → engine runs → verify_install_complete
- sync-protocol step3.b2 simulation: engine called on target project with correct args

### 8.3 Edge Cases
- **Engine binary missing in source**: tad.sh must not crash (graceful skip)
- **No manifests for version range**: engine exits 0, tad.sh continues normally
- **Engine exit 2 (manifest invalid)**: tad.sh warns but does not rollback
- **Engine exit 1 (execution failure)**: tad.sh warns, backup exists for recovery
- **CURRENT_VERSION contains spaces/special chars**: version_le and engine both handle via `tr -d '[:space:]'`
- **Non-TTY / --yes mode**: no /dev/tty prompts anywhere in the engine call path

### 8.4 Test Evidence Required
Blake必须提供：
- [ ] 新 fixture 执行截图（全 PASS）
- [ ] 现有 14 fixture 回归（全 PASS）
- [ ] `bash -n tad.sh` 通过
- [ ] `bash tad.sh --verify-denylist` 通过

---

## 9. Acceptance Criteria

Blake的实现被认为完成，当且仅当：
- [ ] tad.sh 的 upgrade/migrate 路径调用 migration-engine.sh
- [ ] *sync 协议文档更新为包含 engine 调用步骤
- [ ] 零双实现 — 只有 engine 内有 delete/rename 逻辑
- [ ] L721 注释修复
- [ ] 新 fixture 全 PASS + 旧 fixture 回归全 PASS
- [ ] `bash -n tad.sh` + `bash tad.sh --verify-denylist` 全 PASS

---

## 9.1 Spec Compliance Checklist — PRIMARY VERIFICATION SOURCE

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| AC1 | call_migration_engine function exists in tad.sh | post-impl-verifiable | `grep -c 'call_migration_engine()' tad.sh` | 1 | (post-impl) |
| AC2 | Engine called in "upgrade" case after copy_framework_files | post-impl-verifiable | `awk '/^[[:space:]]*"upgrade"/,/;;/' tad.sh \| grep -c 'call_migration_engine'` | 1 | (post-impl) |
| AC3 | Engine called in "migrate" case after copy_framework_files | post-impl-verifiable | `awk '/^[[:space:]]*"migrate"/,/;;/' tad.sh \| grep -c 'call_migration_engine'` | 1 | (post-impl) |
| AC4 | Engine NOT called in "install" case | post-impl-verifiable | `awk '/^[[:space:]]*"install"/,/;;/' tad.sh \| grep -c 'call_migration_engine'` | 0 | (post-impl) |
| AC5 | Zero dual-implementation: no inline rm/mv for migration paths outside engine call | post-impl-verifiable | `grep -n 'rm.*migration\|mv.*migration\|rm.*\.tad/hooks/old\|rm.*deprecated' tad.sh \| grep -v '#' \| grep -v 'call_migration_engine' \| wc -l` | 0 (no inline migration rm/mv) | (post-impl) |
| AC6 | L721 comment fix: "sort -V" replaces "lexicographic" | post-impl-verifiable | `sed -n '715,725p' tad.sh \| grep -c 'sort -V'` | 1 | (post-impl) |
| AC7 | L721 comment no longer says "lexicographic" | post-impl-verifiable | `sed -n '715,725p' tad.sh \| grep -c 'lexicographic'` | 0 | (post-impl) |
| AC8 | sync-protocol.md has migration-engine step | post-impl-verifiable | `grep -c 'migration-engine' .claude/skills/alex/references/sync-protocol.md` | >= 1 | (post-impl) |
| AC9 | sync-protocol.md PRESERVE includes .tad-backup | post-impl-verifiable | `grep -c 'tad-backup' .claude/skills/alex/references/sync-protocol.md` | >= 1 | (post-impl) |
| AC10 | tad.sh syntax valid | post-impl-verifiable | `bash -n tad.sh; echo $?` | 0 | (post-impl) |
| AC11 | Denylist drift check passes | post-impl-verifiable | `bash tad.sh --verify-denylist; echo $?` | 0 | (post-impl) |
| AC12 | set +e wraps engine call (ERR trap safety) | post-impl-verifiable | `grep -A5 'call_migration_engine' tad.sh \| head -20; grep -B2 -A15 'call_migration_engine()' tad.sh \| grep -c 'set +e'` | >= 1 | (post-impl) |
| AC13 | Engine exit 2 handled with warn (not crash) | post-impl-verifiable | `grep -A20 'call_migration_engine()' tad.sh \| grep -c 'exit 2\|log_warn.*chain gap\|log_warn.*invalid'` | >= 1 | (post-impl) |
| AC14 | New fixture(s) pass | post-impl-verifiable | `bash .tad/tests/migration-fixtures/test-15*.sh; echo $?` | 0 | (post-impl) |
| AC15 | Existing 14 fixtures pass (regression) | post-impl-verifiable | `bash .tad/tests/migration-fixtures/run-all.sh; echo $?` | 0 | (post-impl) |
| AC16 | Non-TTY fixture: engine runs without blocking | post-impl-verifiable | `timeout 30 bash .tad/tests/migration-fixtures/test-15*.sh </dev/null; echo $?` | 0 (within 30s) | (post-impl) |
| AC17 | No version.txt → CURRENT_VERSION="none" → engine skipped gracefully | post-impl-verifiable | Fixture assertion: engine call returns 0 when old_ver="none" | 0 | (post-impl) |

> Pre-impl-verifiable ACs: None — all changes are code modifications requiring implementation first.
> AC5 note: The grep pattern is intentionally broad to catch any stray inline migration logic. False positives from existing apply_deprecations are expected — that function is frozen for ≤v2.26.0 per DR-3 and is NOT migration-engine logic.

---

## 9.2 Expert Review Status (Alex 必填)

> Expert review deferred to Conductor per YOLO Epic execution model.
> Conductor handles expert dispatch after handoff creation.

### Experts Selected

1. **shell-portability-reviewer** — bash 3.2 compatibility, set -e trap interaction, non-TTY safety
2. **integration-architect** — verify two-caller convergence, exit code propagation, version capture timing

### Overall Assessment (post-integration)

Pending Conductor expert dispatch.

---

## 10. Important Notes

### 10.1 Critical Warnings

- ⚠️ **ERR trap interaction**: tad.sh L818 `trap 'rollback_on_failure' ERR` means ANY non-zero exit code triggers rollback. Engine call MUST be wrapped in `set +e` block. Failure to do this will cause a tad.sh rollback on engine exit 1 or 2 — losing the successfully copied framework files.
- ⚠️ **apply_deprecations 在 copy_framework_files 内部** (L474): 这意味着 engine 调用实际在 deprecations 之后。顺序是：copy (含 deprecations) → engine → version.txt 写入。这符合 DR-3 的 "apply_deprecations 先跑 → engine 后跑" 契约。
- ⚠️ **CURRENT_VERSION 变量安全**: copy_framework_files 覆盖 `.tad/version.txt` 文件但不改 `$CURRENT_VERSION` shell 变量。不要在 copy 之后重新读取 version.txt 来获取旧版本 — 用已捕获的变量。

### 10.2 Known Constraints

- 当前只有一个 manifest (`2.26.0-to-2.27.0.yaml`) — engine 对其他版本范围会返回 exit 0 (no manifests)
- engine 的 merge 类型报 "需手动处理" — Phase 4 才实现执行
- tad.sh 的 "migrate" case (L1153) 中有遗留的 `rm -rf .tad-backup` (L1158-1159) — 这是 v1.x→v2.x 迁移的旧 backup 目录，与 engine 的 `.tad-backup/{from}-to-{to}/` per-version backup 不同。两者共用 `.tad-backup/` 路径存在 **潜在冲突** — "migrate" case 在 copy 之前删除整个 `.tad-backup/`，而 engine 之后会在里面创建新 backup。这实际是安全的（删除发生在 engine 之前），但需在代码注释中说明。

### 10.3 Sub-Agent使用建议

Blake应该考虑使用：
- [ ] **test-runner** - 完成每个Phase后跑 fixture suite

---

## 11. Learning Content

### 11.1 Decision Rationale: Engine 调用位置

**选择的方案**：copy_framework_files 之后调用 engine

**考虑的替代方案**：

| 方案 | 优点 | 缺点 | 为什么没选 |
|------|------|------|-----------|
| 方案A: copy 之后调用（选中）| engine.sh 已从 source 提取到 target，可直接执行；apply_deprecations 已先完成（DR-3） | 旧文件可能被 copy 覆盖后再被 engine 删除（浪费一次 cp） | ✅ 选中 — 唯一可行方案 |
| 方案B: copy 之前调用 | 避免"先 copy 再 delete" | engine.sh 还在 tarball 里，target 上不存在；或需要从 source 临时路径调用 | 方案可行（`bash $TAD_SRC/.tad/hooks/lib/migration-engine.sh`），但与 tad.sh 的 curl-download 模式不匹配 — engine.sh 需要 `$TAD_SRC` 持续可用 |
| 方案C: verify_install_complete 之后调用 | 先确认 copy 成功 | verify 检查的是新文件完整性；engine 删旧文件后 verify 结果反而更干净 — 但 copy 之后立即删比 verify 之后删更直觉 | 差异不大，但 copy→engine→verify 的顺序更符合"安装→清理→验证"的逻辑 |

**核心权衡**：engine 可用时机 vs 最优调用顺序。tad.sh 的 curl|bash 模式决定了 engine 只在 download+extract 后可用，所以 copy 之后调用是唯一安全选择。

**但是方案 B 再审视**：engine 的 `--source` 参数指向 `$TAD_SRC`（下载解压后的临时目录），里面确实有 engine.sh。所以技术上可以在 copy 之前用 `bash "$TAD_SRC/.tad/hooks/lib/migration-engine.sh"` 调用。但 engine 的 delete 操作目标是 target（`.`），如果 copy 之后再跑 engine，engine 删的可能是 copy 刚放上去的新版本文件。这正好不对 — engine 应该删的是旧版本残留文件，新版本文件由 copy 替换。

实际上 engine 的 delete 路径来自 manifest 的显式枚举 — manifest 只列真正要删除的旧文件（如 `.tad/hooks/old-cleanup.sh`），不会列新版本仍然存在的文件。所以 copy 前后调用都安全。选择 copy 之后是因为：与 apply_deprecations 的顺序一致（DR-3）。

---

## 12. Sub-Agent使用记录

Blake完成后填写：

| Sub-Agent | 是否调用 | 调用时机 | 输出摘要 | 证据链接 |
|-----------|---------|---------|---------|---------|
| test-runner | ❓ | Phase 3 | — | — |

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-06-10
**Version**: 3.1.0

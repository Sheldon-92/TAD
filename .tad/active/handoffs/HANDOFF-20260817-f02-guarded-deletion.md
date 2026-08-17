---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-08-17
**Task ID:** TASK-20260817-001
**Epic:** `EPIC-20260816-framework-health-repair.md`（Phase 2 的 FR-2 单独成单）
**依据:** 审计 F-02；以及 2026-08-16 一次失败尝试的结论（§2.2）
**基线 SHA:** `dbecc6b1`

---

## 🔴 Gate 2

- [x] 需求明确（单一改动点）
- [x] 技术方案完整 —— 复用既有函数，不新建机制
- [x] AC 可运行；改前值**除三条需 Blake 现场取基线外**已全部实测（§9.1 标注；AC-2b 已补测为 **12**）
- [x] MQ1-MQ6 已回答（§5）
- [x] 专家审查 ≥2 且 P0 已修 —— **✅ PASS（5 名 reviewer / 4 轮）**

### ✅ Gate 2 判定：**PASS**（2026-08-17）

| 轮 | Reviewer | 结论 |
|---|---|---|
| 1 | `c96838fe` 事实核查 | `F02 CLAIMS SOUND` —— 7 行行为表全对；抓到 2 处引用错误（已修） |
| 1 | `08c15216` AC 与可实现性 | `GATE2 BLOCKED` —— 4 个 P0：source 不可能、ERR trap 会回滚整个安装、备份方案 B 被证伪、`do_backup` 被漏 |
| 2 | `fd6759e2` | `BLOCKED` —— 一个空格 + `rm -fr` 打穿全部 5 条静态 AC；AC-N2 判红正确实现 |
| 3 | `852e3fe1` | `BLOCKED` —— 三个修复均验证有效，但 4 处工单自相矛盾 |
| **4** | **`aea44a29` 可实现性** | **`F02 IMPLEMENTABLE`** |

**第 4 轮的验收方式与前三轮不同**：不再找 AC 缺陷（已收敛），而是要求 reviewer
**真的在沙箱里照单实现一遍**。结果：

> 「A competent implementer gets a working, AC-green implementation from this document in one pass — I did,
> including the hardest scenario (real install path, ERR trap armed, mixed manifest).」

其沙箱实现的实测结果：引擎从函数内 source 成功（`declare -F` 显示四个函数均来自引擎）、
`do_backup`+`guarded_remove` 正常删除、被拒条目**退出码 0 且循环继续**、
AC-N2c 的 22 个 fixture **逐字节与基线一致**、符号链接场景中项目外文件存活。

**其指出的唯一会致死的一句话已修**：§4.3 原写「或显式传入 `backup_base`」——
实测 `M_FROM: unbound variable` 是致命错误，`|| rc=$?` 抓不住、ERR trap 不触发，安装器直接死。
现已改为「三个全局全部必须设置」，并补上 `M_FROM`/`M_TO` 取值指引、`load_zero_touch` 调用要求、
赋值顺序警告、`curl` stub 方案。

**判定依据**：规则 1（≥2 独立专家审查 + P0 修复）满足且远超；
且第 4 轮由独立方**实际实现验证**，非纸面判断。

---

## 1. Task Overview

### 1.1 一句话

`tad.sh` 的 `apply_deprecations` 用裸 `rm -rf` 删除目标项目中的路径，**绕过了同仓已有的三重防护**。把它接进 `migration-engine.sh` 的 `guarded_remove`。

### 1.2 现状

```bash
# tad.sh:1212-1214（实测；函数体 1163-1224）
if [ -e "$target" ]; then
    rm -rf -- "$target" 2>/dev/null && deleted=$((deleted + 1))
fi
```

唯一前置是 `[ -e "$target" ]` —— 只挡空字符串。

而 `migration-engine.sh` 有完整闸口，**从未被此路径调用**（实测 `guarded_remove` 在 `apply_deprecations` 内计数 = **0**）：

| 函数 | 行 | 作用 |
|---|---|---|
| `check_containment` | :85 | 逐组件符号链接检查 + `pwd -P` 解析后校验不逃出目标 |
| `check_zero_touch` | :147 | 物理解析比对 + 大小写归一 + 文本回退，拦 zero-touch 子树 |
| `guarded_remove` | :216 | rm 点二次复查（TOCTOU 防御）+ 断言备份存在 |

### 1.3 为什么这件事现在必须做

F-01 已于 `46af019c` 修复（`deprecation.yaml` 只列 TAD 自有文件），**但那只修了"删什么"，没修"怎么删"**。

**当前状态**：清单是对的，删除路径仍然不设防。任何一次对 `deprecation.yaml` 的误编辑都会直接变成 `rm -rf`。

### 1.4 Intent Statement

**要达成的**：让 `apply_deprecations` 的删除与 `migration-engine.sh` 的删除**走同一条闸口**，使"越过防护"在结构上不可能，而不是靠清单干净。

**不追求的**：重写 `apply_deprecations` 的解析逻辑、改 `deprecation.yaml` 格式、加新的校验机制。

---

## 2. Background Context

### 2.1 已完成的相邻工作

| commit | 内容 |
|---|---|
| `46af019c` | F-01（清单只列 TAD 自有）、F-03（install 分支 merge）、FR-1b、FR-4b |
| `dbecc6b1` | 一次失败尝试的记录与撤销（见 §2.2） |

### 2.2 ⚠️ 必读：一条错误路线已被证伪（2026-08-16）

Alex 曾尝试在**声明层**加护栏 —— 写一条 `release-verify.sh deprecation-safety` 子命令，
校验 `deprecation.yaml` 的清单里有无用户路径。**五个版本全部被独立 reviewer 端到端打穿，已全部撤销。**

| 版本 | 判据 | 打穿方式 |
|---|---|---|
| v1 | 黑名单 | 漏 `.aider.conf.yml` |
| v2 | 前缀白名单 | `.tad/../AGENTS.md` 穿越 |
| v3 | + 规范性检查 | **awk vs `read -r` 的 NUL 分歧** —— 校验的是另一个列表 |
| v4 | 共用解析器 | **所有权模型错** —— `.tad/*` 吞掉 12 个 zero-touch 用户子树 |
| v5 | 读 `--zero-touch` | 内部 `/./`、大小写不敏感卷、漏读同文件的 `TOP_DENY` |

**五版都挡不住的**：护栏校验**声明的字符串**，破坏发生在**执行时的解析结果**。
实测：目标项目里 `.tad/domains` 若是符号链接，一条**完全合法**的 `.tad/domains/x`
也会删掉项目外的用户数据。

**→ 结论：正确的位置是执行点，即本单。** 详见 `patterns/ac-verification.md` 的「五版全败」条目。
⚠️ **不要再试声明层护栏。**

### 2.3 Current State

```
$ sed -n '/^apply_deprecations/,/^}/p' tad.sh | grep -c 'guarded_remove'   → 0
$ grep -cE 'check_containment|check_zero_touch|guarded_remove' .tad/hooks/lib/migration-engine.sh → 11
$ bash .tad/hooks/lib/release-verify.sh parity . ; echo $?                 → 0
```

---

## 📚 Project Knowledge（Blake 必读）

| Pattern | 相关点 |
|---|---|
| `shell-portability.md` | **本单核心** —— `pwd -P`、大小写不敏感卷、路径含空格/CJK |
| `ac-verification.md` | **必读「五版全败」条目** —— 它解释了为什么本单的位置是对的 |

**必须应用的两条**：
1. **验证器必须与被验证者共用同一个解析实现**（v3 的 NUL 分歧就是反例）。
2. **校验字符串追不上校验解析结果** —— 本单的全部价值在于它工作在解析之后。

### Blake 确认
- [ ] 我已读 `patterns/ac-verification.md` 的「五版全败」条目，理解为何声明层护栏是错的方向

---

## 3. Requirements

### 3.1 Functional Requirements

| ID | 需求 |
|---|---|
| **FR-1** | `apply_deprecations` 的删除改为调用 `migration-engine.sh` 的 `guarded_remove`，不再裸 `rm -rf` |
| **FR-2** | 调用前须满足 `guarded_remove` 的契约：四参数 `full_path` / `backup_path` / `rel_path` / `base`，且 **backup 必须真实存在**（否则该函数会 ABORT） |
| **FR-3** | 被 `guarded_remove` 拒绝的条目须**记录并继续**，不得静默吞掉，也不得中断整个安装 |
| **FR-4** | `ZT_LIST` 须由 `derive-sync-set.sh --zero-touch` 提供（`check_zero_touch` 依赖该变量），**不得硬编码** |

### 3.2 Non-Functional Requirements

- **NFR1**：不得修改 `migration-engine.sh` 的任何**守卫逻辑**。⚠️ **唯一例外（人已裁定 2026-08-17）**：允许把末行 `main "$@"` 改为 `BASH_SOURCE` 条件调用，见 §4.4。除此之外一行不得动。
- **NFR2**：不得改 `deprecation.yaml` 的格式或内容
- **NFR3**：`apply_deprecations` 的解析循环不变（只换删除动作）
- **NFR4**：安装在正常路径上的行为不变 —— 合法的过期文件仍须被删除

---

## 4. Technical Design

### 4.1 `guarded_remove` 的真实契约（Alex 已实测）

```bash
guarded_remove() {
    local full_path="$1" backup_path="$2" rel_path="$3" base="$4"
    check_containment "$base" "$rel_path"   || return 1   # 符号链接 + 逃逸
    check_zero_touch  "$base" "$rel_path"   || return 1   # zero-touch 子树
    [ -e "$backup_path" ] || [ -d "$backup_path" ] || return 1   # 备份必须存在
    rm -rf -- "$full_path"
}
```

⚠️ **第三个前置是硬要求**：没有备份就 ABORT。本单必须先备份再调用（见 §4.3）。

⚠️ **`guarded_remove` 不调用 `validate_path`**（前缀 allow-list，`migration-engine.sh:72-76`）——
那只存在于 `validate_full` 中。**本单获得的是 containment + zero-touch 两重，不含 allow-list。**
（Gate 2 reviewer `c96838fe` 指出。）这不改变本单的价值，但 Blake 不应误以为拿到了三重防护。

### 4.2 三个守卫的实测行为（Alex 已验证，可作为 AC 依据）

| 输入 | `check_containment` | `check_zero_touch` |
|---|---|---|
| `.tad/templates/a.template`（正常） | 放行 | 放行 |
| `.tad/domains/x`（`domains` 是符号链接） | **拒绝** `symlink component` | — |
| `.tad/../../outside.md`（逃出目标） | **拒绝** `realpath escapes target` | — |
| `.tad/../AGENTS.md`（穿越但仍在目标内） | **放行** ⚠️ | — |
| `.tad/memory` | — | **拒绝** `ZERO_TOUCH` |
| `.tad/./memory` | — | **拒绝**（物理解析） |
| `.tad/Project-Knowledge` | — | **拒绝**（大小写归一） |

⚠️ **注意第 4 行**：`check_containment` 只保证不逃出目标项目，**`.tad/../AGENTS.md` 它是放行的**。
拦住用户根文件靠的是 `deprecation.yaml` 清单本身（F-01 已修）+ `check_zero_touch`。
**本单不改变这个分工**，但 AC 须如实反映它 —— 不得声称本单能拦住所有用户文件。

### 4.3 备份 —— 方案已定，Blake 不得再选

⚠️ **原 §4.3 留的"方案 B"（复用安装流程已有备份）已被 Gate 2 reviewer `08c15216` 证伪**：

`backup_existing()`（`tad.sh:164-172`）只做 `cp -r .tad "$backup_dir"`：

| 覆盖情况 | 数字 |
|---|---|
| `.tad/*` 路径 | 45 / 82 有备份 |
| **`.claude/*` 路径** | **36 / 82 完全无备份** |
| `.codex/hooks.json` | 1 / 82 无备份 |
| **全新安装**（`[ -d ".tad" ]` 为假） | **0 / 82** |

→ 那 37 条会在 `guarded_remove` 处**全部 ABORT**，过期文件清理不掉（NFR4 违反）。

**✅ 采用引擎自己的 `do_backup`**（`migration-engine.sh:641`），并照抄其标准调用对（`:898-899`）：

```bash
do_backup      "$rel_path" "$backup_base"                            || rc=$?
guarded_remove "$full_path" "$backup_base/$rel_path" "$rel_path" "$TARGET" || rc=$?
```

**Blake 须注意**：
- ⚠️ **`do_backup` 读三个全局 `TARGET`、`M_FROM`、`M_TO`，三者【全部必须设置】。**
  **传 `backup_base` 参数不能替代** —— `do_backup` 内部仍会用 `${M_FROM}`/`${M_TO}` 拼 containment 检查路径（`:649`）。
  实测：未设置时报 `M_FROM: unbound variable`，这是**致命 shell 错误，`|| rc=$?` 抓不住、ERR trap 也不触发**，安装器直接死。
  （Gate 2 第 4 轮 reviewer `aea44a29` 在沙箱实现中撞到此处。）

- ⚠️ **`M_FROM`/`M_TO` 取什么值**：**不得**用 `old_ver`→`new_ver` —— 那会让 `backup_base` 与
  `call_migration_engine` 的完全相同，而 `do_backup` **拒绝覆盖已存在的备份**，导致同时出现在
  migration manifest 与 `deprecation.yaml` 的路径被拒（NFR4 违反）。
  **建议用 `current_version`→`current_version`**（reviewer 沙箱采用并验证可行），或任何能与迁移备份区分开的值。

- ⚠️ **必须在 source 之后调用 `load_zero_touch "$src"`** —— FR-4 要求 `ZT_LIST` 来自
  `derive-sync-set.sh`，而**省略它会静默失败开放**：`ZT_LIST=""` 时 `check_zero_touch` **放行一切**。
  只有 AC-5 能发现。
  ⚠️ 该函数在权威源不可读时会 **`exit 2`**（`:137-143`）—— 那是绕过 `|| rc=$?` 与 rollback trap 的硬退出。
  Blake 须评估此风险并在 completion 记录处置（可接受"读不到权威源就拒绝安装"，但必须是**有意识的选择**）。

- ⚠️ **赋值顺序**：引擎第 15 行在 source 时会把 `TARGET`/`SOURCE`/`FROM_VER`/`TO_VER` **重置为空**。
  因此 `TARGET` 必须在 **source 之后**赋值。
- `check_zero_touch:152-154` **拒绝任何 `.tad-backup/` 下的 rel_path** —— 手搓的备份命名方案会撞上这条守卫，这是必须用 `do_backup` 而非自己 `cp -R` 的第二个理由
- `backup_base` 的既有约定是 `"$TARGET/.tad-backup/${M_FROM}-to-${M_TO}"`（`:826`）

### 4.4 如何复用引擎 —— 人已裁定：改引擎加 `BASH_SOURCE` 守卫

⚠️ **原 §4.4 让 Blake 自己决定 source 时机，那是不可能完成的**：
`migration-engine.sh:1019` 有顶层 `main "$@"`，**source 即立即执行整个引擎**；
且 `main()` 与 `version_le()` 两处函数名冲突；而原 NFR1 禁止改引擎 —— **约束三元组自相矛盾**。

**✅ 人类裁定（2026-08-17）：给 `migration-engine.sh` 开一个明确的口子。**

**唯一允许的改动**（一行结构）：

```bash
# 原：
main "$@"

# 改为：
# Only auto-run when executed directly, never when sourced.
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    main "$@"
fi
```

**Alex 已实测该改动的安全性**：

| 检查 | 结果 |
|---|---|
| 现有消费者调用方式 | `tad.sh:1126`、`run-fixtures.sh:9`、`test-15-dual-caller-integration.sh:18` —— **全部是 `bash "$engine"` 子进程执行，无人 `source`** |
| 加守卫后**直接执行** | 行为**完全不变**（无参数 → usage → exit 2） |
| 加守卫后**被 source** | 不自动执行，`guarded_remove` 等函数可用 |

**`version_le` 冲突的处置**：两个实现语义相同，引擎版多了 `LC_ALL=C`（**更健壮**）。
source 后引擎版会覆盖 `tad.sh:1227` 的版本 —— **这是无害的，甚至是改进**。
但 Blake 须在 completion 中**显式记录**该覆盖已知且被接受，并验证 deprecation 的版本闸门行为不变。

**`main` 冲突的处置**：加了 `BASH_SOURCE` 守卫后引擎的 `main` 仍会被定义并覆盖 `tad.sh` 的。
⚠️ **source 的位置已由 Gate 2 第 3 轮实测确定，不是开放问题**：
- **顶层 source（在 `tad.sh:1921` 之前）→ 不可行**。reviewer 沙箱实测：引擎的 `main` 会**静默替换**安装器的 `main`，运行时打印引擎 usage 并 **exit 2**。
- **「之后」不存在** —— `main "$@"` 是 `tad.sh` 的最后一行。
- **✅ 唯一可行：在 `apply_deprecations` 函数内部 source**（实测 exit 0，引擎函数可用）。

**Blake 须照此实现**，并在 completion 中记录该位置选择及其实测证据。

### 4.5 拒绝不得中断安装 —— 范式已定并实测

⚠️ **这是 Gate 2 最危险的一条 P0**：`tad.sh:7` 有 `set -euo pipefail`，`:1310` 有
`trap 'rollback_on_failure' ERR`，而 `rollback_on_failure` 执行 `rm -rf .tad` + 回滚 + `exit 1`。

**若照原设计直接写 `guarded_remove ... && deleted=$((deleted+1))`，一条被拒条目会摧毁并回滚整个安装** ——
与 FR-3 和硬禁止 #5 完全相反。

**✅ 必须采用的范式**（照抄 `tad.sh:1134-1137` 的既有写法，其注释明确说明
`|| rc=$?` 是 POSIX 保证能抑制 ERR trap 的，`set +e` 反而不行）：

```bash
local rc=0
do_backup      "$rel" "$backup_base"                          || rc=$?
[ "$rc" -eq 0 ] && { guarded_remove "$full" "$backup_base/$rel" "$rel" "$TARGET" || rc=$?; }
if [ "$rc" -eq 0 ]; then
    deleted=$(( deleted + 1 ))
else
    log_warn "  ⚠ refused (rc=$rc): $rel"    # 必须可见
fi
```

**Alex 已实测该范式**：拒绝被记录 → 循环继续 → 后续条目正常删除 → `deleted` 计数正确 → **退出码 0，ERR trap 未触发**。

⚠️ **另须移除 `2>/dev/null`**（`tad.sh:1213`）—— 否则 `guarded_remove` 的 `ABORT:` 信息会被吞掉，
AC-6 要求的"可见记录"就不存在了。

## 5. 强制问题回答

### MQ1 历史搜索
**是**。F-02 来自 2026-08-16 审计；声明层护栏的失败史见 §2.2 与 `patterns/ac-verification.md`。

### MQ2 位置存在性

| 位置 | 内容 | ✅ |
|---|---|---|
| `tad.sh:1212-1214` | 裸 `rm -rf -- "$target"` | ✅ |
| `.tad/hooks/lib/migration-engine.sh:216` | `guarded_remove` 四参数 | ✅ |
| 同 `:85` / `:147` | `check_containment` / `check_zero_touch` | ✅ |
| `derive-sync-set.sh --zero-touch` | 12 个用户产出目录 | ✅ |
| `derive-sync-set.sh:77` | `TOP_DENY="sync-registry.yaml"` | ✅ |

### MQ3 数据流

```
deprecation.yaml files: 条目
   ↓ apply_deprecations 解析（本单不改）
$target 字符串
   ↓ 【本单新增】do_backup（⚠️ 在守卫【之前】执行 —— 被拒条目也会先被 cp -a 到备份区，
   ↓                        非破坏性，但备份区会含未被删除的条目，属预期行为）
   ↓ 【本单新增】guarded_remove
   ├─ check_containment  → 符号链接？逃出目标？→ 拒绝
   ├─ check_zero_touch   → 用户产出子树？→ 拒绝
   ├─ backup 存在？      → 否则 ABORT
   └─ rm -rf
```

**改前**：`[ -e "$target" ]` → `rm -rf`。中间没有任何东西。

### MQ4 视觉层级
N/A。

### MQ5 状态同步
`tad.sh` 无 `.agents` 镜像。`migration-engine.sh` 同理。**本单不涉及镜像同步。**

### MQ6 知识评估
预期产出：**「防护要装在执行点，不是声明点」** —— 本单是该判据的正例，§2.2 的五次失败是反例。

---

## 6. Implementation Steps

| # | 步骤 | FR |
|---|---|---|
| 1 | 跑 §9 全部 AC 改前值，存档 | — |
| 2 | 按 §4.3 使用引擎的 `do_backup`（**方案已定，B 已被证伪，不得再选**）；确认 `TARGET`/`M_FROM`/`M_TO` 的设置方式 | FR-2 |
| 3 | 按 §4.4 加 `BASH_SOURCE` 守卫并 source 引擎（**方式已由人裁定**）；只需确定 source 的**位置**（`tad.sh:1921` 调用 `main` 之前/之后），并给出可运行证据 | — |
| 4 | 改 `apply_deprecations` 的删除动作为 `guarded_remove` | FR-1 |
| 5 | 加拒绝条目的记录与继续逻辑 | FR-3 |
| 6 | 沙箱验证：正常删除仍工作、符号链接被拒、zero-touch 被拒 | — |
| 7 | 跑全部 AC 改后值 | — |

**预计 3-4 小时。**

---

## 7. File Structure

**Modify**：
1. `tad.sh` —— `apply_deprecations` 的删除动作、source 语句、变量初始化
2. **`.tad/hooks/lib/migration-engine.sh`** —— **仅末行 `main "$@"` 改为 `BASH_SOURCE` 条件调用**（§4.4，人已裁定；AC-N2 限制 diff ≤4 行）

### 7.4 Required Evidence Manifest
- `.tad/evidence/reviews/blake/f02-guarded-deletion/` — ≥2 份独立 reviewer 文件
- `.tad/evidence/acceptance-tests/f02-guarded-deletion/` — AC 改前/改后 + 沙箱三场景输出

---

## 8. Testing Requirements

### 8.1 沙箱**四**场景（不可省略）

在 `mktemp -d` 中构造目标项目，用**从 `tad.sh` 逐字节提取**的 `apply_deprecations` 执行：

1. **正常路径**：`.tad/templates/x.template` 存在 → **必须被删**（证明 NFR4）
2. **符号链接**：`.tad/domains` → 项目外目录，清单含 `.tad/domains/x` → **必须被拒**，项目外文件存活
3. **zero-touch**：清单含 `.tad/memory` → **必须被拒**，文件存活

4. **混合清单（新增，Gate 2 reviewer 要求）**：清单含 `[.tad/memory（会被拒）, .tad/templates/x.template（正常）]`，
   **经真实安装路径执行、ERR trap 已武装**，断言：① 退出码 **0** ② stderr 有拒绝记录
   ③ `x.template` **已被删** ④ `deleted` 计数 == **1**

⚠️ **场景 4 需要绕过网络下载**：`tad.sh:1583` 在 `curl | tar -xz` 之后才设 `TAD_SRC`，而本仓尚无 `--source` 模式（F-33）。
reviewer 实测的可行做法：**在 `PATH` 前置一个 `curl` stub**（约 6 行）使其解出预置的本地源目录。

⚠️ **场景 4 需绕过网络下载**：`tad.sh:1583` 在 `curl | tar -xz` 之后才设 `TAD_SRC`，本仓尚无 `--source` 模式（F-33）。
reviewer 实测可行做法：**在 `PATH` 前置一个 `curl` stub**（约 6 行）令其解出预置的本地源目录。

⚠️ **场景 4 不可用"提取函数到沙箱"的方式测** —— 那样 `set -e` 与 `trap ERR` 都不存在，
**P0-2（单条拒绝摧毁整个安装）按构造就看不见**。必须走真实安装路径。

⚠️ **场景 1-3 若用提取方式，须连带提取 `source` 语句与任何 helper**，
否则沙箱里的函数与真实执行的不是同一份 —— 这正是「五版全败」教训 #1。

⚠️ **沙箱路径必须不含空格**（本仓自身路径含空格，见 `shell-portability.md`）。

⚠️ **须覆盖 `.claude/*` 路径**（占清单 36/82 且是零备份类），不得只测 `.tad/*`。

### 8.4 Friction Preflight
- `migration-engine.sh` 的三个函数可 `sed` 提取并独立执行 ✅（Alex 已验证）
- `derive-sync-set.sh --zero-touch` 可用 ✅

---

## 9. Acceptance Criteria

### 9.0 方言
`[F]`=`grep -F` ｜ `[BRE]`=`grep` ｜ `[ERE]`=`grep -E` ｜ `[sh]`=bash 执行
⚠️ 表格内 `\|` 为 Markdown 转义，按方言还原。

### 9.1 AC 表

| AC | 命令 | 期望 | 改前实测 |
|---|---|---|---|
| **AC-1** | `[BRE]` `sed -n '/^apply_deprecations/,/^}/p' tad.sh \| grep -c 'guarded_remove'` | `≥1` | **0** 🔴 |
| **AC-1b** | `[sh]` **行为式判据 —— `guarded_remove` 必须来自引擎文件**（⚠️ 字符串判据已被证明无效：`guarded_remove ()` 多一个空格、`function guarded_remove`、缩进定义都能骗过 `grep`）：<br>在 source 后执行 `shopt -s extdebug; declare -F guarded_remove`，输出的**第三字段必须是 `migration-engine.sh` 的路径** | 路径含 `migration-engine.sh` | 函数不存在 🔴 |
| **AC-1b2** | `[sh]` 同法验证 `check_containment` 与 `check_zero_touch` 也来自引擎 | 两者路径均含 `migration-engine.sh` | 不存在 🔴 |
| **AC-1c** | `[sh]` **行为式 —— 引擎确实被加载**（⚠️ 原文本判据会**判红正确实现**：`tad.sh:1126` 已把路径存进 `local engine=…`，自然写法 `source "$engine"` 使 `grep` 得 **0**）：<br>在 §8.1 场景 4 的真实安装运行中，于 `apply_deprecations` 内部 dump `declare -F guarded_remove`，输出第三字段须为引擎路径 | 路径含 `migration-engine.sh` | 不可执行（未实现）🔴 |
| **AC-2** | `[BRE]` 函数体内不再有裸 `rm -rf`：`sed -n '/^apply_deprecations/,/^}/p' tad.sh \| grep -c 'rm -rf'` | `0` | **1** 🔴 |
| **AC-2b** | `[ERE]` **防把删除挪进别处**（覆盖 `-rf`/`-fr`/`-Rf` 等写法）：<br>`grep -cE 'rm[[:space:]]+-[a-zA-Z]*[rf][a-zA-Z]*[[:space:]]' tad.sh` | **`11`**（改前 12，删除点移除且别处不新增） | **12** ✅（已实测）|
| **AC-2c** | `[F]` **AC-2b 的配套**：`:1585` 的注释含字面 `rm -rf`，是 12 中的一条且改前改后都在。若 Blake 改写该注释，AC-2b 的算术会失效 —— 断言它未被改动：`sed -n '1585p' tad.sh \| grep -cF 'rm -rf'` | **仍为 `1`** | **1** ✅ |
| **AC-3** | `[sh]` **沙箱场景 1**：正常过期文件仍被删除 | 被删 | 被删 ✅（须保持） |
| **AC-4** | `[sh]` **沙箱场景 2**：`.tad/domains` 为符号链接时，项目外文件**存活** | 存活 | **被删** 🔴 |
| **AC-5** | `[sh]` **沙箱场景 3**：清单含 `.tad/memory` 时该目录**存活** | 存活 | **被删** 🔴 |
| **AC-6** | `[sh]` **沙箱场景 4（新增，见 §8.1）—— 混合清单**：`[被拒条目, 正常过期文件]` 经**真实安装路径**（ERR trap 已武装）执行，须同时满足：<br>① 退出码 **0**<br>② stderr 有该拒绝的可见记录<br>③ 正常文件**已被删**<br>④ `deleted` 计数 == **1** | 四项全中 | 不可执行（未实现）🔴 |
| **AC-7** | `[sh]` **ZT_LIST 非硬编码**（原写法会惩罚正确实现 —— `load_zero_touch` 本身就调 `derive-sync-set.sh`）：<br>① `tad.sh` 内无硬编码的 zero-touch 目录清单：`grep -cE 'project-knowledge.*memory.*decisions' tad.sh` == `0`<br>② 运行时 `ZT_LIST` 非空（沙箱中打印其行数 ≥ 12） | ①=0 且 ②≥12 | ①**0** ✅ ／ ② 不可执行 🔴 |
| **AC-N1** | `[sh]` **负控**：`bash -n tad.sh` | `0` | **0** ✅ |
| **AC-N2** | `[git]` **负控 —— 引擎改动仅限守卫**（⚠️ 原写 `grep -cE '^\+'` 会把 `+++ b/…` 头也数进去，导致**正确实现被判红**）：<br>`git diff <起始SHA> -- .tad/hooks/lib/migration-engine.sh \| grep -cE '^\+[^+]'` ≤ **4**，且人工核对新增行只含 `BASH_SOURCE` 守卫结构 | ≤4 且仅守卫 | — |
| **AC-N2b** | `[sh]` **负控 —— 引擎直接执行行为不变**：`bash .tad/hooks/lib/migration-engine.sh; echo $?` | **`2`**（usage） | **2** ✅ |
| **AC-N2c** | `[sh]` **负控 —— 既有消费者不受影响**：`bash .tad/tests/migration-fixtures/run-fixtures.sh` | 与改前同 | 需先取基线 |
| **AC-N3** | `[git]` **负控 NFR2**：`.tad/deprecation.yaml` 未改动 | `0` | — |
| **AC-N4** | `[sh]` **负控**：`bash .tad/hooks/lib/release-verify.sh parity . ; echo $?` | `0` | **0** ✅ |
| **AC-N5** | `[sh]` **负控 NFR3 —— 解析逻辑未变**（⚠️ 必须用**解析器范围**的计数，裸 `grep -cE '^[[:space:]]+-'` 会得到 92 而非 82）：<br>用 §9.3 给出的完整提取命令 | **`82`** | **82** ✅ |

### 9.3 AC-N5 的完整提取命令（不得简写）

```bash
awk_free_count() {
  local inf=0 n=0 line
  while IFS= read -r line; do
    printf '%s' "$line" | grep -qE '^[[:space:]]+"[0-9]+\.[0-9]+\.[0-9]+":' && { inf=0; continue; }
    printf '%s' "$line" | grep -qE '^[[:space:]]+files:[[:space:]]*$' && { inf=1; continue; }
    [ "$inf" = 1 ] && printf '%s' "$line" | grep -qE '^[[:space:]]+[a-z_]+:' && { inf=0; continue; }
    [ "$inf" = 1 ] && printf '%s' "$line" | grep -qE '^[[:space:]]+-[[:space:]]+' && n=$((n+1))
  done < .tad/deprecation.yaml
  printf '%s\n' "$n"
}
```
⚠️ **必须用与 `tad.sh` 相同的状态机**。裸 grep 会数进 `removed_from_this_list:` 下的条目（得 92）。
这正是 `patterns/ac-verification.md`「五版全败」教训 #1 的直接应用。

⚠️ **AC-4 与 AC-5 是本单的判别力核心** —— 它们证明防护真的生效。
⚠️ **AC-3 与 AC-N5 防止"把删除功能改坏了"** —— 只拒不删同样是失败。

### 9.2 Expert Review Status —— **第 1 轮完成，Gate 2 FAIL**

**Reviewer A（`c96838fe`，事实核查）→ `F02 CLAIMS SOUND`**
缺陷真实、`guarded_remove` 契约描述准确、**§4.2 的 7 行行为表全对**（含我如实标注的
「`.tad/../AGENTS.md` 被放行」那行）。
抓到两处引用错误：`tad.sh:1201-1203` 应为 **1212-1214**；守卫函数计数 13 应为 **11**。
✅ 均已修正。并补记：`guarded_remove` **不含** `validate_path`（allow-list 只在 `validate_full`）。

**Reviewer B（`08c15216`，AC 与可实现性）→ `F02 GATE2 BLOCKED`，4 个 P0**

全部经 Alex 独立复核属实：

| # | P0 | 复核证据 |
|---|---|---|
| **1** | **`source` 在本单的约束下不可能** —— `migration-engine.sh:1019` 有顶层 `main "$@"`，source 即立即执行整个引擎；且 `main()` 与 `version_le()` **两处函数名冲突**。而 NFR1／硬禁止 #1 禁止我改引擎去加 `BASH_SOURCE` 守卫 | `grep '^main "\$@"'` → `:1019`；`comm` 求交 → `main()`、`version_le()` |
| **2** | **`set -e` + ERR trap 会把单条拒绝变成整个安装被摧毁** —— `tad.sh:7 set -euo pipefail`、`:1310 trap 'rollback_on_failure' ERR`，而 `rollback_on_failure` 执行 `rm -rf .tad` + 回滚 + `exit 1`。**这与 FR-3／硬禁止 #5 完全相反** | 逐行确认 |
| **3** | **§4.3 方案 B 已被证伪**（不只是未证实）—— `backup_existing` 只 `cp -r .tad`：**36 个 `.claude/*` 路径零备份**（占 82 条的 44%），且全新安装时 `[ -d ".tad" ]` 为假 → **0/82 有备份**。`guarded_remove` 会对它们全部 ABORT | 读 `backup_existing()` 全文 |
| **4** | **`do_backup` 已存在而我漏了** —— `migration-engine.sh:641`，且 `:898-899` 就是标准调用对 `do_backup … \|\| exit 1` + `guarded_remove …`。我却让 Blake 自己手搓 `cp -R` | 读源码确认 |

**另有三条 AC 缺陷**（reviewer 指出，我复核属实）：
- **AC-2 可被绕过**：范围是 `sed` 界定的函数体，把 `rm -rf` 挪进别处的 helper 即可归零；
  更狠的是在 `tad.sh` 内定义一个**同名 shim** `guarded_remove(){ rm -rf -- "$1"; }`，**AC-1 与 AC-2 同时变绿而零安全收益**
- **AC-7 会惩罚正确实现**：`migration-engine.sh:132 load_zero_touch` 本身就调用 `derive-sync-set.sh --zero-touch`。
  Blake 若正确复用它，`grep -c 'derive-sync-set.*zero-touch' tad.sh` = **0** → AC-7 判红。**该 AC 奖励的恰是 FR-4 想避免的重复**
- **AC-6 无判别力**：`guarded_remove` 自身就打印 `ABORT:`，「有记录」免费满足；而真正承重的「安装继续」**没有任何场景测试**

### 9.4 Gate 2 判定历史

> ⚠️ **以下为第 1 轮记录，其结论已被第 2/3 轮取代** —— 保留作为决策轨迹。
> P0-1 中「NFR1 禁止改引擎」一句**已不再成立**（人已于 2026-08-17 裁定开口，见 §4.4）；
> 三条 AC 缺陷已在 §9.1 修复（AC-1b/1b2 改为行为式 `declare -F`、AC-2b 覆盖 `rm -fr`、AC-7 接受 `load_zero_touch` 复用）。

#### 第 1 轮：**FAIL**（2026-08-17）

**根因不是细节，是方案设计有缺陷**：我把「复用既有函数」写进了 Intent，却没验证**它能否被复用**。
`source` 不可行这一条，只要在出单前跑一次 `grep '^main' migration-engine.sh` 就能发现。

**这与本 Epic 反复出现的错误同形**：我用「migration-engine.sh 有完整守卫链」这个**正确的观察**，
直接推出了「接进去即可」这个**未经验证的结论**。中间隔着"如何接"，而那一层我没测。

**→ 需重做技术方案（§4）后再审。Alex 不得在方案确定前让 Blake 动手。**

#### 第 2 轮：**FAIL** —— 静态 AC 被一个空格打穿
`guarded_remove () { rm -fr -- "$1"; }`（多一个空格 + `-fr` 而非 `-rf`）使**五条静态 AC 全绿而零安全收益**。
AC-N2 的 `grep -cE '^\+'` 把 `+++` diff 头也计入，**判红正确实现**。
→ ✅ 已改为**行为式判据**：`shopt -s extdebug; declare -F` 给出函数的真实定义文件，字符串写法骗不过它。
实测四种 shim 变体（空格 / `function` 关键字 / 缩进 / 空实现）**全部抓住**，正确实现通过。

#### 第 3 轮：**FAIL** —— 三个修复均验证正确，但工单自洽性有四处崩塌
reviewer 确认 AC-1b/1b2、AC-2b、AC-N2 三项修复**全部有效**，但发现：
①§7 未列引擎为 Modify（与 NFR1 例外／§4.4／AC-N2 直接冲突）；②Gate 2 勾选「改前值全部实测」为假；
③**AC-1c 会判红正确实现**（`tad.sh:1126` 已把路径存进变量，自然写法 `source "$engine"` 使 grep 得 0）；
④§10.2 概括接受 `main` 冲突，而它允许的顶层 source **实测会使安装器 exit 2**。
→ ✅ 四条均已就地修正；AC-1c 改为行为式；§4.4 明确**唯一可行位置是函数内 source**。

---

## 10. Important Notes

### 10.1 五条硬禁止

1. **禁止修改 `migration-engine.sh` 的守卫逻辑。** 唯一例外是 §4.4 的 `BASH_SOURCE` 守卫（人已裁定）。AC-N2 限制 diff ≤4 行且仅含守卫结构。
2. **禁止改 `deprecation.yaml`。** 清单已于 `46af019c` 修好。AC-N3 拦这个。
3. **禁止在声明层加校验。** 该方向已被五次失败证伪（§2.2）。
4. **禁止假设备份已存在。** `guarded_remove` 无备份即 ABORT。**必须用 §4.3 的 `do_backup`** —— 方案 B（复用 `backup_existing`）已被证伪：36 个 `.claude/*` 零备份，全新安装 0/82。
5. **禁止让单条拒绝中断整个安装。** 拒绝须记录并继续（FR-3）。

### 10.2 遇到以下必须停下上报
- `guarded_remove` 对**正常的**过期文件也 ABORT（说明备份方案不对）
- source 引擎后出现**除 `main`/`version_le` 之外**的函数名冲突（这两个已在 §4.4 中已知并接受）。<br>⚠️ **但 `main` 冲突仅在【函数内 source】时无害** —— 若因故必须顶层 source，**必须停下上报**（实测顶层 source 会使安装器 exit 2）
- 沙箱中正常删除失效（AC-3 转红）

### 10.3 Sub-Agent 建议
- 沙箱**四个**场景**全部**由独立 subagent 执行，禁止自审（**场景 4 尤其不可自审** —— 它是唯一能发现「拒绝中断安装」的场景）
- 实现后调 `code-reviewer` 审 shell 改动，重点查变量初始化时机（`TARGET_REAL` / `ZT_LIST`）

---

## 11. Learning Content

### 11.1 防护装在执行点，不是声明点

**朴素做法**：配置文件可能被误编辑 → 加一条检查配置的校验。

**为什么不够**：校验的是**字符串**，破坏发生在**解析之后**。二者之间隔着解析器差异、路径规范化、
文件系统大小写语义、符号链接解析 —— 每一处都能让"校验通过的字符串"与"实际删除的位置"分离。

**证据**：2026-08-16 的五次尝试（§2.2），四个不同的失败根因，全部由独立 reviewer 端到端打穿。

**可迁移判据**：
> 当破坏性操作的输入来自配置时，**防护要装在执行点**（拿到最终解析结果之后），
> 而不是装在配置校验上。配置校验只能作为**附加**的早期提示，不能作为唯一防线。
> 判断方法：问「校验的对象与实际执行的对象，中间隔着几层转换？」——只要 ≥1 层，就存在分离的可能。

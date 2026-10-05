---
# gate3_verdict: filled by Blake as a Gate 3 POST-STEP (value ∈ pass|fail|partial).
# ⚠️ Do NOT fill at creation — the verdict does not exist until /gate 3 runs.
gate3_verdict: pass
---

# Implementation Completion Report

**From:** Blake (Agent B - Execution Master)
**To:** Alex & Human
**Date:** 2026-08-17
**Project:** TAD
**Task ID:** TASK-20260817-001
**Handoff ID:** HANDOFF-20260817-f02-guarded-deletion.md
**Baseline SHA:** `cd70cf26`

---

## 🔴 Gate 3 v2: Implementation & Integration Quality

### Layer 1 (Self-Check)

| 检查项 | 状态 | 说明 |
|--------|------|------|
| `bash -n tad.sh` (AC-N1) | ✅ | 0（bash 5.3 + macOS bash 3.2 双版本） |
| 引擎直接执行 (AC-N2b) | ✅ | 仍 usage exit 2 |
| fixtures 回归 (AC-N2c) | ✅ | 22/22（与改前基线一致） |
| release-verify parity (AC-N4) | ✅ | 0 |
| 解析逻辑未变 (AC-N5) | ✅ | 82（状态机计数，与改前一致） |

### Layer 2 (Expert Review)

| 专家 | 轮次 | 结论 |
|------|------|------|
| code-reviewer | R1 CONDITIONAL → R2 CONDITIONAL → R3 PASS → **R4 哈希对齐确认** | ✅ **PASS**（无 P0/P1） |
| 独立复验（四场景实跑 + 判别力构造 + 符号链接对抗） | R1 CONDITIONAL → **R2** | ✅ **PASS**（无 P0/残留 P1） |

⚠️ **哈希一致性已核实**：独立复验专家报告中的 `e91c53fc…` 既非 sha256 也非本地 git blob。
Blake 事后用 `cmp` 与 `shasum` 直接比对其 `/tmp/f02-mine/snap2/tad.sh` 与交付版：
**sha256 同为 `5a747e71…11d2`、git blob 同为 `a6ea84eb`、逐字节一致** ——
两位专家的 PASS 落在同一份交付字节上。

**Layer 2 累计发现并修复 3 条实质缺陷 + 1 条硬化**（全部由 reviewer 发现，非自查）：

| # | 来源 | 缺陷 | 修复 |
|---|---|---|---|
| P1-1 | code-reviewer | 权威源不可读时 `load_zero_touch` `exit 2` **硬杀安装**（绕过 `\|\| rc=$?` 与 rollback trap，留半更新状态） | 子 shell 探测 + warn/skip 降级（同样 fail-closed） |
| P1-2 | code-reviewer | `.`/`..` 未在 `do_backup` 前拦截 → 整树 `cp -a` 进备份区 | 遍历预检（**拒绝套用 `validate_path`**，见下） |
| P1-2b | code-reviewer R2 | 上条窄修**自身不完备**：`./` `a/./` `.//` 漏网 → `cp -a "$TARGET/."` **递归自复制**至路径超长，本轮后续条目全失效 | 换完备谓词 `(^\|/)\.\.?(/\|$)` |
| P1-3 | 独立复验 | 守卫拒绝的条目**副本已先落进** `.tad-backup/`，而目标项目只忽略点号版 `.tad.backup.*/` → 用户 memory 副本可被提交 | 被拒即回滚本次创建的副本 |
| P2 | code-reviewer | 探针子 shell 继承已布防的 rollback trap | `( trap - ERR; ... )` |

### 两处**拒绝照搬 reviewer 首选修法**的判断（已交 reviewer 复核并获认可）

1. **P1-2 不套 `validate_path`**：先对真实 82 条清单量拒绝集 → 它会拒掉
   **`.tad/codex/schemas/`**（尾斜杠，1/82），直接违反 NFR4。改用只拦遍历的谓词，
   实测对 82 条**零误伤**。证据：`predicate-impact-analysis.txt`。
2. **P1-3 不改 `.gitignore`**：那是**目标项目**的文件，安装器无权保证 14 个下游项目都有该规则，
   且副本仍留在磁盘上（治标）。改为回滚副本（治本）。

### Evidence

| 项 | 路径 |
|---|---|
| Reviewer 报告 ×2 | `.tad/evidence/reviews/blake/f02-guarded-deletion/` |
| AC 改前/改后 | `acceptance-tests/f02-guarded-deletion/{before,after}.txt` |
| 沙箱四场景 | `sandbox-1-3{.sh,-output.txt}`、`sandbox-4-real-install.sh`、`sandbox-4-output.txt` |
| P1 修复套件（12/12） | `p1-fix-verification.sh`、`p1-fix-output.txt` |
| 谓词误伤面分析 | `predicate-impact-analysis.txt`、`validate_path-impact-analysis.txt` |
| `version_le` 覆盖等价 | `version_le-override-equivalence.txt` |
| 交付快照哈希 | `delivery-snapshot.txt` |

⚠️ **证据不进 main**：`659f4161`（Phase 4 发行瘦身）已将 `.tad/evidence/` 加入 `.gitignore`，
完整内容保留在 orphan 分支 `origin/maintainer-evidence`。Gate 4 复核请在本地工作区查看上述路径，
或 `git show origin/maintainer-evidence:<path>`。

### Knowledge Assessment

| 检查项 | 状态 | 说明 |
|--------|------|------|
| ⚠️ New Discoveries | ✅ Yes | Journal: `.tad/evidence/journal/f02-guarded-deletion-2026-08-17.md`（2 轮共 7 条发现） |
| ⚠️ Skillify Candidate | ❌ No | 候选「否定式断言需要执行自证」已被 `ac-verification.md` 现有条目覆盖，不另开 |
| ⚠️ Workflow Pattern | ❌ No | 单任务顺序执行，无新编排模式 |

### Git

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Changes Committed | ⏳ | 待 Gate 3 判定后提交 |

**Gate 3 v2 结果**：✅ **PASS**
Layer 1 全绿（双 bash 语法 · fixtures 22/22 · parity=0 · 引擎直接执行 exit 2）
+ Layer 2 双专家 PASS（code-reviewer 4 轮 · 独立复验 2 轮，含符号链接对抗与判别力构造）
+ AC 全部达标（AC-1=1 · AC-2=0 · AC-2b=11 · AC-7①=0/②=12 · AC-N1=0 · AC-N2=4 · AC-N2b=2
· AC-N2c=22/22 · AC-N3=0 · AC-N4=0 · AC-N5=82 · 沙箱 AC-3/4/5/6 全绿）

---

## Reflexion History

无 Layer 1 reflexion（Layer 1 一次通过）。本单的 3 次返工全部来自 Layer 2 专家发现，
已在上表逐条记录，并蒸馏进 journal。

---

## 📋 实施总结

### 完成的工作
- `apply_deprecations()` 的删除动作从裸 `rm -rf` 改为 `do_backup` + `guarded_remove`，
  接入 `check_containment`（符号链接/逃逸）与 `check_zero_touch`（用户产出子树）两重守卫
- 引擎末行 `main "$@"` 加 `BASH_SOURCE` 条件（唯一允许的引擎改动，+4 行）
- 被拒条目记录并继续（`\|\| rc=$?` 抑制 ERR trap），不中断安装
- 三处 reviewer 发现的缺陷修复（见上表）

### 修改的文件
```
tad.sh                              # apply_deprecations：引擎装载 + 守卫删除 + 拒绝处理
.tad/hooks/lib/migration-engine.sh  # 仅末行 BASH_SOURCE 守卫（+4 行，守卫逻辑零改动）
```

---

## Notes（给 Alex / Gate 4）

1. **AC-2c 行号锚点失效（非实现缺陷）**：该 AC 断言 `sed -n '1585p' tad.sh` 含 `rm -rf`，
   用于给 AC-2b 的算术钉前提。本单在其上方新增 ~57 行，注释漂移到 **1641**。
   语义已验证：`git show cd70cf26:tad.sh | sed -n '1585p'` 与改后 `sed -n '1641p'`
   **逐字节相同**，且仍是 AC-2b 计数中的一条。建议 Gate 4 用内容锚定复核。
2. **已知限制 P2（同版本重跑）**：合法条目删除后其备份保留，同版本重跑时若文件被重建，
   `do_backup` 会以 "backup already exists" 拒绝，需手动清理 `.tad-backup/<cur>-to-<cur>`。
   这是引擎既有备份语义（拒绝覆盖是其安全设计），本单不改。
3. **既有 P2（非本单引入）**：macOS BSD `sort` 无 `-V` → `version_le` 在旧 macOS 上失效
   （`tad.sh` 原版同样）；`main`/`version_le` 定义替换依赖「main 仅调用一次且 deprecations
   在其体内」的单点不变量。
4. **`guarded_remove` 不含 allow-list**：本单获得 containment + zero-touch 两重，
   **不含** `validate_path` 的前缀 allow-list（那只在 `validate_full` 中）。
   拦住用户根文件仍靠 `deprecation.yaml` 清单本身（F-01 已修）。handoff §4.1 已如实标注。
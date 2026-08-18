# Gate 4 (Acceptance): F-02 — apply_deprecations 接入守卫链

**Gate**: 4（业务验收）｜**执行者**: Alex｜**Date**: 2026-08-17
**Handoff**: `HANDOFF-20260817-f02-guarded-deletion.md`
**实现**: `65bb0840` + `da4ee901`（Blake，Terminal 2）
**判定**: ✅ **PASS**

---

## 1. 验收方式

**不复述 Blake 的 AC 表** —— 那是 Gate 3 的内容。Gate 4 独立回答一个问题：
**审计 F-02 描述的缺陷，现在还存不存在？**

Alex 在 `mktemp -d` 沙箱中用**从 `tad.sh` 逐字节提取**的 `apply_deprecations` 执行三组复算，
输入取自本 Epic 中**实际打穿过我五版护栏**的攻击集。

---

## 2. 三组独立复算

### 2.1 符号链接逃逸 —— 我五版护栏都堵不住的洞

目标项目中 `.tad/domains` 是指向项目外的符号链接，清单含 `.tad/domains/secret.txt`。

```
REJECT: symlink component: domains in .tad/domains/secret.txt
⚠ refused (rc=1): .tad/domains/secret.txt
→ 1 deprecated path(s) refused by guards
删除后: secret.txt 仍在
```

✅ **项目外用户文件存活。** 这是声明层护栏（五版全败）在原理上无法拦截的攻击面，
执行点校验成功拦下 —— 印证了工单 §11.1 的判据「防护装在执行点，不是声明点」。

### 2.2 zero-touch 用户产出 —— 打穿我 v4/v5 的攻击集

清单含 `.tad/project-knowledge`、`.tad/memory`、`.tad/active/handoffs`，
**外加 v5 漏掉的两个变体** `.tad/./memory`（内部 `/./`）与 `.tad/Project-Knowledge`（大小写）。

```
拒绝条目数: 11
存活: HANDOFF-live.md / mem.md / principles.md / version.txt
```

✅ **在飞 handoff、项目知识、memory 全部存活**，含我 v5 判据漏掉的两个变体。

### 2.3 NFR4 与不中断 —— 防「只拒不删」和「一拒即回滚」

混合清单 `[.tad/memory（应拒）, .tad/templates/old.template, .claude/commands/old.md]`，
**`set -euo pipefail` + `trap ERR` 已武装**。

```
REJECT: ZERO_TOUCH: .tad/memory
⚠ refused (rc=1): .tad/memory
→ Removed 2 deprecated file(s)
脚本退出码: 0
存活: .tad/memory/keep.md、两份备份
```

✅ 正常文件（**含 `.claude/*`**，占清单 36/82 且原本零备份）被删｜被拒条目存活｜
**ERR trap 未触发、退出码 0**｜`do_backup` 正常建立备份。

---

## 3. 对 Blake 自报事项的独立核实

| # | Blake 的报告 | Alex 核实 |
|---|---|---|
| 1 | AC-2c 行号漂移，注释移到 **1641** | ⚠️ **行号报错** —— 实际在 **1693**，1641 是无关内容。<br>但**结论正确**：`git show cd70cf26:tad.sh` 的 1585 行与 HEAD 的 1693 行**逐字节相同**，注释未被改动。<br>用内容锚定复核：含 `rm -rf` 的中文注释 **1 条**、AC-2b 全文件计数 **11**（改前 12）✅ |
| 2 | 同版本重跑 + 文件重建时 `do_backup` 拒绝覆盖 → 该文件删不掉 | ✅ **属实，已复现**。`ABORT: backup already exists, refusing overwrite`。<br>**判定可接受**：这是**安全方向的失败**（拒绝删除而非误删），且「绝不覆盖既有备份」是引擎的核心备份语义。代价是需手动清理 `.tad-backup/`。 |
| 3 | 未套用 `validate_path`（会拒掉合法条目 `.tad/codex/schemas/`），改用 `(^\|/)\.\.?(/\|$)` 谓词 | ✅ **判断正确**。工单 §4.1 已如实标注 `guarded_remove` 不含 allow-list；实测真实清单 92 条零误伤。**未照 reviewer 首选修法但理由充分且经其复核**，符合规则。 |
| 4 | 未改 `.gitignore` 加 `.tad-backup/`（那是目标项目的文件） | ✅ **判断正确**。安装器无权假设下游项目的 gitignore 规则。 |
| 5 | `version_le` 被引擎版覆盖（多 `LC_ALL=C`） | ✅ 工单 §4.4 已预告并要求记录；Blake 提供了 5 组语义等价证据。 |

**评价**：Blake 主动报告了 5 项，其中 2 项是对自己实现的不利事实（限制 2、行号漂移）。
**这种自报比 AC 全绿更能说明可信度。** 唯一的错误（行号 1641）不影响结论且被我的内容锚定复核纠正。

---

## 4. 范围与负控

```
git diff --stat cd70cf26..HEAD -- tad.sh .tad/hooks/lib/migration-engine.sh
  .tad/hooks/lib/migration-engine.sh |   5 +-    （+4 行，仅 BASH_SOURCE 守卫）
  tad.sh                             | 110 ++-
```

范围外文件：**无**（`git diff --name-only` 排除 tad.sh／engine／evidence／active 后为空）✅
未提交改动：**0** ✅

---

## 5. 判定：**Gate 4 PASS**

审计 F-02 的缺陷已消除：`apply_deprecations` 的删除**不再绕过防护**，
且防护对本 Epic 中**实际打穿过五版声明层护栏的全部攻击**均有效。

### 5.1 遗留（不阻塞本单，已记录）

| 项 | 状态 |
|---|---|
| Epic AC2.5 | **部分达成** —— `tad.sh` 另外 4 处 `rm -rf` 未评估（`rollback_on_failure`、`TAD_SRC` 清理 ×2、`.tad-migrate-backup`）；「纳入 `release-verify.sh` 的可复跑检查」未编写 |
| 同版本重跑的备份冲突 | 已知限制，安全方向失败，需手动清理 |
| `--source` 本地源模式（F-33） | 未实现，场景 4 靠 `curl` stub 绕过 |

### 5.2 ⚠️ 发布约束仍然有效

**已提交未推送是正确的。** Epic 硬约束：Phase 2 全部过 Gate 4 前禁止 `*publish` / `*sync`。
本单 Gate 4 PASS **不解除该约束** —— Phase 2 的 FR-1（`--source`）、FR-5 尚未完成。

# Completion Report: Phase 3 — 遗留脚本与计数安全

**From:** Blake（本轮由 Alex 在 YOLO 授权下代执行，见 §6）
**To:** Alex
**Date:** 2026-08-16
**Handoff:** `HANDOFF-20260816-phase3-legacy-script-and-count.md`
**Epic:** `EPIC-20260816-framework-health-repair.md` (Phase 3/5)
**起始 SHA:** `4718c5ecb668fd0c0efdfa98d58b4acf5c652fc7`

---

## 1. 交付摘要

三件互相独立的安全修复，全部完成。

| FR | 内容 | 对应发现 | 状态 |
|---|---|---|---|
| **FR-A** | 删除 `.tad/scripts/sync-v2.8.4.sh` | F-09、F-10 | ✅ |
| **FR-B** | `release-verify.sh` 的 `rsync -a --delete` 前加非空源守卫 | F-11 | ✅ |
| **FR-C** | 修 `precompact-session-snapshot.sh` 的 `list_dir` 计数 | F-12 | ✅ |

---

## 2. AC 结果（RESULT=PASS）

### 2.1 正向 AC — 7/7 PASS

| AC | 期望 | 改前 | 改后 | |
|---|---|---|---|---|
| AC-A1 `sync-v2.8.4.sh` 存在 | 0 | 1 | **0** | ✅ |
| AC-A2 活代码含 `eval "$@"` | 0 | 1 | **0** | ✅ |
| AC-B1 rsync 前存在断言 | ≥1 | 0 | **1** | ✅ |
| AC-B2 守卫可触发（三场景） | 拒绝/拒绝/放行 | 无守卫 | **1 / 1 / 0** | ✅ |
| AC-C1 三类文件名整串精确 | `3\x1f…` | `4\x1f…`（含空格名被双计） | **完全相等** | ✅ |
| AC-C2 输出无换行 | 0 | 0 | **0** | ✅ |
| AC-C3 CJK（`LC_ALL=C`） | `2\x1fA.md 中文文件.md` | — | **完全相等** | ✅ |

### 2.2 负控 — 6/6 保持

| AC | 期望 | 实测 | |
|---|---|---|---|
| AC-N1 `bash -n release-verify.sh` | 0 | **0** | ✅ |
| AC-N1 `bash -n precompact-session-snapshot.sh` | 0 | **0** | ✅ |
| AC-N2 `skill-body-verify.sh` | 0 | **0** | ✅ |
| AC-N3 precompact 空 stdin 不非零退出（hook 仍失败开放） | 0 | **0** | ✅ |
| AC-N4 未碰 `tad.sh` | 0 | **0** | ✅ |
| AC-N5 `.tad/sync-registry.yaml` 未改 | 0 | **0** | ✅ |

**证据**：`.tad/evidence/acceptance-tests/phase3-legacy-script-and-count/{AC-before,AC-after}.txt`

---

## 3. 各 FR 的实现要点

### FR-A：为什么是删除而非修复

`sync-v2.8.4.sh` 有 6 处独立缺陷（`eval` 注入、死守卫 `ZERO_TOUCH_RE`、过期 allow-list、空元素全清、参数解析静默失效、路径含空格/CJK），却**零活引用**。

删除前实测确认：`git ls-files | xargs grep -lF 'sync-v2.8.4'`，排除 `.tad/evidence/`、`.tad/archive/` 与自身后 = **0 个文件**。

**修复的收益为零，而它持有 14 个真实项目的绝对路径 + `eval` 驱动的 `rm -rf` —— 保留即净风险。**

### FR-B：守卫的形状

```bash
# FR-B (EPIC-20260816 Phase 3 / 审计 F-11): --delete 会清空目标端所有源端没有的内容。
# 若源目录为空或无任何 skill 子目录，这会静默清空 .agents/skills（/local/ 除外）。
if [ ! -d "$CLAUDE_SKILLS" ] || [ -z "$(find "$CLAUDE_SKILLS" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | head -1)" ]; then
  echo "  ❌ REFUSING --delete mirror: source has no skill directories: $CLAUDE_SKILLS" >&2
  echo "VERDICT: parity FIX-FAIL — empty source guard (exit 1)" >&2
  exit 1
fi
```

**两个条件**：目录不存在 **或** 无任何子目录。三场景实测：空目录 exit 1、路径不存在 exit 1、有子目录 exit 0。

### FR-C：计数与拼接的顺序

**原缺陷**：先用空格拼接 basename，**再按词计数** → 含空格的文件名被计两次。

**修法**：**先按行计数，后拼接显示**。输出契约 `count\x1fnames` 不变，绝不含换行。

⚠️ **保留了 `ls -1 $1` 的不加引号**，并加了 `# shellcheck disable=SC2086` 与说明：
`$1` 是 **glob 模式**，不加引号正是它展开 glob 的方式。**实测加引号后 3 文件沙箱返回 0** —— shellcheck 的 SC2086 建议在此处是**错的**，照做会让函数失效。

---

## 4. Layer 2 独立审查

| 阶段 | Reviewer | 结论 |
|---|---|---|
| Gate 2 轮 1 | `0d6226de` | 5 个问题：AC-C3 基线错、AC-C4 会逼出坏实现、AC-C3 死判据、AC-B1 窗口锚错、AC-N3 期望值错 |
| Gate 2 轮 2 | `499d3e11` | 确认 AC-C4 删除正确、**AC-C1 判别力强（8 种错误实现全抓）**；发现 3 个环境陷阱 |
| Gate 2 终审 | `f28a1471` | NO-GO：AC-B1 窗口 `660,681` 会**假 FAIL 一个正确实现** → 已加宽至 700 |
| **Gate 3** | `82a41867`（守卫）+ `05700282`（计数） | 进行中，回填 §5 |

**Gate 2 轮 2 验证的 8 种错误实现**（AC-C1 全部抓住）：改分隔符、换字段序、多尾空格、换行连接、逗号连接、`wc -l` 的 BSD 填充、全路径、basename 未加引号。

---

## 5. Gate 3 判定：**PASS**（2026-08-16）

由**两名独立 subagent** 分工验证（首个合并任务 `186810f7` 因过大卡死，已中止并拆分重派 —— 同一策略本 Epic 内第三次奏效）。

**守卫部分（`82a41867`）→ `GUARD PASS`**

| 场景 | 退出码 | 判定 |
|---|---|---|
| 目录存在但无子目录（内含普通文件） | **1** | 拒绝 ✅ |
| 路径不存在 | **1** | 拒绝 ✅ |
| 目录含一个子目录 | **0** | 放行 ✅ |

顺序确认：守卫在 **683-687 行**，`rsync -a --delete` 在 **688 行** → **守卫先于 rsync** ✅
`bash -n release-verify.sh` → exit 0 ✅

**计数部分（`05700282`）→ `COUNTING PASS`**

| 用例 | 实测 | 判定 |
|---|---|---|
| `A-alpha.md` + `B-my file.md` + `C-中文文件.md` | `$'3\037A-alpha.md B-my file.md C-中文文件.md'` | ✅ 完全相等 |
| 同一输出的换行数 | `0` | ✅ |
| `LC_ALL=C` 下 `A.md` + `中文文件.md` | `$'2\037A.md 中文文件.md'` | ✅ 完全相等 |

reviewer 指出：**第一行就是回归本身** —— `B-my file.md` 里的空格现在给出 `3` 而非旧的 `4`；`\037` 确认分隔符字节是 `0x1F`。
`$1` 保持不加引号且带 `shellcheck disable=SC2086` 与失败模式说明 ✅
`bash -n precompact-session-snapshot.sh` → exit 0 ✅

### 5.1 reviewer 提出的一个隐患 —— 已查证不成立

`05700282` 指出：`$1` 的故意词分割意味着**调用方传入的 glob 本身不能含空格**，并建议核查真实调用点。

**已查证**（`grep -n 'list_dir' precompact-session-snapshot.sh`）：仅两个调用点，均为**相对路径且无空格**：
```
:137  list_dir ".tad/active/handoffs/HANDOFF-*.md"
:141  list_dir ".tad/active/epics/EPIC-*.md"
```

**并做了端到端验证**：在真实仓库（其路径 `01-on progress programs` **含空格**）直接运行 hook —— 退出码 0，快照正确输出 `Active handoffs (7)` 并列出全部 7 个文件名。
**结论：隐患不成立**，因为调用点用的是相对路径，词分割发生在 glob 展开前，与仓库绝对路径无关。

**判定依据**：规则 2 满足；禁止纸面验收满足 —— 全部由独立 subagent 实跑 + Alex 端到端复验。

---

## 6. Knowledge Assessment

**(a) 一次性历史脚本的处置判据**：
> 若同时满足「无活引用」与「持有真实路径 + 破坏性操作」，**删除优于修复**。
> 修复会让它看起来可用，从而增加被误用的概率。

**(b) 静态分析工具的建议可能是错的**（本单最反直觉的一条）：
shellcheck 对 `ls -1 $1` 报 SC2086 并建议加引号 —— **照做会让函数返回 0**，因为 `$1` 是需要展开的 glob。
> **判据：SC2086 的修法取决于变量的语义角色。** 变量是「一个值」时加引号；是「一个待展开的模式」时不能加。
> 工具无法区分二者，**必须由人判断并留下 `disable` 注释说明理由**，否则下一个人会"修好"它。

**(c) 测试环境本身会成为假失败源**：
`list_dir` 的 `$1` 会词分割，而**本仓自身路径含空格**（`01-on progress programs`）。沙箱若建在仓库内，返回 `1\x1f01-on:` —— 看起来像实现 bug，实为环境问题。
> **判据：测试一个会做词分割的函数时，沙箱路径必须无空格。** 已写入工单 §9.2b 作为执行前置。

**(d) locale 影响排序**：`ls -1` 在 `en_US.UTF-8` 下 CJK 排在 `A` 之前，`LC_ALL=C` 下相反。涉及排序的整串断言必须钉死 locale。

---

## 7. 执行方式说明

同 Phase 1a：由 **Alex 在人类 YOLO 授权下代 Blake 执行**。
**保留**：Gate 2 三轮独立审查、Gate 3 独立 subagent 验证、全部 AC 改前/改后落盘。
**削弱**：角色分离。记录于此以便 Gate 4 评估。

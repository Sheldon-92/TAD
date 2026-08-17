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
**Date:** 2026-08-16
**Project:** TAD Framework
**Task ID:** TASK-20260816-004
**Epic:** `EPIC-20260816-framework-health-repair.md` (Phase 3/5)
**依据:** 审计 `.tad/active/designs/AUDIT-20260816-framework-health.md` F-09、F-10、F-11、F-12

---

## 🔴 Gate 2

- [x] 需求明确
- [x] 技术方案完整
- [x] AC 可运行，改前值全部实测（§9）
- [x] MQ1-MQ6 已回答（§5）
- [ ] 专家审查 ≥2 且 P0 已修 —— **待审**

---

## 1. Task Overview

### 1.1 What We're Building

三件互相独立的安全修复：

| FR | 做什么 | 对应发现 |
|---|---|---|
| **FR-A** | **删除** `.tad/scripts/sync-v2.8.4.sh` | F-09、F-10 |
| **FR-B** | 给 `release-verify.sh` 的 `rsync --delete` 加非空断言 | F-11 |
| **FR-C** | 修 `precompact-session-snapshot.sh` 的 `list_dir` 计数 | F-12 |

三者无依赖关系，可任意顺序。

### 1.2 为什么 FR-A 是删除而非修复

`sync-v2.8.4.sh` 是一次性历史脚本，**却握着四个真实项目的绝对路径和一个 `eval` 驱动的 `rm -rf`**：

```bash
run() { if $DRY_RUN; then printf ...; else eval "$@"; fi }      # :47-52
run "rm -rf \"$proj_path/.tad/$d\""                             # :107
run "rm -rf \"$proj_path/.claude/skills/$skill_name\""          # :126
run "rm -rf \"$proj_path/$dep_file\""                           # :146
```

`$proj_path` 来自 `.tad/sync-registry.yaml`，**含空格（`OpenClaw Hack`）与中文（`运动打卡小助手`）**。路径若含 `"`、`` ` `` 或 `$(` 就会变成 `rm -rf` 内的可执行代码。

同文件另有三处缺陷：
- `:32` `ZERO_TOUCH_RE` 是**死守卫** —— 全文件引用数为 1（只有定义行），且只列 6 个目录而权威源是 12 个
- `:29` `FW_DIRS` 是过期硬编码 allow-list（14 项 vs 权威推导 23 项）
- `:105-110` 空元素时 `[ -d "$TAD_SRC/.tad/" ]` 为真 → 下一行变成 `rm -rf "$proj_path/.tad/"`，**整棵 `.tad` 连 zero-touch 一起清空**

**实测：无任何活代码引用它**（`git ls-files | xargs grep -l 'sync-v2.8.4'` 排除 evidence/archive 与自身后为 **0**）。修复成本远高于删除，收益为零。

### 1.3 Intent Statement

**要达成的**：消除一个可被路径注入的 `rm -rf`；给一个会删目标目录的镜像操作加上非空前置；修一个会在压缩恢复安全网里给出错误计数的函数。

**不追求的**：重构 `release-verify.sh` 或 `precompact` 的其他部分。**三处都是最小改动。**

---

## 📚 Project Knowledge（Blake 必读）

| Pattern | 相关点 |
|---|---|
| `shell-portability.md` | **本单核心** —— BSD/GNU 差异、zsh 分词、空格与 CJK 文件名 |
| `ac-verification.md` | 负控设计 |

**必须应用的三条**：

1. **`for f in $VAR` 在 zsh 下不分词** —— 本仓有过「sed 一个字没改，而汇总检查打印『全部替换』」的实例。
2. **判断文件有无内容用 `wc -c`，不用 `du`**（块舍入会把 4185 字节显示成 `0B`）。
3. **数不对时先怀疑判据。** FR-C 修的正是一个计数错误，**修完必须用含空格与 CJK 的文件名验证**。

### Blake 确认
- [ ] 我已读 `shell-portability.md`

---

## 2. Background Context

### 2.1 Previous Work
Phase 1a / 1b 处理 SKILL 与配置层，本单处理 shell 层。**无内容依赖**，可与 1a/1b 并行排期，但不同时 Active。

### 2.2 Current State
```
$ bash .tad/hooks/lib/skill-body-verify.sh    → exit 0
$ bash -n .tad/hooks/precompact-session-snapshot.sh   → 语法通过
```

### 2.3 Dependencies
无。

---

## 3. Requirements

### 3.1 Functional Requirements

| ID | 需求 |
|---|---|
| **FR-A** | 删除 `.tad/scripts/sync-v2.8.4.sh` |
| **FR-B** | `release-verify.sh:681` 的 `rsync -a --delete` 之前插入非空断言：`$CLAUDE_SKILLS` 目录必须存在且至少含 1 个子目录，否则报错退出（不执行镜像） |
| **FR-C** | `precompact-session-snapshot.sh` 的 `list_dir` 改为按行处理：计数用行数，名称拼接保持现有 `\x1f` 输出契约 |

### 3.2 Non-Functional Requirements
- **NFR1**：不得改 `tad.sh`
- **NFR2**：不得改变 `list_dir` 的**输出契约**（`count\x1fnames`，绝不含换行）—— 下游 `precompact` 快照格式依赖它
- **NFR3**：`release-verify.sh` 的其余行为不变（本单只加断言，不改判定逻辑）

---

## 4. Technical Design

### 4.1 FR-C 的修法

现状（`precompact-session-snapshot.sh:117-126`）：
```bash
names=$(ls -1 $1 2>/dev/null | while read -r f; do basename "$f"; done | tr '\n' ' ' | sed 's/ $//' || echo "")
count=$(printf '%s ' "$names" | tr ' ' '\n' | grep -c . 2>/dev/null || echo "?")
```

**唯一缺陷**：**先用空格拼接再按词计数** → 含空格的文件名被拆成多个。

⚠️ **`ls -1 $1` 的不加引号不是缺陷** —— `$1` 是 glob 模式，不加引号正是它展开 glob 的方式。
初稿曾按 SC2086 要求加引号，**实测加引号后 3 文件沙箱返回 0**（glob 不再展开），已撤回。

**要求**：计数必须在**拼接之前**完成（对行计数），拼接只用于显示。
**输出契约不变**：仍是 `printf '%s\x1f%s' "$count" "$names"`。

### 4.2 FR-B 的断言位置

`release-verify.sh:681` 当前上下文无任何前置检查：
```bash
if [ "$DIRECTION" = "claude-newer" ]; then
  echo "  🔧 Auto-fixing: rsync Claude→Codex..."
  rsync -a --delete --exclude=/local/ "$CLAUDE_SKILLS/" "$AGENTS_SKILLS/"
```

`--delete` 会删除目标端所有源端没有的内容。若 `$CLAUDE_SKILLS` 因任何原因为空目录，**`.agents/skills/` 会被清空**（`/local/` 除外）。

**断言要求**：源目录存在 **且** 至少含 1 个子目录，否则 `exit 1` 并说明原因，**不执行 rsync**。

---

## 5. 强制问题回答

### MQ1 历史搜索
**是**。F-09/F-10 来自 2026-08-16 shell 审计（沙箱复现），F-12 由 Alex 独立复现（2 文件 → 计数 3）。

### MQ2 位置存在性

| 位置 | 内容 | ✅ |
|---|---|---|
| `.tad/scripts/sync-v2.8.4.sh:47-52` | `run()` 含 `eval "$@"` | ✅ |
| 同 `:107, :126, :146` | 三处 `run "rm -rf ..."` | ✅ |
| 同 `:32` | `ZERO_TOUCH_RE`（引用数 1 = 死守卫） | ✅ |
| `release-verify.sh:681` | `rsync -a --delete --exclude=/local/` | ✅ |
| `precompact-session-snapshot.sh:117-126` | `list_dir()` | ✅ |

### MQ3 数据流
N/A。**等价检查**：`list_dir` 的输出契约（`count\x1fnames`）在改动前后必须一致 —— 由 AC-C3 断言。

### MQ4 视觉层级
N/A。

### MQ5 状态同步
本单三个文件均**无 `.agents` 镜像**（`.tad/scripts/` 与 `.tad/hooks/` 不参与双平台镜像）。由 AC-N2 断言 `skill-body-verify.sh` 仍绿，证明未误触镜像面。

### MQ6 知识评估
预期产出：**「一次性历史脚本若持有真实路径与破坏性操作，应当删除而非修复」** —— 修复成本高于删除且收益为零时，保留即净风险。

---

## 6. Implementation Steps

| # | 步骤 | FR |
|---|---|---|
| 1 | 跑 §9 全部 AC 改前值，存档 | — |
| 2 | 删 `.tad/scripts/sync-v2.8.4.sh` | FR-A |
| 3 | `release-verify.sh:681` 前插入非空断言 | FR-B |
| 4 | 重写 `list_dir`（按行计数，契约不变） | FR-C |
| 5 | 跑全部 AC 改后值 + 三类文件名负控（普通/含空格/CJK） | — |

**预计 1.5 小时。**

---

## 7. File Structure

**Delete**：`.tad/scripts/sync-v2.8.4.sh`
**Modify**：`.tad/hooks/lib/release-verify.sh`、`.tad/hooks/precompact-session-snapshot.sh`

### 7.4 Required Evidence Manifest
- `.tad/evidence/reviews/blake/phase3-legacy-script-and-count/` — ≥2 份独立 reviewer 文件
- `.tad/evidence/acceptance-tests/phase3-legacy-script-and-count/` — AC 改前/改后输出 + FR-C 的三类文件名测试记录

---

## 8. Testing Requirements

### 8.1 FR-C 必须的三类文件名测试

在 `mktemp -d` 中分别建：普通名（`A-alpha.md`）、**含空格名**（`B-my file.md`）、**CJK 名**（`C-中文文件.md`），断言 `list_dir` 计数 == `find -type f | wc -l`。

### 8.4 Friction Preflight
- `bash -n` 可用 ✅
- `shellcheck` 可用（`/opt/homebrew/bin/shellcheck`，v0.11.0）✅

---

## 9. Acceptance Criteria

### 9.0 方言标注
`[F]`=`grep -F` ｜ `[BRE]`=`grep` ｜ `[ERE]`=`grep -E` ｜ `[awk]`=awk 程序 ｜ `[sh]`=直接执行 ｜ `[git]`=git 命令
⚠️ 表格内 `\|` 与全角 `｜` 均为 Markdown 排版转义 —— **执行前按标注还原成该方言的「或」语法**（ERE/awk 用 `|`，BRE 用 `\|`，`-F` 不涉及）。

⚠️ **AC-B1 的判别力已修正一次，留痕**：初稿写 `sed -n '661,681p' … | grep -c 'CLAUDE_SKILLS'`，空跑返回 **1** —— 它匹到的是 `rsync` 那行**自己**的 `$CLAUDE_SKILLS`，不是断言。这样「改前」就是绿的，AC 失效。现改为 awk 形式：在 `rsync` 行处停止扫描，且要求命中行同时含守卫/退出语义。**空跑确认改前为 0。**

### 9.1 AC 表

| AC | 方言 | 命令 | 期望 | 改前实测 |
|---|---|---|---|---|
| **AC-A1** | `[F]` | `ls .tad/scripts/sync-v2.8.4.sh 2>/dev/null \| wc -l` | `0` | **1** 🔴 |
| **AC-A2** | `[F]` | 全仓无 `eval "$@"`（排除 evidence/archive）：`git ls-files -z \| xargs -0 grep -lF 'eval "$@"' \| grep -vcE '\.tad/(evidence\|archive)/'` | `0` | **1** 🔴 |
| **AC-B1** | `[BRE]` | **窗口 660-700**（⚠️ **两次修正**：初版 awk 停在 `:97` 的注释只扫 1-96 行；二版窗口 `660,681` 仍会**假 FAIL 一个正确实现** —— 插入守卫会把 rsync 推到 681+N，若守卫首行是注释则落在窗口外。实测：带注释的正确守卫在 `660,681` 下返回 **0**）：<br>`sed -n '660,700p' .tad/hooks/lib/release-verify.sh \| grep -cE '(\[ -z\|\[ ! -d\|find .*-maxdepth\|exit [12]).*CLAUDE_SKILLS\|CLAUDE_SKILLS.*(\|\| *exit\|\|\| *return)'` | `≥1` | **0** 🔴（加宽后实测改前仍 0、改后 1，判别力成立） |
| **AC-B2** | `[sh]` | **负控（可触发性）**：构造 `$CLAUDE_SKILLS` 存在但**无子目录**的沙箱调用 `--fix`，须 **exit 非 0 且未执行 rsync** | 拒绝执行 | 会静默清空 🔴 |
| **AC-C1** | `[sh]` | **整串精确断言**（一条同时覆盖计数/分隔符/字段顺序/连接方式/CJK）：<br>沙箱含 `A-alpha.md`、`B-my file.md`、`C-中文文件.md` →<br>`[ "$(list_dir "$SB/h/*.md")" = $'3\x1fA-alpha.md B-my file.md C-中文文件.md' ]` | **true** | **false**（实际 `4\x1f…`）🔴 |
| **AC-C2** | `[sh]` | **契约负控 —— 输出不得含换行**（原写法 `grep -c $'\n'` 是**死判据**：换行作模式被拆成两个空模式，匹配每一行，恒返回 ≥1，期望值 0 不可达）：<br>`list_dir … \| tr -cd '\n' \| wc -c` | `0` | **0** ✅ |
| **AC-C3** | `[sh]` | **CJK 单独负控**（⚠️ **必须 `LC_ALL=C`** —— 排序受 locale 影响，见 §9.2b）：<br>沙箱仅含 `A.md` + `中文文件.md` →<br>`LC_ALL=C` 下整串须为 `$'2\x1fA.md 中文文件.md'` | **true** | **true** ✅（`LC_ALL=C` 下实测） |
| **AC-N1** | `[sh]` | **负控**：`bash -n` 对两个被改脚本 | 全通过 | 通过 ✅ |
| **AC-N2** | `[sh]` | **负控**：`bash .tad/hooks/lib/skill-body-verify.sh; echo $?` | `0` | **0** ✅ |
| **AC-N3** | `[sh]` | **负控（hook 仍失败开放）**：`precompact-session-snapshot.sh` 在无 handoff 时不得非零退出 —— `bash .tad/hooks/precompact-session-snapshot.sh </dev/null >/dev/null 2>&1; echo $?` | `0` | 待测 |
| **AC-N4** | `[git]` | **负控 NFR1**：`git diff --name-only <起始SHA>..HEAD \| grep -cE '^tad\.sh$'` | `0` | — |
| **AC-N5** | `[F]` | **负控**：`.tad/sync-registry.yaml` 未被改动 | 未改 | 未改 ✅ |

### 9.2b ⚠️ 执行 AC-C 组的三个环境前置（第 2 轮审查发现，缺一即假失败）

**(1) 沙箱路径必须不含空格。**
`list_dir` 的 `$1` 是**故意不加引号的 glob**，会被词分割。**本仓自身路径含空格**（`01-on progress programs`），
若 Blake 把沙箱建在仓库内（`mktemp -d -p .` 或 `./tmp-sb`），实测返回 `1\x1f01-on:` —— **看起来像实现 bug，实为环境问题**。
✅ 用裸 `mktemp -d`（落在 `/var/folders/…`，无空格）。

**(2) AC-C3 必须 `LC_ALL=C`。**
`ls -1` 的排序受 locale 影响：当前机器 `LANG=en_US.UTF-8` 下 CJK 排在 `A` **之前** → 实际输出 `2\x1f中文文件.md A.md`。
`LC_ALL=C` 下才是 `2\x1fA.md 中文文件.md`。
（AC-C1 免疫 —— 它的 `A-`/`B-`/`C-` 前缀强制了顺序；实测跨 `C`/`en_US`/`zh_CN` 三种 locale 稳定。）

**(3) `$'…'` 是 bash/zsh 的 ANSI-C quoting。** 用 `bash` 执行 AC，不要用 `sh`。

**(4) AC-B1 的正则混用了两种 `\|`。** 其中作「或」的需还原为 `|`（ERE），而 `\|\|` 是要匹配的**字面 shell `||`**，须保留为 `\|\|`。
若机械地把每个 `\|` 都还原成 `|`，grep 会报 `empty (sub)expression` 并 **exit 2**（响亮失败，非静默假绿），
但 Blake 不得把该错误记为 `0`。

⚠️ **AC-C1 与 AC-C2 必须成对执行**：C1 用 `$(…)` 比较会**吞掉尾部换行**，一个「输出正确但多一个换行」的实现能过 C1；C2（`tr -cd '\n' | wc -c` → 0）抓它。**单独任一条都不完整。**

⚠️ **AC-N3 有副作用**：执行 `precompact-session-snapshot.sh` 会写 `.tad/active/precompact/snapshot-*.md` 并触发 newest-wins 轮转（该目录已 gitignore，影响可忽略）。Blake 应预期此行为，不要误判为污染。

⚠️ **AC-B2 与 AC-C1 是本单的判别力核心** —— 它们证明修复真的生效，而非只是代码看起来对了。

⚠️ **AC-C4（原「`$1` 须加引号」）已删除 —— 它会逼出一个坏实现。**
`$1` 是**glob 模式**（调用形如 `list_dir ".tad/active/handoffs/HANDOFF-*.md"`），
`ls -1 $1` 的**不加引号是载荷性的** —— 正是它在展开 glob。
实测：改成 `ls -1 "$1"` 后，3 文件沙箱返回 **0**。
原 AC 把「故意的 glob 展开」误读为「SC2086 引号缺陷」，与 AC-C1 **互相矛盾**。
§4.1 中相应的 SC2086 表述一并撤回。

### 9.2 Expert Review Status
**待审。**

---

## 10. Important Notes

### 10.1 四条硬禁止

1. **禁止修改 `tad.sh`。** 它的三个 P0 属 Phase 2，需人裁定后才动。AC-N4 拦这个。
2. **禁止改变 `list_dir` 的输出契约。** 下游快照格式依赖 `count\x1fnames` 且绝不含换行。AC-C3 拦这个。
3. **禁止「修复」`sync-v2.8.4.sh` 而非删除它。** 它无活引用，修复是净成本。
4. **禁止改动 `.tad/sync-registry.yaml`。** 其中 2 个项目路径已不存在，但修正它属 Phase 5（恢复交付），不在本单。AC-N5 拦这个。

### 10.2 遇到以下必须停下上报
- 删 `sync-v2.8.4.sh` 后发现有活引用（与实测矛盾）
- FR-B 的断言导致正常路径也被拒绝
- `list_dir` 改后 `precompact` hook 行为异常

### 10.3 Sub-Agent 建议
- FR-B/FR-C 完成后调 `code-reviewer` 审 shell 改动，重点查引号与分词
  ⚠️ **但必须在 prompt 中排除 `list_dir` 的 `$1`** —— 它的不加引号是**载荷性的 glob 展开**。
  `shellcheck` 仍会对该行报 **SC2086** 并建议 `ls -1 "$1"`，**那是错的建议，照做会让函数返回 0**。
  实现时应加 `# shellcheck disable=SC2086` 并注明原因，或在 completion 中记录该告警为预期。
- AC-B2 的沙箱负控由独立 subagent 执行

---

## 11. Learning Content

### 11.1 一次性脚本的处置

`sync-v2.8.4.sh` 有 6 处独立缺陷（`eval` 注入、死守卫、过期 allow-list、空元素全清、参数解析静默失效、路径含空格/CJK）。

**朴素做法**：逐个修。
**为什么不对**：它无任何活引用，修复的收益为零；而它持有 14 个真实项目的绝对路径 + 破坏性操作，**保留本身就是净风险**。

**可迁移判据**：
> 一次性历史脚本若同时满足「无活引用」与「持有真实路径 + 破坏性操作」，**删除优于修复**。修复会让它看起来可用，从而增加被误用的概率。

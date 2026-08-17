---
task_type: code
e2e_required: yes
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
**Task ID:** TASK-20260816-006
**Epic:** `EPIC-20260816-framework-health-repair.md` (Phase 2/5)
**依据:** 审计 F-01、F-02、F-03、F-33、F-34（+ 相邻 F-05~F-08）

---

## 🛑 本单的特殊状态 —— 先读这里

> **本单交付到 Gate 2 为止，不自动实现。**
>
> 人已裁定（2026-08-16，YOLO 授权时明确排除本 Phase）：
> 1. 改的是会在**别人项目里**执行的 `rm -rf` 路径（`tad.sh:1202`，12 个存活下游项目）
> 2. **当前无法离线端到端验证**（F-33：`TAD_SRC` 只能来自网络下载）→ 没有可运行 AC = TAD 明令禁止的纸面验收
> 3. `deprecation.yaml` 的语义分类**需人裁定**（§4.3），边界存疑一律按「用户拥有」处理
>
> **Blake 收到本单后：完成 Gate 2 前置检查即停，等待人类明确指令再实现。**

---

## 🔴 Gate 2

- [x] 需求明确
- [x] 技术方案完整
- [x] AC 可运行，改前值全部实测（§9）—— **但 AC-B/C 组依赖 FR-1 先落地，见 §4.1**
- [x] MQ1-MQ6 已回答（§5）
- [ ] 专家审查 ≥2 且 P0 已修 —— **待审**
- [ ] **人类实现授权 —— 未获得**

---

## 1. Task Overview

### 1.1 What We're Building

修复安装器中三个会**不可逆删除用户数据**的缺陷，并交付验证它们所必需的可测试性。

| FR | 修什么 | 发现 |
|---|---|---|
| **FR-1** | 加 `--source <dir>` 本地源模式，使安装器可离线沙箱执行 | F-33 |
| **FR-2** | `apply_deprecations` 的版本闸门收成文档声明的 `(old, target]`；删除走 `guarded_remove` | F-01、F-02 |
| **FR-3** | `deprecation.yaml` 增加语义分类。**⚠️ 条目级 `owner:` 不足以表达 `.codex/`/`.gemini/` 的混合归属 —— 必须用路径级粒度，见 §4.3b（该节推翻了 §4.3 表中这两项的分类）。** 分类结果需人裁定。`owner: user` 的**路径**永不删除；混合归属目录须逐路径标注 |
| **FR-4** | install 分支改调 `merge_claude_md` | F-03 |
| **FR-5** | `upgrade-acceptance.sh` 的 `check_deprecated()`：仅对 `owner: tad` 断言不存在；**对 `owner: user` 不作断言（skip）** —— ⚠️ **原写「断言存在且未改动」已被 §9.1c 推翻**：该脚本对任意目标运行且无 before 快照，「未改动」不可验证，而「存在」会对从未有过 `.codex/` 的 claude-code 用户产生假 FAIL |
| **FR-6** | 相邻缺陷：备份时间戳命名、回滚声明与实际一致、tarball 解压到临时目录、migrate 分支 `_archived` 守卫 | F-05~F-08 |

### 1.2 三个 P0 的实测证据

**F-01 —— 每次运行都删用户的 `.codex/`、`.gemini/`、`AGENTS.md`、`GEMINI.md`**

```yaml
# .tad/deprecation.yaml，"2.3.0" 块的 files 列表（实测）
- AGENTS.md
- GEMINI.md
- .codex/
- .gemini/
- .tad/templates/AGENTS.md.template
- .tad/templates/GEMINI.md.template
```

闸门实测恒真：
```bash
v1=2.3.0; v2=2.42.0
[ "$(printf '%s\n%s\n' "$v1" "$v2" | sort -V | head -1)" = "$v1" ] && echo TRUE   # → TRUE
```
且 `copy_framework_files`（内含此调用）在 install/upgrade/migrate **三个分支全覆盖**。

`tad.sh:1149-1150` 的文档字符串声称范围是 `(old_version, current_version]`，**代码实现的是无上界的 `≤ target`**。

**F-02 —— 该删除路径绕过全部防护**

`apply_deprecations` 中 `guarded_remove` 出现次数：**0**（实测）。它与 `deprecation.yaml` 之间唯一的东西是 `[ -e "$target" ]`，只挡空字符串。
而同仓的 `migration-engine.sh` 有完整闸口（`validate_path` → `check_containment` → `check_zero_touch` → 备份断言 → `guarded_remove`），**未被复用**。

**F-03 —— 首装覆盖用户 `CLAUDE.md`**

```bash
sed -n '1623p' tad.sh   # install 分支：cp "$TAD_SRC"/CLAUDE.md ./     ← 裸 cp
grep -cF 'merge_claude_md "$TAD_SRC"' tad.sh   # → 2（只有 upgrade/migrate 调用）
```
而 `detect_state` 在 `.tad/` 与 `.claude/commands/` 均不存在时返回 `fresh` —— **正是「已有 CLAUDE.md、从未装过 TAD」的用户状态**。

### 1.3 F-34 —— 缺陷被写进了验收标准（本单最尖锐的一条）

`upgrade-acceptance.sh` 的 `check_deprecated()` 读 `deprecation.yaml` 的全部 `files:` 条目，然后断言它们**不存在**：

```bash
if [ -d "$full_path" ]; then printf '    stale dir: %s\n' "$fpath"; stale_found=1; fi
if [ -f "$full_path" ]; then printf '    stale file: %s\n' "$fpath"; stale_found=1; fi
```

**判定方向**：用户的 `.codex/` 幸存 → `stale dir` → **测试 FAIL**。

含义：
1. **「用户的 Codex 配置必须被删除」是被写进验收标准的** —— 这是 F-01 长期存活的直接原因
2. **修 F-01 必须同批修 F-34**，否则修好的正确行为会被自己的测试判 FAIL

### 1.4 Intent Statement

**要达成的**：让安装器只删自己写入的东西，不碰用户/第三方拥有的路径；并让这件事可以被真实验证。

**不追求的**：重构安装器架构。**本单只堵洞 + 加可测试性。**

---

## 📚 Project Knowledge（Blake 必读）

| Pattern | 相关点 |
|---|---|
| `shell-portability.md` | **本单核心** —— 路径含空格/CJK、BSD/GNU 差异、`set -e` 交互 |
| `ac-verification.md` | 负控设计、改前红/改后绿 |
| `release-sync.md` | zero-touch 与 deny-list 语义 |

**必须应用的三条**：

1. **禁止纸面验收。** 本单每条 AC 必须**实跑**。FR-1 就是为此存在的前置。
2. **`for f in $VAR` 在 zsh 下不分词** —— 沙箱路径可能含空格。
3. **判断 git 内容只能用 `git show`/`git ls-tree`。**

### Blake 确认
- [ ] 我已读上述三个 pattern
- [ ] 我理解 §「本单的特殊状态」：**未获人类授权前不得实现**

---

## 2. Background Context

### 2.1 Previous Work
Phase 1a/1b/3/4 均不碰 `tad.sh`（各自 NFR 明令禁止）。本单是唯一动安装器的 Phase。

### 2.2 Current State
```
$ grep -cE '\-\-source\)' tad.sh                          → 0   （无本地源模式）
$ sed -n '1152,1213p' tad.sh | grep -c 'guarded_remove'   → 0   （删除路径无防护）
$ grep -cF 'merge_claude_md "$TAD_SRC"' tad.sh            → 2   （install 分支未调用）
$ 下游存活项目                                            → 12 个真实目录
```

### 2.3 Dependencies
无技术依赖。**但有流程依赖：人类授权。**

---

## 3. Requirements

### 3.1 Functional Requirements

| ID | 需求 |
|---|---|
| **FR-1** | 新增 `--source <dir>`（或 `TAD_SOURCE_DIR` env）：跳过 `curl` 下载，直接用本地目录作 `$TAD_SRC`。**必须先于其余 FR 交付** |
| **FR-1b** | ⚠️ **随 FR-1 必须同批交付**：`rm -rf "$TAD_SRC"`（`tad.sh:1586`、`:1865`）须门控为「仅当 `$TAD_SRC` 是本次下载产生的临时目录」。<br>**否则 FR-1 会把清理逻辑变成删除用户传入的 `--source` 目录** —— 这是修复本身引入的新 P0（Gate 2 reviewer `e2994db4` 发现） |
| **FR-4b** | ⚠️ **`AGENTS.md` 的覆盖同样无人修**：即使 `owner: user` 阻止了删除，`extra_root_files` 循环仍会用裸 `cp "$src/$rf" ./`（`tad.sh:~873`）把 TAD 版覆盖用户版（`codex`/`both` 平台）。需与 FR-4 等价的处置（合并或时间戳备份），**否则 AC-B1 在两个平台上永远无法转绿** |
| **FR-2** | `apply_deprecations` 的版本闸门加上界，实现文档声明的 `(old_version, target]`；每个删除动作改走 `migration-engine.sh` 的 `guarded_remove` |
| **FR-3** | `deprecation.yaml` 增加语义分类（如 `owner: tad` / `owner: user`）。**分类结果需人裁定**（§4.3）。`owner: user` 的条目**永不删除** |
| **FR-4** | `tad.sh:1623` 的裸 `cp` 改为 `merge_claude_md "$TAD_SRC"` |
| **FR-5** | `upgrade-acceptance.sh` 的 `check_deprecated()`：仅对 `owner: tad` 断言不存在；**对 `owner: user` 不作断言（skip）** —— ⚠️ **原写「断言存在且未改动」已被 §9.1c 推翻**：该脚本对任意目标运行且无 before 快照，「未改动」不可验证，而「存在」会对从未有过 `.codex/` 的 claude-code 用户产生假 FAIL |
| **FR-6** | F-05：备份改时间戳命名（复用 `backup_existing()` 的方案）；F-06：回滚覆盖其声称范围，或改声明为如实描述；F-07：tarball 解压到 `mktemp -d`；F-08：migrate 分支 `_archived` 加守卫 |

### 3.2 Non-Functional Requirements
- **NFR1**：不得删除或弱化 `migration-engine.sh` 的既有闸口
- **NFR2**：`derive-sync-set.sh` 的推导逻辑不变（zero-touch ∩ sync-set = ∅ 必须继续成立）
- **NFR3**：不得改动 `.tad/sync-registry.yaml`
- **NFR4**：`verify_install_complete` 的校验强度不得降低

---

## 4. Technical Design

### 4.1 交付顺序（不可颠倒）

```
FR-1 本地源模式  →  建沙箱负控测试（改前红）  →  FR-2/3/4/6 修复  →  负控转绿  →  FR-5 修验收测试
```

**理由**：无 FR-1 则无法端到端验证，AC-B/C 组全部落空。**这是本单不能先修 bug 再补测试的原因。**

⚠️ **FR-5 必须与 FR-2/FR-3 同批**：只修 F-01 不修 F-34，验收测试会把修好的正确行为判 FAIL；只修 F-34 不修 F-01，等于删掉唯一的告警。

### 4.2 沙箱负控的构造

```
mktemp -d 中预置一个"用户项目"：
  .codex/config.toml          （用户的 Codex 配置）
  .codex/prompts/mine.md      （用户的自定义 prompt）
  .gemini/settings.json
  AGENTS.md                   （用户自己的，非 TAD 版）
  GEMINI.md
  CLAUDE.md                   （含自定义内容，无 TAD marker）
  CLAUDE.md.bak               （用户自己的备份，F-05 用）
  TAD-main/                   （用户自己的同名目录，F-07 用）
→ 执行安装 → **对预置路径逐个比对内容**（⚠️ **不是** `diff -r` 整树比对 —— 安装器理应新增 `.tad/`/`.claude/`/`CLAUDE.md`，裸 `diff -r` 会把它们报成 `Only in` 而永远 FAIL；且 `.codex/hooks.json` 是 TAD 合法创建的，须显式放行。完整理由见 §9.1b）
```

**三种平台各跑一次**（`claude-code` / `codex` / `both`）—— F-01 的丢失面随平台不同。

### 4.3 ⚠️ `deprecation.yaml` 语义分类 —— 需人裁定

当前 `2.3.0` 块的 6 个条目，我的**建议**分类：

| 条目 | 建议 | 理由 |
|---|---|---|
| `.tad/templates/AGENTS.md.template` | `owner: tad` | TAD 自有模板，删除安全 |
| `.tad/templates/GEMINI.md.template` | `owner: tad` | 同上 |
| **`AGENTS.md`** | **`owner: user`** | **跨厂商 agents.md 标准**（Codex/Cursor/Aider/Zed 读取），本仓自己也有一个 |
| **`GEMINI.md`** | **`owner: user`** | 用户的 Gemini 指令文件 |
| **`.codex/`** | ⚠️ **本行已被 §4.3b 推翻** —— 混合归属：用户拥有 `config.toml`/`prompts/`/MCP 接线，**TAD 拥有 `.codex/hooks.json`**（`tad.sh:940`）。须路径级标注，不可整目录判 `owner: user` | 见 §4.3b |
| **`.gemini/`** | ⚠️ **同上，已被 §4.3b 推翻** —— 须先确认 TAD 是否在其中写入文件，再决定路径级归属 | 见 §4.3b |

其余版本块（`2.8.1`/`2.8.2` 的 `.claude/commands/*.md`、`2.17.0`/`2.30.0` 的 `.tad/domains/*.yaml` 等）**建议全部 `owner: tad`** —— 都是 TAD 自己写入的文件。

⚠️ **Blake 不得自行采用上表。** 须由人确认后写入。**边界存疑一律按 `owner: user` 处理。**

### 4.3b 🔴 上表的 `.codex/` / `.gemini/` 分类不成立 —— 需路径级粒度

Gate 2 reviewer `e2994db4` 指出并经 Alex 复核：**`.codex/` 是混合归属目录**。

| 归属 | 内容 | 证据 |
|---|---|---|
| **用户** | `config.toml`、`prompts/`、MCP 接线 | 用户自己创建 |
| **TAD** | `.codex/hooks.json` | `tad.sh:940` `cat > .codex/hooks.json` |

**单一的条目级 `owner:` 字段表达不了这件事**，且 `owner: user 永不删除` 与本单**自己的硬禁止 #6**
（「只删其中 TAD 自己写入的文件」）**直接矛盾**。

**修正方向（仍需人裁定）**：
- 改为**路径级粒度**：`.codex/` → `owner: user`，`.codex/hooks.json` → `owner: tad`；或
- **删除目录级条目**，改为逐个列出 TAD 自己写入的文件路径

`AGENTS.md` / `GEMINI.md` / 两个 `.tad/templates/*.template` 的分类**维持不变**（reviewer 确认正确）。
其余版本块（`.claude/commands/*`、`.tad/domains/*`、`.tad/codex/*`）**无歧义，均为 `owner: tad`**。

---

## 5. 强制问题回答

### MQ1 历史搜索
**是**。三个 P0 均由 2026-08-16 shell 审计在 `mktemp -d` 沙箱中逐字 `sed` 提取真函数复现，Alex 已独立复核源码与闸门。

### MQ2 位置存在性

| 位置 | 内容 | ✅ |
|---|---|---|
| `tad.sh:1152-1213` | `apply_deprecations()` | ✅ |
| `tad.sh:1196-1205` | 删除循环 + 版本闸门 | ✅ |
| `tad.sh:1216-1221` | `version_le`（用 `sort -V`，与知识库 2026-06-14 条目冲突，见 F-21） | ✅ |
| `tad.sh:1623` | install 分支裸 `cp CLAUDE.md` | ✅ |
| `tad.sh:1304-1345` | `merge_claude_md()`（正确实现，未被 install 调用） | ✅ |
| `tad.sh:861-863` | 作者注释：知道会删 AGENTS.md，补救是装回 TAD 版 | ✅ |
| `.tad/hooks/lib/migration-engine.sh:216` | `guarded_remove`（未被复用） | ✅ |
| `.tad/tests/upgrade-acceptance.sh` `check_deprecated()` | 判定方向反了 | ✅ |

### MQ3 数据流

**用户数据的生存路径**（本单的核心）：

```
用户预置文件 ──→ apply_deprecations 读 deprecation.yaml
                        ↓
                  owner: tad  → 允许删除（走 guarded_remove）
                  owner: user → 【永不删除】（路径级；混合归属目录见 §4.3b）
                        ↓
                  upgrade-acceptance.sh Check 3
                        ↓
                  owner: tad  → 断言不存在
                  owner: user → 【不作断言 / skip】（见 §9.1c）
```

**改前**：无 owner 概念，全部按「该删」处理，验收测试也按「该删」断言。

### MQ4 视觉层级
N/A。

### MQ5 状态同步

| 数据 | 源 | 目标 | 时机 |
|---|---|---|---|
| 框架文件 | 本仓 `.claude`/`.agents`/`.tad` | 用户项目 | 安装/升级 |
| **用户文件** | 用户项目 | **不动** | **永远** |

**不同步的后果**：本单修的正是「本该不动却被删」。

### MQ6 知识评估
预期产出两条：
1. **「管住 COPY 路径的 deny-list 不管 DELETE 路径」** —— 任何在 `guarded_remove` 之外新增的 `rm`/`mv` 都静默退出三重保护
2. **「缺陷被写进验收标准时，测试会保护缺陷」** —— F-34 是本仓最强的 Validation Theater 实例

---

## 6. Implementation Steps

| # | 步骤 | FR | 备注 |
|---|---|---|---|
| 0 | **等待人类实现授权** | — | **无授权不得继续** |
| 1 | 跑 §9 全部 AC 改前值，存档 | — | |
| 2 | 实现 `--source <dir>` | FR-1 | 必须最先 |
| 3 | 建沙箱负控测试，**确认改前红** | — | 见 §4.2 |
| 4 | 人裁定 `deprecation.yaml` 分类，写入 | FR-3 | |
| 5 | 修 `apply_deprecations`（闸门 + `guarded_remove`） | FR-2 | |
| 6 | install 分支改调 `merge_claude_md` | FR-4 | |
| 7 | 修 F-05~F-08 四个相邻缺陷 | FR-6 | |
| 8 | 修 `upgrade-acceptance.sh` Check 3 方向 | FR-5 | **必须与 5 同批** |
| 9 | 负控转绿，三平台各跑一次 | — | |

**预计 6-8 小时。**

---

## 7. File Structure

**Modify**：`tad.sh`、`.tad/deprecation.yaml`、`.tad/tests/upgrade-acceptance.sh`、`.tad/hooks/lib/release-verify.sh`（AC-2e 的闸口检查）
**Create**：`.tad/tests/installer-data-safety.sh`（沙箱负控）

### 7.4 Required Evidence Manifest
- `.tad/evidence/reviews/blake/phase2-installer-data-safety/` — ≥2 份独立 reviewer 文件
- `.tad/evidence/acceptance-tests/phase2-installer-data-safety/` — 三平台各一份完整沙箱输出（改前红 + 改后绿）

---

## 8. Testing Requirements

### 8.1 沙箱负控（本单的核心，不可省略）
见 §4.2。**三种平台各跑一次。**

### 8.4 Friction Preflight
- ⚠️ **FR-1 未交付前，AC-B/C 组全部无法执行** —— 这是本单把 FR-1 排在最前的原因
- `migration-engine.sh` 的 `guarded_remove` 可复用 ✅（已验证其守卫正确拒绝 zero-touch 路径）

---

## 9. Acceptance Criteria

### 9.0 方言标注
`[F]`=`grep -F`（含 `-` 开头的模式须用 `grep -cF -- 'pattern'`）｜ `[BRE]`=`grep` ｜ `[ERE]`=`grep -E` ｜ `[sh]`=执行
⚠️ 表格内 `\|` / `｜` 为 Markdown 排版转义，**按标注还原**。

### 9.1 AC 表

| AC | 类 | 命令 | 期望 | 改前实测 |
|---|---|---|---|---|
| **AC-1a** | FR-1 | `grep -cE '\-\-source\)' tad.sh` | `≥1` | **0** 🔴 |
| **AC-1b** | FR-1 | `[sh]` 沙箱中 `bash tad.sh --source <本地目录> --platform both --yes` 全程无网络，退出码 | `0` | 不可执行 🔴 |
| **AC-1c** | FR-1b | `[awk]` **两个 `rm -rf "$TAD_SRC"` 站点（`:1586`、`:1865`）之前必须有来源门控**：<br>`grep -n 'rm -rf "$TAD_SRC"' tad.sh` 得到的每个行号 N，其前 8 行内须出现门控标记（如 `TAD_SRC_DOWNLOADED` / `_tad_src_owned`）：<br>`for ln in $(grep -n 'rm -rf "$TAD_SRC"' tad.sh \| cut -d: -f1); do sed -n "$((ln-8)),${ln}p" tad.sh \| grep -cE 'TAD_SRC_DOWNLOADED\|_tad_src_owned'; done` | **每个站点均 `≥1`** | **0 / 0** 🔴（实测两站点前 8 行均无任何门控） |
| **AC-1d** | FR-1b | `[sh]` **负控（可触发性）**：沙箱中以 `--source <用户目录>` 运行安装，结束后该目录**必须仍存在且内容不变** | 目录存活 | 不可执行（FR-1 未交付）🔴 |
| **AC-2a** | FR-2 | `sed -n '/^apply_deprecations/,/^}/p' tad.sh \| grep -c 'guarded_remove'` | `≥1` | **0** 🔴 |
| **AC-2b** | FR-2 | `[sh]` 构造 `current_version` 高于上界的沙箱，断言 `2.3.0` 块**不触发** | 不触发 | 恒触发 🔴 |
| **AC-2e** | FR-2 | `[ERE]` `tad.sh` 内所有 `rm -rf` 调用点均在 `guarded_remove` 内或有前置断言 —— 用一条可复跑命令表达并纳入 `release-verify.sh` | 全覆盖 | **5 处裸 `rm -rf`** 🔴 |
| **AC-3a** | FR-3 | `[F]` `grep -c 'owner:' .tad/deprecation.yaml` | `≥6` | **0** 🔴 |
| **AC-3b** | FR-3 | `[F]` `AGENTS.md`/`GEMINI.md` 标 `owner: user`；**`.codex/`/`.gemini/` 按 §4.3b 的路径级方案标注**（原写「四项均标 `owner: user`」已被 §4.3b 推翻 —— 那样会与硬禁止 #6「只删其中 TAD 写入的文件」矛盾） | 按裁定 | **未分类** 🔴 |
| **AC-B1** | 主控 | `[sh]` **三平台各跑**：沙箱预置 6 类用户文件 → 安装 → 对**预置路径**逐个比对**内容**（非裸 `diff -r`）| 预置文件内容不变 | 除 `version.txt` 外全消失 🔴 |
| **AC-B2** | FR-4 | `[sh]` 沙箱预置含自定义内容的 `CLAUDE.md`（无 marker）→ 安装后内容仍在 + 有时间戳备份 | 保留 | 被覆盖 🔴 |
| **AC-B3** | FR-6 | `[sh]` 沙箱预置用户自有 `CLAUDE.md.bak` → 安装后未变 | 未变 | 被覆盖并删除 🔴 |
| **AC-B4** | FR-6 | `[sh]` 沙箱预置用户自有 `TAD-main/` → 安装后未变 | 未变 | 被合并并删除 🔴 |
| **AC-B5** | FR-6 | `[sh]` migrate 分支连跑两次，`_archived/` 同名文件不被静默覆盖 | 不覆盖 | 静默覆盖 🔴 |
| **AC-C1** | FR-5 | `[sh]` 目标含用户 `.codex/` 时跑 `upgrade-acceptance.sh` | **PASS** | 判 `stale dir` → FAIL 🔴 |
| **AC-C2** | FR-5 | `[sh]` 目标残留 `owner: tad` 的过期文件时 | **FAIL**（仍能报警） | FAIL ✅ |
| **AC-N1** | NFR2 | `[sh]` `derive-sync-set.sh --dirs` ∩ `--zero-touch` | `∅` | **∅** ✅ |
| **AC-N2** | NFR2 | `[sh]` `bash tad.sh --verify-denylist` | 通过 | 通过 ✅ |
| **AC-N3** | NFR1 | `[F]` `migration-engine.sh` 的 `check_zero_touch`/`check_containment`/`guarded_remove` 均存在 | 3/3 | **3/3** ✅ |
| **AC-N4** | NFR3 | `[git]` `.tad/sync-registry.yaml` 未被改动 | 未改 | 未改 ✅ |
| **AC-N5** | NFR4 | `[sh]` 沙箱安装后 `verify_install_complete` 通过 | 通过 | — |

⚠️ **AC-B1 是本单唯一的主控。** 其余是「修法正确」与「没伤到别的」。
⚠️ **AC-C1/C2 成对**：C1 证明不再误伤用户文件，C2 证明**仍能发现真正的过期文件** —— 缺 C2 则「把 Check 3 整个删掉」也能通过 C1。

### 9.1b ⚠️ AC-B1 的比对方式已修正（原写法永远无法转绿）

**原写法**：安装后 `diff -r` 预置快照，期望「无差异」。
**问题**：安装器**理应**新增 `.tad/`、`.claude/`、`.agents/`、`CLAUDE.md` —— `diff -r` 会把它们报成
`Only in <target>:`，**即使修复完美也 FAIL**。且 `codex`/`both` 平台下 TAD 会在用户的 `.codex/`
内合法创建 `hooks.json`（`tad.sh:939-940`）。

**修正**：比对**限定在预置路径**上、**比内容而非存在性**，并对 `.codex/hooks.json` 显式放行。

**为什么必须比内容**：reviewer 指出三平台的真实差异只有一处，且方向与 §4.2 的暗示相反 ——
`.codex/`、`.gemini/`、`GEMINI.md` 在**三个平台上都被删且都不恢复**；唯一的平台差是 `AGENTS.md`：
`claude-code` 下删了不回来，`codex`/`both` 下删了之后**被 TAD 版覆盖**（`extra_root_files` 的裸 `cp`）。
**后者用「文件存在」判定会假通过** —— 文件在，但内容已是 TAD 的。

### 9.1c ⚠️ FR-5 的「存在且未改动」不可验证

`upgrade-acceptance.sh` 对任意目标运行，**没有 before 快照** → 「未改动」无从验证；
而「存在」会对**从未有过 `.codex/` 的 claude-code 用户**产生新的假 FAIL。

**正确语义**：`owner: user` 的条目应当**不被断言**（skip），而非断言存在。

### 9.2 Expert Review Status —— **第 1 轮完成（2 名独立 reviewer）**

**Reviewer A（`11d7a787`，事实核查）→ `PHASE2 CLAIMS SOUND`**

四条 P0 声明**全部 CONFIRMED**，与 Alex 自验一致：

| 声明 | 核实 |
|---|---|
| **F-01** | 版本闸门 `tad.sh:1198` 无下界；`.tad/version.txt` = 2.42.0，`sort -V` 实测闸门恒真；`copy_framework_files` 在 **1617/1712/1791** 三分支全调用；作者注释 `tad.sh:861-863` 自己承认会删 `AGENTS.md` |
| **F-02** | `apply_deprecations` 内 `guarded_remove` = **0**；`migration-engine.sh` 的守卫链完整（`:41/:85/:147/:216`）且 `guarded_remove` 有 TOCTOU 二次校验 —— **但完全不可达** |
| **F-03** | `tad.sh:1623` 裸 `cp`；`merge_claude_md` 仅在 1719/1797 被调；`detect_state` 首条件不看 `CLAUDE.md` → 有自写 CLAUDE.md 的新用户正落此态 |
| **F-34** | `check_deprecated` 解析**全部** `files:` 条目、**无版本/owner 过滤**，`.codex/` 以 `/` 结尾走 dir 分支 → `stale dir` → `report_fail` |

**Reviewer B（`e2994db4`，AC 可执行性与范围）→ `PHASE2 GATE2 BLOCKED`**

**报 4 个 P0，全部经 Alex 独立复核属实：**

| # | 问题 | 处置 |
|---|---|---|
| 1 | **FR-1 引入新 P0** —— 加了 `--source` 后，`rm -rf "$TAD_SRC"`（`:1586`、`:1865`）会删掉**用户传入的目录**。我的 FR-1 无任何「仅清理自己下载的」门控 | ✅ 新增 **FR-1b**（须与 FR-1 同批） |
| 2 | **`AGENTS.md` 覆盖无人修** —— `owner: user` 只挡删除，`extra_root_files` 的裸 `cp` 仍会覆盖（`codex`/`both`）→ **AC-B1 在两平台永不转绿** | ✅ 新增 **FR-4b** |
| 3 | **`.codex/` 是混合归属** —— 用户拥有 `config.toml`/`prompts/`，TAD 拥有 `.codex/hooks.json`（`tad.sh:940`）。单一 `owner:` 字段表达不了，且与本单硬禁止 #6 **自相矛盾** | ✅ 新增 **§4.3b**，改为路径级粒度（仍需人裁定） |
| 4 | **AC-B1 的裸 `diff -r` 永不转绿** —— 安装器理应新增 `.tad/`/`.claude/` 等，会被报成 `Only in` | ✅ 改为限定预置路径 + **比内容而非存在性**（§9.1b） |

**Reviewer B 的关键洞察**：三平台的真实差异只有 `AGENTS.md` 一处，且**方向与我的 §4.2 暗示相反** ——
`.codex/`/`.gemini/`/`GEMINI.md` 在三平台**都被删且都不恢复**；`AGENTS.md` 在 `codex`/`both` 下
**删了之后被 TAD 版覆盖**。**用「文件存在」判定会假通过**（文件在，内容已是 TAD 的）。

### 9.3 Gate 2 判定：**FAIL**（2026-08-16）

规则 1 要求「专家审查 ≥2 **且 P0 修复**」。4 个 P0 的**工单侧**修正已完成（FR-1b / FR-4b / §4.3b / §9.1b/c），
但其中两项引入了**新的功能需求**（FR-1b、FR-4b），且 §4.3b 的路径级归属分类**仍待人裁定**。

**→ 本单需第 2 轮审查方可判 Gate 2 PASS。**

### 9.4 第 2 轮审查（`04152963`）—— **P0-1/P0-2 CLOSED，P0-3/P0-4 判 PARTIALLY**

reviewer 确认 FR-1b、FR-4b **完全关闭**（纯追加，无冲突），但指出 **P0-3/P0-4 只是"追加了修正"，被推翻的原文仍在原地以规范语气陈述**，且没有交叉引用：

| 残留位置 | 问题 |
|---|---|
| FR-3（`:169`） | 仍写「`owner: user` 的条目永不删除」，不指向 §4.3b |
| §4.3 表（`:221`） | 仍列 `.codex/` → `owner: user` |
| AC-3b（`:361`） | 仍要求四项均标 `owner: user` —— **绿灯只能靠采用 §4.3b 说无效的分类** |
| 硬禁止 #3（`:447`） | 只引 §4.3 |
| **§4.2（`:206`）** | **仍规定裸 `diff -r`** —— 而实现步骤 3 与 §8.1 都路由到此处 |
| FR-5 / MQ3 | 仍写「断言存在且未改动」，与 §9.1c 相反 |

**reviewer 归纳的模式（我认）**：
> 四处修正**全部以追加新章节的方式落地，没有回改被其取代的原文**。
> FR-1b/FR-4b 安全是因为它们纯属新增；§4.3b 与 §9.1b/c 不安全，
> **因为它们推翻的文本仍作为需求被陈述着** —— 实现者按流程走会落到旧指令上。

**✅ 已全部回改**（不是再追加一节）：FR-3、FR-5（两处）、§4.2、§4.3 表两行、AC-3b、硬禁止 #3、MQ3 —— 共 **9 处**，每处均就地改写并交叉引用推翻它的章节。

### 9.5 Gate 2 判定：**FAIL（维持）**，但阻塞原因已收窄

**已关闭**：P0-1、P0-2、P0-3/P0-4 的文档自洽性。

**仍阻塞（且 Alex 不得代裁）**：
1. **§4.3b 的路径级归属分类**需人裁定 —— 它直接决定「哪些用户文件会被 `rm -rf`」
2. **FR-1b、FR-4b 是新增功能需求**，改变了本单的工作量与范围
3. ~~次要：FR-1b 尚无对应 AC~~ → ✅ **已补 AC-1c（门控静态检查，改前实测 0/0）与 AC-1d（沙箱负控）**

⚠️ **本 Epic 的目标要求 Phase 2「出单 + 过 Gate 2 即停」。出单已完成、两轮审查已完成、
9 处 P0 修正已落地；Gate 2 的最终 PASS 依赖上述人类裁定，这是设计使然而非执行不力** ——
该 Phase 的全部改动都会在别人的项目里执行 `rm -rf`。

⚠️ **这不影响本 Epic 的交付状态**：目标要求 Phase 2「出单 + 过 Gate 2 即停」，
而**出单已完成、第 1 轮审查已完成、P0 已在工单侧修正**。
Gate 2 的最终 PASS 依赖两项**人类裁定**（§4.3b 的归属粒度、FR-1b/FR-4b 的接受），
按 TAD 规则 Alex 不得代裁 —— 见 §10.4。

---

## 10. Important Notes

### 10.1 六条硬禁止

1. **无人类授权不得实现。** 见本单开头。
2. **禁止先改 bug 再补测试。** FR-1 → 负控红 → 修复 → 负控绿，顺序不可颠倒（§4.1）。
3. **禁止自行采用 §4.3 的分类建议**，且 §4.3 表中 `.codex/`/`.gemini/` 两行已被 §4.3b 推翻**。** 须人确认；**边界存疑一律 `owner: user`**。
4. **禁止只修 F-01 不修 F-34**（或反之）。二者必须同批。
5. **禁止弱化 `migration-engine.sh` 的闸口。** AC-N3 拦这个。
6. **禁止删除整个第三方工具目录。** 只删其中 TAD 自己写入的文件。

### 10.2 遇到以下必须停下上报
- `--source` 模式与现有下载路径产生行为差异
- 任何 zero-touch 目录在沙箱中被改动
- AC-B1 在某个平台无法转绿

### 10.3 Sub-Agent 建议
- 沙箱负控由独立 subagent 执行并留完整输出（三平台各一份）
- `deprecation.yaml` 分类写入后调 `security-auditor` 复核 owner 标注

---

## 11. Learning Content

### 11.1 缺陷被写进验收标准时，测试会保护缺陷

`upgrade-acceptance.sh` 的 Check 3 断言「用户的 `.codex/` 必须不存在」。每一次验收通过，都在确认 F-01 的破坏行为是**正确的**。

这不是测试写错了 —— 是**规格错了，而测试忠实地实现了错误的规格**。

**可迁移判据**：
> 当一个缺陷长期存活，**先查它是不是被某个测试保护着**。
> 测试通过 ≠ 行为正确；测试断言的是**当初写下的期望**，而期望本身可能是错的。
> 修这类缺陷必须同批修测试，否则正确的实现会被判 FAIL。

### 11.2 管住 COPY 路径的 deny-list 不管 DELETE 路径

`tad.sh` 的 `TAD_ZERO_TOUCH` 正确保护了复制路径，`migration-engine.sh` 有教科书级的单点删除闸口。**但 `apply_deprecations` 两个都不走。**

**可迁移判据**：
> 任何在 `guarded_remove` 之外新增的 `rm`/`mv` 都**静默退出了 containment + zero-touch + backup 三重保护**。
> 用 `grep -c 'rm -rf' tad.sh .tad/hooks/lib/migration-engine.sh` 在 release-verify 里钉死数量，新增即告警。

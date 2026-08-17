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
| **FR-3** | `deprecation.yaml` 区分「TAD 自有」与「用户/第三方拥有」两类语义 | F-01 |
| **FR-4** | install 分支改调 `merge_claude_md` | F-03 |
| **FR-5** | 修正 `upgrade-acceptance.sh` 的 Check 3 判定方向 | F-34 |
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
| **FR-2** | `apply_deprecations` 的版本闸门加上界，实现文档声明的 `(old_version, target]`；每个删除动作改走 `migration-engine.sh` 的 `guarded_remove` |
| **FR-3** | `deprecation.yaml` 增加语义分类（如 `owner: tad` / `owner: user`）。**分类结果需人裁定**（§4.3）。`owner: user` 的条目**永不删除** |
| **FR-4** | `tad.sh:1623` 的裸 `cp` 改为 `merge_claude_md "$TAD_SRC"` |
| **FR-5** | `upgrade-acceptance.sh` 的 `check_deprecated()`：仅对 `owner: tad` 断言不存在；对 `owner: user` 断言**存在且未改动**（方向相反） |
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
→ 执行安装 → diff -r 预置快照，必须无差异
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
| **`.codex/`** | **`owner: user`** | Codex CLI 的 `config.toml`、prompts、MCP 接线 |
| **`.gemini/`** | **`owner: user`** | 同上 |

其余版本块（`2.8.1`/`2.8.2` 的 `.claude/commands/*.md`、`2.17.0`/`2.30.0` 的 `.tad/domains/*.yaml` 等）**建议全部 `owner: tad`** —— 都是 TAD 自己写入的文件。

⚠️ **Blake 不得自行采用上表。** 须由人确认后写入。**边界存疑一律按 `owner: user` 处理。**

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
                  owner: user → 【永不删除】
                        ↓
                  upgrade-acceptance.sh Check 3
                        ↓
                  owner: tad  → 断言不存在
                  owner: user → 断言存在且未改动
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
| **AC-2a** | FR-2 | `sed -n '/^apply_deprecations/,/^}/p' tad.sh \| grep -c 'guarded_remove'` | `≥1` | **0** 🔴 |
| **AC-2b** | FR-2 | `[sh]` 构造 `current_version` 高于上界的沙箱，断言 `2.3.0` 块**不触发** | 不触发 | 恒触发 🔴 |
| **AC-2e** | FR-2 | `[ERE]` `tad.sh` 内所有 `rm -rf` 调用点均在 `guarded_remove` 内或有前置断言 —— 用一条可复跑命令表达并纳入 `release-verify.sh` | 全覆盖 | **5 处裸 `rm -rf`** 🔴 |
| **AC-3a** | FR-3 | `[F]` `grep -c 'owner:' .tad/deprecation.yaml` | `≥6` | **0** 🔴 |
| **AC-3b** | FR-3 | `[F]` `AGENTS.md`/`GEMINI.md`/`.codex/`/`.gemini/` 四项均标 `owner: user` | 4/4 | **0/4** 🔴 |
| **AC-B1** | 主控 | `[sh]` **三平台各跑**：沙箱预置 6 类用户文件 → 安装 → `diff -r` 预置快照 | **无差异** | 除 `version.txt` 外全消失 🔴 |
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

### 9.2 Expert Review Status
**待审。**

---

## 10. Important Notes

### 10.1 六条硬禁止

1. **无人类授权不得实现。** 见本单开头。
2. **禁止先改 bug 再补测试。** FR-1 → 负控红 → 修复 → 负控绿，顺序不可颠倒（§4.1）。
3. **禁止自行采用 §4.3 的分类建议。** 须人确认；**边界存疑一律 `owner: user`**。
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

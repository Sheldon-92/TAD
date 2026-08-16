---
# Quality Chain Metadata (Alex 必填)
task_type: code
e2e_required: no      # hook 级 fixture 足够
research_required: no # 全部事实由 Alex 2026-08-16 实测，见 §5 MQ1

git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## 止住绝对路径的源头 + 建一个「凭据硬拦、路径软报」的扫描器

**Handoff ID**: `HANDOFF-20260816-privacy-scanner-and-trace-relpath.md`
**Created**: 2026-08-16
**Alex**: Terminal 1
**Epic**: none（NEXT.md §0d + §0e）
**预计工作量**: 2-3 小时

> **为什么这两件事是一张单**：0d 止住源头（hook 别再写绝对路径），
> 0e 是持续监测（扫描器）。**扫描器正好是 0d 的验证器** —— 改完 hook 后跑扫描器，
> 新产生的 trace 不该再命中路径规则。分开做会让 0d 缺一个自然的验收手段。

---

## 🔴 Gate 2: Design Completeness (Alex必填)

| 项 | 状态 | 证据 |
|---|---|---|
| Expert review complete (min 2) | ⬚ 待填 | §9.2 |
| All P0 resolved | ⬚ 待填 | §9.2 |
| Architecture complete | ✅ | §4 |
| Components specified | ✅ | §7 |
| Functions verified | ✅ | §5 MQ2 |
| Data flow mapped | ✅ | §4.3 |

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 读 §4.4 的**自指陷阱** —— 扫描器源码本身含凭据模式串，会命中自己
- [ ] 读 §10.1 的**三条今天刚踩的坑**（判据比数据窄 ×3）
- [ ] 读 `.claude/rules/shell-portability.md`
- [ ] **绝不在脚本里硬编码 `/path/to/TAD`** —— 2026-08-15 就是这么弄死 34 个脚本的

---

## 1. Task Overview

### 1.1 What We're Building

**A（0d）**：`record_trace()` 写 `file` 字段前，把绝对路径转成仓库相对路径。改一个函数覆盖全部 7 个调用点。

**B（0e）**：新建 `.tad/hooks/lib/privacy-scan.sh` + 注册 pre-commit hook。
- **凭据模式命中 → exit 1，阻断提交**
- **个人路径命中 → 警告，仍可提交**

### 1.2 Why We're Building It

2026-08-16 打扫时发现 `spike-codex-home/auth.json` 含**真实有效的** ChatGPT OAuth 凭据
（`refresh_token` 等），随 commit `47918da7` 推送到 **PUBLIC 仓库，公开 3 天**。
用户已 `Log out all` 吊销，仓库已清理（commit `8bb6aaad`）。

**但两个洞还开着**：
1. `post-write-sync.sh` → `record_trace()` 仍在写绝对路径。历史 2770 条 trace 是
   `/path/to/TAD/...`，**那是上轮事后批量替换的结果，不是 hook 的写入方式**。
   hook 一天不改，就一天继续产新的（08-15 / 08-16 各产了几条，由本会话自己的操作触发）。
2. **没有任何自动检查**。那个凭据能被发现纯属打扫时撞上。上轮的隐私清理**扫路径、扫得很干净**，
   它只是从来没扫过凭据 —— **一类判据过了不代表另一类风险过了**。

### 1.3 Intent Statement

**要什么**：让「凭据进仓库」这件事在提交那一刻就被拦住；让绝对路径不再产生。

**不要什么**：不要一个天天误拦、最后被 `--no-verify` 习惯性绕过的闸。
所以**路径只警告不阻断** —— 路径泄漏可事后清洗，凭据泄漏不可逆。
**用户 2026-08-16 裁定：凭据硬拦、路径软报。**

**逃生口是必须的**：`principles.md` 2026-04-15 否决过机械 enforcement，
核心理由是「fail-closed 无自恢复」。所以拒绝时**必须打印明确的绕过方法**（见 §4.2）。

---

## 📚 Project Knowledge（Blake 必读）

**`patterns/shell-portability.md`**（本单直接相关的三条）：
- `grep` 在 `$()` 里、`set -e` 下，no-match 触发 ERR trap → 加 `|| true`
- **BSD grep 把模式中间的 `$` 当锚点** —— 含 `${VAR}` 字面量的模式必须 `-F` 或 `\$`
  （2026-08-16 新增条目，Alex 起草上一张单时自己踩的）
- `comm`/`sort` 处理 CJK 要 `LC_ALL=C`

**`patterns/ac-verification.md`**：
- **自指陷阱**：「验证锚点存文档、文档存锚点」是不动点，要排除自指行
  —— 本单的扫描器正是这个形状，见 §4.4
- **断言仓库当前状态的 AC 会在验收时点反转**（2026-08-16 新增）

**`principles.md` 2026-04-15（SAFETY）**：单用户 CLI 上 fail-closed 无自恢复被否决。
本单的 fail-closed 面**刻意收窄到凭据一类**，且必须有可见逃生口。

### Blake 确认
- [ ] 我理解为什么路径只警告不阻断，以及为什么拒绝信息里必须有绕过方法

---

## 2. Background Context

### 2.1 Current State（全部由 Alex 2026-08-16 实测）

| 事实 | 值 |
|---|---|
| `record_trace()` 定义 | `.tad/hooks/lib/common.sh:72` |
| 调用点 | `post-write-sync.sh` 7 处 + `trace-writer.sh`（wrapper，非第二实现） |
| `file` 字段写出 | `common.sh` 内 `jq --arg file "$file_path"` |
| `size_bytes` 来源 | 同一个 `$file_path` 喂给 `stat`（约 `common.sh:111`） |
| **消费者解析 `file` 字段的** | **0 个**（`trace-digest.sh` 不用、`assemble-bundle.sh` 零命中） |
| 历史 trace `file` 形态 | `/path/to/TAD/...` 2770 条；相对路径 3 条 |
| 现有 pre-commit hook | 无（`.git/hooks/pre-commit` 不存在，待 Blake 复核） |

**因为消费者是 0，改成相对路径不破坏任何下游，历史格式不一致也无害 —— 不需要迁移那 2770 条。**

---

## 3. Requirements

### 3.1 Functional Requirements

**A — record_trace 相对路径**
- **FR1**：`file` 字段输出仓库相对路径（如 `.tad/active/handoffs/x.md`）
- **FR2**：`size_bytes` 仍正确 → **转换必须在 `stat` 之后**
- **FR3**：仓库根用 `git rev-parse --show-toplevel` **派生**，绝不硬编码
- **FR4**：不在仓库内 / `git` 不可用 / 路径不以仓库根开头 → **保持原值**，不报错

**B — privacy-scan.sh**
- **FR5**：凭据模式命中 → exit 1 + 指出文件与行号
- **FR6**：个人路径命中 → 警告，exit 0
- **FR7**：路径规则必须覆盖**三种形态**：`/Users/<u>/`、`-Users-<u>-`、裸用户名
- **FR8**：凭据判据 = **关键词 + 后随像真值的长串**（≥40 字符），不是裸关键词（见 §4.4）
- **FR9**：pre-commit 模式只扫**暂存文件**；手动模式扫全仓
- **FR10**：拒绝时打印绕过方法

### 3.2 Non-Functional
- pre-commit 扫描在典型提交（<50 文件）下 <2 秒
- 扫描器**不得**依赖 `python`/`jq` 之外的非标准工具

---

## 4. Design

### 4.1 A：record_trace 改动落点

`common.sh` 的 `record_trace()` 内，**在 `stat` 取完 `size` 之后、`jq` 组装之前**插入：

```bash
  # 输出用仓库相对路径（size_bytes 已在上面用原始路径取得）
  if [ -n "$file_path" ]; then
    _repo_root=$(git rev-parse --show-toplevel 2>/dev/null || true)
    case "$file_path" in
      "$_repo_root"/*) [ -n "$_repo_root" ] && file_path="${file_path#"$_repo_root"/}" ;;
    esac
    unset _repo_root
  fi
```

⚠️ **顺序是承重的**：放到 `stat` 之前会让 `size_bytes` 在 cwd≠仓库根时变 0。
⚠️ `case` 的 `"$_repo_root"/*` 用引号包住变量再接 `/*`，避免路径含空格时匹配失败
（**本仓库路径就含空格** —— `01-on progress programs`）。

### 4.2 B：privacy-scan.sh 的两档输出

```
$ bash .tad/hooks/lib/privacy-scan.sh --staged

🔴 CREDENTIAL (blocking):
  .tad/evidence/x/auth.json:3   refresh_token = <214 chars>

⚠️  PERSONAL PATH (warning only):
  .tad/evidence/y/AC14.txt:1    /Users/<user>/...

BLOCKED: 1 credential match. Commit refused.
凭据一旦推送就不可撤回，必须先移除。
确认是误报？两种走法：
  1) 把该文件加进 .gitignore 或从暂存区移除（推荐）
  2) 本次跳过：git commit --no-verify
```

**逃生口必须打印出来** —— 这是 2026-04-15 那条纪律的核心（fail-closed 必须有自恢复）。

### 4.3 数据流

```
pre-commit hook
  → privacy-scan.sh --staged
      → git diff --cached --name-only --diff-filter=ACM   （只扫新增/改动，不扫删除）
      → 逐文件 grep -nE 凭据模式  → 命中累加到 CRED
      → 逐文件 grep -nE 路径模式  → 命中累加到 PATHS
  → CRED > 0 → 打印两段 + 逃生口 → exit 1
  → 否则     → 打印 PATHS 警告（若有）→ exit 0
```

### 4.4 ⚠️ 自指陷阱（本单最容易翻车的地方）

**扫描器的源码里必然写着 `refresh_token`、`sk-`、`ghp_` 这些串，所以它会命中自己。**
这张 handoff、以及 `REMOVED-spike-codex-home.md`、以及 `.gitignore` 的注释，同样含这些词。

**错误解法**：把 `.md` 全部排除 → 真泄漏藏在 `.md` 里就漏了（今天那个 `auth.json` 是 `.json`，
但 AC11.txt 里的路径泄漏就在 `.txt` 里）。

**正确解法（FR8）**：凭据判据要求**关键词后面跟着像真值的长串**：

```
"(refresh_token|access_token|id_token|client_secret)"?\s*[:=]\s*"?[A-Za-z0-9._/+-]{40,}
sk-[A-Za-z0-9]{20,}
sk-ant-[A-Za-z0-9_-]{20,}
ghp_[A-Za-z0-9]{30,}
AKIA[A-Z0-9]{16}
-----BEGIN [A-Z ]*PRIVATE KEY-----
```

这样文档里写 `refresh_token` 这个词**不会**命中，只有带真值才命中。
**Alex 已用这套模式实测**：全仓 6000+ 被跟踪文件，命中恰好 1 个（就是那个 `auth.json`），
本 handoff 与 `.gitignore` 注释均**不**命中。

**额外保险**：脚本再显式排除自身路径 `.tad/hooks/lib/privacy-scan.sh`。
⚠️ 但**不要**因为有这条保险就放宽 FR8 的长度要求 —— 两层是独立的，
排除自身只挡自己，挡不住别的文档。

---

## 5. 强制问题回答

### MQ1: 历史代码搜索 ✅

```bash
grep -rn '^record_trace()' .tad/hooks/lib/*.sh   → common.sh:72（唯一实现）
git ls-files -z | xargs -0 grep -ln 'record_trace' → trace-writer.sh 是 wrapper
grep -n '"file"' .tad/hooks/lib/trace-digest.sh  → 0（无消费者）
grep -ho '"file":"[^"]*"' traces/*.jsonl | grep -c '/path/to/TAD' → 2770
ls .git/hooks/pre-commit                          → 不存在（Blake 复核）
```

### MQ2: 函数存在性验证 ✅

| 符号 | 位置 | 验证 |
|---|---|---|
| `record_trace` | `common.sh:72` | ✅ |
| `file_path` 局部变量 | `record_trace` 第 3 行 | ✅ |
| `stat` 取 size | `common.sh` 约 111 行 | ✅ 转换须在其后 |
| `jq --arg file` | `common.sh` 约 126 行 | ✅ |
| `trace_gate_result` 等 wrapper | `trace-writer.sh:9,16,23,41` | ✅ 均转调 `record_trace` |

### MQ3: 数据流完整性 ✅ 见 §4.3
### MQ4: 视觉层级 — N/A（CLI 文本输出，两档已在 §4.2 用 🔴/⚠️ 区分）
### MQ5: 状态同步 — N/A（无持久状态）
### MQ6: 技术调研 — N/A（无选型；模式集已由 Alex 实测验证）

---

## 6. Implementation Steps

### Phase 0: 基线（必须最先）
```bash
mkdir -p /tmp/ps
git ls-files -z | xargs -0 grep -lE '<凭据模式>' 2>/dev/null > /tmp/ps/baseline-cred.txt || true
wc -l < /tmp/ps/baseline-cred.txt    # 期望 0（8bb6aaad 已清）
grep -c '"file":"/path/to/TAD' .tad/evidence/traces/*.jsonl 2>/dev/null | head -1 || true
```

### Phase 1: A — record_trace（预计 30 分钟）
1. 按 §4.1 插入转换块（注意 `stat` 之后）
2. `bash -n .tad/hooks/lib/common.sh`
3. 负控：造一次 handoff 写入 → 新 trace 的 `file` 不含 `/Users/`，且 `size_bytes` ≠ 0

### Phase 2: B — privacy-scan.sh（预计 60 分钟）
4. 写脚本，两档 + `--staged` / 全仓两模式
5. **负控先行**：造一个含假凭据的临时文件 → 必须 BLOCK；
   造一个含 `/Users/x/` 的 → 必须只 WARN 不 BLOCK
6. **自指测试**：对本 handoff、`.gitignore`、扫描器自身跑一遍 → **不得**报凭据

### Phase 3: 注册 pre-commit（预计 20 分钟）
7. 写 `.git/hooks/pre-commit`（可执行）调用扫描器 `--staged`
   ⚠️ `.git/hooks/` 不受版本控制 → **同时**把模板放 `.tad/hooks/templates/pre-commit`
   并在 `tad.sh` 安装流程或 README 说明如何启用（Blake 判断落点，写进 completion）
8. 端到端：`git add` 一个含假凭据的文件 → `git commit` 必须被拒且打印逃生口

---

## 7. File Structure

### 7.1 Files to Create
| 文件 | 用途 |
|---|---|
| `.tad/hooks/lib/privacy-scan.sh` | 扫描器主体 |
| `.tad/hooks/templates/pre-commit` | 可版本化的 hook 模板 |
| `.tad/evidence/acceptance-tests/privacy-scanner/AC-*.sh` | fixture |
| `.tad/evidence/acceptance-tests/privacy-scanner/baseline-red.txt` | 负控红证据 |

### 7.2 Files to Modify — ALLOW-LIST
| 文件 | 改动 |
|---|---|
| `.tad/hooks/lib/common.sh` | `record_trace()` 内插入相对路径转换（约 +7 行） |

**其余既存文件一律禁止修改。** 特别是：
- ❌ 不动 `post-write-sync.sh` 的 7 个调用点（改函数内一处即可覆盖）
- ❌ 不动历史 trace 文件（2770 条格式不一致无害，无消费者）
- ❌ 不动 `.gitignore`（上一单已加规则）
- ❌ 不动任何 SKILL.md / 模板
- ❌ **不动 `NEXT.md`**（Alex 在 Gate 4 后关条目）

### 7.3 Grounded Against
| 事实 | 验证命令 | 期望 |
|---|---|---|
| record_trace 唯一实现 | `grep -c '^record_trace()' .tad/hooks/lib/common.sh` | `1` |
| 无消费者解析 file | `grep -c '"file"' .tad/hooks/lib/trace-digest.sh \|\| true` | `0` |
| 仓库路径含空格 | `git rev-parse --show-toplevel \| grep -c ' '` | `1` ⚠️ |
| 当前无凭据残留 | 见 Phase 0 | `0` |

---

## 8. Testing / 8.4 Friction Preflight

| 前置 | 状态 | 缺失时 |
|---|---|---|
| bash + BSD grep（macOS） | READY | — |
| `git rev-parse` 可用 | READY | 不可用时 FR4 要求保持原值 |
| `jq`（`record_trace` 已依赖） | READY | 已有 fallback |
| `.git/hooks/` 可写 | 未验 | 不可写 → 标 BLOCKED，别跳过 Phase 3 |

**无 BLOCKED 项。** 遇到未列出的摩擦按 `tad_friction_protocol` 处理，**不得**以摩擦为由跳过 AC。

---

## 9. Acceptance Criteria

**A 组 — record_trace**
- [ ] **AC1**：新写入的 trace，`file` 字段以 `.tad/` 或 `.claude/` 开头，**不含** `/Users/`
- [ ] **AC2**：同一条 trace 的 `size_bytes` **≠ 0 且等于真实文件字节数**（证明转换在 `stat` 之后）
- [ ] **AC3**：路径含空格仍正确（本仓库根就含空格）—— 用真实仓库根验，不用构造路径
- [ ] **AC4**：在非 git 目录下调用 `record_trace` → 不报错，`file` 保持原值（FR4）
- [ ] **AC5**：`bash -n .tad/hooks/lib/common.sh` exit 0

**B 组 — 扫描器判别力**
- [ ] **AC6**（负控，**改前必须红**）：含 `"refresh_token": "<60 字符假串>"` 的临时文件 → exit 1
- [ ] **AC7**：含 `/Users/someone/x` 的临时文件 → exit **0**，但 stdout 有 ⚠️ 警告
- [ ] **AC8**：三种路径形态各造一例（`/Users/u/`、`-Users-u-`、裸用户名）→ 三例都被警告捕获
- [ ] **AC9**：**自指** —— 对本 handoff、`.gitignore`、`privacy-scan.sh` 自身扫描 → **零凭据命中**
- [ ] **AC10**：对当前全仓（`git ls-files`）扫描 → **零凭据命中**（`8bb6aaad` 已清干净）
- [ ] **AC11**：拒绝时 stdout **含 `--no-verify` 字样**（逃生口可见，FR10）

**C 组 — 端到端**
- [ ] **AC12**：`git add` 含假凭据的文件 → `git commit` 被拒（exit≠0），且该文件**未**进入历史
- [ ] **AC13**：同一文件用 `git commit --no-verify` → 成功（逃生口真的能用）
      ⚠️ 测完**必须** `git reset --hard` 回退，且假凭据文件不得留在工作区
- [ ] **AC14**：正常提交（无命中）不受影响，耗时 <2 秒

**D 组 — 范围**
- [ ] **AC15**：`git diff HEAD --stat -- .tad/hooks/lib/common.sh` → 仅该文件、约 +7 行、0 删除
- [ ] **AC16**：`git diff HEAD --name-only` 相对基线的新增，只有 §7.1/§7.2 列出的路径

## 9.1 Spec Compliance Checklist ⚠️ Gate 3 逐行执行

| # | 要求 | 验证方法 | 期望 |
|---|---|---|---|
| 1 | 转换在 stat 之后 | `awk '/^record_trace\(\)/,/^}/' .tad/hooks/lib/common.sh \| grep -n 'stat\|show-toplevel'` | `stat` 行号 < `show-toplevel` 行号 |
| 2 | 未硬编码占位符 | `grep -c '/path/to/TAD' .tad/hooks/lib/common.sh \|\| true` | `0` |
| 3 | 仓库根为派生 | `grep -c 'rev-parse --show-toplevel' .tad/hooks/lib/common.sh` | `≥1` |
| 4 | 凭据模式带长度要求 | `grep -cE '\{[0-9]+,\}' .tad/hooks/lib/privacy-scan.sh` | `≥3` |
| 5 | 逃生口可见 | `grep -cF -- '--no-verify' .tad/hooks/lib/privacy-scan.sh` | `≥1` |
| 6 | 三种路径形态都在 | `grep -cE 'Users/|-Users-' .tad/hooks/lib/privacy-scan.sh` | `≥2` |
| 7 | 语法 | `bash -n .tad/hooks/lib/common.sh && bash -n .tad/hooks/lib/privacy-scan.sh; echo $?` | `0` |
| 8 | 改动范围 | `git diff HEAD --stat -- .tad/hooks/lib/common.sh` | 1 file，≈+7，0 deletions |
| 9 | 自指零命中 | `bash .tad/hooks/lib/privacy-scan.sh --file .tad/active/handoffs/HANDOFF-20260816-privacy-scanner-and-trace-relpath.md; echo $?` | `0` |
| 10 | 负控红证据 | `cat .tad/evidence/acceptance-tests/privacy-scanner/baseline-red.txt` | 非空，显示改前 AC6 红 |

## 9.2 Expert Review Status

### Experts Selected
- `code-reviewer`（必选）
- `security-auditor`（本单是安全控制本身，属 SAFETY 面）

### Audit Trail
| Reviewer | Issue | Resolution Section | Status |
|---|---|---|---|
| ⬚ 待 Gate 2 填写 | | | |

---

## 10. Important Notes

### 10.1 ⚠️ 今天刚踩的三个坑，本单极易重演

**同一个形状：判据比数据窄，而且每次都是「返回的数比预期小」才暴露。**

1. `grep -c 'WARNINGS="${WARNINGS}"'` 返回 **0**，真值 15
   —— **BSD grep 把模式中间的 `$` 当锚点**。本单模式串里有大量 `$`，**用 `-F` 或 `\$`**。
2. 隐私规则只匹配 `/Users/<u>/`，漏了 `-Users-<u>-`（4 文件）和裸用户名（18 文件）
   —— **所以 FR7 明确要求三种形态**。
3. notebook 归档正则要求行尾结束，漏了带**行内注释**那条（期望 9 只改了 8）
   —— **写正则时先问：这个字段允许尾随内容吗？**

**外加**：`du -sh` 把 4185 字节的 `auth.json` 显示成 `0B`（块舍入），差点被判空文件跳过。
**问文件有没有内容用 `wc -c`。**

**规矩：任何返回 0 / 返回「没有」的检查，先换一种方法复验再采信。**

### 10.2 Known Constraints（刻意不做）

- **不重写 git 历史**清那个已吊销的 blob（另议，需人裁定）
- **不迁移 2770 条历史 trace** 的路径格式（无消费者，不一致无害）
- **不拦个人路径**（用户裁定：路径可事后清洗，凭据不可逆）
- **不扫 `.git/` 内部对象**（pre-commit 只看暂存区；历史扫描是另一件事）
- `.git/hooks/pre-commit` 不受版本控制 → 换机器/重新 clone 需重新启用，
  故 §7.1 要求同时产出可版本化模板

### 10.3 Sub-Agent 建议
| Sub-Agent | 建议 | 时机 |
|---|---|---|
| `test-runner` | 必须 | Phase 2/3 fixture |
| `code-reviewer` | 必须（Layer 2） | 实现完成后 |
| `security-auditor` | 建议 | 扫描器模式集完成后（判别力评估） |

---

## 11. Learning Content

### 11.1 为什么凭据硬拦、路径软报

两类泄漏的**可逆性**不同，所以闸的硬度应该不同：

- **凭据**：一旦推送即不可撤回（爬虫秒级抓取），事后只能吊销 —— 今天就是这么过来的。
  硬拦的代价（偶尔误拦 + 一次 `--no-verify`）远小于一次泄漏。
- **个人路径**：事后批量替换即可清除，危害是长期的信息暴露而非即时接管。
  硬拦它会天天误报（`evidence/` 里大量 `ls -l` 输出），最终导致整个闸被关掉。

**这就是「窄而硬 > 宽而软」**：把 fail-closed 的面收窄到真正不可逆的那一类，
它才能长期活下来。`principles.md` 2026-04-15 否决的是**宽而硬**（fail-closed 无自恢复），
不是所有机械 enforcement —— 差别在**误报率**和**有没有逃生口**。

### 11.2 上一轮为什么没发现

上轮的隐私清理**本身没做错**：它扫路径、扫得干净，那个目录当时 0 命中。
**它只是从来没扫过凭据。** 一套判据通过，不代表另一类风险通过。
这也是为什么本单的扫描器必须**同时**覆盖两类 —— 而不是再加一个只扫凭据的脚本。

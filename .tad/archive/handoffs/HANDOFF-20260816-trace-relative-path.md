---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: 让 trace 写仓库相对路径（止住绝对路径的源头）

**Handoff ID**: `HANDOFF-20260816-trace-relative-path.md` **(rev2)**
**Created**: 2026-08-16 ｜ **rev2**: 整合 Gate 2 的 8 个 P0 ｜ **Alex**: Terminal 1 ｜ NEXT.md §0d
**规模**: 1 个文件 **+8 行** ｜ **预计**: 60-90 分钟（几乎全在 fixture）

> **rev1 → rev2**：**代码改动一个字没变**（两名专家各自在沙箱里打过补丁，确认四条边界行为全对）。
> **8 个 P0 全在验收层**，其中两条最刺眼的是「我在本文档 §3/§7 写下警告，又在 §4/§6 违反它」。
> rev2 的 §4 用 `test-runner` **实跑验证过**的 harness（未打补丁 4 FAIL/5 PASS → 打补丁 9 PASS →
> 且能抓住"转换放错位置"的变体）。

---

## 1. 要做什么 / 为什么

`record_trace()` 把 `file` 字段写成**绝对路径**，落进 `.tad/evidence/traces/*.jsonl` ——
**该目录被 git 跟踪并推送到 PUBLIC 仓库**。

77 个 trace 里 75 个显示 `/path/to/TAD/...`，**那是历次事后批量替换的结果，不是 hook 的写入方式**。
本周已因此清洗三次（08-15、08-16 两次）。**清洗不是修复。**

## 2. 改动（唯一一处）

`.tad/hooks/lib/common.sh` 的 `record_trace()`，**插在 L111 的 `stat` 之后、
L113 的 `if [ "$HAS_JQ" = true ]; then` 之前**（rev1 误写为"L114 之前"——L113 是 if 行，
"L114 之前"允许插进 jq 分支内，正是下表第 3 行禁止的）：

```bash
  # 输出用仓库相对路径（size 已在上面用原始路径取得，故必须在 stat 之后）
  local _repo_root=""
  if [ -n "$file_path" ]; then
    _repo_root=$(git rev-parse --show-toplevel 2>/dev/null || true)
  fi
  if [ -n "$_repo_root" ]; then
    case "$file_path" in "$_repo_root"/*) file_path="${file_path#"$_repo_root"/}" ;; esac
  fi
```

**三个承重点**：

| # | 要点 | 改错的后果 |
|---|---|---|
| 1 | **必须在 `stat`（L111）之后** | cwd≠仓库根时 `size_bytes` 变 0。⚠️ **cwd=仓库根时两种写法结果相同**，所以只有 AC3（cwd=子目录）能抓住 |
| 2 | **`case` 模式里变量加引号**：`"$_repo_root"/*` | 路径含 **glob 元字符**（`[` `]` `*` `?`）时，不加引号会被当通配符 → **NO MATCH**，路径保持绝对 = 本单白做 |

> **⚠️ Gate 4 更正（2026-08-16）**：rev1/rev2 把承重点 2 的机理写成「本仓库路径含空格，
> 不加引号会漏匹配」——**这是错的**。Blake 的 code-reviewer 指出，Alex 实测确认：
> `case` 的**模式部分不做单词分割**，含空格时加不加引号**都 MATCH**。引号真正的作用是让模式按**字面**处理：
> ```
> r="/a b/repo"    加引号 MATCH   不加引号 MATCH     ← 空格根本不是问题
> r="/a[b]/repo"   加引号 MATCH   不加引号 NO MATCH  ← 这才是引号在防的
> ```
> **结论没变（引号必须加），但理由变了。** 留这条更正是因为**错误的理由比没有理由更危险**：
> 下一个人看到「防空格」，在不含空格的路径上就会认为可以省掉引号，然后在含 `[` 的路径上翻车。
| 3 | **插在 L113 之前，不是插进 jq 分支** | L160 的**无-jq fallback** 用同一个 `$file_path`；插在 L112 一处覆盖两条输出路径 |

**`-n` 守卫外提**（rev2 修正）：`_repo_root` 为空时模式退化成 `/*`，**会匹配任何绝对路径**；
rev1 靠 `case` 内的 `[ -n ... ] &&` 兜底，但那让该分支返回 1。外提后语义显式，且不再有非零返回。

## 3. 边界行为（必须保持）

| 场景 | 期望 | AC |
|---|---|---|
| 不在 git 仓库内 | 保持原值，不报错 | AC7 |
| `git` 二进制不可用（与上一条是不同代码路径） | 保持原值，不报错 | AC13 |
| 路径不在任何仓库内（`/tmp/x`） | 保持原值 | AC6 |
| **符号链接分歧**（`/tmp` vs `/private/tmp`） | 保持绝对 —— **已知降级，AC14 钉死** | AC14 |
| `file_path` 为空 | 整块跳过，无 `file` 键 | AC15 |
| **跨仓库写入**（cwd=TAD，文件在下游项目） | **保持绝对，仍写入 public jsonl** —— **已知残留，见 §7.1** | AC12 |

## 4. 验收标准

### Phase 0 — 基线（自我保护，不是备注）

```bash
SCRATCH="${TAD_SCRATCH:-$(mktemp -d)}"; TR="$SCRATCH/tr"; rm -rf "$TR"; mkdir -p "$TR"
# 顺序守卫：Phase 0 必须在任何编辑之前
git diff --quiet -- .tad/hooks/lib/common.sh || { echo "PHASE0 TOO LATE — common.sh 已脏"; exit 1; }
git rev-parse HEAD > "$TR/base-sha.txt"
git status --porcelain -uall | sort > "$TR/base-status.txt"
```
⚠️ 不要用 `/tmp/tr`：world-writable 且跨会话残留，会静默复用陈旧 base-sha。

### Harness（`test-runner` 已实跑验证，照抄）

```bash
mk_sandbox() {                      # $1 = 目录名，可含空格
  local box; box=$(mktemp -d); box=$(cd "$box" && pwd -P)   # ⚠️ pwd -P 是关键
  mkdir -p "$box/$1/.tad/evidence"
  ( cd "$box/$1" && git init -q . )
  # 前置自检：不通过则整个 AC 套件无意义
  [ "$( cd "$box/$1" && git rev-parse --show-toplevel )" = "$box/$1" ] \
    || { echo "SANDBOX INVALID (symlink divergence)"; exit 1; }
  printf '%s' "$box/$1"
}
emit() {                            # $1=lib $2=cwd $3=abs_file [$4=nojq]
  rm -rf "$2/.tad/evidence/traces"
  ( cd "$2"; source "$1"; [ -n "${4:-}" ] && HAS_JQ=false; record_trace "evidence_created" "$3" )
  tail -1 "$2"/.tad/evidence/traces/*.jsonl
}
```
**为什么 `pwd -P` 是 P0**：`mktemp -d` 给 `/var/...`，`git rev-parse` 给 `/private/var/...`，
分歧使功能按设计不生效 —— **打了正确补丁 AC1（须红）与 AC2（须绿）会返回同一结果**。

### AC 清单

- [ ] **AC1（负控，改前必须红）**：`emit` 未打补丁的 lib → `file` 以 `/` 开头。存 `baseline-red.txt`
- [ ] **AC2**：改后 → `file` **不以 `/` 开头**，等于预期相对路径
- [ ] **AC3（判别力，cwd 必须是子目录）**：`mkdir -p $BOX/sub; cd $BOX/sub` 后 emit →
      `size_bytes` **等于真实字节数且 ≠ 0**。
      ⚠️ **cwd=仓库根时错序实现同样通过**，这条是唯一能抓住它的配置
- [ ] **AC4（含空格）**：沙箱目录名含空格（`a b/repo`）→ AC2/AC3 仍成立
- [ ] **AC5（无-jq 分支）**：`source` 后置 `HAS_JQ=false` → 相对路径同样生效。
      **并断言调用时 `HAS_JQ` 确实为 false**（守卫：若仍为 true 则本条 FAIL）。
      ⚠️ **不要用 `PATH=/usr/bin:/bin`** —— `/usr/bin/jq` 在本机存在，且 `HAS_JQ` 在
      **source 时** latch（`common.sh:6-9`），改 PATH 无效；PATH 剥太狠则 `mkdir`/`date` 一起失联
- [ ] **AC6**：`record_trace "x" "/tmp/outside.txt"` → 保持绝对，**stderr 为空**
- [ ] **AC7**：未 `git init` 的目录 → 保持原值，**stderr 为空**
- [ ] **AC8**：`bash -n .tad/hooks/lib/common.sh` exit 0
- [ ] **AC9（真实端到端）**：**用 Write 工具**（不是 shell！`PostToolUse` matcher 是
      `Write|Edit`，shell 建文件触发不了）创建 `.tad/evidence/acceptance-tests/trace-relative-path/probe.md`：
      (a) **先断言当天 trace 行数增长**（`after -gt before`）—— 没有这步整条是空过；
      (b) 新增行的 `.file` 无前导 `/` 且不含 `/Users/`；
      (c) 清理：删 probe.md **并**把 jsonl 截回 `head -n "$before"`
- [ ] **AC10（范围）**：`git diff $(cat "$TR/base-sha.txt") --stat -- .tad/hooks/lib/common.sh`
      → 1 file，**0 deletions**，新增行数 **+8..+12**，且**全部落在 `record_trace()` 函数体内**
- [ ] **AC11（无蔓延，白名单式）**：`git status --porcelain -uall` 相对基线的新增项 ⊆
      {§5 列出的路径、`.tad/evidence/traces/*.jsonl`、`.tad/evidence/decisions/*.jsonl`、
      COMPLETION/journal/session-state}。**不是 diff 相等断言** —— 那会因环境写入而漂移
- [ ] **AC12（跨仓库，钉死已知残留）**：cwd=repoX、文件在 repoY → **保持绝对**，exit 0。
      这条不是"应该修好"的，是**明确记录本单没堵住这个场景**（见 §7.1）
- [ ] **AC13**：`git` 二进制不可用（PATH shim 返回 127）→ 保持原值，stderr 为空
- [ ] **AC14（钉死降级）**：用 symlink 形式路径（`/tmp/...` 而非 `/private/tmp/...`）→ **保持绝对**
- [ ] **AC15**：`record_trace "t" ""` → 输出无 `file` / `size_bytes` 键，stderr 为空

> ⚠️ **不要用「exit 0」当断言**：`record_trace` 结尾是 `unset`，**恒返回 0**。
> 审查员把函数体整个换成 `echo "TOTALLY BROKEN"` 仍 `rc=0`。
> 所以 AC6/7/13/15 一律断言 **stderr 为空**，不断言退出码。

## 5. 文件

**只准改**：`.tad/hooks/lib/common.sh`（`record_trace()` 内 +8 行）
**新建**：`.tad/evidence/acceptance-tests/trace-relative-path/{AC-*.sh,harness.sh,baseline-red.txt}`
**禁止**：不动 `post-write-sync.sh` 的 7 个调用点 · 不动 `trace-writer.sh` ·
不迁移历史 77 个 trace（见 §6 的消费者核验）· 不动 `.gitignore`/`NEXT.md`/任何 SKILL

## 6. Grounded Against（rev2 已修正两条失效的验证命令）

| 事实 | 验证 | 期望 |
|---|---|---|
| `record_trace` 唯一实现 | `grep -c '^record_trace()' .tad/hooks/lib/common.sh` | `1` |
| `stat` 行 | `grep -Fn 'size=$(stat' .tad/hooks/lib/common.sh` | `111:` ⚠️ **必须 `-F`**：不加时本机返回空（`$` 被当锚点）——rev1 就是这么写的 |
| jq 输出行 | `grep -n -- '--arg file' .tad/hooks/lib/common.sh` | `126:` |
| 无-jq fallback | `grep -Fn 'safe_path=' .tad/hooks/lib/common.sh` | `160:` |
| `HAS_JQ` 在 source 时 latch | `sed -n '5,10p' .tad/hooks/lib/common.sh` | 可见 `HAS_JQ=` 赋值在函数外 |
| **无消费者解析 `file` 键** | `grep -rln --include="*.sh" --include="*.py" --include="*.js" 'evidence/traces' .tad/ .claude/ 2>/dev/null \| xargs grep -ln '\.file\b\|"file"' 2>/dev/null \|\| echo NONE` | `NONE` ⚠️ **两次修正**：rev1 引用了**不存在的** `trace-digest.sh` 且 `\|\| true` 吞掉错误（永真）；rev2 初稿不限扩展名 → 扫到 8 个 `.tad/eval/judge/bundles/*.md` **文档**（假阳性）。**必须限定可执行扩展名** |
| 仓库路径含空格 | `git rev-parse --show-toplevel \| grep -c ' '` | `1` |
| 无 `set -e` | `grep -c 'set -e' .tad/hooks/lib/common.sh \|\| true` | `0` |

## 7. 已知残留与教训

### 7.1 跨仓库写入没堵住 —— 刻意的范围决定，不是遗漏

`git rev-parse --show-toplevel` 求值依据是 **cwd**，不是 `file_path` 所在目录。
`test-runner` 实测：cwd 在 repoX、写 repoY 的文件 → trace 记下 **repoY 的绝对路径**。
**真实场景**：`*sync` 往 ~14 个下游项目写文件，那些路径全在 `/Users/<user>/` 下。

**为什么本单不修**：跨仓库时"仓库相对路径"这个概念**本身是歧义的**——
相对于 TAD 仓库还是下游仓库？两种答案在语义上都说得通，而且都不是显然正确的。
这需要一个独立的设计决定（也可能正确答案是"跨仓库写入根本不该记进本仓库的 trace"），
不是加一行 `cd $(dirname ...)` 能解决的。**AC12 把当前行为钉死，另开一条 NEXT。**

### 7.2 今天同一个形状撞了七次：判据/方法比数据窄

1. `grep -c 'WARNINGS="${WARNINGS}"'` → 0，真值 15（BSD grep 把中间 `$` 当锚点）
2. 隐私规则只认 `/Users/<u>/`，漏 `-Users-<u>-`（4 文件）与裸用户名（18 文件）
3. YAML 正则要求行尾结束，漏了带行内注释那条（期望 9 只改 8）
4. `for f in $FILES` 在 zsh 下**不分词** → sed 一个字没改，汇总却打印"全部替换"
5. `` Gitleaks `protect --staged` ``（大写+反引号）躲过锚在 `gitleaks protect` 的模式
6. **rev1 的 §6 自己犯了第 1 条**：`grep -n 'size=$(stat'` 返回空
7. **最贵的一次**：`wc -c`/`open()` **跟随符号链接**读本机文件 + `git ls-files` 只说路径被跟踪
   → 合取出"凭据泄漏"的错误结论，导致一次不必要的紧急吊销。
   **判断 git 里有什么，只能用 `git show <commit>:<path>` 与 `git ls-tree`（看 mode）。**

**规矩：任何返回 0 / 返回「没有」/ 返回「一致」的检查，先换一种方法复验再采信。**

### 7.3 AC 的四个永真陷阱（本单 8 个 P0 的来源，已进 `patterns/ac-verification.md`）

写完每条 AC 问四句：
(a) 被测对象**完全损坏**时这条会失败吗？（`record_trace` 恒返回 0 → 所有 exit-code 断言永真）
(b) 测试环境是否**恰好落在本单已知的降级分支**里？（`mktemp -d` 的 symlink 分歧）
(c) 存在哪个配置能**区分正确与错误实现**？我指定它了吗？（cwd 必须是子目录）
(d) 这条 AC 的**前置条件我实测过吗**？（`/usr/bin/jq` 存在；shell 建文件不触发 PostToolUse）

## 8. Gate 2 记录

**专家审查（rev1，2026-08-16）**：`code-reviewer` **FAIL** ｜ `test-runner` **CONDITIONAL**
合计 **8 个 P0，全部落在验收层**，已逐条整合：

| 来源 | P0 | 落点 |
|---|---|---|
| 两者 | sandbox 的 symlink 分歧使正确实现 AC 变红 | §4 harness `pwd -P` + 前置自检 |
| 两者 | `/usr/bin/jq` 存在 + `HAS_JQ` source 时 latch → AC5 空转 | AC5 改 `HAS_JQ=false` + 断言 |
| test-runner | AC3 无判别力（cwd=仓库根时错序实现也过） | AC3 强制 cwd=子目录 |
| code-reviewer | AC9 用 shell 建文件触发不了 `PostToolUse` | AC9 改用 Write 工具 + 行数增长断言 |
| 两者 | §6 两行验证命令失效（`$` 锚点 / `trace-digest.sh` 不存在） | §6 已修，见下 |
| code-reviewer | Phase 0 顺序未 pin，晚跑则 AC10/11 反转 | Phase 0 加 `git diff --quiet` 守卫 |
| code-reviewer | `exit 0` 断言永真（`record_trace` 恒返回 0） | 全改为断言 stderr 为空 |
| test-runner | 跨仓库写入仍泄漏绝对路径 | AC12 钉死 + §7.1 记录，另开 NEXT |

**Alex 自查（rev2 定稿前）**：§6 八行**逐行空跑**，抓到第 9 个问题并修正 ——
消费者核验命令不限扩展名时扫到 8 个 `.md` 文档（**假阳性**），已限定 `*.sh/*.py/*.js`，
限定后返回 `NONE`，并交叉复验了真正读 trace 的 6 个脚本均不读 `file` 键。

**rev2 未再送专家**：代码改动与 rev1 逐字相同（已过审两次并在沙箱实跑），
所有变更均为整合上述 P0 + Alex 空跑修正；§4 的 harness 是 `test-runner` 亲自验证过的实现
（未打补丁 4 FAIL/5 PASS → 打补丁 9 PASS → 能抓错序变体）。

## 9. Sub-Agent

| Agent | 时机 |
|---|---|
| `test-runner` | fixture 写完后 + 回归（**AC 层必须实跑验证，不能只文本审**） |
| `code-reviewer` | 实现完成后（Layer 2 必须） |

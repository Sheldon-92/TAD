---
# Quality Chain Metadata (Alex 必填)
task_type: code       # code | yaml | research | e2e | mixed
e2e_required: no      # hook 单元级 fixture 足够，无端到端场景
research_required: no # 调研已在 Alex review 阶段完成，结论写在 §2.1

git_tracked_dirs: []  # 单文件改动，改的文件本身已被跟踪

skip_knowledge_assessment: no  # 这一刀暴露了一个上游结构问题，KA 有实质内容要记

gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## 让 Gate 3 的 Check 8 出声（不让它拦）

**Handoff ID**: `HANDOFF-20260816-gate3-check8-audible.md` **(rev2)**
**Created**: 2026-08-16 ｜ **rev2**: 2026-08-16（整合 2 名专家的 5 个 P0 + 9 个 P1）
**Alex**: Terminal 1
**Epic**: none（独立单，NEXT.md §0）
**预计工作量**: 60-90 分钟（改动 2 行 + 7 个 fixture + 基线捕获 + 回归）

> **rev1 → rev2 的性质**：代码改动**一个字没变**（两名专家都在沙箱里打过补丁，
> 确认 +2/−0、四条路径行为全对）。**变的全是验收层**——rev1 的 §9 里有两条 AC
> 会对**正确的实现**报 FAIL，两条命令会 hang，一条清洁性检查对它要防的泄漏结构性失明。
> 这张单自己的论点就是「看起来在检查、实际没测到东西的闸比没有闸更糟」，
> rev1 的 §9 正好是那副样子。

---

## 🔴 Gate 2: Design Completeness (Alex必填)

### Gate 2 检查结果

| 项 | 状态 | 证据 |
|---|---|---|
| Expert review complete (min 2) | ✅ code-reviewer + security-auditor | §9.2 |
| All P0 resolved | ✅ 5/5 已整合 | §9.2 Audit Trail |
| Architecture complete | ✅ | §4.1 结构图（两名专家逐行核对通过） |
| Components specified | ✅ | §7.2 |
| Functions verified | ✅ | §5 MQ2 |
| Data flow mapped | ✅ | §4.3 载体链（WARNING → output_response → JSON） |

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 读完 §4.1 的**嵌套结构图**再动手 —— 这个 if 有三层，**内层第 199 行已经有一个 `else`**
- [ ] 读 `.claude/rules/shell-portability.md`（编辑 `.tad/hooks/**` 时自动加载）
- [ ] **先做 §6 Phase 0 的基线捕获**，否则一半 AC 无法判定
- [ ] **所有 fixture 必须在 `mktemp -d` 里跑**，绝不在仓库根跑 —— 见 §6.1 的 refuse-to-run 守卫
- [ ] 只改 §7.2 列出的那一个文件

---

## 1. Task Overview

### 1.1 What We're Building

给 `.tad/hooks/pre-gate-check.sh` 的 Check 8（Gate 3 判定检查）补一个 `else` 分支：
当 COMPLETION 报告存在、但**找不到任何 Gate 3 判定行**时，追加一条 WARNING，
并在文案里**点名它实际读的是哪个文件**。

**不设 `HAS_BLOCK=1`。** 这一刀只把「静默」变成「出声」，不改变任何拦截行为。

### 1.2 Why We're Building It

当前 L193 的 `if [ -n "$GATE3_RESULT" ]; then ... fi` 没有 `else`。
grep 抓不到判定行时，这个 check **零输出、零警告**——它看起来在工作，实际什么都没做。

这不是边缘情况。实测最近 20 份 COMPLETION 报告（两名专家独立重采样，数字复现）：

| Gate 3 判定标记 | 有 |
|---|---|
| 正文自评行 `**Gate 3 v2 结果**` | 1 / 20 |
| frontmatter `gate3_verdict:` | 2 / 20 |
| **两种都没有** | **18 / 20** |

这个 check 在近期工作流里 **90% 的时候是完全沉默的**。

### 1.3 Intent Statement（意图声明）

**我要的是什么**：让这个 check 在「我读不到判定」时**说出来**，而不是假装检查过了。

**我明确不要什么**：不要它拦。18/20 的报告都没判定行，设 `HAS_BLOCK=1` 会把几乎所有
近期格式的报告拦死——那不是把 fail-open 修好，是换成一个每次都误拦的 fail-closed，
正是 `principles.md` 2026-04-15「单用户 CLI 上 fail-closed 无自恢复」被否决的模式。

**用户 2026-08-16 明确裁定**：「只让它出声，不让它拦」。
接受的代价（用户已知情）：Blake 自评 FAIL 但报告没写判定行时，仍然溜得过去。

**为什么不修上游**：见 §10.2。

---

## 📚 Project Knowledge（Blake 必读）

**`patterns/shell-portability.md`** — 编辑 `.tad/hooks/**` 时自动注入。本单相关：
- 规则 2：`grep` 在 `$(...)` 里、`set -e` 下，no-match 会触发 ERR trap。
  ✅ **本文件已确认无 `set -e`、无 `trap`**，**不需要**加 `|| true`；也**不要**顺手给 L192 加。
  ⚠️ **但你写的 fixture 脚本如果自己带 `set -e`，`grep -c` 返回 0 时会 exit 1 —— 见 §6.1。**
- **新增（Alex 2026-08-16 实测，本机 BSD grep）**：模式串中间含 `$` 时**必须**用 `grep -F`
  或把 `$` 转义成 `\$`。`grep -c 'WARNINGS="${WARNINGS}"' file` 在本机返回 **0**（真值 15），
  因为 BSD grep 把中间的 `$` 当锚点处理。本单 §6/§7.3/§9.1 已全部改用 `-F`。
  **这条会假绿/假红你的验收——不是理论风险，rev2 起草时就踩了一次。**
- 规则 4：不要在 `$(...)` 调用的 helper 里 `exit`。本单不涉及。

**`patterns/gate-design.md`「claims need carriers」** — 一个 check 声称在验证某件事，
就必须有可观测载体证明它真跑了。本单正是补上缺失的载体；§9 的 AC 也按这条设计
（每条负断言都配一条 liveness 正断言）。

**`principles.md` 2026-04-15（SAFETY）** — 机械 enforcement 在单用户 CLI 上被否决那条。
直接决定「只 WARNING 不 BLOCK」。

**`principles.md` 2026-08-06 修订（deny-list 只适用于有界集合）** — 直接决定 §7.2 的写法：
写权限是无界集合，所以用**小而有界的 allow-list**（只准改一个文件），
并对「最便宜废掉这个闸」的三个文件加显式 AC 守卫。

### Blake 确认
- [ ] 我已读上述四条，理解为什么本单**刻意不设 `HAS_BLOCK`**，以及为什么 §7.2 是 allow-list

---

## 2. Background Context

### 2.1 Previous Work

`NEXT.md` §0 把这条记成「十分钟，补 else → `HAS_BLOCK=1`」。**那个修法是错的**，
Alex 2026-08-16 review 时推翻，依据：

1. NEXT.md 称它是「Gate 3 FAIL 唯一的 BLOCK 路径」——**不精确**（不是全错，见 §10.2 的
   校正）。这个文件共有 4 条 Gate 相关的 `exit 2` 路径（E1-E4，全表见 §4.4），
   主拦截是 E1「没有 COMPLETION 就 exit 2」，Alex 用真 JSON envelope 实测确认能拦。
   Check 8（E4）是第二道。**准确的说法是**：E4 是唯一一条**以 Gate 3 判定本身**为
   触发条件的 BLOCK；E1/E2/E3 都以「产物缺失」为触发条件。
2. 「扩 grep 去抓 frontmatter `gate3_verdict:`」也是错的（Alex 自己先提出、随后自我推翻）：
   那字段是 Gate 3 **跑完之后**由 post-step 写入（`gate/SKILL.md:398` 明说
   「报告写在判定存在之前，所以创建时它是空的」），而本 hook 是 **PreToolUse**，
   在 `/gate 3` **之前**跑——该字段在它看的时点按设计就是空的。
   ✅ 两名专家独立复核了这条时序论证，确认成立。
3. 因此病根在**上游产出不带标记**，不在 grep 模式写窄。补 else 设 BLOCK 会全面误拦。

### 2.2 Current State

- hook 已注册且是活的：`.claude/settings.json:59`，PreToolUse matcher `Skill`
- 管道实测通畅：gate3→exit 2、gate4→WARNING exit 0、非 gate skill→`{}` exit 0
- 文件无 `set -e`、无 `trap`
- `output_response` / `output_empty` 定义在 `.tad/hooks/lib/common.sh`（L37 / L58）；
  `output_response` **有两个实现**：jq 路径（L41）与无-jq 手工 fallback（L46-54），
  后者会用 `tr '\n' ' '` 压平换行 —— §9 AC11 两条都要测
- ⚠️ **工作区在 Blake 开工前就是脏的**：`spike-work` 子模块 + `NEXT.md` + `PROJECT_CONTEXT.md`
  （后两个是 Alex 2026-08-16 修正过期信息所致）。§9 的范围 AC 已按此设计，**不要回滚它们**。

### 2.3 Dependencies

无新依赖。改动只用 bash 内建 + 已 source 的 `common.sh`。
fixture 需要 `jq`（AC11 的一半）；无 `jq` 时该半条标 `EQUIVALENT_SUBSTITUTE` 并说明。

---

## 3. Requirements

### 3.1 Functional Requirements

- **FR1**：COMPLETION 存在 且 grep 找不到 Gate 3 判定行 → 追加一条 WARNING 到 `$WARNINGS`，
  文案中**包含实际读取的文件路径**
- **FR2**：该分支**不得**设置 `HAS_BLOCK`
- **FR3**：现有**四条** Check 8 内部路径行为逐字不变：
  - FR3a 判定行含 FAIL → BLOCK（E4）
  - FR3b 判定行含 PASS → 静默
  - FR3c 有判定行但无 PASS/FAIL → 原 WARNING（L199-200 的既有 else）
  - FR3d 无 COMPLETION → exit 2（E1，在 Check 8 之前）
- **FR4**：Check 8 之外的两条 BLOCK 路径（E2 e2e / E3 research）行为不变

### 3.2 Non-Functional Requirements

- hook 总耗时仍 <500ms（纯字符串拼接，无 I/O）
- WARNING 需说明**为什么**看不到判定 + **读的哪个文件**，否则读到的人不知道该做什么

---

## 4. Design

### 4.1 ⚠️ 嵌套结构图（改动落点 —— 动手前必读）

L191-203 是**三层嵌套**，**内层第 199 行已经有一个 `else`**。
（此图两名专家已逐行对照真实文件核验通过，行号与缩进均准确。）

```
L191  if [ -n "$COMPLETION_FILE" ]; then          ← 第1层（2 空格）：报告是否存在
L192    GATE3_RESULT=$(grep '...' ... | head -1)
L193    if [ -n "$GATE3_RESULT" ]; then           ← 第2层（4 空格）★要补 else 的是这一层★
L194      if echo "$GATE3_RESULT" | grep -q "FAIL"; then    ← 第3层（6 空格）
L195        WARNINGS=...BLOCKED...
L196        HAS_BLOCK=1
L197      elif echo "$GATE3_RESULT" | grep -q "PASS"; then
L198        : # OK
L199      else                                    ← 已存在的 else（第3层，6 空格，别碰）
L200        WARNINGS=...WARNING: 有行但无 PASS/FAIL...
L201      fi                                      ← 收第3层
L202    fi                                        ← 收第2层 ★新 else 插在这一行之前★
L203  fi                                          ← 收第1层
```

**改错层的两种典型失败**：
- 加到第 3 层 → 与已有 `else` 冲突，`bash -n` 报错，或覆盖掉 FR3c 的警告
- 加到第 1 层 → 变成「报告不存在时警告」，但那条路径 E1 早就 exit 2 了，永远走不到

### 4.2 目标形态

在 **L201 的 `fi` 之后、L202 的 `fi` 之前**插入：

```bash
    else
      WARNINGS="${WARNINGS}"$'\n'"WARNING: No Gate 3 verdict line found in ${COMPLETION_FILE} — this check could not confirm whether Gate 3 passed. Verify manually before accepting."
```

**写法约束**：
- 沿用本文件既有惯例 `WARNINGS="${WARNINGS}"$'\n'"..."`（文件中现有 **15** 处）
- **缩进 4 空格，与 L193 的 `if` 同列。**
  ⚠️ **不是**与 L199 的 `else` 同列 —— 那个是 6 空格的第 3 层。（rev1 此处写反，已改正）
- 插入 `${COMPLETION_FILE}` 是**有意的**：`ls | head -1` 按字母序选文件，
  多份报告时「the completion report」会误导，点名文件才满足 claims-need-carriers
- 文案英文，与本文件其余 WARNING 一致

### 4.3 载体链（这条 WARNING 怎么到达人眼前）

```
新 else → $WARNINGS 拼接
        → L246 `elif [ -n "$WARNINGS" ]`
        → output_response "PreToolUse" "...${WARNINGS}"
        → common.sh:37
            ├─ 有 jq (L41)  → jq 构造 JSON .hookSpecificOutput.additionalContext
            └─ 无 jq (L46-54) → 手工拼 JSON，且 `tr '\n' ' '` 压平换行
        → Claude Code 读 additionalContext
```

✅ security-auditor 已追踪 L243-251：三条终端路径都会输出 `$WARNINGS`，
**不存在非空 `$WARNINGS` 被丢弃的路径**。新分支不引入静默。
⚠️ 但**两个 `output_response` 实现都要测**（AC11）——载体是这一刀的全部意义所在。

### 4.4 全部 `exit 2` 路径清单（回归基准）

| ID | 行 | 触发条件 | 本单是否触及 | AC |
|---|---|---|---|---|
| **E1** | `:72` | Gate 3 且零个 `COMPLETION-*.md` | 否 | AC6 |
| **E2** | `:245` ← `HAS_BLOCK=1` @ `:126` | `e2e_required: yes` 且无 e2e 证据 | 否 | AC8 |
| **E3** | `:245` ← `HAS_BLOCK=1` @ `:135` | `research_required: yes` 且无研究证据 | 否 | AC8 |
| **E4** | `:245` ← `HAS_BLOCK=1` @ `:196` | 判定行含 FAIL —— **就在被改的块里** | **是** | AC3 |

---

## 5. 强制问题回答（Evidence Required）

### MQ1: 历史代码搜索 ✅

```bash
# 1. hook 是否注册（决定它是不是活的）
grep -rn "pre-gate-check" .claude/settings.json
→ L59: "command": "bash .tad/hooks/pre-gate-check.sh"                    ✅ 活的

# 2. 是否有 set -e / trap（决定 grep 要不要 || true）
grep -n 'set -e\|set -u\|trap ' .tad/hooks/pre-gate-check.sh lib/hook-envelope.sh lib/common.sh
→ 空                                                                      ✅ 不需要

# 3. 兄弟位置有没有同病
grep -c 'gate3_verdict\|Gate 3.*结果\|Gate 3.*Result' .tad/hooks/*.sh
→ post-write-sync.sh: 4 处；pre-gate-check.sh: 1 处
→ post-write-sync.sh 是 PostToolUse、读写入后的终态，时点不同、不是同病。本单不动。

# 4. 真实命中率（决定 BLOCK 还是 WARNING）
最近 20 份 COMPLETION：自评行 1/20、frontmatter 2/20、两者皆无 18/20
```

**决策**：不复用、不扩 grep、只补 else 且不 BLOCK。理由见 §1.3 + §2.1。

### MQ2: 函数存在性验证 ✅

| 符号 | 位置 | 验证 |
|---|---|---|
| `WARNINGS` | `pre-gate-check.sh:80` 初始化 `""` | ✅ |
| `HAS_BLOCK` | `:81` 初始化 `0`；`=1` 共 **3** 处（`:126` `:135` `:196`） | ✅ 本单不触碰 |
| `GATE3_RESULT` | `:192` | ✅ |
| `COMPLETION_FILE` | `:84`（`ls ... \| head -1`，字母序） | ✅ 新文案要插值它 |
| `output_response` | `lib/common.sh:37`（两个实现分支） | ✅ AC11 覆盖 |
| `safe_count` | `lib/common.sh:191` | ✅ E1 依赖它，AC13 守卫 |

### MQ3: 数据流完整性 ✅
见 §4.3 载体链。唯一"数据流"是 `$WARNINGS` → `output_response` → JSON `additionalContext`，
两个实现分支都由 AC11 覆盖。

### MQ4: 视觉层级 — N/A（无 UI）

### MQ5: 状态同步 — N/A
`$WARNINGS` 是单进程内局部变量，无多处存储。

### MQ6: 技术调研 — N/A（无技术选型）

---

## 6. Implementation Steps

### Phase 0: 基线捕获（预计 10 分钟）⚠️ 必须最先做

一半 AC 依赖「改前值」。**不先捕获，那些 AC 无法判定。**

```bash
mkdir -p /tmp/g3c8
# B1 改动前的文件清单（用 -uall 展开未跟踪目录 —— 见下方警告）
git status --porcelain -uall > /tmp/g3c8/baseline-status.txt
# B2 改动前的 diff 文件名集合
git diff HEAD --name-only          > /tmp/g3c8/baseline-diff-names.txt
# B3 改动前的 handoffs 目录内容（fixture 泄漏检测的真基准）
ls -1 .tad/active/handoffs/        > /tmp/g3c8/baseline-handoffs.txt
# B4 改动前的 HAS_BLOCK 计数（期望 3）
grep -c 'HAS_BLOCK=1' .tad/hooks/pre-gate-check.sh > /tmp/g3c8/baseline-hasblock.txt || true
# B5 改动前的 WARNINGS 拼接行数（期望 15）
# ⚠️ 必须用 -F（固定串）。BSD grep 会把模式中间的 `$` 当锚点处理，
#    不带 -F 的 `grep -c 'WARNINGS="${WARNINGS}"'` 在本机返回 0 而非 15（Alex 实测）。
grep -cF 'WARNINGS="${WARNINGS}"' .tad/hooks/pre-gate-check.sh > /tmp/g3c8/baseline-warnlines.txt || true
# B6 hook 注册串计数（期望 1）
grep -c 'pre-gate-check.sh' .claude/settings.json > /tmp/g3c8/baseline-registration.txt || true
```

⚠️ **为什么必须 `-uall`**：`.tad/active/handoffs/` 是**未跟踪目录**，
不带 `-uall` 时 git 把整个目录折叠成 `?? .tad/active/handoffs/` 一行——
**往里泄漏一个假 COMPLETION，输出字节相同，检测不出来。**

⚠️ **`grep -c` 匹配 0 次时退出码为 1** —— 上面每条都带 `|| true`。
你自己的 fixture 脚本如果用 `set -e`，同样要注意。

### 6.1 Fixture 硬性要求（所有 AC 脚本共用）

**每个 fixture 必须**：

1. `#!/bin/bash` 开头，**绝不用 `echo` 输出 JSON** ——
   用户的 shell 是 zsh，其内建 `echo` 会把 JSON 里字面的 `\n` 展开成真换行、破坏 JSON。
   一律用 `printf '%s'`。
2. 在 `mktemp -d` 里构造最小 `.tad/` 后 `cd` 进去，用**绝对路径**调 hook：
   ```bash
   REPO="$(git rev-parse --show-toplevel)"
   D="$(mktemp -d)"; trap 'rm -rf "$D"' EXIT
   mkdir -p "$D/.tad/active/handoffs"
   ( cd "$D" && printf '%s' '{"tool_name":"Skill","tool_input":{"skill":"gate","args":"3"}}' \
       | bash "$REPO/.tad/hooks/pre-gate-check.sh" )
   ```
   hook 的 `SCRIPT_DIR` 由 `$0` 解析，绝对路径调用时仍能 source 到真 `lib/`；
   而它检查的所有相对路径都落在临时目录里。（security-auditor 已验证此法可行。）
3. **带 refuse-to-run 守卫**，双保险：
   ```bash
   case "$PWD" in
     "$REPO"|"$REPO"/*) printf 'REFUSING: fixture must never run inside the repo\n' >&2; exit 1 ;;
   esac
   ```
4. **断言一律用 substring containment，不用完全相等** ——
   临时 `.tad/` 缺 ralph-loops 等目录，会额外产生若干 WARNING，属预期。

### Phase 1: 负控先行（预计 25 分钟）

⚠️ **必须先让 AC-01 变红，再改代码。** 否则无法证明 fixture 真在测东西
（`principles.md`：「验证了替身，没验证对象」）。

5. 建 `.tad/evidence/acceptance-tests/gate3-check8-audible/`
6. 按 §9 写 7 个 fixture 脚本
7. **改代码前**跑 `AC-01`，必须 **FAIL**，输出存 `baseline-red.txt`

### Phase 2: 改代码（预计 5 分钟）

8. 按 §4.2 插入 `else` 分支（**4 空格缩进**）
9. `bash -n .tad/hooks/pre-gate-check.sh` 必须 exit 0
10. 重跑全部 fixture：AC-01 由红转绿，其余保持绿

### Phase 3: 回归 + 范围核对（预计 15 分钟）

11. 跑 §9 的 AC12-AC15（范围与守卫）
12. `git diff HEAD --stat -- .tad/hooks/pre-gate-check.sh` 确认 `+2 / -0`

---

## 7. File Structure

### 7.1 Files to Create

| 文件 | 用途 | 对应 FR |
|---|---|---|
| `AC-01-missing-verdict.sh` | 负控主证：无判定行 → 出声 | FR1 |
| `AC-02-fail-still-blocks.sh` | E4 回归：FAIL 仍拦（**断言 stderr 文案**） | FR3a |
| `AC-03-pass-stays-quiet.sh` | FR3b 回归（**配 liveness 正断言**） | FR3b |
| `AC-04-template-line-still-warns.sh` | FR3c 回归：有行无 PASS/FAIL | FR3c |
| `AC-05-no-completion-blocks.sh` | E1 回归 | FR3d |
| `AC-06-e2e-research-block.sh` | E2/E3 回归 | FR4 |
| `AC-07-carrier-json.sh` | 载体：jq 与 no-jq 两分支 | FR1 |
| `baseline-red.txt` | 改前 AC-01 的红色输出 | — |

（目录：`.tad/evidence/acceptance-tests/gate3-check8-audible/`）

### 7.2 Files to Modify — ⚠️ ALLOW-LIST（不是 deny-list）

**只准修改这一个既存文件**：

| 文件 | 改动 | 行数 |
|---|---|---|
| `.tad/hooks/pre-gate-check.sh` | L201-202 之间插入 `else` 分支 | **+2 / −0** |

**其余一切既存文件一律禁止修改。** 以下四类尤其危险，**改了会让 11 个 AC 全绿而闸已死**
（所有 AC 都用直接路径调脚本，绕过注册层）——已配 AC13 显式守卫：

| 禁改 | 为什么它能悄悄废掉这个闸 |
|---|---|
| `.claude/settings.json` | L59 是 hook 的**注册处**。删了它，hook 根本不再被触发 |
| `.claude/settings.local.json` | 同样带 `hooks` 键（11 处匹配），可覆盖注册 |
| `.tad/hooks/lib/common.sh` | `safe_count`(L191) 恒返回 0 → **E1 主拦截直接失效**；`output_response`(L37) 是载体 |
| `.tad/hooks/lib/hook-envelope.sh` | 解析层，改了可让整个 Gate 3 块永不进入 |

**另外禁止**：
- ❌ 不动 L192 的 grep 模式（扩 grep 是错方向，见 §2.1）
- ❌ 不动其他 11 个 check
- ❌ 不动 `post-write-sync.sh`
- ❌ 不动模板、不动 Blake 的 `completion_protocol`
- ❌ **不动 `NEXT.md` / `PROJECT_CONTEXT.md`** —— 它们的改动是 Alex 有意为之（修正过期信息）。
  **它们已经在你开工前就是脏的，这是预期状态。回滚它们 = 违反本节。**

> 采用 allow-list 而非 deny-list 的依据：`principles.md` 2026-08-06 修订
> ——写权限是**无界集合**，无界集合上 deny-list 的 fail-open 面无限。

### 7.3 Grounded Against

以下事实由 Alex + 2 名专家于 2026-08-16 实测。Blake 若发现不符请立刻停下报告：

| 事实 | 验证命令 | 期望 |
|---|---|---|
| hook 已注册 | `grep -c 'pre-gate-check.sh' .claude/settings.json` | `1` |
| 无 set -e | `grep -c 'set -e' .tad/hooks/pre-gate-check.sh \|\| true` | `0` |
| 内层已有 else | `sed -n '199p' .tad/hooks/pre-gate-check.sh` | 6 空格 + `else` |
| 外层无 else | `sed -n '202p' .tad/hooks/pre-gate-check.sh` | 4 空格 + `fi` |
| HAS_BLOCK 赋值点 | `grep -c 'HAS_BLOCK=1' .tad/hooks/pre-gate-check.sh` | `3` |
| WARNINGS 拼接行 | `grep -cF 'WARNINGS="${WARNINGS}"' .tad/hooks/pre-gate-check.sh` | `15` |

---

## 8. Testing Requirements

### 8.1 Unit Tests
§7.1 的 7 个 fixture 即单元测试。

### 8.2 Integration Tests
AC9/AC10（真实 envelope 三形态）+ AC11（载体 JSON）。

### 8.3 Edge Cases

| 场景 | 期望 |
|---|---|
| COMPLETION 是空文件 | 走新 else → WARNING，不拦。⚠️ Check 6 也会触发 KA 警告，故只断言 containment |
| 判定行同时含 PASS 和 FAIL（模板未填） | 走 FAIL 分支 → BLOCK（**现状行为，不改**） |
| 多份 COMPLETION | `head -1` 取字母序第一份（**现状行为，不改**）；新文案会点名它 |

## 8.4 Friction Preflight

| 前置 | 状态 | 缺失时的修法 |
|---|---|---|
| bash + BSD grep/sed（macOS） | READY | 本机自带；`sed -n 'addr,+N p'` 已验证本机可用 |
| `.tad/hooks/lib/common.sh` 可 source | READY | 已验证 |
| `mktemp -d` 可用 | READY | 本机自带 |
| `jq`（仅 AC11 的一半） | 未验 | 缺失 → 该半条标 `EQUIVALENT_SUBSTITUTE`，用 no-jq 分支 + 手工解析，并在报告说明 |
| 网络 / 外部 CLI | 不需要 | — |

**无 BLOCKED 项。** 遇到本表未列出的摩擦：按 `tad_friction_protocol` 处理——
修复它或标 BLOCKED，**不得**以摩擦为由跳过 AC。

## 8.5 Feedback Collection
`feedback_required: false` — 无非代码产物。

## 8.6 Test Evidence Required
- `baseline-red.txt`（改前 AC-01 失败输出）
- 7 个 AC 的绿色输出
- `/tmp/g3c8/` 下 6 份基线文件
- `git diff HEAD --stat -- .tad/hooks/pre-gate-check.sh` 输出

---

## 9. Acceptance Criteria

> ⚠️ **所有涉及 hook 行为的 AC 必须在 `mktemp -d` 沙箱里跑**（§6.1）。
> 在仓库根跑会因为「当前有没有 COMPLETION 文件」而给出相反结果 —— rev1 的 P0。

**A 组 — 新分支行为（FR1/FR2）**

- [ ] **AC1**：改动**前** `AC-01-missing-verdict.sh` **FAIL**，输出存入 `baseline-red.txt`
- [ ] **AC2**：改动**后** `AC-01` PASS —— 沙箱内放一份无判定行的 COMPLETION，断言
      **exit 0** 且 stdout 含 `No Gate 3 verdict line found` 且含该 COMPLETION 的文件名

**B 组 — Check 8 内部四条路径回归（FR3）**

- [ ] **AC3**：`AC-02` — 判定行 `**Gate 3 v2 结果**: ❌ FAIL` → **exit 2**
      **且 stderr 含 `BLOCKED: Completion report shows Gate 3 FAIL`**
      （只断言 exit 2 不够：文件名拼错导致的 E1 也是 exit 2，会假绿）
- [ ] **AC4**：`AC-03` — 判定行含 PASS → **exit 0** 且 stdout **含** `Gate 3 prerequisites met`
      （liveness 正断言）**且不含** `No Gate 3 verdict line found`
- [ ] **AC5**：`AC-04` — 判定行为 `**Gate 3 Result**: TBD`（有行、无 PASS/FAIL）→
      stdout 含 `doesn't contain PASS or FAIL` **且不含** `No Gate 3 verdict line found`
- [ ] **AC6**：`AC-05` — 沙箱内 `.tad/active/handoffs/` 为空 → **exit 2**
      且 stderr 含 `no COMPLETION report found`

**C 组 — Check 8 之外的 BLOCK 路径回归（FR4）**

- [ ] **AC7**：`AC-06` E2 分支 — handoff frontmatter `e2e_required: yes` 且无 e2e 证据 →
      exit 2 且 stderr 含 `BLOCKED: Handoff requires E2E`
- [ ] **AC8**：`AC-06` E3 分支 — `research_required: yes` 且无研究证据 →
      exit 2 且 stderr 含 `BLOCKED: Handoff requires research`

**D 组 — hook 管道回归（在沙箱内）**

- [ ] **AC9**：`{"skill":"gate","args":"4"}` → exit 0 且输出 Gate 4 相关文案（未波及 Gate 4）
- [ ] **AC10**：`{"skill":"alex","args":""}` → stdout `{}` 且 exit 0（非 gate skill 仍放行）

**E 组 — 载体（这一刀的全部意义）**

- [ ] **AC11**：`AC-07` — AC2 的场景下，
      (a) `| jq -e -r '.hookSpecificOutput.additionalContext' | grep -q 'No Gate 3 verdict line found'` 通过；
      (b) 在 `PATH=/usr/bin:/bin`（无 jq）下重跑，手工解析仍能看到该文案
      （覆盖 `common.sh` 的两个 `output_response` 实现）

**F 组 — 范围与守卫**

- [ ] **AC12**：`git diff HEAD --stat -- .tad/hooks/pre-gate-check.sh`
      → `1 file changed, 2 insertions(+)`，**0 deletions**
- [ ] **AC13**：**闸未被从旁路废掉** —— 三条同时成立：
      `git diff HEAD --stat -- .claude/ .tad/hooks/lib/` **为空**；
      `grep -c 'pre-gate-check.sh' .claude/settings.json` == `/tmp/g3c8/baseline-registration.txt`；
      `grep -c 'HAS_BLOCK=1' .tad/hooks/pre-gate-check.sh` == `/tmp/g3c8/baseline-hasblock.txt`（`3`）
- [ ] **AC14**：**无范围蔓延** ——
      `diff <(git diff HEAD --name-only) /tmp/g3c8/baseline-diff-names.txt`
      唯一新增行是 `.tad/hooks/pre-gate-check.sh`
- [ ] **AC15**：**无 fixture 泄漏** ——
      ```
      diff <(ls -1 .tad/active/handoffs/ | grep -v '^COMPLETION-20260816-gate3-check8-audible\.md$') \
           /tmp/g3c8/baseline-handoffs.txt
      ```
      **无差异**。
      （⚠️ 这条替代 rev1 的 `git status --porcelain`：那条对未跟踪目录内的泄漏结构性失明）

      > **⚠️ Gate 4 修正（2026-08-16，Alex）**：本条原判据**不含那行 `grep -v`**，
      > 因而在 Blake 写出 COMPLETION 报告后**必然 FAIL** —— 红的原因是一份**合法产物**，
      > 不是泄漏。这与 Gate 2 两名专家抓到的 AC5/AC6 时间炸弹**是同一个形状**：
      > rev2 修了被点名的 AC5/AC6，**漏了同形状的 AC15**（「改一个机制要横向扫兄弟位置」的反例）。
      > Gate 4 实测：原判据 FAIL；加 `grep -v` 排除本单合法 COMPLETION 后 **PASS（无泄漏）**。
      > 已蒸馏进 `patterns/ac-verification.md`「断言仓库当前状态的 AC 会在验收时点反转」。

## 9.1 Spec Compliance Checklist ⚠️ Gate 3 逐行执行

> 每条 Verification Method 都是**可直接复制粘贴的完整命令**（rev1 有两条漏了文件参数会 hang，已修）。

| # | 规格要求 | 验证方法 | 期望证据 |
|---|---|---|---|
| 1 | else 加在**第 2 层**、4 空格 | `awk 'NR>=190 && NR<=206 {printf "%3d|%s\n", NR, $0}' .tad/hooks/pre-gate-check.sh` | 新 `else` 前导恰 4 空格；原 L199 `else` 仍在且为 6 空格 |
| 2 | 新分支不设 HAS_BLOCK | `grep -A2 'No Gate 3 verdict line found' .tad/hooks/pre-gate-check.sh` | 输出中无 `HAS_BLOCK` |
| 3 | HAS_BLOCK 赋值点总数不变 | `grep -c 'HAS_BLOCK=1' .tad/hooks/pre-gate-check.sh` | `3` |
| 4 | grep 模式未被改动 | `sed -n '192p' .tad/hooks/pre-gate-check.sh` | 仍含 `Gate 3.*结果\|Gate 3.*Result` |
| 5 | 沿用既有 WARNINGS 惯例 | `grep -cF 'WARNINGS="${WARNINGS}"' .tad/hooks/pre-gate-check.sh` | `16`（改前 15） |
| 6 | 文案点名文件 | `grep -cF 'No Gate 3 verdict line found in ${COMPLETION_FILE}' .tad/hooks/pre-gate-check.sh` | `1` |
| 7 | 语法合法 | `bash -n .tad/hooks/pre-gate-check.sh; echo "exit=$?"` | `exit=0` |
| 8 | 改动范围 | `git diff HEAD --stat -- .tad/hooks/pre-gate-check.sh` | `1 file changed, 2 insertions(+)`，无 deletions |
| 9 | 旁路守卫 | `git diff HEAD --stat -- .claude/ .tad/hooks/lib/` | 空输出 |
| 10 | 无 fixture 泄漏 | `diff <(ls -1 .tad/active/handoffs/) /tmp/g3c8/baseline-handoffs.txt; echo "exit=$?"` | `exit=0` |
| 11 | 负控真的红过 | `cat .tad/evidence/acceptance-tests/gate3-check8-audible/baseline-red.txt` | 非空，明确显示 AC-01 改前 FAIL |
| 12 | fixture 不在仓库内跑 | `grep -L 'REFUSING' .tad/evidence/acceptance-tests/gate3-check8-audible/AC-*.sh` | 空输出（每个脚本都有守卫） |

## 9.2 Expert Review Status (Alex 必填)

### Experts Selected
- `code-reviewer`（必选）— 规格可执行性
- `security-auditor`（本单改的是质量闸的拦截行为，属 SAFETY 面）— 闸的 blast radius

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|---|---|---|---|
| code-reviewer | **P0-1** AC5/AC6 在 Blake 写出 COMPLETION 后反转，正确实现会被判 FAIL | §9 前置警告 + AC6/AC9/AC10 改沙箱执行；§6.1 | ✅ Fixed |
| code-reviewer | **P0-2** AC9 不可满足（工作区开工前已脏），唯一补救违反 §7.2 | §9 AC12 收窄到单文件 + AC14 用基线集差；§7.2 显式声明不得回滚 | ✅ Fixed |
| code-reviewer | P1-1 §4.2「4 空格」与「与 L199 同列」自相矛盾 | §4.2 改正并标注 rev1 错误 | ✅ Fixed |
| code-reviewer | P1-2 §9.1 row 2/5 无文件参数，逐字跑会 hang | §9.1 全表改为完整命令 | ✅ Fixed |
| code-reviewer | P1-3 AC11 无干净基线可比 | §6 Phase 0 B1-B6 捕获基线 | ✅ Fixed |
| code-reviewer | P1-4 FR3c（有行无 PASS/FAIL）无 AC | 新增 AC5 / `AC-04` | ✅ Fixed |
| code-reviewer | P2-1 HAS_BLOCK 改前值未捕获 | §6 Phase 0 B4 | ✅ Fixed |
| code-reviewer | P2-2 `grep -c` 零匹配 exit 1 | §6 Phase 0 全部加 `\|\| true` + §📚 提示 | ✅ Fixed |
| code-reviewer | P2-3 AC-01 断言 stdout，但 BLOCK 时走 stderr | AC2 加 `exit 0` 断言；§6.1 要求 fixture 自带 `e2e_required: no` 桩 | ✅ Fixed |
| code-reviewer | P2-4 空文件时 Check 6 也触发，全等断言会破 | §6.1 第 4 条 + §8.3 | ✅ Fixed |
| security-auditor | **P0-1** AC11 对 fixture 泄漏结构性失明（未跟踪目录被折叠）；`head -1` 字母序使泄漏文件成为权威报告 | AC15 改用 `ls -1` 快照；§6 Phase 0 用 `-uall`；§6.1 refuse-to-run 守卫；§9.1 row 12 | ✅ Fixed |
| security-auditor | **P0-2** AC5 时间炸弹，诱导实现者删改 gate 状态让测试变绿 | 同 code-reviewer P0-1：全部沙箱化；AC6 加 stderr 断言 | ✅ Fixed |
| security-auditor | **P0-3** §7.2 漏 `settings.json` / `settings.local.json` / `common.sh` —— 改任一处可让 11 个 AC 全绿而闸已死 | §7.2 改为 allow-list + 危险文件表；新增 AC13 旁路守卫；§9.1 row 9 | ✅ Fixed |
| security-auditor | P1-1 E2/E3 无行为 AC | 新增 AC7/AC8 + `AC-06` | ✅ Fixed |
| security-auditor | P1-2 AC3 只断言 exit 2，实证可因 E1 假绿 | AC3 加 stderr 文案断言 | ✅ Fixed |
| security-auditor | P1-3 AC4 裸负断言，空目录也过 | AC4 加 liveness 正断言 | ✅ Fixed |
| security-auditor | P1-4 未验证 WARNING 穿过 `output_response` 两个实现 | 新增 AC11 + `AC-07`；§4.3 载体链 | ✅ Fixed |
| security-auditor | P1-5 AC9/AC11 对脏基线不可验 | AC12 收窄 + AC14/AC15 基线集差 | ✅ Fixed |
| security-auditor | P2-1 `args` 形状（` 3`、`gate 3`）可绕过整个 Gate 3 块 | 记入 §10.2（**范围外**，但必须留档） | ✅ Recorded |
| security-auditor | P2-2 §2.1 反驳了比 NEXT.md 更强的主张 | §2.1 第 1 条改为「不精确而非全错」并给出准确表述 | ✅ Fixed |
| security-auditor | P2-3 WARNING 未点名所读文件 | §4.2 插值 `${COMPLETION_FILE}`；§9.1 row 6 | ✅ Fixed |
| security-auditor | P2-4 zsh 内建 `echo` 会破坏 JSON | §6.1 第 1 条强制 `#!/bin/bash` + `printf` | ✅ Fixed |
| security-auditor | P2-5 `git diff` 未带 HEAD，提交后会空过 | AC12/AC14 全部改用 `git diff HEAD` | ✅ Fixed |

### Overall Assessment (post-integration)
两名专家均给 **CONDITIONAL**，且**都在沙箱里实际打过补丁**，一致确认：
§4.1 结构图逐行准确、§4.2 插入点正确、实测 `+2/−0`、`bash -n` 干净、四条路径行为全对、
`HAS_BLOCK` 计数不变、新分支不引入静默路径。**代码设计零 P0。**
5 个 P0 全部落在验收层，已逐条整合（上表）。rev2 代码改动与 rev1 完全一致。

---

## 10. Important Notes

### 10.1 Critical Warnings

⚠️ **这个 if 有三层，内层第 199 行已经有一个 `else`。** 改错层是本单最可能的失败方式。

⚠️ **所有 hook 行为 AC 必须在沙箱里跑。** 在仓库根跑，结果取决于「此刻有没有 COMPLETION 文件」——
Blake 自己写 COMPLETION 的那一刻，同一条命令的结果就反过来了。

⚠️ **绝不让 fixture 写进真的 `.tad/active/handoffs/`。** 那里泄漏一个 `COMPLETION-00-*.md`，
会因字母序成为 hook 眼中的权威报告，让**未来真正的 Gate 3 静默放行**。

⚠️ **不要"顺手"改进别的东西。** 上一轮英文化那单就是栽在范围蔓延上
（三轮审查、18 个 P0、零交付）。

⚠️ **不要把 `NEXT.md` §0 的原方案当依据**，也**不要回滚 `NEXT.md` / `PROJECT_CONTEXT.md`**。

### 10.2 Known Constraints（本单刻意不解决 —— 范围切分，不是遗漏）

**(a) 上游根本不写 Gate 3 判定标记。** 近期 18/20 份 COMPLETION 既无正文自评行也无
frontmatter `gate3_verdict:`。即使本单改完，新 WARNING 会在 90% 的情况下触发。
**这是对的**——它如实反映"我读不到判定"。真正的修法在上游
（Blake `completion_protocol` step4b/step5 + 两个模板要真的落地），跨协议面，Alex 另开一单。
**副产品**：这条 WARNING 的触发率本身就是「上游修好没有」的度量。

**(b) `args` 形状可绕过整个 Gate 3 块。** security-auditor 实测：
`GATE_NUM` 由 `grep -oE '^[0-9]+'`（L56）解析，行首锚定。

| `args` | 结果 |
|---|---|
| `"3"` / `"3 force"` | exit 2 ✅ |
| `" 3"`（前导空格） | `{}` exit 0 —— **整个 Gate 3 块被跳过** |
| `"gate 3"` | `{}` exit 0 —— **同上** |

**本单范围外**，但必须留档：否则「E1 是真正的闸」这个前提会被下一张单当成无条件成立继承。

**(c) `head -1` 按字母序选 COMPLETION。** 多份报告时选中的未必是当前这份。
本单只做到「文案点名它读了哪个文件」，不改选择逻辑。

### 10.3 Sub-Agent 使用建议

| Sub-Agent | 建议 | 时机 |
|---|---|---|
| `test-runner` | 必须 | Phase 1 fixture 写完后、Phase 3 回归 |
| `code-reviewer` | 必须（Layer 2） | 实现完成后 |
| `bug-hunter` | 仅当 fixture 行为不符预期 | 按需 |

---

## 11. Learning Content

### 11.1 Decision Rationale: 为什么是 WARNING 而不是 BLOCK

一个失效的闸有两种修法，代价方向相反：

- **修成 BLOCK**：安全上限高，但当"合规产出"本身还不存在时（18/20 不带标记），
  它每次都误拦。人的应对必然是绕过或关掉它——最后闸还是没了，还多了摩擦。
- **修成 WARNING**：安全上限低（自评 FAIL 仍可能溜过），但**它诚实**。

选后者的关键理由：**这个缺陷的实质危害是"静默"，不是"不拦"。**
一个会出声的弱闸，比一个沉默的假闸有用——后者会让人以为已经检查过了。

### 11.2 rev1 → rev2 的教训（比这一刀本身更值钱）

rev1 的代码设计零 P0，**5 个 P0 全在验收层**。这是个反复出现的形状：
**想清楚要改什么，比想清楚怎么证明它改对了，容易得多。**

三个具体的坑，都值得进 project-knowledge：

1. **AC 会随时间反转。** AC5 在写 handoff 的时刻是真的（`handoffs/` 空 → exit 2），
   在验收的时刻是假的（Blake 已写 COMPLETION → exit 0）。
   **凡是断言"当前仓库状态"的 AC，都要问：验收发生时这个状态还成立吗？**
2. **`git status --porcelain` 对未跟踪目录内部的变化结构性失明。**
   它把整个未跟踪目录折叠成一行。用它当"没泄漏文件"的证据是无效的，
   必须 `-uall` 或直接 `ls` 目录内容。
3. **AC 全部绕过注册层调用被测对象时，注册层本身就成了盲区。**
   11 个 AC 直接 `bash path/to/hook.sh`，所以删掉 `settings.json` 里的注册行，
   全部 AC 依然绿，而 hook 再也不会被触发。**测被测对象，也要测它有没有被接上。**
4. **BSD grep 会把模式中间的 `$` 当锚点** —— `grep -c 'WARNINGS="${WARNINGS}"' file`
   在本机返回 **0**，真值是 15。Alex 在起草 rev2 时**自己踩了这一次**：
   四条 AC 全写成未转义版本，空跑才发现。修法：`-F` 或 `\$`。
   ⚠️ 这条已经比这一刀本身更值钱——它同时验证了 `session-state` 里那条
   「任何返回 0 的检查先换一种方法复验」是**当前仍然有效的**纪律，不是历史记录。
   建议 Gate 4 时把它蒸馏进 `patterns/shell-portability.md`（那里目前没有这条）。

### 11.3 What-If

**如果上游哪天真的开始稳定写判定标记了？** 那时这条 WARNING 的触发率会自然降到接近 0，
届时再升级成 BLOCK 就是安全的——**升级的前提是触发率先降下来**，不是反过来。

---

## 12. Sub-Agent 使用记录

| Sub-Agent | 是否调用 | 时机 | 输出摘要 | 证据 |
|---|---|---|---|---|
| ⬚ Blake 填写 | | | | |
